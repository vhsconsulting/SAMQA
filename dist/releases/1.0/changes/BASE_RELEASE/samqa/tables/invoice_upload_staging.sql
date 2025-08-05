-- liquibase formatted sql
-- changeset SAMQA:1754374159806 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\invoice_upload_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/invoice_upload_staging.sql:null:d9355e756c2254b3fbfcb6dc878674f1923d3b27:create

create table samqa.invoice_upload_staging (
    batch_number      number,
    invoice_upload_id number,
    invoice_id        number,
    invoice_type      varchar2(100 byte) default 'FEE',
    acc_num           varchar2(20 byte),
    acc_id            number,
    entrp_id          number,
    start_date        varchar2(20 byte),
    end_date          varchar2(20 byte),
    invoice_date      varchar2(20 byte),
    invoice_amount    varchar2(30 byte),
    invoice_term      varchar2(255 byte),
    payment_method    varchar2(255 byte),
    rate_plan_id      number,
    bank_acct_id      number,
    account_type      varchar2(30 byte),
    reason_name       varchar2(255 byte),
    rate_code         varchar2(30 byte),
    error_status      varchar2(1 byte),
    error_message     varchar2(3000 byte),
    created_by        number,
    creation_date     date,
    last_updated_by   number,
    last_update_date  date
);

