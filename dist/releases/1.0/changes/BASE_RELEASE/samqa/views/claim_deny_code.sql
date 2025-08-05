-- liquibase formatted sql
-- changeset SAMQA:1754374169800 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_deny_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_deny_code.sql:null:c00f2d19854bdc448fe4c845b0073d8e11e26316:create

create or replace force editionable view samqa.claim_deny_code (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_DENY_CODE';

