create or replace force editionable view samqa.sterling_users_v (
    user_name,
    password,
    user_type,
    emp_reg_type,
    find_key,
    locked_time,
    succ_access,
    last_login,
    failed_att,
    failed_ip,
    create_pw,
    change_pw,
    email,
    pw_question,
    pw_answer,
    user_id,
    confirmed_flag,
    creation_date,
    last_update_date,
    account_type,
    acc_id,
    tax_id
) as
    select
        a.user_name,
        a.password,
        a.user_type,
        a.emp_reg_type,
        b.acc_num find_key,
        a.locked_time,
        a.succ_access,
        a.last_login,
        a.failed_att,
        a.failed_ip,
        a.create_pw,
        a.change_pw,
        a.email,
        a.pw_question,
        a.pw_answer,
        a.user_id,
        a.confirmed_flag,
        a.creation_date,
        a.last_update_date,
        b.account_type,
        b.acc_id,
        a.tax_id
    from
        online_users a,
        account      b,
        plans        c
    where
            a.user_id = pc_users.get_user(a.tax_id, a.user_type, a.emp_reg_type)
        and b.acc_num = pc_users.get_find_key(a.tax_id, a.user_type, a.emp_reg_type)
        and b.plan_code = c.plan_code
        and c.plan_sign = 'SHA'
        and a.user_status = 'A'
    union
    select
        a.user_name,
        a.password,
        a.user_type,
        a.emp_reg_type,
        a.find_key,
        a.locked_time,
        a.succ_access,
        a.last_login,
        a.failed_att,
        a.failed_ip,
        a.create_pw,
        a.change_pw,
        a.email,
        a.pw_question,
        a.pw_answer,
        a.user_id,
        a.confirmed_flag,
        a.creation_date,
        a.last_update_date,
        null,
        b.broker_id,
        upper(b.broker_lic)
    from
        online_users a,
        broker       b
    where
        a.find_key = upper(b.broker_lic);


-- sqlcl_snapshot {"hash":"4214dd92170290eae2da9c04980cf5d4b2d131a2","type":"VIEW","name":"STERLING_USERS_V","schemaName":"SAMQA","sxml":""}