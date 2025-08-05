-- liquibase formatted sql
-- changeset SAMQA:1754374154474 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\daily_enroll_renewal_account_info.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/daily_enroll_renewal_account_info.sql:null:f90cd671f892ea43070322755d14ae1b6014e6aa:create

create table samqa.daily_enroll_renewal_account_info (
    batch_number               number,
    entrp_id                   number,
    source                     varchar2(100 byte),
    invoice_id                 number,
    error_status               varchar2(1 byte),
    error_message              varchar2(4000 byte),
    creation_date              date,
    billing_frequency          varchar2(10 byte),
    pay_acct_fees              varchar2(20 byte),
    no_of_employees            number,
    quote_header_id            number,
    payment_method             varchar2(20 byte),
    total_quote_price          number,
    no_of_eligible             number,
    salesrep                   varchar2(500 byte),
    account_type               varchar2(20 byte),
    acc_num                    varchar2(100 byte),
    acc_id                     number,
    plan_start_date            date,
    plan_end_date              date,
    renewed_plan_id            number,
    broker_id                  number,
    ga_id                      number,
    ben_plan_created_by        number,
    enrolle_type               varchar2(10 byte),
    bank_acct_num              varchar2(20 byte),
    ben_plan_id                number,
    staging_batch_number       number,
    product_type               varchar2(30 byte),
    mth_opt_fee_paid_by        varchar2(100 byte),
    mth_opt_fee_payment_method varchar2(30 byte),
    mth_opt_fee_bank_acct_id   number,
    funding_payment_method     varchar2(30 byte)
);

