-- liquibase formatted sql
-- changeset SAMQA:1754374169739 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_checks_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_checks_v.sql:null:cf073b096f44ffbe196af96e5bea72d1f82b3e8f:create

create or replace force editionable view samqa.claim_checks_v (
    acc_id,
    claim_id,
    check_number,
    check_amount,
    check_date,
    mailed_date,
    issued_date,
    returned
) as
    select
        acc_id,
        entity_id claim_id,
        check_number,
        check_amount,
        check_date,
        mailed_date,
        issued_date,
        returned
    from
        checks
    where
        entity_type = 'CLAIMN';

