-----------------------------------------------------------------------------
--
--  Logical unit: CDiscount
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


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT c_discount_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   IF newrec_.buy_qty IS NOT NULL THEN
      IF newrec_.buy_qty <= 0 THEN
         Error_Sys.Record_General('ERROR','Buy / Free Issue Quantity cant be zero or negative.');
      END IF;
   END IF;
   IF newrec_.free_iss_qty IS NOT NULL THEN
      IF newrec_.free_iss_qty <= 0 THEN
         Error_Sys.Record_General('ERROR','Buy / Free Issue Quantity cant be zero or negative.');
      END IF;
   END IF;
   
   IF newrec_.dis_per IS NOT NULL THEN
      IF NOT (newrec_.dis_per > 0 AND newrec_.dis_per <= 100) THEN
         Error_Sys.Record_General('ERROR','Discount Percentage should be between 1-100');
      END IF;
   END IF; 
   
   newrec_.discount_id := C_NEW_ENTITY_LINE_SEQ.NEXTVAL;
   
   super(objid_, objversion_, newrec_, attr_);
   
      
END Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


-------------------- LU CUST NEW METHODS -------------------------------------
