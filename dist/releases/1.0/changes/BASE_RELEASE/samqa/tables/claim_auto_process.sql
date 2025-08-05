-- liquibase formatted sql
-- changeset SAMQA:1754374153091 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_auto_process.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_auto_process.sql:null:f926cd597397ab9dcbda4847396b6507efe59811:create

create table samqa.claim_auto_process (
    claim_id         number,
    process_status   varchar2(30 byte),
    entrp_id         number,
    product_type     varchar2(30 byte),
    payment_amount   number,
    employer_balance number,
    claim_status     varchar2(30 byte),
    invoice_status   varchar2(30 byte),
    invoice_date     date,
    creation_date    date,
    invoice_id       number,
    batch_number     number
);

