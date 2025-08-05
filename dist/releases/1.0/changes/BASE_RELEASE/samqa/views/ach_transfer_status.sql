-- liquibase formatted sql
-- changeset SAMQA:1754374167647 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ach_transfer_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ach_transfer_status.sql:null:f467d6d74c1cb657dd2ab97ef22682228311f152:create

create or replace force editionable view samqa.ach_transfer_status (
    status_code,
    status
) as
    select
        lookup_code status_code,
        meaning     status
    from
        lookups
    where
        lookup_name = 'ACH_TRANSFER_STATUS';

