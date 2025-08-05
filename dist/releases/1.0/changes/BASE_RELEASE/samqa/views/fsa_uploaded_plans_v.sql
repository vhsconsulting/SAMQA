-- liquibase formatted sql
-- changeset SAMQA:1754374175033 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_uploaded_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_uploaded_plans_v.sql:null:b6d0eae89a214c32f72b774ef08bf882f9a8e726:create

create or replace force editionable view samqa.fsa_uploaded_plans_v (
    pers_id,
    entrp_id,
    acc_id,
    batch_number,
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
            mass_enrollments a
        where
            a.pers_id is not null
    --  AND   A.ERROR_MESSAGE IS NULL
            and a.account_type in ( 'HRA', 'FSA' )
            and exists (
                select
                    *
                from
                    person
                where
                    pers_id = a.pers_id
            )
    )
    select
        a.pers_id,
        entrp_id,
        a.acc_id,
        a.batch_number,
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
        a.batch_number,
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
        a.batch_number,
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
        a.batch_number,
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
        a.batch_number,
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
        a.batch_number,
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
        a.batch_number,
        'HRA',
        to_number(a.annual_election),
        a.effective_date,
        a.created_by,
        a.coverage_tier_name
    from
        enroll a
    where
        a.hra_fsa_flag = 'YES';

