-- liquibase formatted sql
-- changeset SAMQA:1754374175102 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\funding_option.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/funding_option.sql:null:f72f85e48a97ff1dc662286ff3e21dae1fd5c263:create

create or replace force editionable view samqa.funding_option (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'FUNDING_OPTION';

