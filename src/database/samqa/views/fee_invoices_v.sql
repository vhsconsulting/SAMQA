create or replace force editionable view samqa.fee_invoices_v (
    invoice_number,
    invoice_date,
    invoice_amount,
    acc_num,
    note,
    entrp_id,
    account_type
) as
    select
        nvl(
            nvl(a.list_bill, a.invoice_id),
            a.employer_payment_id
        )              invoice_number,
        a.check_date   invoice_date,
        a.check_amount invoice_amount,
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
    order by
        check_date desc;


-- sqlcl_snapshot {"hash":"e77c9b02d7e3b2437c29dcd421d11b5ce3451770","type":"VIEW","name":"FEE_INVOICES_V","schemaName":"SAMQA","sxml":""}