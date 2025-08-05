-- liquibase formatted sql
-- changeset SAMQA:1754374151780 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_quote_lines.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_quote_lines.sql:null:95325136ccbf885a6af9deecc7e4213f94a1b63f:create

create table samqa.ar_quote_lines (
    quote_line_id         number,
    quote_header_id       number,
    reason_code           number,
    rate_plan_id          number,
    rate_plan_detail_id   number,
    line_list_price       number,
    list_adjusted_amount  number,
    list_adjusted_percent number,
    adjustment_reason     varchar2(50 byte),
    start_date            date,
    end_date              date,
    invoice_to_entity_id  number,
    notes                 varchar2(100 byte),
    creation_date         date default sysdate,
    created_by            number,
    last_update_date      date default sysdate,
    last_updated_by       number
);

