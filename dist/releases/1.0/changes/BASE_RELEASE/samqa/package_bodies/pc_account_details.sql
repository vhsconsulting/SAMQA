-- liquibase formatted sql
-- changeset SAMQA:1754373956167 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_account_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_account_details.sql:null:ebde0536ad448a33f531103cbdce0601b1dcd1b9:create

create or replace package body samqa.pc_account_details as

    function get_receipts_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0)) amount
        into l_amount
        from
            (
                select
                    sum(nvl(amount, 0) + nvl(amount_add, 0)) amount
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 0, 3, 4, 6, 7,
                                      110, 9, 14, 15, 16 )
                    and trunc(fee_date) >= case
                                               when trunc(fee_date) <= p_effective_date
                                                    and trunc(p_effective_date) >= trunc(p_start_date) then
                                                   least(
                                                       trunc(fee_date),
                                                       trunc(p_start_date)
                                                   )
                                               else
                                                   trunc(p_start_date)
                                           end
                    and trunc(fee_date) <= p_end_date
                union all
                select
                    sum(nvl(amount, 0) + nvl(amount_add, 0))
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 10, 130 )
                    and trunc(fee_date) >= p_end_date
                    and trunc(fee_date) <= trunc(sysdate)
            );

        return l_amount;
    exception
        when others then
            return 0;
    end get_receipts_total;

    function get_er_receipts_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0)) amount
        into l_amount
        from
            (
                select
                    sum(nvl(amount, 0)) amount
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 0, 3, 4, 6, 7,
                                      110, 9, 14, 15, 16 )
                    and trunc(fee_date) >= case
                                               when trunc(fee_date) <= p_effective_date
                                                    and trunc(p_effective_date) >= trunc(p_start_date) then
                                                   least(
                                                       trunc(fee_date),
                                                       trunc(p_start_date)
                                                   )
                                               else
                                                   trunc(p_start_date)
                                           end
                    and trunc(fee_date) <= p_end_date
                union all
                select
                    sum(nvl(amount, 0))
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 10, 130 )
                    and trunc(fee_date) >= p_end_date
                    and trunc(fee_date) <= trunc(sysdate)
            );

        return l_amount;
    exception
        when others then
            return 0;
    end get_er_receipts_total;

    function get_ee_receipts_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0)) amount
        into l_amount
        from
            (
                select
                    sum(nvl(amount_add, 0)) amount
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 0, 3, 4, 6, 7,
                                      110, 9, 14, 15, 16 )
                    and trunc(fee_date) >= case
                                               when trunc(fee_date) <= p_effective_date
                                                    and trunc(p_effective_date) >= trunc(p_start_date) then
                                                   least(
                                                       trunc(fee_date),
                                                       trunc(p_start_date)
                                                   )
                                               else
                                                   trunc(p_start_date)
                                           end
                    and trunc(fee_date) <= p_end_date
                union all
                select
                    sum(nvl(amount_add, 0))
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 10, 130 )
                    and trunc(fee_date) >= p_end_date
                    and trunc(fee_date) <= trunc(sysdate)
            );

        return l_amount;
    exception
        when others then
            return 0;
    end get_ee_receipts_total;

    function get_interest_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0) + nvl(amount_add, 0))
        into l_amount
        from
            income
        where
                acc_id = p_acc_id
            and nvl(fee_code, -1) = 8
            and trunc(fee_date) >= p_start_date
            and trunc(fee_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_interest_total;

    function get_disb_fee_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0))
        into l_amount
        from
            payment    a,
            pay_reason b
        where
                acc_id = p_acc_id
            and a.reason_code = b.reason_code
            and b.reason_code not in ( 1, 2, 100 )
            and a.reason_mode = 'P'
            and b.reason_type = 'FEE'
            and trunc(pay_date) >= p_start_date
            and trunc(pay_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_disb_fee_total;

    function get_fee_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(ee_fee_amount, 0) + nvl(er_fee_amount, 0))
        into l_amount
        from
            income
        where
                acc_id = p_acc_id
            and trunc(fee_date) >= p_start_date
            and trunc(fee_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_fee_total;

    function get_fee_paid_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0))
        into l_amount
        from
            payment
        where
                acc_id = p_acc_id
            and reason_code in ( 1, 2, 100 )
            and trunc(pay_date) >= p_start_date
            and trunc(pay_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_fee_paid_total;

    function get_disbursement_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0))
        into l_amount
        from
            payment    a,
            pay_reason b
        where
                acc_id = p_acc_id
            and a.reason_code = b.reason_code
            and a.reason_mode = 'P'
            and b.reason_type = 'DISBURSEMENT'
            and b.reason_code <> 18
            and trunc(pay_date) >= p_start_date
            and trunc(pay_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_disbursement_total;

    function get_qdisb_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(a.amount, 0))
        into l_amount
        from
            payment a,
            claimn  b
        where
                a.acc_id = p_acc_id
            and a.claimn_id = b.claim_id
    -- AND    a.REASON_CODE  IN (11,12,13,19,60) -- These are the only qualified disbursment we reported in 1099SA
            and b.service_status in ( 1, 2 )
            and reason_mode = 'P'
            and trunc(pay_date) >= p_start_date
            and trunc(pay_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_qdisb_total;

    function get_nqdisb_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(a.amount, 0))
        into l_amount
        from
            payment a,
            claimn  b
        where
                acc_id = p_acc_id
            and a.claimn_id = b.claim_id
            and b.service_status = 3
            and reason_mode = 'P'
            and trunc(pay_date) >= p_start_date
            and trunc(pay_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_nqdisb_total;

    function get_current_year_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0)) amount
        into l_amount
        from
            (
                select
                    sum(nvl(amount, 0) + nvl(amount_add, 0)) amount
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 0, 3, 4, 6, 110,
                                      9, 14, 15, 16 )
                    and trunc(fee_date) >= case
                                               when trunc(fee_date) <= p_effective_date
                                                    and trunc(p_effective_date) >= trunc(p_start_date) then
                                                   least(
                                                       trunc(fee_date),
                                                       trunc(p_start_date)
                                                   )
                                               else
                                                   trunc(p_start_date)
                                           end
                    and trunc(fee_date) <= p_end_date
                union all
                select
                    sum(nvl(amount, 0) + nvl(amount_add, 0))
                from
                    income
                where
                        acc_id = p_acc_id
                    and fee_code in ( 10, 130 )
                    and trunc(fee_date) >= p_end_date
                    and trunc(fee_date) <= trunc(sysdate)
            );

        return l_amount;
    exception
        when others then
            return 0;
    end get_current_year_total;

    function get_prior_year_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0) + nvl(amount_add, 0))
        into l_amount
        from
            income
        where
                acc_id = p_acc_id
            and fee_code in ( 7, 10 )
            and trunc(fee_date) >= trunc(p_start_date)
            and trunc(fee_date) <= p_end_date;

        return l_amount;
    exception
        when others then
            return 0;
    end get_prior_year_total;

    function get_contribution (
        p_acc_id in number,
        p_year   in number
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0))
        into l_amount
        from
            (
                select
                    sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0)) amount
                from
                    income inc
                where
                        acc_id = p_acc_id
                    and trunc(fee_date) >= to_date('01/01/' || p_year, 'MM/DD/YYYY')
                    and fee_code in ( 0, 3, 4, 6, 15,
                                      110 )
                    and trunc(fee_date) between to_date('01/01/' || p_year, 'MM/DD/YYYY') and to_date('12/31/' || p_year, 'MM/DD/YYYY'
                    )
                union
                select
                    sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0)) amount
                from
                    income inc
                where
                        acc_id = p_acc_id
                    and fee_code = 130
                    and trunc(fee_date) > to_date('12/31/' || p_year, 'MM/DD/YYYY')
            );

        return l_amount;
    exception
        when others then
            return 0;
    end get_contribution;

    function get_fees (
        p_acc_id in number,
        p_year   in number
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0))
        into l_amount
        from
            payment
        where
                acc_id = p_acc_id
            and reason_code in ( 1, 2, 100 )
            and trunc(pay_date) between to_date('01/01/' || p_year, 'MM/DD/YYYY') and to_date('12/31/' || p_year, 'MM/DD/YYYY');

        return l_amount;
    exception
        when others then
            return 0;
    end get_fees;

    function get_over_contributed_date (
        p_acc_id in number,
        p_year   in number,
        p_fedmax in number
    ) return date is
        l_amount   number := 0;
        l_fees     number := 0;
        l_fee_date date;
    begin
        for x in (
            select
                fee_date,
                amount
            from
                (
                    select
                        fee_date,
                        sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0))
                        over(
                            order by
                                fee_date
                        ) amount
                    from
                        income inc
                    where
                            acc_id = p_acc_id
                        and fee_code in ( 0, 3, 4, 6, 110 )
                        and trunc(fee_date) between to_date('01/01/' || p_year, 'MM/DD/YYYY') and to_date('12/31/' || p_year, 'MM/DD/YYYY'
                        )
                )
            where
                amount > p_fedmax
        ) loop
            l_fee_date := x.fee_date;
        end loop;

        return l_fee_date;
    exception
        when others then
            return null;
    end;

    function get_over_contribution (
        p_year in number
    ) return over_contribution_table_t
        pipelined
        deterministic
    is
        l_cursor sys_refcursor;
        l_record over_contribution_row_t;
    begin
        open l_cursor for select
                              acc_num,
                              fedmax,
                              null,
                              age,
                              acc_id,
                              null,
                              pc_person.count_dependent(pers_id) no_of_dep,
                              email
                          from
                              (
                                  select
                                      acc_num,
                                      d.acc_id,
                                      trunc(months_between(sysdate, birth_date) / 12)    age,
                                      a.pers_id,
                                      pc_users.get_email(d.acc_num, d.acc_id, a.pers_id) email,
                                      get_fed_max(c.plan_type, a.birth_date, p_year)     fedmax
                                  from
                                      account d,
                                      person  a,
                                      insure  c
                                  where
                                          d.account_status = 1
                                      and d.account_type = 'HSA'
                                      and a.pers_id = d.pers_id
                                      and c.pers_id = a.pers_id
                                      and d.start_date <= to_date('12/31' || p_year, 'MM/DD/YYYY')
                                      and exists (
                                          select
                                              *
                                          from
                                              income
                                          where
                                                  acc_id = d.acc_id
                                              and fee_date >= to_date('01/01' || p_year, 'MM/DD/YYYY') - 1
                                      )
                              );
 --  WHERE fedmax < balance ;

        loop

      -- Fetch the next row from the result set
            fetch l_cursor into l_record;

          -- Exit if there are no more rows
            exit when l_cursor%notfound;
                --,  PC_ACCOUNT_DETAILS.get_contribution(acc_id,p_year) balance
              --  , to_char(pc_account_details.get_over_contributed_date(acc_id,p_year,fedmax),'MM/DD/YYYY')   over_contributed_date

      -- Check if the row should be sent based on the filter criteria
       -- Pipe the row of data to the caller

      --
            l_record.over_contributed_date := to_char(
                pc_account_details.get_over_contributed_date(l_record.acc_id, p_year, l_record.fedmax),
                'MM/DD/YYYY'
            );

            if l_record.over_contributed_date is not null then
                l_record.balance := pc_account_details.get_contribution(l_record.acc_id, p_year);
                pipe row ( l_record );
            end if;

       /*  IF l_record.fedmax < pc_account.year_income(l_record.acc_id,TO_DATE('01/01'||P_YEAR,'MM/DD/YYYY'),TO_DATE('12/31'||P_YEAR,'MM/DD/YYYY')) THEN
            l_record.balance := PC_ACCOUNT_DETAILS.get_contribution(l_record.acc_id,p_year);
             IF l_record.fedmax < l_record.balance THEN
                l_record.over_contributed_date := to_char(pc_account_details.get_over_contributed_date
                                          (l_record.acc_id,p_year,l_record.fedmax),'MM/DD/YYYY');
                PIPE ROW(l_record);
             END IF;
         END IF;*/

        end loop;

    -- Close the cursor and exit
        close l_cursor;
        return;
    end get_over_contribution;

    function get_debit_bal_decp (
        p_record_type in varchar2
    ) return debit_transaction_t
        pipelined
        deterministic
    is

        l_record            debit_transaction_row_t;
        l_last_receipt_date date;
        l_last_payment_date date;
        cursor l_bal_cur is
        select
            b.acc_num,
            b.acc_id,
            b.pers_id
            --     ,pc_account.new_acc_balance(b.acc_id) sam_balance
            ,
            a.disbursable_balance                                          metavante_balance,
            pc_lookups.get_meaning(a.account_status, 'MBI_ACCOUNT_STATUS') account_status
        from
            metavante_card_balances a,
            account                 b
        where
                a.plan_type = 'HSA'
            and a.acc_num = b.acc_num
            and b.account_type = 'HSA'
            and b.account_status in ( 1, 2, 3 );

        type cur_record is
            table of l_bal_cur%rowtype index by pls_integer;
        l_cur               cur_record;
    begin
        open l_bal_cur;
        loop
            fetch l_bal_cur
            bulk collect into l_cur limit 1000;
            for i in 1..l_cur.count loop
                l_record.acc_num := l_cur(i).acc_num;
                l_record.sam_balance := 0;
                l_record.acc_id := l_cur(i).acc_id;
                l_record.pers_id := l_cur(i).pers_id;
                l_record.status := l_cur(i).account_status;
                for x in (
                    select
                        (
                            select
                                max(fee_date)
                            from
                                income
                            where
                                income.acc_id = l_cur(i).acc_id
                        ) last_receipt_date,
                        (
                            select
                                max(pay_date)
                            from
                                payment
                            where
                                payment.acc_id = l_cur(i).acc_id
                        ) last_payment_date
                    from
                        dual
                ) loop
                    l_record.last_receipt_date := x.last_receipt_date;
                    l_record.last_payment_date := x.last_payment_date;
                end loop;

                if greatest(l_record.last_receipt_date, l_record.last_payment_date) < sysdate - 2 then
                    l_record.sam_balance := pc_account.acc_balance(l_cur(i).acc_id);
                    if p_record_type = 'OVER_CONTRIBUTION' then
                        if l_cur(i).metavante_balance > l_record.sam_balance then
                            l_record.metavante_balance := l_cur(i).metavante_balance;
                            l_record.difference := l_cur(i).metavante_balance - l_record.sam_balance;
                            pipe row ( l_record );
                        end if;

                    else
                        if l_cur(i).metavante_balance < l_record.sam_balance then
                            l_record.metavante_balance := l_cur(i).metavante_balance;
                            l_record.difference := l_cur(i).metavante_balance - l_record.sam_balance;
                            pipe row ( l_record );
                        end if;
                    end if;

                end if;

            end loop;

            exit when l_bal_cur%notfound;
        end loop;

        close l_bal_cur;
    end get_debit_bal_decp;

    function get_disbursement_total_by_plan (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date,
        p_plan_type  in varchar2
    ) return number is
        l_amount number := 0;
    begin
        select
            sum(nvl(amount, 0))
        into l_amount
        from
            payment    a,
            pay_reason b
        where
                acc_id = p_acc_id
            and a.reason_code = b.reason_code
            and a.reason_mode = 'P'
            and b.reason_type = 'DISBURSEMENT'
            and b.reason_code <> 18
            and trunc(pay_date) >= p_start_date
            and trunc(pay_date) <= p_end_date
            and a.plan_type = p_plan_type;

        return l_amount;
    exception
        when others then
            return 0;
    end get_disbursement_total_by_plan;

end pc_account_details;
/

