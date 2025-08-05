create or replace force editionable view samqa.invoice_payment_analytics_v (
    name,
    acc_num,
    invoice_id,
    invoice_date,
    start_date,
    end_date,
    payment_received_on,
    invoice_amount,
    paid_amount,
    invoice_term,
    payment_method,
    plan_type,
    reason_name,
    check_number,
    check_amount,
    check_date
) as
    select
        pc_entrp.get_entrp_name(d.entrp_id) name,
        a.acc_num,
        a.invoice_id,
        a.invoice_date,
        a.start_date,
        a.end_date,
        b.check_date                        payment_received_on,
        a.invoice_amount - a.void_amount    invoice_amount,
        a.paid_amount,
        a.invoice_term,
        a.payment_method,
        b.plan_type,
        c.reason_name,
        b.check_number,
        b.check_amount,
        to_char(b.check_date, 'MM/DD/YYYY') check_date
    from
        ar_invoice        a,
        employer_payments b,
        pay_reason        c,
        account           d
    where
            a.invoice_id = b.invoice_id
        and a.acc_id = d.acc_id
        and b.reason_code = to_char(c.reason_code)
        and a.status <> 'VOID';


-- sqlcl_snapshot {"hash":"3a272318b07356c57784dbc542704b1922b25c40","type":"VIEW","name":"INVOICE_PAYMENT_ANALYTICS_V","schemaName":"SAMQA","sxml":""}