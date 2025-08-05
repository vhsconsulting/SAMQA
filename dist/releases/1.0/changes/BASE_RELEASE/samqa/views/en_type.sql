-- liquibase formatted sql
-- changeset SAMQA:1754374172614 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\en_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/en_type.sql:null:23fde6b642a826990653b7ead9e327385be5ab58:create

create or replace force editionable view samqa.en_type (
    lookup_name,
    en_code,
    en_name
) as
    select
        lookup_name,
        lookup_code en_code,
        meaning     en_name
    from
        lookups
    where
        lookup_name = 'EN_TYPE';

