create table samqa.income (
    change_num         number,
    acc_id             number(9, 0) not null enable,
    fee_date           date not null enable,
    fee_code           number(3, 0),
    amount             number(15, 2) not null enable,
    contributor        number(9, 0),
    pay_code           number(3, 0) not null enable,
    cc_number          varchar2(100 byte),
    cc_code            number(3, 0),
    cc_owner           varchar2(30 byte),
    cc_date            date,
    note               varchar2(4000 byte),
    amount_add         number(15, 2) default 0,
    cur_bal            number(15, 2),
    contributor_amount number,
    list_bill          varchar2(100 byte),
    transaction_type   varchar2(1 byte) default 'A',
    debit_card_posted  varchar2(1 byte) default 'N',
    ee_fee_amount      number,
    er_fee_amount      number,
    created_by         number,
    creation_date      date,
    last_updated_by    number,
    last_updated_date  date,
    plan_type          varchar2(30 byte),
    orig_doc_ref       varchar2(1000 byte),
    gp_posted          varchar2(2 byte),
    due_date           date,
    postmark_date      date
);

create unique index samqa.income_pk on
    samqa.income (
        change_num
    );

alter table samqa.income
    add constraint income_pk
        primary key ( change_num )
            using index samqa.income_pk enable;


-- sqlcl_snapshot {"hash":"6cce4a83586810bbe56b10cb12b2a1ebb324bcfd","type":"TABLE","name":"INCOME","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INCOME</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CHANGE_NUM</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FEE_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FEE_CODE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>3</PRECISION>\n            <SCALE>0</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>AMOUNT</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CONTRIBUTOR</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PAY_CODE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>3</PRECISION>\n            <SCALE>0</SCALE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CC_NUMBER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>100</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CC_CODE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>3</PRECISION>\n            <SCALE>0</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CC_OWNER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CC_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>NOTE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>4000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>AMOUNT_ADD</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n            <DEFAULT>0</DEFAULT>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CUR_BAL</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>15</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CONTRIBUTOR_AMOUNT</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>LIST_BILL</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>100</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_TYPE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <DEFAULT>'A'</DEFAULT>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DEBIT_CARD_POSTED</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <DEFAULT>'N'</DEFAULT>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>EE_FEE_AMOUNT</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ER_FEE_AMOUNT</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CREATED_BY</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CREATION_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>LAST_UPDATED_BY</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>LAST_UPDATED_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>30</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ORIG_DOC_REF</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>GP_POSTED</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>2</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DUE_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>POSTMARK_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <PRIMARY_KEY_CONSTRAINT_LIST>\n         <PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>INCOME_PK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>CHANGE_NUM</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n      </PRIMARY_KEY_CONSTRAINT_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <HEAP_TABLE></HEAP_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}