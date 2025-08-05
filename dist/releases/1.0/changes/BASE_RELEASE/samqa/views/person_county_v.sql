-- liquibase formatted sql
-- changeset SAMQA:1754374178083 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\person_county_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/person_county_v.sql:null:68ceea61858ca14ae9f0ec9cf779c10d59e2f473:create

create or replace force editionable view samqa.person_county_v (
    lookup_name,
    lookup_code,
    county
) as
    select
        lookup_name,
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'COUNTY';

