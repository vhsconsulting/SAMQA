-- liquibase formatted sql
-- changeset SAMQA:1754374120137 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_web_utility_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_web_utility_pkg.sql:null:031c0bc56818b0cd4f1b5db228b3634f8268ba8d:create

create or replace package body samqa.pc_web_utility_pkg is

    function validate_users (
        p_user_name in varchar2 default null,
        p_passwd    in varchar2 default null
    ) return user_record_t
        pipelined
        deterministic
    is

        pragma autonomous_transaction;
        l_user_name      varchar2(100);
        l_email          varchar2(100);
        l_confirmed_flag varchar2(10);
        l_user_type      varchar2(2) := -1;
        l_failed_att     number(10) := 0;
        l_locked_time    varchar2(30);
        l_emp_reg_type   varchar2(10);
  --l_USER_TYPE  VARCHAR2(100);
        l_password       varchar2(100);
        l_acc_num        number(10);
        l_balance        number(10);
        l_covg_period    varchar2(100);
        l_tax_id         varchar2(100); --Check this variable ??Null;
        l_time_diff      varchar2(1000);
        l_plan_name      varchar2(100);
        l_record_t       user_record_row_t;
        x_error_status   varchar2(10);
        l_rec_exist      varchar2(10);
        l_acc_id         number;
        l_ssn            varchar2(20);
        l_user_status    varchar2(1);   -- Added by Swamy for Ticket#9831
  --l_locked_time  VARCHAR2(100);
        l_invalid_user   varchar2(10) := 'I';
        cursor cur_invalid_user is
        select
            *
        from
            online_users
        where
            user_name = p_user_name;

    begin
        x_error_status := 'E';
        if p_user_name is null
           or p_passwd is null then
            l_record_t.error_message := 'Please enter a valid username/password';
            l_record_t.ssn := null;
            l_record_t.username := p_user_name;
            pipe row ( l_record_t );
        end if;

        for c1 in cur_invalid_user loop
            l_invalid_user := 'V';
            l_record_t.username := p_user_name;
    --PIPE ROW(l_record_t);
        end loop;

        if l_invalid_user = 'I' then
            l_record_t.error_message := 'Invalid User Name.Please Try Again';
            l_record_t.ssn := null;
            l_record_t.username := p_user_name;
            pipe row ( l_record_t );
        end if;

        for x in (
            select
                user_name,
                password,
                tax_id,
                user_id,
                user_type,
                user_status    -- Added by Swamy for Ticket#9831
            from
                online_users
            where
                    user_name = p_user_name
                and password = p_passwd
    --AND user_type = 'S' --Only for Employees
        ) loop
    --pc_log.log_error('BBBtry','In Fn2');
            l_record_t.username := x.user_name;
            l_record_t.ssn := x.tax_id;
            l_ssn := x.tax_id;
            l_user_type := x.user_type;
            l_user_status := x.user_status;   -- Added by Swamy for Ticket#9831
            l_record_t.user_id := x.user_id;
            l_record_t.error_message := 'Success';
            x_error_status := 'S';
    --UPDATE ONLINE_USERS
    --SET failed_att = 0,
    --locked_time='00:00:00',
    --failed_ip = null
    --WHERE user_name = P_user_name;
            if l_user_type in ( 'E', 'B' )
               or l_user_status in ( 'I', 'D' ) then    -- Added OR cond by Swamy for Ticket#9831
                x_error_status := 'E';
            end if;

            for i in (
                select
                    user_name
                from
                    blocked_users
                where
                    user_name = p_user_name
            ) loop
                l_record_t.username := p_user_name;
                l_record_t.error_message := 'Blocked user';
                x_error_status := 'B';
                pipe row ( l_record_t );
            end loop;

            if x_error_status = 'S' then
                for j in (
                    select
                        user_name,
                        confirmed_flag,
                        failed_att,
                        locked_time,
                        emp_reg_type,
                        user_type
                    from
                        online_users
                    where
                            user_name = p_user_name
                        and password = p_passwd
                ) loop
                    if j.confirmed_flag = 'N' then
                        pc_log.log_error('PC_WEB_UTILITY_PKG', 'Your Registration is not complete until you have clicked on the confirmation email sent to you'
                        );
                        l_record_t.username := p_user_name;
                        l_record_t.error_message := 'Your Registration is not complete until you have clicked on the confirmation email sent to you'
                        ;
                        l_record_t.ssn := null;
                        x_error_status := 'R';
                        pipe row ( l_record_t );
                    end if;
        --IF j.Emp_Reg_Type = '1' Then
        -- l_time_diff := round(abs(to_date(j.locked_time,'rrrr-mm-dd hh24:mi:ss') - to_date(SYSDATE,'rrrr-mm-dd hh24:mi:ss'))) / 60;
                    if j.locked_time = '00:00:00' then
                        l_locked_time := null;
                    else
                        l_locked_time := j.locked_time;
                    end if;

                    l_time_diff := ( sysdate - to_date ( l_locked_time, 'rrrr-mm-dd hh24:mi:ss' ) ) * 24;
                    pc_log.log_error('PC_WEB_UTILITY_PKG', 'Locked Time ' || l_time_diff);
                    if
                        j.failed_att >= 3
                        and l_time_diff <= '.30'
                    then
                        pc_log.log_error('PC_WEB_UTILITY_PKG', 'Account is temporarily locked. You can try again after 30 minutes');
                        l_record_t.username := p_user_name;
                        l_record_t.error_message := 'Account is temporarily locked. You can try again after 30 minutes';
                        l_record_t.ssn := null;
                        x_error_status := 'F';
                        pipe row ( l_record_t );
                    elsif
                        j.failed_att >= 3
                        and l_time_diff >= '.30'
                    then
          --pc_log.log_error('BFUpdt','In Fn');
          /*UPDATE ONLINE_USERS
          SET failed_att  = 0,
            LOCKED_TIME   =NULL
          WHERE USER_NAME = p_user_name ;*/

                        pc_users.unlock_user(p_user_name, p_passwd);
          --pc_log.log_error('AFUpdt','In Fn');
                        commit;
                    end if;
        -- END IF;
                end loop;
            end if;

        end loop;

        if
            x_error_status = 'E'
            and l_user_type = 'E'
        then
            l_record_t.username := p_user_name;
            l_record_t.error_message := 'You cannot login to mobile website with your credentials';
            l_record_t.ssn := null;
            pipe row ( l_record_t );
        elsif
            x_error_status = 'E'
            and l_user_type = 'B'
        then
            l_record_t.username := p_user_name;
            l_record_t.error_message := 'You cannot login to mobile website with your credentials';
            l_record_t.ssn := null;
            pipe row ( l_record_t );
        elsif
            x_error_status = 'E'
            and l_user_status = 'I'
        then   -- Added OR cond by Swamy for Ticket#9831
            l_record_t.username := p_user_name;
            l_record_t.error_message := 'User is Inactive,You cannot login to mobile website with your credentials';
            l_record_t.ssn := null;
            pipe row ( l_record_t );
        elsif
            x_error_status = 'E'
            and l_user_status = 'D'
        then   -- Added OR cond by Swamy for Ticket#9831
            l_record_t.username := p_user_name;
            l_record_t.error_message := 'User is Deleted,You cannot login to mobile website with your credentials';
            l_record_t.ssn := null;
            pipe row ( l_record_t );
        end if;

        if
            x_error_status = 'E'
            and l_user_type = '-1'
        then
            l_record_t.username := p_user_name;
            l_record_t.error_message := 'Your Account and Password combination is Invalid.Please try again';
            l_record_t.ssn := null;
            x_error_status := 'E';
    --Ask how to handle DML operation inside a query
    --Throws error 14551. 00000 -  cannot perform a DML operation inside a query
    --pc_log.log_error('AtrylockedTime',to_char(sysdate,'yyyy-mm-dd hh:mi:ss'));
   /* UPDATE ONLINE_USERS
    SET failed_att  = failed_att+1,
        LOCKED_TIME   =TO_CHAR(sysdate,'yyyy-mm-dd hh:mi:ss'),

    WHERE USER_NAME = p_user_name ;*/
            pc_users.lock_user(l_record_t.user_id, 'WRONG_PASSWORD', 'MOBILE');
            commit;
            select
                failed_att
            into l_failed_att
            from
                online_users
            where
                user_name = p_user_name;
    --      pc_log.log_error('AtryFailedAtt',l_FAILED_ATT);
    --   pc_log.log_error('AtryRowsModi',SQL%ROWCOUNT);
            if l_failed_att > 3 then
      --pc_log.log_error('Atry','In loop2');
                l_record_t.username := p_user_name;
                l_record_t.error_message := 'Account is temporarily locked. You can try again after 30 minutes';
                l_record_t.ssn := null;
                x_error_status := 'F';
            end if;

            pipe row ( l_record_t );
        elsif x_error_status = 'S' then
            pipe row ( l_record_t );
        end if;

    end validate_users;

    function get_balances (
        p_ssn          in varchar2,
        p_account_type in varchar2
    ) return balance_record_t
        pipelined
        deterministic
    is

        l_balance_record balance_record_row_t;
        l_acc_num        varchar2(10);
        l_balance        number(10);
        l_tax_id         varchar2(20);
        l_covg_period    varchar2(100);
        l_plan_name      varchar2(100);
        x_error_status   varchar2(10);
        cursor cur_get_fsa_bal (
            l_tax_id varchar2
        ) is
        select
            b.acc_num,
            b.acc_id,
            plan_desc                                 plan_name,
            to_char(a.plan_start_date, 'MM/DD/YYYY')
            || '-'
            || to_char(a.plan_end_date, 'MM/DD/YYYY') coverage_period,
            balance
        from
            fsa_ee_balances_v a,
            acc_overview_v    b
        where
            a.account_type in ( 'HRA', 'FSA' )
            and a.acc_id = b.acc_id
            and b.tax_id = l_tax_id;

    begin
  --pc_log.log_error(p_SSN||'-'||P_Account_Type,'In Balance');
        select
            format_ssn(p_ssn)
        into l_tax_id
        from
            dual;

        dbms_output.put_line('HRA , l_tax_id' || l_tax_id);
        x_error_status := 'E';
  -- SELECT tax_id
  -- INTO l_tax_id
  -- FROM ACC_OVERVIEW_V
  -- WHERE format_ssn(SSN) = format_ssn(P_SSN);
        if
            p_account_type = 'HSA'
            and l_tax_id is not null
        then
            pc_log.log_error('PC_WEB_UTILITY_PKG', l_tax_id);
            for x in (
                select
                    acc_num,
                    acc_id,
                    nvl(
                        pc_account.acc_balance(acc_id),
                        0.00
                    ) as balance
                from
                    acc_overview_v
                where
                        account_type = 'HSA'
                    and account_status <> 4
                    and tax_id = p_ssn
            ) loop
                l_balance_record.ssn := p_ssn;
                l_balance_record.account_type := 'HSA';
                l_balance_record.balance := x.balance;
                l_balance_record.acct_num := x.acc_num;
                l_balance_record.acct_id := x.acc_id;
                x_error_status := 'S';
                pipe row ( l_balance_record );
            end loop;

            if x_error_status = 'E' then
                l_balance_record.ssn := p_ssn;
                l_balance_record.account_type := 'HSA';
                l_balance_record.error_message := 'Error while Deriving HSA Balance' || sqlerrm;
                l_balance_record.balance := 0;
                pipe row ( l_balance_record );
            end if;

        else
            for x in (
                select
                    benefit_year               coverage_period,
                    acc_balance                balance,
                    acc_num,
                    acc_id,
                    plan_end_date,
                    nvl(runout_period_days, 0) runout_period_days,
                    nvl(grace_period, 0)       grace_period,
                    a.show_account_online  -- Added by Swamy for Ticket# Prod Issue 14-mar-23
                from
                    fsa_hra_employees_v a
                where
                        ssn = l_tax_id
                    and plan_end_date + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
            ) loop
                dbms_output.put_line('HRA , account' || x.acc_num);
                l_balance_record.show_account_online := x.show_account_online;   -- Added by Swamy for Ticket# Prod Issue 14-mar-23
                l_balance_record.ssn := p_ssn;
                l_balance_record.account_type := p_account_type;
                if x.plan_end_date + x.runout_period_days + x.grace_period >= trunc(sysdate) then
                    l_balance_record.balance := x.balance;
                end if;

                l_balance_record.acct_num := x.acc_num;
                l_balance_record.acct_id := x.acc_id;
                l_covg_period := x.coverage_period;
                x_error_status := 'S';
                pipe row ( l_balance_record );
            end loop;

            if x_error_status = 'E' then
                l_balance_record.ssn := p_ssn;
                l_balance_record.account_type := p_account_type;
                l_balance_record.balance := 0;
 --     l_balance_record.Error_message := 'Error while Deriving HRA Balance'||sqlerrm;
                pipe row ( l_balance_record );
            end if;
 /* ELSE --For FSA we will have multiple records
    FOR c1 IN cur_get_fsa_bal(l_tax_id)
    LOOP
      l_balance_record.SSN          := P_SSN;
      l_balance_record.balance      := c1.balance;
      l_balance_record.account_type := 'FSA';
      l_balance_record.acct_num     := c1.acc_num;
      l_balance_record.acct_id      := c1.acc_id;
      x_error_status                := 'S';
      PIPE ROW(l_balance_record );
    END LOOP;
    IF x_error_status                 = 'E' THEN
      l_balance_record.SSN           := P_SSN;
      l_balance_record.Account_TYPE  := 'FSA';
      l_balance_record.balance       := 0;
      l_balance_record.Error_message := 'Error while Deriving FSA Balance'||sqlerrm;
      PIPE ROW (l_balance_record);
    END IF;*/

        end if;

    end get_balances;

    function get_acc_info (
        p_acc_num in varchar2
    ) return acc_info_record
        pipelined
        deterministic
    is

        l_record            acc_info_row_t;
        l_name              varchar2(100);
        l_address           varchar2(1000);
        l_city              varchar2(100);
        l_state             varchar2(100);
        l_zip               number;
        l_plan_name         varchar2(100);
        l_start_date        date;
        l_acc_balance       number(10);
        l_available_balance number(10);
        l_bal_with_fee      number(10);
        l_bill_pay_fee      number(10);
        l_acc_id            number(10);
        l_ssn               varchar2(20);
        l_pers_id           number(10);
        l_card_count        number(10);
        l_entrp_id          number(10);
        x_error_status      varchar2(10);
    begin
        x_error_status := 'E';
        for x in (
            select
                name,
                address,
                city,
                state,
                zip,
                acc_num,
                plan_name,
                start_date,
                decode(
                    sign(acc_balance),
                    -1,
                    0,
                    acc_balance
                )                               acc_balance,
                decode(
                    sign(available_balance),
                    -1,
                    0,
                    available_balance
                )                               available_balance,
                decode(
                    sign(acc_balance),
                    -1,
                    0,
                    acc_balance
                ) - nvl(
                    pc_fin.get_bill_pay_fee(acc_id),
                    0
                )                               bal_with_fee,
                pc_fin.get_bill_pay_fee(acc_id) bill_pay_fee,
                acc_id,
                ssn,
                pers_id,
                card_count,
                entrp_id
            from
                acc_overview_v
            where
                acc_num = p_acc_num
        ) loop
  /*  L_NAME                  := x.name;
    L_ADDRESS               := x.address;
    L_CITY                  := x.city;
    L_STATE                 := x.state;
    L_ZIP                   := x.zip;*/
            l_record.acc_num := x.acc_num;
            l_record.plan_name := x.plan_name;
            l_record.effective_date := x.start_date;
            l_record.acct_balance := x.acc_balance;
   /* l_AVAILABLE_BALANCE     := x.AVAILABLE_BALANCE;
    L_BAL_WITH_FEE          := x.bal_with_fee;
    L_BILL_PAY_FEE          := x.bill_pay_fee;
    l_ACC_ID                := x.acc_id;
    l_SSN                   := x.SSN;
    l_PERS_ID               := x.pers_id;
    l_CARD_COUNT            := x.card_count;
    l_ENTRP_ID              := x.entrp_id;*/
            x_error_status := 'S';
            l_record.error_message := 'Successfull';
            pipe row ( l_record );
        end loop;

        if x_error_status = 'E' then
            l_record.acc_num := p_acc_num;
            l_record.error_message := 'Error while retrieving Acct information' || sqlerrm;
            l_record.acct_balance := 0;
            l_record.acc_num := p_acc_num;
            pipe row ( l_record );
        end if;

    end get_acc_info;

    function get_bank_details (
        p_acc_num   in varchar2,
        p_tran_type in varchar2
    ) return bank_record_t
        pipelined
        deterministic
    is

        l_record       bank_record_row_t;
        x_error_status varchar2(10);
        cursor cur_bank_det is
        select
            bank_acct_id,
            acc_id,
            acc_num,
            display_name,
            bank_acct_type,
            account_type,
            bank_acct_num,
            bank_routing_num,
            mod(rownum, 2) rn
        from
            (
                select
                    bank_acct_id,
                    acc_id,
                    acc_num,
                    display_name,
                    bank_acct_type,
                    decode(bank_acct_type, 'C', 'Checking/Money Market', 'S', 'Saving',
                           'SV', 'Saving') account_type,
                    bank_acct_num,
                    bank_routing_num
                from
                    user_bank_acct_v
                where
                        status = 'A'
                    and bank_account_usage = 'ONLINE'
                    and acc_num = p_acc_num
                order by
                    bank_acct_id desc
            );

    begin
        x_error_status := 'E';
        for c1 in cur_bank_det loop
            l_record.bank_acc_id := c1.bank_acct_id;
            l_record.acc_id := c1.acc_id;
            l_record.acc_num := c1.acc_num;
            l_record.display_name := c1.display_name;
            l_record.bank_acct_type := c1.bank_acct_type;
            l_record.account_type := c1.account_type;
            l_record.bank_acct_num := c1.bank_acct_num;
            l_record.bank_routing_num := c1.bank_routing_num;
            x_error_status := 'S';
            pipe row ( l_record );
        end loop;

        if x_error_status = 'E' then
            l_record.bank_acc_id := null;
            if p_tran_type = 'C' then
                l_record.error_message := 'You do not have a bank account on record.You must add a bank account by logging into sterlinghsa.com to schedule contributions.'
                ;
            else
                l_record.error_message := 'You do not have a bank account on record.You must add a bank account by logging into sterlinghsa.com to schedule disbursements.'
                ;
            end if;

            pipe row ( l_record );
        end if;

    end get_bank_details;

    function get_fee_details return fee_desc_t
        pipelined
        deterministic
    is

        l_record       fee_desc_row_t;
        x_error_status varchar2(10);
        cursor cur_fee_det is
        select
            fee_code,
            fee_name
        from
            fee_names
        where
            fee_code in ( 4, 5, 6, 7 )
            and fee_code in ( 4, 5, 6 )
            or ( fee_code = 7
                 and sysdate between trunc(sysdate, 'YYYY') and trunc(sysdate, 'YYYY') + 104 );

    begin
        for c1 in cur_fee_det loop
            l_record.fee_code := c1.fee_code;
            l_record.fee_name := c1.fee_name;
            pipe row ( l_record );
        end loop;
    end get_fee_details;

    function get_reason_details return reason_code_t
        pipelined
        deterministic
    is
        l_record reason_code_record_t;
        cursor cur_det is
        select
            *
        from
            lookups
        where
            lookup_name like 'WEB_EXPENSE_TYPE';

    begin
        for c1 in cur_det loop
            l_record.lookup_code := c1.lookup_code;
            l_record.lookup_name := c1.lookup_name;
            l_record.description := c1.description;
            l_record.meaning := c1.meaning;
            pipe row ( l_record );
        end loop;
    end get_reason_details;

    function get_disbur_contrib_details (
        p_tran_type in varchar2,
        p_acc_id    in number,
        p_acct_type in varchar2
    ) return disbur_contrib_record
        pipelined
        deterministic
    is

        l_record disbur_contrib_record_t;
        cursor cur_contrib (
            l_acc_id number
        ) is
        select
            *
        from
            (
                select
                    to_char(fee_date, 'MM/DD/YYYY')                                                     fee_date,
                    b.fee_name,
                    nvl(amount_add, 0) + nvl(ee_fee_amount, 0) + nvl(amount, 0) + nvl(er_fee_amount, 0) total,
                    change_num
                from
                    income    a,
                    fee_names b
                where
                        acc_id = l_acc_id
                    and a.fee_code = b.fee_code
                    and nvl(a.fee_code, -1) <> 8
                order by
                    change_num desc
            )
        where
            rownum < 6
        order by
            to_date(fee_date, 'MM/DD/YYYY') desc;

        cursor cur_contrib_fsa (
            l_acc_id number
        ) is
        select
            *
        from
            (
                select
                    to_char(fee_date, 'MM/DD/YYYY')                                                     fee_date,
                    b.fee_name,
                    nvl(amount_add, 0) + nvl(ee_fee_amount, 0) + nvl(amount, 0) + nvl(er_fee_amount, 0) total,
                    plan_type,
                    change_num
                from
                    income    a,
                    fee_names b
                where
                        acc_id = l_acc_id
                    and a.fee_code = b.fee_code
                    and nvl(a.fee_code, -1) not in ( 8, 4, 12 )
                order by
                    change_num desc
            )
        where
            rownum < 6
        order by
            to_date(fee_date, 'MM/DD/YYYY') desc;

        cursor cur_disbur (
            l_acc_id number
        ) is
        select
            *
        from
            (
                select
                    to_char(paid_date, 'MM/DD/YYYY') claim_date,
                    b.reason_name,
                    nvl(amount, 0)                   amount,
                    a.plan_type,
                    a.claimn_id
                from
                    payment    a,
                    pay_reason b
                where
                        acc_id = l_acc_id
                    and a.reason_code = b.reason_code
                    and b.reason_type = 'DISBURSEMENT'
                    and a.claimn_id is not null
                order by
                    5 desc
            )
        where
            rownum < 6
        order by
            to_date(claim_date, 'MM/DD/YYYY') desc;

    begin
        if p_tran_type = 'C' then
            if p_acct_type = 'HSA' then
                for c1 in cur_contrib(p_acc_id) loop
                    l_record.fee_date := c1.fee_date;
                    l_record.fee_name := c1.fee_name;
                    l_record.amount := c1.total;
        --l_record.plan_type := c1.plan_type;
                    pipe row ( l_record );
                end loop;

            else
                for c1 in cur_contrib_fsa(p_acc_id) loop
                    l_record.fee_date := c1.fee_date;
                    l_record.fee_name := c1.fee_name;
                    l_record.amount := c1.total;
                    l_record.plan_type := c1.plan_type;
                    pipe row ( l_record );
                end loop;
            end if;

        else
            for c1 in cur_disbur(p_acc_id) loop
                l_record.fee_date := c1.claim_date;
                l_record.fee_name := c1.reason_name;
                l_record.amount := c1.amount;
                l_record.plan_type := c1.plan_type;
                pipe row ( l_record );
            end loop;
        end if;
    end get_disbur_contrib_details;

    function get_acct_details (
        p_acc_num in varchar2
    ) return acc_details_t
        pipelined
        deterministic
    is

        l_record acc_details_row_t;
        cursor cur_acct_det is
        select
            name,
            acc_num,
            account_type,
            balance,
            annual_election,
            plan_type,
            plan_desc,
            to_char(start_date, 'MM/DD/YYYY') start_date,
            plan_end_date,
            runout_period_days,
            grace_period,
            pers_id,
            acc_id
        from
            (
                select distinct
                    name,
                    acc_num,
                    account_type,
                    start_date,
                    acc_balance                             balance,
                    annual_election,
                    plan_type,
                    pc_lookups.get_fsa_plan_type(plan_type) plan_desc,
                    plan_end_date,
                    nvl(runout_period_days, 0)              runout_period_days,
                    nvl(grace_period, 0)                    grace_period,
                    pers_id,
                    acc_id
                from
                    fsa_hra_employees_v
                where
                    acc_num = p_acc_num
                union all
                select
                    null,
                    acc_num,
                    account_type,
                    start_date,
                    pc_account.acc_balance(acc_id),
                    0,
                    null,
                    null,
                    null,
                    0,
                    0,
                    pers_id,
                    acc_id
                from
                    account
                where
                        acc_num = p_acc_num
                    and account_type = 'HSA'
                order by
                    start_date desc
            );

    begin
        for c1 in cur_acct_det loop
            l_record.name := c1.name;
            l_record.acc_id := c1.acc_id;
            l_record.acc_num := c1.acc_num;
            l_record.acct_type := c1.account_type;
            l_record.effective_date := c1.start_date;
            if c1.account_type in ( 'HRA', 'FSA' ) then
                if c1.plan_end_date + c1.runout_period_days + c1.grace_period >= trunc(sysdate) then
                    l_record.acct_balance := c1.balance;
                else
                    l_record.acct_balance := 0;
                end if;
            else
                l_record.acct_balance := c1.balance;
            end if;

            for xx in (
                select
                    address,
                    city,
                    state,
                    zip
                from
                    person
                where
                    pers_id = c1.pers_id
            ) loop
                l_record.address := xx.address;
                l_record.city := xx.city;
                l_record.state := xx.state;
                l_record.zip := xx.zip;
            end loop;

            l_record.plan_type := c1.plan_type;
            l_record.plan_desc := c1.plan_desc;
            l_record.annual_election := c1.annual_election;
            l_record.error_message := null;
            pipe row ( l_record );
        end loop;
    end get_acct_details;

    function get_schd_txn (
        p_tran_type in varchar2,
        p_acc_id    in number
    ) return schd_txn_record
        pipelined
        deterministic
    is

        l_record schd_txn_record_t;
        cursor cur_schd_txn is
        select
            *
        from
            (
                select
                    to_char(transaction_date, 'MM/DD/YYYY')    txn_date,
                    claim_id,
                    total_amount,
                    decode(status, 1, 'Pending', 2, 'Pending') status
                from
                    ach_transfer
                where
                        acc_id = p_acc_id
                    and transaction_type = p_tran_type
                    and status in ( 1, 2 ) --Only pending
                order by
                    transaction_date asc
            )
        where
            rownum < 6;

        cursor cur_schd_txn_contrb is
        select
            *
        from
            (
                select
                    to_char(transaction_date, 'MM/DD/YYYY')    txn_date,
                    transaction_id,
                    total_amount,
                    decode(status, 1, 'Pending', 2, 'Pending') status
                from
                    ach_transfer
                where
                        acc_id = p_acc_id
                    and transaction_type = p_tran_type
                    and status in ( 1, 2 ) --Only pending
                order by
                    transaction_date asc
            )
        where
            rownum < 6;

    begin
        if p_tran_type = 'D' then
            for c1 in cur_schd_txn loop
                l_record.txn_date := c1.txn_date;
                l_record.status := c1.status;
                l_record.amount := c1.total_amount;
                l_record.txn_id := c1.claim_id;
                pipe row ( l_record );
            end loop;

        else
            for c1 in cur_schd_txn_contrb loop
                l_record.txn_date := c1.txn_date;
                l_record.status := c1.status;
                l_record.amount := c1.total_amount;
                l_record.txn_id := c1.transaction_id;
                pipe row ( l_record );
            end loop;
        end if;
    end get_schd_txn;

    function get_acct_type (
        p_user_name in varchar2
    ) return ret_acct_type
        pipelined
        deterministic
    is

        l_record ret_acct_type_t;
        cursor cur_acct_type is
        select distinct
            account_type
        from
            acc_overview_v a,
            online_users   b
        where
                a.tax_id = b.tax_id
            and b.user_name = p_user_name;

    begin
        for c1 in cur_acct_type loop
            l_record.account_type := c1.account_type;
            pipe row ( l_record );
        end loop;
    end get_acct_type;

    function get_contrb_amt (
        p_acc_num in varchar2
    ) return ret_contrb_amt
        pipelined
        deterministic
    is

        l_record ret_contrb_amt_t;
        cursor cur_contrb_amt is
        select
            acc_num,
            acc_id,
            pers_id,
            effective_date,
            plan_type,
            ( to_number(pc_param.get_system_value(
                decode(
                    nvl(plan_type_code, 0),
                    0,
                    'INDIVIDUAL_CONTRIBUTION',
                    1,
                    'FAMILY_CONTRIBUTION'
                ),
                trunc(sysdate, 'YYYY')
            )) +
              case
                  when round(months_between(sysdate, birth_date) / 12) >= 55 then
                        nvl(to_number(pc_param.get_system_value('CATCHUP_CONTRIBUTION',
                                                                trunc(sysdate, 'YYYY'))),
                            0)
                  else
                      0
              end
            ) - nvl(
                pc_account_details.get_current_year_total(acc_id,
                                                          trunc(sysdate, 'yyyy'),
                                                          sysdate,
                                                          effective_date),
                0.00
            ) contribution_limit,
            nvl(
                pc_account_details.get_current_year_total(acc_id,
                                                          trunc(sysdate, 'yyyy'),
                                                          sysdate,
                                                          effective_date),
                0.00
            ) current_yr_contrib,
            nvl(
                pc_account_details.get_disbursement_total(acc_id,
                                                          trunc(sysdate, 'yyyy'),
                                                          sysdate),
                0.00
            ) total_disb_amount
        from
            acc_user_profile_v
        where
            acc_num = p_acc_num;

    begin
        for c1 in cur_contrb_amt loop
            l_record.pers_id := c1.pers_id;
            l_record.plan_type := c1.plan_type;
            l_record.effective_date := c1.effective_date;
            l_record.contrb_limit := c1.contribution_limit;
            l_record.current_yr_contrb := c1.current_yr_contrib;
            l_record.total_disb_amount := c1.total_disb_amount;
            pipe row ( l_record );
        end loop;
    end get_contrb_amt;

    function get_acct_num_det (
        p_acc_num in varchar2
    ) return ret_acct_t
        pipelined
        deterministic
    is
        l_record ret_acct_det;
    begin
        select
            acc_id
        into l_record.acc_id
        from
            account
        where
            acc_num = p_acc_num;

        l_record.error_msg := 'Successfully logged in ';
        pipe row ( l_record );
    exception
        when others then
            l_record.acc_id := null;
            l_record.error_msg := 'Invalid Account Number. Please Check ';
            pipe row ( l_record );
    end get_acct_num_det;

    function get_dc_unsub_claims (
        p_acc_num     in varchar2,
        p_reason_code in number
    ) return claim_t
        pipelined
        deterministic
    is
        l_record claim_record_t;
    begin
        for x in (
            select
                to_char(b.claim_date, 'MM/DD/YYYY')          claim_date,
                b.claim_id,
                b.claim_amount,
                b.prov_name,
                b.service_type,
                pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
                b.pers_id,
                c.acc_id,
                c.acc_num,
                pc_lookups.get_claim_status(b.claim_status)  claim_status,
                nvl(b.offset_amount, 0)                      offset_amount,
                b.claim_amount - nvl(b.offset_amount, 0)     remaining_amount,
                'Debit Card Purchase'                        reason,
                13                                           pay_reason
            from
                claimn  b,
                account c
            where
                    b.claim_status = 'PAID'
                and b.pers_id = c.pers_id
                and c.account_type in ( 'HRA', 'FSA' )
                and unsubstantiated_flag = 'Y'
                and exists (
                    select
                        *
                    from
                        payment a
                    where
                            a.claimn_id = b.claim_id
                        and a.reason_code = 13
                )
                and ( b.substantiation_reason is null
                      or b.substantiation_reason <> 'SUPPORT_DOC_RECV' )
                and c.acc_num = p_acc_num
                and p_reason_code in ( 0, 13 ) -- if 0 is passed in then we have to list all the claims
            union
            select
                to_char(b.claim_date, 'MM/DD/YYYY')          claim_date,
                b.claim_id,
                b.claim_amount,
                b.prov_name,
                b.service_type,
                pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
                b.pers_id,
                c.acc_id,
                c.acc_num,
                pc_lookups.get_claim_status(b.claim_status)  claim_status,
                nvl(b.offset_amount, 0)                      offset_amount,
                b.claim_amount - nvl(b.offset_amount, 0)     remaining_amount,
                pc_lookups.get_reason_name(d.pay_reason),
                d.pay_reason
            from
                claimn           b,
                account          c,
                payment_register d
            where
                    b.claim_status = 'PENDING_DOC'
                and b.pers_id = c.pers_id
                and b.claim_id = d.claim_id
                and c.acc_id = d.acc_id
                and c.account_type in ( 'HRA', 'FSA' )
                and c.acc_num = p_acc_num
                and p_reason_code <> 13
        ) loop
            l_record.claim_id := x.claim_id;
            l_record.claim_amount := x.claim_amount;
            l_record.provider_name := x.prov_name;
            l_record.service_type := x.service_type;
            l_record.service_type_meaning := x.service_type_meaning;
            l_record.claim_date := x.claim_date;
            l_record.pers_id := x.pers_id;
            l_record.acc_id := x.acc_id;
            l_record.acc_num := x.acc_num;
            l_record.claim_status := x.claim_status;
            l_record.offset_amount := x.offset_amount;
            l_record.remaining_offset := x.remaining_amount;
            l_record.reason_name := x.reason;
            l_record.reason_code := x.pay_reason;
            pipe row ( l_record );
        end loop;
    end get_dc_unsub_claims;

    function get_dc_unsub_claim_det (
        p_claim_id in number
    ) return claim_t
        pipelined
        deterministic
    is
        l_record claim_record_t;
    begin
        for x in (
            select
                to_char(b.claim_date, 'MM/DD/YYYY')          claim_date,
                b.claim_id,
                b.claim_amount,
                b.prov_name,
                b.service_type,
                pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
                b.pers_id,
                c.acc_id,
                c.acc_num,
                pc_lookups.get_claim_status(b.claim_status)  claim_status,
                nvl(b.offset_amount, 0)                      offset_amount,
                b.claim_amount - nvl(b.offset_amount, 0)     remaining_amount,
                'Debit Card Purchase'                        reason,
                13                                           reason_code
            from
                claimn  b,
                account c
            where
                    b.claim_status = 'PAID'
                and b.pers_id = c.pers_id
                and c.account_type in ( 'HRA', 'FSA' )
                and unsubstantiated_flag = 'Y'
                and exists (
                    select
                        *
                    from
                        payment a
                    where
                            a.claimn_id = b.claim_id
                        and a.reason_code = 13
                )
                and ( b.substantiation_reason is null
                      or b.substantiation_reason <> 'SUPPORT_DOC_RECV' )
                and b.claim_id = p_claim_id
            union
            select
                to_char(b.claim_date, 'MM/DD/YYYY')          claim_date,
                b.claim_id,
                b.claim_amount,
                b.prov_name,
                b.service_type,
                pc_lookups.get_fsa_plan_type(b.service_type) service_type_meaning,
                b.pers_id,
                c.acc_id,
                c.acc_num,
                pc_lookups.get_claim_status(b.claim_status)  claim_status,
                nvl(b.offset_amount, 0)                      offset_amount,
                b.claim_amount - nvl(b.offset_amount, 0)     remaining_amount,
                pc_lookups.get_reason_name(d.pay_reason),
                d.pay_reason
            from
                claimn           b,
                account          c,
                payment_register d
            where
                    b.claim_status = 'PENDING_DOC'
                and b.pers_id = c.pers_id
                and b.claim_id = d.claim_id
                and c.acc_id = d.acc_id
                and c.account_type in ( 'HRA', 'FSA' )
                and b.claim_id = p_claim_id
        ) loop
            l_record.claim_id := x.claim_id;
            l_record.claim_amount := x.claim_amount;
            l_record.provider_name := x.prov_name;
            l_record.service_type := x.service_type;
            l_record.service_type_meaning := x.service_type_meaning;
            l_record.claim_date := x.claim_date;
            l_record.pers_id := x.pers_id;
            l_record.acc_id := x.acc_id;
            l_record.acc_num := x.acc_num;
            l_record.claim_status := x.claim_status;
            l_record.offset_amount := x.offset_amount;
            l_record.remaining_offset := x.remaining_amount;
            l_record.reason_name := x.reason;
            l_record.reason_code := x.reason_code;
            pipe row ( l_record );
        end loop;
    end get_dc_unsub_claim_det;
