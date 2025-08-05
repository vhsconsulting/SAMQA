create or replace package body samqa.pc_account is

/*
  24.02.2007 MJE acc_balance_card: only return the pending auth amount, not zero minus pending auth amount
  21.03.2006 mal year_income exclude fee_codes by fee_type
  07.06.2005 mal *close_account, *acc_balance_card + pers_id,
  07.06.2005 mal + acc_balance_card
  25.03.2005 mal + account_close, Change_Plan
  21.03.2005 mal + is_account_open , is_account_close
  18.02.2005 mal income_v (+ amount_add)
*/
--  income to account
    function get_account_type_from_pers_id (
        p_pers_id in number
    ) return varchar2 is
        l_acc_type varchar2(30);
    begin
        for x in (
            select
                account_type
            from
                account
            where
                pers_id = p_pers_id
        ) loop
            l_acc_type := x.account_type;
        end loop;

        return l_acc_type;
    end get_account_type_from_pers_id;

    function get_acc_num (
        p_mass_enrollment_id in number
    ) return varchar2 is
        l_acc_num varchar2(30);
    begin
        for x in (
            select
                acc_num
            from
                person  a,
                account b
            where
                    a.pers_id = b.pers_id
                and a.mass_enrollment_id = p_mass_enrollment_id
        ) loop
            l_acc_num := x.acc_num;
        end loop;

        return l_acc_num;
    end;

    function get_account_type (
        p_acc_id in number
    ) return varchar2 is
        l_acc_type varchar2(30);
    begin
        for x in (
            select
                account_type
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_acc_type := x.account_type;
        end loop;

        return l_acc_type;
    end get_account_type;

    procedure end_date_employer as
    begin
        for x in (
            select
                a.entrp_id,
                b.start_date,
                b.acc_num
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = b.entrp_id
                and b.start_date < sysdate - ( 365 * 2 )
                and b.account_type = 'HSA'
                and not exists (
                    select
                        *
                    from
                        person  c,
                        account d,
                        income  e
                    where
                            c.entrp_id = a.entrp_id
                        and c.pers_id = d.pers_id
                        and d.acc_id = e.acc_id
                        and e.fee_date > sysdate - ( 365 * 2 )
                )
        ) loop
            update account
            set
                end_date = sysdate,
                account_status = 4
            where
                    acc_num = x.acc_num
                and account_type = 'HSA';

        end loop;
    end;

    function have_outside_investment (
        p_acc_id in number
    ) return varchar2 is
        l_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                *
            from
                investment d
            where
                d.acc_id = p_acc_id
        ) loop
            l_flag := 'Y';
        end loop;

        return l_flag;
    end;

    function get_outside_investment (
        p_acc_id in number
    ) return number is
        l_balance number := 0;
    begin
        for x in (
            select
                sum(nvl(invest_amount, 0)) invest_amount
            from
                invest_transfer c,
                (
                    select
                        max(transfer_id) transfer_id,
                        investment_id
                    from
                        invest_transfer b
                    group by
                        investment_id
                )               e,
                investment      d
            where
                    e.transfer_id = c.transfer_id
                and e.investment_id = c.investment_id
                and d.investment_id = e.investment_id
                and d.acc_id = p_acc_id
        ) loop
            l_balance := x.invest_amount;
        end loop;

        return l_balance;
    end get_outside_investment;

    function acc_income (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is

        cursor c1 (
            p_acc_id     income.acc_id%type,
            p_date_start date,
            p_date_end   date
        ) is
        select
            sum(amount + nvl(amount_add, 0)) amount
        from
            income
        where
                acc_id = p_acc_id
            and nvl(fee_code, -1) <> 8
            and fee_date between p_date_start and p_date_end;

        r1 c1%rowtype;
    begin
        open c1(acc_id_in, date_start_in, date_end_in);
        fetch c1 into r1;
        close c1;
        return nvl(r1.amount, 0);
    end acc_income;

    function acc_interest (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is

        cursor c1 (
            p_acc_id     income.acc_id%type,
            p_date_start date,
            p_date_end   date
        ) is
        select
            sum(amount + nvl(amount_add, 0)) amount
        from
            income
        where
                acc_id = p_acc_id
            and fee_code = 8
            and fee_date between p_date_start and p_date_end;

        r1 c1%rowtype;
    begin
        open c1(acc_id_in, date_start_in, date_end_in);
        fetch c1 into r1;
        close c1;
        return nvl(r1.amount, 0);
    end acc_interest;

--  pay from account
    function acc_payment (
        acc_id_in     in payment.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is

        cursor c1 (
            p_acc_id     payment.acc_id%type,
            p_date_start date,
            p_date_end   date
        ) is
        select
            sum(amount) amount
        from
            payment
        where
                acc_id = p_acc_id
            and reason_code in ( 11, 12, 13, 19 )
            and pay_date between p_date_start and p_date_end;

        r1 c1%rowtype;
    begin
        open c1(acc_id_in, date_start_in, date_end_in);
        fetch c1 into r1;
        close c1;
        return nvl(r1.amount, 0);
    end acc_payment;

    function acc_fee (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is

        cursor c1 (
            p_acc_id     payment.acc_id%type,
            p_date_start date,
            p_date_end   date
        ) is
        select
            sum(amount) amount
        from
            payment
        where
                acc_id = p_acc_id
            and reason_code in ( 1, 2 )
            and pay_date between p_date_start and p_date_end;

        r1 c1%rowtype;
    begin
        open c1(acc_id_in, date_start_in, date_end_in);
        fetch c1 into r1;
        close c1;
        return nvl(r1.amount, 0);
    end acc_fee;

    function lost_card_fee (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is

        cursor c1 (
            p_acc_id     payment.acc_id%type,
            p_date_start date,
            p_date_end   date
        ) is
        select
            sum(amount) amount
        from
            payment a,
            account b
        where
                a.acc_id = p_acc_id
            and a.acc_id = b.acc_id
            and reason_code = 4
            and b.plan_code <> 401
            and b.account_type = 'HSA'
            and pay_date between p_date_start and p_date_end
        union
        select
            sum(amount) amount
        from
            fremont_bank_stmt a,
            account           b
        where
                b.acc_id = p_acc_id
            and a.acc_id = b.acc_id
            and pay_type = 4
            and b.plan_code = 401
            and b.account_type = 'HSA'
            and b.creation_date between p_date_start and p_date_end;

        r1 c1%rowtype;
    begin
        open c1(acc_id_in, date_start_in, date_end_in);
        fetch c1 into r1;
        close c1;
        return nvl(r1.amount, 0);
    end lost_card_fee;

    function check_cutting_fee (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is

        cursor c1 (
            p_acc_id     payment.acc_id%type,
            p_date_start date,
            p_date_end   date
        ) is
        select
            sum(amount) amount
        from
            payment a,
            account b
        where
                a.acc_id = p_acc_id
            and a.acc_id = b.acc_id
            and reason_code = 14
            and b.plan_code <> 401
            and b.account_type = 'HSA'
            and pay_date between p_date_start and p_date_end
        union
        select
            sum(amount) amount
        from
            fremont_bank_stmt a,
            account           b
        where
                b.acc_id = p_acc_id
            and a.acc_id = b.acc_id
            and pay_type = 14
            and b.plan_code = 401
            and b.account_type = 'HSA'
            and b.creation_date between p_date_start and p_date_end;

        r1 c1%rowtype;
    begin
        open c1(acc_id_in, date_start_in, date_end_in);
        fetch c1 into r1;
        close c1;
        return nvl(r1.amount, 0);
    end check_cutting_fee;
--  Balance in account
/*
FUNCTION acc_balance(
   acc_id_in IN ACCOUNT.acc_id%TYPE
  ,date_start_in IN DATE DEFAULT TRUNC(SYSDATE, 'cc')
  ,date_end_in IN DATE DEFAULT SYSDATE
) RETURN NUMBER
IS
  l_total NUMBER;
BEGIN
  FOR X IN (SELECT b.account_status
                  ,SUM(amount)  AMOUNT
              FROM balance_register A, ACCOUNT B
             WHERE a.acc_id = acc_id_in
              AND  B.ACCOUNT_TYPE = 'HSA'
              AND  a.acc_id = b.acc_id
              AND reason_mode NOT IN ('F','E','C','FP')
              AND TRUNC(fee_date) BETWEEN TRUNC(date_start_in)
                  AND DECODE(A.reason_mode ,'EP',TRUNC(date_end_in)+3, TRUNC(date_end_in))
              group by b.account_status,a.acc_id
            UNION
            SELECT  B.ACCOUNT_STATUS, to_number(A.AVAILABLE_BALANCE)
            FROM    metavante_card_balances A, ACCOUNT B
            WHERE   B.acc_id = acc_id_in
            AND     A.ACC_NUM = B.ACC_NUM
            AND     B.ACCOUNT_TYPE = 'HRA')
   LOOP
     IF x.account_status = 4 THEN
        l_total := x.amount;
     ELSIF  x.amount < 0 THEN
        l_total := x.amount;
     ELSE
        l_total := x.amount-20;
     END IF;
   END LOOP;
   RETURN NVL(l_total,0);
EXCEPTION
   WHEN OTHERS THEN
       RETURN 0;
     -- raise;
END acc_balance;
 */
    function get_hra_balance (
        acc_id_in     in account.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is
        l_total number := 0;
    begin
   --PC_LOG.LOG_ERROR('START_DATE',date_start_in);

        for x in (
            select/*+ index(A BALANCE_REGISTER_N8) */
                b.account_status,
                sum(amount) amount
            from
                balance_register          a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.acc_id = acc_id_in
                and b.account_type = 'HRA'
                and a.acc_id = b.acc_id
                and c.acc_id = b.acc_id
                and c.plan_type = a.plan_type
                and c.product_type = 'HRA'
                and trunc(c.plan_start_date) <= sysdate
                and trunc(c.plan_end_date) >= sysdate
                and trunc(fee_date) >= trunc(c.plan_start_date)
                and trunc(fee_date) <= trunc(c.plan_end_date)
                and c.status = 'A'
            group by
                b.account_status
        ) loop
            if x.account_status = 4 then
                l_total := x.amount;
            elsif x.amount < 0 then
                l_total := x.amount;
            else
                l_total := x.amount;
            end if;
        end loop;

        return l_total;
    end get_hra_balance;

    function get_hra_plan_year_balance (
        acc_id_in     in account.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is
        l_total number := 0;
    begin
   --PC_LOG.LOG_ERROR('START_DATE',date_start_in);

        for x in (
            select /*+ index(A BALANCE_REGISTER_N8) */
                b.account_status,
                sum(amount) amount
            from
                balance_register          a,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    a.acc_id = acc_id_in
                and b.account_type = 'HRA'
                and a.acc_id = b.acc_id
                and c.acc_id = b.acc_id
                and c.plan_type = a.plan_type
                and c.product_type = 'HRA'
                and trunc(c.plan_start_date) >= date_start_in
                and trunc(c.plan_end_date) <= date_end_in
                and trunc(fee_date) >= trunc(c.plan_start_date)
                and trunc(fee_date) <= trunc(c.plan_end_date)
                and c.status = 'A'
            group by
                b.account_status
        ) loop
            if x.account_status = 4 then
                l_total := x.amount;
            elsif x.amount < 0 then
                l_total := x.amount;
            else
                l_total := x.amount;
            end if;
        end loop;

        return l_total;
    end get_hra_plan_year_balance;

    function acc_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null,
        p_start_date   in date default null,
        p_end_date     in date default null
    ) return number is
        l_total        number;
        l_exists       varchar2(1) := 'N';
        l_account_type varchar2(10);   -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin

     -- Below For loop added by Swamy for Ticket#9912
        for j in (
            select
                account_type
            from
                account
            where
                acc_id = acc_id_in
        ) loop
            l_account_type := j.account_type;
        end loop;

        l_total := new_acc_balance(acc_id_in, date_start_in, date_end_in, l_account_type, p_plan_type,
                                   p_start_date, p_end_date);   --p_account_type replaced by L_ACCOUNT_TYPE by Swamy for Ticket#9912 on 10/08/2021


/*
     IF  p_account_type IN ('HRA','FSA') THEN
           FOR X IN ( SELECT c.annual_election, b.account_status
                        ,SUM(CASE WHEN C.PLAN_TYPE IN ('LPF','FSA') THEN
                             (CASE WHEN A.REASON_MODE= 'I' THEN 0 ELSE amount END )
                              ELSE
                             amount END )  AMOUNT
                      FROM balance_register A
                         , ACCOUNT B
                         , BEN_plan_ENROLLMENT_SETUP C
                     WHERE a.acc_id = acc_id_in
                      AND  B.ACCOUNT_TYPE IN ('HRA','FSA')
                      AND  a.acc_id = b.acc_id
                      AND  c.acc_id = b.acc_id
                      AND  c.plan_type = a.plan_type
                      AND  c.plan_type = p_plan_type
                      AND  TRUNC(c.plan_start_date) <= nvl(TRUNC(date_start_in),TRUNC(c.plan_start_date))
                      AND  TRUNC(c.plan_end_date)   >= nvl(TRUNC(date_end_in) ,TRUNC(c.plan_end_date))
                      AND  NVL(c.effective_end_date,sysdate)+nvl(c.runout_period_days,0)
                          + NVL(c.grace_period,0)+360  >= sysdate
                      AND  TRUNC(fee_date) >= TRUNC(c.plan_start_date)
                      AND  ((c.status = 'A')
                           or (c.status = 'I' AND TRUNC(c.plan_end_date)+nvl(c.runout_period_days,0)
                           + NVL(c.grace_period,0)+360   >= trunc(sysdate)))
                      AND  TRUNC(fee_date) >= TRUNC(nvl(nvl(p_start_date,date_start_in),c.plan_start_date))
                      AND TRUNC(fee_date) <= DECODE(A.reason_mode ,'EP', TRUNC(nvl(nvl(p_end_date,date_end_in)
                                                                        ,SYSDATE))
                                                         +3,  TRUNC(nvl(nvl(p_end_date,date_end_in),TRUNC(SYSDATE))))
                      group by c.annual_election, b.account_status  )
          LOOP
            l_exists := 'Y';
            IF p_plan_type IN ('FSA','LPF') THEN
               l_total := x.annual_election+x.amount;
            ELSE
               l_total := x.amount;
            END IF;
          END LOOP;

     ELSE
        FOR X IN (SELECT B.ACCOUNT_TYPE, b.account_status ,b.plan_code
                        ,SUM( amount  )  AMOUNT
                    FROM balance_register A, ACCOUNT B
                   WHERE a.acc_id = acc_id_in
                    AND  B.ACCOUNT_TYPE = 'HSA'
                    AND  a.acc_id = b.acc_id
                    AND  reason_mode NOT IN ('F','E','C','FP')
                    AND TRUNC(fee_date) BETWEEN TRUNC(NVL(date_start_in,SYSDATE))
                        AND DECODE(A.reason_mode ,'EP',TRUNC(NVL(date_end_in,sysdate))+3, TRUNC(NVL(date_end_in,sysdate)))
                    group by b.account_status,a.acc_id,B.ACCOUNT_TYPE,b.plan_code
                  )
         LOOP
           IF x.account_status = 4 THEN
              l_total := x.amount;
           ELSIF  x.amount < 0 THEN
              l_total := x.amount;
           ELSE
              l_total := x.amount-PC_PLAN.get_minimum(x.plan_code); --6588 (20$ should not be deducyed fo E-HSA )
           END IF;
         END LOOP;
    END IF;
    IF p_account_type IN ('HRA','FSA')
    AND l_exists = 'N' AND NVL(l_total,0) = 0
    THEN
               FOR X IN ( SELECT b.account_status
                       , c.annual_election   AMOUNT
                      FROM  ACCOUNT B
                         , BEN_plan_ENROLLMENT_SETUP C
                     WHERE b.acc_id = acc_id_in
                      AND  B.ACCOUNT_TYPE IN ('HRA','FSA')
                       AND  c.acc_id = b.acc_id
                       AND  c.plan_type = p_plan_type
                       AND  c.plan_type IN ('LPF','FSA')
                       AND  NVL(c.effective_end_date,sysdate)+nvl(c.runout_period_days,0)+ NVL(c.grace_period,0)+180  >= sysdate
                       AND  TRUNC(c.plan_start_date) >= TRUNC(NVL(date_start_in,c.plan_start_date))
                       AND  TRUNC(c.plan_end_date)   <= TRUNC(NVL(date_end_in,c.plan_end_date))
                      -- AND  TRUNC(c.plan_start_date) <= TRUNC(SYSDATE)
                      --AND  TRUNC(c.plan_end_date)   >= TRUNC(SYSDATE)
                       AND  ((c.status = 'A')
                           or (c.status = 'I' AND TRUNC(c.plan_end_date)+nvl(c.runout_period_days,0)
                           + NVL(c.grace_period,0) +180  >= trunc(sysdate)))

                      )
          LOOP
             IF x.account_status = 4 THEN
              l_total := 0;

           ELSE
              l_total := x.amount;
           END IF;
          END LOOP;
    END IF;
    */

        return nvl(l_total, 0);
    exception
        when others then
            return 0;
     -- raise;
    end acc_balance;

    function current_hrafsa_balance (
        acc_id_in          in account.acc_id%type,
        date_start_in      in date default trunc(sysdate, 'cc'),
        date_end_in        in date default sysdate,
        plan_start_date_in in date default trunc(sysdate, 'YYYY'),
        plan_end_date_in   in date default add_months(
            trunc(sysdate, 'YYYY'),
            12
        ),
        p_plan_type        in varchar2 default null
    ) return number is
        l_total        number;
        l_exists       varchar2(1) := 'N';
        l_account_type varchar2(30);
    begin
        l_account_type := get_account_type(acc_id_in);
        l_total := new_acc_balance(acc_id_in, plan_start_date_in, plan_end_date_in, l_account_type, p_plan_type,
                                   date_start_in, date_end_in);

         /*    FOR X IN ( SELECT c.annual_election, b.account_status
                       ,SUM(CASE WHEN C.PLAN_TYPE IN ('HRA','LPF','FSA') THEN
                           DECODE(A.REASON_MODE,'I',0,amount)
                        ELSE
                           amount END )  AMOUNT
                      FROM balance_register A
                         , ACCOUNT B
                         , BEN_plan_ENROLLMENT_SETUP C
                     WHERE a.acc_id = acc_id_in
                      AND  B.ACCOUNT_TYPE IN ('HRA','FSA')
                      AND  a.acc_id = b.acc_id
                      AND  c.acc_id = b.acc_id
                      AND  c.plan_type = a.plan_type
                      AND  c.plan_type = p_plan_type
                      AND  TRUNC(c.plan_start_date) <= nvl(TRUNC(plan_start_date_in),TRUNC(c.plan_start_date))
                      AND  TRUNC(c.plan_end_date)   >= nvl(TRUNC(plan_end_date_in) ,TRUNC(c.plan_end_date))
                      AND  NVL(c.effective_end_date,sysdate) >= sysdate
                      AND  TRUNC(fee_date) >= TRUNC(c.plan_start_date)
                      AND  c.status = 'A'
                     -- AND  TRUNC(fee_date) >= nvl(TRUNC(date_start_in),TRUNC(c.plan_start_date))
                      AND TRUNC(fee_date) <= DECODE(A.reason_mode ,'EP', nvl(TRUNC(date_end_in) ,TRUNC(SYSDATE))
                                                         +3,  nvl(TRUNC(date_end_in) ,TRUNC(SYSDATE)) )
                      group by c.annual_election, b.account_status  )
          LOOP
            l_exists := 'Y';
            IF p_plan_type IN ('HRA','FSA','LPF') THEN
               l_total := x.annual_election+x.amount;
            ELSE
               l_total := x.amount;
            END IF;
          END LOOP;
         pc_log.log_error('ACC_BALANCE','Exists '||l_exists||', total '||NVL(l_total,0) );
    IF   l_exists = 'N' AND NVL(l_total,0) = 0
    THEN
               FOR X IN ( SELECT b.account_status
                       , c.annual_election   AMOUNT
                      FROM  ACCOUNT B
                         , BEN_plan_ENROLLMENT_SETUP C
                     WHERE b.acc_id = acc_id_in
                      AND  B.ACCOUNT_TYPE IN ('HRA','FSA')
                       AND  c.acc_id = b.acc_id
                       AND  c.plan_type = p_plan_type
                       AND  c.plan_type IN ('HRA','HR5','HRP','LPF','FSA')
                       AND  NVL(c.effective_end_date,sysdate) >= sysdate
                      AND  TRUNC(c.plan_start_date) = TRUNC(plan_start_date_in)
                      AND  TRUNC(c.plan_end_date)   = TRUNC(plan_end_date_in)
                      AND  c.status = 'A'  )
          LOOP
             IF x.account_status = 4 THEN
              l_total := 0;

           ELSE
              l_total := x.amount;
           END IF;
          END LOOP;
    END IF;*/

        return nvl(l_total, 0);
    exception
        when others then
            return 0;
     -- raise;
    end current_hrafsa_balance;

    function current_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null
    ) return number is
        l_total        number;
        l_exists       varchar2(1) := 'N';
        l_account_type varchar2(10);    -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin
    -- Added by Swamy for Ticket#9912 on 10/08/2021
        for j in (
            select
                account_type
            from
                account
            where
                acc_id = acc_id_in
        ) loop
            l_account_type := j.account_type;
        end loop;

        if p_account_type in ( 'HRA', 'FSA' ) then
            for x in (
                select /*+ index(A BALANCE_REGISTER_N7) */
                    c.annual_election,
                    b.account_status,
                    sum(
                        case
                            when c.plan_type in('LPF', 'FSA') then
                                decode(a.reason_mode, 'I', 0, amount)
                            else
                                amount
                        end
                    ) amount
                from
                    balance_register          a,
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        a.acc_id = acc_id_in
                    and b.account_type in ( 'HRA', 'FSA' )
                    and a.acc_id = b.acc_id
                    and c.acc_id = b.acc_id
                    and c.plan_type = a.plan_type
                    and c.plan_type = p_plan_type
                    and trunc(c.plan_start_date) <= nvl(
                        trunc(date_start_in),
                        trunc(c.plan_start_date)
                    )
                    and trunc(c.plan_end_date) >= nvl(
                        trunc(date_end_in),
                        trunc(c.plan_end_date)
                    )
                    and nvl(c.effective_end_date, sysdate) + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0) >= sysdate
                    and trunc(fee_date) >= trunc(c.plan_start_date)
                    and ( ( c.status = 'A' )
                          or ( c.status = 'I'
                               and trunc(c.plan_end_date) + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0) >= trunc(sysdate) )
                               )
                    and trunc(fee_date) >= nvl(
                        trunc(date_start_in),
                        trunc(c.plan_start_date)
                    )
                    and trunc(fee_date) <= decode(a.reason_mode,
                                                  'EP',
                                                  nvl(
                                                                   trunc(date_end_in),
                                                                   trunc(sysdate)
                                                               ) + 3,
                                                  nvl(
                                                                   trunc(date_end_in),
                                                                   trunc(sysdate)
                                                               ))
                group by
                    c.annual_election,
                    b.account_status
            ) loop
                l_exists := 'Y';
                if p_plan_type in ( 'FSA', 'LPF' ) then
                    l_total := x.annual_election + x.amount;
                else
                    l_total := x.amount;
                end if;

            end loop;

        else
      /*  FOR X IN (SELECT B.ACCOUNT_TYPE, b.account_status
                        ,SUM(amount  )  AMOUNT
                    FROM balance_register A, ACCOUNT B
                   WHERE a.acc_id = acc_id_in
                    AND  B.ACCOUNT_TYPE = 'HSA'
                    AND  a.acc_id = b.acc_id
                    AND reason_mode NOT IN ('F','E','C','FP')
                    AND TRUNC(fee_date) BETWEEN TRUNC(NVL(date_start_in,SYSDATE))
                        AND DECODE(A.reason_mode ,'EP',TRUNC(NVL(date_end_in,SYSDATE))+3, TRUNC(NVL(date_end_in,SYSDATE)))
                    group by B.ACCOUNT_TYPE, b.account_status
                  )*/
            for x in (
                select
                    sum(amount) amount
                from
                    (
                        select /*+ index(A BALANCE_REGISTER_N7) */
                            b.account_type,
                            b.account_status,
                            sum(amount) amount
                        from
                            balance_register a,
                            account          b
                        where
                                a.acc_id = acc_id_in
                            and b.account_type = l_account_type    --'HSA'   -- Replaced HSA by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                            and a.acc_id = b.acc_id
                            and reason_mode not in ( 'F', 'E', 'C', 'FP', 'EP' )
                            and a.reason_mode <> 'EP'
                            and trunc(fee_date) between trunc(nvl(date_start_in, sysdate)) and trunc(nvl(date_end_in, sysdate))
                        group by
                            b.account_status,
                            a.acc_id,
                            b.account_type
                        union
                        select
                            b.account_type,
                            b.account_status,
                            sum(amount) amount
                        from
                            balance_register a,
                            account          b
                        where
                                a.acc_id = acc_id_in
                            and b.account_type = l_account_type    --'HSA'   -- Replaced HSA by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                            and a.acc_id = b.acc_id
                            and a.reason_mode = 'EP'
                            and trunc(fee_date) between trunc(nvl(date_start_in, sysdate)) and trunc(nvl(date_end_in, sysdate))--+3 --SK Commneted +3 on 09/23 to avoid including pending disbursements from next month
                        group by
                            b.account_status,
                            a.acc_id,
                            b.account_type
                    )
            ) loop
                l_total := x.amount;
            end loop;
        end if;

        if
            p_account_type in ( 'HRA', 'FSA' )
            and l_exists = 'N'
            and nvl(l_total, 0) = 0
        then
            for x in (
                select
                    b.account_status,
                    c.annual_election amount
                from
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        b.acc_id = acc_id_in
                    and b.account_type in ( 'HRA', 'FSA' )
                    and c.acc_id = b.acc_id
                    and c.plan_type = p_plan_type
                    and c.plan_type in ( 'LPF', 'FSA' )
                    and nvl(c.effective_end_date, sysdate) + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0) >= sysdate
                    and trunc(c.plan_start_date) >= trunc(date_start_in)
                    and trunc(c.plan_end_date) <= trunc(date_end_in)
                      -- AND  TRUNC(c.plan_start_date) <= TRUNC(SYSDATE)
                      --AND  TRUNC(c.plan_end_date)   >= TRUNC(SYSDATE)
                    and ( ( c.status = 'A' )
                          or ( c.status = 'I'
                               and trunc(c.plan_end_date) + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0) >= trunc(sysdate) )
                               )
            ) loop
                if x.account_status = 4 then
                    l_total := 0;
                else
                    l_total := x.amount;
                end if;
            end loop;
        end if;

        return nvl(l_total, 0);
    exception
        when others then
            return 0;
     -- raise;
    end current_balance;
--  Balance in DEBIT CARD
--  Balance in DEBIT CARD
    function acc_balance_card (
        acc_id_in     in account.acc_id%type  -- ???? ?????? ???? - ?? ?? ????? ??????
        ,
        pers_id_in    in account.pers_id%type default null  -- ???? ??????? - ?? ?????? ?? ?? ?????
        ,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is
        l_total number;
    begin
        select
            least(c.current_card_value,
                  pc_account.new_acc_balance(b.acc_id, '01-JAN-2004', sysdate, 'HSA'))
        into l_total
        from
            account    b,
            card_debit c
        where
                b.acc_id = acc_id_in
            and c.card_id = b.pers_id;

        return nvl(l_total, 0);
    exception
        when others then
            return 0;
    end acc_balance_card;

    function is_account_open (
        acc_id_in in account.acc_id%type,
        date_in   in date default sysdate
    ) return number is
        ret number := null;
    begin
        for x in (
            select
                0 status
            from
                account
            where
                    acc_id = acc_id_in
                and account_status in ( 1, 5 )
        ) loop
            ret := x.status;
        end loop;

        return ret;
    end is_account_open;

    function is_account_close (
        acc_id_in in account.acc_id%type,
        date_in   in date default sysdate
    ) return number is
    begin
        return 1 - pc_account.is_account_open(acc_id_in, date_in);
    end is_account_close;

    procedure recalc_fees (
        acc_id_in in account.acc_id%type,
        date_in   in date default sysdate
    ) is
    begin
        delete from payment
        where
                acc_id = acc_id_in
            and pay_date > date_in
            and reason_code in ( 1, 2 )
            and note like 'Generate%';

        pc_fin.take_fees(acc_id_in, date_in);
    end recalc_fees;

    procedure close_account (
        acc_id_in        in account.acc_id%type,
        date_in          in date  --  ???????? ???????????????? ?????????? ??????????
        ,
        note_in          in account.note%type,
        closed_reason_in in varchar2 default 'MEMBER_REQUEST'
    ) is
/*
13.07.2006 mal  -balance_card   +Account Termination Fee
*/
        temp_v            number;
        v_plan_code       number;
        v_current_balance number;
        v_income_count    number;
        v_entrp_id        number;
    begin

/* no need more to check balance_card - Mike 12.07.2006
 cc :=  Pc_Account.acc_balance_card(acc_id_in);
 IF cc <> 0 THEN
   RAISE_APPLICATION_ERROR( -20001,
    'Can not close account with non-zero Debit Card Balance '||cc);
 END IF;
*/

        v_current_balance := pc_account.current_balance(acc_id_in);
        update account
        set
            end_date = date_in  -- date close
            ,
            account_status = 4,
            account_reopen_date = null,
            note = nvl(note_in, note),
            closed_reason = closed_reason_in
        where
            acc_id = acc_id_in;  -- this acc

/* 05/08/2012: as per shavee's compliant we should not change complete flag as per business
 update account
  set    complete_flag = 0 -- if it is non funded , make it incomplete setup as it has to be
                           -- that way
 where   ACC_ID  = acc_id_in
 and NOT EXISTS ( SELECT * FROM INCOME WHERE INCOME.ACC_ID  = ACCOUNT.ACC_ID
                  and acc_id= acc_id_in);
 **/
-- have the account Termination Fee?
        for x in (
            select
                b.pers_id,
                b.entrp_id
            from
                account a,
                person  b
            where
                    a.acc_id = acc_id_in
                and b.pers_id = a.pers_id
            union
            select
                dep.pers_id,
                b.entrp_id
            from
                account a,
                person  b,
                person  dep
            where
                    a.acc_id = acc_id_in
                and b.pers_id = a.pers_id
                and a.pers_id = dep.pers_main
        ) loop
            update card_debit
            set
                status = 3
            where
                    card_id = x.pers_id
                and status <> 3;

            v_entrp_id := x.entrp_id;
        end loop;

        select
            count(1)
        into temp_v
        from
            payment
        where
                acc_id = acc_id_in
            and reason_code = 15
            and amount > 0;

/** Vanitha Changes **/
        if temp_v = 0 then -- have not, will insert

            temp_v := pc_plan.fcustom_fee_value(v_entrp_id, 15);
            if temp_v is null then
                select
                    fee_amount,
                    plan_code
                into
                    temp_v,
                    v_plan_code
                from
                    plan_fee
                where
                        fee_code = 15
                    and plan_code = (
                        select
                            plan_code
                        from
                            account
                        where
                            acc_id = acc_id_in
                    );

            end if;

            if nvl(temp_v, 0) > 0 then
                if v_current_balance > 0 then
                    insert into payment (
                        change_num,
                        acc_id,
                        pay_date,
                        amount,
                        reason_code,
                        note,
                        cur_bal
                    ) values ( change_seq.nextval,
                               acc_id_in,
                               date_in,
                               least(
                                   nvl(temp_v, 20),
                                   v_current_balance
                               ),
                               15,
                               'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss'),
                               v_current_balance - nvl(temp_v, 20) );

                else
                    select
                        count(1)
                    into v_income_count
                    from
                        income
                    where
                        acc_id = acc_id_in;

                    if v_income_count = 0 then
                        null;
                    else
                        insert into payment (
                            change_num,
                            acc_id,
                            pay_date,
                            amount,
                            reason_code,
                            note,
                            cur_bal
                        ) values ( change_seq.nextval,
                                   acc_id_in,
                                   date_in,
                                   nvl(temp_v, 20),
                                   15,
                                   'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss'),
                                   v_current_balance - nvl(temp_v, 20) );

                    end if;

                end if;
            end if;

        end if;

        pc_account.recalc_fees(acc_id_in, date_in);
    end close_account;

    procedure reopen_account (
        acc_id_in in account.acc_id%type,
        date_in   in date default trunc(sysdate),
        note_in   in account.note%type default null
    ) is
/* 30.06.2006 mal
*/
        d1        date;
        l_pers_id number;
    begin
        pc_log.log_error('reopen_account', 'acc_id_in' || acc_id_in);
        select
            end_date,
            pers_id
        into
            d1,
            l_pers_id
        from
            account
        where
            acc_id = acc_id_in;

        if d1 is not null then

/*   As per discussion with david rosenfeld on 02/28/2008 , it is decided that
     we do not remove the account termination fee that has been already charged
         DELETE FROM PAYMENT
     WHERE ACC_ID = acc_id_in
       AND REASON_CODE = 15;  -- Account Termination Fee
*/
         /** Account Reopening Fee Changes */

            insert into payment (
                change_num,
                acc_id,
                pay_date,
                amount,
                reason_code,
                note,
                cur_bal
            )
                select
                    change_seq.nextval,
                    a.acc_id,
                    date_in,
                    b.fee_amount,
                    18,
                    'Reopening Fee ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss'),
                    0
                from
                    account  a,
                    plan_fee b
                where
                        a.plan_code = b.plan_code
                    and a.acc_id = acc_id_in
                    and b.fee_code = 21
                    and trunc(a.end_date) - trunc(sysdate) >= 90;

            update account
            set
                end_date = null,
                account_status = 1,
                suspended_date = null,
                account_reopen_date = date_in,
                note = 'Was closed '
                       || to_char(d1)
                       || '. Reopen '
                       || to_char(date_in)
                       || '.'
                       || note_in
                       || note,
                closed_reason = null
            where
                    acc_id = acc_id_in
                and account_status = 4;

     /** Vanitha Changes **/
            delete from fremont_bank_stmt
            where
                    acc_id = acc_id_in
                and pay_type = 1;
         /** When the account is reopend, will reopen the card too,
             card can be reopened by setting status to unsuspend pending **/

            for x in (
                select
                    b.pers_id
                from
                    account a,
                    person  b,
                    person  dep
                where
                        a.acc_id = acc_id_in
                    and b.pers_id = a.pers_id
                union
                select
                    dep.pers_id
                from
                    account a,
                    person  b,
                    person  dep
                where
                        a.acc_id = acc_id_in
                    and b.pers_id = a.pers_id
                    and a.pers_id = dep.pers_main
            ) loop
                update card_debit
                set
                    status = 10
                where
                    card_id = x.pers_id;

            end loop;

            pc_account.recalc_fees(acc_id_in, date_in);
        else
            null; -- was open, no need re-open
        end if;

    end reopen_account;

    procedure change_plan (
        acc_id_in in account.acc_id%type,
        date_in   in date,
        plan_in   in account.plan_code%type,
        note_in   in account.note%type
    ) is

        cursor c1 is
        select
            plan_sign,
            fsetup,
            fmonth
        from
            plan_fee_v
        where
            plan_code = plan_in;

        r1             c1%rowtype;
        pid            account.pers_id%type;
        v_setup        number;
        v_maint        number;
        v_plan_sign    varchar2(10);
        v_account_type varchar2(30);
    begin
        v_account_type := pc_account.get_account_type(acc_id_in);
        if v_account_type = 'HSA' then
            pid := pc_person.pers_id_from_acc_id(acc_id_in);
            v_maint := pc_person.fee_maint_dflt(pid, plan_in);
            open c1;
            fetch c1 into r1;
            close c1;
            v_setup := r1.fsetup;
            v_plan_sign := r1.plan_sign;
            update account
            set
                plan_code = plan_in,
                fee_maint = v_maint,
                note = nvl(note_in, note),
                plan_change_date = date_in,
                last_update_date = sysdate,
                last_updated_by = v('USER_ID')
            where
                    acc_id = acc_id_in
                and account_type = 'HSA';

 --    IF v_setup = 0 THEN
 --        DELETE FROM PAYMENT
 --        WHERE  REASON_CODE IN (1,2)
 --        AND    ACC_ID = acc_id_in;
 --     ELSE
            update payment
            set
                amount = v_setup,
                last_updated_date = sysdate,
                last_updated_by = v('USER_ID')
            where
                    reason_code = 1
                and acc_id = acc_id_in
                and pay_date > date_in;

            update payment
            set
                amount = v_maint,
                last_updated_date = sysdate,
                last_updated_by = v('USER_ID')
            where
                    reason_code = 2
                and acc_id = acc_id_in
                and pay_date > date_in;
    --  END IF;

            pc_account.recalc_fees(acc_id_in, date_in);
        end if;

        if v_account_type = 'POP' then
            update account
            set
                plan_code = plan_in,
                note = nvl(note_in, note),
                plan_change_date = date_in,
                last_update_date = sysdate,
                last_updated_by = v('USER_ID')
            where
                    acc_id = acc_id_in
                and account_type = 'POP';

        end if;

    end change_plan;

    procedure upgrade_account (
        acc_id_in in account.acc_id%type,
        date_in   in date,
        plan_in   in account.plan_code%type,
        note_in   in account.note%type,
        p_user_id in number default 0
    ) is
        pid     account.pers_id%type;
        v_setup number;
        v_maint number;
    begin
        pid := pc_person.pers_id_from_acc_id(acc_id_in);
        v_maint := pc_person.fee_maint_dflt(pid, plan_in);

 --  v_maint := r1.FMONTH * 2;
        update account
        set
            plan_code = plan_in
    --  , FEE_SETUP = v_setup
            ,
            plan_change_date = sysdate,
            fee_maint = v_maint,
            note = nvl(note_in, note),
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                acc_id = acc_id_in
            and account_type = 'HSA';

        pc_account.recalc_fees(acc_id_in, date_in);
    end upgrade_account;

    function year_income (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'yyyy') -- any date in year
        ,
        date_end_in   in date default sysdate -- no need now, spare for future.
    ) return number is
