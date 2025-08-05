-- liquibase formatted sql
-- changeset SAMQA:1754374152338 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ben_plan_renewals.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ben_plan_renewals.sql:null:c0cba3f1e2d548237c3c3bccc6126b2b6a9ab65e:create

create table samqa.ben_plan_renewals (
    acc_id               number,
    ben_plan_id          number,
    plan_type            varchar2(30 byte),
    creation_date        date default sysdate,
    created_by           number,
    last_updated_by      number,
    last_updated_date    date default sysdate,
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
    pay_acct_fees        varchar2(100 byte),
    optional_fee_paid_by varchar2(100 byte)
);

