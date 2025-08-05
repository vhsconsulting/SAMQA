-- liquibase formatted sql
-- changeset SAMQA:1754374162801 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_commissions_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_commissions_detail.sql:null:9c73bc63579b461470f5dd478c4179692169d67e:create

create table samqa.sales_commissions_detail (
    sal_comm_detail_id  number,
    salesrep_id         number,
    acc_num             varchar2(100 byte),
    acc_id              number,
    entrp_id            number,
    amount              number,
    start_date          date,
    broker_id           number,
    invoice_id          number,
    account_type        varchar2(100 byte),
    comm_flag           varchar2(50 byte),
    first_payment_date  date,
    period_start_date   date,
    period_end_date     date,
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    check_date          date,
    employer_payment_id number,
    change_num          number,
    process_flag        varchar2(10 byte)
);

