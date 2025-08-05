-- liquibase formatted sql
-- changeset SAMQA:1754374162261 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\plan_eligibile_expenses.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/plan_eligibile_expenses.sql:null:57287c2c9250b59c95b6739b1c20f97f5291cc9d:create

create table samqa.plan_eligibile_expenses (
    expense_id       number,
    entity_id        number,
    plan_type        varchar2(100 byte),
    expense_code     varchar2(100 byte),
    description      varchar2(2000 byte),
    created_by       number,
    creation_date    date,
    updated_by       number,
    last_update_date date
);

