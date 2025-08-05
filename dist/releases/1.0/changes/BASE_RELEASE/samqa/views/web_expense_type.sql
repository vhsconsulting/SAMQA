-- liquibase formatted sql
-- changeset SAMQA:1754374180158 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\web_expense_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/web_expense_type.sql:null:fc9fd4d63a1e6cb1b7c94d67d288c88e85de2afb:create

create or replace force editionable view samqa.web_expense_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'WEB_EXPENSE_TYPE';

