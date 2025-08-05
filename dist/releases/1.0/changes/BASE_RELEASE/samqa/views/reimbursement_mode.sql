-- liquibase formatted sql
-- changeset SAMQA:1754374178480 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\reimbursement_mode.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/reimbursement_mode.sql:null:6cb8ed42e97667ee9881395a330b99d354e9df63:create

create or replace force editionable view samqa.reimbursement_mode (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'REIMBURSEMENT_MODE';

