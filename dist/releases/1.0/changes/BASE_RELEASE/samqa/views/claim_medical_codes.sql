-- liquibase formatted sql
-- changeset SAMQA:1754374169891 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_medical_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_medical_codes.sql:null:4279e7666603607df76ed9b8cdfc14814b3c44a5:create

create or replace force editionable view samqa.claim_medical_codes (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_MEDICAL_CODES';

