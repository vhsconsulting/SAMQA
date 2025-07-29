create or replace force editionable view samqa.enrolled_subscribers_v (
    user_name,
    acc_num,
    title,
    first_name,
    middle_name,
    last_name,
    emp_group,
    emp_name,
    emp_contact_person,
    gender,
    ssn,
    birth_date,
    drivlic,
    passport,
    address,
    city,
    state,
    zip,
    phone_day,
    email,
    broker_id,
    carrier_name,
    carrier_id,
    pers_id,
    health_plan_eff_date,
    plan_type,
    deductible,
    plan_code,
    plan_name,
    fee_setup,
    fee_maint,
    initial_contribution,
    bank_name,
    account_type,
    routing_number,
    bank_account_number,
    creation_date,
    ip_address,
    debit_card_flag,
    account_status
) as
    select
        nvl(a.user_name,(
            select
                user_name
            from
                online_users
            where
                find_key = c.acc_num
        ))                                                                                                                    user_name
        ,
        c.acc_num,
        a.title,
        a.first_name,
        a.middle_name,
        a.last_name,
        (
            select
                k.acc_num
            from
                account k
            where
                k.entrp_id = b.pers_id
        )                                                                                                                     emp_group
        ,
        d.name                                                                                                                emp_name
        ,
        d.entrp_contact                                                                                                       emp_contact_person
        ,
        decode(b.gender, 'M', 'Male', 'Female')                                                                               gender,
        b.ssn,
        b.birth_date,
        b.drivlic,
        b.passport,
        b.address,
        b.city,
        b.state,
        b.zip,
        b.phone_day,
        b.email,
        c.broker_id,
        a.carrier_name,
        a.carrier_id,
        a.pers_id,
        a.health_plan_eff_date,
        (
            select
                plan_name
            from
                plan_type
            where
                plan_type_code = a.plan_type
        )                                                                                                                     plan_type
        ,
        a.deductible,
        a.plan_code,
        (
            select
                plan_name
            from
                plans
            where
                plans.plan_code = a.plan_code
        )                                                                                                                     plan_name
        ,
        c.fee_setup,
        c.fee_maint,
        nvl(a.ee_contribution, 0) + nvl(a.er_contribution, 0) + nvl(a.ee_fee_contribution, 0) + nvl(a.er_fee_contribution, 0) initial_contribution
        ,
        a.bank_name,
        a.account_type,
        a.routing_number,
        a.bank_account_number,
        a.creation_date,
        a.ip_address,
        a.debit_card_flag,
        c.account_status
    from
        online_enrollment a,
        person            b,
        account           c,
        enterprise        d
    where
            a.pers_id = b.pers_id
        and b.pers_id = c.pers_id
        and b.entrp_id = d.entrp_id (+);


-- sqlcl_snapshot {"hash":"78915599375dcb1555c005ee835b65d2f8381d3a","type":"VIEW","name":"ENROLLED_SUBSCRIBERS_V","schemaName":"SAMQA","sxml":""}