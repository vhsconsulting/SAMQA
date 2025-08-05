-- liquibase formatted sql
-- changeset SAMQA:1754374155785 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eb_settlement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eb_settlement.sql:null:332b41f986fb295617a2199857da287c3785777e:create

create table samqa.eb_settlement (
    settle_num      number(9, 0) not null enable,
    file_date       date not null enable,
    file_time       number(6, 0) not null enable,
    line            number(6, 0) not null enable,
    tpaid           varchar2(6 byte) not null enable,
    processed_date  date not null enable,
    client_id       varchar2(6 byte) not null enable,
    trans_date      date not null enable,
    description     varchar2(70 byte) not null enable,
    payment_amount  number(10, 2) not null enable,
    trans_code      varchar2(8 byte) not null enable,
    member_id       varchar2(30 byte) not null enable,
    purse_type      varchar2(3 byte) not null enable,
    merch_name      varchar2(50 byte) not null enable,
    mcc             varchar2(4 byte) not null enable,
    payment_ref     varchar2(25 byte) not null enable,
    trans_source    varchar2(4 byte) not null enable,
    match_trans_id  varchar2(10 byte) not null enable,
    plan_start_date date not null enable,
    plan_end_date   date not null enable,
    trans_unique_id varchar2(36 byte) not null enable,
    file_name       varchar2(80 byte) not null enable,
    acc_id          number(9, 0) not null enable,
    pers_id         number(9, 0) not null enable,
    claim_id        number(9, 0) default 0 not null enable,
    created_claim   char(1 byte) default 'N' not null enable
);