/*
Total Receipts for the Year you calculate as
All Subscriber receipts for the calendar year (but not the Interest)
plus All Employer receipts for the year
minus Receipts with the reason Contribution for the previous year but
recorded in this calendar year.
20.03.2006
> May I exclude Rollover from Total Receipts for the Year ?
Yes, Kolya. Looks like a logical thing to do.
*/
        d1  date := trunc(date_start_in, 'yyyy'); -- 01.01.year
        d1n date := add_months(d1, 12);           -- 01.01.next year
        d2  date := d1n - 1;              -- 31.12.year
        d2n date := add_months(d2, 12);   -- 31.12.next year
        cursor c1 is
        select
            sum(amount + nvl(amount_add, 0)) as tot
        from
            (
                select
                    a.acc_id,
                    fee_code,
                    fee_date,
                    amount,
                    amount_add
                from
                    income  a,
                    account b
                where
                        a.acc_id = acc_id_in
                    and a.acc_id = b.acc_id
                    and nvl(fee_code, 0) not in ( 5, 7, 18, 10, 30,
                                                  130, 50, 8 ) --exclude Contribution for previous year and Interest,hsa transfer, rollover, initial contribution for previous year
                    and trunc(fee_date) >= case
                                               when trunc(fee_date) <= trunc(b.start_date)
                                                    and trunc(b.start_date) = d1 then
                                                   least(
                                                       trunc(fee_date),
                                                       d1
                                                   )
                                               else
                                                   d1
                                           end
                    and trunc(fee_date) <= d2
   -- this year
                union all
                select
                    acc_id,
                    fee_code,
                    fee_date,
                    amount,
                    amount_add
                from
                    income
                where
                        acc_id = acc_id_in
                    and fee_code in ( 7, 10, 130 ) -- Contribution for previous year, made in next year = our year
                    and fee_date between d1n and d2n -- next year
            );

        r1  c1%rowtype;
    begin
        open c1;
        fetch c1 into r1;
        close c1;
        return nvl(r1.tot, 0);
    end year_income;

    function get_initial_contribution (
        acc_id_in account.acc_id%type
    ) return number is
        l_amount number := 0;
    begin
        for x in (
            select
                sum(initial_contrib) initial_contrib
            from
                (
                    select
                        nvl(
                            sum(nvl(amount, 0) + nvl(amount_add, 0)),
                            0
                        ) initial_contrib
                    from
                        income a
                    where
                            a.fee_code = 3
                        and a.acc_id = acc_id_in
                    union all
                    select
                        + nvl(amount, 0) + nvl(amount_add, 0)
                    from
                        (
                            select
                                min(change_num) change_num
                            from
                                income
                            where
                                    acc_id = acc_id_in
                                and nvl(amount, 0) + nvl(amount_add, 0) > 0
                        )      a,
                        income b
                    where
                            b.change_num = a.change_num
                        and b.fee_code <> 3
                        and b.acc_id = acc_id_in
                )
        ) loop
            l_amount := x.initial_contrib;
        end loop;

        return l_amount;
    end get_initial_contribution;

    function get_broker (
        p_broker_id in number
    ) return varchar2 is
        l_broker_name varchar2(3200);
    begin
        for x in (
            select
                a.agency_name name
            from
                broker a,
                person b
            where
                    a.broker_id = b.pers_id
                and a.broker_id = p_broker_id
        ) loop
            l_broker_name := x.name;
        end loop;

        return l_broker_name;
    end get_broker;

    function get_carrier (
        p_carrier_id in number
    ) return varchar2 is
        l_carrier_name varchar2(3200);
    begin
        for x in (
            select
                carrier_name
            from
                carriers_v
            where
                carrier_id = p_carrier_id
        ) loop
            l_carrier_name := x.carrier_name;
        end loop;

        return l_carrier_name;
    end get_carrier;
