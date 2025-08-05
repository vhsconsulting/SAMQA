-- liquibase formatted sql
-- changeset SAMQA:1754374169691 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cc_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cc_type.sql:null:ae271b56ad95a4656c012b89b4af9fbec8b101e5:create

create or replace force editionable view samqa.cc_type (
    lookup_name,
    cc_code,
    cc_name
) as
    select
        lookup_name,
        lookup_code cc_code,
        meaning     cc_name
    from
        lookups
    where
        lookup_name = 'CC_TYPE';

