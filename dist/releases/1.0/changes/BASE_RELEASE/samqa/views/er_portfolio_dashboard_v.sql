-- liquibase formatted sql
-- changeset SAMQA:1754374173006 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\er_portfolio_dashboard_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/er_portfolio_dashboard_v.sql:null:63bd9056ed45add5f0187e3c3b84e2c3ca6c6473:create

create or replace force editionable view samqa.er_portfolio_dashboard_v (
    no_of_employees,
    coverage_period,
    plan_type,
    plan_name,
    tax_id,
    account_type,
    acc_num
) as
    select
        pc_entrp.count_active_person(b.entrp_id) no_of_employees,
        null                                     coverage_period,
        null                                     plan_type,
        null                                     plan_name,
        replace(b.entrp_code, '-')               tax_id,
        e.account_type,
        e.acc_num                                acc_num
    from
        account    e,
        enterprise b
    where
            e.entrp_id = b.entrp_id
        and ( e.end_date is null
              or e.end_date > sysdate )
        and e.account_type = 'HSA'
    union
    select
        pc_entrp.count_active_person(b.entrp_id) no_of_employees,
        null                                     coverage_period,
        null                                     plan_type,
        null                                     plan_name,
        replace(b.entrp_code, '-')               tax_id,
        e.account_type,
        e.acc_num                                acc_num
    from
        account    e,
        enterprise b
    where
            e.entrp_id = b.entrp_id
        and ( e.end_date is null
              or e.end_date > sysdate )
        and e.account_type = 'COBRA'
        and exists (
            select
                lower(c.ssoidentifier) ssoidentifier,
                d.clientid
            from
                clientcontact c,
                client        d
            where
                    c.clientid = d.clientid
                and c.allowsso = 1
                and b.cobra_id_number = d.clientid
        )
    union
    select
        pc_entrp.count_active_person(b.entrp_id, k.account_type, e.plan_type) no_of_employees,
        to_char(e.plan_start_date, 'MM/DD/YYYY')
        || '-'
        || to_char(e.plan_end_date, 'MM/DD/YYYY')                             coverage_period,
        case
            when e.product_type = 'HRA' then
                'HRA'
            else
                e.plan_type
        end                                                                   plan_type,
        pc_lookups.get_fsa_plan_type(e.plan_type)                             plan_name,
        replace(b.entrp_code, '-'),
        k.account_type,
        k.acc_num                                                             acc_num
    from
        account                   k,
        enterprise                b,
        ben_plan_enrollment_setup e
    where
            k.entrp_id = b.entrp_id
        and k.acc_id = e.acc_id
        and e.status <> 'R'
        and ( k.end_date is null
              or k.end_date > sysdate )
        and e.plan_end_date + nvl(grace_period, 0) + nvl(runout_period_days, 0) >= sysdate
        and k.account_type in ( 'FSA', 'HRA' );