/*** Enrollment is validated when the enrollment is uploaded
     from excel/webform
***/
    function validate_enrollment (
        p_acc_id in number
    ) return varchar2 is
        l_error_message varchar2(3200) := null;
    begin
        for x in (
            select
                drivlic,
                passport,
                address,
                city,
                state,
                zip,
                pc_account.new_acc_balance(b.acc_id, '01-JAN-2004', sysdate, 'HSA') balance,
                c.insur_id,
                c.start_date                                                        eff_date,
                b.start_date,
                b.complete_flag,
                b.account_status,
                nvl(b.signature_on_file, 'N')                                       signature_on_file,
                b.account_type
            from
                person  a,
                account b,
                insure  c
            where
                    a.pers_id (+) = b.pers_id
                and c.pers_id (+) = a.pers_id
                and b.acc_id = p_acc_id
        ) loop
            if
                (
                    x.drivlic is null
                    and x.passport is null
                )
                and l_error_message is null
                and x.account_type = 'HSA'
            then
                l_error_message := 'Account cannot be setup complete because Driver License/Passport information is missing';
            end if;

            if
                ( nvl(x.address, '0') = '0'
                or nvl(x.city, '0') = '0'
                or nvl(x.state, '0') = '0'
                or nvl(x.zip, '0') = '0' )
                and l_error_message is null
            then
                l_error_message := 'Account cannot be setup complete because Address information is incomplete';
            end if;

            if
                x.insur_id is null
                and l_error_message is null
                and x.account_type = 'HSA'
            then
                l_error_message := 'Account cannot be setup complete because insurance carrier information is missing';
            end if;

        end loop;

        return l_error_message;
    end validate_enrollment;

    function validate_subscriber (
        p_acc_id in number,
        p_setup  in number,
        p_status in number
    ) return varchar2 is
        l_error_message varchar2(3200) := null;
    begin
        for x in (
            select
                drivlic,
                passport,
                address,
                city,
                state,
                zip,
                pc_account.new_acc_balance(b.acc_id, '01-JAN-2004', sysdate, 'HSA') balance,
                c.insur_id,
                c.start_date                                                        eff_date,
                b.start_date,
                b.complete_flag,
                b.account_status,
                nvl(b.signature_on_file, 'N')                                       signature_on_file,
                b.account_type,
                b.verified_by,
                nvl(b.id_verified, 'N')                                             id_verified
            from
                person  a,
                account b,
                insure  c
            where
                    a.pers_id (+) = b.pers_id
                and c.pers_id (+) = a.pers_id
                and b.acc_id = p_acc_id
        ) loop
            if x.signature_on_file = 'Y' then
                if p_status = 1 then

              -- 01/18/2018 : Vanitha: As per the request from Duarte/Shavee Driver License is no longer mandatory
              -- for HSA account activation
             /*  IF (X.DRIVLIC IS NULL AND X.PASSPORT IS NULL)  AND L_ERROR_MESSAGE IS NULL
               AND X.ACCOUNT_TYPE= 'HSA'
               THEN
                   L_ERROR_MESSAGE := 'Account cannot be setup complete because Driver License/Passport information is missing';
               END IF;*/
                    if
                        ( nvl(x.address, '0') = '0'
                        or nvl(x.city, '0') = '0'
                        or nvl(x.state, '0') = '0'
                        or nvl(x.zip, '0') = '0' )
                        and l_error_message is null
                    then
                        l_error_message := 'Account cannot be setup complete because Address information is incomplete';
                    end if;

                    if
                        x.insur_id is null
                        and l_error_message is null
                        and x.account_type = 'HSA'
                    then
                        l_error_message := 'Account cannot be setup complete because insurance carrier information is missing';
                    end if;
             /*  IF X.ID_VERIFIED = 'N'  AND L_ERROR_MESSAGE IS NULL
               AND X.ACCOUNT_TYPE= 'HSA'
               THEN
                  L_ERROR_MESSAGE := 'Account cannot be setup complete because of pending ID verification';
               END IF;*/

                end if;
