create or replace force editionable view samqa.plan_codes (
    plan_code,
    plan_name,
    plan_sign,
    fsetup,
    fmonth
) as
    select
        plan_code,
        plan_name,
        plan_sign,
        nvl(
            pc_plan.fsetup(plan_code),
            0
        ) fsetup,
        nvl(
            pc_plan.fmonth(plan_code),
            0
        ) fmonth
    from
        plans;


-- sqlcl_snapshot {"hash":"c0924d7a6b58d60b84a4905681e7cf3b8030e216","type":"VIEW","name":"PLAN_CODES","schemaName":"SAMQA","sxml":""}