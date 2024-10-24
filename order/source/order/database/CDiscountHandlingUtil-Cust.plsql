-----------------------------------------------------------------------------
--
--  Logical unit: CDiscountHandlingUtil
--  Component:    ORDER
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Cust;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- PRIVATE DECLARATIONSLU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Apply_Promotion(contract_ VARCHAR2,order_no_ VARCHAR2,catalog_no_ VARCHAR2,customer_  VARCHAR2) IS
   CURSOR get_discount_details (contract_  VARCHAR2,customer_  VARCHAR2,catalog_no_   VARCHAR2) IS
      SELECT *
      FROM C_DISCOUNT t
      WHERE t.CONTRACT = contract_
      AND    t.CUS_ID = customer_
      AND    t.SALES_PART = catalog_no_
      FETCH FIRST 1 ROWS ONLY;      
   get_discount_details_rec_  get_discount_details%ROWTYPE;
   
   qty_ NUMBER;
   disc_type_ VARCHAR2(15);
   promo_catalog_no_  VARCHAR2(15);
BEGIN   
   OPEN get_discount_details(contract_,customer_,catalog_no_);
   FETCH get_discount_details INTO get_discount_details_rec_;
   CLOSE get_discount_details;
   
   disc_type_ := get_discount_details_rec_.disc_type_db;
   IF disc_type_ = 'FREE_ISSUE' THEN
      qty_ := get_discount_details_rec_.free_iss_qty;
      promo_catalog_no_  :=  get_discount_details_rec_.free_sales;
      Create_Customer_Order_Line___(contract_,order_no_,promo_catalog_no_,qty_);
   ELSIF disc_type_ = 'SHRT_EXP' THEN 
      Apply_Discount___(contract_,order_no_,catalog_no_,get_discount_details_rec_.dis_per);
   END IF;   
END Apply_Promotion;

