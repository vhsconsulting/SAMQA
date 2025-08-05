-- liquibase formatted sql
-- changeset SAMQA:1754374167154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\account_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/account_type.sql:null:dc1af80a93a2276feaaf14ffd5da5cc0babee832:create

create or replace force editionable view samqa.account_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'ACCOUNT_TYPE';

