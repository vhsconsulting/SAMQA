
  CREATE TABLE "SAMQA"."GP_FEE_ERROR_EXTERNAL" 
   (	"BATCH_NUMBER" VARCHAR2(255 BYTE), 
	"ENTITYID" VARCHAR2(255 BYTE), 
	"DOCNUM" VARCHAR2(255 BYTE), 
	"DOCTYPE" VARCHAR2(255 BYTE), 
	"DOCDATE" VARCHAR2(255 BYTE), 
	"DUEDATE" VARCHAR2(255 BYTE), 
	"DESCRIPTION" VARCHAR2(255 BYTE), 
	"TXN_AMOUNT" VARCHAR2(255 BYTE), 
	"GP_ACC_NUMBER" VARCHAR2(255 BYTE), 
	"DEBITAMT" VARCHAR2(255 BYTE), 
	"CREDITAMT" VARCHAR2(255 BYTE), 
	"DISTTYPE" VARCHAR2(255 BYTE), 
	"RECORD_NUMBER" VARCHAR2(255 BYTE), 
	"ERROR_MESSAGE" VARCHAR2(255 BYTE)
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "GP"
      ACCESS PARAMETERS
      ( records delimited BY newline skip 1 
        fields terminated BY ',' optionally enclosed by '"' missing field VALUES are NULL 
        badfile'GP_FEE_ERROR_EXTERNAL.bad'  logfile'GP_FEE_ERROR_EXTERNAL.log'
          )
      LOCATION
       ( "GP":'GP_4333743_inv04292015_ERRORS.CSV'
       )
    )
   REJECT LIMIT UNLIMITED ;


-- sqlcl_snapshot {"hash":"2215ec072fbefc0f963f191f6b6991f5cbe6c577","type":"TABLE","name":"GP_FEE_ERROR_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>GP_FEE_ERROR_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTITYID</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DOCNUM</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DOCTYPE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DOCDATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DUEDATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DESCRIPTION</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TXN_AMOUNT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>GP_ACC_NUMBER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DEBITAMT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CREDITAMT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DISTTYPE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>RECORD_NUMBER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ERROR_MESSAGE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>GP</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited BY newline skip 1 \n        fields terminated BY ',' optionally enclosed by '\"' missing field VALUES are NULL \n        badfile'GP_FEE_ERROR_EXTERNAL.bad'  logfile'GP_FEE_ERROR_EXTERNAL.log'\n          </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>GP</DIRECTORY>\n                  <NAME>GP_4333743_inv04292015_ERRORS.CSV</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}