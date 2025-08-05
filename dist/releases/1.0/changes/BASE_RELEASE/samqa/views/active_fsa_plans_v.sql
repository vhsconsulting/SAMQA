-- liquibase formatted sql
-- changeset SAMQA:1754374167757 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\active_fsa_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/active_fsa_plans_v.sql:null:8d9a683e173c8029c1379170f7e536648eeb7064:create

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

