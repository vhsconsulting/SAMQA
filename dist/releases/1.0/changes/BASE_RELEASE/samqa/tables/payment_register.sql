-- liquibase formatted sql
-- changeset SAMQA:1754374162009 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\payment_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/payment_register.sql:null:6f30953ddbb66d368a1b99a0db99278246d2bf46:create

create table samqa.payment_register (
    payment_register_id    number not null enable,
    batch_number           varchar2(30 byte),
    acc_num                varchar2(30 byte),
    acc_id                 number,
    pers_id                number,
    provider_name          varchar2(255 byte),
    vendor_id              number,
    vendor_orig_sys        varchar2(255 byte),
    claim_code             varchar2(50 byte),
    claim_id               number,
    check_number           varchar2(30 byte),
    claim_type             varchar2(30 byte),
    peachtree_interfaced   char(1 byte),
    trans_date             date,
    gl_account             varchar2(30 byte),
    cash_account           varchar2(30 byte),
    claim_amount           number,
    claim_paid             number,
    note                   varchar2(2000 byte),
    creation_date          date,
    created_by             number,
    last_update_date       date,
    last_updated_by        number,
    claim_error_flag       varchar2(1 byte),
    insufficient_fund_flag varchar2(1 byte),
    patient_name           varchar2(255 byte),
    memo                   varchar2(3200 byte),
    entrp_id               number,
    date_of_service        varchar2(255 byte),
    cancelled_flag         varchar2(255 byte),
    service_type           varchar2(30 byte),
    service_start_date     date,
    service_end_date       date,
    pay_reason             number,
    bank_acct_id           number,
    expense_category       varchar2(255 byte),
    insurance_category     varchar2(255 byte)
);