/* FUNCTION get_hsa_employees(p_er_accnum IN VARCHAR2 ,p_search_by IN VARCHAR2,p_search_value IN VARCHAR2
                           ,p_sort_by IN VARCHAR2,p_sort_order IN VARCHAR2)
 RETURN  employee_t PIPELINED DETERMINISTIC
IS
  l_ACC_id   NUMBER;
  type r_cursor is REF CURSOR;
  c_cur r_cursor;
  l_record_t employee_record_t;
  l_sql      VARCHAR2(3200);
BEGIN

   PC_LOG.LOG_ERROR('get_hsa_employees','p_er_accnum '||p_er_accnum||' p_search_by '||p_search_by||' p_search_value '||p_search_value
                                       ||' p_sort_by '||p_sort_by|| ' p_sort_order '||p_sort_order);

   l_ACC_id := PC_ACCOUNT.GET_ACC_ID(p_er_accnum);
   IF l_acc_id IS NOT NULL THEN
     l_sql := 'select NAME,FIRST_NAME,LAST_NAME, ACC_NUM, START_DATE, ACC_STATUS,PERS_ID, ACC_ID
                     , ER_ACC_ID,HSA_EFFECTIVE_DATE,COMPLETE_FLAG from EMPLOYEES_V
               where ER_ACC_ID= '||l_ACC_id;
     IF p_search_value IS NOT NULL THEN
       IF p_search_by IN ('LAST_NAME','FIRST_NAME','ACC_NUM') THEN
        l_sql :=  l_sql ||' AND  UPPER('||p_search_by ||') LIKE ''%'  ||UPPER(p_search_value)||'%''';
       ELSE
        l_sql :=  l_sql ||' AND '|| p_search_by ||' = '''  ||p_search_value||'''';

       END IF;
     END IF;
     IF p_sort_by IS  NULL  THEN
            l_sql :=  l_sql ||' ORDER BY  LAST_NAME ASC';
      ELSE
         IF p_sort_by IN ('NAME','FIRST_NAME','LAST_NAME','ACC_NUM','START_DATE',
                         'ACC_STATUS','PERS_ID','ACC_ID','ER_ACC_ID',
                         'HSA_EFFECTIVE_DATE','COMPLETE_FLAG') THEN
             l_sql :=  l_sql ||' ORDER BY  '|| p_sort_by ||' '||NVL(p_sort_order,'');
         ELSE
           l_sql :=  l_sql ||' ORDER BY  LAST_NAME ASC';
         END IF;
     END IF;
     pc_log.log_error('get_hsa_employees','sql '||l_sql);

     OPEN c_cur FOR l_sql;
     LOOP
         fetch c_cur into l_record_t;
         exit when c_cur%notfound;*/
         /*  l_record_t.employee_name := x.name;
         l_record_t.first_name     := x.first_name;

         l_record_t.last_name     := x.last_name;
         l_record_t.acc_num       := x.acc_num;
         l_record_t.start_date    := x.start_date;
         l_record_t.acc_status    := x.acc_status;
         l_record_t.pers_id       := x.pers_id;
         l_record_t.acc_id        := x.acc_id;
         l_record_t.er_acc_id     := x.er_acc_id;
         l_record_t.hsa_effective_date := x.hsa_effective_date;*/

       /*  PIPE ROW (l_record_t);
     END LOOP;
 ELSE
     PIPE ROW (l_record_t);
  END IF;
EXCEPTION
   WHEN OTHERS THEN
       pc_log.log_app_error('PC_WEB_UTILITY_PKG','get_hsa_employees'
                , DBMS_UTILITY.FORMAT_CALL_STACK
                , DBMS_UTILITY.FORMAT_ERROR_STACK ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                , p_er_accnum ||':'||p_search_by ||':'||p_search_value||':'||p_sort_by ||':'||
                  p_sort_order );

END get_hsa_employees;
*/

