create or replace force editionable view samqa.fsa_hra_employees_v (
    acc_num,
    name,
    first_name,
    last_name,
    start_date,
    annual_election,
    end_date,
    acc_balance,
    plan_type,
    plan_start_date,
    plan_end_date,
    benefit_year,
    entrp_id,
    er_acc_num,
    account_type,
    acc_id,
    ben_plan_id_main,
    pers_id,
    plan_type_meaning,
    deductible,
    enrolled_date,
    division_code,
    division_name,
    termination_req_date,
    termination_date,
    ben_plan_id,
    runout_period_days,
    grace_period,
    sf_ordinance_flag,
    orig_sys_vendor_ref,
    ssn,
    status,
    product_type,
    rollover,
    show_account_online
) as
    select
        a.acc_num,
        c.first_name
        || ' '
        || c.last_name                            name,
        c.first_name,
        c.last_name,
        b.effective_date                          start_date,
        b.annual_election,
        b.effective_end_date                      end_date,
    -- SUM(
        case
            when b.plan_start_date > sysdate then
                0
            else
                pc_account.new_acc_balance(a.acc_id, b.plan_start_date, b.plan_end_date, a.account_type, b.plan_type)
        end                                       acc_balance,
        b.plan_type,
        b.plan_start_date,
        b.plan_end_date,
        to_char(b.plan_start_date, 'MM/DD/YYYY')
        || '-'
        || to_char(b.plan_end_date, 'MM/DD/YYYY') benefit_year,
        c.entrp_id,
        pc_entrp.get_acc_num(c.entrp_id)          er_acc_num,
        a.account_type,
        a.acc_id,
        b.ben_plan_id_main,
        a.pers_id,
        case
            when b.product_type = 'HRA' then
                'Health Reimbursement'
            else
                pc_lookups.get_fsa_plan_type(b.plan_type)
        end                                       plan_type_meaning,
        b.reimbursement_ded,
        b.creation_date,
        pc_person.get_division_code(a.pers_id)    division_code,
        pc_person.get_division_name(a.pers_id)    division_name,
        b.termination_req_date,
        b.effective_end_date                      termination_date,
        b.ben_plan_id,
        b.runout_period_days,
        b.grace_period,
        b.sf_ordinance_flag,
        c.orig_sys_vendor_ref,
        c.ssn,
        b.status,
        b.product_type,
        b.rollover,
        a.show_account_online  -- Added by Swamy for Prod Issue.14-mar-23
    from
        account                   a,
        ben_plan_enrollment_setup b,
        person                    c
    where
        a.account_type in ( 'HRA', 'FSA' )
        and a.acc_id = b.acc_id
        and c.pers_id = a.pers_id
        and b.status <> 'R';


-- sqlcl_snapshot {"hash":"83b6b41e179745befe8e453c90401f2794192bf5","type":"VIEW","name":"FSA_HRA_EMPLOYEES_V","schemaName":"SAMQA","sxml":""}