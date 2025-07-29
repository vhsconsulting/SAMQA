create or replace force editionable view samqa.hrafsa_invoice_payments_v (
    name,
    acc_num,
    start_date,
    end_date,
    status,
    amount,
    fee_type,
    product
) as
    select
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        sum(a.total_line_amount) amount,
        'SETUP'                  fee_type,
        'FSA'                    product
    from
        ar_invoice_lines a,
        pay_reason       b,
        ar_invoice       c,
        enterprise       d
    where
            a.rate_code = b.reason_code
        and b.plan_type <> 'HRA'
        and a.status not in ( 'VOID', 'CANCELLED' )
        and a.invoice_id = c.invoice_id
        and b.reason_type = 'FEE'
        and d.entrp_id = c.entity_id
        and b.reason_code = 44
    group by
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status
    union
    select
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        sum(a.total_line_amount) amount,
        'RENEWAL'                fee_type,
        'FSA'                    product
    from
        ar_invoice_lines a,
        pay_reason       b,
        ar_invoice       c,
        enterprise       d
    where
            a.rate_code = b.reason_code
        and b.plan_type <> 'HRA'
        and a.status not in ( 'VOID', 'CANCELLED' )
        and a.invoice_id = c.invoice_id
        and b.reason_type = 'FEE'
        and d.entrp_id = c.entity_id
        and b.reason_code = 46
    group by
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status
    union
    select
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        sum(a.total_line_amount) amount,
        'MAINTENANCE'            fee_type,
        'FSA'                    product
    from
        ar_invoice_lines a,
        pay_reason       b,
        ar_invoice       c,
        enterprise       d
    where
            a.rate_code = b.reason_code
        and b.plan_type <> 'HRA'
        and a.status not in ( 'VOID', 'CANCELLED' )
        and a.invoice_id = c.invoice_id
        and b.reason_type = 'FEE'
        and d.entrp_id = c.entity_id
        and b.reason_code in ( 31, 32, 33, 35, 36,
                               37, 38, 39, 40, 41,
                               48, 51 )
    group by
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status
    union
    select
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        sum(a.total_line_amount) amount,
        b.reason_name,
        'FSA'                    product
    from
        ar_invoice_lines a,
        pay_reason       b,
        ar_invoice       c,
        enterprise       d
    where
            a.rate_code = b.reason_code
        and b.plan_type <> 'HRA'
        and a.status not in ( 'VOID', 'CANCELLED' )
        and a.invoice_id = c.invoice_id
        and a.rate_code in ( '16', '4', '17' )
        and b.reason_type = 'FEE'
        and d.entrp_id = c.entity_id
    group by
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        b.reason_name
    union
    select
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        sum(a.total_line_amount) amount,
        'SETUP'                  fee_type,
        'HRA'                    product
    from
        ar_invoice_lines a,
        pay_reason       b,
        ar_invoice       c,
        enterprise       d
    where
            a.rate_code = b.reason_code
        and b.plan_type in ( 'HRP', 'HR5', 'ACO', 'HR4', 'HRA' )
        and a.status not in ( 'VOID', 'CANCELLED' )
        and a.invoice_id = c.invoice_id
        and b.reason_type = 'FEE'
        and b.reason_code = 43
        and d.entrp_id = c.entity_id
    group by
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status
    union
    select
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        sum(a.total_line_amount) amount,
        'RENEWAL'                fee_type,
        'HRA'                    product
    from
        ar_invoice_lines a,
        pay_reason       b,
        ar_invoice       c,
        enterprise       d
    where
            a.rate_code = b.reason_code
        and b.plan_type in ( 'HRP', 'HR5', 'ACO', 'HR4', 'HRA' )
        and a.status not in ( 'VOID', 'CANCELLED' )
        and a.invoice_id = c.invoice_id
        and b.reason_type = 'FEE'
        and b.reason_code = 45
        and d.entrp_id = c.entity_id
    group by
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status
    union
    select
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status,
        sum(a.total_line_amount) amount,
        'MAINTENANCE'            fee_type,
        'HRA'                    product
    from
        ar_invoice_lines a,
        pay_reason       b,
        ar_invoice       c,
        enterprise       d
    where
            a.rate_code = b.reason_code
        and b.plan_type in ( 'HRP', 'HR5', 'ACO', 'HR4', 'HRA' )
        and a.status not in ( 'VOID', 'CANCELLED' )
        and a.invoice_id = c.invoice_id
        and b.reason_type = 'FEE'
        and b.reason_code in ( 42, 34, 47, 50 )
        and d.entrp_id = c.entity_id
    group by
        d.name,
        c.acc_num,
        c.start_date,
        c.end_date,
        c.status;


-- sqlcl_snapshot {"hash":"94285b0b77d07e5313396db24fd1ca52582228c8","type":"VIEW","name":"HRAFSA_INVOICE_PAYMENTS_V","schemaName":"SAMQA","sxml":""}