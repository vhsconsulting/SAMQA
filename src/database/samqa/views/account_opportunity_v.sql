create or replace force editionable view samqa.account_opportunity_v (
    account_type,
    entrp_id,
    acc_id,
    acc_num,
    account_status,
    plan_code,
    verified_date,
    verified_sales_date,
    salesrep_id,
    opp_id,
    implementation_stage_cde,
    assigned_dept,
    assigned_emp_id,
    email_pref,
    opportunity_type,
    current_plan_year,
    plan_start_date,
    plan_end_date,
    plan_name,
    plan_number,
    closed_date,
    opp_created_date,
    opp_status,
    plan_type,
    ben_plan_id,
    created_by,
    expec_closed_date,
    service_start_date
) as
    select
        a.account_type,
        a.entrp_id,
        a.acc_id,
        a.acc_num,
        a.account_status,
        a.plan_code,
        a.verified_date,
        a.verified_sales_date,
        a.salesrep_id,
        o.opp_id,
        o.implementation_stage_cde,
        o.assigned_dept,
        o.assigned_emp_id,
        o.email_pref,
        o.opportunity_type,
        o.current_plan_year,
        o.plan_start_date,
        o.plan_end_date,
        o.plan_name,--20241112 add
        o.plan_number,
        o.closed_date,
        o.created_date                      as opp_created_date,
        o.status                            as opp_status,
        o.plan_type,
        o.ben_plan_id,
        o.created_by,
        o.expec_closed_date,
        to_char(a.start_date, 'MM/DD/YYYY') service_start_date
    from
        account     a,
        opportunity o
    where
        a.acc_id = o.acc_id (+);


-- sqlcl_snapshot {"hash":"713a3ce182976fa48caa76cc853352cc08e80ed6","type":"VIEW","name":"ACCOUNT_OPPORTUNITY_V","schemaName":"SAMQA","sxml":""}