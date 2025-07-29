create table samqa.card_transfer (
    transfer_id     number(9, 0) not null enable,
    card_id         number(9, 0) not null enable,
    transfer_date   date default trunc(sysdate) not null enable,
    transfer_amount number(15, 2) not null enable,
    note            varchar2(4000 byte),
    cur_bal         number(15, 2)
);

create unique index samqa.card_transfer_pk on
    samqa.card_transfer (
        transfer_id
    );

alter table samqa.card_transfer
    add constraint card_transfer_amount check ( transfer_amount <> 0 ) enable;

alter table samqa.card_transfer
    add constraint card_transfer_pk
        primary key ( transfer_id )
            using index samqa.card_transfer_pk enable;


-- sqlcl_snapshot {"hash":"d6d0c559ba5e3b859ceafc1853f44f7d4220b572","type":"TABLE","name":"CARD_TRANSFER","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CARD_TRANSFER</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSFER_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CARD_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TRANSFER_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n            <DEFAULT>TRUNC(SYSDATE)</DEFAULT>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TRANSFER_AMOUNT</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>NOTE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>4000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CUR_BAL</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <CHECK_CONSTRAINT_LIST>\n         <CHECK_CONSTRAINT_LIST_ITEM>\n            <NAME>CARD_TRANSFER_AMOUNT</NAME>\n            <CONDITION>TRANSFER_AMOUNT &#60;> 0</CONDITION>\n         </CHECK_CONSTRAINT_LIST_ITEM>\n      </CHECK_CONSTRAINT_LIST>\n      <PRIMARY_KEY_CONSTRAINT_LIST>\n         <PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>CARD_TRANSFER_PK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>TRANSFER_ID</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n      </PRIMARY_KEY_CONSTRAINT_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <HEAP_TABLE></HEAP_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}