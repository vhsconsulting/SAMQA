create table samqa.fee_names (
    fee_code number(3, 0) not null enable,
    fee_name varchar2(100 byte) not null enable,
    fee_type number(1, 0) default 0
);

create unique index samqa.fee_names_pk on
    samqa.fee_names (
        fee_code
    );

alter table samqa.fee_names
    add constraint fee_names_pk
        primary key ( fee_code )
            using index samqa.fee_names_pk enable;


-- sqlcl_snapshot {"hash":"2e2d3fafb48f4f9ed8e5be82c7aadb6fd9d05cfd","type":"TABLE","name":"FEE_NAMES","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>FEE_NAMES</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>FEE_CODE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>3</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FEE_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>100</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FEE_TYPE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>1</PRECISION>\n            <SCALE>0</SCALE>\n            <DEFAULT>0</DEFAULT>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <PRIMARY_KEY_CONSTRAINT_LIST>\n         <PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>FEE_NAMES_PK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>FEE_CODE</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n      </PRIMARY_KEY_CONSTRAINT_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <HEAP_TABLE></HEAP_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}