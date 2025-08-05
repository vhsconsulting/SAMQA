-- liquibase formatted sql
-- changeset SAMQA:1754374152085 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ben_plan_approvals.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ben_plan_approvals.sql:null:c24828fbcb2b1f1b746ace49fd7ad94e0cb81b13:create

create table samqa.ben_plan_approvals (
    ben_plan_app_id number,
    batch_number    number,
    name            varchar2(255 byte),
    annual_election varchar2(255 byte),
    effective_date  varchar2(255 byte),
    pay_contrib     varchar2(255 byte),
    first_pay_date  varchar2(255 byte),
    ben_plan_id     number,
    status          varchar2(1 byte),
    entrp_id        number,
    reject_reason   varchar2(255 byte),
    approved_date   date,
    approved_by     number,
    rejected_date   date,
    rejected_by     number
);

