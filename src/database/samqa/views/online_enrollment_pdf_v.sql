create or replace force editionable view samqa.online_enrollment_pdf_v (
    user_name,
    name,
    file_name,
    ssn,
    gender,
    birth_date,
    address,
    city,
    state,
    zip,
    drivlic,
    employer_name,
    employer_group,
    email,
    phone,
    carrier_name,
    health_plan_eff_date,
    deductible,
    acc_num,
    setup_fee,
    maintenance_fee,
    initial_contribution,
    total_setup_fees,
    debit_card_requested,
    hsa_plan_type,
    bank_name,
    account_type,
    routing_number,
    bank_account_number,
    creation_date,
    ip_address,
    referrer,
    pers_id
) as
    select
        pc_users.get_user_name(pc_users.get_user(
            replace(ssn, '-'),
            'S',
            2
        ))                                                                                                            user_name,
        first_name
        || ', '
        || middle_name
        || ' '
        || last_name                                                                                                  name,
        b.acc_num                                                                                                     file_name,
        ssn,
        decode(gender, 'M', 'Male', 'Female')                                                                         gender,
        a.birth_date,
        a.address,
        a.city,
        a.state,
        a.zip,
        id_number                                                                                                     drivlic,
        e.name                                                                                                        employer_name,
        (
            select
                acc_num
            from
                account kk
            where
                kk.entrp_id = e.entrp_id
        )                                                                                                             employer_group,
        a.email,
        a.phone,
        pc_entrp.get_entrp_name(c.insur_id)                                                                           carrier_name,
        to_char(c.start_date, 'MM/DD/YYYY')                                                                           health_plan_eff_date
        ,
        c.deductible,
        b.acc_num,
        b.fee_setup                                                                                                   setup_fee,
        b.fee_maint * 2                                                                                               maintenance_fee
        ,
        nvl(er_contribution, 0) + nvl(ee_contribution, 0) + nvl(er_fee_contribution, 0) + nvl(ee_fee_contribution, 0) initial_contribution
        ,
        b.fee_setup + ( b.fee_maint * 2 )                                                                             total_setup_fees
        ,
        decode(a.debit_card_flag, 'Y', 'Yes', 'No')                                                                   debit_card_requested
        ,
        (
            select
                plan_name
            from
                plan_type
            where
                plan_type_code = c.plan_type
        )                                                                                                             hsa_plan_type,
        bank_name,
        b.account_type,
        routing_number,
        bank_account_number,
        a.creation_date,
        ip_address,
        'SterlingHSA'                                                                                                 referrer,
        a.pers_id
    from
        online_enrollment a,
        account           b,
        insure            c,
        enterprise        e
    where
            a.acc_id = b.acc_id
        and c.pers_id = a.pers_id
        and a.entrp_id = e.entrp_id (+);


-- sqlcl_snapshot {"hash":"8ffd76ab3ba571f0108bb97a408c4575ea12f20d","type":"VIEW","name":"ONLINE_ENROLLMENT_PDF_V","schemaName":"SAMQA","sxml":""}