PROCEDURE Create_Customer_Order_Line___(contract_ VARCHAR2,order_no_ VARCHAR2,catalog_no_ VARCHAR2,qty_ NUMBER) IS
   info_        VARCHAR2(3200);
   objid_       VARCHAR2(3200);
   objversion_  VARCHAR2(3200);
   attr_        VARCHAR2(3200);
   action_      VARCHAR2(3200);
   part_no_ VARCHAR2(32);
   c_order_no_ VARCHAR2(32);
   
   CURSOR get_default(order_no_ VARCHAR2) IS 
      SELECT attr
      FROM TABLE(Customer_Order_Handling_SVC.CRUD_Default('ORDER_NO'||chr(31)||order_no_||chr(30), customer_order_line## => ''));
   get_default_rec_ VARCHAR2(3200); 
   
BEGIN
   OPEN get_default(order_no_);
   FETCH get_default INTO get_default_rec_;
   CLOSE get_default;
   
   attr_ := get_default_rec_;
   
   Client_SYS.Add_To_Attr('SALES_UNIT_MEAS',Sales_Part_API.Get_Sales_Unit_Meas(contract_, catalog_no_), attr_);
   Client_SYS.Add_To_Attr('BASE_SALE_UNIT_PRICE', 0, attr_);
   Client_SYS.Add_To_Attr('BASE_UNIT_PRICE_INCL_TAX', 0, attr_);
   Client_SYS.Add_To_Attr('CATALOG_TYPE', 'Inventory part', attr_);
   Client_SYS.Add_To_Attr('SALE_UNIT_PRICE', 0, attr_);
   Client_SYS.Add_To_Attr('UNIT_PRICE_INCL_TAX', 0, attr_);
   Client_SYS.Add_To_Attr('SUPPLY_CODE', 'Invent Order', attr_);
   Client_SYS.Add_To_Attr('CLOSE_TOLERANCE', 0, attr_);
   Client_SYS.Add_To_Attr('PART_PRICE', Sales_Part_API.Get_List_Price(contract_, catalog_no_), attr_);
   Client_SYS.Add_To_Attr('PRICE_SOURCE_DB', 'BASE', attr_);
   Client_SYS.Add_To_Attr('CONTRACT', contract_, attr_);
   Client_SYS.Add_To_Attr('CATALOG_NO', catalog_no_, attr_);
   Client_SYS.Add_To_Attr('BUY_QTY_DUE', qty_, attr_);
   
   Customer_Order_Line_API.New__(info_,
                                 objid_,
                                 objversion_,
                                 attr_,
                                 'DO');
END Create_Customer_Order_Line___;

PROCEDURE Apply_Discount___(contract_ VARCHAR2,order_no_ VARCHAR2,catalog_no_ VARCHAR2,discount_ NUMBER)
IS
   attr_        VARCHAR2(3200);
BEGIN
   NULL;
    Client_SYS.Add_To_Attr('DISCOUNT', discount_, attr_);
    Customer_Order_Line_API.Modify(attr_,
                                   order_no_,
                                   1,
                                   1,
                                   0);
END Apply_Discount___;

PROCEDURE Val_Disc_Apply IS
   
   result_ C_PROMOTION_HANDLING_SVC.ENTITY_DEC;
   
   CURSOR get_val_disc_rec IS
      SELECT *
      FROM c_discount t ;
      
   CURSOR get_invoice_amt(contract_ VARCHAR2,customer_ VARCHAR2,catalog_no_ VARCHAR2) IS   
      SELECT SUM(t.net_curr_amount)
      FROM customer_order_inv_join t
      WHERE t.contract = contract_
      AND t.catalog_no = catalog_no_
      AND t.identity = customer_
      AND t.head_objstate_db != 'Cancelled';
   get_invoice_amt_ NUMBER;
   
BEGIN
   FOR rec_ IN get_val_disc_rec LOOP
      IF rec_.disc_type_db = 'VAL_DIS' AND rec_.state = 'A' AND (SYSDATE BETWEEN rec_.from_date AND rec_.to_date) AND rec_.ach_amt IS NULL THEN
         OPEN get_invoice_amt(rec_.contract,rec_.cus_id,rec_.sales_part);
         FETCH get_invoice_amt INTO get_invoice_amt_;
         CLOSE get_invoice_amt;
         
         IF get_invoice_amt_ >= rec_.tar_amt THEN   
         result_ :=  C_Promotion_Handling_SVC.CRUD_Update('*',
                                                          rec_.discount_id,
                                                          'ACH_AMT'||chr(31)||get_invoice_amt_||chr(30),
                                                          'DO',
                                                          c_discount## => '');
         New_Instant_Invoice(rec_.cus_id);
         END IF;                                                 
      END IF;   
   END LOOP;   
END Val_Disc_Apply;

PROCEDURE New_Instant_Invoice(customer_ VARCHAR2) IS
   attr_          VARCHAR2(32000);
   info_          VARCHAR2(32000);
   objid_         VARCHAR2(4000);
   objversion_    VARCHAR2(4000);  
   
   --customer_ VARCHAR2(50);
   CURSOR get_addr(customer_ VARCHAR2) IS
      SELECT address_id 
      FROM customer_info_address t
      WHERE t.customer_id = customer_
      FETCH FIRST 1 ROWS ONLY;
   get_addr_ VARCHAR2(50);

   CURSOR get_company(customer_ VARCHAR2) IS
      SELECT B.company
      FROM CUSTOMER_INFO A
      JOIN IDENTITY_INVOICE_INFO B
      ON A.party_type_db = B.party_type_db
      AND A.customer_id = B.identity
      WHERE A.customer_id = customer_
      FETCH FIRST 1 ROWS ONLY;
   get_company_ VARCHAR2(50);
   
BEGIN
   --customer_ := 'RANPA DEALER-KANDY';
   
   OPEN get_addr(customer_);
   FETCH get_addr INTO get_addr_;
   CLOSE get_addr;
   
   OPEN get_company(customer_);
   FETCH get_company INTO get_company_;
   CLOSE get_company;

   Client_SYS.Add_To_Attr('CREATOR', 'INSTANT_INVOICE_API', attr_);
   Client_SYS.Add_To_Attr('INVOICE_TYPE', 'INSTINV', attr_);
   Client_SYS.Add_To_Attr('COMPANY', get_company_, attr_);   
   Client_SYS.Add_To_Attr('IDENTITY', customer_, attr_);
   Client_SYS.Add_To_Attr('PAYER_IDENTITY',customer_, attr_);
   Client_SYS.Add_To_Attr('INVOICE_DATE', sysdate, attr_);
   Client_SYS.Add_To_Attr('DELIVERY_DATE', sysdate, attr_);  
   Client_SYS.Add_To_Attr('CURRENCY', Company_API.GET_CURRENCY_CODE(get_company_), attr_);
   Client_SYS.Add_To_Attr('CURR_RATE', Currency_Code_API.Get_Conv_Factor(get_company_,Company_API.GET_CURRENCY_CODE(get_company_)), attr_);
   Client_SYS.Add_To_Attr('TAX_CURR_RATE',1, attr_);
   Client_SYS.Add_To_Attr('INVOICE_ADDRESS_ID',get_addr_, attr_);
   Client_SYS.Add_To_Attr('DELIVERY_ADDRESS_ID',get_addr_, attr_);
   Client_SYS.Add_To_Attr('USE_PROJ_ADDRESS_FOR_TAX_DB','FALSE', attr_);
   Client_SYS.Add_To_Attr('USE_DELIVERY_INV_ADDRESS_DB','FALSE', attr_);  
   Client_SYS.Add_To_Attr('SUPPLY_COUNTRY_DB',Customer_Info_API.Get_Country_Db(customer_), attr_);
   Client_SYS.Add_To_Attr('PAY_TERM_ID',0, attr_);
   Client_SYS.Add_To_Attr('TAX_LIABILITY','TAX', attr_);
   Instant_Invoice_API.New__(info_, objid_, objversion_, attr_, 'DO');
END  New_Instant_Invoice; 
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-------------------- LU CUST NEW METHODS -------------------------------------
