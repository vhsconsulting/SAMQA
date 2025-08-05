-- liquibase formatted sql
-- changeset SAMQA:1754374170993 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\coverage_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/coverage_type.sql:null:0d48233c7b82c864713cccd86c0f3cafbb8b28a4:create

create or replace force editionable view samqa.coverage_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'COVERAGE_TYPE';

