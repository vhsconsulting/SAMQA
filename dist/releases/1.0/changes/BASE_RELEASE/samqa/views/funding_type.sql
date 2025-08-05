-- liquibase formatted sql
-- changeset SAMQA:1754374175111 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\funding_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/funding_type.sql:null:e764b97faaa2e314af83f04aa36df39121550a53:create

create or replace force editionable view samqa.funding_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FUNDING_TYPE';

