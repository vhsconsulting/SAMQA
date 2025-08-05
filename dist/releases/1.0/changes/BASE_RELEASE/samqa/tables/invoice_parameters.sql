-- liquibase formatted sql
-- changeset SAMQA:1754374159734 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\invoice_parameters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/invoice_parameters.sql:null:0e9a96f8e9847b0a4ba4913d4c06971bc81b6e9b:create

create table samqa.invoice_parameters (
    invoice_param_id      number not null enable,
    entity_id             number,
    entity_type           varchar2(30 byte),
    payment_term          varchar2(30 byte),
    invoice_frequency     varchar2(30 byte),
    payment_method        varchar2(30 byte),
    autopay               varchar2(30 byte),
    bank_acct_id          number,
    pharmacy_charges_flag varchar2(30 byte),
    wellness_bonus_flag   varchar2(30 byte),
    creation_date         date default sysdate,
    created_by            number,
    last_update_date      date default sysdate,
    last_updated_by       number,
    last_invoiced_date    date,
    min_inv_amount        number,
    invoice_email         varchar2(2000 byte),
    billing_name          varchar2(255 byte),
    billing_attn          varchar2(255 byte),
    billing_address       varchar2(255 byte),
    billing_city          varchar2(255 byte),
    billing_zip           varchar2(255 byte),
    billing_state         varchar2(255 byte),
    min_inv_hra_amount    number default 0,
    detailed_reporting    varchar2(1 byte),
    sync_address          varchar2(1 byte),
    invoice_type          varchar2(100 byte) default 'FEE',
    division_code         varchar2(255 byte),
    product_type          varchar2(100 byte),
    rate_plan_id          number,
    status                varchar2(1 byte) default 'A',
    send_invoice_reminder varchar2(1 byte) default 'Y'
);

alter table samqa.invoice_parameters add primary key ( invoice_param_id )
    using index enable;

