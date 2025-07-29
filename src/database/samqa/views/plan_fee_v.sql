create or replace force editionable view samqa.plan_fee_v (
    plan_code,
    plan_name,
    plan_sign,
    fsetup,
    fmonth,
    custom_plan,
    show_online_flag,
    annual_flag
) as
    select
        pln.plan_code                 plan_code,
        pln.plan_name                 plan_name,
        pln.plan_sign                 plan_sign,
        pc_plan.fsetup(pln.plan_code) fsetup,
        case
            when annual_flag = 'N' then
                pc_plan.fmonth(pln.plan_code)
            else
                pc_plan.fannual(pln.plan_code)
        end                           fmonth,
        custom_plan,
        show_online_flag,
        annual_flag
    from
        plans pln
    where
        account_type in ( 'HSA', 'LSA' );


-- sqlcl_snapshot {"hash":"5509713b090dc00f8217da218300141b21921950","type":"VIEW","name":"PLAN_FEE_V","schemaName":"SAMQA","sxml":""}