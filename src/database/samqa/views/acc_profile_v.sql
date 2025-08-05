create or replace force editionable view samqa.acc_profile_v (
    first_name,
    middle_name,
    last_name,
    name,
    address,
    city,
    state,
    zip,
    phone_day,
    annual_election,
    available_balance,
    acc_id,
    acc_num,
    start_date,
    division_code
) as
    select
        a.first_name,
        a.middle_name,
        a.last_name,
        a.first_name
        || ' '
        || a.middle_name
        || ' '
        || a.last_name                                                                                    name,
        a.address,
        a.city,
        a.state,
        a.zip,
        a.phone_day,
        c.annual_election,
        pc_account.acc_balance(b.acc_id, c.plan_start_date, c.plan_end_date, b.account_type, c.plan_type) available_balance,
        b.acc_id,
        b.acc_num,
        to_char(start_date, 'MM/DD/YYYY')                                                                 start_date,
        a.division_code
    from
        person                    a,
        account                   b,
        ben_plan_enrollment_setup c
    where
            a.pers_id = b.pers_id
        and c.acc_id = b.acc_id
        and c.status <> 'R'
        and trunc(c.plan_end_date) > trunc(sysdate)
        and trunc(c.plan_start_date) < trunc(sysdate);


-- sqlcl_snapshot {"hash":"e8997a484eb0ae31f36069dc783c10eed816dd90","type":"VIEW","name":"ACC_PROFILE_V","schemaName":"SAMQA","sxml":""}