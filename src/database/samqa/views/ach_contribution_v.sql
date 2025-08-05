create or replace force editionable view samqa.ach_contribution_v (
    transaction_id,
    acc_num,
    acc_id,
    status,
    ee_amount,
    er_amount,
    ee_fee_amount,
    er_fee_amount,
    total_contrib,
    transaction_date,
    transaction_type
) as
    select
        c.transaction_id,
        b.acc_num,
        c.acc_id,
        c.status,
        sum(ee_amount)     ee_amount,
        sum(er_amount)     er_amount,
        sum(ee_fee_amount) ee_fee_amount,
        sum(er_fee_amount) er_fee_amount,
        c.total_amount     total_contrib,
        c.transaction_date transaction_date,
        c.transaction_type
    from
        ach_transfer_details a,
        ach_transfer         c,
        account              b
    where
            c.acc_id = b.acc_id
        and a.transaction_id = c.transaction_id
    group by
        c.transaction_id,
        c.acc_id,
        acc_num,
        c.status,
        c.total_amount,
        c.transaction_date,
        c.transaction_type;


-- sqlcl_snapshot {"hash":"8fe8cf4431c09710cd4fe7525a0b8430f4e007c2","type":"VIEW","name":"ACH_CONTRIBUTION_V","schemaName":"SAMQA","sxml":""}