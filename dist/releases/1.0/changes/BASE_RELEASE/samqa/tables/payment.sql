-- liquibase formatted sql
-- changeset SAMQA:1754374161934 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\payment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/payment.sql:null:04b92a0a0dfb819fbb3c096bc487b770b5cbcac4:create

create table samqa.payment (
    change_num        number,
    acc_id            number(9, 0) not null enable,
    pay_date          date not null enable,
    amount            number(15, 2) not null enable,
    reason_code       number(3, 0) not null enable,
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

create unique index samqa.payment_pk on
    samqa.payment (
        change_num
    );

alter table samqa.payment
    add constraint payment_pk
        primary key ( change_num )
            using index samqa.payment_pk enable;

