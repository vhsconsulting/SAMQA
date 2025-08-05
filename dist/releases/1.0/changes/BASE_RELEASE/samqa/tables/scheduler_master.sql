-- liquibase formatted sql
-- changeset SAMQA:1754374163088 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\scheduler_master.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/scheduler_master.sql:null:2dd4b17209ece70e9517a65766d4fc0b65c8ef0d:create

create table samqa.scheduler_master (
    scheduler_id         number,
    acc_id               number,
    payment_method       varchar2(30 byte),
    payment_type         varchar2(30 byte),
    reason_code          number,
    payment_start_date   date,
    payment_end_date     date,
    recurring_flag       varchar2(1 byte) default 'N',
    recurring_frequency  varchar2(30 byte),
    amount               number,
    fee_amount           number,
    bank_acct_id         number,
    contributor          number,
    created_by           number,
    creation_date        date,
    last_updated_by      number,
    last_updated_date    date default sysdate,
    plan_type            varchar2(30 byte),
    orig_system_ref      varchar2(30 byte),
    orig_system_source   varchar2(30 byte),
    pay_to_all           varchar2(1 byte) default 'N',
    pay_to_all_amount    number,
    scheduler_name       varchar2(255 byte),
    note                 varchar2(3200 byte),
    calendar_id          number,
    pay_cycle_id         number,
    status               varchar2(1 byte),
    source               varchar2(15 byte),
    post_prev_pay_period varchar2(1 byte) default 'N',
    no_of_pay_period     varchar2(50 byte)
);

alter table samqa.scheduler_master add primary key ( scheduler_id )
    using index enable;

