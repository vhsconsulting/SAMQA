-- liquibase formatted sql
-- changeset SAMQA:1754374180057 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\us_states.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/us_states.sql:null:fa56b362479f45ce0c5e2b27d01c4848173d48e2:create

create or replace force editionable view samqa.us_states (
    lookup_name,
    state_abbr,
    state_name
) as
    select
        lookup_name,
        lookup_code state_abbr,
        meaning     state_name
    from
        lookups
    where
        lookup_name = 'STATE';

