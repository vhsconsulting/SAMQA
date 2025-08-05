-- liquibase formatted sql
-- changeset SAMQA:1754374178136 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\person_profession_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/person_profession_v.sql:null:5247309fddca6e100de60604cf8b33d84076b1a3:create

create or replace force editionable view samqa.person_profession_v (
    profession
) as
    select
        meaning
    from
        lookups
    where
        lookup_name = 'PROFESSION';

