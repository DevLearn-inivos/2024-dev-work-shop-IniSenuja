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
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-------------------- LU CUST NEW METHODS -------------------------------------
