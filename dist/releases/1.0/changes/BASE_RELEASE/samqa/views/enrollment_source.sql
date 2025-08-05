-- liquibase formatted sql
-- changeset SAMQA:1754374172825 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\enrollment_source.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/enrollment_source.sql:null:ad94ef7963dbb799a400672e5d2f36882e3a2357:create

create or replace force editionable view samqa.enrollment_source (
    source_code,
    meaning
) as
    select
        lookup_code source_code,
        meaning     gender
    from
        lookups
    where
        lookup_name = 'ENROLLMENT_SOURCE';

