create or replace force editionable view samqa.ben_plans_acc_v (
    ben_plan_id,
    plan_name,
    plan_type,
    acc_id,
    plan_start_date,
    plan_end_date,
    status,
    annual_election,
    effective_end_date,
    effective_date
) as
    select
        ben_plan_id,
        case
            when product_type = 'HRA' then
                ben_plan_name
            else
                pc_lookups.get_meaning(plan_type, 'FSA_PLAN_TYPE')
        end plan_name,
        plan_type,
        acc_id,
        plan_start_date,
        plan_end_date,
        status,
        annual_election,
        effective_end_date,
        effective_date
    from
        ben_plan_enrollment_setup a
    where
            trunc(plan_start_date) <= trunc(sysdate)
        and effective_end_date is null
        and plan_end_date + nvl(runout_period_days, 0) + nvl(grace_period, 0) >= trunc(sysdate)
        and a.status <> 'R'
    union
    select
        ben_plan_id,
        case
            when product_type = 'HRA' then
                ben_plan_name
            else
                pc_lookups.get_meaning(plan_type, 'FSA_PLAN_TYPE')
        end plan_name,
        plan_type,
        acc_id,
        plan_start_date,
        plan_end_date,
        status,
        annual_election,
        effective_end_date,
        effective_date
    from
        ben_plan_enrollment_setup a
    where
            trunc(plan_start_date) <= trunc(sysdate)
        and effective_end_date is not null
        and runout_period_term = 'CPE'
        and effective_end_date + nvl(runout_period_days, 0) >= trunc(sysdate)
        and a.status <> 'R'
    union
    select
        ben_plan_id,
        case
            when product_type = 'HRA' then
                ben_plan_name
            else
                pc_lookups.get_meaning(plan_type, 'FSA_PLAN_TYPE')
        end plan_name,
        plan_type,
        acc_id,
        plan_start_date,
        plan_end_date,
        status,
        annual_election,
        effective_end_date,
        effective_date
    from
        ben_plan_enrollment_setup a
    where
            trunc(plan_start_date) <= trunc(sysdate)
        and effective_end_date is not null
        and runout_period_term = 'CYE'
        and plan_end_date + nvl(runout_period_days, 0) >= trunc(sysdate)
        and a.status <> 'R'
    order by
        1;


-- sqlcl_snapshot {"hash":"d3eb7079d2e0b1bb1de44033375cd1d9ed258d75","type":"VIEW","name":"BEN_PLANS_ACC_V","schemaName":"SAMQA","sxml":""}