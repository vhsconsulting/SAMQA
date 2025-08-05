-- liquibase formatted sql
-- changeset SAMQA:1754374178223 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\plan_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/plan_codes.sql:null:c0924d7a6b58d60b84a4905681e7cf3b8030e216:create

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

