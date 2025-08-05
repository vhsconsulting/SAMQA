-- liquibase formatted sql
-- changeset SAMQA:1754374170120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_type.sql:null:4de5b599702c65fe74672816b313d03bad0d119a:create

create or replace force editionable view samqa.claim_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_TYPE';

