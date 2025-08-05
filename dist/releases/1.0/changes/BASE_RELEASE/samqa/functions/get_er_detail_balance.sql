-- liquibase formatted sql
-- changeset SAMQA:1754373927557 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_er_detail_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_er_detail_balance.sql:null:748165e45c9c4d052ad9ee4d35a5c69b8fbe1b49:create

create or replace function samqa.get_er_detail_balance (
    p_entrp_id     in number,
    p_product_type in varchar2,
    p_end_date     in date
) return number is
    l_balance number := 0;
    l_ord     number := 0;
begin
    pc_log.log_error('get_er_recon_report', 'P_END_DATE ' || p_end_date);
    pc_log.log_error('get_er_recon_report', 'P_PRODUCT_TYPE ' || p_product_type);
    pc_log.log_error('get_er_recon_report', 'p_entrp_id ' || p_entrp_id);
    for x in (
        select
            transaction_type,
            acc_num,
            claim_invoice_id,
            check_amount,
            note,
            plan_type,
            transaction_date,
            paid_date,
            first_name,
            last_name,
            ord_no,
            reason_code
        from
            (
                select
                    b.fee_name            transaction_type,
                    '-'                   acc_num,
                    to_char(a.invoice_id) claim_invoice_id,
                    check_amount,
                    a.note,
                    a.plan_type,
                    trunc(check_date)     transaction_date,
                    trunc(check_date)     paid_date,
                    ''                    first_name,
                    ''                    last_name,
                    1                     ord_no,
                    a.reason_code
                from
                    employer_deposits a,
                    fee_names         b,
                    account           c
                where
                        a.entrp_id = p_entrp_id
                    and a.reason_code = b.fee_code
                    and a.entrp_id = c.entrp_id
                    and c.account_type in ( 'HRA', 'FSA' )
                    and trunc(check_date) <= nvl(p_end_date, sysdate)
                    and a.reason_code not in ( 5, 11, 12, 15, 8,
                                               17, 18, 40 )
                    and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                union all
                select
                    b.reason_name,
                    '-'              acc_num,
                    to_char(a.check_number),
                    - a.check_amount amount,
                    a.note,
                    a.plan_type,
                    trunc(a.transaction_date),
                    trunc(a.check_date),
                    ''               first_name,
                    ''               last_name,
                    2                ord_no,
                    a.reason_code
                from
                    employer_payments a,
                    pay_reason        b
                where
                        a.entrp_id = p_entrp_id
                    and a.reason_code = b.reason_code
                    and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    and trunc(a.check_date) <= nvl(p_end_date, sysdate)
                    and b.reason_code = 25
                union all
                select
                    case
                        when a.reason_code in ( 11, 12, 13, 19 ) then
                            'Claim Payment'
                        else
                            reason_name
                    end transaction_type,
                    c.acc_num,
                    to_char(a.claim_id),
                    - a.pay_amount,
                    e.reason_name,
                    a.service_type,
                    d.pay_date,
                    d.paid_date,
                    p.first_name,
                    p.last_name,
                    2   ord_no,
                    a.reason_code
                from
                    employer_payment_detail a,
                    claimn                  b,
                    account                 c,
                    payment                 d,
                    pay_reason              e,
                    person                  p
                where
                        a.entrp_id = p_entrp_id
                    and transaction_source = 'CLAIM_PAYMENT'
                    and pc_lookups.get_meaning(a.service_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                    and a.claim_id = b.claim_id
                    and a.change_num = d.change_num
                    and b.pers_id = c.pers_id
                    and c.acc_id = d.acc_id
                    and a.reason_code = e.reason_code
                    and a.reason_code = d.reason_code
                    and a.reason_code <> 13
                    and p.pers_id = b.pers_id
                    and a.status = 'PROCESSED'
                union all
                select
                    case
                        when a.reason_code in ( 11, 12, 13, 19 ) then
                            'Claim Payment'
                        else
                            reason_name
                    end transaction_type,
                    c.acc_num,
                    to_char(a.claim_id),
                    - a.pay_amount,
                    e.reason_name,
                    a.service_type,
                    d.pay_date,
                    d.paid_date,
                    p.first_name,
                    p.last_name,
                    2   ord_no,
                    a.reason_code
                from
                    employer_payment_detail   a,
                    claimn                    b,
                    account                   c,
                    payment                   d,
                    pay_reason                e,
                    person                    p,
                    ben_plan_enrollment_setup bp
                where
                        a.entrp_id = p_entrp_id
                    and transaction_source = 'CLAIM_PAYMENT'
                    and pc_lookups.get_meaning(a.service_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                    and a.claim_id = b.claim_id
                    and a.change_num = d.change_num
                    and b.pers_id = c.pers_id
                    and c.acc_id = d.acc_id
                    and a.reason_code = e.reason_code
                    and a.reason_code = d.reason_code
                    and a.reason_code = 13
                    and p.pers_id = b.pers_id
                    and bp.plan_type = a.service_type
                    and b.plan_end_date = bp.plan_end_date
                    and b.plan_start_date = bp.plan_start_date
                    and bp.acc_id = c.acc_id
                    and bp.claim_reimbursed_by is null
                    and a.status = 'PROCESSED'
                union all
                select
                    case
                        when a.reason_code in ( 11, 12, 13, 19 ) then
                            'Claim Payment'
                        else
                            reason_name
                    end transaction_type,
                    c.acc_num,
                    to_char(a.claim_id),
                    - a.pay_amount,
                    e.reason_name,
                    a.service_type,
                    d.pay_date,
                    d.paid_date,
                    p.first_name,
                    p.last_name,
                    2   ord_no,
                    a.reason_code
                from
                    employer_payment_detail   a,
                    claimn                    b,
                    account                   c,
                    payment                   d,
                    pay_reason                e,
                    person                    p,
                    ben_plan_enrollment_setup bp
                where
                        a.entrp_id = p_entrp_id
                    and transaction_source = 'CLAIM_PAYMENT'
                    and pc_lookups.get_meaning(a.service_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                    and a.claim_id = b.claim_id
                    and a.change_num = d.change_num
                    and b.pers_id = c.pers_id
                    and c.acc_id = d.acc_id
                    and a.reason_code = e.reason_code
                    and a.reason_code = d.reason_code
                    and a.reason_code = 13
                    and p.pers_id = b.pers_id
                    and bp.plan_type = d.plan_type
                    and b.plan_end_date = bp.plan_end_date
                    and b.plan_start_date = bp.plan_start_date
                    and bp.entrp_id = p.entrp_id
                    and bp.claim_reimbursed_by = 'STERLING'
                    and a.paid_date >= nvl(bp.reimburse_start_date, bp.plan_start_date)
                    and a.status = 'PROCESSED'
                union
                select
                    case
                        when a.reason_code in ( 11, 12, 13, 19 ) then
                            'Claim Payment'
                        else
                            reason_name
                    end transaction_type,
                    c.acc_num,
                    to_char(a.claim_id),
                    - a.pay_amount,
                    'Pending ePayment',
                    a.service_type,
                    a.paid_date,
                    a.paid_date,
                    p.first_name,
                    p.last_name,
                    2   ord_no,
                    a.reason_code
                from
                    employer_payment_detail a,
                    claimn                  b,
                    account                 c,
                    pay_reason              e,
                    person                  p
                where
                        a.entrp_id = p_entrp_id
                    and transaction_source = 'PENDING_ACH'
                    and a.status = 'PROCESSED'
                    and a.claim_id = b.claim_id
                    and b.pers_id = c.pers_id
                    and a.reason_code = e.reason_code
                    and p.pers_id = b.pers_id
                    and pc_lookups.get_meaning(b.service_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                union
                select
                    case
                        when a.reason_code in ( 11, 12, 13, 19 ) then
                            'Claim Payment'
                        else
                            reason_name
                    end transaction_type,
                    c.acc_num,
                    to_char(a.claim_id),
                    - a.pay_amount,
                    'Pending Check',
                    a.service_type,
                    a.paid_date,
                    a.paid_date,
                    p.first_name,
                    p.last_name,
                    2   ord_no,
                    a.reason_code
                from
                    employer_payment_detail a,
                    claimn                  b,
                    account                 c,
                    pay_reason              e,
                    person                  p
                where
                        a.entrp_id = p_entrp_id
                    and transaction_source = 'PENDING_CHECK'
                    and a.status = 'PROCESSED'
                    and a.claim_id = b.claim_id
                    and b.pers_id = c.pers_id
                    and a.reason_code = e.reason_code
                    and p.pers_id = b.pers_id
                    and pc_lookups.get_meaning(b.service_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
            )
              /*  SELECT CASE WHEN REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END  transaction_type,
                       A.ACC_NUM,
                       TO_CHAR(A.claim_id),
                      -A.AMOUNT,
                       A.REASON_NAME,
                       A.plan_type,
                       A.TRANSACTION_DATE,
                       A.PAID_DATE,
                       B.FIRST_NAME,
                       B.LAST_NAME,
                       2 ORD_NO
                FROM HRAFSA_CLAIM_DETAIL_V A,PERSON B
                WHERE A.ENTRP_ID = P_ENTRP_ID 
                AND   A.PERS_ID  = B.PERS_ID
                AND   A.PAID_DATE >=  '01-JAN-2004'
                AND   TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE+1)
                AND   PC_LOOKUPS.GET_meaning(A.PLAN_TYPE,'FSA_HRA_PRODUCT_MAP') = P_PRODUCT_TYPE
                AND   NVL(A.TAKEOVER,'N') = 'N'
                UNION ALL
                SELECT 'Claim Payment',PC_PERSON.acc_num(B.PERS_ID) ACC_NUM, TO_CHAR(B.CLAIM_ID) 
                     , -A.TOTAL_AMOUNT , 'Pending ePayment' REASON_NAME
                     , B.SERVICE_TYPE PLAN_TYPE, A.TRANSACTION_DATE,A.TRANSACTION_DATE
                     , C.FIRST_NAME, C.LAST_NAME,
                       2 ORD_NO
                 FROM ACH_TRANSFER A, CLAIMN B,PERSON C
                WHERE  A.CLAIM_ID = B.CLAIM_ID
                AND   B.ENTRP_ID = P_ENTRP_ID
                AND   C.PERS_ID  = b.PERS_ID
                AND   A.STATUS IN (1,2)
                AND   TRUNC(A.TRANSACTION_DATE) <= NVL(P_END_DATE,A.TRANSACTION_DATE)
                AND   PC_LOOKUPS.GET_meaning(B.SERVICE_TYPE ,'FSA_HRA_PRODUCT_MAP') = P_PRODUCT_TYPE
                UNION ALL
                SELECT'Claim Payment',PC_PERSON.acc_num(B.PERS_ID) ACC_NUM, TO_CHAR(B.CLAIM_ID )
                     , -A.CHECK_AMOUNT , 'Pending Check' REASON_NAME
                     , B.SERVICE_TYPE PLAN_TYPE, A.CHECK_DATE,A.CHECK_DATE
                     , C.FIRST_NAME, C.LAST_NAME,
                       2 ORD_NO
                 FROM  CHECKS A, CLAIMN B,PERSON C
                WHERE  A.ENTITY_ID = B.CLAIM_ID 
                AND   A.ENTITY_TYPE= 'CLAIMN'
                AND   B.ENTRP_ID = P_ENTRP_ID                
                AND   B.PERS_ID  = C.PERS_ID
                AND   TRUNC(A.CHECK_DATE) <= NVL(P_END_DATE,A.CHECK_DATE)
                AND   A.STATUS IN ('READY','SENT')
                AND   PC_LOOKUPS.GET_meaning(B.SERVICE_TYPE ,'FSA_HRA_PRODUCT_MAP') = P_PRODUCT_TYPE)*/
        order by
            paid_date asc,
            ord_no asc
    ) loop
        l_balance := l_balance + x.check_amount;
    end loop;

    return l_balance;
end get_er_detail_balance;
/

