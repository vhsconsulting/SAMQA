-- liquibase formatted sql
-- changeset SAMQA:1754374175627 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\hrafsa_claim_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/hrafsa_claim_detail_v.sql:null:cdd958fbd8134c5c6eaa4cd87a660c15f81fda4a:create

create or replace force editionable view samqa.hrafsa_claim_detail_v (
    acc_num,
    claim_id,
    amount,
    transaction_date,
    reason_name,
    plan_type,
    paid_date,
    entrp_id,
    reason_code,
    takeover,
    pers_id
) as
    select
        acc.acc_num,
        p.claim_id,
        c.amount           amount,
        trunc(c.pay_date)  transaction_date,
        pr.reason_name,
        c.plan_type,
        trunc(c.paid_date) paid_date,
        p.entrp_id,
        c.reason_code,
        p.takeover,
        p.pers_id
    from
        account    acc,
        claimn     p,
        payment    c,
        pay_reason pr
    where
        acc.account_type in ( 'HRA', 'FSA' )
        and acc.pers_id = p.pers_id
        and p.claim_id = c.claimn_id
        and pr.reason_type = 'DISBURSEMENT'
        and c.reason_code <> 13
        and p.service_type = c.plan_type
        and c.acc_id = acc.acc_id
        and pr.reason_code = c.reason_code
    union all
    select
        acc.acc_num,
        p.claim_id,
        c.amount           amount,
        trunc(c.pay_date)  transaction_date,
        pr.reason_name,
        c.plan_type,
        trunc(c.paid_date) paid_date,
        p.entrp_id,
        c.reason_code,
        p.takeover,
        p.pers_id
    from
        account                   acc,
        claimn                    p,
        payment                   c,
        pay_reason                pr,
        ben_plan_enrollment_setup bp
    where
        acc.account_type in ( 'HRA', 'FSA' )
        and acc.pers_id = p.pers_id
        and p.claim_id = c.claimn_id
        and c.reason_code = 13
        and bp.status in ( 'A', 'I' )
        and bp.entrp_id = p.entrp_id
        and c.acc_id = acc.acc_id
        and p.service_type = c.plan_type
        and bp.plan_type = c.plan_type
        and p.plan_end_date = bp.plan_end_date
        and p.plan_start_date = bp.plan_start_date
        and pr.reason_code = c.reason_code
        and bp.claim_reimbursed_by is null
    union all
    select
        acc.acc_num,
        p.claim_id,
        c.amount           amount,
        trunc(c.pay_date)  transaction_date,
        pr.reason_name,
        c.plan_type,
        trunc(c.paid_date) paid_date,
        p.entrp_id,
        c.reason_code,
        p.takeover,
        p.pers_id
    from
        account                   acc,
        claimn                    p,
        payment                   c,
        pay_reason                pr,
        ben_plan_enrollment_setup bp
    where
        acc.account_type in ( 'HRA', 'FSA' )
        and c.reason_code = 13
        and bp.claim_reimbursed_by = 'STERLING'
        and bp.status in ( 'A', 'I' )
        and acc.pers_id = p.pers_id
        and p.claim_id = c.claimn_id
        and bp.entrp_id = p.entrp_id
        and c.acc_id = acc.acc_id
        and p.service_type = c.plan_type
        and bp.plan_type = c.plan_type
        and c.pay_date >= nvl(bp.reimburse_start_date, bp.plan_start_date)
        and p.plan_end_date = bp.plan_end_date
        and p.plan_start_date = bp.plan_start_date
        and pr.reason_code = c.reason_code;

