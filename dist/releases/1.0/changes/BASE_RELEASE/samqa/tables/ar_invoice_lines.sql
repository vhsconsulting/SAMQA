-- liquibase formatted sql
-- changeset SAMQA:1754374151697 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_invoice_lines.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_invoice_lines.sql:null:b5ae0b30a4314881b4415492e0d8f2fe4c2d3890:create

create table samqa.ar_invoice_lines (
    invoice_line_id     number not null enable,
    invoice_id          number,
    invoice_line_type   varchar2(255 byte),
    rate_code           varchar2(30 byte),
    quantity            number,
    unit_rate_cost      number default 0,
    total_line_amount   number default 0,
    note                varchar2(3200 byte),
    comments            varchar2(3200 byte),
    status              varchar2(30 byte),
    created_by          number,
    creation_date       date default sysdate,
    last_updated_by     number,
    last_update_date    date default sysdate,
    batch_number        number,
    description         varchar2(3200 byte),
    no_of_months        number,
    void_date           date,
    cancelled_date      date,
    void_amount         number,
    calculation_type    varchar2(100 byte) default 'AMOUNT',
    product_type        varchar2(100 byte),
    void_reason         varchar2(255 byte),
    rate_plan_detail_id number
);

alter table samqa.ar_invoice_lines add primary key ( invoice_line_id )
    using index enable;

