create table samqa.check_external (
    file_name    varchar2(250 byte),
    check_number varchar2(15 byte),
    acc_num      varchar2(20 byte),
    check_dt     varchar2(15 byte),
    mailed_dt    varchar2(15 byte)
)
organization external ( type oracle_loader
    default directory checks_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( checks_dir : 'STERLING_RECEIPT_0220240221001_manual' )
) reject limit unlimited;


-- sqlcl_snapshot {"hash":"dce2226e0b3143bcfab52693b2ece1e1cc9a669f","type":"TABLE","name":"CHECK_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CHECK_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>FILE_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>250</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CHECK_NUMBER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CHECK_DT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>MAILED_DT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>CHECKS_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited BY newline skip 1\n    fields terminated BY ','\n    optionally enclosed BY '\"' LRTRIM MISSING FIELD VALUES ARE NULL         </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>CHECKS_DIR</DIRECTORY>\n                  <NAME>STERLING_RECEIPT_0220240221001_manual</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}