-- we want manual enrollments without funds to get updated to setup complete. sk 03_16_2018.
           /* IF P_STATUS = 1 AND x.ACCOUNT_STATUS = 3 AND X.BALANCE <= 0  AND L_ERROR_MESSAGE IS NULL
            AND X.ACCOUNT_TYPE= 'HSA'
            THEN
            L_ERROR_MESSAGE := 'Account cannot be activated, because there is not enough balance';
            END IF;*/
                if
                    p_status = 1
                    and x.account_status = 3
                    and x.eff_date > trunc(sysdate)
                    and l_error_message is null
                then
                    l_error_message := 'Account cannot be activated, insurance effective date is '
                                       || to_char(x.eff_date, 'mm/dd/yyyy');
                end if;

                if
                    p_status = 1
                    and x.account_status = 3
                    and x.start_date > trunc(sysdate)
                    and l_error_message is null
                then
                    l_error_message := 'Account cannot be activated, account effective date is '
                                       || to_char(x.start_date, 'mm/dd/yyyy');
                end if;

                if
                    p_setup = 0
                    and p_status = 1
                    and l_error_message is null
                    and x.account_type = 'HSA'
                then
                    l_error_message := 'Account cannot be activated, because account is not setup complete';
                end if;

            else
                if x.account_type = 'HSA' then
                    l_error_message := 'Validation will be done only after we have the signature on file ';
                end if;
            end if;
        end loop;

        return l_error_message;
    end;

    function check_online_account (
        p_acc_id in number
    ) return varchar2 is
        l_return_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                'Y' flag
            from
                online_enrollment
            where
                    acc_id = p_acc_id
                and entrp_id is not null
        ) loop
            l_return_flag := x.flag;
        end loop;

        return l_return_flag;
    end check_online_account;

    procedure reset_card_status is
    begin
        null;
    end reset_card_status;

    function get_employer_status (
        entrp_id_in   in number,
        start_date_in in varchar2,
        end_date_in   in varchar2
    ) return varchar2 is
        l_status varchar2(30);
    begin
        if entrp_id_in is null then
            l_status := 'New';
        else
            for x in (
                select
                    ( (
                        select
                            min(check_date)
                        from
                            employer_deposits a
                        where
                            a.entrp_id = account.entrp_id
                    ) )                                  reg_date,
                    to_date(start_date_in, 'MM/DD/YYYY') start_date,
                    to_date(end_date_in, 'MM/DD/YYYY')   end_date
                from
                    account
                where
                        entrp_id = entrp_id_in
                    and account_type = 'HSA'
                union
                select
                    start_date,
                    to_date(start_date_in, 'MM/DD/YYYY') start_date,
                    to_date(end_date_in, 'MM/DD/YYYY')   end_date
                from
                    account
                where
                        entrp_id = entrp_id_in
                    and account_type <> 'HSA'
            ) loop
                if ( x.reg_date is null
                     or (
                    start_date_in is not null
                    and x.reg_date + 90 > x.end_date
                )
                or (
                    start_date_in is not null
                    and x.reg_date + 90 <= x.start_date
                    and x.reg_date + 90 >= x.end_date
                )
                or x.reg_date + 90 >= sysdate ) then
                    l_status := 'New';
                else
                    l_status := 'Existing';
                end if;
            end loop;
        end if;

        return l_status;
    end;

    function get_salesrep (
        broker_id_in in number
    ) return varchar2 is
        l_salesrep_name varchar2(320);
    begin
        for x in (
            select
                b.name
            from
                broker   a,
                salesrep b
            where
                    a.salesrep_id = b.salesrep_id
                and a.broker_id = broker_id_in
        ) loop
            l_salesrep_name := x.name;
        end loop;

        return l_salesrep_name;
    end;
