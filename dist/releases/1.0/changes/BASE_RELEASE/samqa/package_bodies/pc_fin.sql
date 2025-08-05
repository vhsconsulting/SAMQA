-- liquibase formatted sql
-- changeset SAMQA:1754374031595 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_fin.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_fin.sql:null:83e408c56c12ee5cd664e76d25670ff7c449ede8:create

create or replace package body samqa.pc_fin is

    function interate (
        balance_in in number,
        dat_in     in date default trunc(sysdate, 'mm'),
        vid_in     in varchar2
    ) return number is
    /*
    08.08.2005
    > $1-$2000 interest IS 1%
    > $2001-5000 IS 2%
    > $5001 AND above IS 3 %

    > That's what Kevin says. If it is wrong we will blame it on him.
    ---------------
    From: "Kevin Woodard" <kevin.woodard@sterlingadministration.com>
    Date: November 17, 2005 7:21:11 AM PST
    April 1 - August 30  2004
    < 2,000             .05%
    >2000               1.5%
    Sept 1 2004 - June 30 2005
    < 2000              .75%
    >2000               2.0%
    July 1 2005 - Today
    < 1000           1%
    1000 - 5000      2%

    >5000            3%
    CRB Bank        .75% on all
    */
        cursor c1 is
        select
            rate
        from
            bal_rate a
        where
            balance_in between low and hi
            and dfrom <= dat_in
            and a.bank = vid_in
            and a.active = 1
        order by
            dfrom desc; -- new dates first
        retval number;
    begin
        open c1;
        fetch c1 into retval; -- take first row.
        close c1;
        return retval;
    end interate;

    procedure acc_interest (
        acc_in in number,
        dat_in in date,
        amt_in in number,
        am_out out number,
        ch_out out number
    ) is
    /* INSERT or UPDATE record of interest, INCOME.fee_code = 8 */
        cursor c1 is
        select
            change_num,
            amount,
            fee_date
        from
            income
        where
                fee_code = 8 -- interest
            and acc_id = acc_in
            and trunc(fee_date, 'mm') = trunc(dat_in, 'mm'); -- once per month
        r1    c1%rowtype;
        rchan number;
    begin
        open c1;
        fetch c1 into r1;
        close c1;
        rchan := r1.change_num;
   --  dbms_output.put_line('Acc_Intereststart='||dat_in||' '||acc_in||' '|| amt_in ||'='|| rchan||'=');
        if rchan is null -- no record for the interest
         then
            if amt_in <> 0 then -- zero need to re-write previous calculation, but no need to insert zero
                insert into income (
                    change_num,
                    acc_id,
                    fee_date,
                    fee_code,
                    amount,
                    pay_code,
                    note
                ) values ( change_seq.nextval,
                           acc_in,
                           dat_in,
                           8,
                           amt_in,
                           9,
                           null ) returning change_num into rchan;
     -- What PAY_CODE use for interest?    9 = Other money transfer
            else
                null;
            end if;

            am_out := amt_in; -- balance changed
     -- Dbgt('ins'||am_out);
        else
            if
                r1.amount = amt_in
                and r1.fee_date = dat_in
            then -- already recorded
                am_out := 0; -- balance NOT changed
            else
                update income
                set
                    amount = amt_in,
                    fee_date = dat_in
                where
                    change_num = rchan;

                am_out := amt_in - r1.amount; -- balance changed
            end if;
        end if;

        ch_out := rchan;
    end;

    procedure recalc_balance (
        dat_from in date default sysdate - 31,
        dat_to   in date default sysdate,
        acc_in   in number default null  -- NULL means all accounts
        ,
        priz_in  in number default 0  -- 1 = calc %

    ) is
    /*  */
        v_aid      number := 0; -- current acc_id
        v_dat      date := dat_from - 1; -- start date
        v_dat8_end date := sysdate; -- after this date will NOT %%
        pre_date   date;
        pre_days   number;
        v_bal      number(15, 2);
        v_baledic  number(15, 2);
        v_rat      number(15, 4); -- %% anual rate
        v_pp       number(15, 2); -- %% for days
        v_ppm      number(15, 2) := 0; -- %% for month
        v_delta    number(15, 2);
        v_ch       number;
        mm         number := priz_in * ( 1 + months_between(dat_to, dat_from) );
        cursor c1 is
        select distinct
            acc_id,
            fee_date,
            change_num,
            amount,
            fee_code,
            avid,
            pc_account.current_balance(acc_id, from_date, fee_date - 1) balance,
            start_date,
            suspended_date,
            account_reopen_date
        from
            (
                select
                    p.acc_id,
                    p.fee_date,
                    p.change_num,
                    p.amount,
                    p.fee_code,
                    d.plan_sign avid,
                    v.suspended_date,
                    least(
                        nvl((
                            select
                                min(fee_date)
                            from
                                balance_register
                            where
                                acc_id = v.acc_id
                        ),
                            v.start_date),
                        v.start_date
                    )           from_date,
                    v.start_date,
                    v.account_reopen_date
                from
                    acc_op  p -- operations
                    ,
                    account v -- need  avid
                    ,
                    plans   d
                where
                    ( v.acc_id = acc_in  -- this account may be closed
                      or ( acc_in is null
                           and v.account_status in ( 1, 2, 5 ) ) )
                    and p.acc_id = v.acc_id
                    and d.plan_code = v.plan_code
                    and p.fee_date between dat_from and dat_to
                    and v.account_type = 'HSA'
                union all
                select
                    a.acc_id,
                    least(dd,
                          nvl(a.end_date, dat_to)),
                    null,
                    0,
                    8,
                    d.plan_sign avid,
                    a.suspended_date,
                    least(
                        nvl((
                            select
                                min(fee_date)
                            from
                                income
                            where
                                acc_id = a.acc_id
                        ),
                            a.start_date),
                        a.start_date
                    )           from_date,
                    a.start_date,
                    a.account_reopen_date
                from
                    account a,
                    plans   d,
                    (
                        select
                            add_months(
                                last_day(trunc(dat_from)),
                                rownum - 1
                            ) as dd
                        from
                            all_objects
                        where
                            rownum <= mm
                    )
                where
                    ( a.acc_id = acc_in
                      or ( acc_in is null
                           and a.account_status in ( 1, 2, 5 ) ) )
                    and dd between a.start_date and last_day(nvl(a.end_date, dat_to))
                    and a.account_type = 'HSA'
                    and not exists (
                        select
                            null
                        from
                            income i
                        where
                                i.acc_id = a.acc_id
                            and i.fee_date = dd
                            and fee_code = 8
                    )
                    and a.plan_code = d.plan_code
            )
        order by
            1,
            2,
            3;

    begin
        for r1 in c1 loop
            if v_aid != r1.acc_id then -- new acc
                v_aid := r1.acc_id;
                v_dat := greatest((dat_from - 1),
                                  nvl(r1.account_reopen_date, r1.start_date)); --r1.FEE_DATE;
                v_ppm := 0;
                v_pp := 0;
            end if;

            if
                trunc(r1.fee_date) <= trunc(nvl(r1.suspended_date, sysdate + 1))
                and trunc(r1.fee_date) >= trunc(nvl(r1.account_reopen_date, r1.fee_date))
                and r1.balance > 0
            then
                pre_date := v_dat;
                v_dat := r1.fee_date;
                pre_days := v_dat - pre_date; --  +1 ?

                v_rat := pc_fin.interate(r1.balance, v_dat, r1.avid); -- % rate for whole year
                v_pp := r1.balance * ( power(1 + v_rat / 100, pre_days / 365) - 1 ); -- %% money for pre_days

                if v_pp > 0 then -- %% have a sense
                    v_ppm := v_ppm + v_pp; -- sum days for month
                end if;
                v_bal := v_bal + r1.amount;
              -- Write interest
                if
                    r1.fee_code = 8  -- the record for %%
                    and v_dat < v_dat8_end -- not in future
                then
                    if v_ppm < 0 then -- negative %% have not sense
                        v_ppm := 0; -- write zero%% to re-write previous calculation
                    end if;
                    pc_fin.acc_interest(v_aid, v_dat, v_ppm, v_delta, v_ch);
                    v_ppm := 0; -- saved month %% , now start new month
                else
                    v_ch := null; -- NO %% in future!
                end if;

            end if;

        end loop;
    end recalc_balance;

    procedure calc_balance (
        acc_in in number default null,
        dat_in in date default trunc(sysdate, 'mm')
    ) is
    /* Mark account, date of last in/out money -
      for recalc balance from this date.
    */

   /* CURSOR c1 IS
    SELECT BROKER_FIRE -- this field not in use, let use it for mark!
      FROM ACCOUNT
     WHERE ACC_ID = acc_in;
      r1 c1%ROWTYPE;*/
    begin
      /* OPEN c1;
      FETCH c1 INTO r1;
      CLOSE c1;
      IF r1.broker_fire <= dat_in
      THEN NULL; -- existing mark date early, no need to change
      ELSE -- mark is NULL or >  dat_in
        UPDATE ACCOUNT
           SET broker_fire = dat_in -- earliest date
         WHERE acc_id = acc_in;
      END IF;*/
        null;
    end calc_balance;

    procedure take_setup (
        acc_in in number,
        dat_in in date,
        fee_in in number
    ) is
        cnt     number;
        inc_cnt number;
    begin
        select
            count(*)
        into inc_cnt
        from
            income
        where
            acc_id = acc_in;
    -- Take fees only if the account balance is positive
        if inc_cnt > 0 then
            if pc_account.acc_balance(acc_in) > 0 then
                select
                    count(change_num)
                into cnt
                from
                    payment
                where
                        acc_id = acc_in
                    and reason_code = 1; -- Set Up fee
                if cnt = 0 then
                    insert into payment (
                        change_num,
                        acc_id,
                        pay_date,
                        amount,
                        reason_code,
                        claim_id,
                        pay_num,
                        note
                    ) values ( change_seq.nextval,
                               acc_in,
                               dat_in,
                               fee_in,
                               1,
                               null,
                               null,
                               'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss') );

                    insert_fee_for_bank(acc_in, 1, fee_in);
                elsif cnt = 1 then
                    null;
                else
                    null;
                end if;

            end if;

        end if;

    end take_setup;

    procedure take_month (
        acc_in in number,
        dat_in in date,
        fee_in in number
    ) is
    /*
      Take monthly fee from acc_in
    */
        cnt            number;
        l_fee          number;
        l_beg_bal      number := 0;
        l_end_bal      number := 0;
        l_account_type varchar2(10);
        l_start_date   date;
        l_transaction  varchar2(1) := 'N';
    begin
        select
            count(change_num)
        into cnt
        from
            payment
        where
                acc_id = acc_in
            and reason_code = 2
            and trunc(pay_date, 'mm') = trunc(dat_in, 'mm');

        l_account_type := pc_account.get_account_type(acc_in);
        pc_log.log_error('cnt', cnt
                                || ' l_account_type :'
                                || l_account_type
                                || ' dat_in :='
                                || dat_in);

        pc_log.log_error('balance',
                         pc_account.current_balance(acc_in));
        if cnt = 0 then -- no the fee, let take it
            if l_account_type = 'LSA' then    -- IF Cond. LSA Added by Swamy for Ticket#10104
                l_beg_bal := pc_account.acc_balance(acc_in,
                                                    '01-jan-2004',
                                                    trunc(dat_in, 'mm'));

                l_end_bal := pc_account.acc_balance(acc_in, '01-jan-2004', dat_in);
                l_start_date := to_date ( '01-jan-2004', 'dd-mon-yyyy' );
                l_transaction := pc_account.check_minimum_balance(acc_in, l_account_type, l_start_date, dat_in);
                pc_log.log_error('l_beg_bal',
                                 l_beg_bal
                                 || ' l_end_bal :'
                                 || l_end_bal
                                 || ' bal :='
                                 || pc_account.current_balance(acc_in)
                                 || ' l_transaction :='
                                 || l_transaction);

                if (
                    pc_account.current_balance(acc_in) > 0
                    and ( l_beg_bal + l_end_bal ) / 2 < 30000
                )
                or l_transaction = 'Y' then
                    insert into payment (
                        change_num,
                        acc_id,
                        pay_date,
                        amount,
                        reason_code,
                        claim_id,
                        pay_num,
                        note
                    ) values ( change_seq.nextval,
                               acc_in,
                               dat_in,
                               fee_in,
                               2,
                               null,
                               null,
                               'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss') );

                end if;

            else             -- Code ends by Swamy for Ticket#10104
                if pc_account.current_balance(acc_in) > 0 then
                    l_beg_bal := pc_account.acc_balance(acc_in,
                                                        '01-jan-2004',
                                                        trunc(dat_in, 'mm'));

                    l_end_bal := pc_account.acc_balance(acc_in, '01-jan-2004', dat_in);
                    if ( l_beg_bal + l_end_bal ) / 2 < 30000 then
                        insert into payment (
                            change_num,
                            acc_id,
                            pay_date,
                            amount,
                            reason_code,
                            claim_id,
                            pay_num,
                            note
                        ) values ( change_seq.nextval,
                                   acc_in,
                                   dat_in,
                                   fee_in,
                                   2,
                                   null,
                                   null,
                                   'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss') );

                        insert_fee_for_bank(acc_in, 2);
                    end if;

                end if;
            end if;
        elsif cnt = 1 then
            null; -- already taken. may check amount = fee_in
        else
            null; --RAISE; if > 1 then error!!
        end if;

    end take_month;

    procedure take_fees (
        acc_in in number default null,
        dat_in in date default trunc(sysdate, 'mm')
    ) is

        cursor acc_cur is
        select
            a.acc_id,
            a.enrollment_source,
            decode(a.plan_code,
                   401,
                   pc_plan.fee_value(a.plan_code, 1),
                   nvl(fee_setup,
                       pc_plan.fee_value(a.plan_code, 1))) fee_setup,
            nvl(
                pc_plan.fmonth_er(b.entrp_id)
                --  , Pc_Plan.fee_value(A.plan_code, 2)) FeeMon -- changing for teamster
                 -- Added by Joshi for 5363. to get the monthy fee for e-HSA plan(paper)
                ,
                case
                        when(
                            a.enrollment_source = 'PAPER'
                            and a.plan_code = 8
                        ) then
                            pc_plan.fmonth_ehsa_paper(a.plan_code)
                        else pc_plan.fee_value(a.plan_code, 2)
                    end
            )                                              feemon
              --Employer Online Portal
            ,
            pc_plan.fannual(a.plan_code)                   fee_annual,
            a.start_date,
            a.reg_date,
            a.account_reopen_date,
            case
                when a.account_reopen_date is not null
                     and trunc(a.account_reopen_date, 'MM') = dat_in then
                    dat_in
                when trunc(a.start_date, 'MM') = dat_in then
                    dat_in
                when ( trunc(a.start_date, 'MM') < dat_in
                       or trunc(a.account_reopen_date, 'MM') < dat_in ) then
                    dat_in - 1
            end                                            sdat,
            trunc(sysdate, 'mm')                           edat
               --Employer Online Portal
            ,
            trunc(sysdate, 'rr')                           eyear,
            a.plan_code,
            a.pers_id,
            a.plan_change_date,
            a.account_type    -- Added by Swamy for Ticket#10104
            ,
            b.entrp_id        -- Added by Swamy for Ticket#10414 15/11/2021
        from
            account a,
            person  b
        --WHERE (ACC_ID = 334332 OR (334332 IS NULL AND a.PERS_ID IS NOT NULL AND account_status IN (1,2,5)))
        where
            ( acc_id = acc_in
              or ( acc_in is null
                   and a.pers_id is not null
                   and account_status in ( 1, 2, 5 ) ) )
            and a.pers_id = b.pers_id
            and account_type in ( 'HSA', 'LSA' ) -- LSA Added by Swamy for Ticket#10104
        order by
            1;

        mon                date;
        l_card_id          number;
        l_fee_mon          number;    -- Added by Swamy for Ticket#10414 15/11/2021
        l_chk_flg          varchar2(1) := 'Y';
        l_rate_plan_exists varchar2(1) := 'N';
    begin
        for acc_rec in acc_cur loop
           -- Start Added by Swamy for Ticket#10414 15/11/2021
           -- For HSA ONLY, the monthly fees should be as per the customised employer monthly fee for the Employees who are disassociated/terminated from the employer.
            l_fee_mon := acc_rec.feemon;
            l_chk_flg := 'Y'; -- Added by Swamy for Ticket# 23/01/2023
            if
                acc_rec.account_type = 'HSA'
                and nvl(acc_rec.entrp_id, -1) = -1
            then
                for y in (
                    select
                        old_entrp_id
                    from
                        account_history
                    where
                            acc_id = acc_rec.acc_id
                        and nvl(old_entrp_id, -1) <> - 1
                    order by
                        creation_date desc
                    fetch first 1 rows only
                ) loop
                   /*for k in (select fee_maint from account where entrp_id = y.old_entrp_id) loop
                      l_fee_mon := nvl(k.fee_maint,acc_rec.FeeMon);
                   end loop;*/
                    l_fee_mon := nvl(
                        pc_plan.fmonth_er(y.old_entrp_id),
                        acc_rec.feemon
                    );
                end loop;
            end if;
	       -- End of Ticket#10414

            if acc_rec.plan_code not in ( 5, 6, 7 ) then
                pc_log.log_error('Take Fees..loop', sql%rowcount);
			-- Only for HSA setupfee is required and not for LSA
                if acc_rec.account_type = 'HSA' then   -- IF cond added by Swamy for Ticket#10104
                    take_setup(acc_rec.acc_id, acc_rec.start_date, acc_rec.fee_setup);
                    pc_log.log_error('Take Fees..loop', 'After Setup');
                end if;

                mon := acc_rec.sdat;  -- NVL(dat_in,
                pc_log.log_error('acc_rec.sdat', mon);
                pc_log.log_error('acc_rec.edat',
                                 trunc(acc_rec.edat, 'MM'));
                while trunc(mon, 'MM') < trunc(acc_rec.edat, 'MM') loop
                    pc_log.log_error('TAke month loop', mon
                                                        || ' acc_rec.account_type :='
                                                        || acc_rec.account_type
                                                        || 'acc_rec.entrp_id :='
                                                        || acc_rec.entrp_id);

               -- Added below by Swamy for Ticket#12122 19/04/2024 
               -- For LSA, system should check if there is invoice parameter setup, if no then it should charge the monthly fee from plan_fee table.
               -- If there is invoice setup, then it should check if there is any invoice generated and then check if an employee is included in the invoice.
               -- If an employee is not included in the invoice then it should not change the monthly fee.
                 /*
                 l_rate_plan_exists := 'N';
                 FOR m IN (SELECT 'Y' l_exists 
                                    FROM invoice_parameters a,rate_plans b
                                   WHERE a.entity_id = b.entity_id
                                     AND a.payment_method = 'DIRECT_DEPOSIT'
                                     AND b.status = 'A'
                                     AND a.invoice_type = 'FEE'
                                     AND a.status = 'A'
                                     AND a.entity_id = acc_rec.ENTRP_ID)
                LOOP
                    l_rate_plan_exists := m.l_exists;
				END LOOP;
                */

               -- Added if cond by Swamy for Ticket#11453 23/01/2023
                    if
                        acc_rec.account_type = 'LSA'
                        and nvl(acc_rec.entrp_id, -1) <> -1
                    then   
                  -- Check if Employee is included in invoice. Deduct the fees amount only if the employee is included in the invoice.
                  -- Do not deduct the fees amount if employee is not included in the invoice.
                        l_chk_flg := 'Y';
                        pc_log.log_error('**1 TAke month loop mon', mon
                                                                    || ' acc_rec.pers_id :='
                                                                    || acc_rec.pers_id
                                                                    || 'acc_rec.entrp_id :='
                                                                    || acc_rec.entrp_id);

                        l_chk_flg := pc_fin.chk_employee_included_in_invoice(acc_rec.entrp_id, acc_rec.pers_id, mon);
                        pc_log.log_error(' **1 for acc_rec.pers_id', acc_rec.pers_id
                                                                     || 'l_chk_flg :='
                                                                     || l_chk_flg);
                    end if;
               -- END Ticket#11453

                    pc_log.log_error(' **2 for acc_rec.pers_id', acc_rec.pers_id
                                                                 || 'l_chk_flg :='
                                                                 || l_chk_flg);

               -- Added by Joshi 12122
               -- For LSA, system should check if there is invoice parameter setup, if no then it should charge the monthly fee from plan_fee table.
               -- If there is invoice setup, then it should check if there is any invoice generated and then check if an employee is included in the invoice.
               -- If an employee is not included in the invoice then it should not change the monthly fee.
                    if acc_rec.account_type = 'LSA' then
                        if l_chk_flg = 'Y' then
                            take_month(acc_rec.acc_id,
                                       last_day(mon),
                                       l_fee_mon);   -- Replaced acc_rec.FeeMon with l_fee_mon Swamy for Ticket#10414 15/11/2021
                        else
                            if (
                                acc_rec.enrollment_source = 'PAPER'
                                and acc_rec.plan_code = 8
                            ) then
                                l_fee_mon := pc_plan.fmonth_ehsa_paper(acc_rec.plan_code);
                            else
                                l_fee_mon := pc_plan.fee_value(acc_rec.plan_code, 2);
                            end if;

                            take_month(acc_rec.acc_id,
                                       last_day(mon),
                                       l_fee_mon);
                        end if;
                    else
                        if nvl(l_chk_flg, 'Y') = 'Y' then  -- IF cond Added for Ticket#11453
                            take_month(acc_rec.acc_id,
                                       last_day(mon),
                                       l_fee_mon);   -- Replaced acc_rec.FeeMon with l_fee_mon Swamy for Ticket#10414 15/11/2021
                        end if;
                    end if;

                    mon := add_months(mon, 1);
                end loop; -- WHILE mon
            else --Annual Fees for New plans
               --Employer Online Portal
               --For all new HSA accounts ,we calculate Annual fees
                take_annual(acc_rec.acc_id, sysdate, acc_rec.fee_annual);
            end if; --FOr Standard and Value monthly fee gets cut

            pc_log.log_error('In FIN..Yr', 'After Calc Annual');
            select
                count(*)
            into l_card_id
            from
                card_debit
            where
                card_id = acc_rec.pers_id;

            if
                l_card_id > 0
                and pc_account.acc_balance(acc_rec.acc_id) > 0
                and acc_rec.plan_change_date is null
            then
                card_open_fee(acc_rec.pers_id);
            end if;

        end loop; -- FOR acc_rec
    end take_fees;

    procedure insert_fee_for_bank (
        p_acc_id     in number,
        p_fee_reason in number,
        p_amount     number default 0,
        p_claim_id   number default null
    ) is
    begin
        for y in (
            select
                'X'
            from
                account
            where
                    acc_id = p_acc_id
                and plan_code = 401
        ) loop
            for x in (
                select
                    decode(p_amount, 0, fee_amount, p_amount) fee_amount
                from
                    plan_fee
                where
                        fee_code = p_fee_reason
                    and plan_code = 2
            ) loop
                insert into fremont_bank_stmt values ( p_acc_id,
                                                       p_fee_reason,
                                                       x.fee_amount,
                                                       sysdate,
                                                       p_claim_id );

            end loop;
        end loop;
    end insert_fee_for_bank;

    function allow_fee (
        acc_id_in in account.acc_id%type,
        year_in   in date default sysdate
    ) return number is

        jany  date := trunc(year_in, 'yyyy');
        decy  date := add_months(jany, 11);
        mons  number;
        d1    date;
        d2    date;
        cursor c1 is
        select
            fee_setup,
            fee_maint / 2           as feemon,
            trunc(start_date, 'mm') as dstart,
            trunc(end_date, 'mm')   as dend
        from
            account
        where
                acc_id = acc_id_in
            and account_type = 'HSA';

        r1    c1%rowtype;
        ret_v number;
    begin
        open c1;
        fetch c1 into r1;
        close c1;
        d1 := greatest(r1.dstart, jany);
        d2 := least(
            nvl(r1.dend, decy),
            decy
        );
        mons := 1 + months_between(d2, d1);
        mons := greatest(mons, 0);
        ret_v := mons * r1.feemon;
        if trunc(r1.dstart, 'yyyy') = jany then
            ret_v := ret_v + r1.fee_setup;
        end if;

        return nvl(ret_v, 0);
    end allow_fee;

    function receipts (
        acc_id_in in account.acc_id%type,
        year_in   in date default sysdate
    ) return number
    /*
    14.12.2005 mal exclude fee_codes - by fee_type
    14.06.2005 mal This is former FUNCTION Pc_Person.payed
    02.06.2005 mal  fee_code NOT IN  ... 5,7
    Tanya wrote 02 June 2005:
    So when you calculate the Allowable it should NOT take into
    account the Receipts with the reasons:
    Roll-over and Contribution for the previous year.
    */ is
        ret_v number;
    begin
        return pc_account.year_income(acc_id_in, year_in);
      -- difference - only 5 = Roll-over - need ask Tanya
    end receipts;

    procedure allows (
        pers_id_in in person.pers_id%type,
        year_in    in date default sysdate,
        deduc_out  out number  -- ???????? ?????
        ,
        add_out    out number   -- ??????? ?? ????????
    ) is
    /*

    Tanya 20.01.2005: about over 55 adjustment:
    if the person has insurance only 6 months in this year, he
    only $300 additional contribution.
    Also it should be adjusted by the Month of his birth if he
    is 55 this year. So if his B-day is in December, he can get
    only $50. How do you like this?
    Tanya 02.06.2005:
      The maximum contribution for 2005 is the lesser of
      the amount of the high-deductible health plan's annual deductible
       or $2,650 for an individual or $5,250 for a family.

     03.06.2005 mal + alow,  -let55
     21.01.2005 mal + YEAR_IN. :1:2:3:4:5:6 55 :7:8:9:10:11:12 :13:14 :15:16:17:18:19 :20:21:22:23:24:25:26:27, $600 :28:29:30:31:32:33:34:35:36:37:38:39:40:41:42
     05.01.2005 mal + c55
     13.10.2004 mal :43:44:45:46:47:48:49:50
     */
        jany    date := trunc(year_in, 'yyyy'); -- :51:52:53:54:55:56 :57:58:59:60:61:62 :63:64:65:66:67:68:69:70:71:72 :73:74:75:76
        decy    date := add_months(jany, 11);  -- :77:78:79:80:81:82 :83:84:85:86:87:88:89 :90:91:92:93:94:95:96:97:98:99 :100:101:102:103
    --   let55 DATE := ADD_MONTHS(jany, -54*12) -1; -- 31 :104:105:106:107:108:109:110 55 :111:112:113 :114:115:116:117:118,
        -- :119:120:121 :122:123:124:125:126:127:128 :129:130:131:132:133:134, :135:136:137:138 :139 :140:141:142:143 :144:145:146:147 :148:149:150:151 :152:153:154 :155:156:157:158:159 55 :160:161:162, :163:164:165:166:167 :168:169:170:171:172:173.
        mons    number;   -- :174:175:176:177:178:179:180:181:182:183 :184:185:186:187:188:189:190 :191:192:193:194:195:196:197:198 :199:200:201:202:203:204:205:206:207 :208 :209:210:211:212 :213:214:215:216
        d1      date;
        d2      date;
        s55     number;
        fam     number; -- :217:218:219:220:221:222:223:224:225:226 :227:228:229:230:231:232 :233:234:235:236:237
        alow    number;
        afee    number;
        alow_up number; -- Catch_up
        cursor c1 is
        select
            trunc(start_date, 'mm') as dstart,
            trunc(end_date, 'mm')   as dend,
            plan_type,
            deductible  -- :238:239:240 :241:242:243:244:245 :246:247 :248:249:250:251 :252:253:254
        from
            insure
        where
            pers_id = pers_id_in;

        r1      c1%rowtype;

    -- add $ ALLOW_CATCH_UP for older 55, but <= 2 persons.
        cursor c55 is
        select
            pers_id,
            pers_main,
            birth_date,
            months_between(sysdate, birth_date) / 12 m55
       --    , GREATEST(0, LEAST(mons, -- not longer, valid insurance
       --  1 + MONTHS_BETWEEN(d2, TRUNC(NVL(BIRTH_DATE, year_in), 'mm')) - 55*12)) AS m55
        from
            person -- for young person m55 = 0
        where -- Slow! NVL(PERS_MAIN, PERS_ID) = PERS_id_in
            ( pers_main = pers_id_in  -- count family
              or pers_id = pers_id_in ) -- account holder
        order by
            birth_date;

    begin
        open c1;
        fetch c1 into r1;
        close c1;
  /*     d1 := GREATEST (r1.dstart, jany);      -- :255:256:257:258:259:260 :261:262:263:264:265:266:267:268:269 :270:271:272 :273:274:275:276, :277:278:279 :280:281:282:283:284
       d2 := LEAST(NVL(r1.dend, decy), decy); -- :285:286:287:288:289:290:291:292:293 :294:295:296:297:298:299:300:301:302 :303:304:305 :306:307:308:309, :310:311:312 :313:314:315:316:317:318
       mons := 1 + MONTHS_BETWEEN(d2, d1);    -- months valid insurance
       mons := GREATEST(mons, 0); -- :319:320:321:322:323:324:325:326 mons < 0, :327:328:329:330:331:332:333:334 :335:336:337:338:339:340:341:342:343 :344:345:346:347:348:349:350:351 :352:353:354:355:356 :357:358:359:360:361:362:363:364:365 :366:367:368:369
         s55 := 0; fam := 0;
         FOR r55 IN c55 LOOP
           fam := fam + 1;
           s55 := s55 + r55.m55 * alow_up / 12; -- for each month older 55
         END LOOP;
         s55 := LEAST(s55, alow_up * 2); -- limit 2 persons*/

        for r55 in c55 loop
            s55 := r55.m55; -- for each month older 55
        end loop;
        if r1.plan_type = 1 then
            alow := pc_param.get_value('FAMILY_CONTRIBUTION', year_in);
        else
            alow := pc_param.get_value('INDIVIDUAL_CONTRIBUTION', year_in);
        end if;

        if s55 > 55 then
            alow_up := nvl(
                pc_param.get_value('CATCHUP_CONTRIBUTION', year_in),
                1000
            );
        end if;

     --  alow := LEAST(alow, r1.deductible);
     --  Pc_Fin.pv_allow_deduct_year := alow;
     --  deduc_out := alow / 12 * mons;
    --   afee := Pc_Fin.allow_fee(Pc_Person.acc_id(pers_id_in), year_in); -- Expected fees
   --    deduc_out := ROUND(deduc_out + afee, 2); -- ADD FEES
        deduc_out := alow;
        add_out := alow_up;
     --    add_out   := ROUND(s55, 2);
    end allows;

    procedure card_open_fee (
        pers_id_in in person.pers_id%type
    ) is
    /* Take fee (16) when open debit card
       date        author           description
       ---------  ----------  ---------------  ------------------------------------
     24.03.2006 mal  Add feecur, use PLAN_FEE.FEE_AMOUNT instead of program constants
     15.06.2005 mal  Created this procedure.
    */
        cursor acur is
        select
            p.pers_main,
            a.plan_code,
            a.acc_id,
            p.pers_id                                 as pmain -- account holder
            ,
            first_name
            || ' '
            || last_name                              as pname,
            (
                select
                    count(*)
                from
                    payment
                where
                        payment.acc_id = a.acc_id
                    and reason_code = 16
            )                                         pay_count,
            pc_plan.fcustom_fee_value(p.entrp_id, 16) card_open_custom_fee,
            pc_plan.fcustom_fee_value(p.entrp_id, 66) dep_card_custom_fee
        from
            person  p,
            account a
        where
                p.pers_id = pers_id_in -- this person has card
            and a.pers_id = p.pers_id
            and a.account_type = 'HSA'; -- but accoun holder may be another person

        arec         acur%rowtype;
        tmpvar       number;
        l_card_count number := 0;
    begin
       --   dbms_output.put_line('card open fee : pers main '||pers_id_in);
        open acur;
        fetch acur into arec;
        close acur;
        select
            count(*)
        into l_card_count
        from
            card_debit
        where
            card_id = pers_id_in;

        if
            l_card_count = 1
            and arec.pay_count = 0
        then
            if arec.card_open_custom_fee is null then
                tmpvar := pc_plan.fee_value(arec.plan_code, 16, 1);
            else
                tmpvar := arec.card_open_custom_fee;
            end if;

            if tmpvar > 0 then
                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    note
                )
                    select
                        change_seq.nextval,
                        arec.acc_id,
                        trunc(sysdate),
                        tmpvar,
                        16,
                        'Generate fee for ' || arec.pname
                   -- debug ||' pers='||arec.pmain||' plan='||arec.plan_code ||' cnt='||prec.cnt
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                payment
                            where
                                    payment.acc_id = arec.acc_id
                                and reason_code = 16
                        );

            end if;

        end if;

        tmpvar := 0;
        l_card_count := 0;
        for x in (
            select
                count(*)                                cnt,
                c.card_id,
                d.pers_main,
                c.issue_date,
                d.first_name
                || ' '
                || d.last_name                          pname,
                pc_person.count_debit_card(d.pers_main) card_cnt
            from
                card_debit a,
                person     b,
                card_debit c,
                person     d
            where
                    b.pers_main = pers_id_in
                and a.issue_date = to_char(sysdate, 'YYYYMMDD')
                and a.card_id = b.pers_id
                and b.pers_main = d.pers_main
                and c.card_id = d.pers_id
                and pc_person.count_debit_card(d.pers_main) > 2
            group by
                c.card_id,
                d.pers_main,
                c.issue_date,
                d.first_name
                || ' '
                || d.last_name
            having
                count(*) = 1
            order by
                d.pers_main
        ) loop
            if
                x.card_cnt > 2
                and x.cnt = 1
                and x.issue_date = to_char(sysdate, 'YYYYMMDD')
            then
                if arec.dep_card_custom_fee is null then
                    tmpvar := pc_plan.fee_value(arec.plan_code, 16, 1);
                else
                    tmpvar := arec.dep_card_custom_fee;
                end if;

                if tmpvar > 0 then
                    insert into payment (
                        change_num,
                        acc_id,
                        pay_date,
                        amount,
                        reason_code,
                        note
                    ) values ( change_seq.nextval,
                               arec.acc_id,
                               trunc(sysdate),
                               tmpvar * x.cnt,
                               66,
                               'Generate fee for '
                               || x.pname
                               || ' dependant ' );

                end if;

            end if;
        end loop;

    end card_open_fee;

    procedure card_claim_fee (
        acc_id_in   in payment.acc_id%type,
        claim_id_in in payment.claimn_id%type,
        source_in   in varchar2 default 'MBI'
    ) is
    /* purpose: take fee (17) when pay claim from debit card (value plan only)
       revisions:
       date        author           description
       ---------  ----------  ---------------  ------------------------------------
      27.03.2006 mal Get fee_amount by Pc_Plan.fee_value
      15.06.2005 mal Created this procedure.
    */
        cursor acur is
        select
            plan_code,
            p.entrp_id
        from
            account a,
            person  p
        where
                acc_id = acc_id_in
            and a.pers_id = p.pers_id
            and account_type = 'HSA';

        arec   acur%rowtype;
        tmpvar number;
    begin
        open acur;
        fetch acur into arec;
        close acur;
        tmpvar := pc_plan.fcustom_fee_value(arec.entrp_id, 17);
        if tmpvar is null then
            tmpvar := pc_plan.fee_value(arec.plan_code, 17);
        end if;

        if tmpvar <> 0 then
            insert into payment (
                change_num,
                acc_id,
                pay_date,
                amount,
                reason_code,
                claimn_id,
                note
            )
                select
                    change_seq.nextval,
                    acc_id_in,
                    pay_date,
                    tmpvar,
                    17,
                    claim_id_in,
                    'Generate fee for claim '
                    || (
                        select
                            claim_code
                        from
                            claimn
                        where
                            claim_id = payment.claimn_id
                    )
                from
                    payment
                where
                    not exists (
                        select
                            *
                        from
                            payment
                        where
                                acc_id = acc_id_in
                            and claimn_id = claim_id_in
                            and reason_code = 17
                    )
                        and acc_id = acc_id_in
                        and claimn_id = claim_id_in
                        and reason_code = 13;

        else
            null; --  zero or null no need to INSERT
        end if;

        if arec.plan_code = 401 then
            insert_fee_for_bank(acc_id_in, 17);
        end if;
    end card_claim_fee;

    procedure payment_fee_insert (
        acc_id_in          in payment.acc_id%type,
        change_num_in      in payment.change_num%type,
        reason_code_in     in number,
        p_orig_reason_code in number
    ) is
    begin
        for x in (
            select
                a.acc_id,
                pc_plan.fee_value(plan_code, reason_code_in) fee_amount,
                pc_lookups.get_reason_name(reason_code_in)
                || ' for change_num '
                || b.change_num
                || ' and pay date '
                || to_char(b.pay_date, 'MM/DD/YYYY')
                || ' ,amount '
                || nvl(b.amount, '')                         note
            from
                account a,
                payment b
            where
                    a.acc_id = acc_id_in
                and a.acc_id = b.acc_id
                and b.change_num = change_num_in
                and b.reason_code = p_orig_reason_code
        ) loop
            insert into payment (
                change_num,
                acc_id,
                pay_date,
                amount,
                reason_code,
                claimn_id,
                note,
                pay_num
            )
                select
                    change_seq.nextval,
                    acc_id_in,
                    sysdate,
                    x.fee_amount,
                    reason_code_in,
                    null,
                    x.note,
                    change_num_in
                from
                    payment
                where
                        change_num = change_num_in
                    and not exists (
                        select
                            *
                        from
                            payment
                        where
                                acc_id = acc_id_in
                            and reason_code = reason_code_in
                            and pay_num = change_num_in
                    );

        end loop;
    end payment_fee_insert;

    procedure delete_fee (
        acc_id_in          in payment.acc_id%type,
        change_num_in      in payment.change_num%type,
        reason_code_in     in number,
        p_orig_reason_code in number
    ) is
    begin
        insert into payment (
            change_num,
            acc_id,
            pay_date,
            amount,
            reason_code,
            claimn_id,
            note,
            pay_num
        )
            select
                change_seq.nextval,
                acc_id_in,
                sysdate,
                - amount,
                reason_code_in,
                null,
                'Adjusting for deleted returned cheque, change_num_in ' || change_num_in,
                change_num_in
            from
                payment
            where
                pay_num = change_num_in;

    end delete_fee;

    function allow_deduct_year (
        acc_id_in in account.acc_id%type,
        year_in   in date default sysdate
    ) return number is
        deduc_out number; -- :370:371:372:373:374:375:376:377 :378:379:380:381:382
        add_out   number; -- :383:384:385:386:387:388:389 :390:391 :392:393:394:395:396:397:398:399
    begin
        pc_fin.allows(
            pc_person.pers_id_from_acc_id(acc_id_in),
            year_in,
            deduc_out,
            add_out
        );
        return pc_fin.pv_allow_deduct_year;
    end;

    procedure need_calc_balance (
        acc_in in number
    ) is

    /* check, and recalc balance, if need
     from date last changed
    */
        cursor c1 is
        select
            start_date,
            end_date--, broker_fire  -- date last changed
        from
            account
        where
                acc_id = acc_in
            and account_type = 'HSA';

        r1                 c1%rowtype;
        need_calc_interest number;
    begin
        open c1;
        fetch c1 into r1;
        close c1;
        if r1.end_date is null  -- open account
         then
            need_calc_interest := 1;
        else
            need_calc_interest := 0; -- only balance, no interest
        end if;

        pc_fin.recalc_balance(
            trunc(trunc(r1.start_date, 'mm') - 1,
                  'MM'),
            trunc(sysdate) + 1,
            acc_in,
            need_calc_interest
        );
       -- 28.01.2006 change r1.broker_fire to r1.start_date -
      -- will calc from very begining, to avoid error from "double balances"
      -- record at date r1.broker_fire may be just inserted and have NULL balance,

      -- but we need real previous balance to recalc
      -- Start from 1st of previous month, to calc correct interest.
    end need_calc_balance;

    procedure dbgt (
        str in varchar2,
        pp  number default null
    ) is
        pragma autonomous_transaction;
    begin
        if pc_fin.pv_debug = 1 then
            insert into trc_log (
                username,
                curdate,
                line
            ) values ( pp,
                       sysdate,
                       str );

            commit;
        else
            null; -- no debug, nothing to do
        end if;
    end;

    function get_balance (
        acc_in in number,
        dat_in in date default sysdate
    ) return number is
    /* balance for show in reports =   all income - all payment
    09.04.2006 mal created
    */
        cursor c1 is
        select
            sum(amount) as sam
        from
            balance_register
        where
                acc_id = acc_in
            and fee_date <= dat_in
            and reason_mode <> 'C';

        retval number;
    begin
        open c1;
        fetch c1 into retval;
        close c1;
        return retval;
    end get_balance;

    function get_balancint (
        acc_in in number,
        dat_in in date default sysdate
    ) return number is
    /* balance for calc interest =   all income,but 13 - all payment + card transfer
    23.04.2006 mal created
    */
        cursor c1 is
        select
            sum(amount)
        from
            balance_register
        where
                acc_id = acc_in
            and fee_date <= dat_in
            and reason_mode <> 'C';

        retval number;
    begin
        open c1;
        fetch c1 into retval;
        close c1;
        return retval;
    end get_balancint;

    procedure bill_pay_fee (
        p_acc_id in number default null
    ) is
    begin
      --Earlier check cutting fees was hard coded.Now dynamically picking from PLAN_FEE table
        for x in (
            select
                a.acc_id,
                a.pay_date,
                (
                    select
                        fee_amount
                    from
                        plan_fee pf
                    where
                            fee_code = 14 --Bill pay fee
                        and pf.plan_code = b.plan_code
                )                  as amount,
                14                 as reason_code,
                'generate for claim '
                || claimn_id
                || ' ch_num='
                || min(change_num) as note,
                plan_code,
                a.claimn_id
            from
                payment a,
                (
                    select
                        acc_id,
                        plan_code,
                        nvl(plan_change_date, start_date) plan_change_date
                    from
                        account
                    where
                        account_status in ( 1, 4, 5 )
                        and account_type = 'HSA'
                        and plan_code not in ( 1, 101, 201, 501, 401,
                                               504, 4 )
                )       b
            where
                reason_code in ( 11, 12 )  -- We don't charge ANY fees for ePayment. (19)
                and pay_date >= '01-jan-2013'
                and pay_date >= plan_change_date
                and claimn_id is not null
                and a.acc_id = b.acc_id
                and ( p_acc_id is null
                      or b.acc_id = p_acc_id )
                and not exists (
                    select
                        null
                    from
                        payment b
                    where
                            a.acc_id = b.acc_id
                        and trunc(a.pay_date) = trunc(b.pay_date)
                        and a.claimn_id = b.claimn_id
                        and b.reason_code = 14
                        and note like '% claim '
                                      || claimn_id
                                      || '%'
                )
            group by
                a.acc_id,
                pay_date,
                claimn_id,
                plan_code
        ) loop
            if x.amount > 0 then
                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    note,
                    claimn_id
                ) values ( change_seq.nextval,
                           x.acc_id,
                           x.pay_date,
                           x.amount,
                           14,
                           x.note,
                           x.claimn_id );

            end if;
        end loop;
    end bill_pay_fee;

    function get_bill_pay_fee (
        p_acc_id in number
    ) return number is
        l_amount       number;
        l_account_type varchar2(10);   -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin

        -- Below For loop added by Swamy for Ticket#9912 on 10/08/2021
        for j in (
            select
                account_type
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_account_type := j.account_type;
        end loop;

        for x in (
            select
                nvl(b.fee_amount, 0) amount
            from
                account  a,
                plan_fee b
            where
                    a.plan_code = b.plan_code
                and a.acc_id = p_acc_id
                and b.fee_code = 14
                and a.account_type = l_account_type
        )  -- 'HSA'  replaced by l_account_type by Swamy for Ticket#9912 on 10/08/2021
         loop
            l_amount := x.amount;
        end loop;

        return l_amount;
    end;

    procedure process_eb_settlement (
        acc_id_in     in number,
        dat_in        in varchar2,
        amount_in     in number,
        claimn_id     in number,
        trans_code_in in number,
        source_in     in varchar2 default 'MBI'
    ) is
        l_reason_code number;
    begin
        if trans_code_in = '00060504' then
            l_reason_code := 4;
        else
            l_reason_code := 13;
        end if;

        insert into payment (
            change_num,
            acc_id,
            pay_date,
            amount,
            reason_code,
            claimn_id,
            pay_source,
            debit_card_posted
        ) values ( change_seq.nextval,
                   acc_id_in,
                   to_date(dat_in, 'yyyymmdd'),
                   amount_in,
                   l_reason_code,
                   claimn_id,
                   source_in,
                   'Y' );

        if l_reason_code = 13 then
            card_claim_fee(acc_id_in, claimn_id, source_in);
        end if;
        if trans_code_in = '00060504' then
            insert_fee_for_bank(acc_id_in, 4, amount_in);
        end if;
    end;

    procedure close_payment (
        p_claim_id       in number,
        p_pers_id        in number,
        p_claim_code     in varchar2,
        p_provider_name  in varchar2,
        p_start_date     in date,
        p_pers_patient   in varchar2,
        p_service_status in number,
        p_tax_code       in varchar2,
        p_claim_amount   in number,
        p_fee_date       in date,
        p_disb_amount    in number,
        p_claim_type     in number,
        p_check_number   in number,
        p_payment_note   in number
    ) is
        l_claim_id        number;
        l_claim_code      varchar2(30);
        l_current_balance number;
        l_check_number    number;
    begin
        if p_claim_code is null then
            select
                upper(substr(last_name, 1, 4))
                || to_char(sysdate, 'YYYYMMDD')
            into l_claim_code
            from
                person
            where
                pers_id = p_pers_id;

        end if;

        dbms_output.put_line('Claim amount for acc_id '
                             || p_pers_id
                             || ' amount '
                             || p_claim_amount);
        for x in (
            select
                acc_id,
                account_status,
                suspended_date
            from
                account
            where
                    pers_id = p_pers_id
                and account_type = 'HSA'
        ) loop

    /*      IF   x.account_status = 2 AND x.suspended_date IS NOT NULL THEN
           PC_FIN.TAKE_FEES(x.acc_id,x.SUSPENDED_DATE);
          END IF;*/
            l_current_balance := pc_account.current_balance(x.acc_id);
            if l_current_balance < 0 then
                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    note
                ) values ( change_seq.nextval,
                           x.acc_id,
                           sysdate,
                           l_current_balance,
                           20,
                           'Courtesy Credit before closing account ' );

            end if;

            if l_current_balance > 0 then
                insert into claimn (
                    claim_id,
                    pers_id,
                    pers_patient,
                    claim_code,
                    prov_name,
                    claim_date_start,
                    claim_date_end,
                    tax_code,
                    service_status,
                    claim_amount,
                    claim_paid,
                    claim_pending,
                    note,
                    pay_reason
                ) values ( nvl(p_claim_id, doc_seq.nextval),
                           p_pers_id,
                           p_pers_id,
                           nvl(p_claim_code, l_claim_code),
                           p_provider_name,
                           p_start_date,
                           null,
                           p_tax_code,
                           p_service_status,
                           p_claim_amount,
                           p_claim_amount,
                           0,
                           'Close Account',
                           p_claim_type ) returning claim_id into l_claim_id;

                insert into payment (
                    change_num,
                    claimn_id,
                    pay_date,
                    amount,
                    reason_code,
                    pay_num,
                    note,
                    acc_id
                ) values ( change_seq.nextval,
                           l_claim_id,
                           p_fee_date,
                           l_current_balance,
                           p_claim_type,
                           p_check_number,
                           p_payment_note,
                           x.acc_id );

                for x in (
                    select
                        a.claim_id,
                        c.amount,
                        c.acc_id,
                        a.created_by
                    from
                        payment_register a,
                        claimn           b,
                        payment          c
                    where
                            a.claim_id = l_claim_id
                        and a.claim_id = b.claim_id
                        and b.claim_id = c.claimn_id
                        and c.reason_code <> 19
                        and c.acc_id = a.acc_id
                ) loop
                    pc_check_process.insert_check(
                        p_claim_id     => x.claim_id,
                        p_check_amount => x.amount,
                        p_acc_id       => x.acc_id,
                        p_user_id      => x.created_by,
                        p_status       => 'OPEN',
                        p_source       => 'HSA_CLAIM',
                        x_check_number => l_check_number
                    );
                end loop;

            end if;

        end loop;

        update card_debit
        set
            status = 3
     --      , last_update_by = 0
        where
                card_id = p_pers_id
            and status <> 3;

    exception
        when others then
            raise_application_error('-20001', 'Error in Creating Closing Disbursement for this account' || sqlerrm);
    end close_payment;

    procedure activate_account is
    begin
        for x in (
            select
                acc_id,
                pc_account.validate_subscriber(acc_id, 1, 1) error_message,
                verified_by
            from
                account
            where
                    account_status = 3
                and complete_flag = 0
                and account_type = 'HSA'
                and entrp_id is null
        ) loop
            if x.error_message is null then
                update account
                set
                    complete_flag = 1,
                    signature_on_file = 'Y'
                where
                        acc_id = x.acc_id
                    and complete_flag = 0;

            else
                update account
                set
                    note = x.error_message
                where
                        acc_id = x.acc_id
                    and complete_flag = 0;

            end if;
        end loop;

        for x in (
            select
                a.pers_id,
                acc_id,
                complete_flag,
                (
                    select
                        count(*)
                    from
                        balance_register
                    where
                        acc_id = a.acc_id
                )   cnt,
                case
                    when pc_plan.can_create_card_on_pend(a.plan_code) = 'Y' then
                        1
                    else
                        9
                end card_status
            from
                account a,
                person  b
            where
                    account_status = 1
                and account_type = 'HSA'
                and ( pc_account.acc_balance(acc_id) = 0
                      or complete_flag = 0 )
                and a.pers_id = b.pers_id
        ) loop
            if x.cnt = 0
            or x.complete_flag = 0 then
                update card_debit
                set
                    status = x.card_status  -- Ready to Activate
                    ,
                    last_update_date = sysdate
                where
                        card_id = x.pers_id
                    and status = 1
                    and card_number is null;

        /** Set Pending Activation for Dependants ***/
                update card_debit
                set
                    status = x.card_status  -- Ready to Activate
                    ,
                    last_update_date = sysdate
                where
                        status = 1
                    and card_id in (
                        select
                            pers_id
                        from
                            person
                        where
                                pers_main = x.pers_id
                            and card_issue_flag = 'Y'
                    )
                    and card_number is null;

                update account
                set
                    account_status = 3
                where
                    acc_id = x.acc_id;

            end if;
        end loop;

        for x in (
            select
                acc_id,
                acc_num,
                pers_id
            from
                account
            where
                    account_status = 3
                and entrp_id is null
                and account_type = 'HSA'
                and ( ( trunc(start_date) <= trunc(sysdate)
                        and complete_flag = 1 ) )
                and nvl(
                    pc_account.acc_balance(acc_id),
                    0
                ) > 0
                and not exists (
                    select
                        trunc(insure.start_date)
                    from
                        insure
                    where
                        pers_id = account.pers_id
                )
        ) loop
            update account
            set
                note = 'Health Plan is not setup for this account, Cannot Activate',
                complete_flag = 0
            where
                acc_id = x.acc_id;

        end loop;

        for x in (
            select
                account.acc_id,
                account.acc_num,
                account.pers_id,
                id_verified,
                case
                    when (
                        select
                            count(*)
                        from
                            online_enrollment
                        where
                                online_enrollment.acc_id = account.acc_id
                            and entrp_id is not null
                    ) > 0 then
                        'Y'
                    else
                        decode(verified_by, null, 'N', 'Y')
                end verified_by
            from
                account
            where
                    account_status = 3
                and entrp_id is null
                and account.account_type = 'HSA'
                and ( ( trunc(account.start_date) <= trunc(sysdate)
                        and account.complete_flag = 1 ) )
                and nvl(
                    pc_account.acc_balance(account.acc_id),
                    0
                ) > 0
                and trunc(sysdate) >= (
                    select
                        trunc(insure.start_date)
                    from
                        insure
                    where
                        insure.pers_id = account.pers_id
                )
        ) loop
        /** Set Ready to Activate for Account holder ***/

            if nvl(x.id_verified, 'N') = 'N' then
                update account
                set
                    note = substr((case
                        when instr(note, 'Account cannot be activated because of pending ID verification') > 0 then
                            note
                        else note || ' Account cannot be activated because of pending ID verification'
                    end),
                                  1,
                                  4000),
                    last_update_date = sysdate
                where
                    acc_id = x.acc_id;

            end if;

            if
                x.verified_by = 'Y'
                and x.id_verified = 'Y'
            then
                update card_debit
                set
                    status = 1  -- Ready to Activate
                    ,
                    start_date = sysdate,
                    last_update_date = sysdate
                where
                        card_id = x.pers_id
                    and status = 9
                    and trunc(start_date) <= trunc(sysdate);

        /** Set Ready to Activate for Dependants ***/
                update card_debit
                set
                    status = 1  -- Ready to Activate
                    ,
                    start_date = sysdate,
                    last_update_date = sysdate
                where
                        status = 9
                    and card_id in (
                        select
                            pers_id
                        from
                            person
                        where
                                pers_main = x.pers_id
                            and card_issue_flag = 'Y'
                    )
                    and trunc(start_date) <= trunc(sysdate);

                update account
                set
                    account_status = 1,
                    complete_flag = 1,
                    note = 'Changing Effective Date to '
                           || to_char(sysdate, 'mm/dd/yyyy')
                           || ' from '
                           || to_char(start_date, 'mm/dd/yyyy'),
                    start_date = sysdate
                where
                        acc_id = x.acc_id
                    and account_type = 'HSA'
                    and entrp_id is null;

                dbms_output.put_line('Activating ' || x.acc_num);
            end if;

        end loop;

        update account
        set
            first_activity_date = (
                select
                    min(fee_date)
                from
                    income
                where
                    income.acc_id = account.acc_id
            )
        where
            first_activity_date is null
            and exists (
                select
                    *
                from
                    income
                where
                    income.acc_id = account.acc_id
            );

    exception
        when others then
            raise_application_error('-20001', 'Error in Activating Account' || sqlerrm);
    end activate_account;

    procedure suspend_account is
    begin
        for x in (
            select
                acc_id,
                pers_id,
                acc_num
            from
                account
            where
                ( pc_account.acc_balance(acc_id) < 0
                  or blocked_flag = 'Y' )
                and account_type = 'HSA'
                and account_status = 1
            union all
            select
                acc_id,
                pers_id,
                acc_num
            from
                account      a,
                online_users b
            where
                    a.acc_num = b.find_key
                and a.account_status = 1
                and a.account_type = 'HSA'
                and b.blocked = 'Y'
        ) loop
        /** Set Suspension Pending  for Subscribers ***/

            update card_debit
            set
                status = 6 -- Suspension Pending
                ,
                last_update_date = sysdate
            where
                    card_id = x.pers_id
                and status not in ( 3, 5, 6 ) -- Not Closed, Lost/Stolen
                and card_number is not null
                and status <> 6
                and exists (
                    select
                        *
                    from
                        metavante_cards mc
                    where
                            mc.acc_num = x.acc_num
                        and dependant_id is null
                        and mc.status_code not in ( 4, 5 )
                );

        /** Set Suspension Pending  for Dependants ***/
            update card_debit
            set
                status = 6 -- Suspension Pending
                ,
                last_update_date = sysdate
            where
                card_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        pers_main = x.pers_id
                )
                and status not in ( 3, 5, 6 ) -- Not Closed, Lost/Stolen
                and card_number is not null
                and not exists (
                    select
                        *
                    from
                        account
                    where
                        pers_id = card_debit.card_id
                )
                and exists (
                    select
                        *
                    from
                        metavante_cards mc
                    where
                            mc.acc_num = x.acc_num
                        and dependant_id = card_debit.card_id
                        and mc.status_code not in ( 4, 5 )
                );

            update account
            set
                account_status = 2,
                suspended_date = sysdate
            where
                    acc_id = x.acc_id
                and account_status = 1
                and account_type = 'HSA';

        end loop;
    exception
        when others then
            raise_application_error('-20001', 'Error in Suspending Account' || sqlerrm);
    end suspend_account;

    procedure close_pending_account (
        p_acc_id in number default null
    ) is
        l_no number := 0;
    begin
        for x in (
            select
                acc_id,
                pers_id,
                acc_num
            from
                account
            where
                    hsa_effective_date < sysdate - 90
                and account_status = 3
                and entrp_id is null
                and account_type = 'HSA'
                and acc_id = nvl(p_acc_id, acc_id)
                and not exists -- ( SELECT * FROM INCOME WHERE ACC_ID  = ACCOUNT.ACC_ID) SK Updated to allow account closing for backed out transactions.
                 (
                    select
                        acc_id
                    from
                        income
                    where
                        acc_id = account.acc_id
                    having
                        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(ee_fee_amount, 0) + nvl(er_fee_amount, 0)) > 0
                    group by
                        acc_id
                )
            union
            select
                acc_id,
                pers_id,
                acc_num
            from
                account
            where
                    acc_id = p_acc_id
                and account_status = 3
                and complete_flag = 0
                and account_type = 'HSA'
              --  AND NOT EXISTS ( SELECT * FROM INCOME WHERE ACC_ID  = ACCOUNT.ACC_ID)
        ) loop
            dbms_output.put_line('Closing account ' || x.acc_num);
            l_no := l_no + 1;
            update card_debit
            set
                status = 3,
                last_update_date = sysdate
            where
                    card_id = x.pers_id
                and status <> 3;

          -- Terminating Dependants
            update card_debit
            set
                status = 3 -- Terminated
                ,
                last_update_date = sysdate
            where
                card_id in (
                    select
                        pers_id
                    from
                        person
                    where
                        pers_main = x.pers_id
                )
                and status <> 3
                and card_number is not null
                and not exists (
                    select
                        *
                    from
                        account
                    where
                        pers_id = card_debit.card_id
                );

            pc_account.close_account(x.acc_id,
                                     sysdate,
                                     'Closing Non Funded Pending Account ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss'),
                                     'CLOSED_NON_FUNDS');

        end loop;

        dbms_output.put_line('Number of Closed account ' || l_no);
    exception
        when others then
            raise_application_error('-20001', 'Error in Closing Pending Account' || sqlerrm);
    end close_pending_account;

    procedure process_suspended_account is
        l_cur_bal number := 0;
        l_acc_bal number := 0;
    begin
        pc_log.log_error('process_suspended_account', 'balance > 0 and unsuspend');
        for x in (
            select
                a.pers_id,
                a.plan_code,
                a.acc_id,
                b.entrp_id,
                a.suspended_date,
                sysdate - a.suspended_date activedays,
                nvl(
                    pc_plan.fcustom_fee_value(b.entrp_id, 15),
                    nvl((
                        select
                            fee_amount
                        from
                            plan_fee
                        where
                                fee_code = 15
                            and plan_fee.plan_code = a.plan_code
                    ), 0)
                )                          close_fee,
                blocked_flag
            from
                account a,
                person  b
            where
                    a.account_status = 2
                and a.account_type = 'HSA'
                and a.pers_id = b.pers_id
                and not exists (
                    select
                        *
                    from
                        online_users
                    where
                            a.acc_num = online_users.find_key
                        and blocked = 'Y'
                )
        ) loop
            l_cur_bal := 0;
            l_acc_bal := 0;
           -- vanitha:fixing on 11/04/2018
            l_cur_bal := pc_account.current_balance(x.acc_id, '01-JAN-2004', sysdate, 'HSA');
           -- vanitha : reverting to unsuspend based account balance
            l_acc_bal := pc_account.new_acc_balance(x.acc_id, '01-JAN-2004', sysdate, 'HSA');

         --  l_cur_bal := l_acc_bal -PC_PLAN.get_minimum(x.plan_code);
         -- take monthly fee
            if l_acc_bal > 0 then
                pc_fin.take_fees(x.acc_id, x.suspended_date);
            end if;
            -- if account is suspended for more than 60 days then reinstatement fee is charged
     --    vanitha : commented on 03/13/2019 for the account unsuspend problem dur to checking of l_acc_bal which was zero
     --     IF l_acc_bal  >= 0 AND  NVL(x.blocked_flag,'N') = 'N' THEN
     --    vanitha : added on 03/13/2019 for the account unsuspend problem dur to checking of l_acc_bal which was zero
            if
                l_acc_bal >= 0
                and nvl(x.blocked_flag, 'N') = 'N'
            then
                update account
                set
                    account_status = 1,
                    suspended_date = null
                where
                        acc_id = x.acc_id
                    and account_status = 2
                    and account_type = 'HSA';

                if
                    x.activedays > 60
                    and x.activedays < 90
                then
                    if pc_plan.fcustom_fee_value(x.entrp_id, 10) is null then
                        insert into payment (
                            change_num,
                            acc_id,
                            pay_date,
                            amount,
                            reason_code,
                            note
                        )
                            select
                                change_seq.nextval,
                                x.acc_id,
                                sysdate,
                                fee_amount,
                                10,
                                'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss')
                            from
                                plan_fee
                            where
                                    fee_code = 10
                                and plan_code = x.plan_code
                                and not exists (
                                    select
                                        *
                                    from
                                        payment
                                    where
                                            acc_id = x.acc_id
                                        and reason_code = 10
                                );

                    else
                        if pc_plan.fcustom_fee_value(x.entrp_id, 10) > 0 then
                            insert into payment (
                                change_num,
                                acc_id,
                                pay_date,
                                amount,
                                reason_code,
                                note
                            )
                                select
                                    change_seq.nextval,
                                    x.acc_id,
                                    sysdate,
                                    pc_plan.fcustom_fee_value(x.entrp_id, 10),
                                    10,
                                    'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss')
                                from
                                    dual
                                where
                                    not exists (
                                        select
                                            *
                                        from
                                            payment
                                        where
                                                acc_id = x.acc_id
                                            and reason_code = 10
                                    );

                        end if;
                    end if;
               -- Take monthly fees

               -- When metavante was transitioned on july 28 2009 some of the accounts could have been in closed state
           -- or suspended date. They may not have been moved to metavante , so by setting to ready to activate
           -- the cards will be recreated
              /* UPDATE card_debit
               SET    status = 1 --Ready to Activate
               WHERE  card_id = x.pers_id
                AND   status in (4,6) -- Suspended
                AND   card_number IS  NULL;*/

                end if;

            end if;

        end loop;

        pc_log.log_error('process_suspended_account', 'close the account after 90 days');

        -- Close the account after 90 days
        for x in (
            select
                a.pers_id,
                a.plan_code,
                a.acc_id,
                a.suspended_date,
                sysdate - suspended_date activedays,
                nvl(
                    pc_plan.fcustom_fee_value(b.entrp_id, 15),
                    nvl((
                        select
                            fee_amount
                        from
                            plan_fee
                        where
                                fee_code = 15
                            and plan_fee.plan_code = a.plan_code
                    ), 0)
                )                        close_fee
            from
                account a,
                person  b
            where
                    a.account_status = 2
                and a.account_type = 'HSA'
                and a.pers_id = b.pers_id
                and sysdate - a.suspended_date >= 90
        ) loop
         -- take monthly fee
            l_cur_bal := 0;
            l_acc_bal := 0;
           -- vanitha:fixing on 11/04/2018

            l_cur_bal := pc_account.current_balance(x.acc_id, '01-JAN-2004', sysdate, 'HSA');
       --    l_cur_bal := l_acc_bal -PC_PLAN.get_minimum(x.plan_code);

            if l_cur_bal > 0 then
                pc_fin.take_fees(x.acc_id, x.suspended_date);
            end if;
          -- Terminate the account
            if ( (
                l_cur_bal > -50
                and l_cur_bal < 50
            )
            or (
                l_cur_bal < -50
                and x.suspended_date < '01-JAN-2009'
            ) ) then
          -- Terminating Subscribers
                update card_debit
                set
                    status = 3,
                    last_update_date = sysdate
                where
                        card_id = x.pers_id
                    and status <> 3;

          -- Terminating Dependants
                update card_debit
                set
                    status = 3 -- Terminated
                    ,
                    last_update_date = sysdate
                where
                    card_id in (
                        select
                            pers_id
                        from
                            person
                        where
                            pers_main = x.pers_id
                    )
                    and status <> 3
                    and card_number is not null
                    and not exists (
                        select
                            *
                        from
                            account
                        where
                            pers_id = card_debit.card_id
                    );

                pc_account.close_account(x.acc_id,
                                         sysdate,
                                         'Closing suspended account ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss'),
                                         'SUSPENDED');

             -- Zero in the balance before closing the account
                if l_cur_bal < 0 then
                    insert into payment (
                        change_num,
                        acc_id,
                        pay_date,
                        amount,
                        reason_code,
                        note
                    )
                        select
                            change_seq.nextval,
                            x.acc_id,
                            sysdate,
                            decode(
                                sign(l_cur_bal),
                                -1,
                                l_cur_bal - x.close_fee
                            ),
                            0,
                            'Zeroing in the balance before closing account '
                        from
                            dual;

                end if;

            end if;

        end loop;

        pc_log.log_error('process_suspended_account', 'unsuspend the card ');
        for x in (
            select
                pers_id,
                acc_num
            from
                account    a,
                card_debit c
                 -- where  pc_account.new_acc_balance(acc_id) >= 0
                  --AND    account_status = 2
            where
                    a.pers_id = c.card_id
                and account_status = 1
                and account_type = 'HSA'
                and nvl(blocked_flag, 'N') = 'N'
                and c.status in ( 4, 6 )
                and c.status_code not in ( 4, 5 )
        ) loop
            update card_debit
            set
                status = 7 --Un-Suspend Pending
                ,
                last_update_date = sysdate
            where
                    card_id = x.pers_id
                and status in ( 4, 6 )
                and status_code not in ( 4, 5 )
                and exists (
                    select
                        *
                    from
                        metavante_cards mc
                    where
                            mc.acc_num = x.acc_num
                        and dependant_id is null
                        and mc.status_code not in ( 4, 5 )
                );  -- Unsuspend only if it is not terminated or lost/stolen
        end loop;

        pc_log.log_error('process_suspended_account', 'unsuspend the dependent card ');
        for x in (
            select
                b.pers_id,
                a.acc_num,
                a.acc_id
            from
                account    a,
                person     b,
                card_debit c
            where
                b.pers_main is not null
                and a.pers_id = b.pers_main
                and b.pers_id = c.card_id
                and account_status in ( 1, 2 )
                and c.status in ( 4, 6 )
                and account_type = 'HSA'
                and nvl(blocked_flag, 'N') = 'N'
        ) loop
            l_acc_bal := 0;
            l_acc_bal := pc_account.new_acc_balance(x.acc_id, '01-JAN-2004', sysdate, 'HSA');
            if l_acc_bal > 0 then
                update card_debit
                set
                    status = 7 --Un-Suspend Pending
                    ,
                    last_update_date = sysdate
                where
                        card_id = x.pers_id
                    and status in ( 4, 6 )
                    and status_code not in ( 4, 5 ) -- Unsuspend only if it is not terminated or lost/stolen
                    and exists (
                        select
                            *
                        from
                            metavante_cards mc
                        where
                                mc.acc_num = x.acc_num
                            and dependant_id = x.pers_id
                            and mc.status_code not in ( 4, 5 )
                    );  -- Unsuspend only if it is not terminated or lost/stolen
            end if;

        end loop;

        pc_log.log_error('process_suspended_account', 'last blocked ');
        for x in (
            select
                acc_id,
                suspended_date,
                plan_code
            from
                account
            where
                    account_status = 2
                and account_type = 'HSA'
                and entrp_id is null --sk added 10/18
                and nvl(blocked_flag, 'N') = 'N'
        ) loop
            l_acc_bal := 0;
            l_acc_bal := pc_account.new_acc_balance(x.acc_id, '01-JAN-2004', sysdate, 'HSA');
            if l_acc_bal > 0 then
                pc_fin.take_fees(x.acc_id, x.suspended_date);
                update account
                set
                    account_status = 1,
                    suspended_date = null
                where
                        acc_id = x.acc_id
                    and account_status = 2;

                dbms_output.put_line('Rowcount ' || sql%rowcount);
            end if;

        end loop;

    exception
        when others then
            raise_application_error('-20001', 'Error in Reactivating Account' || sqlerrm);
    end process_suspended_account;

    procedure update_debit_card_settlements is
    begin
        for x in (
            select
                s.pers_id,
                s.payment_amount * t.trans_sign as amount
            from
                eb_settlement  s,
                eb_trans_codes t
            where
                    s.trans_code != '00001101'
                and s.trans_code != '00001102'
                and s.trans_code = t.trans_code
                and s.created_claim = 'Y'
                and trunc(s.file_date) = to_date(sysdate, 'DD-MON-YY')
        ) loop
            update card_debit
            set
                current_card_value = current_card_value + x.amount
            where
                card_id = x.pers_id;

        end loop;
    end update_debit_card_settlements;

    procedure annual_investment_fee_payment is
    begin
        insert into payment (
            change_num,
            acc_id,
            pay_date,
            amount,
            reason_code,
            note
        )
            select
                change_seq.nextval,
                a.acc_id,
                sysdate,
                c.fee_amount,
                c.fee_code,
                c.note
            from
                (
                    select
                        a.acc_id,
                        a.plan_code
                    from
                        account    a,
                        investment b
                    where
                            a.acc_id = b.acc_id
                        and b.end_date is null
                        and a.account_status <> 4
                        and a.account_type = 'HSA'
                        and ( trunc(sysdate) - trunc(b.start_date) ) / 365 > 1
                    union
                    select
                        a.acc_id,
                        a.plan_code
                    from
                        account    a,
                        investment b
                    where
                            a.acc_id = b.acc_id
                        and b.end_date is null
                        and a.account_type = 'HSA'
                        and a.account_status <> 4
                        and trunc(sysdate) = trunc(b.start_date)
                )        a,
                plan_fee c
            where
                    a.plan_code = c.plan_code
                and c.fee_code = 3
                and not exists (
                    select
                        *
                    from
                        payment
                    where
                            payment.acc_id = a.acc_id
                        and pay_date > sysdate - 365
                                                 and reason_code = c.fee_code
                );

    end annual_investment_fee_payment;

    procedure lost_stolen_payment (
        p_acc_id    in number,
        p_plan_code in number,
        p_note      in varchar2
    ) is
    begin
        insert into payment (
            change_num,
            acc_id,
            pay_date,
            amount,
            reason_code,
            note
        )
            select
                change_seq.nextval,
                p_acc_id,
                sysdate,
                fee_amount,
                fee_code,
                p_note
            from
                plan_fee
            where
                    plan_code = p_plan_code
                and fee_code = 4;

    end lost_stolen_payment;

    procedure create_outside_investment (
        p_investment_id  in number,
        p_invest_date    in varchar2,
        p_ending_balance in number,
        p_note           in varchar2,
        p_user_name      in varchar2,
        x_error_message  out varchar2
    ) is
    begin
        pc_log.log_error('PC_FIN.create_outside_investment', 'Step1');
        insert into invest_transfer (
            transfer_id,
            investment_id,
            invest_date,
            invest_amount,
            note,
            created_by,
            last_updated_by
        ) values ( transfer_seq.nextval,
                   p_investment_id,
                   to_date(p_invest_date, 'MM/DD/YYYY'),
                   p_ending_balance,
                   'Posted by '
                   || p_user_name
                   || ' Note : '
                   || p_note,
                   get_user_id(p_user_name),
                   get_user_id(p_user_name) );

    end create_outside_investment;

    function recalculate_interest (
        dat_from in date default sysdate - 31,
        dat_to   in date default sysdate,
        acc_in   in number default null  -- NULL means all accounts
        ,
        priz_in  in number default 0  -- 1 = calc %
    ) return number is
    /*  */

        l_total_int    number := 0;
        l_adjusted_int number := 0;
    begin
        if acc_in is not null then
            for x in (
                select
                    sum(amount) amount
                from
                    income
                where
                        fee_code = 8
                    and acc_id = acc_in
            ) loop
                l_total_int := x.amount;
            end loop;

            pc_fin.recalc_balance(dat_from, dat_to, acc_in, 1);
            for x in (
                select
                    sum(amount) amount
                from
                    income
                where
                        fee_code = 8
                    and acc_id = acc_in
            ) loop
                l_adjusted_int := x.amount;
            end loop;

            rollback;
            dbms_output.put_line('l_total_fee ' || l_total_int);
            dbms_output.put_line('v_ppm ' || l_adjusted_int);
            if l_adjusted_int - l_total_int <> 0 then
                insert into income (
                    change_num,
                    acc_id,
                    fee_date,
                    fee_code,
                    amount,
                    pay_code,
                    note,
                    creation_date,
                    created_by
                ) values ( change_seq.nextval,
                           acc_in,
                           sysdate,
                           8,
                           l_adjusted_int - l_total_int,
                           9,
                           'Posting adjustment of interest calculated for back dated deposits',
                           sysdate,
                           - 1 );

            end if;

        end if;

        return l_adjusted_int - l_total_int;
    exception
        when others then
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            return -1;
    end recalculate_interest;

    function contribution_limit (
        pers_id_in in number,
        year_in    in date default sysdate
    ) return number is
        l_contrib_limit number := 0;
    begin
        for x in (
            select
                a.pers_id,
                birth_date,
                nvl(
                    trunc((sysdate - birth_date) / 365.25),
                    -1
                )                   as m55,
                nvl(b.plan_type, 0) plan_type
            from
                person a,
                insure b
            where
                    a.pers_id = b.pers_id (+)
                and a.pers_id = pers_id_in
            order by
                birth_date
        ) loop
            if x.m55 > 54 then
                l_contrib_limit := nvl(
                    pc_param.get_system_value('CATCHUP_CONTRIBUTION', year_in),
                    1000
                ); -- Catch_up
            end if;

            if x.plan_type = 0 then
                l_contrib_limit := l_contrib_limit + pc_param.get_system_value('INDIVIDUAL_CONTRIBUTION', year_in);
            else
                l_contrib_limit := l_contrib_limit + pc_param.get_system_value('FAMILY_CONTRIBUTION', year_in);
            end if;

        end loop;
   /*   IF TO_NUMBER(TO_CHAR(SYSDATE,'MM')) = 4 AND  TO_NUMBER(TO_CHAR(SYSDATE,'MM')) < 12 THEN
         l_contrib_limit := l_contrib_limit*2;
      END IF;*/
        return l_contrib_limit;
    end contribution_limit;

    function contribution_ytd (
        acc_id_in         in number,
        account_type_in   in varchar2,
        plan_type_in      in varchar2,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null
    ) return number is
        l_amount number := 0;
    begin
        if account_type_in = 'HSA' then
            for x in (
                select
                    sum(nvl(a.amount, 0) + nvl(a.amount_add, 0)) contribution
                from
                    income a
                where
                    a.acc_id = acc_id_in
            ) loop
                l_amount := x.contribution;
            end loop;
        else
            for x in (
                select
                    sum(nvl(a.amount, 0) + nvl(a.amount_add, 0)) contribution
                from
                    income a
                where
                        a.acc_id = acc_id_in
                    and a.fee_code <> 12
                    and a.plan_type = plan_type_in
                    and trunc(a.fee_date) >= trunc(p_plan_start_date)
                    and trunc(a.fee_date) <= trunc(p_plan_end_date)
            ) loop
                l_amount := x.contribution;
            end loop;
        end if;

        return l_amount;
    end contribution_ytd;

    function disbursement_ytd (
        acc_id_in         in number,
        account_type_in   in varchar2,
        plan_type_in      in varchar2,
        reason_code_in    in number,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null
    ) return number is
        l_amount number := 0;
    begin
        if account_type_in = 'HSA' then
            for x in (
                select
                    sum(nvl(a.amount, 0)) contribution
                from
                    payment a
                where
                        a.acc_id = acc_id_in
                    and a.reason_mode = 'P'
            ) loop
                l_amount := x.contribution;
            end loop;
        else
            for x in (
                select
                    sum(contribution) contribution
                from
                    (
                        select
                            sum(nvl(a.amount, 0)) contribution
                        from
                            payment a,
                            claimn  b
                        where
                                a.acc_id = acc_id_in
                            and trunc(a.pay_date) >= trunc(p_plan_start_date)
                            and trunc(a.pay_date) <= trunc(p_plan_end_date)
                            and a.claimn_id = b.claim_id
                            and a.plan_type = nvl(plan_type_in, plan_type)
                            and a.reason_code = nvl(reason_code_in, a.reason_code)
                        union
                        select
                            - sum(nvl(amount, 0))
                        from
                            balance_register
                        where
                                acc_id = acc_id_in
                            and trunc(fee_date) >= trunc(p_plan_start_date)
                            and trunc(fee_date) <= trunc(p_plan_end_date)
                            and plan_type = nvl(plan_type_in, plan_type)
                            and reason_code = 22
                    )
            ) loop
                l_amount := x.contribution;
            end loop;
        end if;

        return l_amount;
    end disbursement_ytd;

    function deductible_ytd (
        acc_id_in         in number,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null,
        p_pers_id         in number default null
    ) return number is
        l_amount number := 0;
    begin
        for x in (
            select
                sum(nvl(a.deductible_amount, 0)) deductible
            from
                deductible_balance a,
                claimn             b
            where
                    a.acc_id = acc_id_in
                and a.claim_id = b.claim_id
                and b.claim_status not in ( 'CANCELLED', 'DENIED', 'ERROR', 'DECLINED' )
                and a.pers_patient = nvl(p_pers_id, a.pers_patient)
                and trunc(b.plan_start_date) >= trunc(p_plan_start_date)
                and trunc(b.plan_end_date) <= trunc(p_plan_end_date)
        ) loop
            l_amount := x.deductible;
        end loop;

        return l_amount;
    end deductible_ytd;

    procedure create_employer_deposit (
        p_list_bill          in number,
        p_entrp_id           in number,
        p_check_amount       in number,
        p_check_date         in date,
        p_posted_balance     in number,
        p_fee_bucket_balance in number,
        p_remaining_balance  in number,
        p_user_id            in number,
        p_plan_type          in varchar2,
        p_note               in varchar2,
        p_reason_code        in number default 4,
        p_check_number       in varchar2 default null
    ) is
    begin
        insert into employer_deposits a (
            employer_deposit_id,
            entrp_id,
            list_bill,
            check_number,
            check_amount,
            check_date,
            posted_balance,
            fee_bucket_balance,
            remaining_balance,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            note,
            plan_type,
            reason_code
        ) values ( p_list_bill -- EMPLOYER_DEPOSIT_ID
        ,
                   p_entrp_id -- ENTRP_ID
                   ,
                   p_list_bill-- LIST_BILL
                   ,
                   p_check_number -- CHECK_NUMBER
                   ,
                   p_check_amount -- CHECK_AMOUNT
                   ,
                   p_check_date   -- CHECK_DATE
                   ,
                   nvl(p_posted_balance, 0)  -- POSTED_BALANCE
                   ,
                   nvl(p_fee_bucket_balance, 0)   -- FEE_BUCKET_BALANCE
                   ,
                   nvl(p_remaining_balance, 0) -- REMAINING_BALANCE
                   ,
                   p_user_id -- CREATED_BY
                   ,
                   sysdate   -- CREATION_DATE
                   ,
                   p_user_id -- LAST_UPDATED_BY
                   ,
                   sysdate   -- LAST_UPDATE_DATE
                   ,
                   p_note,
                   p_plan_type,
                   p_reason_code ); -- NOTE

    end create_employer_deposit;

    procedure create_receipt (
        p_acc_id            in number,
        p_fee_date          in date,
        p_entrp_id          in number,
        p_er_amount         in number default 0,
        p_ee_amount         in number default 0,
        p_er_fee            in number default 0,
        p_ee_fee            in number default 0,
        p_pay_code          in number,
        p_plan_type         in varchar2,
        p_debit_card_posted in varchar2,
        p_list_bill         in number,
        p_fee_reason        in number,
        p_note              in varchar2,
        p_check_amount      in number,
        p_user_id           in number,
        p_check_number      in varchar2 default null
    ) is
        l_exists number := 0;
    begin
        select
            count(*)
        into l_exists
        from
            income
        where
                acc_id = p_acc_id
            and plan_type = p_plan_type
            and list_bill = p_list_bill
            and fee_code = p_fee_reason;

        if l_exists = 0 then
            insert into income (
                change_num,
                acc_id,
                fee_date,
                fee_code,
                amount,
                contributor,
                pay_code,
                note,
                contributor_amount,
                debit_card_posted,
                creation_date,
                created_by,
                last_updated_date,
                last_updated_by,
                plan_type,
                list_bill,
                cc_number
            ) values ( change_seq.nextval,
                       p_acc_id,
                       p_fee_date,
                       p_fee_reason -- Annual election
                       ,
                       p_er_amount,
                       p_entrp_id,
                       p_pay_code -- Annual election
                       ,
                       p_note,
                       p_check_amount,
                       nvl(p_debit_card_posted, 'N'),
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       p_plan_type,
                       p_list_bill,
                       p_check_number );

        end if;

    end create_receipt;

    procedure create_prefunded_receipt (
        p_batch_number in number,
        p_user_id      in number,
        p_acc_num      in varchar2 default null
    ) is
        l_list_bill    number;
        l_check_number varchar2(30);
    begin
        pc_log.log_error('PC_BENEFIT_PLANS.CREATE_ANNUAL_ELECTION ', p_batch_number);
        for x in (
            select
                a.ben_plan_id,
                a.entrp_id,
                a.plan_type,
                a.effective_date,
                a.plan_start_date,
                c.acc_num,
                sum(nvl(b.annual_election, 0)) check_amount
            from
                ben_plan_enrollment_setup a,
                ben_plan_enrollment_setup b,
                account                   c
            where
                    a.ben_plan_id = b.ben_plan_id_main
                and a.acc_id = c.acc_id
                and c.acc_num = nvl(p_acc_num, c.acc_num)
                and b.funding_type = 'PRE_FUND'
                and b.batch_number = nvl(p_batch_number, b.batch_number)
               --  AND    B.PLAN_TYPE   IN ('FSA','LPF')
                and c.account_type in ( 'HRA', 'FSA' )
                and a.entrp_id is not null
                and a.plan_type is not null
                and exists (
                    select
                        *
                    from
                        income d
                    where
                            trunc(d.fee_date) >= trunc(a.plan_start_date)
                        and trunc(d.fee_date) <= trunc(a.plan_end_date)
                        and b.acc_id = d.acc_id
                        and d.fee_code = 12
                        and d.cc_number = 'AE:'
                                          || to_char(p_batch_number)
                                          || ':'
                                          || b.ben_plan_id_main
                )
                and not exists (
                    select
                        *
                    from
                        income d
                    where
                            trunc(d.fee_date) >= trunc(a.plan_start_date)
                        and trunc(d.fee_date) <= trunc(a.plan_end_date)
                        and b.acc_id = d.acc_id
                        and d.fee_code = 11
                        and d.cc_number = 'PC:'
                                          || to_char(p_batch_number)
                                          || ':'
                                          || b.ben_plan_id_main
                )
            --    AND   TRUNC(A.PLAN_END_DATE) >= TRUNC(SYSDATE)
            group by
                a.ben_plan_id,
                a.entrp_id,
                a.plan_type,
                a.effective_date,
                a.plan_start_date,
                c.acc_num
            having
                sum(nvl(b.annual_election, 0)) > 0
        ) loop
            l_check_number := 'PC:'
                              || to_char(p_batch_number)
                              || ':'
                              || x.ben_plan_id;

            l_list_bill := null;
            for kk in (
                select
                    list_bill
                from
                    employer_deposits
                where
                        entrp_id = x.entrp_id
                    and check_number = l_check_number
                    and plan_type = x.plan_type
            ) loop
                l_list_bill := kk.list_bill;
                update employer_deposits
                set
                    check_amount = check_amount + nvl(x.check_amount, 0),
                    posted_balance = posted_balance + nvl(x.check_amount, 0),
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    list_bill = kk.list_bill;

            end loop;

            if l_list_bill is null then
                select
                    employer_deposit_seq.nextval
                into l_list_bill
                from
                    dual;
       /*   pc_fin.create_employer_deposit
           (p_list_bill          => L_LIST_BILL
          , p_entrp_id           => x.entrp_id
          , p_check_amount       => x.check_amount
          , p_check_date         => x.PLAN_START_DATE
          , p_posted_balance     => x.check_amount
          , p_fee_bucket_balance => 0
          , p_remaining_balance  => 0
          , p_user_id            => p_user_id
          , p_plan_type          => X.PLAN_TYPE
          , p_note               => 'Posting Prefunded Payroll Contribution'
      , p_reason_code        => 11);*/

                insert into employer_deposits a (
                    employer_deposit_id,
                    entrp_id,
                    list_bill,
                    check_number,
                    check_amount,
                    check_date,
                    posted_balance,
                    fee_bucket_balance,
                    remaining_balance,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    note,
                    plan_type,
                    reason_code,
                    pay_code
                ) values ( l_list_bill -- EMPLOYER_DEPOSIT_ID
                ,
                           x.entrp_id -- ENTRP_ID
                           ,
                           l_list_bill-- LIST_BILL
                           ,
                           l_check_number-- CHECK_NUMBER
                           ,
                           x.check_amount -- CHECK_AMOUNT
                           ,
                           x.plan_start_date   -- CHECK_DATE
                           ,
                           x.check_amount  -- POSTED_BALANCE
                           ,
                           0   -- FEE_BUCKET_BALANCE
                           ,
                           0 -- REMAINING_BALANCE
                           ,
                           0 -- CREATED_BY
                           ,
                           sysdate   -- CREATION_DATE
                           ,
                           0 -- LAST_UPDATED_BY
                           ,
                           sysdate   -- LAST_UPDATE_DATE
                           ,
                           'Posting Prefunded Deposit',
                           x.plan_type,
                           11,
                           4 ); -- NOTE
            end if;

            pc_log.log_error('employer deposit,L_LIST_BILL ', l_list_bill);
            for xx in (
                select
                    *
                from
                    ben_plan_enrollment_setup
                where
                        ben_plan_id_main = x.ben_plan_id
                    and batch_number = nvl(p_batch_number, batch_number)
            ) loop
                begin
                    pc_fin.create_receipt(
                        p_acc_id            => xx.acc_id,
                        p_fee_date          => xx.effective_date,
                        p_entrp_id          => x.entrp_id,
                        p_er_amount         => nvl(xx.annual_election, 0),
                        p_pay_code          => 4,
                        p_plan_type         => x.plan_type,
                        p_debit_card_posted => 'N',
                        p_list_bill         => l_list_bill,
                        p_fee_reason        => 11,
                        p_note              => 'Posting Prefunded Payroll Contribution',
                        p_check_amount      => x.check_amount,
                        p_user_id           => p_user_id,
                        p_check_number      => l_check_number
                    );

                exception
                    when others then
                        dbms_output.put_line('ACC ID ' || xx.acc_id);
                end;
            end loop;

        end loop;

    end create_prefunded_receipt;

    procedure annual_fee_payment is
    begin
        insert into payment (
            change_num,
            acc_id,
            pay_date,
            amount,
            reason_code,
            note
        )
            select
                change_seq.nextval,
                a.acc_id,
                sysdate,
                c.fee_amount,
                c.fee_code,
                c.note
            from
                (
                    select
                        a.acc_id,
                        a.plan_code,
                        max(b.pay_date) last_pay_date
                    from
                        account a,
                        payment b
                    where
                            a.acc_id = b.acc_id
                        and a.end_date is null
                        and a.account_status <> 4
                        and a.account_type = 'HSA'
                        and b.reason_code = 100
                    group by
                        a.acc_id,
                        a.plan_code
                )        a,
                plan_fee c
            where
                    a.plan_code = c.plan_code
                and c.fee_code = 100
                and a.last_pay_date <= add_months(sysdate, -12);

    end annual_fee_payment;

    function is_rolled_over (
        p_acc_id   in number,
        p_fee_date in date
    ) return varchar2 is
        l_rollover_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                count(*) cnt
            from
                income                    a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and nvl(a.amount, 0) + nvl(a.amount_add, 0) < 0
                and a.fee_code = 17
                and b.product_type = 'HRA'
                and a.plan_type = b.plan_type
                and a.acc_id = b.acc_id
                and a.fee_date between b.plan_start_date and b.plan_end_date
                and trunc(p_fee_date) between b.plan_start_date and b.plan_end_date
        ) loop
            if x.cnt > 0 then
                l_rollover_flag := 'Y';
            end if;
        end loop;

        return l_rollover_flag;
    end is_rolled_over;

    function get_rollover_date (
        p_acc_id   in number,
        p_fee_date in date
    ) return date is
        l_rollover_date date;
    begin
        for x in (
            select
                a.fee_date
            from
                income                    a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = p_acc_id
                and nvl(a.amount, 0) + nvl(a.amount_add, 0) < 0
                and a.fee_code = 17
                and b.product_type = 'HRA'
                and a.plan_type = b.plan_type
                and a.acc_id = b.acc_id
                and a.fee_date between b.plan_start_date and b.plan_end_date
                and trunc(p_fee_date) between b.plan_start_date and b.plan_end_date
        ) loop
            l_rollover_date := x.fee_date;
        end loop;

        return l_rollover_date;
    end get_rollover_date;
    --BEGIN
     -- initialize
     --Pc_Fin.pv_debug := Pc_Param.get_value('DEBUG');

    function claim_filed_ytd (
        acc_id_in         in number,
        account_type_in   in varchar2,
        plan_type_in      in varchar2,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null
    ) return number is
        l_amount number := 0;
    begin
        pc_log.log_error('PC_FIN.claim_filed_YTD', 'Start of Proc');
        if account_type_in = 'HSA' then
            for x in (
                select
                    sum(nvl(a.amount, 0)) contribution
                from
                    payment a
                where
                        a.acc_id = acc_id_in
                    and a.reason_mode = 'P'
            ) loop
                l_amount := x.contribution;
            end loop;

        else
            for x in (
                select
                    sum(contribution) contribution
                from
                /*(SELECT SUM(NVL(B.CLAIM_AMOUNT,0)) contribution
                    FROM  PAYMENT A , CLAIMN B
                   WHERE  a.acc_id =acc_id_in
                   AND    a.claimn_id = b.claim_id
                   AND   b.claim_status <> 'CANCELLED'
                   --AND    a.reason_code  = NVL(reason_code_in,a.reason_code)
                   AND    a.plan_type =  NVL(plan_type_in,plan_type)
                   AND    TRUNC(a.pay_date) >= TRUNC(p_plan_start_date)
                   AND    TRUNC(a.pay_date) <= TRUNC(p_plan_end_date)
       UNION
                    Include Denied Claims*/
                    (
                        select
                            sum(nvl(b.claim_amount, 0)) contribution
                        from
                            claimn  b,
                            account a
                        where
                                a.acc_id = acc_id_in
                            and a.pers_id = b.pers_id
                            and b.claim_status <> 'CANCELLED'
                            and b.service_type = nvl(plan_type_in, b.service_type)
                            and trunc(b.plan_start_date) >= trunc(p_plan_start_date)
                            and trunc(b.plan_end_date) <= trunc(p_plan_end_date)
                    )
            ) loop
                l_amount := x.contribution;
            end loop;
        end if;

        return l_amount;
    exception
        when others then
            pc_log.log_error('PC_FIN.Claim_filed_YTD', sqlerrm);
            return 0;
    end claim_filed_ytd;

    function get_monthly_contribution (
        p_amount    in number,
        p_frequency in varchar2
    ) return number is
        l_amount number;
    begin
        pc_log.log_error('PC_FIN.get_monthly_contribution', 'Start of Proc');
        select
            p_amount * (
                case
                    when p_frequency = 'BIANNUALLY'  then
                        2
                    when p_frequency = 'ANNUALLY'    then
                        1
                    when p_frequency = 'BIWEEKLY'    then
                        26
                    when p_frequency = 'WEEKLY'      then
                        52
                    when p_frequency = 'BIMONTHLY'   then
                        24
                    when p_frequency = 'SEMIMONTHLY' then
                        24
                    when p_frequency = 'MONTHLY'     then
                        12
                    when p_frequency = 'QUARTERLY'   then
                        4
                    else
                        1
                end
            ) / 12
        into l_amount
        from
            dual;
  /*RETURN ROUND(l_amount,0);*/
        return l_amount;
    exception
        when others then
            pc_log.log_error('PC_FIN.get_monthly_contribution', sqlerrm);
            return 0;
    end get_monthly_contribution;

    function get_balance_details (
        p_acc_id_in       in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_entrp_id        in number
    ) return balance_t
        pipelined
        deterministic
    is

        l_record          balance_row_t;
        v_total_ee        number := 0;
        v_total_er        number := 0;
        l_employer_contrb number;
        l_employee_contrb number;
        v_frequency       varchar2(200);
    begin
        pc_log.log_error('PC_FIN.get_balance_details', 'Start of Proc');
        for x in (
            select distinct
                a.schedule_id,
                b.recurring_frequency
            from
                scheduler_calendar a,
                scheduler_master   b
            where
                period_date between p_plan_start_date and p_plan_end_date
                and a.schedule_id = b.scheduler_id
                and b.plan_type = p_plan_type
                and b.recurring_flag = 'Y'
                and b.contributor = p_entrp_id
                and b.payment_end_date >= sysdate
        ) loop
            pc_log.log_error('PC_FIN.get_balance_details', x.schedule_id);
            pc_log.log_error('PC_FIN.get_balance_details', p_acc_id_in);
            select
                nvl(
                    sum(ee_amount),
                    0
                ),
                nvl(
                    sum(er_amount),
                    0
                )
            into
                l_employee_contrb,
                l_employer_contrb
            from
                scheduler_details
            where
                    scheduler_id = x.schedule_id
                and acc_id = p_acc_id_in;

            v_total_ee := l_employee_contrb + v_total_ee;
            v_total_er := l_employer_contrb + v_total_er;
            v_frequency := x.recurring_frequency;
        end loop;

        l_record.pre_tax := v_total_ee;
        l_record.post_tax := v_total_er;
  --Calculate monthly Contrib
        pc_log.log_error('PC_FIN.get_balance_details', 'Before calculating monthly contribution');
        select
            pc_fin.get_monthly_contribution((v_total_ee + v_total_er), v_frequency)
        into l_record.monthly_contrib
        from
            dual;

        pipe row ( l_record );
    exception
        when others then
            pc_log.log_error('PC_FIN.get_balance_details', sqlerrm);
            pipe row ( l_record );
    end get_balance_details;

    procedure take_annual (
        acc_in in number,
        dat_in in date,
        fee_in in number
    ) is
        cnt   number;
        l_fee number;
    begin
        pc_log.log_error('In TAke Annual', 'Payment');
        select
            count(change_num)
        into cnt
        from
            payment
        where
                acc_id = acc_in
            and reason_code = 100
            and pay_date > add_months(dat_in, -12);  --We cannot consider just year component.We have to see when was the last fees charged;

        if cnt = 0 then -- no the fee, let take it
            if pc_account.current_balance(acc_in) > 0 then
                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    claim_id,
                    pay_num,
                    note
                ) values ( change_seq.nextval,
                           acc_in,
                           sysdate,
                           fee_in,
                           100,
                           null,
                           null,
                           'Generate ' || to_char(sysdate, 'yyyy mm dd hh24:MI:ss') );

            end if;
        end if;

    end take_annual;

