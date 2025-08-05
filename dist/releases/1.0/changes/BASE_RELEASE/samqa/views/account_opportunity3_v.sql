-- liquibase formatted sql
-- changeset SAMQA:1754374167076 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\account_opportunity3_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/account_opportunity3_v.sql:null:6f8508ab4d81c71187e49b265daff1d51de99980:create

create or replace force editionable view samqa.account_opportunity3_v (
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
    plan_name,
    plan_number,
    closed_date,
    opp_created_date,
    opp_status,
    plan_type,
    ben_plan_number,
    expec_closed_date,
    created_by,
    ben_plan_id,
    submission_date,
    dol_due_date,
    extension_field,
    extended_due_date,
    form_5500_field,
    plan_start_date,
    plan_end_date
) as
    with b as (
        select distinct
            ab.acc_id,
            ab.account_type,
            bb.plan_type,
            bb.ben_plan_number
        from
            ben_plan_enrollment_setup bb,
            account                   ab
        where
                bb.acc_id = ab.acc_id 
			--AND upper(bb.plan_type) NOT LIKE '%RENEW%' 
			--AND bb.status = 'A' 
            -- and bb.ben_plan_number is not null
			--AND (GREATEST (TRUNC(ab.Reg_Date),TRUNC(ab.Start_Date)) >= add_months(TRUNC(bb.plan_start_date),-11))
			--AND 
			--	((ab.account_type='FORM_5500' AND (upper(bb.plan_type) LIKE '%SNGL_RENEW%' OR upper(bb.plan_type) LIKE '%MER_RENEW%' OR upper(bb.plan_type) LIKE '%MERS_RENEW%')))
            and ab.account_type = 'FORM_5500'
            and trunc(bb.plan_end_date) <= trunc(add_months(sysdate, -12))
            and ab.end_date is null
            and ab.account_status = 1
        union
        select distinct
            ab.acc_id,
            ab.account_type,
            bb.product_type as plan_type,
            bb.ben_plan_number
        from
            ben_plan_enrollment_setup bb,
            account                   ab
        where
                bb.acc_id = ab.acc_id 
			--AND upper(bb.plan_type) NOT LIKE '%RENEW%' 
            and bb.status = 'A' 
            -- and bb.ben_plan_number is not null
            and ( greatest(
                trunc(ab.reg_date),
                trunc(ab.start_date)
            ) >= add_months(
                trunc(bb.plan_start_date),
                -11
            ) )
            and ( greatest(
                trunc(ab.reg_date),
                trunc(ab.start_date)
            ) >= add_months(
                trunc(bb.plan_start_date),
                -11
            )
                  or ( ab.account_type = 'FSA'
                       and bb.product_type = 'HRA'
                       and nvl(bb.renewal_flag, 'N') = 'Y' ) )
            and ( ab.account_type = 'FSA'
                  and bb.product_type in ( 'FSA', 'HRA' )
                  and nvl(bb.renewal_flag, 'N') = 'Y' )
    )
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
        o.plan_name,--20241112 add
        o.plan_number,
        o.closed_date,
        o.created_date opp_created_date,
        o.status       opp_status,
        a.plan_type, --20241016 add
        a.ben_plan_number,
        o.expec_closed_date,
        o.created_by,
        o.ben_plan_id,
        o.submission_date,
        o.dol_due_date,
        o.extension_field,
        o.extended_due_date,
        o.form_5500_field,
        o.plan_start_date,
        o.plan_end_date
    from
        (
            select
                decode(ac.account_type, 'FORM_5500', '5500_POP', 'FSA', '5500_POP',
                       'OTHER_ACC_TYPE') as account_type_check,
                ac.account_type,
                ac.entrp_id,
                ac.acc_id,
                ac.acc_num,
                ac.account_status,
                ac.plan_code,
                ac.verified_date,
                ac.verified_sales_date,
                ac.salesrep_id,
                b.plan_type,
                b.ben_plan_number
		--decode(ac.account_type,'FSA',c.plan_type,b.plan_type) plan_type,
		--decode(ac.account_type,'FSA',c.ben_plan_number,b.ben_plan_number) ben_plan_number 
            from
                account ac,
                b
            where
                ac.acc_id = b.acc_id (+)
        )           a
        left join opportunity o on a.acc_id = o.acc_id
                                   and ( ( account_type_check = '5500_POP'
                                           and nvl(a.ben_plan_number, -1) = nvl(o.plan_number, -1)
                                           and nvl(a.plan_type, '-1') = nvl(o.plan_type, '-1') )
                                         or account_type_check != '5500_POP'
                                         or account_type is null )
                                   and o.opportunity_type = 'Renewal'
    order by
        o.opp_id asc;

