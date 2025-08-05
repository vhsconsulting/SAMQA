-- liquibase formatted sql
-- changeset SAMQA:1754374166995 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\account_opportunity1_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/account_opportunity1_v.sql:null:9ba582c6d08c9627b964e039892c16b6d95c6c54:create

create or replace force editionable view samqa.account_opportunity1_v (
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
    plan_end_date,
    send_plan_docs_to,
    invoice_to,
    plan_doc_sent_to_client,
    crm_id,
    broker_information,
    account_manager,
    service_start_date,
    hra_type
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
            and upper(bb.plan_type) not like '%RENEW%'
            and bb.status = 'A' 
        -- and bb.ben_plan_number is not null
       --AND (GREATEST (TRUNC(ab.Reg_Date),TRUNC(ab.Start_Date)) >= add_months(TRUNC(bb.plan_start_date),-11))
            and ( ( greatest(
                trunc(ab.reg_date),
                trunc(ab.start_date)
            ) >= add_months(
                trunc(bb.plan_start_date),
                -11
            ) )
                  or ab.account_type = 'FORM_5500' )
            and ( ( ab.account_type = 'FORM_5500'
                    and ( upper(bb.plan_type) like '%SNGL%'
                          or upper(bb.plan_type) like '%MER%'
                          or upper(bb.plan_type) like '%MERS%' ) )
                  or ( ab.account_type = 'POP'
                       and ( upper(bb.plan_type) like '%COMP_POP%'
                             or upper(bb.plan_type) like '%BASIC_POP%' ) ) )
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
        --AND (GREATEST (TRUNC(ab.Reg_Date),TRUNC(ab.Start_Date)) >= add_months(TRUNC(bb.plan_start_date),-11))

            and ( greatest(
                trunc(ab.reg_date),
                trunc(ab.start_date)
            ) >= add_months(
                trunc(bb.plan_start_date),
                -11
            )
                  or ( ab.account_type = 'FSA'
                       and bb.product_type = 'HRA'
                       and nvl(bb.renewal_flag, 'N') != 'Y' ) )
            and ( ab.account_type = 'FSA'
                  and bb.product_type in ( 'FSA', 'HRA' )
                  and nvl(bb.renewal_flag, 'N') != 'Y' )
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
        to_char(o.created_date, 'MM/DD/YYYY')                     opp_created_date,
        o.status                                                  opp_status,
        a.plan_type, --20241016 add
        a.ben_plan_number,
        o.expec_closed_date,
        get_user_name_details(upper(get_user_name(o.created_by))) created_by,
        o.ben_plan_id,
        o.submission_date,
        o.dol_due_date,
        o.extension_field,
        o.extended_due_date,
        o.form_5500_field,
        o.plan_start_date,
        o.plan_end_date,
        o.send_plan_docs_to,
        o.invoice_to,
        o.plan_doc_sent_to_client,
        o.crm_id,
        o.broker_information,
        a.account_manager,
        a.service_start_date,
        a.hra_type
    from
        (
            select
                decode(ac.account_type, 'FORM_5500', '5500_POP', 'POP', '5500_POP',
                       'FSA', '5500_POP', 'OTHER_ACC_TYPE')         as account_type_check,
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
                b.ben_plan_number,
                initcap(pc_sales_team.get_sales_rep_name(ac.am_id)) as account_manager,
                to_char(ac.start_date, 'MM/DD/YYYY')                service_start_date,
                ac.hra_type
		--decode(ac.account_type,'FSA',c.plan_type,b.plan_type) plan_type,
		--decode(ac.account_type,'FSA',c.ben_plan_number,b.ben_plan_number) ben_plan_number 
            from
                account ac,
                b
            where
                ac.acc_id = b.acc_id (+)
        )           a
        left join opportunity o on a.acc_id = o.acc_id
                                   and o.opportunity_type = 'New'  --20241218 add
                                   and ( ( account_type_check = '5500_POP'
                                           and nvl(a.ben_plan_number, -1) = nvl(o.plan_number, -1)
                                           and a.plan_type = o.plan_type )
                                         or account_type_check != '5500_POP'
                                         or account_type is null )
    order by
        o.opp_id asc;

