-- liquibase formatted sql
-- changeset SAMQA:1754374162785 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_commission_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_commission_report.sql:null:2c072daa9430fdae34831fae6169816921e6f1d5:create

create table samqa.sales_commission_report (
    salesrep_id            number,
    salesrep               varchar2(255 byte),
    amount                 number,
    eligible               number(10, 0),
    enrolled               number,
    commissionable_revenue number,
    annualized_revenue     number,
    group_name             varchar2(100 byte),
    account_type           varchar2(30 byte),
    reg_date               date,
    enrolled_annual        number,
    eligible_annual        number,
    period_start_date      date,
    period_end_date        date,
    insert_id              varchar2(10 byte),
    creation_date          date,
    created_by             number,
    last_update_date       date,
    last_updated_by        number
);

