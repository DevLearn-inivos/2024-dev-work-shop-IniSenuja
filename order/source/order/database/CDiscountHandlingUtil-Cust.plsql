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

PROCEDURE Create_Customer_Order_Line(contract_ VARCHAR2,order_no_ VARCHAR2,catalog_no_ VARCHAR2) IS
   info_        VARCHAR2(3200);
   objid_       VARCHAR2(3200);
   objversion_  VARCHAR2(3200);
   attr_        VARCHAR2(3200);
   action_      VARCHAR2(3200);
   part_no_ VARCHAR2(32);
   c_order_no_ VARCHAR2(32);
   
   CURSOR get_default IS 
      SELECT attr
      FROM TABLE(Customer_Order_Handling_SVC.CRUD_Default('ORDER_NO'||chr(31)||'*1012'||chr(30), customer_order_line## => ''));
   get_default_rec_ VARCHAR2(3200); 
   
BEGIN
   OPEN get_default;
   FETCH get_default INTO get_default_rec_;
   CLOSE get_default;
   
   part_no_ := 'BATA-M';
   c_order_no_ := '*1012';
   attr_ := get_default_rec_;
   
   Client_SYS.Add_To_Attr('SALES_UNIT_MEAS',Sales_Part_API.Get_Sales_Unit_Meas(contract_, catalog_no_), attr_);
   Client_SYS.Add_To_Attr('BASE_SALE_UNIT_PRICE', 0, attr_);
   Client_SYS.Add_To_Attr('BASE_UNIT_PRICE_INCL_TAX', 0, attr_);
   Client_SYS.Add_To_Attr('CATALOG_TYPE', 'Inventory part', attr_);
   Client_SYS.Add_To_Attr('SALE_UNIT_PRICE', 0, attr_);
   Client_SYS.Add_To_Attr('UNIT_PRICE_INCL_TAX', 0, attr_);
   Client_SYS.Add_To_Attr('SUPPLY_CODE', 'Invent Order', attr_);
   Client_SYS.Add_To_Attr('CLOSE_TOLERANCE', 0, attr_);
   Client_SYS.Add_To_Attr('PART_PRICE', 2000, attr_);
   Client_SYS.Add_To_Attr('PRICE_SOURCE', 'Copied', attr_);
   Client_SYS.Add_To_Attr('CONTRACT', 'SI-RP', attr_);
   Client_SYS.Add_To_Attr('CATALOG_NO', 'BATA-M', attr_);
   Client_SYS.Add_To_Attr('BUY_QTY_DUE', 5, attr_);

   Customer_Order_Line_API.New__(info_,
                                 objid_,
                                 objversion_,
                                 attr_,
                                 'DO');
END Create_Customer_Order_Line;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-------------------- LU CUST NEW METHODS -------------------------------------
