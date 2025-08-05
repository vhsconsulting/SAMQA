-- liquibase formatted sql
-- changeset SAMQA:1754374170096 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_status.sql:null:2ac236d06380e51a02c43114f8ee055bedb20cba:create

create or replace force editionable view samqa.claim_status (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_STATUS';

