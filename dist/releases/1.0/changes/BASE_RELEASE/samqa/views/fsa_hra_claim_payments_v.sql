-- liquibase formatted sql
-- changeset SAMQA:1754374173992 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\fsa_hra_claim_payments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/fsa_hra_claim_payments_v.sql:null:b86652149265770a0ad7473bddd533ec42f9497a:create

create or replace force editionable view samqa.fsa_hra_claim_payments_v (
    acc_id,
    pers_id,
    claim_id,
    claim_code,
    request_date,
    claim_amount,
    claim_type_code,
    claim_type,
    claim_status,
    claim_stat_meaning,
    claim_source,
    vendor_id,
    bank_acct_id,
    claim_paid,
    claim_pending,
    approved_amount,
    denied_amount,
    denied_reason,
    reimbursement_method,
    prov_name,
    acc_num,
    entrp_id,
    approved_date,
    paid_date,
    deductible_amount
) as
    select
        pr.acc_id,
        a.pers_id,
        a.claim_id,
        a.claim_code,
        to_char(a.claim_date_start, 'MM/DD/RRRR')            request_date,
        a.claim_amount,
        b.lookup_code                                        claim_type_code,
        b.meaning                                            claim_type,
        a.claim_status,
        pc_lookups.get_claim_status(a.claim_status)          claim_stat_meaning,
    -- PC_LOOKUPS.GET_CLAIM_STATUS(A.CLAIM_STATUS) CLAIM_STAT_MEANING ,
        case
            when pr.claim_type in ( 'SUBSCRIBER', 'PROVIDER' ) then
                'In office'
            else
                'Online'
        end                                                  claim_source,
        pr.vendor_id,
        pr.bank_acct_id,
        nvl(c.amount, 0)                                     claim_paid,
        nvl(a.claim_pending, 0)                              claim_pending,
        nvl(a.approved_amount, 0)                            approved_amount,
        nvl(a.denied_amount, 0)                              denied_amount,
        case
            when a.source_claim_id is not null then
                pc_lookups.get_denied_reason(a.denied_reason)
                || '# '
                || a.source_claim_id
            else
                pc_lookups.get_denied_reason(a.denied_reason)
        end                                                  denied_reason,
        decode(pr.pay_reason, 19, 'Direct Deposit', 'Check') reimbursement_method,
        a.prov_name,
        nvl(pr.acc_num,(
            select
                acc_num
            from
                account
            where
                pers_id = a.pers_id
        ))                                                   acc_num, -------Nvl Added By Rprabu 28/04/2020 For Ticket# 9014.
        a.entrp_id,
        a.approved_date,
        to_char(c.paid_date, 'MM/DD/YYYY')                   paid_date,
        a.deductible_amount   --Ticket#2459
    from
        payment_register  pr,
        claimn            a,
        fsa_hra_plan_type b,
        payment           c
    where
            a.service_type = b.lookup_code
        and pr.claim_id (+) = a.claim_id ---   + added by rprabu for Ticket#4649 on 18/06/2019
        and c.claimn_id (+) = a.claim_id
        and a.claim_status <> 'ERROR';

