create table samqa."debit_EXTERNAL" (
    ssn        varchar2(30 byte),
    debit_card varchar2(30 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'debit.bad'
            logfile 'debit.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'debit_card.csv' )
) reject limit unlimited;


-- sqlcl_snapshot {"hash":"b7a65d39ffc6d2ce5a2ae50892c6b6f18b882c78","type":"TABLE","name":"debit_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>debit_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DEBIT_CARD</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>ENROLL_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited by newline skip 1  badfile 'debit.bad'   logfile 'debit.log'   fields terminated by ','   optionally enclosed by '\"'   LRTRIM   MISSING FIELD VALUES ARE NULL              </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <NAME>debit_card.csv</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}