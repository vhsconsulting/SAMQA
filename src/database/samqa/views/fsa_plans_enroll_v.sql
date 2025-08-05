create or replace force editionable view samqa.fsa_plans_enroll_v (
    pers_id,
    entrp_id,
    acc_id,
    plan_type,
    annual_election,
    effective_date,
    created_by,
    coverage_tier_name
) as
    with enroll as (
        select
            a.*
        from
            mass_enrollments         a,
            fsa_enrollments_external fsa
        where
            a.pers_id is not null
            and a.ssn = lpad(fsa.ssn, 9, '0')
            and a.account_type = 'FSA'
                       -- and A.ERROR_MESSAGE IS  NULL
            and exists (
                select
                    *
                from
                    person
                where
                    mass_enrollment_id = a.mass_enrollment_id
            )
    )
    select
        a.pers_id,
        entrp_id,
        a.acc_id,
        'FSA'                  plan_type,
        a.hfsa_annual_election annual_election,
        a.hfsa_effective_date  effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.health_fsa_flag = 'YES'
    union
    select
        a.pers_id,
        entrp_id,
        a.acc_id,
        'DCA',
        a.dfsa_annual_election,
        a.dfsa_effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.dep_fsa_flag = 'YES'
    union
    select
        pers_id,
        entrp_id,
        a.acc_id,
        'LPF',
        a.post_ded_annual_election,
        a.post_ded_effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.post_ded_fsa_flag = 'YES'
    union
    select
        pers_id,
        entrp_id,
        a.acc_id,
        'TRN',
        a.transit_annual_election,
        a.transit_effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.transit_fsa_flag = 'YES'
    union
    select
        pers_id,
        entrp_id,
        a.acc_id,
        'PKG',
        a.parking_annual_election,
        a.parking_effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.parking_fsa_flag = 'YES'
    union
    select
        pers_id,
        entrp_id,
        a.acc_id,
        'UA1',
        a.bicycle_annual_election,
        a.bicycle_effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.bicycle_fsa_flag = 'YES'
    union
    select
        pers_id,
        entrp_id,
        a.acc_id,
        'HRA',
        to_number(a.annual_election),
        a.effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.hra_fsa_flag = 'YES';


-- sqlcl_snapshot {"hash":"cfbd1e7bfb0f68dd14bcb4cd6a0bfd6cbf27ac24","type":"VIEW","name":"FSA_PLANS_ENROLL_V","schemaName":"SAMQA","sxml":""}