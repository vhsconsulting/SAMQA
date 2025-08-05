-- liquibase formatted sql
-- changeset SAMQA:1754374167655 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ach_transfer_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ach_transfer_type.sql:null:1a8b770dc1e8d3102898b2b5c13d1d509010bf7c:create

create or replace force editionable view samqa.ach_transfer_type (
    transfer_type,
    transfer_name
) as
    select
        lookup_code transfer_type,
        meaning     transfer_name
    from
        lookups
    where
        lookup_name = 'ACH_TRANSFER_TYPE';

