create or replace force editionable view samqa.fsa_hra_employees_queens_v (
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
    reimbursement_ded,
    creation_date,
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
    rollover
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
        b.rollover
    from
        account                   a,
        ben_plan_enrollment_setup b,
        person                    c
    where
            a.acc_id = b.acc_id
        and c.pers_id = a.pers_id
        and b.status <> 'R'
    union
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
                pc_account.previous_acc_balance(a.acc_id, b.plan_start_date, b.plan_end_date, a.account_type, b.plan_type,
                                                b.effective_date, b.effective_end_date)
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
        b.rollover
    from
        account          a,
        ben_plan_history b,
        person           c
    where
            a.acc_id = b.acc_id
        and c.pers_id = a.pers_id
        and b.status <> 'R'
        and trunc(b.effective_date) < trunc(b.effective_end_date)
        and b.life_event_code in ( 'TERM_PLAN', 'TERM_ONE_PLAN', 'LOA_RETURN', 'LOA_NO_CONTRIBUTION', 'LOA_POST_TAX_CONTRIBUTION' )
        and b.ben_plan_history_id = (
            select
                max(d.ben_plan_history_id)
            from
                ben_plan_history d
            where
                    d.ben_plan_id = b.ben_plan_id
                and d.plan_type = b.plan_type
                and d.life_event_code = b.life_event_code
        )
        and not exists (
            select
                ben_plan_id
            from
                ben_plan_enrollment_setup x
            where
                    x.ben_plan_id = b.ben_plan_id
                and x.life_event_code = b.life_event_code
        );


-- sqlcl_snapshot {"hash":"4b551367082692c0a1bc7d82867cadd30fb5777d","type":"VIEW","name":"FSA_HRA_EMPLOYEES_QUEENS_V","schemaName":"SAMQA","sxml":""}