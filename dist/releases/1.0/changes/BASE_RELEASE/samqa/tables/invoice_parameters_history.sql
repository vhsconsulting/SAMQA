-- liquibase formatted sql
-- changeset SAMQA:1754374159770 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\invoice_parameters_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/invoice_parameters_history.sql:null:db817e649239432f15beb521e7a5a94b2e1b7299:create

create table samqa.invoice_parameters_history (
    invoice_param_id         number not null enable,
    entity_id                number,
    entity_type              varchar2(30 byte),
    payment_term             varchar2(30 byte),
    invoice_frequency        varchar2(30 byte),
    payment_method           varchar2(30 byte),
    autopay                  varchar2(30 byte),
    bank_acct_id             number,
    pharmacy_charges_flag    varchar2(30 byte),
    wellness_bonus_flag      varchar2(30 byte),
    creation_date            date,
    created_by               number,
    last_update_date         date,
    last_updated_by          number,
    last_invoiced_date       date,
    min_inv_amount           number,
    invoice_email            varchar2(2000 byte),
    billing_name             varchar2(255 byte),
    billing_attn             varchar2(255 byte),
    billing_address          varchar2(255 byte),
    billing_city             varchar2(255 byte),
    billing_zip              varchar2(255 byte),
    billing_state            varchar2(255 byte),
    min_inv_hra_amount       number,
    detailed_reporting       varchar2(1 byte),
    sync_address             varchar2(1 byte),
    invoice_type             varchar2(100 byte),
    division_code            varchar2(255 byte),
    product_type             varchar2(100 byte),
    rate_plan_id             number,
    status                   varchar2(1 byte),
    send_invoice_reminder    varchar2(1 byte),
    invoice_param_history_id number,
    changed_date             date,
    changed_by               number
);

