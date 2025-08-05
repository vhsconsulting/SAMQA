-- liquibase formatted sql
-- changeset SAMQA:1754374178154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\person_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/person_type.sql:null:4291fb9bc3e1fd8a6a3d6004929d709f3450b9a5:create

create or replace force editionable view samqa.person_type (
    person_type,
    meaning
) as
    select
        lookup_code person_type,
        description meaning
    from
        lookups
    where
        lookup_name = 'PERSON_TYPE';

