-- liquibase formatted sql
-- changeset SAMQA:1754374160953 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\new_hsa_commission_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/new_hsa_commission_report.sql:null:f8699f588705a4b919c60cac220dd73b307abfbb:create

create table samqa.new_hsa_commission_report (
    salesrep_id         number,
    salesrep            varchar2(255 byte),
    amount              number,
    group_name          varchar2(255 byte),
    account_type        varchar2(30 byte),
    acc_id              number,
    account_number      varchar2(30 byte),
    enrollment_date     date,
    funded_date         date,
    employer_start_date date,
    period_start_date   date,
    period_end_date     date,
    insert_id           varchar2(10 byte),
    creation_date       date,
    created_by          number
);

