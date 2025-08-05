create or replace force editionable view samqa.account_v (
    pers_id,
    acc_id,
    reg_date,
    start_date,
    acc_num,
    birth_date,
    blocked_flag,
    enroll_flag,
    account_type,
    account_status,
    complete_flag,
    ssn
) as
    select
        pen.pers_id                pers_id,
        acc.acc_id,
        acc.reg_date               reg_date,
        acc.start_date             start_date,
        acc.acc_num,
        pen.birth_date             birth_date,
        nvl(acc.blocked_flag, 'N') blocked_flag,
        (
            select
                count(*)
            from
                online_enrollment b
            where
                acc.acc_num = b.acc_num
        )                          enroll_flag,
        acc.account_type,
        acc.account_status,
        acc.complete_flag,
        pen.ssn
    from
        account acc,
        person  pen
    where
            pen.pers_id = acc.pers_id
        and acc.account_status <> 5;


-- sqlcl_snapshot {"hash":"6afc4e20aa8269dccbc5889c6fd90d6788faec6f","type":"VIEW","name":"ACCOUNT_V","schemaName":"SAMQA","sxml":""}