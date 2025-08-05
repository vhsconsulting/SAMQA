-- liquibase formatted sql
-- changeset SAMQA:1754374145923 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\run_er_recon_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/run_er_recon_report.sql:null:2d6f1143116e7cf247a8ca4b353dfd1d27c730fb:create

create or replace procedure samqa.run_er_recon_report (
    p_entrp_id     in number,
    p_product_type in varchar2,
    p_end_date     in date
) is
    l_balance number := 0;
    l_ord     number := 0;
begin
    pc_log.log_error('get_er_recon_report', 'P_END_DATE ' || p_end_date);
    pc_log.log_error('get_er_recon_report', 'P_PRODUCT_TYPE ' || p_product_type);
    pc_log.log_error('get_er_recon_report', 'p_entrp_id ' || p_entrp_id);
    execute immediate 'truncate table fsahra_er_balance_temp';
    insert into fsahra_er_balance_temp
        select
            transaction_type,
            acc_num,
            claim_invoice_id,
            check_amount,
            plan_type,
            reason_code,
            note,
            transaction_date,
            paid_date,
            first_name,
            last_name,
            ord_no,
            employer_payment_id
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
                    a.reason_code,
                    a.employer_deposit_id employer_payment_id
                from
                    employer_deposits a,
                    fee_names         b,
                    account           c
                where
                        a.entrp_id = p_entrp_id
                    and trunc(check_date) <= nvl(p_end_date, sysdate)
                    and a.entrp_id = c.entrp_id
                    and a.reason_code not in ( 5, 11, 12, 15, 8,
                                               17, 18, 40 )
                    and c.account_type in ( 'HRA', 'FSA' )
                    and a.reason_code = b.fee_code
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
                    a.reason_code,
                    a.employer_payment_id
                from
                    employer_payments a,
                    pay_reason        b
                where
                        a.entrp_id = p_entrp_id
                    and a.reason_code = b.reason_code
                    and pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = p_product_type
                    and trunc(a.check_date) <= nvl(p_end_date, sysdate)
                    and b.reason_code in ( 90, 25 )
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
                    a.paid_date,
                    p.first_name,
                    p.last_name,
                    2   ord_no,
                    a.reason_code,
                    a.employer_payment_id
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
                    and a.product_type = p_product_type
                    and a.reason_code <> 13
                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                    and a.claim_id = b.claim_id
                    and b.claim_id = d.claimn_id
                    and a.change_num = d.change_num
                    and c.acc_id = d.acc_id
                    and p.pers_id = b.pers_id
                    and b.pers_id = c.pers_id
                    and a.reason_code = e.reason_code
                    and a.reason_code = d.reason_code
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
                    case
                        when transaction_source = 'PENDING_CHECK' then
                            'Pending Check'
                        else
                            'Pending ePayment'
                    end,
                    a.service_type,
                    a.paid_date,
                    a.paid_date,
                    p.first_name,
                    p.last_name,
                    2   ord_no,
                    a.reason_code,
                    a.employer_payment_id
                from
                    employer_payment_detail a,
                    claimn                  b,
                    account                 c,
                    pay_reason              e,
                    person                  p
                where
                        a.entrp_id = p_entrp_id
                    and transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH' )
                    and a.product_type = p_product_type
                    and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                    and a.status = 'PROCESSED'
                    and a.claim_id = b.claim_id
                    and p.pers_id = b.pers_id
                    and b.pers_id = c.pers_id
                    and a.reason_code = e.reason_code
            );

    for x in (
        select
            claim_reimbursed_by,
            plan_end_date,
            plan_start_date,
            reimburse_start_date,
            plan_type,
            ben_plan_id
        from
            ben_plan_enrollment_setup
        where
                entrp_id = p_entrp_id
            and product_type = p_product_type
    ) loop
        if x.claim_reimbursed_by is null then
            insert into fsahra_er_balance_gtt
                select
                    transaction_type,
                    acc_num,
                    claim_invoice_id,
                    check_amount,
                    plan_type,
                    reason_code,
                    note,
                    transaction_date,
                    paid_date,
                    first_name,
                    last_name,
                    ord_no,
                    employer_payment_id
                from
                    (
                        select
                            case
                                when a.reason_code in ( 11, 12, 13, 19 ) then
                                    'Claim Payment'
                                else
                                    reason_name
                            end                 transaction_type,
                            c.acc_num,
                            to_char(a.claim_id) claim_invoice_id,
                            - a.pay_amount      check_amount,
                            e.reason_name       note,
                            a.service_type      plan_type,
                            d.pay_date          transaction_date,
                            a.paid_date,
                            p.first_name,
                            p.last_name,
                            2                   ord_no,
                            a.reason_code,
                            a.employer_payment_id
                        from
                            employer_payment_detail a,
                            claimn                  b,
                            account                 c,
                            payment                 d,
                            pay_reason              e,
                            person                  p
                        where
                                a.entrp_id = p_entrp_id
                            and a.reason_code = 13
                            and transaction_source = 'CLAIM_PAYMENT'
                            and a.status = 'PROCESSED'
                            and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                            and a.product_type = p_product_type
                            and d.reason_code = 13
                            and a.claim_id = b.claim_id
                            and a.claim_id = d.claimn_id
                            and a.change_num = d.change_num
                            and b.pers_id = c.pers_id
                            and c.acc_id = d.acc_id
                            and c.pers_id = p.pers_id
                            and a.reason_code = e.reason_code
                            and a.service_type = x.plan_type
                            and b.plan_end_date = x.plan_end_date
                            and b.plan_start_date = x.plan_start_date
                    );

        end if;

        if x.claim_reimbursed_by = 'STERLING' then
            insert into fsahra_er_balance_gtt
                select
                    transaction_type,
                    acc_num,
                    claim_invoice_id,
                    check_amount,
                    plan_type,
                    reason_code,
                    note,
                    transaction_date,
                    paid_date,
                    first_name,
                    last_name,
                    ord_no,
                    employer_payment_id
                from
                    (
                        select
                            case
                                when a.reason_code in ( 11, 12, 13, 19 ) then
                                    'Claim Payment'
                                else
                                    reason_name
                            end                 transaction_type,
                            c.acc_num,
                            to_char(a.claim_id) claim_invoice_id,
                            - a.pay_amount      check_amount,
                            e.reason_name       note,
                            a.service_type      plan_type,
                            d.pay_date          transaction_date,
                            a.paid_date,
                            p.first_name,
                            p.last_name,
                            2                   ord_no,
                            a.reason_code,
                            a.employer_payment_id
                        from
                            employer_payment_detail a,
                            claimn                  b,
                            account                 c,
                            payment                 d,
                            pay_reason              e,
                            person                  p
                        where
                                a.entrp_id = p_entrp_id
                            and a.reason_code = 13
                            and transaction_source = 'CLAIM_PAYMENT'
                            and a.status = 'PROCESSED'
                            and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                            and a.product_type = p_product_type
                            and d.reason_code = 13
                            and a.claim_id = b.claim_id
                            and a.claim_id = d.claimn_id
                            and a.change_num = d.change_num
                            and b.pers_id = c.pers_id
                            and c.acc_id = d.acc_id
                            and c.pers_id = p.pers_id
                            and a.reason_code = e.reason_code
                            and a.service_type = x.plan_type
                            and b.plan_end_date = x.plan_end_date
                            and b.plan_start_date = x.plan_start_date
                            and a.paid_date >= nvl(x.reimburse_start_date, x.plan_start_date)
                    );

        end if;

        if x.claim_reimbursed_by = 'EMPLOYER' then
            for xx in (
                select
                    claim_reimbursed_by,
                    plan_end_date,
                    plan_start_date,
                    reimburse_start_date,
                    plan_type
                from
                    ben_plan_history
                where
                        entrp_id = p_entrp_id
                    and ben_plan_id = x.ben_plan_id
                    and product_type = p_product_type
                    and claim_reimbursed_by = 'STERLING'
            ) loop
                insert into fsahra_er_balance_gtt
                    select
                        transaction_type,
                        acc_num,
                        claim_invoice_id,
                        check_amount,
                        plan_type,
                        reason_code,
                        note,
                        transaction_date,
                        paid_date,
                        first_name,
                        last_name,
                        ord_no,
                        employer_payment_id
                    from
                        (
                            select
                                case
                                    when a.reason_code in ( 11, 12, 13, 19 ) then
                                        'Claim Payment'
                                    else
                                        reason_name
                                end                 transaction_type,
                                c.acc_num,
                                to_char(a.claim_id) claim_invoice_id,
                                - a.pay_amount      check_amount,
                                e.reason_name       note,
                                a.service_type      plan_type,
                                d.pay_date          transaction_date,
                                a.paid_date,
                                p.first_name,
                                p.last_name,
                                2                   ord_no,
                                a.reason_code,
                                a.employer_payment_id
                            from
                                employer_payment_detail a,
                                claimn                  b,
                                account                 c,
                                payment                 d,
                                pay_reason              e,
                                person                  p
                            where
                                    a.entrp_id = p_entrp_id
                                and a.reason_code = 13
                                and transaction_source = 'CLAIM_PAYMENT'
                                and a.status = 'PROCESSED'
                                and trunc(a.paid_date) <= nvl(p_end_date, sysdate)
                                and a.product_type = p_product_type
                                and d.reason_code = 13
                                and a.claim_id = b.claim_id
                                and a.claim_id = d.claimn_id
                                and a.change_num = d.change_num
                                and b.pers_id = c.pers_id
                                and c.acc_id = d.acc_id
                                and c.pers_id = p.pers_id
                                and a.reason_code = e.reason_code
                                and a.service_type = xx.plan_type
                                and b.plan_end_date = xx.plan_end_date
                                and b.plan_start_date = xx.plan_start_date
                                and a.paid_date between xx.plan_start_date and nvl(x.reimburse_start_date, xx.plan_start_date)
                        );

            end loop;
        end if;

    end loop;   
     
             /*  UNION ALL
                (SELECT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END TRANSACTION_TYPE 
                    , C.ACC_NUM , TO_CHAR(A.CLAIM_ID) , -A.PAY_AMOUNT , E.REASON_NAME , A.SERVICE_TYPE , D.PAY_DATE 
                    , a.PAID_DATE , P.FIRST_NAME , P.LAST_NAME , 2 ORD_NO ,
                      A.REASON_CODE,
                      A.EMPLOYER_PAYMENT_ID
                FROM EMPLOYER_PAYMENT_DETAIL A , CLAIMN B , ACCOUNT C , PAYMENT D , PAY_REASON E , PERSON P
                   , BEN_PLAN_ENROLLMENT_SETUP BP
                WHERE a.ENTRP_ID =P_ENTRP_ID
                AND A.REASON_CODE = 13
                and TRANSACTION_SOURCE = 'CLAIM_PAYMENT' 
                AND A.STATUS = 'PROCESSED'
                AND TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE)
                AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
                AND D.REASON_CODE = 13
                AND A.CLAIM_ID = B.CLAIM_ID 
                AND A.CLAIM_ID = D.CLAIMN_ID 
                AND A.CHANGE_NUM = D.CHANGE_NUM
                AND B.PERS_ID = C.PERS_ID               
                AND C.ACC_ID = D.ACC_ID 
                AND C.PERS_ID = P.PERS_ID
                AND BP.ACC_ID  = C.ACC_ID
                AND A.PRODUCT_TYPE = BP.PRODUCT_TYPE
                AND A.REASON_CODE = E.REASON_CODE 
                AND BP.ENTRP_ID                = a.ENTRP_ID
                AND BP.PLAN_TYPE            =A.SERVICE_TYPE
                AND B.PLAN_END_DATE         = BP.PLAN_END_DATE
                AND B.PLAN_START_DATE       = BP.PLAN_START_DATE
                AND BP.CLAIM_REIMBURSED_BY = 'STERLING'
                AND A.PAID_DATE            >= NVL(BP.reimburse_start_date,BP.PLAN_START_DATE)
                AND A.STATUS = 'PROCESSED'
                UNION ALL
                SELECT TRANSACTION_TYPE, ACC_NUM, CLAIM_ID,PAY_AMOUNT,REASON_NAME,SERVICE_TYPE,PAY_DATE
                        ,     PAID_DATE,FIRST_NAME,LAST_NAME,ORD_NO,REASON_CODE,EMPLOYER_PAYMENT_ID
               FROM ( SELECT DISTINCT CASE WHEN A.REASON_CODE IN (11,12,13,19) THEN 'Claim Payment' ELSE REASON_NAME END TRANSACTION_TYPE 
                    , C.ACC_NUM , TO_CHAR(A.CLAIM_ID) CLAIM_ID , -A.PAY_AMOUNT PAY_AMOUNT, E.REASON_NAME , A.SERVICE_TYPE , D.PAY_DATE 
                    , a.PAID_DATE , P.FIRST_NAME , P.LAST_NAME , 2 ORD_NO ,
                      A.REASON_CODE,D.CHANGE_NUM,
                      A.EMPLOYER_PAYMENT_ID
                        FROM EMPLOYER_PAYMENT_DETAIL A , CLAIMN B , ACCOUNT C , PAYMENT D , PAY_REASON E , PERSON P
                           , BEN_PLAN_ENROLLMENT_SETUP BPS,BEN_PLAN_HISTORY BP
		            WHERE a.ENTRP_ID =P_ENTRP_ID
		                AND A.REASON_CODE = 13
		                and TRANSACTION_SOURCE = 'CLAIM_PAYMENT' 
		                AND A.STATUS = 'PROCESSED'
		                AND TRUNC(A.PAID_DATE) <= NVL(P_END_DATE,SYSDATE)
		                AND A.PRODUCT_TYPE = P_PRODUCT_TYPE
		                AND D.REASON_CODE = 13
		                AND A.CLAIM_ID = B.CLAIM_ID 
		                AND A.CLAIM_ID = D.CLAIMN_ID 
		                AND A.CHANGE_NUM = D.CHANGE_NUM
		                AND B.PERS_ID = C.PERS_ID               
		                AND C.ACC_ID = D.ACC_ID 
		                AND C.PERS_ID = P.PERS_ID
		                AND BP.ACC_ID  = C.ACC_ID
		                AND A.PRODUCT_TYPE = BP.PRODUCT_TYPE
		                AND A.REASON_CODE = E.REASON_CODE 
		                AND BP.ENTRP_ID                = a.ENTRP_ID
                        AND B.PLAN_END_DATE         = BP.PLAN_END_DATE
                        AND B.PLAN_START_DATE       = BP.PLAN_START_DATE
                        AND BP.ENTRP_ID                = a.ENTRP_ID
                        AND BP.CLAIM_REIMBURSED_BY = 'STERLING' 
                        AND BPS.BEN_PLAN_ID = BP.BEN_PLAN_ID
                        AND BPS.CLAIM_REIMBURSED_BY  = 'EMPLOYER'
                        AND A.PAID_DATE BETWEEN BP.PLAN_START_DATE and NVL(BPS.reimburse_start_date,BP.PLAN_START_DATE)
                        AND A.STATUS = 'PROCESSED'))*/

     --OPEN X_CURSOR FOR SELECT * FROM fsahra_er_balance_gtt where rownum < 10;

end run_er_recon_report;
/

