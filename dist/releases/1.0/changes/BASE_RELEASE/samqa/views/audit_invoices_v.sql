-- liquibase formatted sql
-- changeset SAMQA:1754374168328 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\audit_invoices_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/audit_invoices_v.sql:null:866ce360b2c94f2606642786e76b1fef26fecdd7:create

create or replace force editionable view samqa.audit_invoices_v (
    invoice_id,
    billing_date,
    status,
    plan_type,
    total_invoice_amount,
    invoice_amount,
    reason_code,
    posted_amount,
    running_total
) as
    select
        invoice_id,
        billing_date,
        status,
        plan_type,
        total_invoice_amount,
        invoice_amount,
        reason_code,
        posted_amount,
        running_total
    from
        (
            select
                invoice_id,
                entrp_id,
                plan_type,
                invoice_amount,
                total_invoice_amount,
                reason_code,
                start_date,
                end_date,
                status,
                billing_date,
                (
                    select
                        sum(check_amount)
                    from
                        employer_payments ep
                    where
                            x.reason_code = ep.reason_code
                        and x.invoice_id = ep.invoice_id
                        and ( ( x.plan_type = ep.plan_type )
                              or ( ep.plan_type is null
                                   and x.plan_type is null ) )
                ) posted_amount,
                sum(invoice_amount)
                over(partition by invoice_id
                     order by
                         reason_code, plan_type
                ) running_total
            from
                (
                    select
                        ar.invoice_id,
                        ar.entity_id                               entrp_id,
                        billing_date,
                        pr.product_type                            plan_type,
                        ar.invoice_amount - nvl(ar.void_amount, 0) total_invoice_amount,
                        sum(arl.total_line_amount)                 invoice_amount,
                        pr.reason_mapping                          reason_code,
                        ar.start_date,
                        ar.end_date,
                        ar.status
                    from
                        ar_invoice         ar,
                        ar_invoice_lines   arl,
                        invoice_parameters a,
                        pay_reason         pr
                    where
                            ar.invoice_id = arl.invoice_id
                        and a.entity_id = ar.entity_id
                        and arl.rate_code = to_char(pr.reason_code)
                        and ar.entity_type = 'EMPLOYER'
                        and arl.status not in ( 'VOID' )
                        and a.invoice_type = ar.invoice_reason
                        and ar.status <> 'VOID'
                    group by
                        ar.invoice_id,
                        ar.entity_id,
                        pr.product_type,
                        pr.reason_mapping,
                        ar.start_date,
                        ar.end_date,
                        ar.invoice_amount,
                        nvl(ar.void_amount, 0),
                        ar.status,
                        billing_date
                    order by
                        pr.reason_mapping
                ) x
        )
    where
            invoice_amount <> posted_amount
        and total_invoice_amount <> 50
    order by
        invoice_id;

