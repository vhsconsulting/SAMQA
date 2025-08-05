-- liquibase formatted sql
-- changeset SAMQA:1754374151795 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_quote_lines_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_quote_lines_staging.sql:null:39d065a81144bb41581574e356905f4d9f4536d1:create

create table samqa.ar_quote_lines_staging (
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
    batch_number          number,
    creation_date         date,
    created_by            number,
    last_update_date      date,
    last_updated_by       number,
    rate_plan_name        varchar2(100 byte)
);

