create or replace force editionable view samqa.er_user_v (
    user_name,
    acc_num,
    entrp_id,
    email,
    emp_reg_type,
    tax_id,
    user_id
) as
    select
        a.user_name,
        a.find_key,
        pc_entrp.get_entrp_id_from_ein(a.tax_id) entrp_id,
        a.email,
        emp_reg_type,
        a.tax_id,
        a.user_id
    from
        online_users a
    where
        a.user_type = 'E';


-- sqlcl_snapshot {"hash":"b90912d1d84f705d34a8d55bf74e37527b6b4861","type":"VIEW","name":"ER_USER_V","schemaName":"SAMQA","sxml":""}