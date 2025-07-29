create or replace force editionable view samqa.invoice_detail_report_v (
    invoice_id,
    pers_id,
    pers_name,
    description,
    invoice_reason,
    plan_type,
    reason_desc,
    unit_rate_cost,
    acc_num,
    acc_id,
    rate_code,
    no_of_months,
    division_code,
    rate_amount,
    account_type
) as
    select
        a.invoice_id,
        a.pers_id,
        p.last_name
        || ','
        || p.first_name                                            pers_name,
        c.description,
        invoice_reason,
        a.plans                                                    plan_type,
        pc_lookups.get_meaning(a.invoice_reason, 'INVOICE_REASON') reason_desc,
        c.unit_rate_cost,
        ac.acc_num,
        ac.acc_id,
        a.rate_code,
        count(distinct a.start_date)                               no_of_months,
        p.division_code,
        a.rate_amount,
        a.account_type
    from
        ar_invoice_lines             c,
        invoice_distribution_summary a,
        person                       p,
        pay_reason                   d,
        account                      ac
    where
            c.invoice_line_id = a.invoice_line_id
        and a.invoice_id = c.invoice_id
        and a.pers_id = ac.pers_id
        and a.pers_id = p.pers_id
        and c.status not in ( 'VOID', 'CANCELLED' )   -- Cancelled added by Swamy for Ticket#9946 on 10/06/2021
        and c.invoice_line_type <> 'ACTIVE_ADJUSTMENT'
    -- AND   (D.PLAN_TYPE <> 'HRA' OR D.PLAN_TYPE IS NULL)
    group by
        a.invoice_id,
        a.pers_id,
        c.description,
        p.last_name
        || ','
        || p.first_name,
        a.plans,
        a.rate_code,
        a.invoice_reason,
        c.unit_rate_cost,
        ac.acc_num,
        ac.acc_id,
        p.division_code,
        a.rate_amount,
        a.account_type
    union all
    select
        a.invoice_id,
        a.pers_id,
        p.last_name
        || ','
        || p.first_name                                            pers_name,
        c.description,
        invoice_reason,
        a.plans                                                    plan_type,
        pc_lookups.get_meaning(a.invoice_reason, 'INVOICE_REASON') reason_desc,
        c.unit_rate_cost,
        ac.acc_num,
        ac.acc_id,
        a.rate_code,
        c.no_of_months,
        p.division_code,
        a.rate_amount,
        a.account_type
    from
        ar_invoice_lines             c,
        invoice_distribution_summary a,
        person                       p,
   -- PAY_REASON D ,
        account                      ac
    where
            c.invoice_line_id = a.invoice_line_id
        and a.invoice_id = c.invoice_id
        and a.pers_id = ac.pers_id
        and p.pers_id = ac.pers_id
        and a.pers_id = p.pers_id
        and c.status not in ( 'VOID', 'CANCELLED' )   -- Cancelled added by Swamy for Ticket#9946 on 10/06/2021
        and c.invoice_line_type = 'ACTIVE_ADJUSTMENT'
        and a.invoice_kind = 'ACTIVE_ADJUSTMENT';


-- sqlcl_snapshot {"hash":"0d6812eae96ed8c905b8531ed52635548da7f407","type":"VIEW","name":"INVOICE_DETAIL_REPORT_V","schemaName":"SAMQA","sxml":""}