create or replace force editionable view samqa.daily_setup_renewal_invoice_v (
    invoice_id,
    acc_num,
    employer_name,
    invoice_date,
    invoice_due_date,
    start_date,
    end_date,
    invoice_amount,
    pending_amount,
    discount_amount,
    invoice_term,
    status,
    auto_pay,
    batch_number,
    product_type,
    plan_type,
    billing_name,
    division_name,
    source,
    error_message
) as
    select
        ar_invoice.invoice_id                                                         as invoice_id,
        acc.acc_num                                                                   as acc_num,
        e.name                                                                        employer_name,
        ar_invoice.invoice_date                                                       as invoice_date,
        ar_invoice.invoice_due_date                                                   as invoice_due_date,
        plan_start_date                                                               as start_date,
        plan_end_date                                                                 as end_date,
        ar_invoice.invoice_amount                                                     as invoice_amount,
        ar_invoice.pending_amount                                                     as pending_amount,
        (
            select
                nvl(
                    sum(arl.total_line_amount),
                    null
                )
            from
                ar_invoice_lines arl
            where
                    arl.invoice_id = ar_invoice.invoice_id
                and rate_code in ( 264, 265, 266 )
                and arl.status not in ( 'CANCELLED', 'DRAFT', 'VOID' )
        )                                                                             as discount_amount,
        ar_invoice.invoice_term                                                       as invoice_term,
        ar_invoice.status                                                             as status,
        ar_invoice.auto_pay                                                           as auto_pay,
        der.batch_number,
        acc.account_type                                                              as product_type,
        null                                                                          as plan_type,
        ar_invoice.billing_name,
        pc_employer_divisions.get_division_name(ar_invoice.division_code, e.entrp_id) division_name,
        der.source,
        case
            when der.error_message is not null then
                der.error_message
            when der.invoice_id is not null
                 or der.invoice_id <> - 1 then
                'invoice generated succesfully'
            when der.invoice_id is null
                 or der.invoice_id = - 1 then
                'invoice did not generate. Please check'
        end                                                                           error_message
    from
        daily_enroll_renewal_account_info der,
        ar_invoice                        ar_invoice,
        account                           acc,
        enterprise                        e
    where
            der.invoice_id = ar_invoice.invoice_id (+)
        and der.entrp_id = acc.entrp_id
        and acc.entrp_id = e.entrp_id
        and der.entrp_id = e.entrp_id
        and der.entrp_id = acc.entrp_id;


-- sqlcl_snapshot {"hash":"9e42abe5a7040cb5f5bbad457b55766fc53f6b98","type":"VIEW","name":"DAILY_SETUP_RENEWAL_INVOICE_V","schemaName":"SAMQA","sxml":""}