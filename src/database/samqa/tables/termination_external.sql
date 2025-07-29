create table samqa.termination_external (
    acc_num          varchar2(30 byte),
    ssn              varchar2(30 byte),
    last_name        varchar2(255 byte),
    first_name       varchar2(255 byte),
    termination_date varchar2(255 byte),
    plan_type        varchar2(255 byte),
    tpa_id           varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'terminations.bad'
            logfile 'terminations.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( enroll_dir : 'inputfileTerms.csv20120112' )
) reject limit unlimited;


-- sqlcl_snapshot {"hash":"082dd0c229b637e6e3c847607c4476ccb3dc62b7","type":"TABLE","name":"TERMINATION_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>TERMINATION_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>LAST_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FIRST_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TERMINATION_DATE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TPA_ID</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>ENROLL_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited BY newline skip 1 badfile 'terminations.bad' logfile 'terminations.log' fields terminated BY ',' optionally enclosed BY '\"' LRTRIM MISSING FIELD VALUES ARE NULL         </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>ENROLL_DIR</DIRECTORY>\n                  <NAME>inputfileTerms.csv20120112</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>UNLIMITED</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}