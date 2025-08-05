-- liquibase formatted sql
-- changeset SAMQA:1754374156425 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_payment_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_payment_log.sql:null:ebb127f69fa4f7f95ee07d1fb9cff1f0f6870212:create

create table samqa.employer_payment_log (
    entrp_id        number,
    check_date      date,
    plan_type       varchar2(100 byte),
    plan_start_date date,
    plan_end_date   date,
    reason_code     number,
    check_number    varchar2(100 byte),
    check_amount    number,
    creation_date   date,
    note            varchar2(1000 byte)
);

