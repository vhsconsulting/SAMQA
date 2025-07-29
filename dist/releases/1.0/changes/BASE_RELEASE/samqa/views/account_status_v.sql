-- liquibase formatted sql
-- changeset SAMQA:1753779778706 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\account_status_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/account_status_v.sql:null:a6d575a7444e1cc5cdd04875f0c7f1bb7842003f:create

create or replace force editionable view samqa.account_status_v (
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

