create table samqa.claim (
    claim_id         number(9, 0) not null enable,
    pers_id          number(9, 0) not null enable,
    prov_id          number(9, 0) not null enable,
    claim_date_start date not null enable,
    claim_date_end   date,
    claim_bill       number(15, 2),
    service_doctor   varchar2(100 byte),
    claim_paid       number(15, 2),
    remainder        number(15, 2),
    claim_code       varchar2(20 byte),
    send_date        date,
    receive_date     date,
    note             varchar2(4000 byte),
    pers_patient     number(9, 0) not null enable,
    bill_val         number(15, 2)
);

create unique index samqa.claim_pk on
    samqa.claim (
        claim_id
    );

alter table samqa.claim
    add constraint claim_pk
        primary key ( claim_id )
            using index samqa.claim_pk enable;


-- sqlcl_snapshot {"hash":"6564d8523a3cfafeb2602bd06d60176aea199d5e","type":"TABLE","name":"CLAIM","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PERS_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PROV_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_DATE_START</NAME>\n            <DATATYPE>DATE</DATATYPE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_DATE_END</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_BILL</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SERVICE_DOCTOR</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>100</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_PAID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>REMAINDER</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_CODE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SEND_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>RECEIVE_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>NOTE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>4000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PERS_PATIENT</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>BILL_VAL</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <PRIMARY_KEY_CONSTRAINT_LIST>\n         <PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>CLAIM_PK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>CLAIM_ID</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n      </PRIMARY_KEY_CONSTRAINT_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <HEAP_TABLE></HEAP_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}