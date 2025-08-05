create or replace force editionable view samqa.hrafsa_employee_payments_v (
    entrp_id,
    transaction_type,
    amount,
    transaction_date,
    reason_name,
    plan_type,
    description,
    creation_date,
    employer_payment_id
) as
    select
        a.entrp_id,
        'PAYMENT'                                                        transaction_type,
        decode(b.reason_type, 'REFUND', a.check_amount, -a.check_amount) amount,
        a.transaction_date,
        case
            when a.transaction_source = 'PENDING_ACH'   then
                'Pending ACH'
            when a.transaction_source = 'PENDING_CHECK' then
                'Pending Check'
            else
                b.reason_name
        end                                                              reason_name,
        a.plan_type,
        decode(b.reason_code, 25, a.note, b.reason_name)                 description,
        a.creation_date,
        a.employer_payment_id
    from
        employer_payments a,
        pay_reason        b,
        account           c
    where
            c.entrp_id = a.entrp_id
        and b.reason_type in ( 'REFUND', 'DISBURSEMENT' )
        and b.reason_code not in ( 23, 13 )
        and c.account_type in ( 'HRA', 'FSA' )
        and c.payroll_integration = 'N'
        and a.reason_code = b.reason_code
    union all
    select
        a.entrp_id,
        'PAYMENT'        transaction_type,
        - a.check_amount amount,
        a.transaction_date,
        b.reason_name,
        a.plan_type,
        b.reason_name    description,
        a.creation_date,
        a.employer_payment_id
    from
        employer_payments         a,
        pay_reason                b,
        ben_plan_enrollment_setup bp,
        account                   acc
    where
        acc.entrp_id is not null
        and acc.entrp_id = a.entrp_id
        and bp.entrp_id = a.entrp_id
        and a.reason_code = 13
        and acc.payroll_integration = 'N'
        and acc.account_type in ( 'HRA', 'FSA' )
        and acc.acc_id = bp.acc_id
        and a.plan_type = bp.plan_type
        and bp.status in ( 'A', 'I' )
        and a.reason_code = b.reason_code
        and a.plan_start_date = bp.plan_start_date
        and a.plan_end_date = bp.plan_end_date
        and bp.claim_reimbursed_by = 'STERLING'
        and a.check_date >= trunc(nvl(bp.reimburse_start_date, bp.plan_start_date))
    union all
    select
        a.entrp_id,
        'PAYMENT'        transaction_type,
        - a.check_amount amount,
        a.transaction_date,
        b.reason_name,
        a.plan_type,
        b.reason_name    description,
        a.creation_date,
        a.employer_payment_id
    from
        employer_payments         a,
        pay_reason                b,
        ben_plan_enrollment_setup bps, --30132
        account                   acc
    where
        acc.entrp_id is not null
        and acc.entrp_id = a.entrp_id
        and bps.entrp_id = a.entrp_id
        and a.reason_code = 13
        and acc.payroll_integration = 'N'
        and acc.account_type in ( 'HRA', 'FSA' )
        and acc.acc_id = bps.acc_id
        and a.plan_type = bps.plan_type
        and bps.status in ( 'A', 'I' )
        and a.reason_code = b.reason_code
        and a.plan_start_date = bps.plan_start_date
        and a.plan_end_date = bps.plan_end_date
        and bps.claim_reimbursed_by = 'EMPLOYER'
        and a.check_date >= bps.plan_start_date
        and a.check_date <= bps.reimburse_start_date
        and exists (
            select
                *
            from
                ben_plan_history bp
            where
                    bp.claim_reimbursed_by = 'STERLING'
                and bps.ben_plan_id = bp.ben_plan_id
        )
/*SELECT A.ENTRP_ID ,
'PAYMENT' transaction_type ,
-A.CHECK_amount amount ,
A.TRANSACTION_DATE ,
B.reason_name ,
A.plan_type ,
B.REASON_NAME DESCRIPTION,
A.CREATION_DATE,
A.EMPLOYER_PAYMENT_ID
FROM EMPLOYER_PAYMENTS A ,
PAY_REASON B ,
BEN_PLAN_HISTORY BP ,BEN_PLAN_ENROLLMENT_SETUP BPS, --30132
ACCOUNT ACC
WHERE  ACC.ENTRP_ID IS NOT NULL
AND ACC.ENTRP_ID = A.ENTRP_ID
AND BP.ENTRP_ID = A.ENTRP_ID
AND A.REASON_CODE = 13
AND ACC.PAYROLL_INTEGRATION='N'
AND ACC.ACCOUNT_TYPE IN ('HRA','FSA')
AND ACC.ACC_ID = BP.ACC_ID
AND A.PLAN_TYPE = BP.PLAN_TYPE
AND BP.STATUS IN ('A','I')
AND A.REASON_CODE = B.REASON_CODE
AND A.PLAN_START_DATE = BP.PLAN_START_DATE
AND A.PLAN_END_DATE = BP.PLAN_END_DATE
AND BP.CLAIM_REIMBURSED_BY = 'STERLING' 
AND BPS.BEN_PLAN_ID = BP.BEN_PLAN_ID
AND BPS.CLAIM_REIMBURSED_BY  = 'EMPLOYER'
AND A.CHECK_DATE BETWEEN BP.PLAN_START_DATE and NVL(BPS.reimburse_start_date,BP.PLAN_START_DATE)*/;


-- sqlcl_snapshot {"hash":"c233a8c222a26f6122c25f5262f5a3aa6459c2bb","type":"VIEW","name":"HRAFSA_EMPLOYEE_PAYMENTS_V","schemaName":"SAMQA","sxml":""}