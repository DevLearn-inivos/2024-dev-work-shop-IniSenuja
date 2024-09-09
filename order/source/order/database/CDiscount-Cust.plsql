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
   CURSOR get_records IS
    SELECT *
    FROM c_discount;
   
BEGIN
   
   FOR record_ IN get_records LOOP
--      Error_Sys.Record_General('ERROR',newrec_.sales_grp||newrec_.sales_grp);
      IF (newrec_.disc_type = record_.disc_type_db 
         
--         AND (newrec_.sales_part = record_.sales_part) 
--         AND newrec_.sales_grp = record_.sales_grp 
--         AND newrec_.cus_id = record_.cus_id
--         AND newrec_.cus_grp = record_.cus_grp 
         )
      THEN    
         IF newrec_.sales_part IS NOT NULL THEN 
            IF newrec_.sales_part = record_.sales_part THEN
               IF newrec_.cus_id IS NOT NULL THEN
                  IF newrec_.cus_id = record_.cus_id THEN
                     Error_Sys.Record_General('ERROR','The record exists');
                  END IF;
               ELSE    
                  IF newrec_.cus_grp = record_.cus_grp THEN
                     Error_Sys.Record_General('ERROR','The record exists');
                  END IF;   
               END IF;
            END IF;
         ELSE
            IF newrec_.sales_grp = record_.sales_grp THEN
               IF newrec_.cus_id IS NOT NULL THEN
                  IF newrec_.cus_id = record_.cus_id THEN
                     Error_Sys.Record_General('ERROR','The record exists');
                  END IF;
               ELSE    
                  IF newrec_.cus_grp = record_.cus_grp THEN
                     Error_Sys.Record_General('ERROR','The record exists');
                  END IF;   
               END IF;
            END IF;   
         END IF;     
      END IF;
   END LOOP;   
   
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
