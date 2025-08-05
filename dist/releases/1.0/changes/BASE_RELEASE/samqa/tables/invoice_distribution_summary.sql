-- liquibase formatted sql
-- changeset SAMQA:1754374159674 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\invoice_distribution_summary.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/invoice_distribution_summary.sql:null:314a81a54a8b4113e71cc39b1e9fc8743329e5ae:create

create table samqa.invoice_distribution_summary (
    invoice_id      number,
    entrp_id        number,
    pers_id         number,
    invoice_kind    varchar2(25 byte),
    plans           varchar2(50 byte),
    invoice_days    number,
    invoice_reason  varchar2(30 byte),
    rate_code       varchar2(30 byte),
    account_type    varchar2(5 byte),
    start_date      date,
    end_date        date,
    invoice_line_id number,
    entity_id       number,
    entity_type     varchar2(30 byte),
    rate_amount     number,
    division_code   varchar2(255 byte)
);

