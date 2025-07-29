create or replace force editionable view samqa.fsa_employees_v (
    acc_num,
    name,
    start_date,
    annual_election,
    end_date,
    acc_balance,
    plan_type,
    plan_start_date,
    entrp_id,
    er_acc_num
) as
    select
        a.acc_num,
        pc_person.get_person_name(a.pers_id)                              name,
        b.plan_start_date                                                 start_date,
        b.annual_election,
        a.end_date,
        sum(
            case
                when b.plan_start_date > sysdate then
                    0
                else
                    pc_account.acc_balance(a.acc_id, b.plan_start_date, b.plan_end_date, a.account_type, b.plan_type)
            end
        )                                                                 acc_balance,
        b.plan_type,
        b.plan_start_date,
        pc_person.get_entrp_from_pers_id(a.pers_id)                       entrp_id,
        pc_entrp.get_acc_num(pc_person.get_entrp_from_pers_id(a.pers_id)) er_acc_num
    from
        account                   a,
        ben_plan_enrollment_setup b
    where
            a.acc_id = b.acc_id
        and a.account_type = 'FSA'
        and status <> 'R'
    group by
        a.acc_num,
        pc_person.get_person_name(a.pers_id),
 --   a.START_DATE,
        b.annual_election,
        a.end_date,
        b.plan_type,
        b.plan_start_date,
        pc_person.get_entrp_from_pers_id(a.pers_id),
        pc_entrp.get_acc_num(pc_person.get_entrp_from_pers_id(a.pers_id));


-- sqlcl_snapshot {"hash":"208315f23122d39bec144e4c9f6e0039e9ba160e","type":"VIEW","name":"FSA_EMPLOYEES_V","schemaName":"SAMQA","sxml":""}