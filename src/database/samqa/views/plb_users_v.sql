create or replace force editionable view samqa.plb_users_v (
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
    blocked,
    end_date,
    account_status
) as
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
        a.blocked,
        b.end_date,
        b.account_status
    from
        online_users a,
        account      b,
        plans        c
    where
            a.find_key = b.acc_num
        and b.plan_code = c.plan_code
        and c.plan_sign <> 'SHA';


-- sqlcl_snapshot {"hash":"2d239ff389ce9f99caa394d5821d48eee34cb672","type":"VIEW","name":"PLB_USERS_V","schemaName":"SAMQA","sxml":""}