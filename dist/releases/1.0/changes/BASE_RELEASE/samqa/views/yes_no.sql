-- liquibase formatted sql
-- changeset SAMQA:1754374180203 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\yes_no.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/yes_no.sql:null:e8fe0626ad9588423bed87f63990dd5616220000:create

create or replace force editionable view samqa.yes_no (
    yes_no_code,
    yes_no_meaning
) as
    select
        lookup_code yes_no_code,
        meaning     yes_no_meaning
    from
        lookups
    where
        lookup_name = 'YES_NO';