-- Added by Swamy for Ticket#12013 12022024
    function get_hsa_employees (
        p_er_accnum    in varchar2,
        p_search_by    in varchar2,
        p_search_value in varchar2,
        p_sort_by      in varchar2,
        p_sort_order   in varchar2,
        p_start_row    in varchar2,
        p_end_row      in varchar2
    ) return employee_t
        pipelined
        deterministic
    is

        l_acc_id   number;
        type r_cursor is ref cursor;
        c_cur      r_cursor;
        l_record_t employee_record_t;
        l_sql      varchar2(3200);
        l_cond     varchar2(500);
        l_sort     varchar2(500);
        l_where    varchar2(100);
    begin
        pc_log.log_error('get_hsa_employees', 'p_er_accnum '
                                              || p_er_accnum
                                              || ' p_search_by '
                                              || p_search_by
                                              || ' p_search_value '
                                              || p_search_value
                                              || ' p_sort_by '
                                              || p_sort_by
                                              || ' p_sort_order '
                                              || p_sort_order
                                              || ' p_start_row :='
                                              || p_start_row
                                              || ' p_end_row :='
                                              || p_end_row);

        l_acc_id := pc_account.get_acc_id(p_er_accnum);
        if l_acc_id is not null then
            if p_search_value is not null then
                if p_search_by in ( 'LAST_NAME', 'FIRST_NAME', 'ACC_NUM' ) then
                    l_cond := ' AND  UPPER('
                              || p_search_by
                              || ') LIKE ''%'
                              || upper(p_search_value)
                              || '%''';

                else
                    l_cond := ' AND '
                              || p_search_by
                              || ' = '''
                              || p_search_value
                              || '''';
                end if;
            else
                l_cond := ' AND 1 =1 ';
            end if;

            if p_sort_by is null then
                l_sort := ' ORDER BY  LAST_NAME ASC';
            else
                if p_sort_by in ( 'NAME', 'FIRST_NAME', 'LAST_NAME', 'ACC_NUM', 'START_DATE',
                                  'ACC_STATUS', 'PERS_ID', 'ACC_ID', 'ER_ACC_ID', 'HSA_EFFECTIVE_DATE',
                                  'COMPLETE_FLAG' ) then
                    l_sort := ' ORDER BY  '
                              || p_sort_by
                              || ' '
                              || nvl(p_sort_order, '');

                else
                    l_sort := ' ORDER BY  LAST_NAME ASC';
                end if;
            end if;

            if
                nvl(p_start_row, '*') <> '*'
                and nvl(p_end_row, '*') <> '*'
            then
                l_where := ' WHERE outer.rn >= NVL('
                           || p_start_row
                           || ' ,outer.rn) AND outer.rn <= NVL('
                           || p_end_row
                           || ',outer.rn)';
            else
                l_where := ' WHERE 1 = 1';
            end if;

            pc_log.log_error('get_hsa_employees', 'l_cond '
                                                  || l_cond
                                                  || ' l_sort :='
                                                  || l_sort);
            l_sql := 'SELECT outer.*
     FROM (SELECT ROWNUM rn, inner.*
     FROM (select NAME,FIRST_NAME,LAST_NAME, ACC_NUM, START_DATE, ACC_STATUS,PERS_ID, ACC_ID
                     , ER_ACC_ID,HSA_EFFECTIVE_DATE,COMPLETE_FLAG from EMPLOYEES_V
               where ER_ACC_ID= '
                     || l_acc_id
                     || l_cond
                     || l_sort
                     || '
               ) inner) outer';
            l_sql := l_sql || l_where;
            pc_log.log_error('get_hsa_employees', 'sql ' || l_sql);
            open c_cur for l_sql;

            loop
                fetch c_cur into l_record_t;
                exit when c_cur%notfound;
                pipe row ( l_record_t );
            end loop;

        else
            pipe row ( l_record_t );
        end if;

    exception
        when others then
            pc_log.log_app_error('PC_WEB_UTILITY_PKG', 'get_hsa_employees', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace,
                                 p_er_accnum
                                 || ':'
                                 || p_search_by
                                 || ':'
                                 || p_search_value
                                 || ':'
                                 || p_sort_by
                                 || ':'
                                 || p_sort_order);
    end get_hsa_employees;

    function get_active_hsa_employees (
        p_er_accnum    in varchar2,
        p_search_by    in varchar2,
        p_search_value in varchar2,
        p_sort_by      in varchar2,
        p_sort_order   in varchar2
    ) return employee_t
        pipelined
        deterministic
    is

        l_acc_id   number;
        type r_cursor is ref cursor;
        c_cur      r_cursor;
        l_record_t employee_record_t;
        l_sql      varchar2(3200);
    begin
        pc_log.log_error('get_active_hsa_employees', 'p_er_accnum '
                                                     || p_er_accnum
                                                     || ' p_search_by '
                                                     || p_search_by
                                                     || ' p_search_value '
                                                     || p_search_value
                                                     || ' p_sort_by '
                                                     || p_sort_by
                                                     || ' p_sort_order '
                                                     || p_sort_order);

        l_acc_id := pc_account.get_acc_id(p_er_accnum);
        if l_acc_id is not null then
            l_sql := 'select ROWNUM,NAME,FIRST_NAME,LAST_NAME, ACC_NUM, START_DATE, ACC_STATUS,PERS_ID, ACC_ID
                       , ER_ACC_ID,HSA_EFFECTIVE_DATE,COMPLETE_FLAG from EMPLOYEES_V
                 where ER_ACC_ID= '
                     || l_acc_id
                     || ' AND ACCOUNT_STATUS <> 4 AND NVL(SIGNATURE_ON_FILE,''N'') = ''Y'' ';
            if p_search_value is not null then
                l_sql := l_sql
                         || ' AND '
                         || p_search_by
                         || ' = '
                         || p_search_value;
            end if;

            if p_sort_by is null then
                l_sql := l_sql || ' ORDER BY  LAST_NAME ASC';
            else
                if p_sort_by in ( 'NAME', 'FIRST_NAME', 'LAST_NAME', 'ACC_NUM', 'START_DATE',
                                  'ACC_STATUS', 'PERS_ID', 'ACC_ID', 'ER_ACC_ID', 'HSA_EFFECTIVE_DATE',
                                  'COMPLETE_FLAG' ) then
                    l_sql := l_sql
                             || ' ORDER BY  '
                             || p_sort_by
                             || ' '
                             || nvl(p_sort_order, '');

                else
                    l_sql := l_sql || ' ORDER BY  LAST_NAME ASC';
                end if;
            end if;

            open c_cur for l_sql;

            loop
                fetch c_cur into l_record_t;
                exit when c_cur%notfound;
           /*  l_record_t.employee_name := x.name;
           l_record_t.first_name     := x.first_name;

           l_record_t.last_name     := x.last_name;
           l_record_t.acc_num       := x.acc_num;
           l_record_t.start_date    := x.start_date;
           l_record_t.acc_status    := x.acc_status;
           l_record_t.pers_id       := x.pers_id;
           l_record_t.acc_id        := x.acc_id;
           l_record_t.er_acc_id     := x.er_acc_id;
           l_record_t.hsa_effective_date := x.hsa_effective_date;*/

                pipe row ( l_record_t );
            end loop;

        else
            pipe row ( l_record_t );
        end if;

    exception
        when others then
            pc_log.log_app_error('PC_WEB_UTILITY_PKG', 'get_active_hsa_employees', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace,
                                 p_er_accnum
                                 || ':'
                                 || p_search_by
                                 || ':'
                                 || p_search_value
                                 || ':'
                                 || p_sort_by
                                 || ':'
                                 || p_sort_order);
    end get_active_hsa_employees;

    function has_active_plan (
        p_acc_num in varchar2
    ) return number is
        l_no_of_plan number := 0;
    begin
        for x in (
            select
                count(*) no_of_plan
            from
                fsa_hra_employees_v
            where
                    acc_num = p_acc_num
                and plan_end_date + nvl(runout_period_days, 0) + nvl(grace_period, 0) >= trunc(sysdate)
                and plan_start_date <= trunc(sysdate)
        ) loop
            l_no_of_plan := x.no_of_plan;
        end loop;

        return l_no_of_plan;
    end has_active_plan;

    function check_card_suspend (
        p_acc_num in varchar2
    ) return ret_card_suspend_t
        pipelined
        deterministic
    is
        l_record card_suspend_t;
    begin
        for x in (
            select
                'Y' status
            from
                card_debit a,
                account    b
            where
                    b.acc_num = p_acc_num
                and a.card_id = b.pers_id
                and a.status in ( 4, 6 )
        ) loop
            l_record.status := x.status;
            pipe row ( l_record );
        end loop;
    end check_card_suspend;

    function display_debit_card_claim (
        p_claim_id in varchar2
    ) return ret_debit_claim_t
        pipelined
        deterministic
    is
        l_record debit_claim_t;
    begin
        for x in (
            select
                a.claim_amount,
                a.claim_status,
                nvl(c.amount, 0)                                     claim_paid,
                nvl(a.claim_pending, 0)                              claim_pending,
                nvl(a.approved_amount, 0)                            approved_amount,
                nvl(a.denied_amount, 0)                              denied_amount,
                pc_lookups.get_denied_reason(a.denied_reason)        denied_reason,
                (
                    select
                        reason_name
                    from
                        pay_reason r
                    where
                        r.reason_code = a.pay_reason
                )                                                    reimbursement_method,
                to_char(c.paid_date, 'MM/DD/YYYY')                   paid_date,
                ( nvl(a.claim_amount, 0) - nvl(a.offset_amount, 0) ) unsubstantiated_amount
            from
                claimn  a,
                payment c
            where
                    c.claimn_id = a.claim_id
                and a.claim_id = p_claim_id
                and reason_code = 13
        ) loop
            l_record.claim_status := initcap(x.claim_status);
            l_record.claim_paid := x.claim_paid;
            l_record.paid_date := x.paid_date;
            l_record.claim_pending := x.claim_pending;
            l_record.unsubstantiated_amount := x.unsubstantiated_amount;
            l_record.reimbursement_method := x.reimbursement_method;
            pipe row ( l_record );
        end loop;
    end display_debit_card_claim;

    procedure update_reason (
        p_claim_id in varchar2,
        p_user_id  in number
    ) is
    begin
        update claimn
        set
            substantiation_reason = 'SUPPORT_DOC_RECV',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            claim_id = p_claim_id;

    exception
        when others then
            pc_log.log_error('In Update Reason', sqlerrm);
    end update_reason;

    function get_hra_profile (
        p_acc_num in varchar2
    ) return acc_details_t
        pipelined
        deterministic
    is
        l_record acc_details_row_t;
    begin
        for x in (
            select distinct
                pc_person.get_person_name(pers_id) name,
                acc_num,
                account_type,
                start_date,
                pers_id,
                acc_id
            from
                account
            where
                acc_num = p_acc_num
        ) loop
            l_record.acc_id := x.acc_id;
            l_record.name := x.name;
            l_record.acc_num := x.acc_num;
            l_record.acct_type := x.account_type;
            l_record.effective_date := to_char(x.start_date, 'MM/DD/YYYY');
            l_record.acct_balance := 0;
            l_record.annual_election := 0;
            if x.account_type in ( 'HRA', 'FSA' ) then
                for xx in (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                        acc_id = x.acc_id
                    order by
                        plan_end_date asc
                ) loop
                    if
                            xx.plan_end_date + nvl(xx.runout_period_days, 0) + nvl(xx.grace_period, 0) >= trunc(sysdate)
                        and xx.plan_start_date <= trunc(sysdate)
                    then
                        l_record.acct_balance := l_record.acct_balance + round(
                            pc_account.acc_balance(x.acc_id, xx.plan_start_date, xx.plan_end_date, x.account_type, xx.plan_type),
                            2
                        );

                        l_record.effective_date := to_char(xx.effective_date, 'MM/DD/YYYY');
                        l_record.annual_election := l_record.annual_election + xx.annual_election;
                    else
                        l_record.acct_balance := 0;
                        l_record.effective_date := to_char(xx.effective_date, 'MM/DD/YYYY');
                    end if;

                    l_record.plan_type := xx.plan_type;
                    l_record.plan_desc := pc_lookups.get_fsa_plan_type(xx.plan_type);
                    l_record.annual_election := xx.annual_election;
                end loop;
            end if;

            pipe row ( l_record );
        end loop;
    end get_hra_profile;

    function get_plan_yr (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return ret_get_plan_yr
        pipelined
        deterministic
    is
        l_record get_plan_yr_t;
    begin
        for x in (
            select
                to_char(a.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(a.plan_end_date, 'MM/DD/YYYY')  d,
                to_char(a.plan_start_date, 'DD-MON-RRRR')
                || ':'
                || to_char(a.plan_end_date, 'DD-MON-RRRR') ret_format,
                a.plan_type
            from
                ben_plan_enrollment_setup a
            where
                    acc_id = p_acc_id
                and status = 'A'
                and a.plan_type = nvl(p_plan_type, a.plan_type)
        ) loop
            l_record.plan_yr := x.d;
            l_record.plan_yr_format := x.ret_format;
            l_record.plan_type := x.plan_type;
            pipe row ( l_record );
        end loop;
    end get_plan_yr;

    function get_sterling_address1 return varchar2 is
    begin
        for x in (
            select
                constant_value
            from
                web_constants
            where
                constant_name = 'STERLING_ADDRESS1'
        ) loop
            return x.constant_value;
        end loop;
    end get_sterling_address1;

    function get_sterling_city return varchar2 is
    begin
        for x in (
            select
                constant_value
            from
                web_constants
            where
                constant_name = 'STERLING_CITY'
        ) loop
            return x.constant_value;
        end loop;
    end get_sterling_city;

    function get_sterling_state return varchar2 is
    begin
        for x in (
            select
                constant_value
            from
                web_constants
            where
                constant_name = 'STERLING_STATE'
        ) loop
            return x.constant_value;
        end loop;
    end get_sterling_state;

    function get_sterling_zip return varchar2 is
    begin
        for x in (
            select
                constant_value
            from
                web_constants
            where
                constant_name = 'STERLING_ZIP'
        ) loop
            return x.constant_value;
        end loop;
    end get_sterling_zip;

    function get_sterling_address return varchar2 is
    begin
        for x in (
            select
                constant_value
            from
                web_constants
            where
                constant_name = 'STERLING_ADDRESS'
        ) loop
            return x.constant_value;
        end loop;
    end get_sterling_address;

    function get_sterling_cs_info return varchar2 is
    begin
        for x in (
            select
                constant_value
            from
                web_constants
            where
                constant_name = 'CUSTOMER_SERVICE_INFO'
        ) loop
            return x.constant_value;
        end loop;
    end get_sterling_cs_info;

    function get_contrib_type (
        p_acc_id in varchar2
    ) return ret_contrib_type_t
        pipelined
        deterministic
    is

        l_record    get_contrib_type_t;
        l_acc_count pls_integer;
        l_age       number;
        cursor cur_prior_contrib (
            p_age number
        ) is
        select
            fee_code,
            fee_name
        from
            fee_names
        where
            fee_code in ( 4, 5, 7 )
            and ( fee_code in ( 4, 5 )
                  or ( fee_code = 7
                       and trunc(sysdate) between trunc(sysdate, 'YYYY') and get_tax_day ) )
        union
        select
            fee_code,
            fee_name
        from
            fee_names
        where
            ( fee_code = 6
              and p_age >= 55 );

        cursor cur_init_contrib (
            p_age number
        ) is
        select
            fee_code,
            fee_name
        from
            fee_names
        where
            fee_code in ( 3, 4, 5, 7 )
            and ( fee_code in ( 3, 4, 5 )
                  or ( fee_code = 7
                       and trunc(sysdate) between trunc(sysdate, 'YYYY') and get_tax_day ) )
        union
        select
            fee_code,
            fee_name
        from
            fee_names
        where
            ( fee_code = 6
              and p_age >= 55 );

        cursor cur_catchup is
        select
            months_between(sysdate, birth_date) / 12 age
        from
            person
        where
            pers_id = (
                select
                    pers_id
                from
                    account
                where
                    acc_id = p_acc_id
            )
        order by
            birth_date;

    begin
        select
            count(*)
        into l_acc_count
        from
            income  a,
            account b
        where
                b.acc_id = p_acc_id
            and a.acc_id = b.acc_id;

        open cur_catchup;
        fetch cur_catchup into l_age;
        close cur_catchup;
        if l_acc_count >= 1 then
            for c1 in cur_prior_contrib(l_age) loop
                l_record.fee_code := c1.fee_code;
                l_record.fee_name := c1.fee_name;
                pipe row ( l_record );
            end loop;
        else
            for c2 in cur_init_contrib(l_age) loop
                l_record.fee_code := c2.fee_code;
                l_record.fee_name := c2.fee_name;
                pipe row ( l_record );
            end loop;
        end if;

    end get_contrib_type;
/** Added this for Mobile APP relese : Vanitha: 03/22/2016*/
    function get_acc_info_by_tax_id (
        p_ssn in varchar2
    ) return acc_info_record
        pipelined
        deterministic
    is

        l_record            acc_info_row_t;
        l_name              varchar2(100);
        l_address           varchar2(1000);
        l_city              varchar2(100);
        l_state             varchar2(100);
        l_zip               number;
        l_plan_name         varchar2(100);
        l_start_date        date;
        l_acc_balance       number(10);
        l_available_balance number(10);
        l_bal_with_fee      number(10);
        l_bill_pay_fee      number(10);
        l_acc_id            number(10);
        l_ssn               varchar2(20);
        l_pers_id           number(10);
        l_card_count        number(10);
        l_entrp_id          number(10);
        x_error_status      varchar2(10);
    begin
        x_error_status := 'E';
        for x in (
            select
                name,
                address,
                city,
                state,
                zip,
                acc_num,
                plan_name,
                start_date,
                decode(
                    sign(acc_balance),
                    -1,
                    0,
                    acc_balance
                ) acc_balance,
                acc_id,
                ssn,
                pers_id,
                card_count,
                entrp_id
            from
                acc_overview_v
            where
                ssn = format_ssn(p_ssn)
        ) loop
  /*  L_NAME                  := x.name;
    L_ADDRESS               := x.address;
    L_CITY                  := x.city;
    L_STATE                 := x.state;
    L_ZIP                   := x.zip;*/
            l_record.acc_id := x.acc_id;
            l_record.pers_id := x.pers_id;
            l_record.acc_num := x.acc_num;
            l_record.plan_name := x.plan_name;
            l_record.effective_date := x.start_date;
            l_record.acct_balance := x.acc_balance;
            x_error_status := 'S';
            l_record.error_message := 'Successful';
            pipe row ( l_record );
        end loop;

        if x_error_status = 'E' then
            l_record.acc_num := null;
            l_record.error_message := 'Error while retrieving Acct information' || sqlerrm;
            l_record.acct_balance := 0;
            l_record.acc_num := null;
            pipe row ( l_record );
        end if;

    end get_acc_info_by_tax_id;

    function get_payroll_schedule (
        p_acc_id            in number,
        p_plan_type         in varchar2,
        p_scheduler_id      in number,
        p_freq_code         in varchar2,
        p_start_dt          date,
        p_end_dt            date,
        p_no_of_pay_periods number
    ) -- Added by Jaggi #11365
     return date_table is

        l_date_tbl         date_table := date_table();
        l_schedule         pc_schedule.schedule_date_table;
        l_plan_end_date    date;
        l_recurr_frequency varchar2(100);
        l_account_type     varchar2(20);
    begin
        pc_log.log_error('PC_WEB_UTILITY_PKG : p_plan_type', p_plan_type);
        pc_log.log_error('PC_WEB_UTILITY_PKG : p_start_dt', p_start_dt);
        pc_log.log_error('PC_WEB_UTILITY_PKG : p_end_dt', p_end_dt);
        pc_log.log_error('PC_WEB_UTILITY_PKG : p_scheduler_id', p_scheduler_id);
        pc_log.log_error('PC_WEB_UTILITY_PKG : p_no_of_pay_periods', p_no_of_pay_periods);
        l_account_type := pc_account.get_account_type(p_acc_id);
   -- get the existing frequency for scheduler .
   -- Added by Joshi for PPP.
   -- 6031: modified by Joshi. if scheduler exist and frequency is same. get from schedule otherwise generate
   -- calender as per new frequency.

        if p_scheduler_id is not null then
            select
                recurring_frequency
            into l_recurr_frequency
            from
                scheduler_master
            where
                scheduler_id = p_scheduler_id;

            if l_recurr_frequency = p_freq_code then
                select
                    period_date
                bulk collect
                into l_date_tbl
                from
                    scheduler_calendar
                where
                    schedule_id = p_scheduler_id;

            end if;

        end if;

     -- ELSE commented for 6031

	-- get the plan end date for Transit and parking plans.
    -- added p_scheduler_id for prod bug 09/12/2019.
/* commmented by Jaggi #11365
	IF P_PLAN_TYPE in ('TRN','PKG') AND p_scheduler_id IS NULL THEN
		  pc_log.log_error('PC_WEB_UTILITY_PKG : p_plan_type', 'inside IF clause');
		  FOR X IN ( SELECT MAX(plan_end_date)  plan_end_date
                       FROM ben_plan_enrollment_setup plans
                      WHERE acc_id = p_acc_id
                        AND plan_type NOT IN ('TRN','PKG')
		   -- ticket 7420.Joshi commented below. payment start date should be between plan start and plan end date.
		  --and TRUNC(plans.plan_start_date) <= TRUNC(SYSDATE) AND TRUNC(plans.plan_end_date) >  TRUNC(SYSDATE))
		  and trunc(start_dt) between TRUNC(plans.plan_start_date) and TRUNC(plans.plan_end_date) )
		  LOOP
			l_plan_end_date := x.plan_end_date ;
		  END LOOP;

		 IF l_plan_end_date is NULL THEN
			-- ticket 7420.Joshi commented below  need to take year of payment start date.
			-- l_plan_end_date := '12/31/' || TO_CHAR(SYSDATE,'YYYY');  should take year of paument start date.
			l_plan_end_date := TO_DATE ('31-DEC-' || TO_CHAR(start_dt,'YYYY'));
		 END IF;
		 pc_log.log_error('PC_WEB_UTILITY_PKG : l_plan_end_date',l_plan_end_date);
	ELSE
    */
        l_plan_end_date := p_end_dt;
--	END IF ;

  /* commented by by Joshi for #9968.(monthly frequency date change issue for HSA)
	IF l_date_tbl.Count = 0  THEN
		l_schedule := pc_schedule.get_schedule(p_acc_id,freq_code,start_dt,l_plan_end_date);
		SELECT * BULK COLLECT INTO l_date_tbl  FROM TABLE(L_SCHEDULE) ;
	END IF;
  */
    -- END IF;  commented for 6031
  -- Added by Joshi for #9968.(monthly frequency date change issue for HSA)
        if l_date_tbl.count = 0 then
            if l_account_type in ( 'HSA', 'LSA' ) then
                l_schedule := pc_schedule.get_schedule_hsa(p_acc_id, p_freq_code, p_start_dt, l_plan_end_date);
                select
                    *
                bulk collect
                into l_date_tbl
                from
                    table ( l_schedule );

            else
        -- Added code by Joshi for 12559. Date to begin Processing is the first pay date of the calendar with all following pay dates populating every two weeks except
        -- in the two months where there is a third pay date.)
                if p_freq_code = 'BIWEEKLY' then
                    l_schedule := pc_schedule.get_schedule(p_acc_id, p_freq_code, p_start_dt, l_plan_end_date);
                    if nvl(p_no_of_pay_periods, 26) = 26 then
                        select
                            *
                        bulk collect
                        into l_date_tbl
                        from
                            table ( l_schedule ); 
               -- SELECT * BULK COLLECT INTO l_date_tbl  FROM TABLE(L_SCHEDULE)  WHERE ROWNUM <= NVL(p_no_of_pay_periods,'24');

                    else
                        select
                            column_value
                        bulk collect
                        into l_date_tbl
                        from
                            (
                                select
                                    column_value,
                                    row_number()
                                    over(partition by to_char(column_value, 'YYYY-MM')
                                         order by
                                             column_value
                                    ) as rn
                                from
                                    table ( l_schedule )
                            )
                        where
                            rn <= 2;

                        pc_log.log_error('Get_Payroll_Schedule',
                                         'l_date_tbl ' || l_date_tbl.count());
                        if l_date_tbl.count() >= 24 then
                            for j in l_date_tbl.first..l_date_tbl.last loop
                                pc_log.log_error('Get_Payroll_Schedule',
                                                 'l_date_tbl(j) ' || l_date_tbl(j));
                                if j > 24 then
                                    l_date_tbl.delete(j);
                                end if;
                            end loop;
                        end if;

                    end if;

                else
                    l_schedule := pc_schedule.get_schedule(p_acc_id, p_freq_code, p_start_dt, l_plan_end_date);
                    select
                        *
                    bulk collect
                    into l_date_tbl
                    from
                        table ( l_schedule );

                end if;
            end if;
        end if;

        return l_date_tbl;
    end get_payroll_schedule;

--- Joshi for PPP
    function get_payroll_frequency return ret_payroll_freq
        pipelined
        deterministic
    is
        l_record get_payroll_freq_t;
    begin
        for x in (
            select
                lookup_code,
                meaning
            from
                lookups
            where
                    lookup_name = 'PAYROLL_FREQUENCY'
                and lookup_code not in ( 'ONCE', 'DAILY', 'SEMIMONTHLY', 'TWICE_A_WEEK', 'THRICE_A_WEEK',
                                         'BIANNUALLY' )
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.meaning := x.meaning;
            pipe row ( l_record );
        end loop;
    end get_payroll_frequency;

-- Added by Jaggi
    function get_mob_pending_disbursments (
        p_acc_id in number
    ) return mob_pending_disburs_record
        pipelined
        deterministic
    is

        l_record       mob_pending_disburs_record_t;
        l_entrp_id     number;
        l_acct_type    varchar2(10);
        l_pers_id      number;
        l_patient_name varchar2(250);
        l_service_name varchar2(4000);
    begin
        for j in (
            select
                *
            from
                (
                    select distinct
                        c.claim_id,
                        c.claim_amount,
                        c.service_type,
                        c.service_start_date,
                        c.service_end_date,
                        c.bank_acct_id,
                        c.vendor_id,
                        case
                            when c.bank_acct_id is not null then
                                'PayMe'
                            else
                                'PayProvider'
                        end                                                                                                edit_type,
                        decode(c.claim_status, 'PENDING_DOC', 'Pending Documentation', 'PENDING_REVIEW', 'Pending Review') claim_status
                        ,
                        c.creation_date,
                        acc.acc_num,
                        acc.pers_id,
                        acc.account_type,
                        c.pers_patient
                    from
                        pay_reason b,
                        claimn     c,
                        account    acc
                    where
                            c.pers_id = acc.pers_id
                        and acc.acc_id = p_acc_id
                        and c.pay_reason = b.reason_code
                        and ( ( acc.account_type = 'HSA'
                                and c.claim_status = 'PENDING_APPROVAL' )
                              or ( acc.account_type <> 'HSA'
                                   and c.claim_status in ( 'PENDING_DOC', 'PENDING_REVIEW' ) ) )
                    order by
                        c.claim_id desc
                )
            where
                rownum < 11
            order by
                claim_id desc
        ) loop
            l_record.claim_id := j.claim_id;
            l_record.claim_amount := j.claim_amount;
            l_record.service_type := j.service_type;
            if j.account_type = 'HSA' then
                for x in (
                    select
                        claim_status status,
                        claim_date   transaction_date
                    from
                        hsa_claim_report_online_v
                    where
                        transaction_number = j.claim_id
                ) loop
                    l_record.service_start_date := x.transaction_date;
                    l_record.claim_status := x.status;
                end loop;
            else
                l_record.service_start_date := j.service_start_date;
                l_record.claim_status := j.claim_status;
            end if;

            for x in (
                select
                    patient_dep_name,
                    service_name
                from
                    claim_detail
                where
                    claim_id = j.claim_id
            ) loop
                l_patient_name := x.patient_dep_name;
                l_service_name := x.service_name;
            end loop;

            l_patient_name := nvl(l_patient_name,
                                  pc_person.get_person_name(j.pers_patient));
            l_record.service_end_date := j.service_end_date;
            l_record.bank_acct_id := j.bank_acct_id;
            l_record.vendor_id := j.vendor_id;
            l_record.patient_name := l_patient_name;
            l_record.edit_type := j.edit_type;
            l_record.service_name := l_service_name;
            l_record.creation_date := j.creation_date;
            if j.vendor_id is not null then
                for x in (
                    select
                        vendor_id,
                        vendor_name
                        || ','
                        || address1
                        || ' '
                        || city
                        || ','
                        || state
                        || ' '
                        || zip pay_info
                    from
                        vendors
                    where
                            vendor_id = j.vendor_id
                        and nvl(vendor_status, 'A') = 'A'
                ) loop
                    l_record.pay_info := x.pay_info;
                end loop;
            else
                l_record.pay_info := pc_person.get_person_name(j.pers_id);
            end if;

            pipe row ( l_record );
        end loop;
    end get_mob_pending_disbursments;
-- added by Jaggi #11365
    function get_payroll_frequency_fsa_hra return ret_payroll_freq
        pipelined
        deterministic
    is
        l_record get_payroll_freq_t;
    begin
        for x in (
            select
                lookup_code,
                meaning
            from
                lookups
            where
                    lookup_name = 'PAYROLL_FREQUENCY'
                and lookup_code not in ( 'ONCE', 'DAILY', 'SEMIMONTHLY1', 'SEMIMONTHLY2', 'TWICE_A_WEEK',
                                         'THRICE_A_WEEK', 'BIANNUALLY' )
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.meaning := x.meaning;
            pipe row ( l_record );
        end loop;
    end get_payroll_frequency_fsa_hra;

-- Added by Swamy for Ticket#12013 12022024
    function get_bulk_enroll_renewal (
        p_entrp_id     in number,
        p_process_type in varchar2,
        p_start_row    in varchar2,
        p_end_row      in varchar2
    ) return fsahrahsa_employee_t
        pipelined
        deterministic
    is

        l_acc_id       number;
        type r_cursor is ref cursor;
        c_cur          r_cursor;
        l_hra_record_t fsahrahsa_employee_record_t;
        l_sql          varchar2(3200);
        l_cond         varchar2(500);
        l_sort         varchar2(500);
        l_end_row      varchar2(500);
    begin
        pc_log.log_error('get_bulk_enroll_renewal', 'p_entrp_id '
                                                    || p_entrp_id
                                                    || ' p_process_type '
                                                    || p_process_type
                                                    || ' p_start_row :='
                                                    || p_start_row
                                                    || ' p_end_row :='
                                                    || p_end_row);

        if p_entrp_id is not null then
            if p_process_type is not null then
                l_cond := ' AND  UPPER(process_type) LIKE ''%''  ||UPPER(p_process_type)||''%''';
            else
                l_cond := ' AND 1  = 1 ';
            end if;

            l_end_row := 'outer.rn';
            l_sql := 'SELECT outer.*
     FROM (SELECT ROWNUM RN, inner.UPLOAD_DATE, inner.FILE_NAME, inner.FILE_UPLOAD_RESULT , inner.NO_OF_EMPLOYEES, inner.FILE_UPLOAD_ID,MOD(ROWNUM,2) M_RN
     FROM (SELECT UPLOAD_DATE , FILE_NAME , FILE_UPLOAD_RESULT , NO_OF_EMPLOYEES ,FILE_UPLOAD_ID from FILE_UPLOAD_HISTORY_V  where ENTRP_ID = '
                     || p_entrp_id
                     || '
      			AND PROCESS_TYPE = '''
                     || p_process_type
                     || '''
               ) inner) outer
               WHERE outer.rn >= '
                     || nvl(p_start_row, 0)
                     || ' AND outer.rn <= '
                     || nvl(p_end_row, l_end_row)
                     || '';

     --pc_log.log_error('get_bulk_enroll_renewal','sql '||l_sql);

            open c_cur for l_sql;

            loop
                fetch c_cur into l_hra_record_t;
                exit when c_cur%notfound;
                pipe row ( l_hra_record_t );
            end loop;

        else
            pipe row ( l_hra_record_t );
        end if;

    exception
        when others then
            pc_log.log_app_error('PC_WEB_UTILITY_PKG', 'get_bulk_enroll_renewal', dbms_utility.format_call_stack, dbms_utility.format_error_stack
            , dbms_utility.format_error_backtrace,
                                 p_entrp_id
                                 || ':'
                                 || p_process_type
                                 || ':'
                                 || ':'
                                 || ':');
    end get_bulk_enroll_renewal;

end pc_web_utility_pkg;
/

