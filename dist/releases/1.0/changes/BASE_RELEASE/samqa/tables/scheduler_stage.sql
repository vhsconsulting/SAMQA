-- liquibase formatted sql
-- changeset SAMQA:1754374163104 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\scheduler_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/scheduler_stage.sql:null:225f0e3309f98a1b398699fca3282eaa84a258ab:create

create table samqa.scheduler_stage (
    scheduler_stage_id   number,
    batch_number         number,
    entrp_id             number,
    ben_plan_id          number,
    plan_type            varchar2(30 byte),
    reason_name          varchar2(3200 byte),
    payroll_date         varchar2(30 byte),
    payment_start_date   date,
    payment_end_date     date,
    recurring_flag       varchar2(1 byte),
    recurring_frequency  varchar2(30 byte),
    ee_acc_num           varchar2(20 byte),
    er_acc_id            number,
    scheduler_id         number,
    creation_date        date,
    created_by           number,
    last_update_date     date,
    last_updated_by      number,
    pay_contrib_method   number,
    error_message        varchar2(3200 byte),
    status               varchar2(1 byte),
    note                 varchar2(2000 byte),
    bank_acct_id         number,
    payment_method       varchar2(30 byte),
    post_prev_pay_period varchar2(1 byte) default 'N',
    no_of_pay_period     varchar2(50 byte)
);

alter table samqa.scheduler_stage add constraint scheduler_batch_num unique ( batch_number ) disable;

