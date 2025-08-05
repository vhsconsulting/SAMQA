create or replace force editionable view samqa.enroll_acc_v (
    user_name,
    acc_num,
    entrp_id,
    email,
    tax_id
) as
    select
        a.user_name,
        b.acc_num,
        b.entrp_id,
        a.email,
        a.tax_id
    from
        online_users a,
        account      b
    where
            a.find_key = b.acc_num
        and b.pers_id is null
        and a.emp_reg_type = '1';


-- sqlcl_snapshot {"hash":"d182a53bc48089b311e9871d45074e5846a8d101","type":"VIEW","name":"ENROLL_ACC_V","schemaName":"SAMQA","sxml":""}