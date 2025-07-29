create or replace procedure samqa.update_er_payment_detail (
    p_entrp_id in number
) as

    cursor l_cur is
    select
        a.entrp_id,
        sum(a.pay_amount),
        a.check_num,
        a.reason_code,
        a.paid_date,
        a.service_type,
        a.plan_start_date,
        a.plan_end_date,
        a.transaction_source,
        b.employer_payment_id
    from
        employer_payment_detail a,
        employer_payments       b
    where
        a.transaction_source in ( 'PENDING_CHECK', 'PENDING_ACH' )
        and a.entrp_id = b.entrp_id
        and a.check_num = b.check_number
        and a.reason_code = b.reason_code
        and a.service_type = b.plan_type
        and a.plan_start_date = b.plan_start_date
        and a.plan_end_date = b.plan_end_date
        and a.transaction_source = b.transaction_source
        and a.status <> 'VOID'
        and a.paid_date = b.check_date
        and a.entrp_id = p_entrp_id
    group by
        a.entrp_id,
        a.check_num,
        a.reason_code,
        a.paid_date,
        a.service_type,
        a.plan_start_date,
        a.plan_end_date,
        a.transaction_source,
        b.check_amount,
        b.employer_payment_id
    having
        sum(a.pay_amount) = b.check_amount;

    cursor l_p_cur is
    select
        a.entrp_id,
        sum(a.pay_amount),
        a.check_num,
        a.reason_code,
        a.paid_date,
        a.service_type,
        a.plan_start_date,
        a.plan_end_date,
        a.transaction_source,
        b.employer_payment_id
    from
        employer_payment_detail a,
        employer_payments       b
    where
            a.transaction_source = 'CLAIM_PAYMENT'
        and a.entrp_id = b.entrp_id
        and a.check_num = b.check_number
        and a.reason_code = b.reason_code
        and a.service_type = b.plan_type
        and a.plan_start_date = b.plan_start_date
        and a.plan_end_date = b.plan_end_date
        and a.transaction_source = b.transaction_source
        and a.status <> 'VOID'
        and a.paid_date = b.check_date
        and a.entrp_id = p_entrp_id
    group by
        a.entrp_id,
        a.check_num,
        a.reason_code,
        a.paid_date,
        a.service_type,
        a.plan_start_date,
        a.plan_end_date,
        a.transaction_source,
        b.check_amount,
        b.employer_payment_id
    having
        sum(a.pay_amount) = b.check_amount;

    type l_rec is record (
            entrp_id            number,
            amount              number,
            check_num           varchar2(255),
            reason_code         number,
            paid_date           date,
            service_type        varchar2(255),
            plan_start_date     date,
            plan_end_date       date,
            transaction_source  varchar2(3200),
            employer_payment_id number
    );
    type tab is
        table of l_rec;
    l_tab     tab;
    l_pay_tab tab;
begin
    open l_cur;
    loop
        fetch l_cur
        bulk collect into l_tab limit 1000;
        forall i in 1..l_tab.count
            update employer_payment_detail a
            set
                employer_payment_id = l_tab(i).employer_payment_id
            where
                    a.entrp_id = l_tab(i).entrp_id
                and a.check_num = l_tab(i).check_num
                and a.reason_code = l_tab(i).reason_code
                and a.service_type = l_tab(i).service_type
                and a.plan_start_date = l_tab(i).plan_start_date
                and a.plan_end_date = l_tab(i).plan_end_date
                and a.transaction_source = l_tab(i).transaction_source
                and a.paid_date = l_tab(i).paid_date;

        exit when l_tab.count < 1000;
    end loop;

    close l_cur;
    open l_p_cur;
    loop
        fetch l_p_cur
        bulk collect into l_pay_tab limit 1000;
        forall i in 1..l_pay_tab.count
            update employer_payment_detail a
            set
                employer_payment_id = l_pay_tab(i).employer_payment_id
            where
                    a.entrp_id = l_pay_tab(i).entrp_id
                and a.check_num = l_pay_tab(i).check_num
                and a.reason_code = l_pay_tab(i).reason_code
                and a.service_type = l_pay_tab(i).service_type
                and a.plan_start_date = l_pay_tab(i).plan_start_date
                and a.plan_end_date = l_pay_tab(i).plan_end_date
                and a.transaction_source = l_pay_tab(i).transaction_source
                and a.paid_date = l_pay_tab(i).paid_date;

        exit when l_pay_tab.count < 1000;
    end loop;

    close l_p_cur;
end;
/


-- sqlcl_snapshot {"hash":"77c88e5a66607928d316cc80616cf3d85d97a5d8","type":"PROCEDURE","name":"UPDATE_ER_PAYMENT_DETAIL","schemaName":"SAMQA","sxml":""}