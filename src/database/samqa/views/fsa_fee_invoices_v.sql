create or replace force editionable view samqa.fsa_fee_invoices_v (
    invoice_number,
    invoice_date,
    invoice_amount,
    acc_num,
    note,
    entrp_id,
    account_type
) as
    select
        nvl(a.list_bill, a.employer_payment_id) invoice_number,
        a.check_date                            invoice_date,
        a.check_amount                          invoice_amount,
        b.acc_num,
        a.note,
        a.entrp_id,
        b.account_type
    from
        employer_payments a,
        account           b
    where
            a.reason_code = 2
        and a.entrp_id = b.entrp_id
        and b.account_type = 'FSA'
    order by
        check_date desc;


-- sqlcl_snapshot {"hash":"aeccd9e5c4fd13705624ee7ecf37e65be3dfba34","type":"VIEW","name":"FSA_FEE_INVOICES_V","schemaName":"SAMQA","sxml":""}