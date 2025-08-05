create or replace force editionable view samqa.enrollment_pdf_v (
    user_name,
    name,
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
        user_name,
        first_name
        || ', '
        || middle_name
        || ' '
        || last_name                                                                                                  name,
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
        carrier_name,
        health_plan_eff_date,
        deductible,
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
                plan_type_code = a.plan_type
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
        enterprise        e
    where
            a.acc_id = b.acc_id
        and a.entrp_id = e.entrp_id (+);


-- sqlcl_snapshot {"hash":"4bb8b2f99f28cd55a6ebf3ff0a4023a0b4e82c82","type":"VIEW","name":"ENROLLMENT_PDF_V","schemaName":"SAMQA","sxml":""}