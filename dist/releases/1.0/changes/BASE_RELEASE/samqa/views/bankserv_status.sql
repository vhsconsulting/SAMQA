-- liquibase formatted sql
-- changeset SAMQA:1754374168421 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\bankserv_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/bankserv_status.sql:null:50e5a5dea0f96df9a32695c65e2efc1aa6c9dc41:create

create or replace force editionable view samqa.bankserv_status (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'BANKSERV_STATUS';

