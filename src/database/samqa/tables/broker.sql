create table samqa.broker (
    broker_id              number(9, 0),
    start_date             date not null enable,
    end_date               date,
    broker_lic             varchar2(20 byte),
    broker_rate            number(5, 2) default 15,
    share_rate             number(5, 2),
    ga_rate                number(5, 2),
    ga_id                  number(9, 0),
    note                   varchar2(4000 byte),
    creation_date          date default sysdate,
    created_by             number,
    last_update_date       date default sysdate,
    last_updated_by        number,
    agency_name            varchar2(100 byte),
    salesrep_id            number,
    verified_by            number,
    verified_date          date,
    commissions_payable_to varchar2(100 byte),
    flg_agree              varchar2(1 byte),
    cheque_flag            varchar2(1 byte) default 'Y',
    reason_flag            varchar2(200 byte),
    am_id                  number
);

create unique index samqa.broker_pk on
    samqa.broker (
        broker_id
    );

create unique index samqa.broker_lic_u on
    samqa.broker (
        broker_lic
    );

alter table samqa.broker
    add constraint broker_end_date check ( end_date >= start_date ) enable;

alter table samqa.broker
    add constraint broker_lic_u unique ( broker_lic )
        using index samqa.broker_lic_u enable;

alter table samqa.broker
    add constraint broker_pk
        primary key ( broker_id )
            using index samqa.broker_pk enable;


-- sqlcl_snapshot {"hash":"371042e6ad6fb4f0eda410fd2926ffca8b685067","type":"TABLE","name":"BROKER","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BROKER_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>START_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n            <NOT_NULL></NOT_NULL>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>END_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>BROKER_LIC</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>20</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>BROKER_RATE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>5</PRECISION>\n            <SCALE>2</SCALE>\n            <DEFAULT>15</DEFAULT>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SHARE_RATE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>5</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>GA_RATE</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>5</PRECISION>\n            <SCALE>2</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>GA_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n            <PRECISION>9</PRECISION>\n            <SCALE>0</SCALE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>NOTE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>4000</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CREATION_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n            <DEFAULT>sysdate</DEFAULT>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CREATED_BY</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>LAST_UPDATE_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n            <DEFAULT>sysdate</DEFAULT>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>LAST_UPDATED_BY</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>AGENCY_NAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>100</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SALESREP_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>VERIFIED_BY</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>VERIFIED_DATE</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>COMMISSIONS_PAYABLE_TO</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>100</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FLG_AGREE</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CHEQUE_FLAG</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>1</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n            <DEFAULT>'Y'</DEFAULT>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>REASON_FLAG</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>200</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>AM_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <CHECK_CONSTRAINT_LIST>\n         <CHECK_CONSTRAINT_LIST_ITEM>\n            <NAME>BROKER_END_DATE</NAME>\n            <CONDITION>END_DATE >= START_DATE</CONDITION>\n         </CHECK_CONSTRAINT_LIST_ITEM>\n      </CHECK_CONSTRAINT_LIST>\n      <PRIMARY_KEY_CONSTRAINT_LIST>\n         <PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>BROKER_PK</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>BROKER_ID</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </PRIMARY_KEY_CONSTRAINT_LIST_ITEM>\n      </PRIMARY_KEY_CONSTRAINT_LIST>\n      <UNIQUE_KEY_CONSTRAINT_LIST>\n         <UNIQUE_KEY_CONSTRAINT_LIST_ITEM>\n            <NAME>BROKER_LIC_U</NAME>\n            <COL_LIST>\n               <COL_LIST_ITEM>\n                  <NAME>BROKER_LIC</NAME>\n               </COL_LIST_ITEM>\n            </COL_LIST>\n            <USING_INDEX></USING_INDEX>\n         </UNIQUE_KEY_CONSTRAINT_LIST_ITEM>\n      </UNIQUE_KEY_CONSTRAINT_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <HEAP_TABLE></HEAP_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}