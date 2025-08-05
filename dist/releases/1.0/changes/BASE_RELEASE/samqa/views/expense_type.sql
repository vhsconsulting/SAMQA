-- liquibase formatted sql
-- changeset SAMQA:1754374173173 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\expense_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/expense_type.sql:null:137bab8551a85d633b63eca24613aa4fcc502655:create

create or replace force editionable view samqa.expense_type (
    lookup_name,
    expense_code,
    expense_name,
    expense_nshort
) as
    select
        lookup_name,
        lookup_code expense_code,
        description expense_name,
        meaning     expense_nshort
    from
        lookups
    where
        lookup_name = 'EXPENSE_TYPE';

