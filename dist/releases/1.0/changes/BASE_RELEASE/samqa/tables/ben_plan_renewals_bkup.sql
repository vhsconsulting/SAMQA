-- liquibase formatted sql
-- changeset SAMQA:1754374152355 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ben_plan_renewals_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ben_plan_renewals_bkup.sql:null:0957bdebda27c98765261f4f4f36b857d4668869:create

create table samqa.ben_plan_renewals_bkup (
    acc_id               number,
    ben_plan_id          number,
    plan_type            varchar2(10 byte),
    creation_date        date,
    created_by           number,
    last_updated_by      number,
    last_updated_date    date,
    broker_name          varchar2(100 byte),
    broker_id            number,
    start_date           date,
    end_date             date,
    salesrep_id          number,
    css                  varchar2(30 byte),
    source               varchar2(20 byte),
    renewed_plan_id      number,
    renewal_batch_number number,
    ga_id                number,
    no_of_eligible_old   number,
    pay_method_old       varchar2(100 byte),
    carrier_pay_old      number,
    open_enrll_suite_old number,
    carrier_notif_old    number,
    renewal_fee_old      number,
    pay_acct_fees        varchar2(100 byte)
);

