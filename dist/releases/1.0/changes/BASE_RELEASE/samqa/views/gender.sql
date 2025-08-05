-- liquibase formatted sql
-- changeset SAMQA:1754374175119 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\gender.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/gender.sql:null:0cdbe844cd91ad5175cfa2fe5405f98eab39c65d:create

create or replace force editionable view samqa.gender (
    gender_code,
    gender
) as
    select
        lookup_code gender_code,
        meaning     gender
    from
        lookups
    where
        lookup_name = 'GENDER';