/*Sk Added on 11/09/2023*/
    function get_employer_name (
        acc_id_in in number
    ) return varchar2 is
        l_entrp_name varchar2(320);
    begin
        for x in (
            select
                b.name
            from
                account    a,
                enterprise b
            where
                    a.entrp_id = b.entrp_id
                and a.acc_id = acc_id_in
        ) loop
            l_entrp_name := x.name;
        end loop;

        return l_entrp_name;
    end;

    function get_person_name (
        acc_id_in in number
    ) return varchar2 is
        l_person_name varchar2(320);
    begin
        for x in (
            select
                b.first_name
                || ' '
                || b.last_name as name
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and a.acc_id = acc_id_in
        ) loop
            l_person_name := x.name;
        end loop;

        return l_person_name;
    end;

    function get_salesrep_id (
        p_pers_id  in number,
        p_entrp_id in number
    ) return number is
        l_salesrep_id number;
    begin
        for x in (
            select
                salesrep_id
            from
                account
            where
                entrp_id = p_entrp_id
            union
            select
                salesrep_id
            from
                account
            where
                pers_id = p_pers_id
        ) loop
            l_salesrep_id := x.salesrep_id;
        end loop;

        return l_salesrep_id;
    end;

    function get_salesrep_name (
        sales_rep_in in number
    ) return varchar2 is
        l_salesrep_name varchar2(320);
    begin
        for x in (
            select
                b.name
            from
                salesrep b
            where
                b.salesrep_id = sales_rep_in
        ) loop
            l_salesrep_name := x.name;
        end loop;

        return l_salesrep_name;
    end get_salesrep_name;

    function fee_bucket_balance (
        acc_id_in     in account.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number is
        l_total number;
    begin
        select /*+ index(BALANCE_REGISTER_N8) */
            sum(amount)
        into l_total
        from
            balance_register a
        where
                acc_id = acc_id_in
            and reason_mode in ( 'F', 'FP' )
            and trunc(fee_date) between date_start_in and date_end_in;

        return nvl(l_total, 0);
    exception
        when others then
            return 0;
    end fee_bucket_balance;

    function outside_inv_balance (
        acc_id_in   account.acc_id%type,
        date_end_in in date default sysdate
    ) return number is
        l_transfer_amt number := 0;
    begin
        select
            sum(i.invest_amount)
        into l_transfer_amt
        from
            (
                select
                    a.acc_id,
                    a.investment_id,
                    max(b.transfer_id) transfer_id
                from
                    investment      a,
                    invest_transfer b
                where
                        a.investment_id = b.investment_id
                    and a.acc_id = acc_id_in
                    and trunc(b.invest_date) <= trunc(date_end_in)
                group by
                    a.acc_id,
                    a.investment_id
            )               x,
            account         b,
            invest_transfer i
        where
                x.acc_id = acc_id_in
            and x.acc_id = b.acc_id
            and i.transfer_id = x.transfer_id
            and x.investment_id = i.investment_id
            and trunc(i.invest_date) <= trunc(date_end_in);

        return nvl(l_transfer_amt, 0);
    exception
        when others then
            return 0;
    end;
/** Broker assignment is done from Account (5)
    and employer ***/
    procedure assign_broker (
        p_broker_id      in number,
        p_pers_id        in number,
        p_acc_id         in number,
        p_entrp_id       in number,
        p_effective_date in varchar2,
        p_user_id        in number
    ) is
        l_count number;
    begin
  /*** If there are broker assignments
       for future and current, then just delete it ****/
        if p_entrp_id is null then
            delete from broker_assignments a
            where
                    a.effective_date > to_date(p_effective_date, 'MM/DD/YYYY')
                and a.pers_id = p_pers_id;

            delete from broker_assignments a
            where
                    a.effective_date >= to_date(p_effective_date, 'MM/DD/YYYY')
                and a.pers_id = p_pers_id
                and a.broker_id <> p_broker_id;

 /** End date the assignment if there is already one **/
            update broker_assignments a
            set
                effective_end_date = to_date(p_effective_date, 'MM/DD/YYYY') - 1
            where
                    a.effective_date < to_date(p_effective_date, 'MM/DD/YYYY')
                and a.pers_id = p_pers_id
                and a.broker_id <> p_broker_id;

            insert into broker_assignments
                select
                    broker_assignment_seq.nextval,
                    p_broker_id,
                    p_pers_id,
                    entrp_id,
                    nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    'A',
                    null
                from
                    person
                where
                        pers_id = p_pers_id
                    and not exists (
                        select
                            *
                        from
                            broker_assignments
                        where
                                broker_id = p_broker_id
                            and pers_id = p_pers_id
                            and effective_date <= nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate)
                    );

        else
            delete from broker_assignments a
            where
                    a.effective_date = to_date(p_effective_date, 'MM/DD/YYYY')
                and a.entrp_id = p_entrp_id
                and a.broker_id = p_broker_id;

            delete from broker_assignments a
            where
                    a.effective_date > to_date(p_effective_date, 'MM/DD/YYYY')
                and a.entrp_id = p_entrp_id;

            delete from broker_assignments a
            where
                    a.effective_date >= to_date(p_effective_date, 'MM/DD/YYYY')
                and a.entrp_id = p_entrp_id
                and a.broker_id <> p_broker_id;

 /** End date the assignment if there is already one **/
            update broker_assignments a
            set
                effective_end_date = to_date(p_effective_date, 'MM/DD/YYYY') - 1
            where
                    a.effective_date < to_date(p_effective_date, 'MM/DD/YYYY')
                and a.entrp_id = p_entrp_id
                and a.broker_id <> p_broker_id;

            insert into broker_assignments
                select
                    broker_assignment_seq.nextval,
                    p_broker_id,
                    null,
                    p_entrp_id,
                    nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    'A',
                    null
                from
                    dual
                where
                    not exists (
                        select
                            *
                        from
                            broker_assignments
                        where
                                broker_id = p_broker_id
                            and entrp_id = p_entrp_id
                            and effective_date <= nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate)
                    );

            insert into broker_assignments
                select
                    broker_assignment_seq.nextval,
                    p_broker_id,
                    pers_id,
                    entrp_id,
                    nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    'A',
                    null
                from
                    person
                where
                        entrp_id = p_entrp_id
                    and not exists (
                        select
                            *
                        from
                            broker_assignments
                        where
                                broker_id = p_broker_id
                            and pers_id = p_pers_id
                            and effective_date <= nvl(to_date(p_effective_date, 'MM/DD/YYYY'), sysdate)
                    );

        end if;
    end assign_broker;

    function check_duplicate (
        p_ssn           in varchar2,
        p_group_acc_num in varchar2,
        p_emp_name      in varchar2,
        p_account_type  in varchar2,
        p_entrp_id      in number
    ) return varchar2 is
        l_entrp_id number;
        l_dup_flag varchar2(1) := 'N';
        l_dup      number;
    begin
        if p_entrp_id is not null then
            if p_group_acc_num is not null then
                l_entrp_id := pc_entrp.get_entrp_id(p_group_acc_num);
            end if;

            if p_emp_name is not null then
                l_entrp_id := pc_entrp.get_entrp_id(p_emp_name);
            end if;

        end if;

        if p_account_type in ( 'HSA', 'LSA' ) then    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
            select
                count(*)
            into l_dup
            from
                person  a,
                account b
            where
                    replace(a.ssn, '-') = replace(p_ssn, '-')
                and a.pers_id = b.pers_id
                and b.account_status <> 4
                and b.account_type = p_account_type
                and ( p_entrp_id is null
                      or a.entrp_id = p_entrp_id );

        end if;

        if p_account_type in ( 'HRA', 'FSA' ) then
            select
                count(*)
            into l_dup
            from
                person  a,
                account b
            where
                    replace(a.ssn, '-') = replace(p_ssn, '-')
                and a.pers_id = b.pers_id
                and a.entrp_id = p_entrp_id
                and b.account_type = p_account_type;

        end if;

        if l_dup > 0 then
            l_dup_flag := 'Y';
        end if;
        return l_dup_flag;
    end check_duplicate;

    procedure create_catchup_account (
        p_pers_id       in number,
        p_user_id       in number,
        x_error_message out varchar2
    ) is
        l_acc_id  number;
        l_pers_id number;
    begin
        for x in (
            select
                a.first_name,
                a.last_name,
                a.middle_name,
                c.address,
                c.city,
                c.state,
                c.zip,
                c.phone_day,
                c.email,
                a.ssn,
                a.gender,
                a.relat_code,
                a.note,
                a.birth_date,
                a.title,
                b.broker_id,
                b.salesrep_id,
                b.fee_setup,
                b.plan_code,
                b.fee_maint,
                b.lang_perf,
                a.pers_main,
                b.acc_num
            from
                person  a,
                account b,
                person  c
            where
                    a.pers_main = b.pers_id
                and a.pers_main = c.pers_id
                and a.pers_id = p_pers_id
                and b.pers_id = c.pers_id
        ) loop
            insert into person (
                pers_id,
                first_name,
                middle_name,
                last_name,
                birth_date,
                title,
                gender,
                ssn,
                address,
                city,
                state,
                zip,
                phone_day,
                email,
                relat_code,
                note,
                person_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                pers_main
            ) values ( pers_seq.nextval,
                       x.first_name,
                       x.middle_name,
                       x.last_name,
                       x.birth_date,
                       x.title,
                       x.gender,
                       x.ssn,
                       x.address,
                       x.city,
                       x.state,
                       x.zip,
                       x.phone_day,
                       x.email,
                       1,
                       'Online Enrollment',
                       'SUBSCRIBER',
                       sysdate,
                       421,
                       sysdate,
                       421,
                       x.pers_main ) returning pers_id into l_pers_id;

            insert into account (
                acc_id,
                pers_id,
                acc_num,
                plan_code,
                start_date,
                broker_id,
                note,
                fee_setup,
                fee_maint,
                reg_date,
                account_status,
                complete_flag,
                signature_on_file,
                hsa_effective_date,
                account_type,
                enrollment_source,
                salesrep_id,
                lang_perf,
                catchup_flag
            ) values ( acc_seq.nextval,
                       l_pers_id,
                       substr(x.acc_num,
                              4,
                              length(x.acc_num)),
                       x.plan_code,
                       sysdate,
                       x.broker_id,
                       'Catchup Contribution Account',
                       x.fee_setup,
                       x.fee_maint,
                       sysdate,
                       1,
                       1,
                       'Y',
                       sysdate,
                       'HSA',
                       'CATCHUP',
                       x.salesrep_id,
                       x.lang_perf,
                       'Y' ) returning acc_id into l_acc_id;

        end loop;
    exception
        when others then
            x_error_message := sqlerrm;
    end create_catchup_account;

    function get_acc_id (
        p_acc_num in varchar2
    ) return number is
        l_acc_id number;
    begin
        for x in (
            select
                acc_id
            from
                account
            where
                acc_num = upper(p_acc_num)
        ) loop
            l_acc_id := x.acc_id;
        end loop;

        return l_acc_id;
    end get_acc_id;

    function get_acc_num_from_acc_id (
        p_acc_id in number
    ) return varchar2 is
        l_acc_num varchar2(30);
    begin
        for x in (
            select
                acc_num
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_acc_num := x.acc_num;
        end loop;

        return l_acc_num;
    end get_acc_num_from_acc_id;

    function get_acc_id_from_ssn (
        p_ssn      in varchar2,
        p_entrp_id in number
    ) return number is
        l_acc_id number;
    begin
        for x in (
            select
                a.acc_id,
                b.entrp_id
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and replace(b.ssn, '-') = replace(
                    format_ssn(p_ssn),
                    '-'
                )
                and ( b.entrp_id is null
                      or b.entrp_id = p_entrp_id )
        ) loop
            if p_entrp_id = x.entrp_id then
                l_acc_id := x.acc_id;
            elsif nvl(p_entrp_id, -1) = nvl(x.entrp_id, -1) then
                l_acc_id := x.acc_id;
            end if;
        end loop;

        return l_acc_id;
    end get_acc_id_from_ssn;

    function get_account_status (
        p_acc_id in number
    ) return number is
        l_account_status number;
    begin
        for x in (
            select
                account_status
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_account_status := x.account_status;
        end loop;

        return l_account_status;
    end get_account_status;

    function get_status (
        p_acc_id in number
    ) return varchar2 is
        l_status varchar2(30);
    begin
        for x in (
            select
                b.status
            from
                account_status b,
                account        a
            where
                    b.status_code = a.account_status
                and a.acc_id = p_acc_id
        ) loop
            l_status := x.status;
        end loop;

        return l_status;
    end get_status;

    procedure upsert_acc_pref (
        p_entrp_id               in number,
        p_acc_id                 in number,
        p_claim_pay_method       in varchar2,
        p_auto_pay               in varchar2,
        p_plan_doc_only          in varchar2,
        p_status                 in varchar2,
        p_allow_eob              in varchar2,
        p_user_id                in number,
        p_pin_mailer             in varchar2 default 'N',
        p_teamster_group         in varchar2 default 'N',
        p_allow_exp_enroll       in varchar2 default 'Y',
        p_maint_fee_paid         in number default null,
        p_allow_online_renewal   in varchar2,
        p_allow_election_changes in varchar2,
        p_plan_action_flg        in varchar2 default 'Y',
        p_submit_election_change in varchar2 default 'Y',
        p_edi_flag               in varchar2 default 'N'   -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
        ,
        p_vendor_id              in number default null    -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
        ,
        p_reference_flag         in varchar2  --Code added by preethy for ticket No:#6071 on 05/07/2018
        ,
        p_allow_payroll_edi      in varchar2  --Code added  by preethy for ticket No:6300 on 16/07/2018
        ,
        p_allow_broker_enroll    in varchar2 default null /*Ticket#6834 */,
        p_allow_broker_renewal   in varchar2 default null,
        p_allow_broker_invoice   in varchar2 default null,
        p_fees_paid_by           in varchar2 default null    -- Added by Swamy for Ticket#11037
    ) is
        l_count     number := 0;
        l_acc_count number := 0;
    begin
        if p_entrp_id is not null then
            select
                count(*)
            into l_count
            from
                account_preference
            where
                entrp_id = p_entrp_id;

            select
                count(*)
            into l_acc_count
            from
                account_preference
            where
                acc_id = p_acc_id;

            if l_count + l_acc_count = 0 then
                insert into account_preference (
                    account_preference_id,
                    acc_id,
                    entrp_id,
                    status,
                    claim_payment_method,
                    autopay_ind,
                    plan_only,
                    allow_eob,
                    pin_mailer_allowed,
                    teamster_group,
                    allow_exp_enroll,
                    maint_fee_paid_by,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    allow_online_renewal,
                    allow_election_changes,
                    plan_action_flag,
                    submit_elec_chng_flag,
                    edi_flag               -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
                    ,
                    vendor_id              -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
                    ,
                    reference_flag    --Code added by preethy for ticket No:#6071 on 05/07/2018
                    ,
                    allow_payroll_edi  --Code added by preethy for ticket No:6300 on 16/07/2018
                    ,
                    allow_broker_enroll  /*Ticket36834 */,
                    allow_broker_renewal,
                    allow_broker_invoice,
                    fees_paid_by            -- Added by Swamy for Ticket#11037
                ) values ( account_preference_seq.nextval,
                           p_acc_id,
                           p_entrp_id,
                           'A',
                           p_claim_pay_method,
                           p_auto_pay,
                           p_plan_doc_only,
                           p_allow_eob,
                           p_pin_mailer,
                           p_teamster_group,
                           nvl(p_allow_exp_enroll, 'Y'),
                           p_maint_fee_paid,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           p_allow_online_renewal,
                           p_allow_election_changes,
                           p_plan_action_flg,
                           p_submit_election_change,
                           p_edi_flag                     -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
                           ,
                           decode(p_edi_flag, 'Y', p_vendor_id, null)                    -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
                           ,
                           p_reference_flag  --Code added by preethy for ticket No:#6071 on 05/07/2018
                           ,
                           p_allow_payroll_edi --Code added by preethy for ticket No:6300 on 16/07/2018
                           ,
                           p_allow_broker_enroll  /*Ticket36834 */,
                           p_allow_broker_renewal,
                           p_allow_broker_invoice,
                           p_fees_paid_by            -- Added by Swamy for Ticket#11037
                            );

            else
                update account_preference
                set
                    claim_payment_method = nvl(p_claim_pay_method, claim_payment_method),
                    status = nvl(p_status, status),
                    plan_only = nvl(p_plan_doc_only, plan_only),
                    autopay_ind = nvl(p_auto_pay, autopay_ind),
                    allow_eob = nvl(p_allow_eob, allow_eob),
                    pin_mailer_allowed = nvl(p_pin_mailer, pin_mailer_allowed),
                    teamster_group = nvl(p_teamster_group, teamster_group),
                    allow_exp_enroll = nvl(p_allow_exp_enroll, allow_exp_enroll),
                    maint_fee_paid_by = nvl(p_maint_fee_paid, maint_fee_paid_by),
                    allow_online_renewal = nvl(p_allow_online_renewal, allow_online_renewal),
                    allow_election_changes = nvl(p_allow_election_changes, allow_election_changes),
                    plan_action_flag = nvl(p_plan_action_flg, plan_action_flag),
                    submit_elec_chng_flag = nvl(p_submit_election_change, submit_elec_chng_flag),
                    edi_flag = nvl(p_edi_flag, 'N')    -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
                    ,
                    vendor_id = p_vendor_id           -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
                    ,
                    reference_flag = p_reference_flag  --Code added by preethy for ticket No:#6071 on 05/07/2018
                    ,
                    allow_payroll_edi = p_allow_payroll_edi  --Code added by preethy for ticket No:6300 on 16/07/2018
                    ,
                    allow_broker_enroll = nvl(p_allow_broker_enroll, allow_broker_enroll)  -- NVL Added by Swamy for Ticket#11161  /*Ticket#6834 */
                    ,
                    allow_broker_renewal = nvl(p_allow_broker_renewal, allow_broker_renewal)   -- NVL Added by Swamy for Ticket#11161
                    ,
                    allow_broker_invoice = nvl(p_allow_broker_invoice, allow_broker_invoice)   -- NVL Added by Swamy for Ticket#11161
                    ,
                    fees_paid_by = p_fees_paid_by  -- Added by Swamy for Ticket#11037
                where
                    entrp_id = p_entrp_id;

            end if;

        end if;
    end upsert_acc_pref;

    function get_cobra_url (
        p_name   in varchar2,
        p_tax_id in varchar2,
        p_lookup in varchar2
    ) return varchar2 is
        l_enrollment_source varchar2(255);
    begin
        if p_lookup = 'EMPLOYEE' then
            for x in (
                select
                    decode(b.enrollment_source, 'WEB_COBRA', 'https://www.sterlinghsa.com/cobra_login/SignOn', 'http://www.cobrapoint.com'
                    ) enrollment_source
                from
                    person  a,
                    account b
                where
                        substr(ssn, 8, 4) = p_tax_id
                    and a.pers_id = b.pers_id
                    and upper(a.last_name) = upper(p_name)
                    and b.account_type = 'COBRA'
            ) loop
                l_enrollment_source := x.enrollment_source;
            end loop;
        else
            for x in (
                select
                    decode(b.enrollment_source, 'WEB_COBRA', 'https://www.sterlinghsa.com/cobra_login/SignOn', 'http://www.cobrapoint.com'
                    ) enrollment_source
                from
                    enterprise a,
                    account    b
                where
                    ( a.entrp_code is null
                      or replace(a.entrp_code, '-') = replace(p_tax_id, '-') )
                    and a.entrp_id = b.entrp_id
                    and upper(a.name) = upper(p_name)
                    and b.account_type = 'COBRA'
            ) loop
                l_enrollment_source := x.enrollment_source;
            end loop;
        end if;

        return l_enrollment_source;
    end get_cobra_url;

    function has_baa_document (
        p_acc_id in number
    ) return varchar2 is
        v_file_status varchar2(100);
    begin
        select distinct
            'Y'
        into v_file_status
        from
            file_attachments
        where
                entity_id = p_acc_id
            and document_purpose = 'BUS_AGG';

        return v_file_status;
    exception
        when others then
            v_file_status := 'N';
            return v_file_status;
    end has_baa_document;

    function get_hex_acc_list (
        p_tax_id in varchar2
    ) return varchar2 is
        l_acc_list varchar2(255);
    begin
        for x in (
            select
                case
                    when account_type = 'HRA' then
                        'R'
                    when account_type = 'HSA'
                         and account_status <> 4 then
                        'H'
                    when account_type = 'FSA' then
                        'F'
                end acc_prefix
            from
                person  a,
                account b
            where
                    a.ssn = p_tax_id
                and a.pers_id = b.pers_id
        ) loop
            l_acc_list := l_acc_list || x.acc_prefix;
        end loop;

        return l_acc_list;
    end get_hex_acc_list;

    function new_acc_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null,
        p_start_date   in date default null,
        p_end_date     in date default null
    ) return number is

        l_total        number := 0;
        l_exists       varchar2(1) := 'N';
        l_account_type varchar2(10);    -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin
     -- Added by Swamy for Ticket#9912 on 10/08/2021
        l_account_type := pc_account.get_account_type(acc_id_in);
        if nvl(l_account_type, p_account_type) = 'COBRA' then
            for x in (
                select
                    sum(amount) amount
                from
                    balance_register a,
                    account          b
                where
                        a.acc_id = acc_id_in
                    and b.pers_id is not null
                    and a.reason_code <> 4
                    and a.acc_id = b.acc_id
                    and b.account_type = 'COBRA'
            ) loop
                l_total := x.amount;
            end loop;

        elsif nvl(l_account_type, p_account_type) in ( 'HRA', 'FSA' ) then
            for x in (
                select /*+ index(A BALANCE_REGISTER_N7) */
                    c.annual_election,
                    b.account_status,
                    b.acc_num,
                    sum(
                        case
                            when c.plan_type in('LPF', 'FSA') then
                                (
                                    case
                                        when a.reason_mode = 'I' then
                               /*   (CASE WHEN REASON_CODE = 17 AND AMOUNT < 0
                                  THEN  amount
                                  ELSE 0 END ) */
                                            0
                                        else
                                            amount
                                    end
                                )
                            else
                                amount
                        end
                    ) amount
                from
                    balance_register          a,
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        a.acc_id = acc_id_in
                    and c.plan_type = p_plan_type
                    and b.pers_id is not null
                    and b.account_type in ( 'HRA', 'FSA' )
                    and c.status in ( 'A', 'I' )
                    and a.acc_id = b.acc_id
                    and c.acc_id = b.acc_id
                    and c.plan_type = a.plan_type
                    and trunc(fee_date) >= trunc(c.plan_start_date)
                    and trunc(fee_date) >= trunc(c.effective_date)--SK Added ON 08_11 to see if this fix the issue related to case#81458
                    and trunc(c.plan_start_date) <= nvl(
                        trunc(date_start_in),
                        trunc(c.plan_start_date)
                    )
                    and trunc(c.plan_end_date) >= nvl(
                        trunc(date_end_in),
                        trunc(c.plan_end_date)
                    )
                    and c.plan_term_date >= sysdate - 360
                                                      and trunc(fee_date) between nvl(p_start_date, c.plan_start_date) and nvl(p_end_date
                                                      , c.plan_end_date)
                group by
                    c.annual_election,
                    b.account_status,
                    b.acc_num
            ) loop
                l_exists := 'Y';
                if p_plan_type in ( 'FSA', 'LPF' ) then
                    l_total := x.annual_election + x.amount;
                else
                    l_total := x.amount;
                end if;

            end loop;
        else
            if
                date_start_in is not null
                and date_end_in is not null
                and nvl(l_account_type, p_account_type) <> 'COBRA'
            then
                for x in (
                    select
                        account_type,
                        account_status,
                        sum(amount) amount,
                        plan_code
                    from
                        (
                            select /*+ index(A BALANCE_REGISTER_N8) */
                                b.account_type,
                                b.account_status,
                                sum(amount) amount,
                                b.plan_code -- 6588
                            from
                                balance_register a,
                                account          b
                            where
                                    a.acc_id = acc_id_in
                                and b.pers_id is not null
                                and a.acc_id = b.acc_id
                                and b.account_type <> 'COBRA'
                                and b.account_type = l_account_type  -- 'HSA' replaced by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                                and reason_mode not in ( 'F', 'E', 'C', 'FP', 'EP' )
                                and trunc(fee_date) between trunc(nvl(date_start_in, sysdate)) and trunc(nvl(date_end_in, sysdate))
                            group by
                                b.account_status,
                                a.acc_id,
                                b.account_type,
                                b.plan_code -- 6588
                            union
                            select  /*+ index(A BALANCE_REGISTER_N8) */
                                b.account_type,
                                b.account_status,
                                sum(amount) amount,
                                b.plan_code -- 6588
                            from
                                balance_register a,
                                account          b
                            where
                                    a.acc_id = acc_id_in
                                and b.pers_id is not null
                                and a.acc_id = b.acc_id
                                and b.account_type <> 'COBRA'
                                and b.account_type = l_account_type  -- 'HSA' replaced by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                                and a.reason_mode = 'EP'
                                and trunc(fee_date) between trunc(nvl(date_start_in, sysdate)) and trunc(nvl(date_end_in, sysdate)) +
                                3
                            group by
                                b.account_status,
                                a.acc_id,
                                b.account_type,
                                b.plan_code -- 6588
                        )
                    group by
                        account_type,
                        account_status,
                        plan_code
                ) loop
                    if x.account_status = 4 then
                        l_total := x.amount;
                    elsif x.amount < 0 then
                        l_total := x.amount;
                    else
                        l_total := x.amount - pc_plan.get_minimum(x.plan_code);
                    end if;
                end loop;

            else
                for x in (
                    select
                        account_type,
                        account_status,
                        sum(amount) amount,
                        plan_code
                    from
                        (
                            select /*+ index(A BALANCE_REGISTER_N8) */
                                b.account_type,
                                b.account_status,
                                sum(amount) amount,
                                b.plan_code -- 6588
                            from
                                balance_register a,
                                account          b
                            where
                                    a.acc_id = acc_id_in
                                and b.pers_id is not null
                                and a.acc_id = b.acc_id
                                and b.account_type <> 'COBRA'
                                and b.account_type = l_account_type  -- 'HSA' replaced by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                                and reason_mode not in ( 'F', 'E', 'C', 'FP', 'EP' )
                            group by
                                b.account_status,
                                a.acc_id,
                                b.account_type,
                                b.plan_code -- 6588
                            union
                            select /*+ index(A BALANCE_REGISTER_N8) */
                                b.account_type,
                                b.account_status,
                                sum(amount) amount,
                                b.plan_code -- 6588
                            from
                                balance_register a,
                                account          b
                            where
                                    a.acc_id = acc_id_in
                                and b.pers_id is not null
                                and a.acc_id = b.acc_id
                                and b.account_type <> 'COBRA'
                                and b.account_type = l_account_type  -- 'HSA' replaced by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                                and a.reason_mode = 'EP'
                            group by
                                b.account_status,
                                a.acc_id,
                                b.account_type,
                                b.plan_code -- 6588
                        )
                    group by
                        account_type,
                        account_status,
                        plan_code
                ) loop
                    if x.account_status = 4 then
                        l_total := x.amount;
                    elsif x.amount < 0 then
                        l_total := x.amount;
                    else
                        l_total := x.amount - pc_plan.get_minimum(x.plan_code);
                    end if;
                end loop;
            end if;
        end if;

        if
            nvl(l_account_type, p_account_type) in ( 'HRA', 'FSA' )
            and p_plan_type in ( 'LPF', 'FSA' )
            and l_exists = 'N'
            and nvl(l_total, 0) = 0
        then
            for x in (
                select
                    c.annual_election amount,
                    b.account_status,
                    b.acc_num
                from
                    account                   b,
                    ben_plan_enrollment_setup c
                where
                        b.acc_id = acc_id_in
                    and b.pers_id is not null
                    and c.plan_type = p_plan_type
                    and c.plan_type in ( 'LPF', 'FSA' )
                    and b.account_type in ( 'HRA', 'FSA' )
                    and c.status in ( 'A', 'I' )
                    and c.acc_id = b.acc_id
                    and trunc(c.plan_start_date) <= nvl(
                        trunc(date_start_in),
                        trunc(c.plan_start_date)
                    )
                    and trunc(c.plan_end_date) >= nvl(
                        trunc(date_end_in),
                        trunc(c.plan_end_date)
                    )
                    and c.plan_term_date >= sysdate - 180
            ) loop
                if x.account_status = 4 then
                    l_total := 0;
                else
                    l_total := x.amount;
                end if;
            end loop;
        end if;

        return nvl(l_total, 0);
    exception
        when others then
            return 0;
      --raise;
    end new_acc_balance;

    function is_stacked_account (
        p_entrp_id in number
    ) return varchar2 is
        l_stacked_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup plans,
                enterprise                er,
                account                   acc
            where
                    er.entrp_id = p_entrp_id
                and plans.entrp_id = er.entrp_id
                and plans.entrp_id = acc.entrp_id
                and acc.account_type in ( 'FSA', 'HRA' )
                and plans.plan_end_date > sysdate
                and plans.status = 'A'
                and plans.product_type in ( 'FSA', 'HRA' )
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
        ) loop
            if x.cnt > 0 then
                l_stacked_flag := 'Y';
            end if;
        end loop;

        return l_stacked_flag;
    end is_stacked_account;

    procedure insert_acc_pref (
        p_acc_pref in acc_pref_t,
        p_userid   in number,
        p_status   out varchar2,
        p_error    out varchar2
    ) is
    begin
        for i in 1..p_acc_pref.count loop
            insert into account_preference (
                account_preference_id,
                acc_id,
                entrp_id,
                paper_doc,
                preferred_language,
                claim_payment_method,
                status,
                autopay_ind,
                plan_only,
                allow_eob,
                pin_mailer_allowed,
                teamster_group,
                allow_exp_enroll,
                er_contribution_frequency,
                ee_contribution_frequency,
                er_contribution_flag,
                ee_contribution_flag,
                setup_fee_paid_by,
                maint_fee_paid_by,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( account_preference_seq.nextval,
                       p_acc_pref(i).acc_id,
                       p_acc_pref(i).entrp_id,
                       p_acc_pref(i).paper_doc,
                       p_acc_pref(i).preferred_language,
                       p_acc_pref(i).claim_payment_method,
                       p_acc_pref(i).status,
                       p_acc_pref(i).autopay_ind,
                       p_acc_pref(i).plan_only,
                       p_acc_pref(i).allow_eob,
                       p_acc_pref(i).pin_mailer_allowed,
                       p_acc_pref(i).teamster_group,
                       p_acc_pref(i).allow_exp_enroll,
                       p_acc_pref(i).er_contribution_frequency,
                       p_acc_pref(i).ee_contribution_frequency,
                       p_acc_pref(i).er_contribution_flag,
                       p_acc_pref(i).ee_contribution_flag,
                       p_acc_pref(i).setup_fee_paid_by,
                       p_acc_pref(i).maint_fee_paid_by,
                       sysdate,
                       p_userid,
                       sysdate,
                       p_userid );

        end loop;

        p_status := 'S';
    exception
        when others then
            p_status := 'E';
            p_error := 'INSERT_ACC_PREF ERROR' || sqlerrm;
            pc_log.log_error('Insert Account_Preference', sqlerrm);
    end insert_acc_pref;

    function active_hsa_acct (
        p_ssn in varchar2
    ) return hsa_act_acct_t
        pipelined
        deterministic
    is
        l_record hsa_acct_record_t;
    begin
        for x in (
            select
                count(*) cnt
            from
                account a,
                person  b
            where
                    a.account_type = 'HSA'
                and b.ssn = format_ssn(p_ssn)
                and a.pers_id = b.pers_id
                and a.account_status in ( 1, 3 )
        ) loop
            l_record.hsa_cnt := x.cnt;
            l_record.error_message := 'Success';
            l_record.error_status := 'S';
        end loop;

        pipe row ( l_record );
    end;

    function generate_acc_num (
        p_plan_code in number,
        p_state     in varchar2
    ) return varchar2 is
        l_acc_num varchar2(30);
    begin
        select
            decode(account_type,
                   'HSA',
                   case
                    when
                        plan_suffix = 'I'
                        and plan_sign = 'SHA'
                    then
                        plan_suffix || upper(p_state)
                    when
                        plan_suffix <> 'I'
                        and plan_sign = 'SHA'
                    then
                        plan_suffix
                    else plan_suffix
                end,
                   plan_suffix)
            || online_enroll_seq.nextval
        into l_acc_num
        from
            plans
        where
            plan_code = p_plan_code;

        return l_acc_num;
    end generate_acc_num;

    function is_payroll_integrated (
        p_entrp_id number
    ) return varchar2 is
        is_payroll varchar2(1);
    begin
        select
            payroll_integration
        into is_payroll
        from
            account
        where
            entrp_id = p_entrp_id;

        return is_payroll;
    end is_payroll_integrated;

 --Added by Karthe For the pier Ticket 2156
    function enable_plan_action (
        p_entrp_id number
    ) return varchar2 is
        v_flag varchar2(1);
    begin
        for i in (
            select
                plan_action_flag
            into v_flag
            from
                account_preference
            where
                entrp_id = p_entrp_id
        ) loop
            v_flag := i.plan_action_flag;
        end loop;

        return nvl(v_flag, 'Y');
    exception
        when others then
            return 'Y';
    end;

 --Added by Karthe For the pier Ticket 2156
    function show_submit_elec_chng (
        p_entrp_id number
    ) return varchar2 is
        v_flag varchar2(1);
    begin
        for i in (
            select
                submit_elec_chng_flag
            into v_flag
            from
                account_preference
            where
                entrp_id = p_entrp_id
        ) loop
            v_flag := i.submit_elec_chng_flag;
        end loop;

        return nvl(v_flag, 'Y');
    exception
        when others then
            return 'Y';
    end;
/** 05/04/2017 : This is to show the before LOA termination plan balance **/
    function previous_acc_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null,
        p_start_date   in date default null,
        p_end_date     in date default null
    ) return number is
        l_total  number := 0;
        l_exists varchar2(1) := 'N';
    begin
        if p_account_type in ( 'HRA', 'FSA' ) then
            for x in (
                select /*+ index(A BALANCE_REGISTER_N8) */
                    bph.annual_election,
                    b.account_status,
                    b.acc_num,
                    sum(
                        case
                            when bph.plan_type in('LPF', 'FSA') then
                                (
                                    case
                                        when a.reason_mode = 'I' then
                                            0
                                        else
                                            amount
                                    end
                                )
                            else
                                amount
                        end
                    ) amount
                from
                    balance_register a,
                    account          b,
                    ben_plan_history bph,
                    (
                        select
                            max(ben_plan_history_id) ben_plan_history_id
                        from
                            ben_plan_history bh
                        where
                                bh.acc_id = acc_id_in
                            and bh.plan_type = p_plan_type
                            and trunc(bh.plan_start_date) <= nvl(
                                trunc(date_start_in),
                                trunc(bh.plan_start_date)
                            )
                            and trunc(bh.plan_end_date) >= nvl(
                                trunc(date_end_in),
                                trunc(bh.plan_end_date)
                            )
                    )                bh
                where
                        a.acc_id = acc_id_in
                    and bph.ben_plan_history_id = bh.ben_plan_history_id
                    and bph.plan_type = p_plan_type
                    and b.pers_id is not null
                    and b.account_type in ( 'HRA', 'FSA' )
                    and bph.status in ( 'A', 'I' )
                    and a.acc_id = b.acc_id
                    and bph.acc_id = b.acc_id
                    and bph.plan_type = a.plan_type
                    and trunc(fee_date) >= trunc(bph.plan_start_date)
                    and trunc(bph.plan_start_date) <= nvl(
                        trunc(date_start_in),
                        trunc(bph.plan_start_date)
                    )
                    and trunc(bph.plan_end_date) >= nvl(
                        trunc(date_end_in),
                        trunc(bph.plan_end_date)
                    )
                    and trunc(fee_date) between nvl(p_start_date, bph.plan_start_date) and nvl(p_end_date, bph.plan_end_date)
                group by
                    bph.annual_election,
                    b.account_status,
                    b.acc_num
            ) loop
                l_exists := 'Y';
                if p_plan_type in ( 'FSA', 'LPF' ) then
                    l_total := x.annual_election + x.amount;
                else
                    l_total := x.amount;
                end if;

            end loop;
        end if;

        if
            p_account_type in ( 'HRA', 'FSA' )
            and p_plan_type in ( 'LPF', 'FSA' )
            and l_exists = 'N'
            and nvl(l_total, 0) = 0
        then
            for x in (
                select
                    bph.annual_election amount,
                    b.account_status,
                    b.acc_num
                from
                    account          b,
                    ben_plan_history bph,
                    (
                        select
                            max(ben_plan_history_id) ben_plan_history_id
                        from
                            ben_plan_history bh
                        where
                                bh.acc_id = acc_id_in
                            and bh.plan_type = p_plan_type
                            and trunc(bh.plan_start_date) <= nvl(
                                trunc(date_start_in),
                                trunc(bh.plan_start_date)
                            )
                            and trunc(bh.plan_end_date) >= nvl(
                                trunc(date_end_in),
                                trunc(bh.plan_end_date)
                            )
                    )                bh
                where
                        b.acc_id = acc_id_in
                    and bph.ben_plan_history_id = bh.ben_plan_history_id
                    and bph.plan_type = p_plan_type
                    and b.pers_id is not null
                    and bph.plan_type in ( 'LPF', 'FSA' )
                    and b.account_type in ( 'HRA', 'FSA' )
                    and bph.status in ( 'A', 'I' )
                    and bph.acc_id = b.acc_id
                    and trunc(bph.plan_start_date) <= nvl(
                        trunc(date_start_in),
                        trunc(bph.plan_start_date)
                    )
                    and trunc(bph.plan_end_date) >= nvl(
                        trunc(date_end_in),
                        trunc(bph.plan_end_date)
                    )
                    and bph.plan_term_date >= sysdate - 180
            ) loop
                if x.account_status = 4 then
                    l_total := 0;
                else
                    l_total := x.amount;
                end if;
            end loop;

        end if;

        return nvl(l_total, 0);
    exception
        when others then
            return 0;
     -- raise;
    end previous_acc_balance;

