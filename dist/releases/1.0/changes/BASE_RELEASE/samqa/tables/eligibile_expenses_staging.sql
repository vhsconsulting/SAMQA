-- liquibase formatted sql
-- changeset SAMQA:1754374155853 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\eligibile_expenses_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/eligibile_expenses_staging.sql:null:7154393052dda7d77e72ff9cd23ec5696916df08:create

create table samqa.eligibile_expenses_staging (
    expense_id       number,
    entity_id        number,
    plan_type        varchar2(100 byte),
    expense_code     varchar2(100 byte),
    batch_number     number,
    created_by       number,
    creation_date    date,
    updated_by       number,
    last_update_date date
);

