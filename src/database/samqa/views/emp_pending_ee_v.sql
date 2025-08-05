create or replace force editionable view samqa.emp_pending_ee_v (
    entrp_id,
    name,
    ssn,
    plan_name,
    reg_date,
    acc_num
) as
    select
        b.entrp_id,
        first_name
        || ' '
        || last_name name,
        ssn,
        plan_name,
        reg_date,
        (
            select
                acc_num
            from
                account
            where
                entrp_id = b.entrp_id
        )
    from
        account a,
        person  b,
        plans   c
    where
            a.plan_code = c.plan_code
        and a.pers_id = b.pers_id
        and a.account_status = 3;


-- sqlcl_snapshot {"hash":"0c1d3ec4f81665f5d8edea6f67f3f9e1331a5f66","type":"VIEW","name":"EMP_PENDING_EE_V","schemaName":"SAMQA","sxml":""}