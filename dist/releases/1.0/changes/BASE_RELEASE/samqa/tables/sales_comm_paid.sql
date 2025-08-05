-- liquibase formatted sql
-- changeset SAMQA:1754374162713 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_comm_paid.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_comm_paid.sql:null:045b7fec62d9d4be5ff8bf6a480b321a3f7d97d3:create

create table samqa.sales_comm_paid (
    comm_paid_id       number,
    salesrep_id        number,
    processed_date     date,
    period_start_date  date,
    period_end_date    date,
    transaction_amount number,
    quantity           number,
    account_category   varchar2(30 byte),
    account_type       varchar2(30 byte),
    creation_date      date,
    created_by         number,
    last_update_date   date,
    last_updated_by    number,
    revenue_amount     number
);

alter table samqa.sales_comm_paid add primary key ( comm_paid_id )
    using index enable;

