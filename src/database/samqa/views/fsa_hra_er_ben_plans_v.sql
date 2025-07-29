create or replace force editionable view samqa.fsa_hra_er_ben_plans_v (
    acc_num,
    plan_start_date,
    plan_end_date,
    plan_type,
    plan_type_meaning,
    acc_id,
    entrp_id,
    status,
    effective_date,
    effective_end_date,
    ben_plan_id,
    minimum_election,
    maximum_election,
    open_enrollment_start_date,
    open_enrollment_end_date,
    runout_period_days,
    grace_period,
    product_type
) as
    select
        b.acc_num,
        a.plan_start_date,
        a.plan_end_date,
        a.plan_type,
        case
            when pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA' then
                pc_lookups.get_meaning(a.plan_type, 'FSA_PLAN_TYPE')
                || '-'
                || a.ben_plan_name
            else
                pc_lookups.get_meaning(a.plan_type, 'FSA_PLAN_TYPE')
        end                                        plan_type_meaning,
        a.acc_id,
        b.entrp_id,
        a.status,
        a.effective_date,
        a.effective_end_date,
        a.ben_plan_id,
        a.minimum_election,
        a.maximum_election,
        nvl(a.open_enrollment_start_date, sysdate) open_enrollment_start_date,
        nvl(a.open_enrollment_end_date, sysdate)   open_enrollment_end_date,
        a.runout_period_days,
        a.grace_period,
        a.product_type
    from
        ben_plan_enrollment_setup a,
        account                   b
    where
            a.acc_id = b.acc_id
        and b.entrp_id is not null
        and a.status <> 'R'
        and a.product_type in ( 'HRA', 'FSA' );


-- sqlcl_snapshot {"hash":"318c4f0475a92f8effde893a449478067207fd4c","type":"VIEW","name":"FSA_HRA_ER_BEN_PLANS_V","schemaName":"SAMQA","sxml":""}