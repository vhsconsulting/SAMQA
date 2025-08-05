-- liquibase formatted sql
-- changeset SAMQA:1754374174972 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_uploaded_plan_types_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_uploaded_plan_types_v.sql:null:d5e1070228b94ed8d2294a4af635e50dd50b06e5:create

create or replace force editionable view samqa.fsa_uploaded_plan_types_v (
    ssn,
    entrp_id,
    plan_type,
    annual_election,
    effective_date,
    created_by
) as
    with enroll as (
        select distinct
            a.*
        from
            mass_enrollments         a,
            fsa_enrollments_external fsa
        where
                a.creation_date > sysdate - 1
            and a.error_message is null
            and a.ssn = fsa.ssn
            and a.account_type = 'FSA'
    )
    select
        a.ssn,
        entrp_id,
        'FSA'                  plan_type,
        a.hfsa_annual_election annual_election,
        a.hfsa_effective_date  effective_date,
        a.created_by
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
        a.created_by
    from
        enroll a
    where
        a.dep_fsa_flag = 'YES'
    union
    select
        a.ssn,
        entrp_id,
        'LPF',
        a.post_ded_annual_election,
        a.post_ded_effective_date,
        a.created_by
    from
        enroll a
    where
        a.post_ded_fsa_flag = 'YES'
    union
    select
        a.ssn,
        entrp_id,
        'TRN',
        a.transit_annual_election,
        a.transit_effective_date,
        a.created_by
    from
        enroll a
    where
        a.transit_fsa_flag = 'YES'
    union
    select
        a.ssn,
        entrp_id,
        'PKG',
        a.parking_annual_election,
        a.parking_effective_date,
        a.created_by
    from
        enroll a
    where
        a.parking_fsa_flag = 'YES'
    union
    select
        a.ssn,
        entrp_id,
        'UA1',
        a.bicycle_annual_election,
        a.bicycle_effective_date,
        a.created_by
    from
        enroll a
    where
        a.bicycle_fsa_flag = 'YES'
    union
    select
        ssn,
        entrp_id,
        'HRA',
        to_number(a.annual_election),
        a.effective_date,
        a.created_by
    from
        enroll a
    where
        a.hra_fsa_flag = 'YES';

