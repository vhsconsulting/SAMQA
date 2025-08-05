-- liquibase formatted sql
-- changeset SAMQA:1754374178145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\person_title_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/person_title_v.sql:null:692a059c3ff40d64aec850a598f7a4fcfa57b376:create

create or replace force editionable view samqa.person_title_v (
    lookup_name,
    lookup_code,
    title
) as
    select
        lookup_name,
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'PERSON_TITLE';

