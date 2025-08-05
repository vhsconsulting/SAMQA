-- liquibase formatted sql
-- changeset SAMQA:1754373934270 stripComments:false logicalFilePath:BASE_RELEASE\samqa\materialized_views\broker_account_nohsa_rnw_rev_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/materialized_views/broker_account_nohsa_rnw_rev_mv.sql:null:e249ed7eec2ee870fb13c51c29b1dd1057940bb4:create

create materialized view samqa.broker_account_nohsa_rnw_rev_mv (
    revenue_amount,
    account_type,
    broker_id,
    pay_approved_date,
    start_date,
    salesrep_id,
    broker,
    city,
    state,
    zip,
    salesrep_name
) build immediate using index
    refresh force
    on demand
    using enforced constraints
    disable on query computation
    disable query rewrite
as
    select
        b.total_line_amount as revenue_amount,
        d.account_type,
        d.broker_id,
        a.approved_date     pay_approved_date,
        a.start_date,
        br.salesrep_id,
        replace(
            trim(p.first_name
                 || ' '
                 || p.last_name),
            '  ',
            ' '
        )                   as broker,
        p.city,
        p.state,
        p.zip,
        s.name              as salesrep_name
           --, pc_sales_team.get_sales_rep_name(br.salesrep_id) "SALES"
    from
        ar_invoice       a,
        ar_invoice_lines b,
        pay_reason       c,
        account          d,
        person           p,
        broker           br,
        salesrep         s
    where
            a.invoice_id = b.invoice_id
        and d.broker_id = br.broker_id
            --AND (br.broker_id = :p90_broker OR :p90_broker IS NULL )
        and br.broker_id = p.pers_id
           /* AND (( trunc(a.approved_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'
            ))
                    AND trunc(a.start_date) <= trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY')) )
                  OR ( trunc(a.start_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'
                  ))
                       AND trunc(a.approved_date) < trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) ) ) */
        and a.acc_id = d.acc_id
        and d.account_type in ( 'FSA', 'HRA' )
        and a.invoice_reason = 'FEE'
        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
        and b.rate_code = to_char(c.reason_code)
        and c.reason_code in ( 30, 45, 46 )
        and br.salesrep_id = s.salesrep_id (+)
    union all
    select
        b.total_line_amount as revenue_amount,
        d.account_type,
        d.broker_id,
        a.approved_date     pay_approved_date,
        a.start_date,
        br.salesrep_id,
        replace(
            trim(p.first_name
                 || ' '
                 || p.last_name),
            '  ',
            ' '
        )                   as broker,
        p.city,
        p.state,
        p.zip,
        s.name              as salesrep_name
            --, pc_sales_team.get_sales_rep_name(br.salesrep_id) "SALES"
    from
        ar_invoice       a,
        ar_invoice_lines b,
        pay_reason       c,
        account          d,
        person           p,
        broker           br,
        salesrep         s
    where
            a.invoice_id = b.invoice_id
            /*AND ( ( trunc(a.approved_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'
            ))
                    AND trunc(a.start_date) <= trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY')) )
                  OR ( trunc(a.start_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'
                  ))
                       AND trunc(a.approved_date) < trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) ) ) */
        and a.acc_id = d.acc_id
        and d.broker_id = br.broker_id
            --AND ( br.broker_id = :p90_broker OR :p90_broker IS NULL )
        and br.broker_id = p.pers_id
        and d.account_type in ( 'FSA', 'HRA', 'COBRA' )
        and a.invoice_reason = 'FEE'
        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
        and b.rate_code = to_char(c.reason_code)
        and greatest(
            trunc(d.reg_date),
            trunc(d.start_date)
        ) < add_months(a.start_date, -12)
        and c.reason_code in ( 2, 35, 31, 33, 67,
                               34, 68, 36, 39, 38,
                               37, 32, 40, 54, 55,
                               86 )
        and br.salesrep_id = s.salesrep_id (+)
    union all
    select
        b.total_line_amount as revenue_amount,
        d.account_type,
        d.broker_id,
        a.approved_date     pay_approved_date,
        a.start_date,
        br.salesrep_id,
        replace(
            trim(p.first_name
                 || ' '
                 || p.last_name),
            '  ',
            ' '
        )                   as broker,
        p.city,
        p.state,
        p.zip,
        s.name              as salesrep_name            
            --,pc_sales_team.get_sales_rep_name(br.salesrep_id) "SALES"
    from
        ar_invoice       a,
        ar_invoice_lines b,
        pay_reason       c,
        account          d,
        person           p,
        broker           br,
        salesrep         s
    where
            a.invoice_id = b.invoice_id
        and d.broker_id = br.broker_id
            -- AND ( br.broker_id = :p90_broker OR :p90_broker IS NULL )
        and br.broker_id = p.pers_id
            /*AND ( ( trunc(a.approved_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'
            ))
                    AND trunc(a.start_date) <= trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY')) )
                  OR ( trunc(a.start_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'
                  ))
                       AND trunc(a.approved_date) < trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) ) ) */
        and a.acc_id = d.acc_id
        and d.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                'ACA' )
        and a.invoice_reason = 'FEE'
        and ( a.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
              and b.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
        and b.rate_code = to_char(c.reason_code)
        and c.reason_code in ( 30, 45, 46, 182 )
        and br.salesrep_id = s.salesrep_id (+);

