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


-- sqlcl_snapshot {"hash":"cf073b096f44ffbe196af96e5bea72d1f82b3e8f","type":"VIEW","name":"CLAIM_CHECKS_V","schemaName":"SAMQA","sxml":""}