-- liquibase formatted sql
-- changeset SAMQA:1754374161966 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\payment1217.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/payment1217.sql:null:d328f52f70269f1bfaf86c0e574d89c8cd6e8033:create

create table samqa.payment1217 (
    change_num        number,
    acc_id            number(9, 0),
    pay_date          date,
    amount            number(15, 2),
    reason_code       number(3, 0),
    claim_id          number(9, 0),
    pay_num           number,
    note              varchar2(4000 byte),
    claimn_id         number,
    cur_bal           number(15, 2),
    debit_card_posted varchar2(1 byte) default 'N',
    pay_source        varchar2(30 byte),
    reason_mode       varchar2(3 byte),
    creation_date     date,
    created_by        number,
    last_updated_by   number,
    last_updated_date date,
    claim_posted      varchar2(1 byte),
    plan_type         varchar2(30 byte),
    paid_date         date,
    gp_posted         varchar2(2 byte)
);

