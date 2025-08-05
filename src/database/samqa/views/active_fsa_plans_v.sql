create or replace force editionable view samqa.active_fsa_plans_v (
    acc_id,
    plan_name,
    plan_type
) as
    select
        acc_id,
        pc_benefit_plans.get_plan_name(plan_type, ben_plan_id) plan_name,
        plan_type
    from
        ben_plan_enrollment_setup a
    where
            a.status = 'A'
        and trunc(a.plan_start_date, 'YYYY') = trunc(sysdate, 'YYYY');


-- sqlcl_snapshot {"hash":"8d9a683e173c8029c1379170f7e536648eeb7064","type":"VIEW","name":"ACTIVE_FSA_PLANS_V","schemaName":"SAMQA","sxml":""}