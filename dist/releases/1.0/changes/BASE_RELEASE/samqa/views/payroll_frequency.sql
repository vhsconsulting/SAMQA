-- liquibase formatted sql
-- changeset SAMQA:1754374177988 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\payroll_frequency.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/payroll_frequency.sql:null:8581fc4833d1f7792f3c17eff79ffbf0dd804ff6:create

create or replace force editionable view samqa.payroll_frequency (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'PAYROLL_FREQUENCY';

