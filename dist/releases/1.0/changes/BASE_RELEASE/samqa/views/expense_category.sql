-- liquibase formatted sql
-- changeset SAMQA:1754374173163 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\expense_category.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/expense_category.sql:null:c35e60c02e7379568b2fb4c9ae7d696471077edd:create

create or replace force editionable view samqa.expense_category (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'EXPENSE_CATEGORY';

