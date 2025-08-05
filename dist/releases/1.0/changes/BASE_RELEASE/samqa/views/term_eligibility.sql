-- liquibase formatted sql
-- changeset SAMQA:1754374179895 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\term_eligibility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/term_eligibility.sql:null:fc12f65bed730924a001106fb377d5ec29e1fdd0:create

create or replace force editionable view samqa.term_eligibility (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'TERM_ELIGIBILITY';

