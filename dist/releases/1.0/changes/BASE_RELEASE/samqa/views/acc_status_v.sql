-- liquibase formatted sql
-- changeset SAMQA:1754374166654 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\acc_status_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/acc_status_v.sql:null:4b2ae8dbf611b334eb8e6896e20efc5580db3026:create

create or replace force editionable view samqa.acc_status_v (
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

