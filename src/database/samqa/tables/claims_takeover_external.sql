create table samqa.claims_takeover_external (
    acc_num           varchar2(15 byte),
    service_plan_type varchar2(5 byte),
    claim_amount      varchar2(15 byte),
    service_start_dt  varchar2(15 byte),
    service_end_dt    varchar2(15 byte),
    note              varchar2(50 byte),
    takeover_flag     varchar2(5 byte)
)
organization external ( type oracle_loader
    default directory claim_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( claim_dir : 'Sterling_HRAFSA_Takeover_Claim_Template.csv' )
) reject limit 1;


-- sqlcl_snapshot {"hash":"845f826ac433f869301a74391eb1017a57ef7d14","type":"TABLE","name":"CLAIMS_TAKEOVER_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIMS_TAKEOVER_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SERVICE_PLAN_TYPE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>5</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_AMOUNT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SERVICE_START_DT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SERVICE_END_DT</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>15</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>NOTE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>50</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TAKEOVER_FLAG</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>5</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>CLAIM_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited BY newline skip 1\n    fields terminated BY ',' optionally enclosed BY '\"' LRTRIM MISSING FIELD VALUES ARE NULL     </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>CLAIM_DIR</DIRECTORY>\n                  <NAME>Sterling_HRAFSA_Takeover_Claim_Template.csv</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>1</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}