create or replace force editionable view samqa.fsa_ee_balances_v (
    acc_num,
    account_type,
    balance,
    annual_election,
    plan_type,
    plan_desc,
    start_date,
    plan_start_date,
    plan_end_date,
    status,
    acc_id
) as
    select
        a.acc_num,
        a.account_type,
        pc_account.acc_balance(a.acc_id, b.plan_start_date, b.plan_end_date, a.account_type, b.plan_type) balance,
        b.annual_election,
        b.plan_type,
        b.plan_name                                                                                       plan_desc,
        b.effective_date                                                                                  start_date,
        b.plan_start_date,
        b.plan_end_date,
        b.status,
        a.acc_id
    from
        account         a,
        ben_plans_acc_v b
    where
        a.acc_id = b.acc_id
  --AND NVL(b.effective_end_date,sysdate) >= sysdate;
        ;


-- sqlcl_snapshot {"hash":"009f477a33b230feba2b60df732f64a8b2c2e0d8","type":"VIEW","name":"FSA_EE_BALANCES_V","schemaName":"SAMQA","sxml":""}