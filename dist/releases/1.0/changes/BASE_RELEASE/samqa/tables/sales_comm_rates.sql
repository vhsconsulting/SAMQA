-- liquibase formatted sql
-- changeset SAMQA:1754374162735 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_comm_rates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_comm_rates.sql:null:fbbefc66a02655653b63d938970812a601f3d9e6:create

create table samqa.sales_comm_rates (
    comm_rate_id     number,
    account_type     varchar2(30 byte),
    account_category varchar2(30 byte),
    comm_method      varchar2(30 byte),
    comm_amount      number,
    comm_perc        number,
    start_date       date,
    end_date         date,
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number,
    entity_type      varchar2(30 byte),
    min_range        number,
    max_range        number
);

alter table samqa.sales_comm_rates add primary key ( comm_rate_id )
    using index enable;

