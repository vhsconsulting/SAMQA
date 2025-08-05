-- liquibase formatted sql
-- changeset SAMQA:1754374180165 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\web_reimbursement_mode.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/web_reimbursement_mode.sql:null:b13952c371e298048c3f95a6396c7620d1faa7c1:create

create or replace force editionable view samqa.web_reimbursement_mode (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'WEB_REIMBURSEMENT_MODE';

