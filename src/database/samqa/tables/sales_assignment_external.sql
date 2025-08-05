create table samqa.sales_assignment_external (
    acc_num        varchar2(100 byte),
    sales_rep_name varchar2(1000 byte),
    effective_date varchar2(1000 byte),
    salesrep_role  varchar2(50 byte)
)
organization external ( type oracle_loader
    default directory report_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'salesrep.bad'
            logfile 'salesrep.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null reject rows with all null fields
    ) location ( report_dir : 'Salesrep_upload_template (4) sd.csv' )
) reject limit 0;


-- sqlcl_snapshot {"hash":"bc46651b2c99261e43e0a0f6c9b2eb13bafd1e87","type":"TABLE","name":"SALES_ASSIGNMENT_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_ASSIGNMENT_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>100</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SALES_REP_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>EFFECTIVE_DATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SALESREP_ROLE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>50</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>REPORT_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>Records Delimited By Newline Skip 1 Badfile 'salesrep.bad' Logfile 'salesrep.log' Fields Terminated By ',' Optionally Enclosed By '\"' Lrtrim Missing Field Values Are Null Reject Rows\nWith All Null Fields     </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>REPORT_DIR</DIRECTORY>\n                  <NAME>Salesrep_upload_template (4) sd.csv</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>0</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}