-- Added by Swamy on 27/01/2023
-- Check if Employee is included in invoice. Deduct the fees amount only if the employee is included in the invoice.
-- Do not deduct the fees amount if employee is not included in the invoice.
    function chk_employee_included_in_invoice (
        p_entrp_id in number,
        p_pers_id  in number,
        p_dat_in   in date
    ) return varchar2 is
        l_return varchar2(1) := 'N';
    begin
        pc_log.log_error('In chk_employee_included_in_invoice ', 'p_dat_in :=' || p_dat_in);
        for i in (
            select
                invoice_id
            from
                ar_invoice
            where
                    entity_id = p_entrp_id
                and status in ( 'GENERATED', 'PROCESSED', 'POSTED' )
                and invoice_date >= trunc(p_dat_in, 'MM')
                and invoice_date <= last_day(trunc(p_dat_in, 'MM')) 
               --AND invoice_date >= (TRUNC(LAST_DAY(ADD_MONTHS(p_dat_in,-1)))+1)  -- Added by Swamy for Ticket#12137 09052024,fetch the latest invoice, not previous years current month's invoice.
               --AND invoice_date <= TRUNC(LAST_DAY(p_dat_in))                     -- Added by Swamy for Ticket#12137 09052024
			   --AND EXTRACT(MONTH FROM invoice_date) = EXTRACT(MONTH FROM (p_dat_in))
        ) loop
            pc_log.log_error('In chk_employee_included_in_invoice ', 'i.invoice_id :=' || i.invoice_id);
            for j in (
                select
                    1
                from
                    invoice_distribution_summary
                where
                        invoice_id = i.invoice_id
                    and entrp_id = p_entrp_id
                    and pers_id = p_pers_id
            ) loop
                l_return := 'Y';
            end loop;

        end loop;

        return l_return;
    end chk_employee_included_in_invoice;

end pc_fin;
/

