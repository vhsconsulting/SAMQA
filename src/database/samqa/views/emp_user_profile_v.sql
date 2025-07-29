create or replace force editionable view samqa.emp_user_profile_v (
    user_name,
    email,
    find_key,
    user_id,
    tax_id
) as
    select
        c.user_name,
        c.email,
        c.find_key,
        c.user_id,
        c.tax_id
    from
        online_users c,
        account      a
    where
            c.find_key = a.acc_num
        and c.user_type = 'E';


-- sqlcl_snapshot {"hash":"9c608cb0863842ae34cd23afc9a3b55399667532","type":"VIEW","name":"EMP_USER_PROFILE_V","schemaName":"SAMQA","sxml":""}