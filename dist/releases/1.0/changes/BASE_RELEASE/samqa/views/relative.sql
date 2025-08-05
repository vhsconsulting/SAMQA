-- liquibase formatted sql
-- changeset SAMQA:1754374178489 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\relative.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/relative.sql:null:55dd39117574701163ec651b16a3c9c96ef6a9ca:create

create or replace force editionable view samqa.relative (
    lookup_name,
    relat_code,
    relat_name
) as
    select
        lookup_name,
        lookup_code relat_code,
        meaning     relat_name
    from
        lookups
    where
        lookup_name = 'RELATIVE';

