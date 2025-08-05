-- liquibase formatted sql
-- changeset SAMQA:1754374180017 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ui_invoice_query_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ui_invoice_query_v.sql:null:df31e62de23b51ac2d6f1d207d486cd511b76870:create

create or replace force editionable view samqa.ui_invoice_query_v (
    invoice_number,
    invoice_date,
    invoice_due_date,
    status_code,
    status,
    invoice_posted_date,
    invoice_id,
    entrp_id,
    employer_name,
    acc_id,
    acc_num,
    account_type,
    invoice_term,
    start_date,
    end_date,
    coverage_period,
    comments,
    auto_pay,
    billing_name,
    billing_address,
    billing_city,
    billing_zip,
    billing_state,
    billing_attn,
    payment_method,
    invoice_status,
    invoice_reason,
    division_code,
    refund_amount,
    invoice_amount,
    pending_amount,
    paid_amount,
    void_amount,
    entity_id,
    entity_type,
    plan_type,
    rate_plan_id,
    broker_id,
    ga_id,
    created_by,
    enrolle_type
) as
    select
        ar.invoice_number,
        ar.invoice_date                                         invoice_date,
        to_char(ar.invoice_due_date, 'dd-mon-yyyy')             invoice_due_date,
        case
            when ar.invoice_amount = nvl(ar.refund_amount, 0) then
                'REFUNDED'
            else
                ar.status
        end                                                     status_code,
        decode(ar.status, 'POSTED', 'Paid', 'Outstanding')      status,
        ar.invoice_posted_date,
        ar.invoice_id,
        decode(ar.entity_type, 'EMPLOYER', ar.entity_id)        entrp_id,
        pc_entrp.get_entrp_name(ar.entity_id)                   employer_name,
        ar.acc_id,
        ar.acc_num,
        a.account_type                                          account_type,
        pc_lookups.get_meaning(ar.invoice_term, 'PAYMENT_TERM') invoice_term,
        to_char(ar.start_date, 'dd-mon-yyyy')                   start_date,
        to_char(ar.end_date, 'dd-mon-yyyy')                     end_date,
        to_char(ar.start_date, 'MM/DD/YYYY')
        || '-'
        || to_char(ar.end_date, 'MM/DD/YYYY')                   coverage_period,
        ar.comments,
        ar.auto_pay,
        ar.billing_name,
        ar.billing_address,
        ar.billing_city,
        ar.billing_zip,
        ar.billing_state,
        ar.billing_attn,
        ar.payment_method,
        ar.status                                               invoice_status,
        ar.invoice_reason,
        ar.division_code,
        ar.refund_amount,
        ar.invoice_amount,
        nvl(ar.pending_amount, 0)                               pending_amount,
        nvl(ar.paid_amount, 0)                                  paid_amount,
        nvl(ar.void_amount, 0)                                  void_amount,
        ar.entity_id,
        ar.entity_type,
        ar.plan_type,
        ar.rate_plan_id,
        a.broker_id                                             broker_id,
        a.ga_id                                                 ga_id,
        pc_users.get_user_name(a.created_by)                    created_by,
        nvl(a.enrolle_type, 'EMPLOYER')                         enrolle_type
    from
        ar_invoice ar,
        account    a
    where
            ar.entity_id = a.entrp_id
        and ar.entity_type = 'EMPLOYER'
        and ar.invoice_reason = 'FEE';

