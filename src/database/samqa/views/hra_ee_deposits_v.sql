create or replace force editionable view samqa.hra_ee_deposits_v (
    fee_date,
    acc_num,
    name,
    entrp_id,
    account_type,
    status,
    plan_type,
    list_bill,
    fee_code,
    er_amount,
    ee_amount,
    plan_start_date,
    plan_end_date,
    ben_plan_name
) as
    select
        fee_date,
        b.acc_num,
        pc_person.get_person_name(b.pers_id)        name,
        pc_person.get_entrp_from_pers_id(b.pers_id) entrp_id,
        b.account_type,
        c.status,
        a.plan_type,
        a.list_bill,
        a.fee_code,
        nvl(a.amount, 0)                            er_amount,
        nvl(a.amount_add, 0)                        ee_amount,
        c.plan_start_date,
        c.plan_end_date,
        c.ben_plan_name
    from
        income                    a,
        account                   b,
        ben_plan_enrollment_setup c
    where
            a.acc_id = b.acc_id
        and b.account_type = 'HRA'
        and c.status in ( 'A', 'I' )
        and c.acc_id = b.acc_id
        and a.plan_type = c.plan_type
        and nvl(a.fee_code, -1) <> 12;


-- sqlcl_snapshot {"hash":"9fb33fb130cbce57d20f4997d7f633954c266c4b","type":"VIEW","name":"HRA_EE_DEPOSITS_V","schemaName":"SAMQA","sxml":""}