-- liquibase formatted sql
-- changeset SAMQA:1754374144102 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\insert_er_balance_gtt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/insert_er_balance_gtt.sql:null:41edce3860111865dc174d158578ffde0a19257c:create

create or replace procedure samqa.insert_er_balance_gtt (
    p_entrp_id     in number,
    p_product_type in varchar2,
    p_end_date     in date
) is
    l_balance number := 0;
    l_ord     number := 0;
    l_count   number := 0;
begin
    pc_log.log_error('get_er_recon_report', 'P_END_DATE ' || p_end_date);
    pc_log.log_error('get_er_recon_report', 'P_PRODUCT_TYPE ' || p_product_type);
    pc_log.log_error('get_er_recon_report', 'p_entrp_id ' || p_entrp_id);
    execute immediate 'ALTER SESSION ENABLE PARALLEL DML';
    insert /*+ PARALLEL(t, 4) */ into fsahra_er_balance_gtt
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
                                   --AND      PRODUCT_TYPE = P_PRODUCT_TYPE   -- commented by Joshi and added below for Ticket#11027 on 04/04/2022
            and ( ( p_product_type = 'HRA'
                    and plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) )
                  or ( p_product_type = 'FSA'
                       and plan_type in ( 'FSA', 'DCA', 'PKG', 'TRN', 'IIR',
                                          'LPF', 'UA1', 'HR4' ) ) )
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
                select distinct
                    claim_reimbursed_by,
                    plan_end_date,
                    plan_start_date,
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

    select
        count(*)
    into l_count
    from
        fsahra_er_balance_gtt;

    pc_log.log_error('get_er_recon_report', 'no of rows ' || l_count);
end insert_er_balance_gtt;
/

