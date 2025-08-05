-- liquibase formatted sql
-- changeset SAMQA:1754374174924 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_plans_online_enroll_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_plans_online_enroll_v.sql:null:14a0a41a3c7f91dcd51fa892d1e071a9ac247fa2:create

create or replace force editionable view samqa.fsa_plans_online_enroll_v (
    ssn,
    entrp_id,
    plan_type,
    annual_election,
    effective_date,
    created_by,
    batch_number
) as
    with enroll as (
        select
            a.*
        from
            online_enrollment a
        where
            a.pers_id is null
            and a.account_type = 'FSA'
            and batch_number is not null
    )
    select
        a.ssn,
        entrp_id,
        'FSA'                  plan_type,
        a.hfsa_annual_election annual_election,
        a.hfsa_effective_date  effective_date,
        a.created_by,
        batch_number
    from
        enroll a
    where
        a.health_fsa_flag = 'YES'
    union
    select
        a.ssn,
        entrp_id,
        'DCA',
        a.dfsa_annual_election,
        a.dfsa_effective_date,
        a.created_by,
        batch_number
    from
        enroll a
    where
        a.dep_fsa_flag = 'YES'
    union
    select
        ssn,
        entrp_id,
        'LPF',
        a.post_ded_annual_election,
        a.post_ded_effective_date,
        a.created_by,
        batch_number
    from
        enroll a
    where
        a.post_ded_fsa_flag = 'YES'
    union
    select
        ssn,
        entrp_id,
        'TRN',
        a.transit_annual_election,
        a.transit_effective_date,
        a.created_by,
        batch_number
    from
        enroll a
    where
        a.transit_fsa_flag = 'YES'
    union
    select
        ssn,
        entrp_id,
        'PKG',
        a.parking_annual_election,
        a.parking_effective_date,
        a.created_by,
        batch_number
    from
        enroll a
    where
        a.parking_fsa_flag = 'YES'
    union
    select
        ssn,
        entrp_id,
        'UA1',
        a.bicycle_annual_election,
        a.bicycle_effective_date,
        a.created_by,
        batch_number
    from
        enroll a
    where
        a.bicycle_fsa_flag = 'YES';

