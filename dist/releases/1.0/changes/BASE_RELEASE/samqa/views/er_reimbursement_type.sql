-- liquibase formatted sql
-- changeset SAMQA:1754374173088 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\er_reimbursement_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/er_reimbursement_type.sql:null:5b77841226b4243e4110e33a44f44d11b398baf7:create

create or replace force editionable view samqa.er_reimbursement_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'ER_REIMBURSEMENT_TYPE';

