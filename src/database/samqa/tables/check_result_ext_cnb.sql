create table samqa.check_result_ext_cnb (
    cnb_trans_ref   varchar2(16 byte),
    status_code     varchar2(4 byte),
    status_name     varchar2(4000 byte),
    status_desc     varchar2(4000 byte),
    confirmation_id varchar2(400 byte)
)
organization external ( type oracle_loader
    default directory checks_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( checks_dir : 'EASI_Status.sterlingadmin.202504251828.csv' )
) reject limit unlimited;


-- sqlcl_snapshot {"hash":"46fc31585edf301c38347497a2c8bf2241cbcd1c","type":"TABLE","name":"CHECK_RESULT_EXT_CNB","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CHECK_RESULT_EXT_CNB</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CNB_TRANS_REF</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>16</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>STATUS_CODE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>4</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>STATUS_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>4000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>STATUS_DESC</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>4000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CONFIRMATION_ID</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>400</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>CHECKS_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited BY newline skip 1\n    fields terminated BY ','\n    optionally enclosed BY '\"' LRTRIM MISSING FIELD VALUES ARE NULL         </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>CHECKS_DIR</DIRECTORY>\n                  <NAME>EASI_Status.sterlingadmin.202504251828.csv</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}