-- Added by swamy on 11/06/2018 wrt Ticket#5863
-- Function will be calledfrom Apex page 39 to retrive the vendor name based on vendoe ID.
    function get_vendor_name (
        p_vendor_id in number
    ) return varchar2 is
        l_vendor_name external_vendor_credentials.vendor_name%type;
    begin
        for x in (
            select
                vendor_name
            from
                external_vendor_credentials
            where
                vendor_id = p_vendor_id
        ) loop
            l_vendor_name := x.vendor_name;
        end loop;

        return l_vendor_name;
    end get_vendor_name;

-- Below Function Added By Swamy For Ticket#6794(ACN Migration)
    function is_migrated (
        p_acc_id number
    ) return varchar2 is
        ls_migrated varchar2(1) := 'N';
    begin
        select
            nvl(migrated_flag, 'N')
        into ls_migrated
        from
            account
        where
            acc_id = p_acc_id;

        return nvl(ls_migrated, 'N');
    exception
        when no_data_found then
            ls_migrated := 'N';
    end is_migrated;

-- Below Function Added By Swamy For Ticket#6794(ACN Migration)
    function get_plan_code (
        p_acc_id in number
    ) return number is
        l_plan_code number;
    begin
        for x in (
            select
                plan_code
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_plan_code := x.plan_code;
        end loop;

        return l_plan_code;
    end get_plan_code;

-- Added by Joshi for 6794 : ACN Migration
    function get_emp_accid_from_pers_id (
        p_pers_id number
    ) return number is
        l_acc_id number;
    begin
        select
            a.acc_id
        into l_acc_id
        from
            person  p,
            account a
        where
                a.entrp_id = p.entrp_id
            and p.pers_id = p.pers_id
            and p.pers_id = p_pers_id;

        return l_acc_id;
    exception
        when others then
            return null;
    end get_emp_accid_from_pers_id;

    function get_ameritrade_acct_detail (
        p_acc_id number
    ) return tbl_ameritrade_acct
        pipelined
        deterministic
    is

        l_record            rec_ameritrade_acct;
        l_flag              varchar2(1);
        l_account_number    varchar2(20);
        l_hsa_avail_balance number;
        l_acct_balance      number;
        l_acct_count        number;
        l_acct_requested    varchar2(1);
    begin
--
        for x in (
            select
                *
            from
                investment d
            where
                    d.acc_id = p_acc_id
                and invest_id = 3433
        ) loop
            l_flag := 'Y';
            l_account_number := x.invest_acc;
         -- l_acct_balance := PC_ACCOUNT.get_outside_investment(P_ACC_ID)
            select
                sum(nvl(invest_amount, 0))
            into l_acct_balance
            from
                invest_transfer c,
                (
                    select
                        max(transfer_id) transfer_id,
                        investment_id
                    from
                        invest_transfer b
                    group by
                        investment_id
                )               e,
                investment      d
            where
                    e.transfer_id = c.transfer_id
                and e.investment_id = c.investment_id
                and d.investment_id = e.investment_id
                and d.acc_id = p_acc_id
                and d.invest_id = 3433;

            l_record.account_number := l_account_number;
            l_record.outside_inv_balance := l_acct_balance;
        end loop;

        select
            count(*)
        into l_acct_count
        from
            file_attachments
        where
                entity_id = p_acc_id
            and entity_name = 'ACCOUNT'
            and document_purpose = 'APP'
            and upper(description) like '%AMERITRADE%';

        if
            l_account_number is not null
            and l_acct_count >= 0
        then
            l_acct_requested := 'P';
        elsif
            l_account_number is null
            and l_acct_count > 0
        then
            l_acct_requested := 'R';
        else
            l_acct_requested := 'N';
        end if;

        l_record.acct_requested := l_acct_requested;
        l_record.acc_id := p_acc_id;
        l_hsa_avail_balance := pc_account.new_acc_balance(p_acc_id, to_date('01-JAN-2004', 'DD-MON-YYYY'), sysdate, 'HSA',
                                                          'HSA');

        l_record.hsa_balance := l_hsa_avail_balance;
        pipe row ( l_record );
    end get_ameritrade_acct_detail;

    procedure create_outside_investment (
        p_claim_id      number,
        p_user_id       number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_invest_cnt   integer;
        l_acct_balance number;
    begin
        x_return_status := 'S';
        for y in (
            select
                c.claim_id,
                c.claim_date,
                c.claim_amount,
                i.invest_acc,
                i.investment_id,
                a.acc_id
            from
                claimn     c,
                investment i,
                account    a
            where
                    a.pers_id = c.pers_id
                and a.account_type = 'HSA'
                and a.acc_id = i.acc_id
                and i.invest_id = 8074
                and c.pay_reason = 18
                and nvl(c.claim_source, 'INTERNAL') = 'ONLINE'
                and c.claim_status = 'PAID'
                and i.end_date is null
                and c.claim_id = p_claim_id
        ) loop
            select
                count(*)
            into l_invest_cnt
            from
                invest_transfer it
            where
                    it.investment_id = y.investment_id
                and it.claim_id = y.claim_id;

            if l_invest_cnt = 0 then

                    -- Get the latest investment value.
                select
                    sum(nvl(invest_amount, 0))
                into l_acct_balance
                from
                    invest_transfer c,
                    (
                        select
                            max(transfer_id) transfer_id,
                            investment_id
                        from
                            invest_transfer b
                        group by
                            investment_id
                    )               e,
                    investment      d
                where
                        e.transfer_id = c.transfer_id
                    and e.investment_id = c.investment_id
                    and d.investment_id = e.investment_id
                    and d.acc_id = y.acc_id
                    and d.invest_id = 8074;

                if l_acct_balance is null then
                    l_acct_balance := 0;
                end if;
                pc_log.log_error('l_acct_balance', 'Account balance  ' || l_acct_balance);
                pc_log.log_error('Y.CLAIM_AMOUNT', 'Y.CLAIM_AMOUNT  ' || y.claim_amount);
                    /* 9246 : commented and added below insert as invest_date should be current_date and not last day of month.
                    INSERT INTO INVEST_TRANSFER(TRANSFER_ID, INVESTMENT_ID, INVEST_DATE, INVEST_AMOUNT,NOTE,CREATION_DATE,CREATED_BY,CLAIM_ID)
                    VALUES(TRANSFER_SEQ.NEXTVAL,Y.INVESTMENT_ID, LAST_DAY(Y.CLAIM_DATE), (l_acct_balance+Y.CLAIM_AMOUNT),'Generated online on ' || TO_CHAR(SYSDATE,'MMDDYYYY'),sysdate,P_USER_ID, Y.CLAIM_ID);
                    */
                insert into invest_transfer (
                    transfer_id,
                    investment_id,
                    invest_date,
                    invest_amount,
                    note,
                    creation_date,
                    created_by,
                    claim_id
                ) values ( transfer_seq.nextval,
                           y.investment_id,
                           y.claim_date,
                           ( l_acct_balance + y.claim_amount ),
                           'Generated online on '
                           || to_char(y.claim_date, 'MMDDYYYY'),
                           sysdate,
                           p_user_id,
                           y.claim_id );

                pc_notifications.send_ameritrade_confirm_email(y.acc_id, p_user_id);
            end if;

        end loop;

    end create_outside_investment;

-- Procedure Added by Swamy for Ticket#7568
-- Update the Account status to Closed only after all the Runout and Grace period is over and only if the End_Date is specified in Account table.
-- If there are Multiple Plans, then take the max plan end date for that plan and take the (runout and grace) period and close only if the max(plan end date + runout + grace) period < Sysdate.
    procedure close_all_accounts is

        v_date              date;
        v_plan_end_date     date;
        v_close_date        date;
        v_max_days          date;
        v_days              date;
        v_max_plan_end_date date;
        v_max_ben_plan_id   number;
        v_run_grace_days    number;
    begin
        for i in (
            select
                acc_id,
                account_type,
                end_date
            from
                account
            where
                end_date is not null
                and account_status in ( '1', '3' )
            -- and acc_id = 416953
                and account_type not in ( 'COBRA' )  ---- rprabu 20/10/2023 															   
                and entrp_id is not null
            order by
                acc_id
        ) loop
   -- Get The End Date
            v_date := trunc(i.end_date);
            pc_log.log_error('Close_All_Accounts', 'I.Account_Type  '
                                                   || i.account_type
                                                   || 'i.Acc_Id :='
                                                   || i.acc_id);

            if i.account_type in ( 'HRA', 'FSA' ) then
        -- initializing the variable
                v_max_days := to_date ( '01/jan/1901', 'dd/mon/yyyy' );
                v_max_plan_end_date := to_date ( '01/jan/1901', 'dd/mon/yyyy' );
                v_run_grace_days := 0;
        -- Get All The Plan_End_Date, Grace Days,Runout Days Details For Each Account
                for j in (
                    select
                        a.plan_end_date,
                        a.runout_period_days,
                        a.grace_period,
                        a.ben_plan_id
                    from
                        ben_plan_enrollment_setup a
                    where
                            status = 'A'
                        and acc_id = i.acc_id
                        and plan_end_date is not null
                    order by
                        a.ben_plan_id
                ) loop
           -- Get the Actual End date by adding grace and runout days to the plan end date.
                    v_days := trunc(j.plan_end_date) + nvl(j.runout_period_days, 0) + nvl(j.grace_period, 0);
           -- If there are multiple benplan, get the actual Max end date by looking into each record by the below logic.
                    if trunc(v_days) > trunc(v_max_days) then
                        v_max_days := v_days;
                        v_max_plan_end_date := j.plan_end_date;
                        v_max_ben_plan_id := j.ben_plan_id;
                        v_run_grace_days := nvl(j.runout_period_days, 0) + nvl(j.grace_period, 0);

                    end if;

                end loop;
--pc_log.log_error('Close_All_Accounts', 'V_Max_Plan_End_Date  '|| V_Max_Plan_End_Date);
        -- If the Max date from the Benplan table is lesser than the End date specified in the account level then take Benplan tables mac end date and add the grace and runout period and if this date is less than the system date, then mark the account as closed.
        -- else take the end date of the account table, and take max plan end date from benplan table and for that record take the runout and grace days.this date is less than the sysdate, then mark the account as Closed.
                if trunc(v_max_plan_end_date) < trunc(v_date) then
                    v_close_date := trunc(v_max_plan_end_date) + v_run_grace_days;
                else
                    v_close_date := trunc(v_date) + v_run_grace_days;
                end if;

            else
                v_close_date := v_date;
            end if;

            pc_log.log_error('Close_All_Accounts', 'v_close_date  '
                                                   || v_close_date
                                                   || ' SYSDATE := '
                                                   || sysdate);
            if trunc(v_close_date) < trunc(sysdate) then
                update account
                set
                    account_status = '4'
                where
                    acc_id = i.acc_id;

            end if;

        end loop;
    exception
        when others then
            pc_log.log_error('Close_All_Accounts',
                             'others  ' || sqlerrm(sqlcode));
    end close_all_accounts;

--Added by Joshi for 9072
    function get_edi_flag (
        p_tax_id in varchar2
    ) return varchar2 as
        l_edi_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                nvl(edi_flag, 'N') edi_flag
            from
                account            a,
                account_preference ap,
                enterprise         e
            where
                    a.acc_id = ap.acc_id
                and a.entrp_id = e.entrp_id
                and e.entrp_code = p_tax_id
        ) loop
            if x.edi_flag = 'Y' then
                l_edi_flag := x.edi_flag;
            end if;
        end loop;

        return ( l_edi_flag );
    end get_edi_flag;

-- Added by Swamy for Ticket#9912 on 10/08/2021
    function get_account_type_from_entrp_id (
        p_entrp_id in number
    ) return varchar2 is
        l_acc_type varchar2(30);
    begin
        for x in (
            select
                account_type
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_acc_type := x.account_type;
        end loop;

        return l_acc_type;
    end get_account_type_from_entrp_id;

  -- Added by Swamy for Ticket#10104 on 21/09/2021
  -- FOR LSA if the employee amount > 0 or if the employee has made any transaction in that month, then system should impose the $5 fee as the employee has availed sterling services in that month.
    function check_minimum_balance (
        p_acc_id       in number,
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return varchar2 is
        l_exists varchar2(1) := 'N';
    begin
        pc_log.log_error('Pc_Account.check_minimum_balance', 'p_acc_id  '
                                                             || p_acc_id
                                                             || ' p_account_type :='
                                                             || p_account_type
                                                             || ' P_START_DATE :='
                                                             || p_start_date
                                                             || ' P_END_DATE :='
                                                             || p_end_date);

        for x in (
            select
                count(register_id) count_register_id,
                sum(amount)        amount
            from
                balance_register a,
                account          b
            where
                    a.acc_id = p_acc_id
                and b.account_type = p_account_type
                and a.acc_id = b.acc_id
                and reason_mode not in ( 'F', 'E', 'C', 'FP' )
                and trunc(fee_date) between trunc(nvl(p_start_date, sysdate)) and decode(a.reason_mode,
                                                                                         'EP',
                                                                                         trunc(nvl(p_end_date, sysdate)) + 3,
                                                                                         trunc(nvl(p_end_date, sysdate)))
        ) loop
            if x.count_register_id > 0 then
                l_exists := 'Y';
            end if;
        end loop;

        return l_exists;
    end check_minimum_balance;

-- Added by Swamy for Ticket#10431(Renewal Resubmit)
    function get_renewal_resubmit_flag (
        p_entrp_id in number
    ) return varchar2 is
        l_renewal_resubmit_flag varchar2(1);
    begin
        for x in (
            select
                renewal_resubmit_flag
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_renewal_resubmit_flag := x.renewal_resubmit_flag;
        end loop;

        return nvl(l_renewal_resubmit_flag, 'N');  -- Added by Swamy for Ticket#11636
    end get_renewal_resubmit_flag;

    -- Added by Jaggi for #11128
    function check_flg_agree (
        p_acc_id number
    ) return varchar2 is
        l_flg_verified varchar2(1) default 'N';
    begin
        for x in (
            select
                creation_date,
                agreement_flag,
                reg_date
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            if
                x.agreement_flag is null
                and nvl(x.creation_date, x.reg_date) < '01-JUL-22'
            then
                l_flg_verified := 'Y';
            end if;
        end loop;

        return nvl(l_flg_verified, 'N');
    end check_flg_agree;

    -- Added by Jaggi for #11128
    procedure update_agreement_flag (
        p_user_id   number,
        p_acc_id    in number,
        p_flg_agree in varchar2
    ) is
    begin
        update account
        set
            agreement_flag = p_flg_agree,
            agreement_read_user_id = p_user_id,
            agreement_read_date = to_char(sysdate, 'mm/dd/yyyy HH24:MI:SS')
        where
            acc_id = p_acc_id;

    end update_agreement_flag;

-- Added by Swamy for Ticket#11106 to find the Stacked Account.
    function is_stacked_account_new (
        p_entrp_id in number
    ) return varchar2 is
        l_stacked_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                count(*) cnt
            from
                ben_plan_enrollment_setup plans,
                enterprise                er,
                account                   acc
            where
                    er.entrp_id = p_entrp_id
                and plans.entrp_id = er.entrp_id
                and plans.entrp_id = acc.entrp_id
                and acc.account_type in ( 'FSA', 'HRA' )
                and plans.plan_end_date > sysdate
                and plans.status = 'A'
                and plans.product_type = 'FSA'
                and ( plans.effective_end_date is null
                      or plans.effective_end_date > sysdate )
                and exists (
                    select
                        1
                    from
                        ben_plan_enrollment_setup bs
                    where
                            bs.entrp_id = plans.entrp_id
                        and bs.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' )
                        and ( bs.effective_end_date is null
                              or bs.effective_end_date > sysdate )
                        and bs.status = 'A'
                )
        ) loop
            if x.cnt > 0 then
                l_stacked_flag := 'Y';
            end if;
        end loop;

        return l_stacked_flag;
    end is_stacked_account_new;

-- Added by Shavee
    procedure remove_employer as
    begin
        for x in (
            select
                pers_id
            from
                person
            where
                entrp_id is not null
                and pers_id in (
                    select
                        pers_id
                    from
                        account acc
                    where
                        acc.entrp_id is null
                        and acc.account_type = 'HSA'
                        and acc.start_date < trunc(trunc(sysdate, 'MM') - 365 * 1,
                                                   'MM')
              --  AND e.account_status=4
              --AND ACC.ACCOUNT_STATUS =1
                        and not exists (
                            select
                                *
                            from
                                income
                            where
                                    acc_id = acc.acc_id
                                and income.fee_code != 8
                                and contributor is not null
                                and fee_date > trunc(trunc(sysdate, 'MM') - 365 * 1,
                                                     'MM')
                        )
                )
        ) loop
            update person
            set
                entrp_id = null
            where
                    pers_id = x.pers_id
                and entrp_id is not null;

        end loop;
    end;
-- Added by Jaggi #11263
    function get_broker_id (
        p_acc_id in number
    ) return number is
        l_broker_id number;
    begin
        for x in (
            select
                broker_id
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_broker_id := x.broker_id;
        end loop;

        return l_broker_id;
    end get_broker_id;
-- Added by Jaggi #11263
    function get_ga_id (
        p_acc_id in number
    ) return number is
        l_ga_id number;
    begin
        for x in (
            select
                ga_id
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_ga_id := x.ga_id;
        end loop;

        return l_ga_id;
    end get_ga_id;

    procedure close_qb_accounts (
        p_entrp_id  number,
        p_term_date date,
        p_user_id   number
    ) is
    begin
        for i in (
            select
                a.pers_id,
                b.acc_num
            from
                person  a,
                account b
            where
                    a.entrp_id = p_entrp_id
                and a.pers_id = b.pers_id
                and account_status in ( 1, 3 )
                and person_type = 'QB'
        ) loop 

--	Update the plans elections status
            update plan_elections
            set
                status = decode(status, 'E', 'TE', 'P', 'TP',
                                'PR', 'TP', status),
                termination_date = p_term_date,
                termination_reason = 'EMPLOYER_TERMED',
                terminated_on = sysdate,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    pers_id = i.pers_id
                and status in ( 'E', 'P', 'PR' ); 

         --Update the invoice parameter and rate plans effective end date and also status. ( end dating premium setup)
            update invoice_parameters
            set
                status = 'I',
                autopay = 'N',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    entity_type = 'PERSON'
                and entity_id = i.pers_id; 

         -------------Rate plans updation 
            update rate_plans
            set
                status = 'I',
                effective_end_date = p_term_date,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    entity_type = 'PERSON'
                and entity_id = i.pers_id; 

     ----Rate plan detail  updation 
            update rate_plan_detail
            set
                effective_end_date = p_term_date,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                ( effective_end_date is null
                  or effective_end_date > sysdate )
                and rate_plan_id in (
                    select
                        rate_plan_id
                    from
                        rate_plans
                    where
                            entity_type = 'PERSON'
                        and entity_id = i.pers_id
                ); 

         -- Cancel the invoices.
            for x in (
                select
                    invoice_id
                from
                    ar_invoice
                where
                        entity_type = 'PERSON'
                    and invoice_reason = 'PREMIUM'
                    and entity_id = i.pers_id
            ) loop
                pc_invoice.void_invoice(x.invoice_id, p_user_id, 'EMPLOYER_TERMED', null, 'CANCELLED');
            end loop;

        -- Terminate all QB accounts  
            update account
            set
                end_date = p_term_date,
                account_status = '4',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                pers_id = i.pers_id; 

          -- Sent emails for all 
            -- PC_COBRA_NOTIFICATIONS.COBRA_ER_TERMINATION_NOTIFICATION( I.pers_id );  ---- employer email 
           ---  PC_COBRA_NOTIFICATIONS.COBRA_QB_TERMINATION_NOTIFICATION( i.pers_id );   ---- QB  email 
              ------Make INactive all QB account for this Employer
            update online_users
            set
                user_status = 'I'
            where
                find_key = i.acc_num;

        end loop;
    exception
        when others then
            pc_log.log_error('TERMINATE_COBRA_EMPLOYER', 'ERROR IN CLOSE_QB_ACCOUNTS : ' || sqlerrm);
    end close_qb_accounts;

    procedure terminate_cobra_employer is
    begin
        for x in (
            select
                entrp_id,
                acc_id,
                trunc(end_date) term_date,
                last_updated_by
            from
                account
            where
                    account_type = 'COBRA'
                and end_date is not null
                and entrp_id is not null
                and account_status = '1'
                and trunc(end_date) <= trunc(sysdate)
        ) loop
            pc_log.log_error('TERMINATE_COBRA_EMPLOYER', 'The account to be closed x.entrp_id : ' || x.entrp_id);
            update account
            set
                account_status = '4'
            where
                entrp_id = x.entrp_id;

            pc_account.close_qb_accounts(x.entrp_id, x.term_date, x.last_updated_by);
        end loop;
    end;
--- Added by rprabu 27/07/2023
    procedure terminate_cobra_qb_employees is
    begin
      ----- need to be discussed with COBRA Team / vanitha  25/11/2023 
   ---------- terminate qbs whose coverage date is ending with sysdate rprabu 27/09/2023
  /* FOR Z IN ( Select distinct   a.pers_id, a.LAST_UPDATED_BY  ,ACC_ID  from plan_elections a, account b
              where  plan_election_id is not null and termination_date is null 
              AND a.pers_id =b.pers_id 
              and END_DATE is null 
              and ACCOUNT_STATUS ='1'
                        and status in ( 'E',  'P', 'PR') 
 						and Trunc(Coverage_end_Date ) =Trunc(SYSDATE) )
         Loop
          pc_log.log_error('TERMINATE_COBRA_EMPLOYEES', 'The account to be closed x.entrp_id : ' ||  Z.Pers_id) ;
          --- 27/09/2023
            PC_ACCOUNT.CLOSE_QB_EE_ACCOUNT(Z.Pers_id , SYSDATE, Z.LAST_UPDATED_BY )  ; 
             End Loop; */ 

    ---------- paid through date < sysdate then qb should be terminated.  rprabu 21/11/2023
  /* FOR Z IN ( Select distinct   a.pers_id, a.LAST_UPDATED_BY  ,ACC_ID, Trunc(PC_PREMIUM.get_paid_thru_date(B.acc_id  )) get_paid_thru_date
   from plan_elections a, account b
              where  plan_election_id is not null and termination_date is null 
              AND a.pers_id =b.pers_id 
              and    Trunc(PC_PREMIUM.get_paid_thru_date(B.acc_id  ))  <=Trunc( SYSDATE)
              and ACCOUNT_STATUS ='1'
                        and a.status in ( 'E',  'P', 'PR') )  
         Loop
          pc_log.log_error('TERMINATE_COBRA_EMPLOYEES', 'The account to be closed x.entrp_id : ' ||  Z.Pers_id) ;
         --- 27/09/2023
            PC_ACCOUNT.CLOSE_QB_EE_ACCOUNT(Z.Pers_id ,  Z.get_paid_thru_date, Z.LAST_UPDATED_BY )  ; 
       End Loop; */ 
	   ----- need to be discussed with COBRA Team / vanitha  25/11/2023 

       --------- term date given in qb screen 36 

        for x in (
            select
                a.pers_id,
                a.acc_id,
                trunc(a.end_date) term_date,
                a.last_updated_by
            from
                account a
            where
                    account_type = 'COBRA'
                and a.pers_id is not null
                and end_date is not null
                and a.entrp_id is null
                and account_status in ( '1', '3' )        -----rprabu 19/10/2023
                and trunc(end_date) <= trunc(sysdate)
        )  ---- rprabu 19/10/2023
         loop

--- 27/07/2023 rprabu  
            pc_account.close_qb_ee_account(x.pers_id, x.term_date, x.last_updated_by);
        end loop;
    end terminate_cobra_qb_employees;
-- added by Jaggi #11629
    function get_salesrep_email (
        p_entrp_id in number
    ) return varchar2 is
        l_email        varchar2(1000);
        l_sales_rep_id number;
    begin
        l_sales_rep_id := pc_account.get_salesrep_id(null, p_entrp_id);
        l_email := pc_sales_team.get_salesrep_email(l_sales_rep_id);
        return l_email;
    exception
        when others then
            l_email := null;
            return l_email;
    end get_salesrep_email;

--- 14/07/2023 rprabu used in COBRA Apex Page 36 for closing QB
    procedure close_qb_ee_account (
        p_pers_id   number,
        p_term_date date,
        p_user_id   number
    )
---  Close the QB account
     is
    begin
			 --	Update the plans elections status
        for x in (
            select
                acc_id,
                termination_reason,
                end_date
            from
                account
            where
                    pers_id = p_pers_id
                and account_status in ( '1', '3' )
        ) loop
            update plan_elections
            set
                status = decode(status, 'E', 'TE', 'P', 'TP',
                                'PR', 'TP', status),
                termination_date = nvl(x.end_date, p_term_date),
                termination_reason = nvl(
                    pc_lookups.get_meaning(x.termination_reason, 'QB_TERMINATION_REASON'),
                    'QB_TERMED'
                )  -----'EMPLOYER_TERMED'
                ,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                terminated_on = sysdate
            where
                    pers_id = p_pers_id
                and status in ( 'P', 'E', 'PR' ); --- rprabu 26/07/2023
 --Update the invoice parameter and rate plans effective end date and also status. ( end dating premium setup)
            update invoice_parameters
            set
                status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    entity_type = 'PERSON'
                and entity_id = p_pers_id;

            pc_log.log_error('TERMINATE_QB_ACCOUNT', 'No of invoice parameters records affected: ' || sql%rowcount);
            update rate_plan_detail
            set
                effective_end_date = p_term_date,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                ( effective_end_date is null
                  or effective_end_date > sysdate )
                and rate_plan_id in (
                    select
                        rate_plan_id
                    from
                        rate_plans
                    where
                            entity_type = 'PERSON'
                        and entity_id = p_pers_id
                );

            pc_log.log_error('TERMINATE_QB_ACCOUNT', 'No of rate_plan_details records affected: ' || sql%rowcount);
            update rate_plans
            set
                status = 'I',
                effective_end_date = p_term_date,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    entity_type = 'PERSON'
                and entity_id = p_pers_id;  
		         -- Cancel the invoices.
            for i in (
                select
                    invoice_id
                from
                    ar_invoice
                where
                        entity_type = 'PERSON'
                    and invoice_reason = 'PREMIUM'
                    and entity_id = p_pers_id
                    and status in ( 'GENERATED', 'PROCESSED', 'DRAFT' )
            ) loop
                pc_invoice.void_invoice(i.invoice_id, p_user_id, 'QB_TERMED', null, 'CANCELLED');  ---EMPLOYER_TERMED
            end loop;

        end loop; 	
      	-- Terminate   QB account
        update account
        set
            end_date = nvl(end_date,
                           last_day(p_term_date)),
            account_status = '4',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                pers_id = p_pers_id
            and account_status in ( '1', '3' );  
       --- EMail Notifications to ER and QB       
			---	PC_COBRA_NOTIFICATIONS.COBRA_ER_TERMINATION_NOTIFICATION( P_Pers_id );  ---- employer email 
			-----	PC_COBRA_NOTIFICATIONS.COBRA_QB_TERMINATION_NOTIFICATION( P_Pers_id );   ---- QB  email   
    exception
        when others then
            pc_log.log_error('CLOSE_QB_EE_ACCOUNT', 'EXCEPTION : ' || sqlerrm);
    end close_qb_ee_account;

-- Added by Joshi for 12006
    function get_acc_num_from_ssn (
        p_ssn in varchar2
    ) return varchar2 is
        l_acc_num account.acc_num%type;
    begin
        for x in (
            select
                a.acc_num
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and replace(b.ssn, '-') = replace(
                    format_ssn(p_ssn),
                    '-'
                )
                and a.account_status not in ( 4 )
        ) loop
            l_acc_num := x.acc_num;
        end loop;

        return l_acc_num;
    end get_acc_num_from_ssn;

end pc_account;
/


-- sqlcl_snapshot {"hash":"386bceba6261bfd501ec31a0d01aaeb55b3a4ebe","type":"PACKAGE_BODY","name":"PC_ACCOUNT","schemaName":"SAMQA","sxml":""}