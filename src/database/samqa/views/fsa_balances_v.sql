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


-- sqlcl_snapshot {"hash":"c1102c2df21b3c555d8db370a9ecc65918e9b88d","type":"VIEW","name":"FSA_BALANCES_V","schemaName":"SAMQA","sxml":""}