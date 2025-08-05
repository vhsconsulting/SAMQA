-- liquibase formatted sql
-- changeset SAMQA:1754374167146 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\account_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/account_status.sql:null:780656b818d634243976f078a26b316c16f61ed9:create

create or replace force editionable view samqa.account_status (
    status_code,
    status
) as
    select
        lookup_code status_code,
        meaning     status
    from
        lookups
    where
        lookup_name = 'ACCOUNT_STATUS';

