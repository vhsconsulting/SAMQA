create or replace package body samqa.pc_fin_recon_report as

    function get_receipt_amount (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0)) receipt_amount
            from
                income  a,
                account b,
                plans   c
            where
                a.fee_date between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 1
                and ( a.fee_code is null
                      or a.fee_code not in ( 8, 130 ) )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_total_amount := x.receipt_amount;
        end loop;

        return l_total_amount;
    end get_receipt_amount;

    function get_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_total_amount number := 0;
        l_record_t     transaction_row_t;
    begin
        pc_log.log_error('get_receipt_details', 'p_start_date ' || p_start_date);
        pc_log.log_error('get_receipt_details', 'p_end_date ' || p_end_date);
        for x in (
            select
                b.acc_num,
                a.fee_code,
                to_char(a.fee_date, 'MM/DD/YYYY')                                                           fee_date,
                pc_person.get_person_name(b.pers_id)                                                        name,
                pc_lookups.get_fee_reason(a.fee_code)                                                       reason_name,
                nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0) receipt_amount
            from
                income  a,
                account b,
                plans   c
            where
                a.fee_date between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 1
                and ( a.fee_code is null
                      or a.fee_code not in ( 8, 130 ) )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.fee_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.receipt_amount;
            pipe row ( l_record_t );
        end loop;

    end get_receipt_details;

    function get_incomp_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0)) receipt_amount -- Incomplete Accounts
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 0
                and ( a.fee_code is null
                      or a.fee_code not in ( 8, 130 ) )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_total_amount := x.receipt_amount;
        end loop;

        return l_total_amount;
    end get_incomp_receipt;

    function get_incomp_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.fee_code,
                to_char(a.fee_date, 'MM/DD/YYYY')                                                           fee_date,
                pc_person.get_person_name(b.pers_id)                                                        name,
                pc_lookups.get_fee_reason(a.fee_code)                                                       reason_name,
                nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0) receipt_amount
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 0
                and ( a.fee_code is null
                      or a.fee_code not in ( 8, 130 ) )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.fee_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.receipt_amount;
            pipe row ( l_record_t );
        end loop;
    end get_incomp_receipt_details;

    function get_fraud_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0)) receipt_amount -- Fraud Accounts
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and ( b.blocked_flag = 'Y' )
        ) loop
            l_total_amount := x.receipt_amount;
        end loop;

        return l_total_amount;
    end get_fraud_receipt;

    function get_fraud_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.fee_code,
                to_char(a.fee_date, 'MM/DD/YYYY')                                                           fee_date,
                pc_person.get_person_name(b.pers_id)                                                        name,
                pc_lookups.get_fee_reason(a.fee_code)                                                       reason_name,
                nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0) receipt_amount
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and ( b.blocked_flag = 'Y' )
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.fee_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.receipt_amount;
            pipe row ( l_record_t );
        end loop;
    end get_fraud_receipt_details;

    function get_prev_adj_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0)) receipt_amount-- Adjustment for previous year contribution
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 1
                and ( a.fee_code = 130 )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_total_amount := x.receipt_amount;
        end loop;

        return l_total_amount;
    end get_prev_adj_receipt;

    function get_prev_adj_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.fee_code,
                to_char(a.fee_date, 'MM/DD/YYYY')                                                           fee_date,
                pc_person.get_person_name(b.pers_id)                                                        name,
                pc_lookups.get_fee_reason(a.fee_code)                                                       reason_name,
                nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0) receipt_amount
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 1
                and ( a.fee_code = 130 )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.fee_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.receipt_amount;
            pipe row ( l_record_t );
        end loop;
    end get_prev_adj_receipt_details;

    function get_interest (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0)) receipt_amount -- Interest
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 1
                and ( a.fee_code = 8 )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_total_amount := x.receipt_amount;
        end loop;

        return l_total_amount;
    end get_interest;

    function get_interest_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.fee_code,
                to_char(a.fee_date, 'MM/DD/YYYY')                                                           fee_date,
                pc_person.get_person_name(b.pers_id)                                                        name,
                pc_lookups.get_fee_reason(a.fee_code)                                                       reason_name,
                nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0) receipt_amount
            from
                income  a,
                account b,
                plans   c
            where
                trunc(a.fee_date) between p_start_date and p_end_date
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and b.complete_flag = 1
                and ( a.fee_code = 8 )
                and ( b.blocked_flag is null
                      or b.blocked_flag = 'N' )
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.fee_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.receipt_amount;
            pipe row ( l_record_t );
        end loop;
    end get_interest_details;

    function get_unposted_er_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.remaining_balance, 0)) remaining_balance -- Employer unposted transactions
            from
                employer_deposits a,
                account           b,
                plans             c
            where
                trunc(a.check_date) between p_start_date and p_end_date
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and a.remaining_balance <> 0
                and nvl(a.note, '-1') = 'Migrating deposits'

	--AND   (A.REASON_CODE IS NULL OR A.REASON_CODE NOT IN (8,130)
        ) loop
            l_total_amount := x.remaining_balance;
        end loop;

        return l_total_amount;
    end get_unposted_er_receipt;

    function get_unposted_er_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.reason_code,
                to_char(a.check_date, 'MM/DD/YYYY')      fee_date,
                pc_entrp.get_entrp_name(b.entrp_id)      name,
                pc_lookups.get_fee_reason(a.reason_code) reason_name,
                nvl(a.remaining_balance, 0)              amount,
                (
                    select
                        count(*)
                    from
                        teamster_v t
                    where
                        t.acc_num = b.acc_num
                )                                        teamster,
                a.list_bill,
                a.check_number
            from
                employer_deposits a,
                account           b,
                plans             c
            where
                trunc(a.check_date) between p_start_date and p_end_date
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and a.remaining_balance <> 0
                and nvl(a.note, '-1') <> 'Migrating deposits'
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.reason_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.amount;
            l_record_t.teamster :=
                case
                    when x.teamster > 0 then
                        'Y'
                    else 'N'
                end;
            l_record_t.listbill := x.list_bill;
            l_record_t.check_number := x.check_number;
            pipe row ( l_record_t );
        end loop;
    end get_unposted_er_details;

    function get_fees (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.amount, 0)) fee_amount
            from
                payment    a,
                account    b,
                plans      c,
                pay_reason d
            where
                trunc(a.pay_date) between p_start_date and p_end_date
                and a.acc_id = b.acc_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and d.reason_code = a.reason_code
                and d.reason_type = 'FEE'
                and c.plan_sign = p_plan_sign
        ) loop
            l_total_amount := x.fee_amount;
        end loop;

        return l_total_amount;
    end get_fees;

    function get_fees_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.reason_code,
                to_char(a.pay_date, 'MM/DD/YYYY')    fee_date,
                pc_person.get_person_name(b.pers_id) name,
                d.reason_name,
                nvl(a.amount, 0)                     amount
            from
                payment    a,
                account    b,
                plans      c,
                pay_reason d
            where
                trunc(a.pay_date) between p_start_date and p_end_date
                and a.acc_id = b.acc_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and d.reason_code = a.reason_code
                and d.reason_type = 'FEE'
                and c.plan_sign = p_plan_sign
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.reason_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.amount;
            pipe row ( l_record_t );
        end loop;
    end get_fees_details;

    function get_payment (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.amount, 0)) fee_amount
            from
                payment    a,
                account    b,
                plans      c,
                pay_reason d
            where
                trunc(a.pay_date) between p_start_date and p_end_date
                and a.acc_id = b.acc_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and d.reason_code = a.reason_code
                and d.reason_type = 'DISBURSEMENT'
                and c.plan_sign = p_plan_sign
        ) loop
            l_total_amount := x.fee_amount;
        end loop;

        return l_total_amount;
    end get_payment;

    function get_payment_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.reason_code,
                to_char(a.pay_date, 'MM/DD/YYYY')    fee_date,
                pc_person.get_person_name(b.pers_id) name,
                d.reason_name,
                nvl(a.amount, 0)                     amount
            from
                payment    a,
                account    b,
                plans      c,
                pay_reason d
            where
                trunc(a.pay_date) between p_start_date and p_end_date
                and a.acc_id = b.acc_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and d.reason_code = a.reason_code
                and d.reason_type = 'DISBURSEMENT'
                and c.plan_sign = p_plan_sign
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.reason_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.amount;
            pipe row ( l_record_t );
        end loop;
    end get_payment_details;

    function get_er_refund (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is
        l_total_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.check_amount, 0)) total -- Employer unposted transactions
            from
                employer_payments a,
                account           b,
                plans             c
            where
                trunc(a.check_date) between p_start_date and p_end_date
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and a.reason_code = 25
        ) loop
            l_total_amount := x.total;
        end loop;

        return l_total_amount;
    end get_er_refund;

    function get_er_refund_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record_t transaction_row_t;
    begin
        for x in (
            select
                b.acc_num,
                a.reason_code,
                to_char(a.check_date, 'MM/DD/YYYY')      fee_date,
                pc_entrp.get_entrp_name(b.entrp_id)      name,
                pc_lookups.get_fee_reason(a.reason_code) reason_name,
                nvl(a.check_amount, 0)                   amount
            from
                employer_payments a,
                account           b,
                plans             c
            where
                trunc(a.check_date) between p_start_date and p_end_date
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
                and b.plan_code = c.plan_code
                and c.plan_sign = p_plan_sign
                and a.reason_code = 25
        ) loop
            l_record_t.name := x.name;
            l_record_t.acc_num := x.acc_num;
            l_record_t.transaction_date := x.fee_date;
            l_record_t.reason_code := x.reason_code;
            l_record_t.reason_name := x.reason_name;
            l_record_t.amount := x.amount;
            pipe row ( l_record_t );
        end loop;
    end get_er_refund_details;

    function get_balance (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is

        l_receipt_amount   number := 0;
        l_balance          number := 0;
        l_incomp_receipt   number := 0;
        l_fraud_receipt    number := 0;
        l_prev_adj_receipt number := 0;
        l_interest         number := 0;
        l_unposted_er      number := 0;
        l_fees             number := 0;
        l_payment          number := 0;
        l_refund           number := 0;
    begin
        l_receipt_amount := get_receipt_amount(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_incomp_receipt := get_incomp_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_fraud_receipt := get_fraud_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_prev_adj_receipt := get_prev_adj_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_interest := get_interest(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_unposted_er := get_unposted_er_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_fees := get_fees(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_payment := get_payment(p_account_type, p_plan_sign, p_start_date, p_end_date);
        l_refund := get_er_refund(p_account_type, p_plan_sign, p_start_date, p_end_date);
        pc_log.log_error('get_balance,l_receipt_amount ', l_receipt_amount);
        pc_log.log_error('get_balance,l_incomp_receipt ', l_incomp_receipt);
        pc_log.log_error('get_balance,l_fraud_receipt ', l_fraud_receipt);
        pc_log.log_error('get_balance,l_prev_adj_receipt ', l_prev_adj_receipt);
        pc_log.log_error('get_balance,l_interest ', l_interest);
        pc_log.log_error('get_balance,l_unposted_er ', l_unposted_er);
        pc_log.log_error('get_balance,l_fees ', l_fees);
        pc_log.log_error('get_balance,l_payment ', l_payment);
        l_balance := nvl(l_receipt_amount, 0) + nvl(l_incomp_receipt, 0) + nvl(l_fraud_receipt, 0) + nvl(l_prev_adj_receipt, 0) + nvl
        (l_interest, 0) - ( nvl(l_fees, 0) + nvl(l_payment, 0) + nvl(l_refund, 0) );

        return l_balance;
    end get_balance;

    function get_beg_balance (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number is

        l_receipt_amount   number := 0;
        l_balance          number := 0;
        l_incomp_receipt   number := 0;
        l_fraud_receipt    number := 0;
        l_prev_adj_receipt number := 0;
        l_interest         number := 0;
        l_refund           number := 0;
        l_unposted_er      number := 0;
        l_fees             number := 0;
        l_payment          number := 0;
    begin
        l_receipt_amount := get_receipt_amount(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_incomp_receipt := get_incomp_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_fraud_receipt := get_fraud_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_prev_adj_receipt := get_prev_adj_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_interest := get_interest(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_unposted_er := get_unposted_er_receipt(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_fees := get_fees(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_payment := get_payment(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        l_refund := get_er_refund(p_account_type, p_plan_sign, p_start_date, p_end_date - 1);
        pc_log.log_error('get_beg_balance,l_receipt_amount ', l_receipt_amount);
        pc_log.log_error('get_beg_balance,l_incomp_receipt ', l_incomp_receipt);
        pc_log.log_error('get_beg_balance,l_fraud_receipt ', l_fraud_receipt);
        pc_log.log_error('get_beg_balance,l_prev_adj_receipt ', l_prev_adj_receipt);
        pc_log.log_error('get_beg_balance,l_interest ', l_interest);
        pc_log.log_error('get_beg_balance,l_unposted_er ', l_unposted_er);
        pc_log.log_error('get_beg_balance,l_fees ', l_fees);
        pc_log.log_error('get_beg_balance,l_payment ', l_payment);
        l_balance := nvl(l_receipt_amount, 0) + nvl(l_incomp_receipt, 0) + nvl(l_fraud_receipt, 0) + nvl(l_prev_adj_receipt, 0) + nvl
        (l_interest, 0) - ( nvl(l_fees, 0) + nvl(l_payment, 0) + nvl(l_refund, 0) );

        return l_balance;
    end get_beg_balance;

    procedure get_ending_balance_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) is

        l_total_amount number := 0;
        l_record_t     pc_fin_recon_report.transaction_t;
        c_limit        pls_integer := 100;
        l_utl_id       utl_file.file_type;
        l_file_name    varchar2(3200);
        l_line         varchar2(32000);
        cursor c_receipt is
        select /*+ Parallel ( A 4 ) */
            pc_person.get_person_name(b.pers_id)                                                        name,
            b.acc_num,
            b.acc_id,
            to_char(a.fee_date, 'MM/DD/YYYY')                                                           fee_date,
            a.fee_code,
            pc_lookups.get_fee_reason(a.fee_code)                                                       reason_name,
            nvl(a.amount, 0) + nvl(a.amount_add, 0) + nvl(a.ee_fee_amount, 0) + nvl(a.er_fee_amount, 0) receipt_amount,
            c.plan_sign,
            b.blocked_flag,
            b.account_status,
            null                                                                                        teamster,
            null                                                                                        listbill,
            null                                                                                        checknumber,
            pc_account.get_salesrep_name(b.salesrep_id),
            null                                                                                        employer_name   -- Added by Joshi for 12215(added employer name)
        from
            income  a,
            account b,
            plans   c
        where
            a.fee_date between p_start_date and p_end_date
            and b.account_type = p_account_type
            and a.acc_id = b.acc_id
            and b.plan_code = c.plan_code
            and c.plan_sign = p_plan_sign
            and b.complete_flag = 1
            and ( a.fee_code is null
                  or a.fee_code not in ( 8, 130 ) )
            and ( b.blocked_flag is null
                  or b.blocked_flag = 'N' );

    begin
        l_utl_id := utl_file.fopen('LISTBILL_DIR', 'Receipt.csv', 'w');
        open c_receipt;
        loop
            fetch c_receipt
            bulk collect into l_record_t limit c_limit;
            for i in 1..l_record_t.count loop
                l_line := l_record_t(i).name
                          || ','
                          || l_record_t(i).acc_num
                          || ','
                          || l_record_t(i).transaction_date
                          || ','
                          || l_record_t(i).reason_code
                          || ','
                          || l_record_t(i).reason_name
                          || ','
                          || l_record_t(i).amount;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

            exit when l_record_t.count = 0;
        end loop;

        utl_file.fclose(file => l_utl_id);
    end get_ending_balance_details;

    function get_hsa_balance_details (
        p_acc_num  in varchar2,
        p_end_date in date
    ) return transaction_t
        pipelined
        deterministic
    is
        l_record     transaction_row_t;
        l_emp_acc_id number;
    begin
        if p_acc_num is not null then
            for x in (
                select
                    acc_num,
                    pers_id,
                    case
                        when p.plan_sign <> 'SHA' then
                            'Y'
                        else
                            'N'
                    end                                             private_label,
                    pc_lookups.get_account_status(x.account_status) account_status,
                    sum(nvl(amount, 0))                             amount,
                    acc_id,
                    blocked_flag,
                    salesrep_id
                from
                    (
                        select
                            b.acc_num,
                            b.pers_id,
                            b.plan_code,
                            b.account_status,
                            sum(amount) amount,
                            b.acc_id,
                            blocked_flag,
                            b.salesrep_id
                        from
                            balance_register a,
                            account          b
                        where
                                b.acc_num = p_acc_num
                            and b.account_type = 'HSA'
                            and a.acc_id = b.acc_id
                            and b.account_status <> 5
                            and reason_mode not in ( 'F', 'E', 'C', 'FP', 'EP' )
                            and txn_date between trunc(sysdate, 'CC') and p_end_date
                        group by
                            b.acc_num,
                            b.pers_id,
                            b.plan_code,
                            b.account_status,
                            b.acc_id,
                            blocked_flag,
                            b.salesrep_id
                        union
                        select
                            b.acc_num,
                            b.pers_id,
                            b.plan_code,
                            b.account_status,
                            sum(amount) amount,
                            b.acc_id,
                            blocked_flag,
                            b.salesrep_id
                        from
                            balance_register a,
                            account          b
                        where
                                b.acc_num = p_acc_num
                            and b.account_type = 'HSA'
                            and a.acc_id = b.acc_id
                            and reason_mode = 'EP'
                            and b.account_status <> 5
                            and txn_date between trunc(sysdate, 'CC') and p_end_date + 3
                        group by
                            b.acc_num,
                            b.pers_id,
                            b.plan_code,
                            b.account_status,
                            b.acc_id,
                            blocked_flag,
                            b.salesrep_id
                    )     x,
                    plans p
                where
                    x.plan_code = p.plan_code
                group by
                    acc_num,
                    pers_id,
                    p.plan_sign,
                    x.account_status,
                    acc_id,
                    blocked_flag,
                    salesrep_id
            ) loop
         -- IF X.AMOUNT > 0 THEN
                l_emp_acc_id := null;
                l_record.name := pc_person.get_person_name(x.pers_id);
                l_record.acc_num := x.acc_num;
                l_record.amount := x.amount;
                l_record.private_label := x.private_label;
                l_record.account_status := x.account_status;
                l_record.acc_id := x.acc_id;
                l_record.fraud_flag := x.blocked_flag;
                l_record.salesrep_name := pc_account.get_salesrep_name(x.salesrep_id);

             -- Added by Joshi for 12215(added employer name)
                l_emp_acc_id := pc_account.get_emp_accid_from_pers_id(x.pers_id);
                l_record.employer_name := pc_account.get_employer_name(l_emp_acc_id);
                pipe row ( l_record );
        --  END IF;
            end loop;

        else
            for xx in (
                select
                    b.acc_id,
                    b.acc_num,
                    b.pers_id,
                    b.plan_code,
                    b.account_status,
                    nvl(b.blocked_flag, 'N') blocked_flag,
                    case
                        when p.plan_sign <> 'SHA' then
                            'Y'
                        else
                            'N'
                    end                      private_label,
                    b.salesrep_id
                from
                    account b,
                    plans   p
                where
                        b.plan_code = p.plan_code
                    and b.entrp_id is null
                    and b.account_type = 'HSA'
                    and account_status <> 5
            ) loop
                l_emp_acc_id := null;
                l_record.name := pc_person.get_person_name(xx.pers_id);
                l_record.acc_num := xx.acc_num;
                l_record.private_label := xx.private_label;
                l_record.account_status := pc_lookups.get_account_status(xx.account_status);
                l_record.acc_id := xx.acc_id;
                l_record.fraud_flag := xx.blocked_flag;
                l_record.salesrep_name := pc_account.get_salesrep_name(xx.salesrep_id);

               -- Added by Joshi for 12215(added employer name)
                l_emp_acc_id := pc_account.get_emp_accid_from_pers_id(xx.pers_id);
                l_record.employer_name := pc_account.get_employer_name(l_emp_acc_id);
                l_record.amount := 0;
                for x in (
                    select
                        acc_id,
                        acc_num,
                        pers_id,
                        case
                            when p.plan_sign <> 'SHA' then
                                'Y'
                            else
                                'N'
                        end                                             private_label,
                        pc_lookups.get_account_status(x.account_status) account_status,
                        blocked_flag,
                        sum(nvl(amount, 0))                             amount
                    from
                        (
                            select
                                b.acc_id,
                                b.acc_num,
                                b.pers_id,
                                b.plan_code,
                                b.account_status,
                                nvl(b.blocked_flag, 'N') blocked_flag,
                                sum(amount)              amount
                            from
                                balance_register a,
                                account          b
                            where
                                    b.acc_id = xx.acc_id
                                and b.account_type = 'HSA'
                                and a.acc_id = b.acc_id
                                and reason_mode not in ( 'F', 'E', 'C', 'FP', 'EP' )
                                and txn_date between trunc(sysdate, 'CC') and p_end_date
                            group by
                                b.acc_id,
                                b.acc_num,
                                b.pers_id,
                                b.plan_code,
                                b.account_status,
                                nvl(b.blocked_flag, 'N')
                            union
                            select
                                b.acc_id,
                                b.acc_num,
                                b.pers_id,
                                b.plan_code,
                                b.account_status,
                                nvl(b.blocked_flag, 'N') blocked_flag,
                                sum(amount)              amount
                            from
                                balance_register a,
                                account          b
                            where
                                    b.acc_id = xx.acc_id
                                and b.account_type = 'HSA'
                                and a.acc_id = b.acc_id
                                and reason_mode = 'EP'
                                and txn_date between trunc(sysdate, 'CC') and p_end_date + 3
                            group by
                                b.acc_id,
                                b.acc_num,
                                b.pers_id,
                                b.plan_code,
                                b.account_status,
                                nvl(b.blocked_flag, 'N')
                        )     x,
                        plans p
                    where
                        x.plan_code = p.plan_code
                    group by
                        acc_id,
                        acc_num,
                        pers_id,
                        p.plan_sign,
                        x.account_status,
                        blocked_flag
                ) loop
        --  IF X.AMOUNT > 0 THEN

                    l_record.amount := nvl(x.amount, 0); 
         -- END IF;
                end loop;

                pipe row ( l_record );
            end loop;
        end if;
    end get_hsa_balance_details;

    procedure send_balance_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_end_date  date;
    begin
        l_end_date := p_end_date;
        l_file_name := 'Balance_'
                       || to_char(p_end_date, 'MMDDYYYY')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Balance,Register for ,'
                  || to_char(p_start_date, 'MMDDYYYY')
                  || ',and '
                  || to_char(p_end_date, 'MMDDYYYY');

        x_subject := 'Balance Register as of ' || to_char(p_end_date, 'MMDDYYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'Name,Account Number,Employer Name,Private Label(Y/N),Account Status,Sales Rep, Beginning Balance,Ending Balance,Beginnning Fee Bucket Balance,Ending Fee Bucket Balance'
        ;
        x_subject := 'Balance Register as of ' || to_char(p_end_date, 'MM/DD/YYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                acc_id,
                name,
                employer_name,
                acc_num,
                private_label,
                account_status,
                amount,
                salesrep_name
            from
                table ( pc_fin_recon_report.get_hsa_balance_details(null, p_start_date - 1) )
        ) loop
        -- l_line := '"'||X.NAME||'","'||X.ACC_NUM||'",'||X.PRIVATE_LABEL||','||X.ACCOUNT_STATUS||',"'||x.SALESREP_NAME||'",'||X.AMOUNT;

            l_line := '"'
                      || x.name
                      || '","'
                      || x.acc_num
                      || '","'
                      || x.employer_name
                      || '",'
                      || x.private_label
                      || ','
                      || x.account_status
                      || ',"'
                      || x.salesrep_name
                      || '",'
                      || x.amount;

            for xx in (
                select
                    name,
                    acc_num,
                    private_label,
                    account_status,
                    amount
                from
                    table ( pc_fin_recon_report.get_hsa_balance_details(x.acc_num, p_end_date) )
            ) loop
                l_line := l_line
                          || ','
                          || xx.amount;
            end loop;

            l_line := l_line
                      || ','
                      || pc_account.fee_bucket_balance(x.acc_id,
                                                       trunc(sysdate, 'cc'),
                                                       p_start_date - 1);

            l_line := l_line
                      || ','
                      || pc_account.fee_bucket_balance(x.acc_id,
                                                       trunc(sysdate, 'cc'),
                                                       p_end_date);

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        x_file_name := l_file_name;
        utl_file.fclose(file => l_utl_id);
        pc_notifications.insert_reports('Balance Register Report', '/u01/app/oracle/oradata/report/', l_file_name, null, 'Balance Register Report'
        );
    end send_balance_report;

    procedure send_unposted_er_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_end_date  date;
    begin
        l_end_date := p_end_date;
        l_file_name := 'unposted_'
                       || to_char(p_end_date, 'MMDDYYYY')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Unposted Employer ,Balances as of ,' || to_char(p_end_date, 'MMDDYYYY');
        x_subject := 'Unposted Employer Balances as of ' || to_char(p_end_date, 'MMDDYYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'Name,Account Number,Check Number,Transaction Date,Reason ,Remaining Balance, List Bill, Teamster';
        x_subject := 'Unposted Employer Balances as of ' || to_char(p_end_date, 'MM/DD/YYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                name,
                acc_num,
                transaction_date,
                check_number,
                reason_name,
                amount,
                listbill,
                teamster
            from
                table ( pc_fin_recon_report.get_unposted_er_details('HSA',
                                                                    'SHA',
                                                                    trunc(sysdate, 'cc'),
                                                                    p_end_date - 1) )
        ) loop
            l_line := '"'
                      || x.name
                      || '","'
                      || x.acc_num
                      || '","'
                      || x.check_number
                      || '",'
                      || x.transaction_date
                      || ','
                      || x.reason_name
                      || ','
                      || x.amount
                      || ','
                      || x.listbill
                      || ','
                      || x.teamster;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        x_file_name := l_file_name;
        utl_file.fclose(file => l_utl_id);
    end send_unposted_er_report;
 /*** Notification for previous month deposits  created in current month ***/
    procedure send_ee_income_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_end_date  date;
    begin
        l_end_date := p_end_date;
        l_file_name := 'ind_receipts_'
                       || to_char(p_end_date, 'MMDDYYYY')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Individual deposits posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        x_subject := 'Individual deposits posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'Name,Account Number,Reason, Check Number,Employer Deposit, Employee Deposit,' || 'Account type, Creation Date, Transaction Date'
        ;
        x_subject := 'Individual Deposits Posted Between  '
                     || to_char(p_start_date, 'MM/DD/YYYY')
                     || ' to '
                     || to_char(p_end_date, 'MM/DD/YYYY');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                pc_person.get_person_name(b.pers_id)   person_name,
                b.acc_num,
                a.amount,
                a.amount_add,
                a.cc_number,
                b.account_type,
                to_char(a.creation_date, 'MM/DD/YYYY') creation_date,
                to_char(a.fee_date, 'MM/DD/YYYY')      fee_date,
                c.fee_name
            from
                income    a,
                account   b,
                fee_names c
            where
                    trunc(a.creation_date, 'MM') > trunc(a.fee_date, 'MM')
                and b.account_type in ( 'HRA', 'FSA', 'HSA' )
                and a.creation_date between p_start_date and p_end_date
                and a.cc_number like '%adj%'
                and a.acc_id = b.acc_id
                and a.fee_code = c.fee_code
                and a.fee_code not in ( 11, 12, 17, 8 )
        ) loop
            l_line := '"'
                      || x.person_name
                      || '","'
                      || x.acc_num
                      || '",'
                      || x.fee_name
                      || ','
                      || x.cc_number
                      || ','
                      || x.amount
                      || ','
                      || x.amount_add
                      || ','
                      || x.account_type
                      || ','
                      || x.creation_date
                      || ','
                      || x.fee_date;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        x_file_name := l_file_name;
        utl_file.fclose(file => l_utl_id);
    end send_ee_income_prev_report;

 /*** Notification for previous month employer payments  created in current month ***/
    procedure send_er_payment_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_end_date  date;
    begin
        l_end_date := p_end_date;
        l_file_name := 'er_payments_'
                       || to_char(p_end_date, 'MMDDYYYY')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Employer Payments posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        x_subject := 'Employer Payments posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'Name,Account Number, Check Number,Reason, Check Amount,' || 'Account type, Creation Date, Check Date,Invoice # ';
        x_subject := 'Employer Payments Posted Between  '
                     || to_char(p_start_date, 'MM/DD/YYYY')
                     || ' to '
                     || to_char(p_end_date, 'MM/DD/YYYY');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                pc_entrp.get_entrp_name(a.entrp_id)    er_name,
                b.acc_num,
                b.account_type,
                a.check_amount,
                to_char(a.creation_date, 'MM/DD/YYYY') creation_date,
                to_char(a.check_date, 'MM/DD/YYYY')    check_date,
                a.check_number,
                c.reason_name,
                a.invoice_id
            from
                employer_payments a,
                account           b,
                pay_reason        c
            where
                    trunc(a.creation_date, 'MM') > trunc(a.check_date, 'MM')
                and a.creation_date between p_start_date and p_end_date
                and a.reason_code not in ( 11, 12, 13, 121, 19 )
                and a.entrp_id = b.entrp_id
                and a.reason_code = c.reason_code
        ) loop
            l_line := '"'
                      || x.er_name
                      || '","'
                      || x.acc_num
                      || '",'
                      || x.check_number
                      || ','
                      || x.reason_name
                      || ','
                      || x.check_amount
                      || ','
                      || x.account_type
                      || ','
                      || x.creation_date
                      || ','
                      || x.check_date
                      || ','
                      || x.invoice_id;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        x_file_name := l_file_name;
        utl_file.fclose(file => l_utl_id);
    end send_er_payment_prev_report;

 /*** Notification for previous month employee payments  created in current month ***/
    procedure send_ee_payment_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_end_date  date;
    begin
        l_end_date := p_end_date;
        l_file_name := 'ee_payments_'
                       || to_char(p_end_date, 'MMDDYYYY')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Employee payments posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        x_subject := 'Employee payments posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'Name,Account Number,Reason, Check Number,Check Amount,' || 'Account type, Creation Date, Transaction Date';
        x_subject := 'Employee payments Posted between  '
                     || to_char(p_start_date, 'MM/DD/YYYY')
                     || ' to '
                     || to_char(p_end_date, 'MM/DD/YYYY');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                pc_person.get_person_name(b.pers_id)   person_name,
                b.acc_num,
                a.amount,
                b.account_type,
                to_char(a.creation_date, 'MM/DD/YYYY') creation_date,
                a.pay_num,
                to_char(
                    nvl(a.paid_date, a.pay_date),
                    'MM/DD/YYYY'
                )                                      paid_date,
                c.reason_name
            from
                payment    a,
                account    b,
                pay_reason c
            where
                    trunc(a.creation_date, 'MM') > trunc(
                        nvl(a.paid_date, a.pay_date),
                        'MM'
                    )
                and trunc(a.creation_date) - trunc(nvl(a.paid_date, a.pay_date)) > 7
                and a.creation_date between p_start_date and p_end_date
                and a.acc_id = b.acc_id
                and a.reason_code = c.reason_code
        ) loop
            l_line := '"'
                      || x.person_name
                      || '","'
                      || x.acc_num
                      || '",'
                      || x.reason_name
                      || ','
                      || x.pay_num
                      || ','
                      || x.amount
                      || ','
                      || x.account_type
                      || ','
                      || x.creation_date
                      || ','
                      || x.paid_date;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        x_file_name := l_file_name;
        utl_file.fclose(file => l_utl_id);
    end send_ee_payment_prev_report; 

 /*** Notification for previous month employer receipts  created in current month ***/
    procedure send_er_receipt_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_end_date  date;
    begin
        l_end_date := p_end_date;
        l_file_name := 'er_receipts_'
                       || to_char(p_end_date, 'MMDDYYYY')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Employer Receipts posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        x_subject := 'Employer Receipts posted before ,' || to_char(p_start_date, 'MMDDYYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'Name,Account Number,Reason, Check Number,Check Amount,' || 'Account type, Creation Date, Transaction Date, Invoice #'
        ;
        x_subject := 'Employer Receipts Posted Between  '
                     || to_char(p_start_date, 'MM/DD/YYYY')
                     || ' to '
                     || to_char(p_end_date, 'MM/DD/YYYY');

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                pc_entrp.get_entrp_name(a.entrp_id)    name,
                b.acc_num,
                b.account_type,
                a.check_number,
                a.check_amount,
                to_char(a.creation_date, 'MM/DD/YYYY') creation_date,
                to_char(a.check_date, 'MM/DD/YYYY')    check_date,
                c.fee_name,
                a.invoice_id
            from
                employer_deposits a,
                account           b,
                fee_names         c
            where
                    trunc(a.creation_date, 'MM') > trunc(a.check_date, 'MM')
                and trunc(a.creation_date) - trunc(a.check_date) > 7
                and a.creation_date between p_start_date and p_end_date
                and a.reason_code not in ( 11, 12 )  -- exclude annual election and payroll 
                and a.entrp_id = b.entrp_id
                and a.reason_code = c.fee_code
        ) loop
            l_line := '"'
                      || x.name
                      || '","'
                      || x.acc_num
                      || '",'
                      || x.fee_name
                      || ','
                      || x.check_number
                      || ','
                      || x.check_amount
                      || ','
                      || x.account_type
                      || ','
                      || x.creation_date
                      || ','
                      || x.check_date
                      || ','
                      || x.invoice_id;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        x_file_name := l_file_name;
        utl_file.fclose(file => l_utl_id);
    end send_er_receipt_prev_report;

    procedure send_cobra_balance_report (
        p_end_date  in date--
        ,
        x_file_name out varchar2,
        x_subject   out varchar2
    ) is
        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200);
        l_line      varchar2(32000);
        l_end_date  date;
    begin
        l_end_date := p_end_date;
        l_file_name := 'Balance Register for COBRA EMPLOYERS'
                       || to_char(p_end_date, 'MMDDYYYY')
                       || '.csv';
        l_utl_id := utl_file.fopen('REPORT_DIR', l_file_name, 'w');
        l_line := 'Balance Register for COBRA EMPLOYERS ' || to_char(p_end_date, 'MMDDYYYY');
        x_subject := 'Balance Register for COBRA EMPLOYERS as of ' || to_char(p_end_date, 'MMDDYYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'Name,Account Status,Account Number,Balance';
        x_subject := 'Balance Register for COBRA EMPLOYER  ' || to_char(p_end_date, 'MM/DD/YYYY');
        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        for x in (
            select
                pc_entrp.get_entrp_name(a.entrp_id)                                       name,
                pc_account.get_status(a.acc_id)                                           account_status,
                a.acc_num                                                                 account_number,
                pc_employer_fin.get_employer_balance(a.entrp_id, p_end_date - 1, 'COBRA') balance
            from
                account a
            where
                    account_type = 'COBRA'
                and a.account_status in ( 1, 4 )
                and a.entrp_id is not null
        ) loop
            l_line := '"'
                      || x.name
                      || '","'
                      || x.account_status
                      || '",'
                      || x.account_number
                      || ','
                      || x.balance;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        x_file_name := l_file_name;
        utl_file.fclose(file => l_utl_id);
        pc_notifications.insert_reports('Balance Register Report for COBRA Employers', '/u01/app/oracle/oradata/report/', l_file_name
        , null, 'Balance Register Report for COBRA Employers');
    end send_cobra_balance_report;

end pc_fin_recon_report;
/


-- sqlcl_snapshot {"hash":"6ee3729357620af04d9c0508c8c41c3f0a43dc69","type":"PACKAGE_BODY","name":"PC_FIN_RECON_REPORT","schemaName":"SAMQA","sxml":""}