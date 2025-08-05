-- liquibase formatted sql
-- changeset SAMQA:1754374173626 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_balances_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_balances_v.sql:null:c1102c2df21b3c555d8db370a9ecc65918e9b88d:create

create or replace force editionable view samqa.fsa_balances_v (
    acc_id,
    effective_date,
    annual_election,
    acc_balance,
    plan_type
) as
    select
        acc_id,
        to_char(effective_date, 'MM/DD/RRRR')                          effective_date,
        annual_election,
        pc_account.acc_balance(acc_id,
                               trunc(plan_start_date),
                               trunc(plan_end_date),
                               'FSA',
                               plan_type)                                          acc_balance,
        pc_benefit_plans.get_plan_name(ben.plan_type, ben.ben_plan_id) plan_type
    from
        ben_plan_enrollment_setup ben
    where
        status in ( 'A', 'I' )
        and product_type = 'FSA';

