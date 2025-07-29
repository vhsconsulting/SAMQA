create table samqa.invoice_external (
    acc_num        varchar2(20 byte),
    start_date     varchar2(20 byte),
    end_date       varchar2(20 byte),
    invoice_date   varchar2(20 byte),
    invoice_amount varchar2(255 byte),
    account_type   varchar2(30 byte),
    reason_name    varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory invoice_upload_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'Upload_Invoice_Template.csv.bad'
            logfile 'Upload_Invoice_Template.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( invoice_upload_dir : 'Upload_Invoice_Template.csv' )
) reject limit 0;


-- sqlcl_snapshot {"hash":"2e6aa4018c8bf1a2e3baec24b5a4fd9848219199","type":"TABLE","name":"INVOICE_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>START_DATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>END_DATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_DATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_AMOUNT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACCOUNT_TYPE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>REASON_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>INVOICE_UPLOAD_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited by newline skip 1  badfile 'Upload_Invoice_Template.csv.bad'   logfile 'Upload_Invoice_Template.csv.log'   fields terminated by ','   optionally enclosed by '\"'   LRTRIM   MISSING FIELD VALUES ARE NULL</ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>INVOICE_UPLOAD_DIR</DIRECTORY>\n                  <NAME>Upload_Invoice_Template.csv</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>0</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}