create table samqa.debit_log_external (
    line varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory bank_serv_dir access parameters (
        records delimited by newline
            badfile 'debit.bad'
            logfile 'debit.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'DebitLog.csv' )
) reject limit unlimited;


-- sqlcl_snapshot {"hash":"2f19af7f36e6576124728124fe3ae3426e02fb1b","type":"TABLE","name":"DEBIT_LOG_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEBIT_LOG_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LINE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>3200</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>BANK_SERV_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited by newline  badfile 'debit.bad'   logfile 'debit.log'   fields terminated by ','   optionally enclosed by '\"'   LRTRIM   MISSING FIELD VALUES ARE NULL                      </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <NAME>DebitLog.csv</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}