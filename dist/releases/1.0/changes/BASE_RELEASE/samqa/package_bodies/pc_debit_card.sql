-- liquibase formatted sql
-- changeset SAMQA:1754374001595 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_debit_card.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_debit_card.sql:null:c42f9606e339e65000ce45a608825fa914ea4dc0:create

create or replace package body samqa.pc_debit_card is

    procedure insert_alert (
        p_subject in varchar2,
        p_message in varchar2
    ) is
        l_notification_id number;
    begin
        pc_notifications.insert_notifications(
            p_from_address    => 'oracle@sterlingadministration.com',
            p_to_address      => 'IT-Team@sterlingadministration.com',
            p_cc_address      => null,
            p_subject         => p_subject,
            p_message_body    => p_message,
            p_user_id         => 0,
            p_acc_id          => null,
            x_notification_id => l_notification_id
        );

        update email_notifications
        set
            mail_status = 'READY'
        where
            notification_id = l_notification_id;

    end;

    function insert_file_seq (
        p_action in varchar2
    ) return number is
        l_file_id number;
    begin
        insert into metavante_files (
            file_id,
            file_action,
            creation_date,
            last_update_date
        ) values ( file_seq.nextval,
                   p_action,
                   sysdate,
                   sysdate ) returning file_id into l_file_id;

        return l_file_id;
    end;

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2 is
        x_file_name varchar2(320);
    begin
      --     pc_log.log_error('get_file_name',p_action);

        select
            decode(p_result,
                   'RESULT',
                   replace(file_name, '.mbi', '.res'),
                   'EXPORT',
                   replace(file_name, '.mbi', '.exp'))
        into x_file_name
        from
            metavante_files
        where
                file_id = (
                    select
                        max(file_id)
                    from
                        metavante_files
                    where
                            file_action = p_action
                        and nvl(result_flag, 'N') = 'N'
                )
    --  AND   trunc(creation_date) >=  trunc(sysdate)-1
            and nvl(result_flag, 'N') = 'N';

        return x_file_name;
    exception
        when others then
            return null;
    end;

    procedure card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl card_creation_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        l_message         varchar2(32000);
        mass_card_create exception;
        no_card_create exception;
        l_term_date       varchar2(10) := null;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if p_acc_num_list is not null then
            select
                acc_num                           employee_id,
                b.title                           prefix,
                '"'
                || substr(b.last_name, 1, 26)
                || '"'                            last_name,
                '"'
                || substr(b.first_name, 1, 19)
                || '"'                            first_name,
                '"'
                || substr(b.middle_name, 1, 1)
                || '"'                            middle_name,
                '"'
                || b.address
                || '"'                            address,
                '"'
                || b.city
                || '"'                            city,
                '"'
                || b.state
                || '"'                            state,
                '"'
                || b.zip
                || '"'                            zip,
                decode(b.gender, 'M', 1, 'F', 2,
                       0)                         gender,
                to_char(b.birth_date, 'YYYYMMDD') birth_date,
                substr(b.drivlic, 1, 20)          drivlic,
                to_char(a.start_date, 'YYYYMMDD') start_date,
                to_char(a.start_date, 'HHMISS')   start_time,
                null                              email,
                a.pers_id,
                a.acc_id,
                b.entrp_id,
                decode(a.account_type,
                       'HSA',
                       g_employer_id,
                       pc_entrp.get_bps_acc_num(b.entrp_id)),
                nvl(c.pin_mailer, '0')            pin_mailer,
                nvl(c.shipping_method, '1')       shipping_emthod
            bulk collect
            into l_card_create_tbl
            from
                account    a,
                person     b,
                card_debit c
            where
                    a.pers_id = b.pers_id
                and a.pers_id = c.card_id
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(str2tbl(p_acc_num_list) as varchar2_4000_tbl) )
                )
       -- AND  TRUNC(A.start_date) <= TRUNC(SYSDATE+10)         -- Ticket# 6588
                and a.complete_flag = 1
                and a.id_verified = 'Y'
                and ( a.blocked_flag = 'N'
                      or a.blocked_flag is null )
                and a.account_type = 'HSA'
                and a.plan_code = 8 -- Sk added to only send accounts with plan code=8
        -- Ticket #6588 change
                and b.first_name is not null
                and b.last_name is not null
                and b.address is not null
                and b.city is not null
                and b.state is not null
        -- 6588
                and not exists (
                    select
                        *
                    from
                        card_debit
                    where
                            card_debit.card_id = b.pers_id
                        and card_debit.card_number is not null
                        and card_debit.status_code <> 4
                );

        else
            select
                employee_id,
                prefix,
                last_name,
                first_name,
                middle_name,
                address,
                city,
                state,
                zip,
                gender,
                birth_date,
                drivlic,
                start_date,
                start_time,
                null,
                pers_id,
                acc_id,
                entrp_id,
                er_acc_num,
                pin_mailer,
                shipping_emthod
            bulk collect
            into l_card_create_tbl
            from
                (
                    select
                        acc_num                                      employee_id,
                        b.title                                      prefix,
                        '"'
                        || substr(b.last_name, 1, 26)
                        || '"'                                       last_name,
                        '"'
                        || substr(b.first_name, 1, 19)
                        || '"'                                       first_name,
                        '"'
                        || substr(b.middle_name, 1, 1)
                        || '"'                                       middle_name,
                        '"'
                        || b.address
                        || '"'                                       address,
                        '"'
                        || b.city
                        || '"'                                       city,
                        '"'
                        || b.state
                        || '"'                                       state,
                        '"'
                        || b.zip
                        || '"'                                       zip,
                        decode(b.gender, 'M', 1, 'F', 2,
                               0)                                    gender,
                        to_char(b.birth_date, 'YYYYMMDD')            birth_date,
                        substr(b.drivlic, 1, 20)                     drivlic,
                        to_char(a.start_date, 'YYYYMMDD')            start_date,
                        to_char(a.start_date, 'HHMISS')              start_time,
                        null                                         email,
                        a.pers_id,
                        a.acc_id,
                        b.entrp_id,
                        decode(a.account_type,
                               'HSA',
                               g_employer_id,
                               pc_entrp.get_bps_acc_num(b.entrp_id)) er_acc_num,
                        nvl(c.pin_mailer, '0')                       pin_mailer,
                        nvl(c.shipping_method, '1')                  shipping_emthod
                    from
                        account    a,
                        person     b,
                        card_debit c
                    where
                            c.status = 1 -- Ready to Activate
                        and trunc(a.start_date) <= trunc(sysdate)
                        and a.pers_id = b.pers_id
                        and a.pers_id = c.card_id
                        and b.first_name is not null
                        and b.last_name is not null
                        and b.address is not null
                        and b.city is not null
                        and b.state is not null
		/* commented by Joshi for 6588.
        AND a.complete_flag = 1
        AND a.account_status =1
		AND pc_account.acc_balance(a.acc_id) > 0 */
		/* added below condition by Joshi for 6588 on 07-OCT-2020*/
                        and ( ( a.plan_code <> 8
                                and a.complete_flag = 1
                                and a.account_status = 1
                                and pc_account.acc_balance(a.acc_id) > 0 )
                              or ( a.plan_code = 8
                                   and a.complete_flag = 1
                                   and a.id_verified = 'Y'
                                   and ( a.blocked_flag = 'N'
                                         or a.blocked_flag is null )
                                   and ( a.account_status = 3
                                         or a.account_status = 1 ) ) )
                        and a.account_type = 'HSA'
                        and not exists (
                            select
                                *
                            from
                                card_debit
                            where
                                    card_debit.card_id = b.pers_id
                                and card_debit.card_number is not null
                                and card_debit.status_code <> 4
                        )
                    union  -- ADDED ON 11/4/2015: Added condition to have the ability to order the card when they are expired VS
                    select
                        acc_num                           employee_id,
                        b.title                           prefix,
                        '"'
                        || substr(b.last_name, 1, 26)
                        || '"'                            last_name,
                        '"'
                        || substr(b.first_name, 1, 19)
                        || '"'                            first_name,
                        '"'
                        || substr(b.middle_name, 1, 1)
                        || '"'                            middle_name,
                        '"'
                        || b.address
                        || '"'                            address,
                        '"'
                        || b.city
                        || '"'                            city,
                        '"'
                        || b.state
                        || '"'                            state,
                        '"'
                        || b.zip
                        || '"'                            zip,
                        decode(b.gender, 'M', 1, 'F', 2,
                               0)                         gender,
                        to_char(b.birth_date, 'YYYYMMDD') birth_date,
                        substr(b.drivlic, 1, 20)          drivlic,
                        to_char(a.start_date, 'YYYYMMDD') start_date,
                        to_char(a.start_date, 'HHMISS')   start_time,
                        null                              email,
                        a.pers_id,
                        a.acc_id,
                        b.entrp_id,
                        decode(a.account_type,
                               'HSA',
                               g_employer_id,
                               pc_entrp.get_bps_acc_num(b.entrp_id)),
                        nvl(c.pin_mailer, '0')            pin_mailer,
                        nvl(c.shipping_method, '1')       shipping_emthod
                    from
                        account    a,
                        person     b,
                        card_debit c
                    where
                            a.pers_id = b.pers_id
                        and a.pers_id = c.card_id
                        and c.status = 1 -- Ready to Activate
                        and trunc(a.start_date) <= trunc(sysdate)
                        and b.first_name is not null
                        and b.last_name is not null
                        and b.address is not null
                        and b.city is not null
                        and b.state is not null
                        and a.complete_flag = 1
                        and a.account_status = 1
                        and a.account_type = 'HSA'
                        and pc_account.acc_balance(a.acc_id) > 0
                        and exists (
                            select
                                *
                            from
                                card_debit
                            where
                                    card_debit.card_id = b.pers_id
                                and card_debit.card_number is not null
                                and to_date(card_debit.expire_date, 'YYYYMMDD') < sysdate
                        )
                );

        end if;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 1000 then
                l_message := 'ALERT!!!! More than 1000 debit card creations are requested, verify before sending the request';
                raise mass_card_create;
            else
                if get_file_name('CARD_CREATION', 'RESULT') is not null then
                    l_message := 'ALERT!!!! Card creation file from previous day has not been processed yet ';
                    raise mass_card_create;
                end if;

                if p_file_name is null then
                    l_file_id := insert_file_seq('CARD_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_create.mbi';
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char((l_card_create_tbl.count * 3) + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Card_Creation'
                          || ','
                          || 'STL_Result_Card_Creation'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IB'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || g_employer_id                        -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                      || ','
                      || l_card_create_tbl(i).last_name       -- Last Name
                      || ','
                      || l_card_create_tbl(i).first_name      -- First Name
                      || ','
                      || l_card_create_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_card_create_tbl(i).address         -- Address
                      || ','
                      || l_card_create_tbl(i).city            -- City
                      || ','
                      || l_card_create_tbl(i).state           -- State
                      || ','
                      || l_card_create_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ','
                      || '2'                                  -- Employee Status, 2 - Active
                      || ','
                      || l_card_create_tbl(i).gender          -- Gender
                      || ','
                      || l_card_create_tbl(i).birth_date      -- Birth Date
                      || ','
                      || '1'                                  -- HDHP eligible , 1 - Yes
                      || ','
                      || l_card_create_tbl(i).drivlic         -- Employee Driver License
                      || ',CNEW_'
                      || l_card_create_tbl(i).employee_id    -- Record Tracking Number
                      || ','
                      || l_card_create_tbl(i).email;            -- Email Address

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IC'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || g_plan_id                        -- Plan ID
                      || ','
                      || l_card_create_tbl(i).employee_id        -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || g_plan_start_date                -- Plan Start Date
                      || ','
                      || g_plan_end_date                -- Plan End Date
                      || ','
                      || '2'                        -- Account Status , 2 - Active
                      || ','
                      || '0'                        -- Employee Pay Period Election
                      || ','
                      || '0'                        -- Employer Pay Period Election
                      || ','
                      || to_char(sysdate + 1, 'YYYYMMDD')            -- Effective Date
                      || ','
                      || '1'                        -- E-Signature Flag , 1 - Yes
                      || ','
                      || l_card_create_tbl(i).start_date        -- E-Signature Date
                      || ','
                      || l_card_create_tbl(i).start_time              -- E-Signature Time
                      || ',CNEW_'
                      || l_card_create_tbl(i).employee_id            -- Record Tracking Number
                      || ','
                      || l_term_date;                               -- termination date

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IF'                                           -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id        -- Employee ID
                      || ','
                      || to_char(sysdate + 1, 'YYYYMMDD')              -- Issue Date
                      || ','
                      || to_char(sysdate + 1, 'YYYYMMDD')              -- Card Effective Date
                      || ','
                      || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                      || ','
                      || '2'                        -- Issue Card
                      || ','
                      || l_card_create_tbl(i).shipping_method        -- Shipping Method Code, 1 - US Mail, 1- Overnight
                      || ',CNEW_'
                      || l_card_create_tbl(i).employee_id        -- Record Tracking Number
                      || ','
                      || l_card_create_tbl(i).pin_mailer;               -- PIN mailer

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_card_create then
            insert_alert('Error in Creating Card Creation File', l_message);
    /*    mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
               ,'Error in Creating Card Creation File'
               ,l_message);*/

        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Card Creation File', l_sqlerrm);
    end card_creation;

  /*** Load Deposits and Disbursements ***/
  /*** IH is for deposits
       II is for disbursements ****/
    procedure card_adjustments (
        p_acc_num_list      in varchar2 default null,
        p_deposit_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_deposit_file_name varchar2(3200);
        l_payment_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_deposit_tbl  amount_tab;
        l_card_payment_tbl  amount_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
        mass_card_create exception;
        l_message           varchar2(3200);
    begin


      /** Posting the deposits ***/
      /** IH record is for all deposits **/
        select
            acc_num,
            amount,
            merchant_name,
            fee_date,
            change_num
        bulk collect
        into l_card_deposit_tbl
        from
            (
                select
                    b.acc_num,
                    nvl(a.amount, 0) + nvl(a.amount_add, 0) amount,
                    (
                        select
                            fee_name
                        from
                            fee_names
                        where
                            fee_names.fee_code = a.fee_code
                    )                                       merchant_name,
                    to_char(fee_date, 'YYYYMMDD')           fee_date,
                    a.change_num
                from
                    income     a,
                    account    b,
                    card_debit c
                where
                        a.acc_id = b.acc_id
                    and nvl(a.debit_card_posted, 'N') = 'N'
                    and b.account_status = 1
                    and a.transaction_type <> 'P'
                    and c.card_id = b.pers_id
                    and nvl(a.amount, 0) + nvl(a.amount_add, 0) <> 0
                    and a.fee_code <> 8
                    and card_number is not null
               --  AND     NVL(c.status_code,-1) <> 4
                    and b.account_type = 'HSA'
                    and trunc(fee_date) <= trunc(sysdate)
               --   AND     TRUNC(fee_date) > '11-APR-2022' -- Added Temporarily to send missing deposits from 06/01
                    and exists (
                        select
                            *
                        from
                            metavante_cards
                        where
                                c.card_number = metavante_cards.card_number
                            and dependant_id is null
                            and metavante_cards.acc_num = b.acc_num
                    )
                    and not exists (
                        select
                            *
                        from
                            metavante_adjustment_outbound xx
                        where
                                xx.change_num = a.change_num
                            and xx.record_type = 'RECEIPT'
                    )
                                    -- and   NVL(xx.debit_card_posted,'N') = 'Y') -- Added Temporarily to send missing deposits from 06/01
                union
                select
                    *
                from
                    (
                        select
                            employee_id,
                            - pc_plan.get_minimum(b.plan_code) amount /*Ticket#6588 */,
                            'MIN_BALANCE'                      merchant_name,
                            to_char(sysdate, 'YYYYMMDD')       fee_date,
                            to_number(null)
                        from
                            card_balance_external c,
                            account               b
                        where
                            c.account_status in ( 1, 2 )
                            and available_balance = 0
                            and disbursable_balance = 0
                            and c.employee_id = b.acc_num
                            and b.account_type = 'HSA'
                            and employee_contribution_ytd = 0
                            and card_number is not null
                    )
                where
                    amount <> 0
                union  -- We process refunds through IH record as BPS rejects II record saying there is no enough disbursable amount
                select
                    b.acc_num -- Refund amount exceeds total amount disbursed from this plan
                    ,
                    abs(a.amount),
                    'REFUND',
                    to_char(pay_date, 'YYYYMMDD'),
                    a.change_num
                from
                    payment    a,
                    account    b,
                    card_debit c
                where
                        a.acc_id = b.acc_id
                    and nvl(a.debit_card_posted, 'N') = 'N'
                    and b.account_status in ( 1, 2, 4 )
                    and b.pers_id = c.card_id
                    and c.card_number is not null
                    and nvl(a.pay_source, 'EB') = 'EB'
                    and nvl(c.status_code, -1) <> 4
                    and a.reason_mode = 'P'
                    and b.account_type = 'HSA'
                    and a.amount < 0
                    and exists (
                        select
                            *
                        from
                            card_debit
                        where
                                card_id = b.pers_id
                            and card_number is not null
                    )
                    and not exists (
                        select
                            *
                        from
                            metavante_adjustment_outbound xx
                        where
                                xx.change_num = a.change_num
                            and xx.record_type = 'PAYMENT'
                            and nvl(xx.debit_card_posted, 'N') = 'Y'
                    )
            );

        dbms_output.put_line('l_card_deposit_tbl.COUNT ' || l_card_deposit_tbl.count);
        if get_file_name('DEPOSIT', 'RESULT') is not null then
            l_message := 'ALERT!!!! Deposit file from previous day has not been processed yet ';
            raise mass_card_create;
        end if;

        if l_card_deposit_tbl.count > 0 then
            if p_deposit_file_name is null then
                l_file_id := insert_file_seq('DEPOSIT');
                l_deposit_file_name := 'MB_'
                                       || l_file_id
                                       || '_deposit.mbi';
            else
                l_deposit_file_name := p_deposit_file_name;
            end if;

            update metavante_files
            set
                file_name = l_deposit_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_deposit_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_deposit_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Deposit'
                      || ','
                      || 'STL_Result_Deposit'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_deposit_tbl.count loop
            insert into metavante_adjustment_outbound (
                acc_num,
                acc_id,
                record_type,
                change_num,
                amount,
                debit_card_posted,
                creation_date
            )
                select
                    l_card_deposit_tbl(i).employee_id,
                    acc_id,
                    decode(l_card_deposit_tbl(i).merchant_name,
                           'REFUND',
                           'PAYMENT',
                           'RECEIPT'),
                    l_card_deposit_tbl(i).change_num,
                    l_card_deposit_tbl(i).amount,
                    'N',
                    sysdate
                from
                    account
                where
                        acc_num = l_card_deposit_tbl(i).employee_id
                    and account_type = 'HSA'
                    and not exists (
                        select
                            *
                        from
                            metavante_adjustment_outbound
                        where
                            change_num = l_card_deposit_tbl(i).change_num
                    );

            l_line := 'IH'                                       -- Record ID
                      || ','
                      || g_tpa_id                                    -- TPA ID
                      || ','
                      || g_employer_id                               -- Employer ID
                      || ','
                      || l_card_deposit_tbl(i).employee_id          -- Employee ID
                      || ','
                      || 'HSA'                                       -- Account Type Code
                      || ','
                      || g_plan_start_date                           -- Plan Start Date
                      || ','
                      || g_plan_end_date                             -- Plan End Date
                      || ','
                      || '1'                                         -- Deposit Type, 1 - Other
                      || ','
                      || l_card_deposit_tbl(i).amount               -- Employee Deposit Amount
                      || ','
                      || '0';                                         -- Employer Deposit Amount

            if l_card_deposit_tbl(i).merchant_name = 'REFUND' then
                l_line := l_line
                          || ','
                          || l_card_deposit_tbl(i).merchant_name
                          || '_'
                          || l_card_deposit_tbl(i).change_num;   -- Record Tracking Number
            else
                l_line := l_line
                          || ','
                          || l_card_deposit_tbl(i).change_num;   -- Record Tracking Number

            end if;

            l_line := l_line
                      || ','
                      || l_card_deposit_tbl(i).transaction_date      -- Display Date
                      || ','
                      || l_card_deposit_tbl(i).merchant_name;        -- Note

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_deposit_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_deposit_file_name := l_deposit_file_name;
    exception
        when mass_card_create then
            insert_alert('Error in Creating Deposit file ', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating Deposit file ', l_sqlerrm);
    end card_adjustments;
    /*** Load Deposits and Disbursements ***/
  /*** IH is for deposits
       II is for disbursements ****/
    procedure interest_rates (
        p_deposit_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_deposit_file_name varchar2(3200);
        l_payment_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_deposit_tbl  amount_tab;
        l_card_payment_tbl  amount_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
        mass_card_create exception;
        l_message           varchar2(3200);
    begin


      /** Posting the interest ***/
      /** IH record is for all interest **/
        select
            acc_num,
            amount,
            merchant_name,
            fee_date,
            change_num
        bulk collect
        into l_card_deposit_tbl
        from
            (
                select
                    b.acc_num,
                    nvl(a.amount, 0) + nvl(a.amount_add, 0) amount,
                    (
                        select
                            fee_name
                        from
                            fee_names
                        where
                            fee_names.fee_code = a.fee_code
                    )                                       merchant_name,
                    to_char(fee_date, 'YYYYMMDD')           fee_date,
                    a.change_num
                from
                    income     a,
                    account    b,
                    card_debit c
                where
                        a.acc_id = b.acc_id
                    and b.account_type = 'HSA'
                    and trunc(a.fee_date) <= trunc(sysdate)
                    and trunc(a.fee_date) > '01-MAR-2023'
                    and nvl(a.debit_card_posted, 'N') = 'N'
                    and b.account_status = 1
                    and a.transaction_type <> 'P'
                    and c.card_id = b.pers_id
               --  AND     NVL(a.amount,0)+NVL(a.amount_add,0) <> 0
                    and a.fee_code = 8
                    and card_number is not null
               --  AND     NVL(c.status_code,-1) <> 4
                    and exists (
                        select
                            *
                        from
                            metavante_cards
                        where
                                c.card_number = metavante_cards.card_number
                            and dependant_id is null
                            and metavante_cards.acc_num = b.acc_num
                    )
                    and not exists (
                        select
                            *
                        from
                            metavante_adjustment_outbound xx
                        where
                                xx.change_num = a.change_num
                            and xx.record_type = 'INTEREST'
                    )
                    and rownum < 10000
            );

        dbms_output.put_line('l_card_deposit_tbl.COUNT ' || l_card_deposit_tbl.count);
    /*   IF get_file_name('INTEREST','RESULT') IS NOT NULL THEN
          l_message := 'ALERT!!!! Deposit file from previous day has not been processed yet ';
          RAISE mass_card_create;

       END IF;*/
        if l_card_deposit_tbl.count > 0 then
            if p_deposit_file_name is null then
                l_file_id := insert_file_seq('INTEREST');
                l_deposit_file_name := 'MB_'
                                       || l_file_id
                                       || '_interest.mbi';
            else
                l_deposit_file_name := p_deposit_file_name;
            end if;

            update metavante_files
            set
                file_name = l_deposit_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_deposit_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_deposit_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Deposit'
                      || ','
                      || 'STL_Result_Deposit'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_deposit_tbl.count loop
            insert into metavante_adjustment_outbound (
                acc_num,
                acc_id,
                record_type,
                change_num,
                amount,
                debit_card_posted,
                creation_date
            )
                select
                    l_card_deposit_tbl(i).employee_id,
                    acc_id,
                    'INTEREST',
                    l_card_deposit_tbl(i).change_num,
                    l_card_deposit_tbl(i).amount,
                    'N',
                    sysdate
                from
                    account
                where
                        acc_num = l_card_deposit_tbl(i).employee_id
                    and account_type = 'HSA'
                    and not exists (
                        select
                            *
                        from
                            metavante_adjustment_outbound
                        where
                            change_num = l_card_deposit_tbl(i).change_num
                    );

            l_line := 'IH'                                       -- Record ID
                      || ','
                      || g_tpa_id                                    -- TPA ID
                      || ','
                      || g_employer_id                               -- Employer ID
                      || ','
                      || l_card_deposit_tbl(i).employee_id          -- Employee ID
                      || ','
                      || 'HSA'                                       -- Account Type Code
                      || ','
                      || g_plan_start_date                           -- Plan Start Date
                      || ','
                      || g_plan_end_date                             -- Plan End Date
                      || ','
                      || '1'                                         -- Deposit Type, 1 - Other
                      || ','
                      || l_card_deposit_tbl(i).amount               -- Employee Deposit Amount
                      || ','
                      || '0';                                         -- Employer Deposit Amount

            l_line := l_line
                      || ','
                      || l_card_deposit_tbl(i).change_num;   -- Record Tracking Number
            l_line := l_line
                      || ','
                      || l_card_deposit_tbl(i).transaction_date      -- Display Date
                      || ','
                      || l_card_deposit_tbl(i).merchant_name;        -- Note

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_deposit_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_deposit_file_name := l_deposit_file_name;
    exception
        when mass_card_create then
            insert_alert('Error in Creating interest file ', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating interest file ', l_sqlerrm);
    end interest_rates;

    procedure payment_adjustments (
        p_acc_num_list      in varchar2 default null,
        p_payment_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_deposit_file_name varchar2(3200);
        l_payment_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_payment_tbl  adjustment_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
        mass_card_create exception;
        l_message           varchar2(3200);
    begin
        l_line := null;
        l_file_id := null;

       /*** Posting disbursements ***/
       /** II is for all disbursements, pre auth and debit card purchases are excluded **/
        select
            *
        bulk collect
        into l_card_payment_tbl
        from
            (
                select
                    b.acc_num,
                    case
                        when b.account_status in ( 2, 4 ) then
                            least(current_card_value,
                                  nvl(a.amount, 0))
                        when b.account_status = 1
                             and a.amount - current_card_value between 0 and 1 then
                            current_card_value
                        else
                            nvl(a.amount, 0)
                    end          amount,
                    '"'
                    || substr(
                        strip_special_char(nvl((
                            select
                                prov_name
                            from
                                claimn
                            where
                                claim_id = a.claimn_id
                        ),(
                            select
                                reason_name
                            from
                                pay_reason
                            where
                                reason_code = a.reason_code
                        ))),
                        1,
                        48
                    )
                    || '"'       merchant_name,
                    to_char(pay_date, 'YYYYMMDD'),
                    a.change_num,
                    'HSA',
                    g_employer_id,
                    a.change_num tracking_number,
                    a.claimn_id
                from
                    payment    a,
                    account    b,
                    card_debit c
                where
                        nvl(a.debit_card_posted, 'N') = 'N'
                    and a.reason_mode = 'P'
                    and a.amount > 0
                    and b.account_type = 'HSA'
                    and b.account_status in ( 1, 4 )
                    and a.acc_id = b.acc_id
                    and b.pers_id = c.card_id
                    and c.card_number is not null
                    and nvl(a.pay_source, 'EB') = 'EB'
                    and c.current_card_value > 0
                    and a.reason_code <> 15
         --  AND     NVL(c.status_code,-1) <> 4
                    and exists (
                        select
                            *
                        from
                            metavante_cards
                        where
                                c.card_number = metavante_cards.card_number
                            and dependant_id is null
                            and metavante_cards.acc_num = b.acc_num
                    )
                    and not exists (
                        select
                            *
                        from
                            metavante_adjustment_outbound xx
                        where
                                xx.change_num = a.change_num
                            and xx.record_type = 'PAYMENT'
                            and nvl(xx.debit_card_posted, 'N') = 'Y'
                    )
            );

        if get_file_name('PAYMENT', 'RESULT') is not null then
            l_message := 'ALERT!!!! Payment file from previous day has not been processed yet ';
            raise mass_card_create;
        end if;

        if l_card_payment_tbl.count > 0 then
            if p_payment_file_name is null then
                l_file_id := insert_file_seq('PAYMENT');
                l_payment_file_name := 'MB_'
                                       || l_file_id
                                       || '_payment.mbi';
            else
                l_payment_file_name := p_payment_file_name;
            end if;

            update metavante_files
            set
                file_name = l_payment_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_payment_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_payment_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Payment'
                      || ','
                      || 'STL_Result_Payment'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_payment_tbl.count loop
            insert into metavante_adjustment_outbound (
                acc_num,
                acc_id,
                record_type,
                change_num,
                amount,
                debit_card_posted,
                creation_date
            )
                select
                    l_card_payment_tbl(i).employee_id,
                    acc_id,
                    'PAYMENT',
                    l_card_payment_tbl(i).change_num,
                    l_card_payment_tbl(i).amount,
                    'N',
                    sysdate
                from
                    account
                where
                    acc_num = l_card_payment_tbl(i).employee_id;

            l_line := 'II'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || l_card_payment_tbl(i).employer_id                -- Employer ID
                      || ','
                      || l_card_payment_tbl(i).employee_id        -- Employee ID
                      || ','
                      || l_card_payment_tbl(i).plan_type              -- Account Type Code
                      || ','
                      || l_card_payment_tbl(i).merchant_name        -- Merchant Name
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service from
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service to
                      || ','
                      || l_card_payment_tbl(i).amount                -- Approved Claim Amount
                      || ','
                      || l_card_payment_tbl(i).change_num      -- Record Tracking Number
                      || ','
                      || l_card_payment_tbl(i).claim_number;      -- External Claim Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_payment_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_payment_file_name := l_payment_file_name;
    exception
        when mass_card_create then
            insert_alert('Error in Creating Payment file ', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Payment file ', l_sqlerrm);
       /* mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
               ,'Error in Creating Deposit/Payment file'
               ,l_sqlerrm);*/
    end payment_adjustments;

    procedure demographic_update (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_demographic_tbl card_creation_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        if p_acc_num_list is not null then
            select
                d.acc_num employee_id,
                null      prefix,
                '"'
                || substr(b.last_name, 1, 26)
                || '"'    last_name,
                '"'
                || substr(b.first_name, 1, 19)
                || '"'    first_name,
                '"'
                || substr(b.middle_name, 1, 1)
                || '"'    middle_name,
                '"'
                || b.address
                || '"'    address,
                '"'
                || b.city
                || '"'    city,
                '"'
                || b.state
                || '"'    state,
                '"'
                || b.zip
                || '"'    zip,
                null      gender,
                null      hdhp_eligible,
                null      drivlic,
                null      start_date,
                null      start_time,
                null      email,
                b.pers_id,
                null,
                c.entrp_id,
                decode(d.account_type,
                       'HSA',
                       g_employer_id,
                       pc_entrp.get_bps_acc_num(c.entrp_id)),
                'N',
                '1'
            bulk collect
            into l_demographic_tbl
            from
                debit_card_updates b,
                person             c,
                account            d
            where
                    demo_changed = 'Y'
                and demo_processed = 'N'
                and d.pers_id = b.pers_id
                and b.pers_id = c.pers_id
                and d.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                );

        else
            select
                *
            bulk collect
            into l_demographic_tbl
            from
                (
                    select distinct
                        c.acc_num employee_id,
                        null      prefix,
                        '"'
                        || substr(a.last_name, 1, 26)
                        || '"'    last_name,
                        '"'
                        || substr(a.first_name, 1, 19)
                        || '"'    first_name,
                        '"'
                        || substr(a.middle_name, 1, 1)
                        || '"'    middle_name,
                        '"'
                        || a.address
                        || '"'    address,
                        '"'
                        || a.city
                        || '"'    city,
                        '"'
                        || a.state
                        || '"'    state,
                        '"'
                        || a.zip
                        || '"'    zip,
                        null      gender,
                        null      hdhp_eligible,
                        null      drivlic,
                        null      start_date,
                        null      start_time,
                        null      email,
                        b.pers_id,
                        null,
                        a.entrp_id,
                        decode(c.account_type,
                               'HSA',
                               g_employer_id,
                               pc_entrp.get_bps_acc_num(a.entrp_id)),
                        'N',
                        '1'
                    from
                        debit_card_updates b,
                        person             a,
                        account            c
                    where
                            demo_changed = 'Y'
                        and a.pers_id = b.pers_id
                        and a.pers_id = c.pers_id
                        and a.first_name is not null
                        and a.last_name is not null
                        and a.address is not null
                        and a.city is not null
                        and a.state is not null
                        and c.account_type = 'HSA'
                        and demo_processed = 'N'
                        and c.account_status not in ( 4, 5 )
                    union
                    select distinct
                        c.acc_num employee_id,
                        null      prefix,
                        '"'
                        || substr(a.last_name, 1, 26)
                        || '"'    last_name,
                        '"'
                        || substr(a.first_name, 1, 19)
                        || '"'    first_name,
                        '"'
                        || substr(a.middle_name, 1, 1)
                        || '"'    middle_name,
                        '"'
                        || a.address
                        || '"'    address,
                        '"'
                        || a.city
                        || '"'    city,
                        '"'
                        || a.state
                        || '"'    state,
                        '"'
                        || a.zip
                        || '"'    zip,
                        null      gender,
                        null      hdhp_eligible,
                        null      drivlic,
                        null      start_date,
                        null      start_time,
                        null      email,
                        b.pers_id,
                        null,
                        a.entrp_id,
                        decode(c.account_type,
                               'HSA',
                               g_employer_id,
                               pc_entrp.get_bps_acc_num(a.entrp_id)),
                        'N',
                        '1'
                    from
                        debit_card_updates        b,
                        person                    a,
                        account                   c,
                        ben_plan_enrollment_setup bp
                    where
                            demo_changed = 'Y'
                        and a.pers_id = b.pers_id
                        and a.pers_id = c.pers_id
                        and a.first_name is not null
                        and a.last_name is not null
                        and a.address is not null
                        and a.city is not null
                        and a.state is not null
                        and bp.acc_id = c.acc_id
                        and bp.plan_end_date > sysdate
                        and c.account_type in ( 'HRA', 'FSA' )
                        and a.entrp_id is not null
                        and c.bps_acc_num is not null
                        and demo_processed = 'N'
                        and c.account_status not in ( 4, 5 )
                );

        end if;

        if l_demographic_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('ADDRESS_UPDATE');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_address_update.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_demographic_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Address_Update'
                      || ','
                      || 'STL_Result_Address_Update'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IB record now, IB is for employee demographics ***/
        for i in 1..l_demographic_tbl.count loop
            l_line := 'IB'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || l_demographic_tbl(i).er_bps_acc_num                -- Employer ID
                      || ','
                      || l_demographic_tbl(i).employee_id        -- Employee ID
                      || ','
                      || l_demographic_tbl(i).last_name        -- Last Name
                      || ','
                      || l_demographic_tbl(i).first_name        -- First Name
                      || ','
                      || l_demographic_tbl(i).middle_name        -- Middle Name
                      || ','
                      || l_demographic_tbl(i).address            -- Address
                      || ','
                      || l_demographic_tbl(i).city            -- City
                      || ','
                      || l_demographic_tbl(i).state            -- State
                      || ','
                      || l_demographic_tbl(i).zip            -- Zip
                      || ','
                      || 'US'                        -- Country
                      || ',DEMG_'
                      || to_char(sysdate, 'MMDD')
                      || l_demographic_tbl(i).employee_id;        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            p_file_name := l_file_name;
            utl_file.fclose(file => l_utl_id);
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Address Update file ', l_sqlerrm);
    end demographic_update;

    procedure lost_stolen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_if_file_name    varchar2(3200);
        l_line            varchar2(32000);
        l_lost_stolen_tbl lost_stolen_tab;
        l_card_number_tbl varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_lost_stolen exception;
        no_lost_stolen exception;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if p_acc_num_list is not null then
            select
                acc_num                           employee_id,
                b.title                           prefix,
                '"'
                || substr(b.last_name, 1, 26)
                || '"'                            last_name,
                '"'
                || substr(b.first_name, 1, 19)
                || '"'                            first_name,
                '"'
                || substr(b.middle_name, 1, 1)
                || '"'                            middle_name,
                '"'
                || b.address
                || '"'                            address,
                '"'
                || b.city
                || '"'                            city,
                '"'
                || b.state
                || '"'                            state,
                '"'
                || b.zip
                || '"'                            zip,
                decode(b.gender, 'M', 1, 'F', 2,
                       0)                         gender,
                to_char(b.birth_date, 'YYYYMMDD') birth_date,
                substr(b.drivlic, 1, 20)          drivlic,
                to_char(a.start_date, 'YYYYMMDD') start_date,
                to_char(a.start_date, 'HHMISS')   start_time,
                null                              email,
                card_number,
                decode(a.account_type,
                       'HSA',
                       g_employer_id,
                       pc_entrp.get_bps_acc_num(b.entrp_id)),
                'N',
                nvl(c.shipping_method, '1')       shipping_method
            bulk collect
            into l_lost_stolen_tbl
            from
                account    a,
                person     b,
                card_debit c
            where
                    a.pers_id = b.pers_id
                and c.card_id = b.pers_id
                and a.complete_flag = 1
                and a.account_type = 'HSA'
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                );

        else
            select
                acc_num                           employee_id,
                b.title                           prefix,
                '"'
                || substr(b.last_name, 1, 26)
                || '"'                            last_name,
                '"'
                || substr(b.first_name, 1, 19)
                || '"'                            first_name,
                '"'
                || substr(b.middle_name, 1, 1)
                || '"'                            middle_name,
                '"'
                || b.address
                || '"'                            address,
                '"'
                || b.city
                || '"'                            city,
                '"'
                || b.state
                || '"'                            state,
                '"'
                || b.zip
                || '"'                            zip,
                decode(b.gender, 'M', 1, 'F', 2,
                       0)                         gender,
                to_char(b.birth_date, 'YYYYMMDD') birth_date,
                substr(b.drivlic, 1, 20)          drivlic,
                to_char(a.start_date, 'YYYYMMDD') start_date,
                to_char(a.start_date, 'HHMISS')   start_time,
                null                              email,
                card_number,
                decode(a.account_type,
                       'HSA',
                       g_employer_id,
                       pc_entrp.get_bps_acc_num(b.entrp_id)),
                'N',
                nvl(c.shipping_method, '1')       shipping_method
            bulk collect
            into l_lost_stolen_tbl
            from
                account    a,
                person     b,
                card_debit c
            where
                    a.pers_id = b.pers_id
                and c.card_id = b.pers_id
                and c.status = 5 -- lost/stolen
                and b.first_name is not null
                and b.last_name is not null
                and b.address is not null
                and b.city is not null
                and b.state is not null
                and ( a.account_type in ( 'HRA', 'FSA' )
                      or ( a.account_type = 'HSA'
                           and pc_account.acc_balance(a.acc_id) > 0 ) )
                and a.complete_flag = 1
                and a.account_status = 1
                and c.card_number is not null
                and c.status_code not in ( 4, 5 );

        end if;

        l_line := null;
        dbms_output.put_line('l_lost_stolen_tbl.count ' || l_lost_stolen_tbl.count);
        if l_lost_stolen_tbl.count = 0 then
            raise no_lost_stolen;
        else
            if l_lost_stolen_tbl.count > 100 then --sk 01/17/2017
                raise mass_lost_stolen;
            else
                dbms_output.put_line('l_lost_stolen_tbl.count ' || l_lost_stolen_tbl.count);
                if p_file_name is null then
                    l_file_id := insert_file_seq('LOST');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_lost.mbi';
                    dbms_output.put_line('file id ' || l_file_id);
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char((l_lost_stolen_tbl.count * 2) + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Lost_Stolen'
                          || ','
                          || 'STL_Result_Lost_Stolen'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        for i in 1..l_lost_stolen_tbl.count loop
            l_line := 'IB'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || l_lost_stolen_tbl(i).er_bps_acc_num   -- Employer ID
                      || ','
                      || l_lost_stolen_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                      || ','
                      || l_lost_stolen_tbl(i).last_name       -- Last Name
                      || ','
                      || l_lost_stolen_tbl(i).first_name      -- First Name
                      || ','
                      || l_lost_stolen_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_lost_stolen_tbl(i).address         -- Address
                      || ','
                      || l_lost_stolen_tbl(i).city            -- City
                      || ','
                      || l_lost_stolen_tbl(i).state           -- State
                      || ','
                      || l_lost_stolen_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ',LOST_'
                      || l_lost_stolen_tbl(i).employee_id;    -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

       /*** Writing IJ record now, IJ is for lost/stolen ***/
        for i in 1..l_lost_stolen_tbl.count loop
            l_line := 'IJ'                                     -- Record ID
                      || ','
                      || g_tpa_id                           -- TPA ID
                      || ','
                      || l_lost_stolen_tbl(i).er_bps_acc_num   -- Employer ID
                      || ','
                      || l_lost_stolen_tbl(i).card_number             -- dont have card number what to do
                      || ','
                      || '5'                                -- Card Status, 5 -lost/stolen
                      || ','
                      || '11'                               -- Card Status Change Reason, 11 - Cardholder lost the card
           --         ||','||'1'                                -- Issue Card
                      || ',LOST_'
                      || to_char(sysdate, 'MMDD')
                      || l_lost_stolen_tbl(i).employee_id; -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_lost_stolen then
            insert_alert('Error in Creating Lost/Stolen file ', 'ALERT!!!! More than 50 cards have been set to lost/stolen, verify before sending the request'
            );
        when no_lost_stolen then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sql error message ' || l_sqlerrm);
            insert_alert('Error in Creating Lost/Stolen file ', l_sqlerrm);
    end lost_stolen;

    procedure lost_stolen_reorder (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_if_file_name    varchar2(3200);
        l_line            varchar2(32000);
        l_lost_stolen_tbl lost_stolen_tab;
        l_card_number_tbl varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        l_count           number;
        mass_lost_stolen exception;
        no_lost_stolen exception;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        select
            count(*)
        into l_count
        from
            cards_external;

        if l_count = 0 then
            insert_alert('Error in Lost/Stolen Reorder', 'Card Detail file doesnt have any data, cannot process lost/stolen reorder card'
            );
        else
            if p_acc_num_list is not null then
                select
                    acc_num                           employee_id,
                    b.title                           prefix,
                    '"'
                    || substr(b.last_name, 1, 26)
                    || '"'                            last_name,
                    '"'
                    || substr(b.first_name, 1, 19)
                    || '"'                            first_name,
                    '"'
                    || substr(b.middle_name, 1, 1)
                    || '"'                            middle_name,
                    '"'
                    || b.address
                    || '"'                            address,
                    '"'
                    || b.city
                    || '"'                            city,
                    '"'
                    || b.state
                    || '"'                            state,
                    '"'
                    || b.zip
                    || '"'                            zip,
                    decode(b.gender, 'M', 1, 'F', 2,
                           0)                         gender,
                    to_char(b.birth_date, 'YYYYMMDD') birth_date,
                    substr(b.drivlic, 1, 20)          drivlic,
                    to_char(a.start_date, 'YYYYMMDD') start_date,
                    to_char(a.start_date, 'HHMISS')   start_time,
                    null                              email,
                    card_number,
                    decode(a.account_type,
                           'HSA',
                           g_employer_id,
                           pc_entrp.get_bps_acc_num(b.entrp_id)),
                    nvl(c.pin_mailer, '0')            pin_mailer,
                    nvl(c.shipping_method, '1')       shipping_method
                bulk collect
                into l_lost_stolen_tbl
                from
                    account    a,
                    person     b,
                    card_debit c
                where
                        a.pers_id = b.pers_id
                    and c.card_id = b.pers_id
                    and a.complete_flag = 1
                    and a.account_type = 'HSA'
                    and a.acc_num in (
                        select
                            *
                        from
                            table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                    );

            else
                select
                    acc_num                           employee_id,
                    b.title                           prefix,
                    '"'
                    || substr(b.last_name, 1, 26)
                    || '"'                            last_name,
                    '"'
                    || substr(b.first_name, 1, 19)
                    || '"'                            first_name,
                    '"'
                    || substr(b.middle_name, 1, 1)
                    || '"'                            middle_name,
                    '"'
                    || b.address
                    || '"'                            address,
                    '"'
                    || b.city
                    || '"'                            city,
                    '"'
                    || b.state
                    || '"'                            state,
                    '"'
                    || b.zip
                    || '"'                            zip,
                    decode(b.gender, 'M', 1, 'F', 2,
                           0)                         gender,
                    to_char(b.birth_date, 'YYYYMMDD') birth_date,
                    substr(b.drivlic, 1, 20)          drivlic,
                    to_char(a.start_date, 'YYYYMMDD') start_date,
                    to_char(a.start_date, 'HHMISS')   start_time,
                    null                              email,
                    card_number,
                    decode(a.account_type,
                           'HSA',
                           g_employer_id,
                           pc_entrp.get_bps_acc_num(b.entrp_id)),
                    nvl(c.pin_mailer, '0')            pin_mailer,
                    nvl(c.shipping_method, '1')       shipping_method
                bulk collect
                into l_lost_stolen_tbl
                from
                    account    a,
                    person     b,
                    card_debit c
                where
                        a.pers_id = b.pers_id
                    and c.card_id = b.pers_id
                    and c.status = 5 -- lost/stolen
                    and b.first_name is not null
                    and b.last_name is not null
                    and b.address is not null
                    and b.city is not null
                    and b.state is not null
                    and ( ( a.account_type in ( 'HRA', 'FSA' )
                            and pc_entrp.get_bps_acc_num(b.entrp_id) is not null )
                          or ( a.account_type = 'HSA'
                               and pc_account.acc_balance(a.acc_id) > 0 ) )
                    and a.complete_flag = 1
                    and a.account_status = 1
                    and c.card_number is not null
                    and c.status_code = 5
          --  AND a.account_type = 'HSA'
                    and 0 = (
                        select
                            count(*)
                        from
                            cards_external
                        where
                            dependant_id is null
                            and employee_id = a.acc_num
                            and status_code in ( 1, 2 )
                    );

            end if;

            l_line := null;
            l_file_id := null;
            if l_lost_stolen_tbl.count = 0 then
                raise no_lost_stolen;
            else
                if l_lost_stolen_tbl.count > 150 then
                    raise mass_lost_stolen;
                else
                    dbms_output.put_line('l_lost_stolen_tbl.count ' || l_lost_stolen_tbl.count);
                    if p_if_file_name is null then
                        l_file_id := insert_file_seq('LOST_IF');
                        l_if_file_name := 'MB_'
                                          || l_file_id
                                          || '_lost_if.mbi';
                        dbms_output.put_line('file id ' || l_file_id);
                    else
                        l_if_file_name := p_if_file_name;
                    end if;

                    update metavante_files
                    set
                        file_name = l_if_file_name
                    where
                        file_id = l_file_id;

                    l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_if_file_name, 'w');
                    l_line := 'IA'
                              || ','
                              || to_char((l_lost_stolen_tbl.count * 1) + 1)
                              || ','
                              || g_edi_password
                              || ','
                              || 'STL_Import_Lost_Stolen'
                              || ','
                              || 'STL_Result_Lost_Stolen'
                              || ','
                              || 'Standard Result Template';

                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;
            end if;
       /*** Writing IF record now, IF is for lost/stolen ***/
            for i in 1..l_lost_stolen_tbl.count loop
                l_line := 'IF'                        -- Record ID
                          || ','
                          || g_tpa_id                    -- TPA ID
                          || ','
                          || l_lost_stolen_tbl(i).er_bps_acc_num      -- Employer ID
                          || ','
                          || l_lost_stolen_tbl(i).employee_id         -- Employee ID
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')            -- Issue Date
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')            -- Card Effective Date
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || '2'                                      -- Issue Card
                          || ','
                          || l_lost_stolen_tbl(i).shipping_method     -- Shipping Method Code, 1 - US Mail
                          || ',LOST_'
                          || to_char(sysdate, 'MMDD')
                          || l_lost_stolen_tbl(i).employee_id         -- Record Tracking Number
                          || ','
                          || l_lost_stolen_tbl(i).pin_mailer; -- PIN mailer

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

            if l_if_file_name is not null then
                utl_file.fclose(file => l_utl_id);
                p_if_file_name := l_if_file_name;
            end if;

        end if;

    exception
        when mass_lost_stolen then
            insert_alert('Error in Lost/Stolen Reorder', 'ALERT!!!! More than 50 cards have been reordered for lost/stolen status, verify before sending the request'
            );
        when no_lost_stolen then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sql error message ' || l_sqlerrm);
            insert_alert('Error in Lost/Stolen Reorder', l_sqlerrm);
    end lost_stolen_reorder;

    procedure suspend_card (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_suspend_tbl     varchar2_tab;
        l_card_number_tbl varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_suspend exception;
    begin

         --card_request_history (6,'SUBSCRIBER');

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if p_acc_num_list is not null then
            select
                acc_num employee_id,
                c.card_number
            bulk collect
            into
                l_suspend_tbl,
                l_card_number_tbl
            from
                account    a,
                card_debit c
            where
                    a.pers_id = c.card_id
                and a.account_type = 'HSA'
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                )
                and a.complete_flag = 1;

        else
            select
                acc_num employee_id,
                c.card_number
            bulk collect
            into
                l_suspend_tbl,
                l_card_number_tbl
            from
                account    a,
                card_debit c
            where
                    c.card_id = a.pers_id
                and c.status = 6 -- suspend
                and a.complete_flag = 1
                and a.account_status = 2
                and c.status_code not in ( 4, 5 )
                and a.account_type = 'HSA'
                and c.card_number is not null;

        end if;

        l_line := null;
        if l_suspend_tbl.count > 1000 then
            raise mass_suspend;
        elsif l_suspend_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('SUSPEND');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_suspend.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_suspend_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Suspend'
                      || ','
                      || 'STL_Result_Suspend'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IJ record now, IJ is for lost/stolen ***/
        for i in 1..l_suspend_tbl.count loop
            l_line := 'IJ'                   -- Record ID
                      || ','
                      || g_tpa_id               -- TPA ID
                      || ','
                      || g_employer_id           -- Employer ID
                      || ','
                      || l_card_number_tbl(i)   -- dont have card number what to do
                      || ','
                      || '3'                   -- Card Status, 3 - Temporarily Inactive
                      || ','
                      || '6'                   -- Card Status Change Reason, 6 - Pending Card Holder Reimbursement
                      || ',SUSP_'
                      || to_char(sysdate, 'MMDD')
                      || l_suspend_tbl(i);  -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_suspend then
            insert_alert('Error in suspend', 'ALERT!!!! More than 1000 debit card suspend are requested, verify before sending the request'
            );
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Suspenion ', l_sqlerrm);
    end suspend_card;

    procedure unsuspend (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_unsuspend_tbl   varchar2_tab;
        l_card_number_tbl varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        card_request_history(7, 'SUBSCRIBER');
        if p_acc_num_list is null then
            select
                acc_num employee_id,
                c.card_number
            bulk collect
            into
                l_unsuspend_tbl,
                l_card_number_tbl
            from
                account    a,
                card_debit c
            where
                    a.pers_id = c.card_id
                and c.status = 7 -- unsuspend
                and pc_account.acc_balance(a.acc_id) > 0
                and status_code not in ( 4, 5 )
                and a.complete_flag = 1
                and a.account_type = 'HSA'
                and a.account_status in ( 1, 3 )
                and c.card_number is not null;

        else
            select
                acc_num employee_id,
                c.card_number
            bulk collect
            into
                l_unsuspend_tbl,
                l_card_number_tbl
            from
                account    a,
                card_debit c
            where
                    a.pers_id = c.card_id
                and a.account_type = 'HSA'
                and a.complete_flag = 1
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                );

        end if;

        l_line := null;
        if l_unsuspend_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('UNSUSPEND');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_unsuspend.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_unsuspend_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Unsuspend'
                      || ','
                      || 'STL_Result_Unsuspend'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IJ record now, IJ is for Unsuspend ***/
        for i in 1..l_unsuspend_tbl.count loop
            l_line := 'IJ'                                           -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_number_tbl(i)         -- dont have card number what to do
                      || ','
                      || '2'                        -- Card Status, 2 - Active
                      || ','
                      || '1'                        -- Card Status Change Reason, 1 - IVR
                      || ',USUS_'
                      || to_char(sysdate, 'MMDD')
                      || l_unsuspend_tbl(i);        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Unsuspension', l_sqlerrm);
    end unsuspend;

    procedure terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id        utl_file.file_type;
        l_file_name     varchar2(3200);
        l_line          varchar2(32000);
        l_terminate_tbl account_tab;
        l_sqlerrm       varchar2(32000);
        l_file_id       number;
        mass_terminate exception;
        no_terminate exception;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            acc_num                      employee_id,
            to_char(sysdate, 'YYYYMMDD') end_date,
            c.card_number,
            decode(a.account_type,
                   'HSA',
                   g_employer_id,
                   pc_entrp.get_bps_acc_num(d.entrp_id)),
            a.account_type
        bulk collect
        into l_terminate_tbl
        from
            account    a,
            card_debit c,
            person     d
        where
                a.pers_id = c.card_id
            and d.pers_id = c.card_id
            and ( a.end_date is not null
                  or c.status = 3 ) -- Ready to Activate
           -- AND a.account_status = 4
            and c.terminated = 'N'
            and c.status_code not in ( 4, 5 )
            and a.account_type in ( 'HRA', 'FSA', 'HSA' )
            and c.card_number is not null;

        l_line := null;
        if l_terminate_tbl.count = 0 then
            raise no_terminate;
        else
            if l_terminate_tbl.count > 800 then
                raise mass_terminate;
            else
                if p_file_name is null then
                    l_file_id := insert_file_seq('TERMINATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_termination.mbi';
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char((l_terminate_tbl.count * 2) + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Terminate'
                          || ','
                          || 'STL_Result_Terminate'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

       /*** Writing IC record now, IC is for employee account ***/
        for i in 1..l_terminate_tbl.count loop
            if l_terminate_tbl(i).account_type = 'HSA' then
                l_line := 'IC'                        -- Record ID
                          || ','
                          || g_tpa_id                    -- TPA ID
                          || ','
                          || g_employer_id                -- Employer ID
                          || ','
                          || g_plan_id                    -- Plan ID
                          || ','
                          || l_terminate_tbl(i).employee_id        -- Employee ID
                          || ','
                          || 'HSA'                    -- Account Type Code
                          || ','
                          || g_plan_start_date                -- Plan Start Date
                          || ','
                          || g_plan_end_date                -- Plan End Date
                          || ','
                          || '5'                        -- Account Status , 5 - Terminated
                          || ','
                          || '0'                        -- Employee Pay Period Election
                          || ','
                          || '0'                        -- Employer Pay Period Election
                          || ','
                          || l_terminate_tbl(i).end_date            -- Termination Date
                          || ',TERM_'
                          || to_char(sysdate, 'MMDD')
                          || l_terminate_tbl(i).employee_id -- Record Tracking Number
                          || ',,';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end loop;

        l_line := null;
        for i in 1..l_terminate_tbl.count loop
            l_line := 'IJ'                   -- Record ID
                      || ','
                      || g_tpa_id               -- TPA ID
                      || ','
                      || l_terminate_tbl(i).employer_id           -- Employer ID
                      || ','
                      || l_terminate_tbl(i).card_number   -- dont have card number what to do
                      || ','
                      || '4'                   -- Card Status, 3 - Permenantly Inactive
                      || ','
                      || '15'                   -- Card Status Change Reason, 6 - Pending Card Holder Reimbursement
                      || ',TERM_'
                      || to_char(sysdate, 'MMDD')
                      || l_terminate_tbl(i).employee_id;  -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

       /*** Writing IC record now, IC is for terminate ***/

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_terminate then
            insert_alert('Error in termination', 'ALERT!!!! More than 100 debit card terminations are requested, verify before sending the request'
            );
        when no_terminate then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in termination', l_sqlerrm);
    end terminate;

    procedure reopen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_reopen_tbl      varchar2_tab;
        l_card_number_tbl varchar2_tab;
        l_start_date_tbl  varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
    begin


        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if p_acc_num_list is not null then
            select
                acc_num employee_id,
                card_number
            bulk collect
            into
                l_reopen_tbl,
                l_card_number_tbl
            from
                account    a,
                card_debit c
            where
                    a.pers_id = c.card_id
                and a.account_type = 'HSA'
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                );

        else
            select
                acc_num employee_id,
                card_number,
                to_char(a.start_date, 'YYYYMMDD')
            bulk collect
            into
                l_reopen_tbl,
                l_card_number_tbl,
                l_start_date_tbl
            from
                account    a,
                card_debit c
            where
                    a.pers_id = c.card_id
                and a.account_type = 'HSA'
                and c.status = 10 -- Reopen
                and a.account_status = 1
                and c.card_number is not null;

        end if;

        l_line := null;
        if l_reopen_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('REOPEN');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_reopen.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char((l_reopen_tbl.count * 2) + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Reopen'
                      || ','
                      || 'STL_Result_Reopen'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IC record now, IC is for employee account ***/
        for i in 1..l_reopen_tbl.count loop
            l_line := 'IC'                    -- Record ID
                      || ','
                      || g_tpa_id                -- TPA ID
                      || ','
                      || g_employer_id            -- Employer ID
                      || ','
                      || g_plan_id                -- Plan ID
                      || ','
                      || l_reopen_tbl(i)              -- Employee ID
                      || ','
                      || 'HSA'                -- Account Type Code
                      || ','
                      || g_plan_start_date            -- Plan Start Date
                      || ','
                      || g_plan_end_date            -- Plan End Date
                      || ','
                      || '2'                    -- Account Status , 2 - Active
                      || ','
                      || '0'                    -- Employee Pay Period Election
                      || ','
                      || '0'                    -- Employer Pay Period Election
                      || ','
                      || to_char(
                l_start_date_tbl(i),
                'YYYYMMDD'
            )        -- Effective Date
                      || ',ROPN_'
                      || to_char(sysdate, 'MMDD')
                      || l_reopen_tbl(i);        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        for i in 1..l_reopen_tbl.count loop
            l_line := 'IJ'                   -- Record ID
                      || ','
                      || g_tpa_id               -- TPA ID
                      || ','
                      || g_employer_id           -- Employer ID
                      || ','
                      || l_card_number_tbl(i)   -- dont have card number what to do
                      || ','
                      || '3'                   -- Card Status, 3 - Temporarily Inactive
                      || ','
                      || '6'                   -- Card Status Change Reason, 6 - Pending Card Holder Reimbursement
                      || ',TERM_'
                      || to_char(sysdate, 'MMDD')
                      || l_reopen_tbl(i);  -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IC record now, IC is for terminate ***/

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Reopen', l_sqlerrm);
    end reopen;

    procedure acc_num_change (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id             utl_file.file_type;
        l_file_name          varchar2(3200);
        l_line               varchar2(32000);
        l_acc_num_change_tbl acc_num_change_tab;
        l_sqlerrm            varchar2(32000);
        l_file_id            number;
    begin
        select
            old_acc_num,
            b.acc_num employee_id
        bulk collect
        into l_acc_num_change_tbl
        from
            debit_card_updates b,
            account            c
        where
                acc_num_changed = 'Y'
            and acc_num_processed = 'N'
            and c.acc_num = b.acc_num
            and c.account_type in ( 'HRA', 'FSA', 'HSA' );

        if l_acc_num_change_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('ACC_NUM_UPDATE');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_acc_num_update.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_acc_num_change_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Acc_Num_Change'
                      || ','
                      || 'STL_Result_RQ'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IB record now, IB is for employee demographics ***/
        for i in 1..l_acc_num_change_tbl.count loop
            l_line := 'IQ'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_acc_num_change_tbl(i).old_employee_id        -- Old Employee ID
                      || ','
                      || l_acc_num_change_tbl(i).employee_id        -- Employee ID
                      || ','
                      || '0'       -- Copy Record
                      || ',DEMG_'
                      || to_char(sysdate, 'MMDD')
                      || l_acc_num_change_tbl(i).employee_id;        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            p_file_name := l_file_name;
            utl_file.fclose(file => l_utl_id);
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Account number change', l_sqlerrm);
    end acc_num_change;

    procedure hra_acc_num_change (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id             utl_file.file_type;
        l_file_name          varchar2(3200);
        l_line               varchar2(32000);
        l_acc_num_change_tbl hra_acc_num_tab;
        l_sqlerrm            varchar2(32000);
        l_file_id            number;
    begin
        select
            replace(ssn, '-'),
            a.acc_num     employee_id,
            c.bps_acc_num bps_acc_num
        bulk collect
        into l_acc_num_change_tbl
        from
            person  b,
            account a,
            account c
        where
                b.pers_id = a.pers_id
            and c.entrp_id = b.entrp_id
            and a.account_type = 'HRA'
            and c.bps_acc_num = 'STLDURALECT';

        if l_acc_num_change_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('ACC_NUM_UPDATE');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_acc_num_update.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_acc_num_change_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Acc_Num_Change'
                      || ','
                      || 'STL_Result_RQ'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IB record now, IB is for employee demographics ***/
        for i in 1..l_acc_num_change_tbl.count loop
            l_line := 'IQ'                        -- Record ID
                      || ','
                      || g_tpa_id                  -- TPA ID
                      || ','
                      || l_acc_num_change_tbl(i).employer_id          -- Employer ID
                      || ','
                      || l_acc_num_change_tbl(i).old_employee_id        -- Old Employee ID
                      || ','
                      || l_acc_num_change_tbl(i).employee_id        -- Employee ID
                      || ','
                      || '0'       -- Copy Record
                      || ',DEMG_'
                      || to_char(sysdate, 'MMDD')
                      || l_acc_num_change_tbl(i).employee_id;        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            p_file_name := l_file_name;
            utl_file.fclose(file => l_utl_id);
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in HRA account number change ', l_sqlerrm);
    end hra_acc_num_change;
  -- IMPORT
  /***** Request to send Export records ******/

    procedure import_req_export (
        p_record_type      in varchar2,
        p_transaction_type in varchar2,
        p_file_name        in out varchar2
    ) is

        l_utl_id     utl_file.file_type;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_reopen_tbl varchar2_tab;
        l_sqlerrm    varchar2(32000);
        l_file_id    number;
    begin
          /** will check with metavante if IL record is needed for this **/
        if p_record_type is not null then
            if p_file_name is null then
                l_file_id := insert_file_seq(p_record_type);
                l_file_name := 'MB_'
                               || l_file_id
                               || '_'
                               || p_record_type
                               || '.mbi';
                dbms_output.put_line('file id ' || l_file_id);
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            if nvl(p_transaction_type, -1) <> 'MANUAL_CLAIM' then
                l_line := 'IA'
                          || ','
                          || 2
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_'
                          || p_record_type
                          || '_Import'
                          || ','
                          || 'STL_Export_Result'
                          || ','
                          || 'STL_'
                          || p_record_type
                          || '_Export';
            else
                l_line := 'IA'
                          || ','
                          || 2
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_'
                          || p_record_type
                          || '_Import'
                          || ','
                          || 'STL_Export_Result'
                          || ','
                          || 'STL_Export_Claim_Template';
            end if;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            if p_record_type <> 'EN' then
                l_line := 'IL'            -- Record ID
                          || ','
                          || g_tpa_id             -- TPA ID
                          || ','
                          || p_record_type        -- Export Record Type
                          || ','
                          || '1'                  -- Transaction TYpe, 1- All
                          || ','
                          || ''                   -- -- Export Date from
                          || ','
                          || ''                   -- Export Date to
                          || ','
                          || '2';                 -- Output format

            else
                l_line := 'IL'                            -- Record ID
                          || ','
                          || g_tpa_id                             -- TPA ID
                          || ','
                          || p_record_type;                       -- Export Record Type
                if p_transaction_type <> 'MANUAL_CLAIM' then
                    l_line := l_line
                              || ','
                              || '2';                -- Transaction Origination, 'POS'
                else
                    l_line := l_line
                              || ','
                              || '4';                  -- Transaction Origination, 'MANUAL'
                end if;

                l_line := l_line
                          || ','
                          || '1'                -- Transaction TYpe, includes Pre-Auth, Force-Post, Refund
                          || ','
                          || '99'                                 -- Transaction Status
                          || ','
                          || '2';                                  -- Transaction Date Type, 1 -- Settlement Date
                if p_transaction_type = 'PENDING' then
                    l_line := l_line
                              || ','
                              || to_char(trunc(sysdate) - 22,
                                         'YYYYMMDD'); -- Export Date from
                elsif p_transaction_type = 'MANUAL_CLAIM' then
                    l_line := l_line
                              || ','
                              || to_char(trunc(sysdate) - 2,
                                         'YYYYMMDD');
                else
                    l_line := l_line
                              || ','
                              || to_char(trunc(sysdate) - 4,
                                         'YYYYMMDD');
                end if;

                l_line := l_line
                          || ','
                          || to_char(
                    trunc(sysdate),
                    'YYYYMMDD'
                )   -- Export Date to
                          || ','
                          || '2'                                 -- Output format
                          || ','
                          || '4';                                  -- Transaction Filter

            end if;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Import request ', l_sqlerrm);
    end;

    procedure request_account_export (
        p_file_name in out varchar2
    ) is
    begin
        -- 'EC' is to get the available balance in the card
        import_req_export('EC', null, p_file_name);
    end;

    procedure request_card_export (
        p_file_name in out varchar2
    ) is
    begin
         -- 'EC' is to get the available balance in the card
        import_req_export('EM', null, p_file_name);
    end;

    procedure request_manual_claim_export (
        p_file_name in out varchar2
    ) is
    begin
         -- 'EC' is to get the available balance in the card
        import_req_export('EN', 'MANUAL_CLAIM', p_file_name);
    end;

    procedure request_transaction_export (
        p_file_name in out varchar2
    ) is
    begin
        -- 'EC' is to get the available balance in the card
        import_req_export('EN', 'SETTLEMENT', p_file_name);
    end;

    procedure request_pending_auth_export (
        p_file_name in out varchar2
    ) is
    begin
        -- 'EC' is to get the available balance in the card
        import_req_export('EN', 'PENDING', p_file_name);
    end;

    /*** Processing Export Records ****/

    procedure update_card_details (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    ) is

        l_utl_id         utl_file.file_type;
        l_file_name      varchar2(3200);
        l_sqlerrm        varchar2(3200);
        l_card_file_name varchar2(30) := 'MB_'
                                         || to_char(sysdate, 'YYYYMMDD')
                                         || '_EM.exp';
        l_create_error exception;
        l_exists         varchar2(1) := 'N';
        l_status         varchar2(1);
    begin
        l_file_name := 'MB_'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '_log.csv';
        if p_file_name is not null then
            l_card_file_name := p_file_name;
        end if;
        if file_length(l_card_file_name) > 0 then
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(l_card_file_name, '.exp', '.mbi');

        end if;

        if l_exists = 'N' then
            dbms_output.put_line('No Export files found ');
        else
            begin
                execute immediate '
                   ALTER TABLE CARDS_EXTERNAL
                    location (DEBIT_CARD_DIR:'''
                                  || l_card_file_name
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := 'Error in Changing location of cards file' || sqlerrm;
                    insert_alert('Error in updaing card details for EM ', 'Error in altering card  file  ' || l_card_file_name);
                    raise l_create_error;
            end;
        end if;

        for x in (
            select
                count(*) cnt
            from
                cards_external
        ) loop
            if x.cnt > 0 then
                begin
                    execute immediate 'TRUNCATE TABLE METAVANTE_CARDS';
                    insert into metavante_cards (
                        metavante_card_id,
                        acc_num,
                        card_effective_date,
                        card_expire_date,
                        card_number,
                        status_code,
                        status_code_reason,
                        shipment_tracking_number,
                        activation_date,
                        mailed_date,
                        issue_date,
                        last_update_date,
                        creation_date,
                        dependant_id,
                        card_proxy_number,
                        pin_request_date,
                        pin_mailed_date
                    )
                        select
                            metavante_card_seq.nextval,
                            employee_id,
                            card_effective_date,
                            card_expire_date,
                            card_number,
                            status_code,
                            status_code_reason,
                            shipment_tracking_number,
                            activation_date,
                            mailed_date,
                            issue_date,
                            sysdate,
                            sysdate,
                            dependant_id,
                            card_proxy_number,
                            to_date(pin_request_date, 'YYYYMMDD'),
                            to_date(pin_mailed_date, 'YYYYMMDD')
                        from
                            cards_external
                        where
                            dependant_id is null
                            or is_number(dependant_id) = 'Y';

                exception
                    when others then
                        l_sqlerrm := 'Error in Changing truncating metavante_cards ' || sqlerrm;
                        insert_alert('Error in Changing truncating metavante_cards ', l_sqlerrm);
                        raise l_create_error;
                end;

            end if;
        end loop;

        commit;
        process_card_details;
    exception
        when l_create_error then
            rollback;
            x_error_message := l_sqlerrm;
            insert_alert('Error in Changing updating card details for EM ', l_sqlerrm);
            x_error_status := 'E';
        when others then
            rollback;
            l_sqlerrm := sqlerrm;
            x_error_message := l_sqlerrm;

       /** send email alert as soon as it fails **/
            insert_alert('Error in Changing updating card details for EM ', l_sqlerrm);
            x_error_status := 'E';
    end update_card_details;

    procedure process_card_details is

        l_utl_id         utl_file.file_type;
        l_file_name      varchar2(3200);
        l_sqlerrm        varchar2(3200);
        l_card_file_name varchar2(30) := 'MB_'
                                         || to_char(sysdate, 'YYYYMMDD')
                                         || '_EM.exp';
        l_create_error exception;
        l_exists         varchar2(1) := 'N';
        l_status         varchar2(1);
    begin
        for x in (
            select
                rownum        rn,
                b.employee_id,
                card_effective_date,
                b.card_expire_date,
                b.status_code card_status,
                case
                    when b.status_code in ( 1, 2 ) then
                        2
                    when b.status_code = 3 then
                        4
                    when b.status_code = 5 then
                        5
                    when b.status_code = 4 then
                        3
                end           status_code,
                b.shipment_tracking_number,
                b.activation_date,
                b.mailed_date,
                b.issue_date,
                b.card_number,
                d.pers_id,
                d.acc_id,
                c.status,
                d.account_status,
                d.plan_code
            from
                cards_external b,
                account        d,
                card_debit     c
            where
                    d.acc_num = b.employee_id
                and b.dependant_id is null
                and c.card_id = d.pers_id
                and b.primary_flag = 1
                and to_date(b.card_expire_date, 'YYYYMMDD') > sysdate
                  --  and   B.CARD_NUMBER = PC_DEBIT_CARD.GET_EE_CARD_NUMBER(B.EMPLOYEE_ID)
                and ( b.dependant_id is null
                      or is_number(b.dependant_id) = 'Y' )
                and exists (
                    select
                        *
                    from
                        person  e,
                        account f
                    where
                            e.pers_id = c.card_id
                        and f.pers_id = e.pers_id
                )
            order by
                d.acc_num,
                b.card_number
        ) loop
            begin
                l_sqlerrm := null;
                l_status := null;
                l_exists := 'Y';
          /** Accoount Holder Cards **/
                if
                    x.card_status in ( 4, 5 )
                    and x.account_status = 4
                then
                    l_status := 3;
                end if;

                update card_debit
                set
                    issue_date = x.issue_date,
                    mailed_date = x.mailed_date,
                    activation_date = x.activation_date,
                    expire_date = x.card_expire_date
               --, card_status      = x.status_code
                    ,
                    tracking_number = x.shipment_tracking_number,
                    card_number = x.card_number,
                    last_update_date = sysdate,
                    status = nvl(l_status, x.status_code),
                    status_code = x.card_status,
                    terminated = decode(l_status, 3, 'Y', 'N')
                where
                    card_id = x.pers_id;

                commit;
            exception
                when others then
                    rollback;
                    insert_alert('Error in  processing employee card details for EM ', 'Card id '
                                                                                       || x.pers_id
                                                                                       || 'Error '
                                                                                       || l_sqlerrm);
            end;
        end loop;

        for x in (
            select
                rownum        rn,
                b.employee_id,
                card_effective_date,
                b.card_expire_date,
                case
                    when b.status_code in ( 1, 2 ) then
                        2
                    when b.status_code = 3 then
                        4
                    when b.status_code = 5 then
                        5
                    when b.status_code = 4 then
                        3
                end           status_code,
                b.shipment_tracking_number,
                b.activation_date,
                b.mailed_date,
                b.issue_date,
                b.card_number,
                c.card_id,
                c.status,
                b.status_code card_status,
                (
                    select
                        account_status
                    from
                        account
                    where
                        acc_num = b.employee_id
                )             account_status,
                d.acc_id,
                d.plan_code
            from
                cards_external b,
                card_debit     c,
                account        d,
                person         e
            where
                b.dependant_id is not null
                and b.employee_id = d.acc_num
                and is_number(b.dependant_id) = 'Y'
                and to_date(b.card_expire_date, 'YYYYMMDD') > sysdate
                and b.primary_flag = 1
                and e.pers_main = d.pers_id
                and c.card_id = e.pers_id
                and to_char(c.card_id) = b.dependant_id
          --      AND   B.CARD_NUMBER = PC_DEBIT_CARD.get_dep_card_number(B.EMPLOYEE_ID, b.dependant_id)
            order by
                d.acc_num,
                b.card_number asc
        ) loop
            begin
                l_sqlerrm := null;
                l_status := null;
                if
                    x.card_status in ( 4, 5 )
                    and x.account_status = 4
                then
                    l_status := 3;
                end if;
          /** Accoount Holder Cards **/
                update card_debit
                set
                    issue_date = x.issue_date,
                    mailed_date = x.mailed_date,
                    activation_date = x.activation_date,
                    expire_date = x.card_expire_date
               --, card_status      = x.status_code
                    ,
                    tracking_number = x.shipment_tracking_number,
                    card_number = x.card_number,
                    last_update_date = sysdate,
                    status = nvl(l_status, x.status_code),
                    status_code = x.card_status,
                    terminated = decode(l_status, 3, 'Y', 'N')
                where
                    card_id = x.card_id;

            exception
                when others then
                    rollback;
                    l_sqlerrm := sqlerrm;

            /** send email alert as soon as it fails **/
                    insert_alert('Error in  processing dependant card details for EM ', 'Card id '
                                                                                        || x.card_id
                                                                                        || 'Error '
                                                                                        || l_sqlerrm);
            end;
        end loop;
              /** For the lost/stolen we have to make sure that the card is set to
	          lost/stolen at BPS end, only after confirming that we will send in
		  the new card file generation **/

        for x in (
            select
                d.pers_id,
                case
                    when b.status_code in ( 1, 2 ) then
                        2
                    when b.status_code = 3 then
                        4
                    when b.status_code = 5 then
                        5
                    when b.status_code = 4 then
                        3
                end status_code
            from
                cards_external b,
                account        d,
                card_debit     c
            where
                    d.acc_num = b.employee_id
                and b.dependant_id is null
                and c.card_id = d.pers_id
                and c.status = 5
                and b.status_code = 5
                and to_date(b.card_expire_date, 'YYYYMMDD') > sysdate
                  --  and   B.CARD_NUMBER = PC_DEBIT_CARD.GET_EE_CARD_NUMBER(B.EMPLOYEE_ID)
                and exists (
                    select
                        *
                    from
                        person  e,
                        account f
                    where
                            e.pers_id = c.card_id
                        and f.pers_id = e.pers_id
                )
            union
            select
                d.pers_id,
                case
                    when b.status_code in ( 1, 2 ) then
                        2
                    when b.status_code = 3 then
                        4
                    when b.status_code = 5 then
                        5
                    when b.status_code = 4 then
                        3
                end status_code
            from
                cards_external b,
                account        d,
                card_debit     c
            where
                    d.acc_num = b.employee_id
                and b.dependant_id is null
                and c.card_id = d.pers_id
                and b.status_code in ( 1, 2, 4, 5 )
                and c.status = 5
                   -- AND   B.PRIMARY_FLAG = 1
                and to_date(b.card_expire_date, 'YYYYMMDD') > sysdate
                  --  and   B.CARD_NUMBER = PC_DEBIT_CARD.GET_EE_CARD_NUMBER(B.EMPLOYEE_ID)
                and ( b.dependant_id is null
                      or is_number(b.dependant_id) = 'Y' )
                and exists (
                    select
                        *
                    from
                        person  e,
                        account f
                    where
                            e.pers_id = c.card_id
                        and f.pers_id = e.pers_id
                )
        ) loop
            update card_debit
            set
                status_code = x.status_code
            where
                card_id = x.pers_id;

        end loop;

       /** For the dependent lost/stolen we have to make sure that the card is set to
	          lost/stolen at BPS end, only after confirming that we will send in
		  the new card file generation **/

        for x in (
            select
                e.pers_id,
                d.acc_num,
                case
                    when b.status_code in ( 1, 2 ) then
                        2
                    when b.status_code = 3 then
                        4
                    when b.status_code = 5 then
                        5
                    when b.status_code = 4 then
                        3
                end status_code
            from
                cards_external b,
                card_debit     c,
                account        d,
                person         e
            where
                b.dependant_id is not null
                and b.employee_id = d.acc_num
                and is_number(b.dependant_id) = 'Y'
                and to_date(b.card_expire_date, 'YYYYMMDD') > sysdate
                and c.status = 5
                and b.status_code = 5
                and e.pers_main = d.pers_id
                and c.card_id = e.pers_id
                and to_char(c.card_id) = b.dependant_id
            union
            select
                e.pers_id,
                d.acc_num,
                case
                    when b.status_code in ( 1, 2 ) then
                        2
                    when b.status_code = 3 then
                        4
                    when b.status_code = 5 then
                        5
                    when b.status_code = 4 then
                        3
                end status_code
            from
                cards_external b,
                card_debit     c,
                account        d,
                person         e
            where
                b.dependant_id is not null
                and b.employee_id = d.acc_num
                and is_number(b.dependant_id) = 'Y'
                and to_date(b.card_expire_date, 'YYYYMMDD') > sysdate
                and b.status_code in ( 1, 2, 4, 5 )
                and e.pers_main = d.pers_id
                and c.card_id = e.pers_id
                and to_char(c.card_id) = b.dependant_id
        ) loop
            update card_debit
            set
                status_code = x.status_code
            where
                card_id = x.pers_id;

        end loop;

        for x in (
            select
                e.pers_id,
                d.acc_num,
                case
                    when b.status_code in ( 1, 2 ) then
                        2
                    when b.status_code = 3 then
                        4
                    when b.status_code = 5 then
                        5
                    when b.status_code = 4 then
                        3
                end status_code
            from
                cards_external b,
                card_debit     c,
                account        d,
                person         e
            where
                    b.employee_id = d.acc_num
                and to_date(b.card_expire_date, 'YYYYMMDD') <= sysdate
                and c.status = 5
                and b.status_code <> 5
                and c.status_code <> 5
                and e.pers_id = d.pers_id
                and c.card_id = e.pers_id
            order by
                d.acc_num,
                b.card_number asc
        ) loop
            update card_debit
            set
                status_code = x.status_code
            where
                card_id = x.pers_id;

        end loop;

    end process_card_details;

    procedure update_card_balance (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    ) is

        l_utl_id                 utl_file.file_type;
        l_file_name              varchar2(3200);
        l_sqlerrm                varchar2(3200);
        l_card_balance_file_name varchar2(30) := 'MB_'
                                                 || to_char(sysdate, 'YYYYMMDD')
                                                 || '_EC.exp';
        l_create_error exception;
        l_exists                 varchar2(1) := 'N';
    begin
        l_file_name := 'MB_'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '_log.csv';
        if p_file_name is not null then
            l_card_balance_file_name := p_file_name;
        end if;
        if file_exists(l_card_balance_file_name) = 'TRUE' then
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(l_card_balance_file_name, '.exp', '.mbi');

        end if;

        if l_exists = 'N' then
            dbms_output.put_line('No Export files found ');
        else
            begin
                execute immediate '
                       ALTER TABLE CARD_BALANCE_EXTERNAL
                        location (DEBIT_CARD_DIR:'''
                                  || l_card_balance_file_name
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    insert_alert('Error in Changing card balance file for EC ', 'Error in altering card balance file  ' || l_card_balance_file_name
                    );
                    raise l_create_error;
            end;
        end if;

        for x in (
            select
                available_balance,
                disbursable_balance,
                employee_contribution_ytd,
                pre_auth_hold_balance,
                a.pers_id,
                b.account_status,
                b.card_number,
                b.employee_id,
                b.employer_id,
                b.plan_id,
                case
                    when a.acc_num like 'HRA%' then
                        decode((
                            select
                                count(*)
                            from
                                ben_plan_enrollment_setup bp,
                                account                   d
                            where
                                    d.bps_acc_num = b.employer_id
                                and bp.ben_plan_name = b.plan_id
                                and bp.status in('A', 'I')
                                and bp.acc_id = d.acc_id
                        ),
                               0,
                               'Y',
                               'N')
                    else
                        'Y'
                end                                    insert_flag,
                b.plan_type,
                to_date(b.plan_start_date, 'YYYYMMDD') plan_start_date,
                to_date(b.plan_end_date, 'YYYYMMDD')   plan_end_date,
                b.annual_election,
                a.acc_id
            from
                account               a,
                card_balance_external b
            where
                a.acc_num = b.employee_id
        ) loop
            l_sqlerrm := null;
            begin
                update card_debit
                set
                    current_card_value = x.disbursable_balance,
                    current_auth_value = x.pre_auth_hold_balance,
                    last_update_date = sysdate,
                    card_number = x.card_number
                where
                    card_id = x.pers_id;

                if x.insert_flag = 'Y' then
                    if x.plan_type = 'HSA' then
                        update metavante_card_balances
                        set
                            available_balance = x.available_balance,
                            disbursable_balance = x.disbursable_balance,
                            employee_contribution_ytd = x.employee_contribution_ytd,
                            pre_auth_hold_balanc = x.pre_auth_hold_balance,
                            last_update_date = sysdate,
                            employer_id = x.employer_id,
                            plan_id = x.plan_id
                        where
                            acc_num = x.employee_id;

                    else
                        update metavante_card_balances
                        set
                            available_balance = x.available_balance,
                            disbursable_balance = x.disbursable_balance,
                            employee_contribution_ytd = x.employee_contribution_ytd,
                            pre_auth_hold_balanc = x.pre_auth_hold_balance,
                            last_update_date = sysdate,
                            employer_id = x.employer_id,
                            plan_id = x.plan_id,
                            annual_election = x.annual_election,
                            account_status = x.account_status
                        where
                                acc_num = x.employee_id
                            and plan_type = x.plan_type
                            and plan_start_date = x.plan_start_date
                            and plan_end_date = x.plan_end_date;

                    end if;

                    if sql%rowcount = 0 then
                        insert into metavante_card_balances (
                            metavante_card_balance_id,
                            acc_num,
                            account_status,
                            card_number,
                            available_balance,
                            disbursable_balance,
                            employee_contribution_ytd,
                            pre_auth_hold_balanc,
                            last_upload_status,
                            upload_error_code,
                            employer_id,
                            plan_id,
                            plan_type,
                            plan_start_date,
                            plan_end_date,
                            annual_election,
                            last_update_date,
                            creation_date,
                            acc_id
                        ) values ( metavante_card_balance_seq.nextval,
                                   x.employee_id,
                                   x.account_status,
                                   x.card_number,
                                   x.available_balance,
                                   x.disbursable_balance,
                                   x.employee_contribution_ytd,
                                   x.pre_auth_hold_balance,
                                   null,
                                   null,
                                   x.employer_id,
                                   x.plan_id,
                                   x.plan_type,
                                   x.plan_start_date,
                                   x.plan_end_date,
                                   x.annual_election,
                                   sysdate,
                                   sysdate,
                                   x.acc_id );

                    end if;

                end if;
           -- END LOOP;
            exception
                when others then
                    rollback;
                    l_utl_id := utl_file.fopen('DEBIT_LOG_DIR', l_file_name, 'a');
                    l_sqlerrm := sqlerrm;
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_sqlerrm
                    );
                    utl_file.fclose(file => l_utl_id);
            end;

        end loop;
     -- BPS might have been updated with plan start date and plan end date so
     -- it is better to reconcile
   /*  FOR X IN ( select A.EMPLOYEE_ID
                      , A.PLAN_ID
                      , B.BEN_PLAN_ID
                      , A.PLAN_START_DATE
                      , A.PLAN_END_DATE
                      ,A.ANNUAL_ELECTION
                      , C.ACC_ID
                      , A.PLAN_TYPE
                 from card_balance_external A
                    , BEN_PLAN_ENROLLMENT_SETUP B
                    , ACCOUNT C
                 WHERE A.EMPLOYEE_ID = C.ACC_NUM
                 AND   B.ACC_ID = C.ACC_ID
                 AND   A.PLAN_START_DATE = TO_CHAR(B.PLAN_START_DATE,'YYYYMMDD')
                 AND   A.PLAN_END_DATE = TO_CHAR(B.PLAN_END_DATE,'YYYYMMDD')
                 AND   B.BEN_PLAN_NAME = A.PLAN_ID
                 AND employee_id like 'HRA%')
      LOOP
         UPDATE BEN_PLAN_ENROLLMENT_SETUP
          SET   PLAN_START_DATE = TO_DATE(X.PLAN_START_DATE,'YYYYMMDD')
            ,   PLAN_END_DATE =  TO_DATE(X.PLAN_END_DATE,'YYYYMMDD')
            ,   ANNUAL_ELECTION =  X.ANNUAL_ELECTION
            ,   PLAN_TYPE = X.PLAN_TYPE
        WHERE  BEN_PLAN_ID = X.BEN_PLAN_ID;
      END LOOP;*/

    exception
        when l_create_error then
            rollback;
            x_error_message := l_sqlerrm;
            insert_alert('Error in updating card balance ', l_sqlerrm);
            x_error_status := 'E';
        when others then
            rollback;
            l_sqlerrm := sqlerrm;
       /** send email alert as soon as it fails **/
            insert_alert('Error in updating card balance ', l_sqlerrm);
            x_error_status := 'E';
    end;

    procedure post_pending_authorizations (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    ) is

        l_sqlerrm              varchar2(3200);
        l_settlement_file_name varchar2(30) := 'MB_'
                                               || to_char(sysdate, 'YYYYMMDD')
                                               || '_EN.exp';
        l_create_error exception;
        l_exists               varchar2(1);
    begin
        if p_file_name is not null then
            l_settlement_file_name := p_file_name;
        end if;
        if file_exists(l_settlement_file_name) = 'TRUE' then
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(l_settlement_file_name, '.exp', '.mbi');

        end if;

        if l_exists = 'N' then
            dbms_output.put_line('No Export files found ');
        else
            begin
                execute immediate '
                       ALTER TABLE SETTLEMENTS_EXTERNAL
                        location (DEBIT_CARD_DIR:'''
                                  || l_settlement_file_name
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    insert_alert('Error in posting settlements ', 'Error in altering settlement file  ' || l_settlement_file_name);
                    raise l_create_error;
            end;
        end if;

        for x in (
            select
                count(*) cnt
            from
                settlements_external
            where
                record_id = 'EN'
        ) loop
            if x.cnt > 0 then
                delete from metavante_authorizations;

                insert into metavante_authorizations (
                    authorization_id,
                    acc_num,
                    pers_id,
                    merchant_name,
                    transaction_amount,
                    transaction_date,
                    mcc_code,
                    approval_code,
                    creation_date,
                    last_update_date,
                    plan_type
                )
                    select distinct
                        settlement_seq_number,
                        b.acc_num,
                        c.pers_id,
                        a.merchant_name,
                        a.transaction_amount,
                        to_date(a.settlement_date, 'YYYYMMDD'),
                        a.mcc_code,
                        a.approval_code,
                        sysdate,
                        sysdate,
                        a.plan_type
                    from
                        settlements_external a,
                        account              b,
                        person               c
                    where
                            a.employee_id = b.acc_num
                        and b.pers_id = c.pers_id
                        and a.transaction_code = 11
                        and a.transaction_process_code <> 50 -- EXCLUDE REVERSALS
                        and not exists (
                            select
                                *
                            from
                                metavante_authorizations d
                            where
                                    d.authorization_id = a.settlement_seq_number
                                and d.approval_code = a.approval_code
                        )
                        and not exists (
                            select
                                *
                            from
                                metavante_settlements d
                            where
                                    d.acc_num = a.employee_id
                                and d.approval_code = a.approval_code
                        );

            end if;
        end loop;

    exception
        when l_create_error then
            rollback;
            x_error_message := l_sqlerrm;
            insert_alert('Error in Posting Pending Authorizations', l_sqlerrm);
            x_error_status := 'E';
        when others then
            rollback;
            l_sqlerrm := sqlerrm;
       /** send email alert as soon as it fails **/
            insert_alert('Error in Posting Pending Authorizations', 'Error in Posting Pending Authorizations' || l_sqlerrm);
            x_error_status := 'E';
    end;

    procedure process_settlements (
        x_error_message out varchar2,
        x_error_status  out varchar2,
        p_file_name     in out varchar2
    ) is

        l_claim_id             number;
        l_sqlerrm              varchar2(3200);
        l_settlement_file_name varchar2(30) := 'MB_'
                                               || to_char(sysdate, 'YYYYMMDD')
                                               || '_EN.exp';
        l_file_name            varchar2(3200);
        l_utl_id               utl_file.file_type;
        l_create_error exception;
        l_exists               varchar2(1) := 'N';
        l_transaction_count    number := 0;
        l_count                number := 0;
        l_processed exception;
        l_plan_start_date      date;
        l_plan_end_date        date;
        l_card_number          number;
        l_claim_status         varchar2(100);
        l_substantiate_flag    varchar2(1);
    begin
        if p_file_name is not null then
            l_settlement_file_name := p_file_name;
        end if;
        --  l_sql :=  'ALTER TABLE METAVANTE_RESULT_EXTERNAL LOCATION (';
        select
            count(*)
        into l_count
        from
            metavante_files
        where
                result_flag = 'Y'
            and file_name = replace(l_settlement_file_name, '.exp', '.mbi');

        if l_count > 0 then
            raise l_processed;
        end if;
        if file_length(l_settlement_file_name) > 0 then
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(l_settlement_file_name, '.exp', '.mbi');

        end if;

        if l_exists = 'N' then
            dbms_output.put_line('No Export files found ');
        else
            begin
                execute immediate '
                   ALTER TABLE SETTLEMENTS_EXTERNAL
                    location (DEBIT_CARD_DIR:'''
                                  || l_settlement_file_name
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := 'Error in changing settlement file ' || sqlerrm;
                    insert_alert('Error in processing settlement file', 'Error in altering settlement file  ' || l_settlement_file_name
                    );
                    raise l_create_error;
            end;
        end if;

        l_file_name := 'MB_'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '_log.csv';
        for x in (
            select
                settlement_seq_number,
                b.pers_id,
                b.acc_id,
                substr(
                    pc_person.get_claim_code(b.pers_id),
                    1,
                    4
                )                                           claim_code,
                a.merchant_name,
                a.transaction_amount,
                employee_id,
                mcc_code,
                transaction_code,
                transaction_status,
                transaction_date,
                approval_code,
                disbursable_balance,
                effective_date,
                pos_flag,
                origin_code,
                pre_auth_hold_balance,
                settlement_date,
                terminal_city,
                terminal_name,
                detail_response_code,
                plan_type,
                pc_person.get_entrp_from_pers_id(b.pers_id) entrp_id,
                plan_start_date,
                plan_end_date,
                card_number,
                b.account_type
            from
                settlements_external a,
                account              b
            where
                    a.employee_id = b.acc_num
                and a.transaction_code in ( 12, 14 )
                and a.pos_flag <> 4
                and a.record_id = 'EN'
                and not exists (
                    select
                        *
                    from
                        metavante_settlements c
                    where
                            c.settlement_number || c.transaction_date = a.settlement_seq_number || a.transaction_date
                        and c.acc_num = a.employee_id
                )

                --AND  A.ORIGIN_CODE IN (1,2,3,4)
        ) loop
            begin
                l_claim_id := null;
                l_sqlerrm := null;
                insert into metavante_settlements (
                    settlement_number,
                    acc_num,
                    acc_id,
                    merchant_name,
                    mcc_code,
                    transaction_amount,
                    transaction_code,
                    transaction_status,
                    transaction_date,
                    approval_code,
                    disbursable_balance,
                    effective_date,
                    pos_flag,
                    origin_code,
                    pre_auth_hold_balance,
                    settlement_date,
                    terminal_city,
                    terminal_name,
                    detail_response_code,
                    created_claim,
                    claim_id,
                    last_update_date,
                    creation_date,
                    plan_type,
                    plan_start_date,
                    plan_end_date,
                    card_number
                ) values ( x.settlement_seq_number,
                           x.employee_id,
                           x.acc_id,
                           x.merchant_name,
                           x.mcc_code,
                           x.transaction_amount,
                           x.transaction_code,
                           x.transaction_status,
                           x.transaction_date,
                           x.approval_code,
                           x.disbursable_balance,
                           x.effective_date,
                           x.pos_flag,
                           x.origin_code,
                           x.pre_auth_hold_balance,
                           x.settlement_date,
                           x.terminal_city,
                           x.terminal_name,
                           x.detail_response_code,
                           'N',
                           null,
                           sysdate,
                           sysdate,
                           x.plan_type,
                           x.plan_start_date,
                           x.plan_end_date,
                           x.card_number );

          -- PC_LOG.LOG_ERROR('SETTLEMENTS',X.SETTLEMENT_SEQ_NUMBER);
        --   PC_LOG.LOG_ERROR('SETTLEMENTS,EFFECTIVE_DATE',X.EFFECTIVE_DATE);
      --     PC_LOG.LOG_ERROR('SETTLEMENTS,SETTLEMENT_DATE',X.SETTLEMENT_DATE);
                l_plan_start_date := null;
                l_plan_end_date := null;

           /*FOR xX IN ( SELECT PLAN_START_DATE, PLAN_END_DATE
                      FROM   BEN_PLAN_ENROLLMENT_SETUP
                      WHERE  NVL(TO_DATE(SUBSTR(X.EFFECTIVE_DATE,1,8),'YYYYMMDD'),TO_DATE(SUBSTR(X.SETTLEMENT_DATE,1,8),'YYYYMMDD'))
                      BETWEEN PLAN_START_DATE AND PLAN_END_DATE
                      AND    ACC_ID= X.acc_id
                      AND    PLAN_TYPE = X.PLAN_TYPE)
           LOOP
              l_plan_start_date := xX.PLAN_START_DATE;
              l_plan_end_date := xX.PLAN_END_DATE;
           END LOOP;*/
                l_claim_status := 'PAID';
           -- Add this when we go live with debit card project
                l_substantiate_flag := 'N';
                if x.account_type in ( 'HRA', 'FSA' ) then
                    for xx in (
                        select
                            nvl(allow_substantiation, 'N') allow_substantiation
                        from
                            ben_plan_enrollment_setup
                        where
                                plan_type = x.plan_type
                            and status in ( 'A', 'I' )
                            and plan_start_date = to_date(substr(x.plan_start_date, 1, 8),
        'YYYYMMDD')
                            and plan_end_date = to_date(substr(x.plan_end_date, 1, 8),
        'YYYYMMDD')
                            and acc_id = x.acc_id
                    ) loop
                        if xx.allow_substantiation = 'Y' then
                            if x.transaction_status in ( 'AUP1', 'AUP5', 'AUPI' ) then
                                l_substantiate_flag := 'Y';
                            elsif x.transaction_status in ( 'AAA8', 'AAA1', 'AAA4' ) then
                                l_substantiate_flag := 'N';
                            end if;

                        end if;
                    end loop;
                end if;

                l_claim_id := null;
                insert into claimn (
                    claim_id,
                    pers_id,
                    pers_patient,
                    claim_code,
                    prov_name,
                    claim_date_start,
                    tax_code,
                    service_status,
                    claim_amount,
                    claim_paid,
                    claim_pending,
                    service_type,
                    note,
                    claim_status,
                    entrp_id,
                    plan_start_date,
                    plan_end_date,
                    approved_amount,
                    approved_date,
                    claim_date_end,
                    service_start_date,
                    service_end_date,
                    pay_reason,
                    claim_source,
                    payment_release_date,
                    creation_date,
                    last_update_date,
                    unsubstantiated_flag,
                    mcc_code
                ) values ( doc_seq.nextval,
                           x.pers_id,
                           x.pers_id,
                           x.claim_code || x.settlement_date,
                           x.merchant_name,
                           nvl(to_date(substr(x.settlement_date, 1, 8),
                               'YYYYMMDD'),
                               to_date(substr(x.transaction_date, 1, 8),
                               'YYYYMMDD')),
                           1,
                           2,
                           x.transaction_amount,
                           x.transaction_amount,
                           0,
                           x.plan_type,
                           'Debit Card Claim Created for '
                           || x.settlement_seq_number
                           || '('
                           || to_char(sysdate, 'yyyymmdd')
                           || ')',
                           l_claim_status,
                           x.entrp_id,
                           to_date(substr(x.plan_start_date, 1, 8),
                                   'YYYYMMDD'),
                           to_date(substr(x.plan_end_date, 1, 8),
                                   'YYYYMMDD'),
                           x.transaction_amount,
                           to_date(x.transaction_date, 'yyyymmddhh24miss'),
                           nvl(to_date(substr(x.settlement_date, 1, 8),
                               'YYYYMMDD'),
                               to_date(substr(x.transaction_date, 1, 8),
                               'YYYYMMDD')) -- CLAIM_DATE_END
                               ,
                           nvl(to_date(substr(x.settlement_date, 1, 8),
                               'YYYYMMDD'),
                               to_date(substr(x.transaction_date, 1, 8),
                               'YYYYMMDD')) -- SERVICE_START_DATE
                               ,
                           nvl(to_date(substr(x.settlement_date, 1, 8),
                               'YYYYMMDD'),
                               to_date(substr(x.transaction_date, 1, 8),
                               'YYYYMMDD')) -- SERVICE_END_DATE
                               ,
                           13,
                           'DEBIT_CARD',
                           to_date(x.settlement_date, 'yyyymmddhh24miss'),
                           sysdate,
                           sysdate,
                           l_substantiate_flag,
                           x.mcc_code ) returning claim_id into l_claim_id;
    --       PC_LOG.LOG_ERROR('SETTLEMENTS,L_CLAIM_ID',L_CLAIM_ID);
                if l_claim_id is not null then
                    update metavante_settlements
                    set
                        created_claim = 'Y',
                        claim_id = l_claim_id
                    where
                            settlement_number || transaction_date = x.settlement_seq_number || x.transaction_date
                        and acc_num = x.employee_id;
                      -- Add this when we go live with debit card project

                    if
                        x.account_type in ( 'HRA', 'FSA' )
                        and l_substantiate_flag = 'Y'
                    then
                        pc_notifications.debit_letter_notification(x.pers_id, x.acc_id, 'FIRST_LETTER', 0      --System User ID
                        , l_claim_id);

                    end if;

                    if
                        x.card_number is not null
                        and is_number(x.card_number) = 'Y'
                    then
                        l_card_number := to_number ( substr(x.card_number, 13, 4) );
                    end if;

                    insert into payment (
                        change_num,
                        acc_id,
                        pay_date,
                        amount,
                        reason_code,
                        claimn_id,
                        note,
                        debit_card_posted,
                        plan_type,
                        paid_date,
                        pay_num
                    ) values ( change_seq.nextval,
                               x.acc_id,
                               least(
                                   nvl(to_date(substr(x.settlement_date, 1, 8),
                                       'YYYYMMDD'),
                                       to_date(substr(x.transaction_date, 1, 8),
                                       'YYYYMMDD')),
                                   to_date(substr(x.plan_end_date, 1, 8),
                                     'YYYYMMDD')
                               ),
                               x.transaction_amount,
                               13,
                               l_claim_id,
                               'Debit Card Claim (Claim ID:'
                               || l_claim_id
                               || ') created on '
                               || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                               'Y',
                               x.plan_type,
                               nvl(to_date(substr(x.settlement_date, 1, 8),
                                   'YYYYMMDD'),
                                   to_date(substr(x.transaction_date, 1, 8),
                                   'YYYYMMDD'))
            -- ,l_card_number);
                                   ,
                               x.settlement_seq_number
                               || substr(x.transaction_date, 1, 8) ); -- changed from card number so that the transactions can be unique in GP

                    pc_fin.card_claim_fee(x.acc_id, l_claim_id, 'MBI');
                    l_transaction_count := l_transaction_count + 1;
                end if;

            exception
                when others then
            -- ROLLBACK;
           --   PC_LOG.LOG_ERROR('SETTLEMENTS',X.SETTLEMENT_SEQ_NUMBER);

                    l_utl_id := utl_file.fopen('DEBIT_LOG_DIR', l_file_name, 'w');
                    l_sqlerrm := sqlerrm;
                    insert_alert('Error in settlement file ', l_sqlerrm
                                                              || ' for settlement_seq_number '
                                                              || x.settlement_seq_number
                                                              || ' and account number '
                                                              || x.employee_id);

                    dbms_output.put_line('error message '
                                         || l_sqlerrm
                                         || 'settlement_seq_number '
                                         || x.settlement_seq_number);
           /* mail_utility.send_email('metavante@sterlingadministration.com'
                   ,'vanitha.subramanyam@sterlingadministration.com'
                   ,'Error in Posting  Settlement Records'
                   ,l_sqlerrm);*/
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_sqlerrm
                    );
                    utl_file.fclose(file => l_utl_id);
            end;
        end loop;

        dbms_output.put_line('l_transaction_count ' || l_transaction_count);
    exception
        when l_processed then
            null;
        when l_create_error then
            rollback;
            x_error_message := l_sqlerrm;
            insert_alert('Error in settlement file ', l_sqlerrm);
            x_error_status := 'E';
        when others then
            rollback;
            l_sqlerrm := sqlerrm;
            insert_alert('Error in settlement file ', l_sqlerrm);

       /** send email alert as soon as it fails **/

            x_error_status := 'E';
    end;

    procedure process_er_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    ) is

        l_sqlerrm varchar2(32000);
        l_sql     varchar2(32000);
        l_exists  varchar2(30) := 'N';
        l_create_error exception;
        l_count   number := 0;
        l_processed exception;
    begin
        --  l_sql :=  'ALTER TABLE METAVANTE_RESULT_EXTERNAL LOCATION (';
        select
            count(*)
        into l_count
        from
            metavante_files
        where
                result_flag = 'Y'
            and file_name = replace(p_file_name, '.res', '.mbi');

        if l_count > 0 then
            raise l_processed;
        end if;
        if file_length(p_file_name) > 0 then
            l_sql := l_sql
                     || 'DEBIT_CARD_DIR:'''
                     || p_file_name
                     || ''',';
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(p_file_name, '.res', '.mbi');

        end if;

        if l_exists = 'N' then
            null;
        else
            l_sql := 'ALTER TABLE METAVANTE_ER_RESULT_EXTERNAL LOCATION ('
                     || rtrim(l_sql, ',')
                     || ')';
            begin
                execute immediate l_sql;
            exception
                when others then
                    rollback;
                    l_sqlerrm := 'Error when altering table ' || sqlerrm;
                    insert_alert('Error in result file ' || p_file_name, l_sqlerrm);
                    raise l_create_error;

       /** send email alert as soon as it fails **/

            end;

            l_sqlerrm := null;
            begin
                for x in (
                    select
                        count(*) cnt
                    from
                        metavante_er_result_external
                ) loop
                    if x.cnt = 0 then
                        l_sqlerrm := 'no result files found';
                    end if;
                end loop;
            exception
                when others then
                    l_sqlerrm := 'Error when checking contents in external table ' || sqlerrm;
                    insert_alert('Error in result file ' || p_file_name, l_sqlerrm);
                    raise l_create_error;
                    dbms_output.put_line('sql error message ' || l_sqlerrm);
            end;

                /*** Employer Creation Failures **/
            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    null,
                    decode(record_id, 'RS', 'Employer Demographic Creation', 'RU', 'Employer Plan'),
                    b.error_description,
                    null,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_er_result_external a,
                    metavante_error_codes        b,
                    account                      c
                where
                    record_id in ( 'RS', 'RU' )
                    and c.entrp_id is not null
                    and c.acc_num like '%' || a.employer_id
                    and detail_resp_code <> '0'
                    and a.detail_resp_code = to_char(b.error_id);

            for x in (
                select
                    *
                from
                    metavante_er_result_external a
                where
                        a.record_id = 'RS'
                    and a.detail_resp_code = '0'
            ) loop
                update account
                set
                    bps_acc_num = 'STL' || x.employer_id
                where
                    acc_num like '%' || x.employer_id
                    and entrp_id is not null;

            end loop;

            for x in (
                select
                    *
                from
                    metavante_er_result_external a
                where
                        a.record_id = 'RU'
                    and a.detail_resp_code = '0'
            ) loop
                update ben_plan_enrollment_setup
                set
                    created_in_bps = 'Y'
                where
                    ben_plan_id = x.record_tracking_no;

            end loop;

        end if;

        x_error_message := l_sqlerrm;
    exception
        when l_processed then
            null;
        when l_create_error then
            x_error_message := l_sqlerrm;
            insert_alert('Error in result file ' || p_file_name, l_sqlerrm);
       /** send email alert as soon as it fails **/

        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in result file ' || p_file_name, l_sqlerrm);

       /** send email alert as soon as it fails **/

    end process_er_result;

    procedure process_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    ) is

        l_sqlerrm       varchar2(32000);
        l_sql           varchar2(32000);
        l_exists        varchar2(30) := 'N';
        l_create_error exception;
        l_count         number := 0;
        l_action        varchar2(30);
        l_processed exception;
        l_file_id       number;
        l_error_message varchar2(32000);
    begin
        --  l_sql :=  'ALTER TABLE METAVANTE_RESULT_EXTERNAL LOCATION (';
        select
            count(*)
        into l_count
        from
            metavante_files
        where
                result_flag = 'Y'
            and file_name = replace(p_file_name, '.res', '.mbi');

        if l_count > 0 then
            raise l_processed;
        end if;
        if file_length(p_file_name) > 0 then
            l_sql := l_sql
                     || 'DEBIT_CARD_DIR:'''
                     || p_file_name
                     || ''',';
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(p_file_name, '.res', '.mbi')
            returning file_id,
                      file_action into l_file_id, l_action;

        end if;

        if l_exists = 'N' then
            null;
        else
            l_sql := 'ALTER TABLE METAVANTE_RESULT_EXTERNAL LOCATION ('
                     || rtrim(l_sql, ',')
                     || ')';
            begin
                execute immediate l_sql;
            exception
                when others then
                    rollback;
                    l_sqlerrm := 'Error when altering table ' || sqlerrm;
                    insert_alert('Error in result file ' || p_file_name, l_sqlerrm);
                    raise l_create_error;

       /** send email alert as soon as it fails **/

            end;

            l_sqlerrm := null;
            begin
                for x in (
                    select
                        count(*) cnt
                    from
                        metavante_result_external
                ) loop
                    if x.cnt = 0 then
                        l_sqlerrm := 'no result files found';
                    end if;
                end loop;
            exception
                when others then
                    l_sqlerrm := 'Error when checking contents in external table ' || sqlerrm;
                    raise l_create_error;
                    dbms_output.put_line('sql error message ' || l_sqlerrm);
            end;

                /*** Card Creation Failures **/
            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Card Creation',
                    b.error_description,
                    case
                        when record_id in ( 'RB', 'RF' ) then
                            attribute2
                    end,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                    record_id in ( 'RB', 'RF' )
                    and a.employee_id = c.acc_num
                    and attribute1 not in ( '0', '20005' )
                    and ( ( record_id in ( 'RB', 'RF' )
                            and a.attribute1 = to_char(b.error_id) ) );

                /*** Card Creation Failures **/
            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Card Creation',
                    b.error_description,
                    case
                        when record_id = 'RC' then
                            attribute4
                    end,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                        record_id = 'RC'
                    and a.employee_id = c.acc_num
                    and attribute4 <> '0'
                    and c.account_type = 'HSA'
                    and ( record_id = 'RC'
                          and a.attribute4 = to_char(b.error_id) );
            /*** Card Creation Failures **/
            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    decode(
                        substr(attribute7, 1, 4),
                        'ALEC',
                        'Annual Election',
                        'Card Creation'
                    ),
                    b.error_description,
                    case
                        when record_id = 'RC' then
                            substr(attribute7, 6, 20)
                    end,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                        record_id = 'RC'
                    and a.employee_id = c.acc_num
                    and attribute4 <> '0'
                    and c.account_type <> 'HSA'
                    and ( record_id = 'RC'
                          and a.attribute4 = to_char(b.error_id) );
                /** Lost/Stolen Card Order Failures ***/
            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Lost/Stolen Card Order',
                    b.error_description,
                    attribute2,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                        record_id = 'RF'
                    and a.employee_id = c.acc_num
                    and substr(attribute2, 1, 4) = 'LOST'
                    and attribute1 <> '0'
                    and a.attribute1 = to_char(b.error_id);

             /** Status Updates ***/

            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    decode(
                        substr(a.attribute2, 1, 4),
                        'USUS',
                        'Unsuspend',
                        'TERM',
                        'Termination',
                        'LOST',
                        'Lost/Stolen'
                    ),
                    b.error_description error_description,
                    a.attribute2,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                        record_id = 'RJ'
                    and attribute1 <> '0'
                    and a.attribute1 = b.error_id
                    and error_id not in ( 1, 17, 18 )
                    and substr(a.attribute2,
                               10,
                               (length(a.attribute2) - 8)) = c.acc_num;

                /** Termination Failures **/

            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Termination',
                    b.error_description,
                    attribute2,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                        record_id = 'RC'
                    and a.employee_id = c.acc_num
                    and substr(attribute5, 1, 4) = 'TERM'
                    and attribute4 <> '0'
                    and a.attribute4 = to_char(b.error_id);

                /** Address Update Failures **/

            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Address Update',
                    b.error_description,
                    attribute2,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                        record_id = 'RB'
                    and a.employee_id = c.acc_num
                    and substr(attribute2, 1, 4) = 'DEMG'
                    and attribute1 <> '0'
                    and a.attribute1 = to_char(b.error_id);

                   /**** Income Processing ****/

            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    c.acc_num,
                    'Receipt',
                    'Record num '
                    || d.change_num
                    || ':'
                    || b.error_description,
                    a.attribute8,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c,
                    income                    d
                where
                        a.record_id = 'RH'
                    and a.attribute8 not like 'ALEC%'
                    and a.attribute8 not like 'REFUND%'
                    and d.change_num = a.attribute8
                    and a.attribute7 <> '0'
                    and a.attribute7 = b.error_id
                    and d.acc_id = c.acc_id;

                   /**** Payment Processing ****/

            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    c.acc_num,
                    'Payment',
                    b.error_description,
                    a.attribute2,
                    sysdate,
                    sysdate,
                    null,
                    p_file_name
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c,
                    payment                   d
                where
                        a.record_id = 'RI'
                    and d.change_num = a.attribute2
                    and a.attribute1 <> '0'
                    and a.attribute1 = b.error_id
                    and d.acc_id = c.acc_id;

           /* FOR X IN (SELECT    c.acc_num
                     ,  b.error_description
                    ,  a.attribute2
                    ,  d.amount
                    ,  d.pay_date
                    ,  d.note
                  FROM metavante_result_external a
                       , metavante_error_codes b
                       , account c
                       , payment d
                  WHERE  a.record_id = 'RI'
                    AND  d.change_num = a.attribute2
                    AND  a.attribute1 <> '0'
                    AND  a.attribute1 = b.error_id
                    AND  d.acc_id  = c.acc_id)
            LOOP
                  l_error_message := '<p>
                                   Account number :'||x.acc_num ||'<br>'||
                                  'Payment Amount :'||x.amount||'<br>'||
                                  'Payment Date   :'||x.pay_date||'<br>'||
                                  'Note :' ||x.note||'<br>'||
                                  'Error from BPS :'|| x.error_description||'</p>';
              pc_debit_card.insert_alert('Metavante Payment Posting Errors'
                 ,l_error_message);
            END LOOP;*/
            update_card_notes('SUBSCRIBER');
            if l_action = 'DEPOSIT' then
                pc_notifications.email_hsa_receipt_error;
            end if;
            if l_action = 'PAYMENT' then
                pc_notifications.email_hsa_payment_error;
            end if;
            if l_action = 'HRA_FSA_CLAIM' then
              -- pc_notifications.email_hrafsa_payment_error;
                null;
            end if;
            if l_action = 'HRA_FSA_DEPOSIT' then
              -- pc_notifications.email_hrafsa_payment_error;
                null;
            end if;
        end if;

        x_error_message := l_sqlerrm;
    exception
        when l_processed then
            null;
        when l_create_error then
            x_error_message := l_sqlerrm;
            dbms_output.put_line('error messahe ' || l_sqlerrm);
            insert_alert('Error in result file ' || p_file_name, l_sqlerrm);

       /** send email alert as soon as it fails **/

        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('error messahe ' || l_sqlerrm);
            insert_alert('Error in result file ' || p_file_name, l_sqlerrm);

       /** send email alert as soon as it fails **/

    end process_result;

    procedure migrate_cards is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl card_creation_tab;
        l_sqlerrm         varchar2(32000);
    begin
        l_file_name := 'MB2_'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '_create.mbi';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            acc_num    employee_id,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            '20090812' start_date,
            null       start_time,
            null       email,
            null,
            null,
            null,
            null,
            'N',
            '1'
        bulk collect
        into l_card_create_tbl
        from
            account    a,
            card_debit c
        where
            c.card_number is not null
            and a.pers_id = c.card_id;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count > 0 then
            l_line := 'IA'
                      || ','
                      || to_char((l_card_create_tbl.count) + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Card_Creation'
                      || ','
                      || 'STL_Result_Card_Creation'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        l_line := null;

     /*  FOR i IN 1 .. l_card_create_tbl.COUNT
       LOOP
           l_line := 'IB'                    -- Record ID
                ||','||G_TPA_ID                             -- TPA ID
            ||','||G_EMPLOYER_ID                        -- Employer ID
            ||','||l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
            ||','||l_card_create_tbl(i).last_name       -- Last Name
            ||','||l_card_create_tbl(i).first_name      -- First Name
            ||','||l_card_create_tbl(i).middle_name     -- Middle Name
            ||','||l_card_create_tbl(i).address         -- Address
            ||','||l_card_create_tbl(i).city            -- City
            ||','||l_card_create_tbl(i).state           -- State
            ||','||l_card_create_tbl(i).zip             -- Zip
                    ||','||'US'                                 -- Country
            ||','||'2'                                  -- Employee Status, 2 - Active
            ||','||l_card_create_tbl(i).gender          -- Gender
            ||','||l_card_create_tbl(i).birth_date      -- Birth Date
            ||','||'1'                                  -- HDHP eligible , 1 - Yes
            ||','||l_card_create_tbl(i).drivlic         -- Employee Driver License
            ||',CNEW_'||l_card_create_tbl(i).employee_id    -- Record Tracking Number
        ||','||l_card_create_tbl(i).email;            -- Email Address

           UTL_FILE.PUT_LINE( file   => l_utl_id
                            , buffer => l_line );

       END LOOP;*/

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IC'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || g_plan_id                        -- Plan ID
                      || ','
                      || l_card_create_tbl(i).employee_id        -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || g_plan_start_date                -- Plan Start Date
                      || ','
                      || g_plan_end_date                -- Plan End Date
                      || ','
                      || '2'                        -- Account Status , 2 - Active
                      || ','
                      || '0'                        -- Employee Pay Period Election
                      || ','
                      || '0'                        -- Employer Pay Period Election
                      || ','
                      || l_card_create_tbl(i).start_date           -- Effective Date
                      || ','
                      || '1'                        -- E-Signature Flag , 1 - Yes
                      || ','
                      || l_card_create_tbl(i).start_date        -- E-Signature Date
                      || ','
                      || l_card_create_tbl(i).start_time              -- E-Signature Time
                      || ',CNEW_'
                      || l_card_create_tbl(i).employee_id;            -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
   /*    FOR i IN 1 .. l_card_create_tbl.COUNT
       LOOP
           l_line := 'IF'                                           -- Record ID
                ||','||G_TPA_ID                    -- TPA ID
            ||','||G_EMPLOYER_ID                -- Employer ID
                ||','||l_card_create_tbl(i).employee_id        -- Employee ID
            ||','||TO_CHAR(SYSDATE,'YYYYMMDD')              -- Issue Date
                    ||','||TO_CHAR(SYSDATE,'YYYYMMDD')              -- Card Effective Date
                    ||','||'1'                                      -- Shipping Address Code, 1 - Cardholder Address
                ||','||'2'                        -- Issue Card
            ||','||'1'                                      -- Shipping Method Code, 1 - US Mail
            ||',CNEW_'||l_card_create_tbl(i).employee_id;        -- Record Tracking Number

           UTL_FILE.PUT_LINE( file   => l_utl_id
                            , buffer => l_line );

       END LOOP;*/

        utl_file.fclose(file => l_utl_id);
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('metavante@sterlingadministration.com', 'techsupport@sterlingadministration.com', 'Error in Creating Card Creation File'
            , l_sqlerrm);
    end migrate_cards;

    procedure migrate_deposits is

        l_utl_id           utl_file.file_type;
        l_file_name        varchar2(3200);
        l_line             varchar2(32000);
        l_card_deposit_tbl amount_tab;
        l_sqlerrm          varchar2(32000);
    begin
        l_file_name := 'MB_'
                       || to_char(sysdate, 'YYYYMMDD')
                       || '_payment3_IH.mbi';
        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');

      /** Posting the deposits ***/
      /** IH record is for all deposits **/

        select
            *
        bulk collect
        into l_card_deposit_tbl
        from
            (
                select
                    b.acc_num,
                    5                            amount,
                    'Credit',
                    to_char(sysdate, 'YYYYMMDD') fee_date,
                    to_char(sysdate, 'YYYYMMDD')
                    || rownum
                from
                    card_balance_external a,
                    account               b
                where
                        a.employee_id = b.acc_num
                    and b.plan_code in ( 101, 201, 501, 1, 504 )
                    and trunc(pc_account.acc_balance(b.acc_id) - a.disbursable_balance) > 5
            );

        dbms_output.put_line('l_card_deposit_tbl.COUNT ' || l_card_deposit_tbl.count);
        if l_card_deposit_tbl.count > 0 then
            l_line := 'IA'
                      || ','
                      || to_char(l_card_deposit_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Deposit'
                      || ','
                      || 'STL_Result_Deposit'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_deposit_tbl.count loop
            l_line := 'IH'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_deposit_tbl(i).employee_id          -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || g_plan_start_date                -- Plan Start Date
                      || ','
                      || g_plan_end_date                             -- Plan End Date
                      || ','
                      || '1'                                         -- Deposit Type, 1 - Other
                      || ','
                      || l_card_deposit_tbl(i).amount               -- Employee Deposit Amount
                      || ','
                      || '0'                                         -- Employer Deposit Amount
--             ||','||G_PLAN_ID                                   -- Plan ID
                      || ','
                      || l_card_deposit_tbl(i).change_num          -- Record Tracking Number
                      || ','
                      || l_card_deposit_tbl(i).transaction_date    -- Display Date
                      || ','
                      || l_card_deposit_tbl(i).merchant_name;      -- Note

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        utl_file.fclose(file => l_utl_id);
        l_line := null;
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('metavante@sterlingadministration.com', 'techsupport@sterlingadministration.com', 'Error in Creating Deposit/Payment file'
            , l_sqlerrm);
    end migrate_deposits;

    procedure minimum_fee_adjustments (
        p_acc_num_list      in varchar2 default null,
        p_payment_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_payment_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_deposit_tbl  amount_tab;
        l_card_payment_tbl  amount_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
    begin
        l_line := null;
        l_file_id := null;

       /*** Posting disbursements ***/
       /** II is for all disbursements, pre auth and debit card purchases are excluded **/
       -- IF p_acc_num_list IS  NULL THEN

        select
            a.acc_num,
            - 2 * ( count(*) - 1 ) * amount amount,
            'Void Transaction',
            to_char(sysdate, 'YYYYMMDD'),
            change_num
        bulk collect
        into l_card_payment_tbl
        from
            metavante_adjustment_outbound a,
            account                       b
        where
            a.creation_date between '20-SEP-2012' and '23-SEP-2012'
            and a.acc_id = b.acc_id
            and ( a.acc_num not like 'HRA%'
                  and a.acc_num not like 'FSA%' )
        group by
            a.acc_num,
            a.change_num,
            a.amount,
            b.acc_id
        having count(*) > 1
               and pc_account.acc_balance_card(b.acc_id) + ( count(*) - 1 ) * a.amount = pc_account.acc_balance(b.acc_id);


        /*SELECT b.acc_num
             , a.disbursable_balance-pc_account.acc_balance(acc_id) amount
             , 'Minimum Balance'
             , to_char(sysdate,'YYYYMMDD')
             , null
                BULK COLLECT INTO l_card_payment_tbl
        from card_balance_external a, account b
        where  employee_id = b.acc_num
        and   a.disbursable_balance > pc_account.acc_balance(acc_id)
        and   pc_account.acc_balance(acc_id) > 0
        AND   b.account_type = 'HSA'
        AND   a.disbursable_balance-pc_account.acc_balance(acc_id)  = 20*/
    /*    and   a.disbursable_balance-pc_account.acc_balance(acc_id)
             <> nvl((select sum(amount) from payment where payment.acc_id = b.acc_id and trunc(pay_date) = trunc(sysdate)
                 and reason_code not in (22,13)),0)*/
      --  END IF;
        pc_log.log_error('minimum_fee_adjustments', 'count ' || l_card_payment_tbl.count);
        if l_card_payment_tbl.count > 0 then
            if p_payment_file_name is null then
                l_file_id := insert_file_seq('PAYMENT');
                l_payment_file_name := 'MB_'
                                       || l_file_id
                                       || '_payment.mbi';
            else
                l_payment_file_name := p_payment_file_name;
            end if;

            update metavante_files
            set
                file_name = l_payment_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_payment_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_payment_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Payment'
                      || ','
                      || 'STL_Result_Payment'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_payment_tbl.count loop
            l_line := 'II'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_payment_tbl(i).employee_id        -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || l_card_payment_tbl(i).merchant_name        -- Merchant Name
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service from
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service to
                      || ','
                      || l_card_payment_tbl(i).amount                -- Approved Claim Amount
        --     ||','||G_PLAN_START_DATE                           -- Plan Start Date
        --     ||','||G_PLAN_END_DATE                             -- Plan End Date
    --                 ||','||G_PLAN_ID                                   -- Plan ID
                      || ','
                      || l_card_payment_tbl(i).change_num;      -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_payment_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_payment_file_name := l_payment_file_name;
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            pc_log.log_error('minimum_fee_adjustments, sqlerror ', l_sqlerrm);
            mail_utility.send_email('metavante@sterlingadministration.com', 'techsupport@sterlingadministration.com', 'Error in Creating Deposit/Payment file'
            , l_sqlerrm);
    end minimum_fee_adjustments;

    procedure dep_card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl card_creation_dep_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_card_create exception;
        no_card_create exception;
    begin


        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        if p_acc_num_list is not null then
            select
                acc_num                     employee_id,
                dep.pers_id                 dep_id,
                '"'
                || substr(dep.last_name, 1, 26)
                || '"'                      last_name,
                '"'
                || substr(dep.first_name, 1, 19)
                || '"'                      first_name,
                '"'
                || substr(dep.middle_name, 1, 1)
                || '"'                      middle_name,
                '"'
                || b.address
                || '"'                      address,
                '"'
                || b.city
                || '"'                      city,
                '"'
                || b.state
                || '"'                      state,
                '"'
                || b.zip
                || '"'                      zip,
                decode(dep.relat_code, 2, 1, 3, 2,
                       9, 0)                relative,
                null,
                nvl(c.pin_mailer, '0')      pin_mailer,
                nvl(c.shipping_method, '1') shipping_method
            bulk collect
            into l_card_create_tbl
            from
                account    a,
                person     b,
                person     dep,
                card_debit c
            where
                    dep.card_issue_flag = 'Y'
                and a.account_type = 'HSA'
                and b.pers_id = dep.pers_main
                and dep.pers_id = c.card_id
                and a.pers_id = b.pers_id
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(str2tbl(p_acc_num_list) as varchar2_4000_tbl) )
                )
                and c.status = 1 -- Ready to Activate
                and trunc(a.start_date) <= trunc(sysdate + 10)
                and dep.last_name is not null
                and a.complete_flag = 1;
       -- AND   NOT EXISTS ( SELECT * FROM account WHERE PERS_ID = C.CARD_ID);
        else
            select
                acc_num                     employee_id,
                dep.pers_id                 dep_id,
                '"'
                || substr(dep.last_name, 1, 26)
                || '"'                      last_name,
                '"'
                || substr(dep.first_name, 1, 19)
                || '"'                      first_name,
                '"'
                || substr(dep.middle_name, 1, 1)
                || '"'                      middle_name,
                '"'
                || b.address
                || '"'                      address,
                '"'
                || b.city
                || '"'                      city,
                '"'
                || b.state
                || '"'                      state,
                '"'
                || b.zip
                || '"'                      zip,
                decode(dep.relat_code, 2, 1, 3, 2,
                       9, 0)                relative,
                null,
                nvl(c.pin_mailer, '0')      pin_mailer,
                nvl(c.shipping_method, '1') shipping_method
            bulk collect
            into l_card_create_tbl
            from
                account    a,
                person     b,
                person     dep,
                card_debit c
            where
                    dep.card_issue_flag = 'Y'
                and a.account_type = 'HSA'
                and b.pers_id = dep.pers_main
                and dep.pers_id = c.card_id
                and a.pers_id = b.pers_id
                and c.status = 1 -- Ready to Activate
                and trunc(a.start_date) <= trunc(sysdate)
                and dep.last_name is not null
                and a.complete_flag = 1
                and a.account_status = 1;
       -- AND   NOT EXISTS ( SELECT * FROM account WHERE PERS_ID = C.CARD_ID);
        end if;
       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 2000 then
                raise mass_card_create;
            else
                if p_file_name is null then
                    l_file_id := insert_file_seq('DEP_CARD_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_dep_create.mbi';
                    dbms_output.put_line('file id ' || l_file_id);
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char((l_card_create_tbl.count * 3) + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Dep_Card_Creation'
                          || ','
                          || 'STL_Result_Dep_Card_Creation'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'ID'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || g_employer_id                        -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                      || ','
                      || l_card_create_tbl(i).last_name       -- Last Name
                      || ','
                      || l_card_create_tbl(i).first_name      -- First Name
                      || ','
                      || l_card_create_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_card_create_tbl(i).address         -- Address
                      || ','
                      || l_card_create_tbl(i).city            -- City
                      || ','
                      || l_card_create_tbl(i).state           -- State
                      || ','
                      || l_card_create_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ','
                      || l_card_create_tbl(i).dep_id          -- Dependant ID
                      || ','
                      || l_card_create_tbl(i).relative        -- Relation
                      || ',CNEWDEP_'
                      || l_card_create_tbl(i).dep_id    -- Record Tracking Number
                      || ',,'; -- Birth date, SSN

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IE'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id        -- Employee ID
                      || ','
                      || l_card_create_tbl(i).dep_id           -- Dependant ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || g_plan_start_date                -- Plan Start Date
                      || ','
                      || g_plan_end_date                -- Plan End Date
                      || ',CNEWDEP_'
                      || l_card_create_tbl(i).dep_id;            -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IF'                                           -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id        -- Employee ID
                      || ','
                      || l_card_create_tbl(i).dep_id           -- Dependant ID
                      || ','
                      || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                      || ','
                      || '2'                        -- Issue Card
                      || ','
                      || l_card_create_tbl(i).shipping_method           -- Shipping Method Code, 1 - US Mail
                      || ',CNEWDEP_'
                      || l_card_create_tbl(i).dep_id            -- Record Tracking Number
                      || ','
                      || l_card_create_tbl(i).pin_mailer;               -- PIN mailer

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_file_name := l_file_name;
    exception
        when mass_card_create then
            insert_alert('ALERT!!!! Error in Creating Dependant Card Creation File', 'ALERT!!!! More than 200 dependant debit card creations are requested, verify before sending the request'
            );
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating Dependant Card Creation File', l_sqlerrm);
    end dep_card_creation;

    procedure dep_demographic_update (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_demographic_tbl card_creation_dep_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
    begin


        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        if p_acc_num_list is not null then
            select
                b.acc_num employee_id,
                c.pers_id dep_id,
                '"'
                || substr(c.last_name, 1, 26)
                || '"'    last_name,
                '"'
                || substr(c.first_name, 1, 19)
                || '"'    first_name,
                '"'
                || substr(c.middle_name, 1, 1)
                || '"'    middle_name,
                '"'
                || k.address
                || '"'    address,
                '"'
                || k.city
                || '"'    city,
                '"'
                || k.state
                || '"'    state,
                '"'
                || k.zip
                || '"'    zip,
                null,
                decode(d.account_type,
                       'HSA',
                       g_employer_id,
                       pc_entrp.get_bps_acc_num_from_acc_id(d.acc_id)),
                'N',
                '1'
            bulk collect
            into l_demographic_tbl
            from
                debit_card_updates b,
                person             c,
                account            d,
                card_debit         e,
                person             k
            where
                    b.pers_id = c.pers_main
                and c.pers_main = d.pers_id
                and c.pers_id = e.card_id
                and b.pers_id = k.pers_id
                and e.status_code in ( 1, 2, 3, 5 )
                and demo_changed = 'Y'
                and ( d.account_type = 'HSA'
                      or ( d.account_type in ( 'HRA', 'FSA' )
                           and pc_entrp.get_bps_acc_num_from_acc_id(d.acc_id) is not null ) )
                and k.first_name is not null
                and k.last_name is not null
                and k.address is not null
                and k.city is not null
                and k.state is not null
       --  AND   demo_processed = 'N'
                and b.update_id in (
                    select
                        max(update_id)
                    from
                        debit_card_updates f
                    where
                            f.acc_num = d.acc_num
                        and f.demo_changed = 'Y'
                );

        else
            select
                employee_id,
                dep_id,
                last_name,
                first_name,
                middle_name,
                address,
                city,
                state,
                zip,
                relative,
                employer_id,
                pin_mailer,
                shipping_method
            bulk collect
            into l_demographic_tbl
            from
                (
                    select
                        b.acc_num                                              employee_id,
                        c.pers_id                                              dep_id,
                        '"'
                        || substr(c.last_name, 1, 26)
                        || '"'                                                 last_name,
                        '"'
                        || substr(c.first_name, 1, 19)
                        || '"'                                                 first_name,
                        '"'
                        || substr(c.middle_name, 1, 1)
                        || '"'                                                 middle_name,
                        '"'
                        || k.address
                        || '"'                                                 address,
                        '"'
                        || k.city
                        || '"'                                                 city,
                        '"'
                        || k.state
                        || '"'                                                 state,
                        '"'
                        || k.zip
                        || '"'                                                 zip,
                        null                                                   relative,
                        decode(d.account_type,
                               'HSA',
                               g_employer_id,
                               pc_entrp.get_bps_acc_num_from_acc_id(d.acc_id)) employer_id,
                        'N'                                                    pin_mailer,
                        '1'                                                    shipping_method
                    from
                        debit_card_updates b,
                        person             c,
                        account            d,
                        card_debit         e,
                        person             k
                    where
                            b.pers_id = c.pers_main
                        and c.pers_main = d.pers_id
                        and c.pers_id = e.card_id
                        and b.pers_id = k.pers_id
                        and e.status_code in ( 1, 2, 3, 5 )
                        and demo_changed = 'Y'
                        and d.account_type in ( 'HRA', 'FSA', 'HSA' )
                 --  AND   demo_processed = 'N'
                        and b.update_id in (
                            select
                                max(update_id)
                            from
                                debit_card_updates f
                            where
                                    f.acc_num = d.acc_num
                                and f.demo_changed = 'Y'
                        )
                )
            where
                employer_id is not null;

        end if;

        if l_demographic_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('DEP_ADDRESS_UPDATE');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_dep_demog.mbi';
                dbms_output.put_line('file id ' || l_file_id);
            else
                l_file_name := p_file_name;
            end if;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_line := 'IA'
                      || ','
                      || to_char(l_demographic_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Dep_Address_Update'
                      || ','
                      || 'STL_Result_Dep_Address_Update'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IB record now, IB is for employee demographics ***/
        for i in 1..l_demographic_tbl.count loop
            l_line := 'ID'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || l_demographic_tbl(i).employer_id                -- Employer ID
                      || ','
                      || l_demographic_tbl(i).employee_id        -- Employee ID
                      || ','
                      || l_demographic_tbl(i).last_name        -- Last Name
                      || ','
                      || l_demographic_tbl(i).first_name        -- First Name
                      || ','
                      || l_demographic_tbl(i).middle_name        -- Middle Name
                      || ','
                      || l_demographic_tbl(i).city            -- City
                      || ','
                      || l_demographic_tbl(i).address            -- Address
                      || ','
                      || l_demographic_tbl(i).state            -- State
                      || ','
                      || l_demographic_tbl(i).zip            -- Zip
                      || ','
                      || 'US'
                      || ','
                      || l_demographic_tbl(i).dep_id                  -- Dependant ID
                      || ',DEMGDEP_'
                      || l_demographic_tbl(i).dep_id;   -- Record Tracking Number


            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_file_name := l_file_name;
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Dependant Demographic Update File', l_sqlerrm);
    end dep_demographic_update;

    procedure dep_lost_stolen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_if_file_name    varchar2(3200);
        l_line            varchar2(32000);
        l_lost_stolen_tbl lost_stolen_dep_tab;
        l_card_number_tbl varchar2_tab;
        l_dep_id_tbl      varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_lost_stolen exception;
        no_lost_stolen exception;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if p_acc_num_list is not null then
            select
                pc_person.acc_num(b.pers_main) employee_id,
                b.title                        prefix,
                '"'
                || substr(b.last_name, 1, 26)
                || '"'                         last_name,
                '"'
                || substr(b.first_name, 1, 19)
                || '"'                         first_name,
                '"'
                || substr(b.middle_name, 1, 1)
                || '"'                         middle_name,
                '"'
                || b.address
                || '"'                         address,
                '"'
                || b.city
                || '"'                         city,
                '"'
                || b.state
                || '"'                         state,
                '"'
                || b.zip
                || '"'                         zip,
                b.pers_id                      dependant_id,
                card_number,
                null,
                'N',
                nvl(c.shipping_method, '1')
            bulk collect
            into l_lost_stolen_tbl
            from
                account    a,
                person     b,
                card_debit c
            where
                    a.pers_id = b.pers_id
                and a.account_type = 'HSA'
                and c.card_id = b.pers_id
                and a.complete_flag = 1
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                );

        else
            select
                pc_person.acc_num(b.pers_main) employee_id,
                b.title                        prefix,
                '"'
                || substr(b.last_name, 1, 26)
                || '"'                         last_name,
                '"'
                || substr(b.first_name, 1, 19)
                || '"'                         first_name,
                '"'
                || substr(b.middle_name, 1, 1)
                || '"'                         middle_name,
                '"'
                || d.address
                || '"'                         address,
                '"'
                || d.city
                || '"'                         city,
                '"'
                || d.state
                || '"'                         state,
                '"'
                || d.zip
                || '"'                         zip,
                b.pers_id                      dependant_id,
                card_number,
                decode(e.account_type,
                       'HSA',
                       g_employer_id,
                       pc_entrp.get_bps_acc_num_from_acc_id(e.acc_id)),
                'N',
                nvl(c.shipping_method, '1')
            bulk collect
            into l_lost_stolen_tbl
            from
                person     b,
                card_debit c,
                person     d,
                account    e
            where
                    c.card_id = b.pers_id
            --AND  e.account_type = 'HSA'
                and c.status = 5 -- lost/stolen
                and c.status_code <> 5
                and b.pers_main = d.pers_id
                and b.pers_main is not null
                and e.pers_id = d.pers_id
                and e.account_status = 1
                and e.complete_flag = 1
                and e.account_type in ( 'HRA', 'FSA', 'HSA' )
                and c.card_number is not null;

        end if;

        l_line := null;
        dbms_output.put_line('l_lost_stolen_tbl.count ' || l_lost_stolen_tbl.count);
        if l_lost_stolen_tbl.count = 0 then
            raise no_lost_stolen;
        else
            if l_lost_stolen_tbl.count > 50 then
                raise mass_lost_stolen;
            else
                dbms_output.put_line('l_lost_stolen_tbl.count ' || l_lost_stolen_tbl.count);
                if p_file_name is null then
                    l_file_id := insert_file_seq('DEP_LOST');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_dep_lost.mbi';
                    dbms_output.put_line('file id ' || l_file_id);
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char((l_lost_stolen_tbl.count * 2) + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Dep_Lost_Stolen'
                          || ','
                          || 'STL_Result_Dep_Lost_Stolen'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        for i in 1..l_lost_stolen_tbl.count loop
            l_line := 'ID'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || l_lost_stolen_tbl(i).employer_id    -- Employer ID
                      || ','
                      || l_lost_stolen_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                      || ','
                      || l_lost_stolen_tbl(i).last_name       -- Last Name
                      || ','
                      || l_lost_stolen_tbl(i).first_name      -- First Name
                      || ','
                      || l_lost_stolen_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_lost_stolen_tbl(i).address         -- Address
                      || ','
                      || l_lost_stolen_tbl(i).city            -- City
                      || ','
                      || l_lost_stolen_tbl(i).state           -- State
                      || ','
                      || l_lost_stolen_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ','
                      || l_lost_stolen_tbl(i).dependant_id    -- dependant_id
                      || ',LOST_'
                      || l_lost_stolen_tbl(i).dependant_id;    -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;
       /*** Writing IJ record now, IJ is for lost/stolen ***/
        for i in 1..l_lost_stolen_tbl.count loop
            l_line := 'IJ'                                     -- Record ID
                      || ','
                      || g_tpa_id                           -- TPA ID
                      || ','
                      || l_lost_stolen_tbl(i).employer_id                     -- Employer ID
                      || ','
                      || l_lost_stolen_tbl(i).card_number              -- dont have card number what to do
                      || ','
                      || '5'                                -- Card Status, 5 -lost/stolen
                      || ','
                      || '11'                               -- Card Status Change Reason, 11 - Cardholder lost the card
                      || ','
                      || '1'                                -- Issue Card
                      || ',LOSTDEP_'
                      || to_char(sysdate, 'MMDD')
                      || l_lost_stolen_tbl(i).dependant_id; -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_lost_stolen then
            insert_alert('ALERT!!! Not Sending Lost/Stolen File', 'ALERT!!!! More than 50 dependant cards have been set to lost/stolen, verify before sending the request'
            );
        when no_lost_stolen then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sql error message ' || l_sqlerrm);
            insert_alert('Error in Creating Dependant Lost Stolen File', l_sqlerrm);
    end dep_lost_stolen;

    procedure dep_lost_stolen_reorder (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2,
        p_if_file_name in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_if_file_name    varchar2(3200);
        l_line            varchar2(32000);
        l_lost_stolen_tbl lost_stolen_dep_tab;
        l_card_number_tbl varchar2_tab;
        l_dep_id_tbl      varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        l_count           number;
        mass_lost_stolen exception;
        no_lost_stolen exception;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        select
            count(*)
        into l_count
        from
            cards_external;

        if l_count = 0 then
            insert_alert('Card Detail file doesnt have any data, cannot process lost/stolen reorder card', l_sqlerrm);
        else
      /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

            if p_acc_num_list is not null then
                select
                    pc_person.acc_num(b.pers_main) employee_id,
                    b.title                        prefix,
                    '"'
                    || substr(b.last_name, 1, 26)
                    || '"'                         last_name,
                    '"'
                    || substr(b.first_name, 1, 19)
                    || '"'                         first_name,
                    '"'
                    || substr(b.middle_name, 1, 1)
                    || '"'                         middle_name,
                    '"'
                    || b.address
                    || '"'                         address,
                    '"'
                    || b.city
                    || '"'                         city,
                    '"'
                    || b.state
                    || '"'                         state,
                    '"'
                    || b.zip
                    || '"'                         zip,
                    b.pers_id                      dependant_id,
                    card_number,
                    null,
                    nvl(c.pin_mailer, '0')         pin_mailer,
                    nvl(c.shipping_method, '1')
                bulk collect
                into l_lost_stolen_tbl
                from
                    account    a,
                    person     b,
                    card_debit c
                where
                        a.pers_id = b.pers_id
                    and c.card_id = b.pers_id
                    and a.complete_flag = 1
                    and a.account_type = 'HSA'
                    and a.acc_num in (
                        select
                            *
                        from
                            table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                    );

            else
                select
                    pc_person.acc_num(b.pers_main) employee_id,
                    b.title                        prefix,
                    '"'
                    || substr(b.last_name, 1, 26)
                    || '"'                         last_name,
                    '"'
                    || substr(b.first_name, 1, 19)
                    || '"'                         first_name,
                    '"'
                    || substr(b.middle_name, 1, 1)
                    || '"'                         middle_name,
                    '"'
                    || d.address
                    || '"'                         address,
                    '"'
                    || d.city
                    || '"'                         city,
                    '"'
                    || d.state
                    || '"'                         state,
                    '"'
                    || d.zip
                    || '"'                         zip,
                    b.pers_id                      dependant_id,
                    card_number,
                    decode(e.account_type,
                           'HSA',
                           g_employer_id,
                           pc_entrp.get_bps_acc_num_from_acc_id(e.acc_id)),
                    nvl(c.pin_mailer, '0')         pin_mailer,
                    nvl(c.shipping_method, '1')
                bulk collect
                into l_lost_stolen_tbl
                from
                    person     b,
                    card_debit c,
                    person     d,
                    account    e
                where
                        c.card_id = b.pers_id
                    and c.status = 5 -- lost/stolen
                    and c.status_code = 5
                    and b.pers_main = d.pers_id
                    and e.pers_id = d.pers_id
                    and b.pers_main is not null
                    and e.account_status = 1
                    and e.complete_flag = 1
                    and c.card_number is not null
                    and e.account_type in ( 'HRA', 'FSA', 'HSA' )
           -- AND e.account_type = 'HSA'
                    and decode(e.account_type,
                               'HSA',
                               g_employer_id,
                               pc_entrp.get_bps_acc_num_from_acc_id(e.acc_id)) is not null
                    and 0 = (
                        select
                            count(*)
                        from
                            cards_external
                        where
                                dependant_id = to_char(c.card_id)
                            and ( dependant_id is null
                                  or is_number(dependant_id) = 'Y' )
                            and employee_id = e.acc_num
                            and status_code in ( 1, 2 )
                    );

            end if;

            l_line := null;
            l_file_id := null;
            if l_lost_stolen_tbl.count = 0 then
                raise no_lost_stolen;
            else
                if l_lost_stolen_tbl.count > 150 then
                    raise mass_lost_stolen;
                else
                    if p_if_file_name is null then
                        l_file_id := insert_file_seq('DEP_LOST_IF');
                        l_if_file_name := 'MB_'
                                          || l_file_id
                                          || '_dep_lost_IF.mbi';
                        dbms_output.put_line('file id ' || l_file_id);
                    else
                        l_if_file_name := p_if_file_name;
                    end if;

                    update metavante_files
                    set
                        file_name = l_if_file_name
                    where
                        file_id = l_file_id;

                    l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_if_file_name, 'w');
                    dbms_output.put_line('l_lost_stolen_tbl.count ' || l_lost_stolen_tbl.count);
                    l_line := 'IA'
                              || ','
                              || to_char((l_lost_stolen_tbl.count * 1) + 1)
                              || ','
                              || g_edi_password
                              || ','
                              || 'STL_Import_Dep_Lost_Stolen'
                              || ','
                              || 'STL_Result_Dep_Lost_Stolen'
                              || ','
                              || 'Standard Result Template';

                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;
            end if;
       /*** Writing IF record now, IF is for lost/stolen ***/
            for i in 1..l_lost_stolen_tbl.count loop
                l_line := 'IF'                        -- Record ID
                          || ','
                          || g_tpa_id                    -- TPA ID
                          || ','
                          || l_lost_stolen_tbl(i).employer_id                -- Employer ID
                          || ','
                          || l_lost_stolen_tbl(i).employee_id            -- Employee ID
                          || ','
                          || l_lost_stolen_tbl(i).dependant_id                        -- Dependant ID
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || '2'                        -- Issue Card
                          || ','
                          || l_lost_stolen_tbl(i).shipping_method                                      -- Shipping Method Code, 1 - US Mail
                          || ',LOSTDEP_'
                          || to_char(sysdate, 'MMDD')
                          || l_lost_stolen_tbl(i).dependant_id        -- Record Tracking Number
                          || ','
                          || l_lost_stolen_tbl(i).pin_mailer;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

            if l_if_file_name is not null then
                utl_file.fclose(file => l_utl_id);
                p_if_file_name := l_if_file_name;
            end if;

        end if;

    exception
        when mass_lost_stolen then
            insert_alert('ALERT!!! Not Sending Lost/Stolen File', 'ALERT!!!! More than 50 depdendant cards have been set to lost/stolen, verify before sending the request'
            );
        when no_lost_stolen then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sql error message ' || l_sqlerrm);
            insert_alert('Error in Creating Dependant Lost Stolen Reorder File', l_sqlerrm);
    end dep_lost_stolen_reorder;

    procedure dep_suspend (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_suspend_tbl     varchar2_tab;
        l_card_number_tbl varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        l_pers_id_tbl     number_tab;
        l_bps_acc_num     varchar2(255);
    begin
        card_request_history(6, 'DEPENDANT');

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if p_acc_num_list is not null then
            select
                to_char(b.pers_id) dependant_id,
                c.card_number
            bulk collect
            into
                l_suspend_tbl,
                l_card_number_tbl
            from
                account    a,
                person     b,
                card_debit c
            where
                    a.pers_id = b.pers_main
                and a.account_type = 'HSA'
                and b.pers_id = c.card_id
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                );

        else
            select
                to_char(c.card_id) dependant_id,
                c.card_number,
                b.pers_main
            bulk collect
            into
                l_suspend_tbl,
                l_card_number_tbl,
                l_pers_id_tbl
            from
                card_debit c,
                person     b
            where
                    c.status = 6
                and c.card_id = b.pers_id
                and c.status_code not in ( 4, 5 )-- For fixing already lost card
                and c.card_number is not null
                and not exists (
                    select
                        *
                    from
                        account
                    where
                        pers_id = c.card_id
                );

        end if;

        l_line := null;
        if l_suspend_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('DEP_SUSPEND');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_dep_suspend.mbi';
                dbms_output.put_line('file id ' || l_file_id);
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_suspend_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Dep_Suspend'
                      || ','
                      || 'STL_Result_Dep_Suspend'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IJ record now, IJ is for lost/stolen ***/
        for i in 1..l_suspend_tbl.count loop
            l_bps_acc_num := null;
            for x in (
                select
                    pc_entrp.get_bps_acc_num(entrp_id) bps_acc_num
                from
                    person
                where
                    pers_id = l_pers_id_tbl(i)
            ) loop
                l_bps_acc_num := x.bps_acc_num;
            end loop;

            l_line := 'IJ'                   -- Record ID
                      || ','
                      || g_tpa_id               -- TPA ID
                      || ','
                      || nvl(l_bps_acc_num, g_employer_id)           -- Employer ID
                      || ','
                      || l_card_number_tbl(i)   -- dont have card number what to do
                      || ','
                      || '3'                   -- Card Status, 3 - Temporarily Inactive
                      || ','
                      || '6'                   -- Card Status Change Reason, 6 - Pending Card Holder Reimbursement
                      || ',SUSPDEP_'
                      || to_char(sysdate, 'MMDD')
                      || l_suspend_tbl(i);  -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            p_file_name := l_file_name;
            utl_file.fclose(file => l_utl_id);
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Dependant Suspended File', l_sqlerrm);
    end dep_suspend;

    procedure dep_unsuspend (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_unsuspend_tbl   varchar2_tab;
        l_card_number_tbl varchar2_tab;
        l_pers_id_tbl     number_tab;
        l_bps_acc_num     varchar2(255);
        l_bps_acc_num_tbl varchar2_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        card_request_history(7, 'DEPENDANT');
        select
            to_char(c.card_id) dependant_id,
            c.card_number,
            b.pers_main,
            decode(a.account_type,
                   'HSA',
                   g_employer_id,
                   pc_entrp.get_bps_acc_num(d.entrp_id))
        bulk collect
        into
            l_unsuspend_tbl,
            l_card_number_tbl,
            l_pers_id_tbl,
            l_bps_acc_num_tbl
        from
            card_debit c,
            person     b,
            account    a,
            person     d
        where
                c.status = 7 -- unsuspend
            and status_code not in ( 4, 5 )
            and c.card_id = b.pers_id
            and c.card_number is not null
            and b.pers_main = a.pers_id
            and a.account_status in ( 1, 2, 3 )
            and d.pers_id = a.pers_id
            and ( a.account_type = 'HSA'
                  or ( a.account_type in ( 'HRA', 'FSA' )
                       and pc_entrp.get_bps_acc_num(d.entrp_id) is not null ) )
            and not exists (
                select
                    *
                from
                    account
                where
                    pers_id = c.card_id
            );

        l_line := null;
        if l_unsuspend_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('DEP_UNSUSPEND');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_dep_unsuspend.mbi';
                dbms_output.put_line('file id ' || l_file_id);
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_unsuspend_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Dep_Unsuspend'
                      || ','
                      || 'STL_Result_Dep_Unsuspend'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IJ record now, IJ is for Unsuspend ***/
        for i in 1..l_unsuspend_tbl.count loop
            l_bps_acc_num := null;
            l_line := 'IJ'                                           -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || l_bps_acc_num_tbl(i)               -- Employer ID
                      || ','
                      || l_card_number_tbl(i)         -- dont have card number what to do
                      || ','
                      || '2'                        -- Card Status, 2 - Active
                      || ','
                      || '1'                        -- Card Status Change Reason, 1 - IVR
                      || ',USUSDEP_'
                      || to_char(sysdate, 'MMDD')
                      || l_unsuspend_tbl(i);        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            p_file_name := l_file_name;
            utl_file.fclose(file => l_utl_id);
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Dependant Unsuspend File', l_sqlerrm);
    end dep_unsuspend;

    procedure dep_terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id        utl_file.file_type;
        l_file_name     varchar2(3200);
        l_line          varchar2(32000);
        l_terminate_tbl dep_account_tab;
        l_sqlerrm       varchar2(32000);
        l_file_id       number;
        mass_terminate exception;
        no_terminate exception;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            acc_num            employee_id,
            to_char(
                nvl(a.end_date, sysdate),
                'YYYYMMDD'
            )                  end_date,
            to_char(b.pers_id) dependant_id,
            card_number,
            decode(a.account_type,
                   'HSA',
                   g_employer_id,
                   pc_entrp.get_bps_acc_num(d.entrp_id)),
            a.account_type
        bulk collect
        into l_terminate_tbl
        from
            account    a,
            card_debit c,
            person     b,
            person     d
        where
                a.pers_id = b.pers_main
            and d.pers_id = b.pers_main
            and a.pers_id = d.pers_id
            and b.pers_id = c.card_id
            and ( c.status = 3 ) -- Ready to Activate
            and c.terminated = 'N'
            and c.status_code <> 5
            and a.account_type in ( 'HRA', 'FSA', 'HSA' )
            and c.card_number is not null
            and not exists (
                select
                    *
                from
                    account k
                where
                    k.pers_id = c.card_id
            )
            and rownum < 1500;

        l_line := null;
        if l_terminate_tbl.count = 0 then
            raise no_terminate;
        else
            if l_terminate_tbl.count > 1500 then
                raise mass_terminate;
            else
                if p_file_name is null then
                    l_file_id := insert_file_seq('DEP_TERMINATE');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_dep_terminate.mbi';
                    dbms_output.put_line('file id ' || l_file_id);
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char((l_terminate_tbl.count * 2) + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Dep_Terminate'
                          || ','
                          || 'STL_Result_Dep_Terminate'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

       /*** Writing IC record now, IC is for employee account ***/
        for i in 1..l_terminate_tbl.count loop
            if l_terminate_tbl(i).account_type = 'HSA' then
                l_line := 'IE'                        -- Record ID
                          || ','
                          || g_tpa_id                    -- TPA ID
                          || ','
                          || g_employer_id                -- Employer ID
                          || ','
                          || l_terminate_tbl(i).employee_id        -- Employee ID
                          || ','
                          || l_terminate_tbl(i).dependant_id        -- Dependant ID
                          || ','
                          || 'HSA'                    -- Account Type Code
                          || ','
                          || g_plan_start_date                -- Plan Start Date
                          || ','
                          || g_plan_end_date                -- Plan End Date
                          || ','
                          || l_terminate_tbl(i).end_date            -- Termination Date
                          || ','
                          ||
                    case
                        when to_date ( l_terminate_tbl(i).end_date, 'YYYYMMDD' ) < sysdate then
                            '2'
                        else '5'
                    end                      -- Account Status , 5 - Terminated
                          || ',TERMDEP_'
                          || to_char(sysdate, 'MMDD')
                          || l_terminate_tbl(i).dependant_id;        -- Record Tracking Number

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end loop;

        for i in 1..l_terminate_tbl.count loop
            l_line := 'IJ'                   -- Record ID
                      || ','
                      || g_tpa_id               -- TPA ID
                      || ','
                      || l_terminate_tbl(i).employer_id           -- Employer ID
                      || ','
                      || l_terminate_tbl(i).card_number   -- dont have card number what to do
                      || ','
                      || '3'                   -- Card Status, 3 - Temporarily Inactive
                      || ','
                      || '6'                   -- Card Status Change Reason, 6 - Pending Card Holder Reimbursement
                      || ',TERM_'
                      || to_char(sysdate, 'MMDD')
                      || l_terminate_tbl(i).dependant_id;  -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IC record now, IC is for terminate ***/
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_terminate then
            insert_alert('ALERT!!!! Error in Creating Termination File', 'ALERT!!!! More than 1500 dependant debit card terminations are requested, verify before sending the request'
            );
        when no_terminate then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Dependant Termination File', l_sqlerrm);
    end dep_terminate;

    procedure dep_reopen (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id           utl_file.file_type;
        l_file_name        varchar2(3200);
        l_line             varchar2(32000);
        l_reopen_tbl       varchar2_tab;
        l_card_number_tbl  varchar2_tab;
        l_sqlerrm          varchar2(32000);
        l_dependant_id_tbl varchar2_tab;
        l_file_id          number;
    begin

       /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if p_acc_num_list is not null then
            select
                acc_num            employee_id,
                to_char(c.card_id) dependant_id,
                c.card_number
            bulk collect
            into
                l_reopen_tbl,
                l_dependant_id_tbl,
                l_card_number_tbl
            from
                account    a,
                card_debit c,
                person     b
            where
                    a.pers_id = b.pers_main
                and a.account_type = 'HSA'
                and b.pers_id = c.card_id
                and a.acc_num in (
                    select
                        *
                    from
                        table ( cast(in_list(p_acc_num_list) as varchar2_4000_tbl) )
                );

        else
            select
                acc_num            employee_id,
                to_char(c.card_id) dependant_id,
                c.card_number
            bulk collect
            into
                l_reopen_tbl,
                l_dependant_id_tbl,
                l_card_number_tbl
            from
                account    a,
                card_debit c,
                person     b
            where
                    a.pers_id = b.pers_main
                and b.pers_id = c.card_id
                and a.account_type = 'HSA'
                and c.status = 10 -- Reopen
                and a.account_status = 1
                and c.card_number is not null;

        end if;

        l_line := null;
        if l_reopen_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('DEP_REOPEN');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_dep_reopen.mbi';
                dbms_output.put_line('file id ' || l_file_id);
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char((l_reopen_tbl.count * 2) + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Dep_Reopen'
                      || ','
                      || 'STL_Result_Dep_Reopen'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IE record now, IC is for employee account ***/
        for i in 1..l_reopen_tbl.count loop
            l_line := 'IE'                    -- Record ID
                      || ','
                      || g_tpa_id                -- TPA ID
                      || ','
                      || g_employer_id            -- Employer ID
                      || ','
                      || l_reopen_tbl(i)              -- Employee ID
                      || ','
                      || l_dependant_id_tbl(i)              -- Depenant ID
                      || ','
                      || 'HSA'                -- Account Type Code
                      || ','
                      || g_plan_start_date            -- Plan Start Date
                      || ','
                      || g_plan_end_date            -- Plan End Date
                      || ','
                      || '2'                    -- Account Status , 2 - Active
                      || ',ROPNDEP_'
                      || to_char(sysdate, 'MMDD')
                      || l_dependant_id_tbl(i);        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        for i in 1..l_reopen_tbl.count loop
            l_line := 'IJ'                   -- Record ID
                      || ','
                      || g_tpa_id               -- TPA ID
                      || ','
                      || g_employer_id           -- Employer ID
                      || ','
                      || l_card_number_tbl(i)   -- dont have card number what to do
                      || ','
                      || '3'                   -- Card Status, 3 - Temporarily Inactive
                      || ','
                      || '6'                   -- Card Status Change Reason, 6 - Pending Card Holder Reimbursement
                      || ',TERM_'
                      || to_char(sysdate, 'MMDD')
                      || l_dependant_id_tbl(i);  -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IC record now, IC is for terminate ***/
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line(l_sqlerrm);
            insert_alert('Error in Creating Dependant Reopen File', l_sqlerrm);
    end dep_reopen;

    procedure process_vendor_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    ) is

        l_sqlerrm varchar2(32000);
        l_sql     varchar2(4000);
        l_exists  varchar2(30) := 'N';
        l_create_error exception;
        l_count   number := 0;
        l_processed exception;
    begin

        --  l_sql :=  'ALTER TABLE METAVANTE_DEP_RESULT_EXTERNAL LOCATION (';
        select
            count(*)
        into l_count
        from
            metavante_files
        where
                result_flag = 'Y'
            and file_name = replace(p_file_name, '.res', '.mbi');

        if l_count > 0 then
            raise l_processed;
        end if;
        l_sql := null;
        if file_length(p_file_name) > 0 then
            l_sql := 'DEBIT_CARD_DIR:'''
                     || p_file_name
                     || ''',';
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(p_file_name, '.res', '.mbi');

        end if;

        dbms_output.put_line('after file checking');
        if l_exists = 'N' then
            null;
        else
            l_sql := 'ALTER TABLE METAVANTE_RESULT_EXTERNAL LOCATION ('
                     || rtrim(l_sql, ',')
                     || ')';
            begin
                execute immediate l_sql;
            exception
                when others then
                    rollback;
                    l_sqlerrm := sqlerrm;
                    insert_alert('Error in creating results file ' || p_file_name, l_sqlerrm);
                    raise l_create_error;

       /** send email alert as soon as it fails **/

            end;

            dbms_output.put_line('after altering');
            l_sqlerrm := null;
            begin
                for x in (
                    select
                        count(*) cnt
                    from
                        metavante_result_external
                ) loop
                    if x.cnt = 0 then
                        l_sqlerrm := 'no result files found';
                    end if;
                end loop;
            exception
                when others then
                    l_sqlerrm := 'Error when checking contents in metavante_result_external external table ' || sqlerrm;
                    raise l_create_error;
                    dbms_output.put_line('sql error message ' || l_sqlerrm);
            end;

        end if;

        x_error_message := l_sqlerrm;
    exception
        when l_processed then
            null;
        when l_create_error then
            x_error_message := l_sqlerrm;
       /** send email alert as soon as it fails **/
            insert_alert('Error in processing results file' || p_file_name, l_sqlerrm);
        when others then
            l_sqlerrm := sqlerrm;
       /** send email alert as soon as it fails **/
            insert_alert('Error in processing results file' || p_file_name, l_sqlerrm);
    end process_vendor_result;

    procedure process_dependant_result (
        p_file_name     in varchar2,
        x_error_message out varchar2
    ) is

        l_sqlerrm varchar2(32000);
        l_sql     varchar2(4000);
        l_exists  varchar2(30) := 'N';
        l_create_error exception;
        l_count   number := 0;
        l_processed exception;
    begin

        --  l_sql :=  'ALTER TABLE METAVANTE_DEP_RESULT_EXTERNAL LOCATION (';
        select
            count(*)
        into l_count
        from
            metavante_files
        where
                result_flag = 'Y'
            and file_name = replace(p_file_name, '.res', '.mbi');

        if l_count > 0 then
            raise l_processed;
        end if;
        l_sql := null;
        if file_length(p_file_name) > 0 then
            l_sql := 'DEBIT_CARD_DIR:'''
                     || p_file_name
                     || ''',';
            l_exists := 'Y';
            update metavante_files
            set
                result_flag = 'Y'
            where
                file_name = replace(p_file_name, '.res', '.mbi');

        end if;

        dbms_output.put_line('after file checking');
        if l_exists = 'N' then
            null;
        else
            l_sql := 'ALTER TABLE METAVANTE_DEP_RESULT_EXTERNAL LOCATION ('
                     || rtrim(l_sql, ',')
                     || ')';
            begin
                execute immediate l_sql;
            exception
                when others then
                    rollback;
                    l_sqlerrm := sqlerrm;
                    insert_alert('Error in creating results file ' || p_file_name, l_sqlerrm);
                    raise l_create_error;

       /** send email alert as soon as it fails **/

            end;

            dbms_output.put_line('after altering');
            l_sqlerrm := null;
            begin
                for x in (
                    select
                        count(*) cnt
                    from
                        metavante_dep_result_external
                ) loop
                    if x.cnt = 0 then
                        l_sqlerrm := 'no result files found';
                    end if;
                end loop;
            exception
                when others then
                    l_sqlerrm := 'Error when checking contents in metavante_dep_result_external external table ' || sqlerrm;
                    raise l_create_error;
                    dbms_output.put_line('sql error message ' || l_sqlerrm);
            end;

            dbms_output.put_line('before inserting metavante errors');
            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Dependant Card Creation',
                    b.error_description,
                    case
                        when record_id in ( 'RD', 'RF' ) then
                            attribute2
                        when record_id = 'RC' then
                            attribute4
                    end,
                    sysdate,
                    sysdate,
                    dependant_id,
                    p_file_name
                from
                    metavante_dep_result_external a,
                    metavante_error_codes         b,
                    account                       c
                where
                    record_id in ( 'RD', 'RE', 'RF' )
                    and a.employee_id = c.acc_num
                    and ( ( record_id in ( 'RD', 'RF' )
                            and substr(attribute2, 1, 7) = 'CNEWDEP'
                            and a.attribute1 = to_char(b.error_id)
                            and a.attribute4 <> '0' )
                          or ( record_id = 'RE'
                               and ( substr(attribute5, 1, 7) = 'CNEWDEP'
                                     or attribute5 like 'CRENEWDEP%' )
                               and attribute4 <> '0'
                               and a.attribute4 = to_char(b.error_id) ) );

            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Dependant Card Creation',
                    b.error_description,
                    case
                        when record_id in ( 'RD', 'RF' ) then
                            attribute2
                        when record_id = 'RC' then
                            attribute4
                    end,
                    sysdate,
                    sysdate,
                    dependant_id,
                    p_file_name
                from
                    metavante_dep_result_external a,
                    metavante_error_codes         b
                where
                    record_id in ( 'RD', 'RE', 'RF' )
                    and ( ( substr(attribute2, 1, 7) in ( 'CNEWDEP', 'DEMGDEP', 'LOSTDEP' )
                            and attribute1 <> '0'
                            and record_id in ( 'RD', 'RF' ) )
                          or ( substr(attribute5, 1, 7) in ( 'CNEWDEP', 'TERMDEP', 'ROPNDEP' )
                               and attribute4 <> '0'
                               and record_id = 'RE' ) )
                    and ( ( record_id in ( 'RD', 'RF' )
                            and a.attribute1 = to_char(b.error_id) )
                          or ( record_id = 'RE'
                               and a.attribute4 = to_char(b.error_id) ) );

                /** Lost/Stolen Card Order Failures ***/
            insert into metavante_errors (
                error_id,
                record_id,
                employer_id,
                employee_id,
                action_code,
                detail_response_code,
                record_tracking_number,
                creation_date,
                last_update_date,
                dependant_id,
                file_name
            )
                select
                    metavante_errors_seq.nextval,
                    a.record_id,
                    a.employer_id,
                    a.employee_id,
                    'Dependant Lost/Stolen Card Order',
                    b.error_description,
                    attribute2,
                    sysdate,
                    sysdate,
                    dependant_id,
                    p_file_name
                from
                    metavante_dep_result_external a,
                    metavante_error_codes         b,
                    account                       c
                where
                        record_id = 'RF'
                    and a.employee_id = c.acc_num
                    and substr(attribute2, 1, 7) = 'LOSTDEP'
                    and attribute1 <> '0'
                    and a.attribute1 = to_char(b.error_id);

            for x in (
                select
                    substr(a.attribute2, 13, 4) pers_id,
                    case
                        when error_id in ( 1, 17, 18 ) then
                            null
                        else
                            b.error_description
                    end                         error_description,
                    a.attribute2
                from
                    metavante_dep_result_external a,
                    metavante_error_codes         b
                where
                        record_id = 'RJ'
                    and attribute1 <> '0'
                    and a.attribute1 = b.error_id
            ) loop
                insert into metavante_errors (
                    error_id,
                    record_id,
                    employer_id,
                    employee_id,
                    action_code,
                    detail_response_code,
                    record_tracking_number,
                    creation_date,
                    last_update_date,
                    dependant_id,
                    file_name
                )
                    select
                        metavante_errors_seq.nextval,
                        'RJ',
                        null,
                        b.acc_num,
                        decode(
                            substr(x.attribute2, 1, 7),
                            'USUSDEP',
                            'Dependant Unsuspend',
                            'TERMDEP',
                            'Dependant Termination',
                            'LOSTDEP',
                            'Dependant Lost/Stolen'
                        ),
                        x.error_description || ' for dependant',
                        x.attribute2,
                        sysdate,
                        sysdate,
                        x.pers_id,
                        p_file_name
                    from
                        person  a,
                        account b
                    where
                            a.pers_id = x.pers_id
                        and a.pers_main = b.pers_id;

            end loop;

            update_card_notes('DEPENDANT');
        end if;

        x_error_message := l_sqlerrm;
      --   pc_log.log_error('DEP_RESULT','i AM HERE');
    exception
        when l_processed then
            null;
        when l_create_error then
            x_error_message := l_sqlerrm;
       /** send email alert as soon as it fails **/
            insert_alert('Error in processing results file' || p_file_name, l_sqlerrm);
        when others then
            l_sqlerrm := sqlerrm;
       /** send email alert as soon as it fails **/
            insert_alert('Error in processing results file' || p_file_name, l_sqlerrm);
    end process_dependant_result;

    procedure onetime_terminate (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_payment_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_deposit_tbl  amount_tab;
        l_card_payment_tbl  amount_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
    begin
        l_line := null;
        l_file_id := null;

       /*** Posting disbursements ***/
       /** II is for all disbursements, pre auth and debit card purchases are excluded **/
        if p_acc_num_list is null then
            select
                b.acc_num,
                current_card_value amount,
                'Termination Debit',
                to_char(sysdate, 'YYYYMMDD'),
                b.acc_id
            bulk collect
            into l_card_payment_tbl
            from
                account    b,
                card_debit c
            where
                    b.account_status = 4
                and b.account_type = 'HSA'
                and b.pers_id = c.card_id
                and c.card_number is not null
                and current_card_value > 0
                and exists (
                    select
                        *
                    from
                        card_debit
                    where
                            card_id = b.pers_id
                        and card_number is not null
                );

        end if;

        if l_card_payment_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('PAYMENT');
                l_payment_file_name := 'MB_'
                                       || l_file_id
                                       || '_payment.mbi';
            else
                l_payment_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_payment_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_payment_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_payment_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Payment'
                      || ','
                      || 'STL_Result_Payment'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_payment_tbl.count loop
            l_line := 'II'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || g_employer_id                -- Employer ID
                      || ','
                      || l_card_payment_tbl(i).employee_id        -- Employee ID
                      || ','
                      || 'HSA'                    -- Account Type Code
                      || ','
                      || l_card_payment_tbl(i).merchant_name        -- Merchant Name
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service from
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service to
                      || ','
                      || l_card_payment_tbl(i).amount                -- Approved Claim Amount
                      || ','
                      || l_card_payment_tbl(i).change_num;      -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_payment_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_file_name := l_payment_file_name;
    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            mail_utility.send_email('metavante@sterlingadministration.com', 'techsupport@sterlingadministration.com', 'Error in Creating Deposit/Payment file'
            , l_sqlerrm);
    end onetime_terminate;

    procedure update_card_notes (
        p_person_type in varchar2
    ) is
    begin
        if p_person_type = 'SUBSCRIBER' then
        /*** Update debit card posted flag for payment ***/
            for x in (
                select
                    *
                from
                    metavante_result_external a
                where
                        a.record_id = 'RI'
                    and a.attribute1 = '0'
            ) loop
                update payment
                set
                    debit_card_posted = 'Y'
                where
                    change_num = x.attribute2;

                update metavante_adjustment_outbound
                set
                    debit_card_posted = 'Y'
                where
                    change_num = x.attribute2;

            end loop;

            for x in (
                select
                    replace(attribute8, 'ALEC_') attribute8
                from
                    metavante_result_external a
                where
                        a.record_id = 'RH'
                    and a.attribute7 = '0'
                    and a.attribute8 like 'ALEC%'
            ) loop
                if is_number(x.attribute8) = 'Y' then
                    update income
                    set
                        debit_card_posted = 'Y'
                    where
                            acc_id = to_number(x.attribute8)
                        and fee_code = 12;

                end if;
            end loop;

            for x in (
                select
                    employee_id
                from
                    metavante_result_external a
                where
                        a.record_id = 'RH'
                    and a.attribute7 = '0'
                    and a.attribute8 is null
            ) loop
                update metavante_adjustment_outbound
                set
                    debit_card_posted = 'Y'
                where
                        acc_num = x.employee_id
                    and amount = - 20
                    and record_type = 'RECEIPT'
                    and change_num is null;

            end loop;

            for x in (
                select
                    *
                from
                    metavante_result_external a
                where
                        a.record_id = 'RH'
                    and a.attribute7 = '0'
                    and a.attribute8 not like 'REFUND%'
                    and a.attribute8 not like 'ALEC%'
            ) loop
                update income
                set
                    debit_card_posted = 'Y'
                where
                    change_num = x.attribute8;

                update metavante_adjustment_outbound
                set
                    debit_card_posted = 'Y'
                where
                    change_num = x.attribute8;

            end loop;

            for x in (
                select
                    replace(attribute8, 'REFUND_') attribute8
                from
                    metavante_result_external a
                where
                        a.record_id = 'RH'
                    and a.attribute7 = '0'
                    and a.attribute8 like 'REFUND%'
                    and a.attribute8 not like 'ALEC%'
            ) loop
                update payment
                set
                    debit_card_posted = 'Y'
                where
                    change_num = to_number(x.attribute8);

                update metavante_adjustment_outbound
                set
                    debit_card_posted = 'Y'
                where
                    change_num = x.attribute8;

            end loop;

            for x in (
                select
                    record_tracking_number           change_num,
                    pc_account.acc_balance(b.acc_id) sam_balance,
                    e.disbursable_balance            bps_balance
                from
                    metavante_errors        a,
                    account                 b,
                    payment                 c,
                    person                  d,
                    metavante_card_balances e
                where
                        a.action_code = 'Payment'
                    and a.detail_response_code = 'Low funds in participant account.'
                    and b.acc_num = e.acc_num
                    and a.employee_id = b.acc_num
                    and d.pers_id = b.pers_id
                    and b.acc_id = c.acc_id
                    and b.account_type = 'HSA'
                    and a.record_tracking_number = c.change_num
                    and trunc(a.creation_date) = trunc(sysdate)
            ) loop
                if nvl(x.sam_balance, 0) = nvl(x.bps_balance, 0)
                or (
                    nvl(x.sam_balance, 0) - nvl(x.bps_balance, 0) > 0
                    and nvl(x.sam_balance, 0) - nvl(x.bps_balance, 0) < 1
                ) then
                    update payment
                    set
                        debit_card_posted = 'Y'
                    where
                        change_num = x.change_num;

                end if;
            end loop;

        -- Annual election records
       -- for FSA,HRA,LPF plans we send IH record
            for x in (
                select
                    *
                from
                    metavante_result_external a
                where
                        a.record_id = 'RC'
                    and a.attribute4 = '0'
                    and a.attribute7 like 'ALEC%'
            ) loop
                if is_number(replace(x.attribute7, 'ALEC_')) = 'Y' then
                    update income
                    set
                        debit_card_posted = 'Y'
                    where
                            acc_id = to_number(replace(x.attribute7, 'ALEC_'))
                        and fee_code = 12;

                end if;
            end loop;

         /*** Update debit card update for demographic ***/
            update debit_card_updates b
            set
                demo_processed = 'Y'
            where
                    demo_changed = 'Y'
                and demo_processed = 'N'
                and exists (
                    select
                        *
                    from
                        metavante_result_external a
                    where
                            a.employee_id = b.acc_num
                        and record_id = 'RB'
                        and attribute2 like 'DEMG%'
                        and attribute1 = '0'
                );

            update debit_card_updates b
            set
                acc_num_processed = 'Y'
            where
                    acc_num_changed = 'Y'
                and acc_num_processed = 'N'
                and exists (
                    select
                        *
                    from
                        metavante_result_external a
                    where
                            a.attribute1 = b.acc_num
                        and record_id = 'RQ'
                        and attribute3 like 'DEMG%'
                        and attribute2 in ( '0', '18014' )
                );

            for x in (
                select
                    b.acc_id,
                    b.plan_code
                from
                    metavante_result_external a,
                    account                   b,
                    card_debit
                where
                        a.employee_id = b.acc_num
                    and record_id = 'RF'
                    and attribute2 like 'LOST%'
                    and attribute1 = '0'
                    and card_debit.card_id = b.pers_id
                    and card_debit.status = 5
            ) loop
                pc_fin.lost_stolen_payment(x.acc_id,
                                           x.plan_code,
                                           to_char(sysdate, 'mm/dd/yyyy')
                                           || ' lost/stolen fee ');
            end loop;

       /** Lost Stolen **/

            update card_debit
            set
                status = 2,
                issue_date = to_char(sysdate, 'YYYYMMDD'),
                last_update_date = sysdate,
                last_updated_by = 0
            where
                    status = 5
                and exists (
                    select
                        *
                    from
                        metavante_result_external a,
                        account                   b
                    where
                            a.employee_id = b.acc_num
                        and record_id = 'RF'
                        and attribute2 like 'LOST%'
                        and attribute1 = '0'
              --       AND b.account_type = 'HSA'
                        and card_debit.card_id = b.pers_id
                );

      /** Card Creation **/
            update card_debit
            set
                status = 2,
                issue_date = to_char(sysdate, 'YYYYMMDD'),
                last_update_date = sysdate,
                last_updated_by = 0
            where
                    status = 1
                and exists (
                    select
                        *
                    from
                        metavante_result_external a,
                        account                   b
                    where
                            a.employee_id = b.acc_num
                        and record_id = 'RF'
                        and attribute2 like 'CNEW%'
                        and attribute1 in ( '20005', '0' )
          --   AND    b.account_type = 'HSA'
                        and card_debit.card_id = b.pers_id
                );

            for x in (
                select
                    c.acc_num,
                    c.pers_id,
                    substr(a.attribute2, 1, 4) action
                from
                    metavante_result_external a,
                    account                   c
                where
                        record_id = 'RJ'
                    and attribute1 = '0'
             -- AND   c.account_type = 'HSA'
                    and substr(a.attribute2,
                               10,
                               (length(a.attribute2) - 8)) = c.acc_num
            ) loop
                if x.action in ( 'LOST', 'USUS' ) then
                    update card_debit
                    set
                        status = 2,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and status = 7
                        and x.action = 'USUS';

                else
                    dbms_output.put_line('in suspend');
                    update card_debit
                    set
                        status = 4,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and status = 6;

                    dbms_output.put_line('after suspend' || sql%rowcount);
                end if;
            end loop;

            update vendors
            set
                vendor_in_peachtree = 'Y'
            where
                vendor_id in (
                    select
                        employee_id
                    from
                        metavante_result_external
                    where
                            record_id = 'BP'
                        and employer_id = '0'
                );

            for x in (
                select distinct
                    c.acc_num,
                    substr(attribute7, 1, 4)       action,
                    a.attribute4,
                    c.account_type,
                    substr(attribute7,
                           6,
                           length(attribute7) - 5) record_number,
                    c.acc_id
                from
                    metavante_result_external a,
                    account                   c
                where
                        record_id = 'RC'
                    and a.employee_id = c.acc_num
                    and c.account_type in ( 'FSA', 'HRA' )
                    and substr(attribute7, 1, 4) = 'CNEW'
                    and attribute4 = '0'
            ) loop
                update account
                set
                    bps_acc_num = x.acc_num
                where
                        acc_num = x.acc_num
                    and account_type = x.account_type;

                update ben_plan_enrollment_setup
                set
                    created_in_bps = 'Y'
                where
                        acc_id = x.acc_id
                    and ben_plan_id = x.record_number;

            end loop;

            for x in (
                select
                    c.pers_id,
                    substr(attribute5, 1, 4) action,
                    decode(
                        substr(attribute5, 1, 4),
                        'TERM',
                        3,
                        2
                    )                        status,
                    decode(
                        substr(attribute5, 1, 4),
                        'TERM',
                        'Y',
                        'N'
                    )                        term_flag,
                    a.attribute4,
                    c.account_type
                from
                    metavante_result_external a,
                    account                   c
                where
                        record_id = 'RC'
                    and a.employee_id = c.acc_num
           --  AND c.account_type = 'HSA'
                    and substr(attribute5, 1, 4) in ( 'CNEW', 'TERM', 'ROPN' )
                    and attribute4 in ( '0', '107302', '20009' )
            ) loop
                begin
                    update card_debit
                    set
                        terminated = x.term_flag,
                        status = x.status,
                        last_updated_by = 0
                    where
                        card_id = x.pers_id;

                exception
                    when others then
                        null;
                end;
            end loop;

            for x in (
                select
                    c.pers_id,
                    substr(attribute5, 1, 4)     action,
                    replace(attribute5, 'PTRM_') ben_plan_id,
                    a.attribute4,
                    c.account_type,
                    c.acc_id
                from
                    metavante_result_external a,
                    account                   c
                where
                        record_id = 'RC'
                    and a.employee_id = c.acc_num
                    and c.account_type <> 'HSA'
                    and substr(attribute5, 1, 4) = 'PTRM'
                    and attribute4 in ( '0', '107302', '20009' )
            ) loop
                begin
                    update ben_plan_enrollment_setup
                    set
                        terminated = 'Y',
                        last_updated_by = 0,
                        last_update_date = sysdate
                    where
                        ben_plan_id = x.ben_plan_id;

                    for xx in (
                        select
                            b.scheduler_id,
                            b.plan_type
                        from
                            scheduler_details a,
                            scheduler_master  b
                        where
                                a.scheduler_id = b.scheduler_id
                            and b.plan_type = x.attribute4
                            and a.acc_id = x.acc_id
                    ) loop
                        update scheduler_details
                        set
                            status = 'I',
                            last_updated_by = 0,
                            last_updated_date = sysdate
                        where
                                acc_id = x.acc_id
                            and scheduler_id = xx.scheduler_id;

                    end loop;

                exception
                    when others then
                        null;
                end;
            end loop;

            for x in (
                select
                    c.acc_num,
                    c.pers_id,
                    case
                        when error_id in ( 1, 17, 18 ) then
                            null
                        else
                            b.error_description
                    end error_description,
                    a.attribute2
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                        record_id = 'RJ'
                    and attribute1 <> '0'
            --  AND  c.account_type = 'HSA'
                    and a.attribute1 = b.error_id
                    and substr(a.attribute2,
                               10,
                               (length(a.attribute2) - 8)) = c.acc_num
            ) loop
                begin
                    update card_debit
                    set
                        note = note
                               || decode(x.error_description,
                                         null,
                                         '',
                                         'Metavante:'
                                         || to_char(sysdate, 'yyyymmdd')
                                         || x.error_description),
                        last_updated_by = 0
                    where
                        card_id = x.pers_id;

                    update debit_card_request
                    set
                        error_message = x.acc_num
                                        || ' '
                                        || x.error_description,
                        processed_flag = 'ME',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and trunc(creation_date) = trunc(sysdate);

                exception
                    when others then
                        null;
                end;
            end loop;

            for x in (
                select
                    c.acc_num,
                    c.pers_id,
                    a.attribute2
                from
                    metavante_result_external a,
                    account                   c
                where
                        record_id = 'RJ'
                    and attribute3 = '0'
                    and a.employee_id = c.acc_num
                    and a.attribute4 like 'TERM%'
            ) loop
                update card_debit
                set
                    terminated = 'Y',
                    last_update_date = sysdate
                where
                        card_id = x.pers_id
                    and card_number = x.attribute2;

            end loop;
     /** Update card with notes from card address creation and account creation issues ***/
            for x in (
                select
                    c.pers_id,
                    case
                        when error_id in ( 1, 17, 18 ) then
                            null
                        else
                            b.error_description
                    end           error_description,
                    a.employee_id acc_num
                from
                    metavante_result_external a,
                    metavante_error_codes     b,
                    account                   c
                where
                    record_id in ( 'RB', 'RC', 'RF' )
                    and a.employee_id = c.acc_num
             --AND c.account_type = 'HSA'
                    and ( ( substr(attribute2, 1, 4) in ( 'CNEW', 'DEMG', 'LOST' )
                            and attribute1 <> '0'
                            and record_id in ( 'RF', 'RB' ) )
                          or ( substr(attribute5, 1, 4) in ( 'CNEW', 'TERM', 'ROPN' )
                               and attribute4 <> '0'
                               and record_id = 'RC' ) )
                    and ( ( record_id in ( 'RB', 'RF' )
                            and a.attribute1 = to_char(b.error_id) )
                          or ( record_id = 'RC'
                               and a.attribute4 = to_char(b.error_id) ) )
            ) loop
                begin
                    update card_debit
                    set
                        note = note
                               || decode(x.error_description,
                                         null,
                                         '',
                                         'Metavante:'
                                         || to_char(sysdate, 'yyyymmdd')
                                         || x.error_description)
                    where
                        card_id = x.pers_id;

                    update debit_card_request
                    set
                        error_message = x.acc_num
                                        || ' '
                                        || x.error_description,
                        processed_flag = 'ME',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and trunc(creation_date) = trunc(sysdate);

                exception
                    when others then
                        null;
                end;
            end loop;

        else
            update card_debit
            set
                status = 2,
                last_update_date = sysdate,
                last_updated_by = 0
            where
                    status = 1
                and card_id in (
                    select
                        dependant_id
                    from
                        metavante_dep_result_external a
                    where
                            record_id = 'RF'
                        and attribute2 like 'CNEWDEP%'
                        and attribute1 in ( '20005', '0' )
                );

            update metavante_outbound
            set
                processed_flag = 'Y',
                last_update_date = sysdate
            where
                exists (
                    select
                        *
                    from
                        metavante_dep_result_external a
                    where
                            a.dependant_id = metavante_outbound.pers_id
                        and record_id = 'RE'
                        and ( attribute5 like 'CNEWDEP%'
                              or attribute5 like 'CRENEWDEP%' )
                        and attribute4 = '0'
                )
                and metavante_outbound.action = 'DEPENDANT_INSERT'
                and processed_flag = 'N';

            for x in (
                select
                    b.acc_id,
                    b.plan_code,
                    a.dependant_id
                from
                    metavante_dep_result_external a,
                    account                       b,
                    card_debit
                where
                        a.employee_id = b.acc_num
                    and record_id = 'RF'
                    and attribute2 like 'LOSTDEP%'
                    and attribute1 in ( '20005', '0' )
                 --  AND    b.account_type = 'HSA'
                    and card_debit.card_id = a.dependant_id
                    and card_debit.status = 5
            ) loop
                pc_fin.lost_stolen_payment(x.acc_id,
                                           x.plan_code,
                                           to_char(sysdate, 'mm/dd/yyyy')
                                           || ' lost/stolen fee for dependent ');

                update card_debit
                set
                    status = 2,
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                        status = 5
                    and card_id = x.dependant_id;

            end loop;


  /*** Update status of Lost/stolen and Unsuspend to Active , and suspend pending to suspended ****/
            for x in (
                select
                    dependant_id               pers_id,
                    substr(a.attribute2, 1, 7) action
                from
                    metavante_dep_result_external a
                where
                        record_id = 'RJ'
                    and attribute1 = '0'
            ) loop
                if x.action = 'USUSDEP' then
                    update card_debit
                    set
                        status = 2,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and status = 7;

                else
                    update card_debit
                    set
                        status = 4,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and status = 6;

                end if;
            end loop;

            for x in (
                select
                    dependant_id             pers_id,
                    substr(attribute5, 1, 7) action,
                    decode(
                        substr(attribute5, 1, 7),
                        'TERMDEP',
                        3,
                        2
                    )                        status,
                    decode(
                        substr(attribute5, 1, 7),
                        'TERMDEP',
                        'Y',
                        'N'
                    )                        term_flag
                from
                    metavante_dep_result_external a
                where
                        record_id = 'RE'
                    and substr(attribute5, 1, 7) = 'TERMDEP'
                    and attribute4 in ( '0', '107302', '20009' )
            ) loop
                update card_debit
                set
                    terminated = x.term_flag,
                    status = x.status,
                    last_updated_by = 0
                where
                    card_id = x.pers_id;

            end loop;

            for x in (
                select
                    substr(a.attribute2, 13, 4) pers_id,
                    case
                        when error_id in ( 1, 17, 18 ) then
                            null
                        else
                            b.error_description
                    end                         error_description,
                    a.attribute2,
                    a.employee_id               acc_num
                from
                    metavante_dep_result_external a,
                    metavante_error_codes         b
                where
                        record_id = 'RJ'
                    and attribute1 <> '0'
                    and a.attribute1 = b.error_id
            ) loop
                begin
                    update card_debit
                    set
                        note = note
                               || decode(x.error_description,
                                         null,
                                         '',
                                         'Metavante '
                                         || to_char(sysdate, 'YYYYMMDD')
                                         || ':'
                                         || x.error_description)
                    where
                        card_id = x.pers_id;

                    update debit_card_request
                    set
                        error_message = x.acc_num
                                        || ' '
                                        || x.error_description,
                        processed_flag = 'Y',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and trunc(creation_date) = trunc(sysdate);

                exception
                    when others then
                        null;
                end;
            end loop;

/** Update card with notes from card address creation and account creation issues ***/
            for x in (
                select
                    dependant_id  pers_id,
                    case
                        when error_id in ( 1, 17, 18 ) then
                            null
                        else
                            b.error_description
                    end           error_description,
                    a.employee_id acc_num
                from
                    metavante_dep_result_external a,
                    metavante_error_codes         b
                where
                    record_id in ( 'RD', 'RE', 'RF' )
                    and ( ( substr(attribute2, 1, 7) in ( 'CNEWDEP', 'DEMGDEP', 'LOSTDEP' )
                            and attribute1 <> '0'
                            and record_id in ( 'RD', 'RF' ) )
                          or ( substr(attribute5, 1, 7) in ( 'CNEWDEP', 'TERMDEP', 'ROPNDEP' )
                               and attribute4 <> '0'
                               and record_id = 'RE' ) )
                    and ( ( record_id in ( 'RD', 'RF' )
                            and a.attribute1 = to_char(b.error_id) )
                          or ( record_id = 'RE'
                               and a.attribute4 = to_char(b.error_id) ) )
            ) loop
                begin
                    update card_debit
                    set
                        note = note
                               || decode(x.error_description,
                                         null,
                                         '',
                                         'Metavante:'
                                         || to_char(sysdate, 'MM/DD/YY')
                                         || ' '
                                         || x.error_description)
                    where
                        card_id = x.pers_id;

                    update debit_card_request
                    set
                        error_message = x.acc_num
                                        || ' '
                                        || x.error_description,
                        processed_flag = 'Y',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                            card_id = x.pers_id
                        and trunc(creation_date) = trunc(sysdate); --
                exception
                    when others then
                        null;
                end;
            end loop;

        end if;

        for x in (
            select
                a.debit_card_request_id,
                a.acc_num,
                a.status,
                b.status card_status
            from
                debit_card_request a,
                card_debit         b
            where
                    a.status <> b.status
                and a.card_id = b.card_id
                and processed_flag = 'N'
        ) loop
            update debit_card_request
            set
                processed_flag = 'Y'
            where
                debit_card_request_id = x.debit_card_request_id;

        end loop;

    end;

    procedure card_request_history (
        p_status      in number,
        p_person_type in varchar2
    ) is
        card_error exception;
        l_error_message varchar2(3200);
        l_sqlerrm       varchar2(3200);
    begin
        dbms_output.put_line('IN card request history ');
        if p_person_type = 'SUBSCRIBER' then
            l_error_message := null;
            for x in (
                select
                    card_id,
                    c.acc_id,
                    c.acc_num,
                    a.status,
                    a.created_by,
                    a.last_updated_by,
                    c.account_status,
                    c.complete_flag,
                    pc_account.acc_balance(c.acc_id) balance,
                    a.status_code,
                    a.card_number,
                    c.account_type
                from
                    card_debit a,
                    account    c
                where
                    ( ( p_status is null
                        and status in ( 1, 3, 5 ) )
                      or ( status = p_status ) )
                    and ( ( status = 3
                            and a.terminated = 'N'
                            and card_number is not null )
                          or ( a.status = 1
                               and trunc(c.start_date) <= trunc(sysdate) )
                          or ( status = 6
                               and card_number is not null )
                          or ( status in ( 5, 7 ) ) )
                    and c.pers_id = a.card_id
                    and nvl(terminated, 'N') = 'N'
            ) loop
                l_error_message := null;
                dbms_output.put_line('checking conditions ');
                begin
                    if x.account_type = 'HSA' then
                        if
                            x.balance <= 0
                            and x.status not in ( 3, 6 )
                        then
                            l_error_message := 'Operation on Card Cannot be done, because of Insufficent Balance';
                            raise card_error;
                        end if;

                        if x.complete_flag = 0 then
                            l_error_message := 'Operation on Card Cannot be done, because of Incomplete Account Setup ';
                            raise card_error;
                        end if;
                        if
                            x.status = 1
                            and x.account_status = 2
                        then
                            l_error_message := 'Account status is suspended, Card cannot be ordered';
                            raise card_error;
                        end if;

                        if
                            x.status = 1
                            and x.account_status = 3
                        then
                            l_error_message := 'Account status is Pending Activation, Card cannot be ordered';
                            raise card_error;
                        end if;

                        if
                            x.status_code not in ( 4, 5 )
                            and x.card_number is not null
                            and x.status = 1
                        then
                            l_error_message := 'Active Card Exist in Metvante, New Card cannot be ordered';
                            raise card_error;
                        end if;

                        if
                            x.status <> 1
                            and x.card_number is null
                        then
                            l_error_message := 'No Card Exist in Metvante, Order a new card';
                            raise card_error;
                        end if;

                        dbms_output.put_line('inserting to card request ');
                    end if;

                    insert_card_request(x.card_id, x.acc_num, x.status, null, 'N',
                                        x.created_by);

                exception
                    when card_error then
                        insert_card_request(x.card_id, x.acc_num, x.status, l_error_message, 'N',
                                            x.created_by);
                end;

            end loop;

        else
            l_error_message := null;
            for x in (
                select
                    card_id,
                    c.acc_id,
                    c.acc_num,
                    a.status,
                    a.created_by,
                    a.last_updated_by,
                    c.account_status,
                    c.complete_flag,
                    pc_account.acc_balance(c.acc_id) balance,
                    a.status_code,
                    a.card_number,
                    (
                        select
                            count(*)
                        from
                            card_debit kk
                        where
                            kk.card_id = c.pers_id
                    )                                main_card
                from
                    card_debit a,
                    account    c,
                    person     b
                where
                    ( ( p_status is null
                        and status in ( 1, 3, 5 ) )
                      or ( status = p_status ) )
                    and ( ( status = 3
                            and a.terminated = 'N'
                            and card_number is not null )
                          or ( a.status = 1
                               and c.start_date <= trunc(sysdate) )
                          or ( status = 6
                               and card_number is not null )
                          or ( status in ( 5, 7 ) ) )
                    and c.pers_id = b.pers_main
                    and b.pers_id = a.card_id
                    and c.account_type = 'HSA'
                    and nvl(terminated, 'N') = 'N'
            ) loop
                l_error_message := null;
                begin
                    if
                        x.balance <= 0
                        and x.status not in ( 3, 6 )
                    then
                        l_error_message := 'Operation on Card Cannot be done, because of Insufficent Balance';
                        raise card_error;
                    end if;

                    if x.main_card = 0 then
                        l_error_message := 'Card Request cannot be processed for Dependant , because account holder does not have card'
                        ;
                        raise card_error;
                    end if;
                    if x.complete_flag = 0 then
                        l_error_message := 'Operation on Card Cannot be done, because of Incomplete Account Setup ';
                        raise card_error;
                    end if;
                    if
                        x.status_code not in ( 4, 5 )
                        and x.card_number is not null
                        and x.status = 1
                    then
                        l_error_message := 'Active Card Exist in Metvante, New Card cannot be ordered';
                        raise card_error;
                    end if;

                    if
                        x.status = 1
                        and x.account_status = 2
                    then
                        l_error_message := 'Account status is suspended, Card cannot be ordered';
                        raise card_error;
                    end if;

                    if
                        x.status = 1
                        and x.account_status = 3
                    then
                        l_error_message := 'Account status is Pending Activation, Card cannot be ordered';
                        raise card_error;
                    end if;

                    if
                        x.status <> 1
                        and x.card_number is null
                    then
                        l_error_message := 'No Card Exist in Metvante, Order a new card';
                        raise card_error;
                    end if;

                    dbms_output.put_line('inserting to card request ');
                    insert_card_request(x.card_id, x.acc_num, x.status, null, 'Y',
                                        x.created_by);

                    dbms_output.put_line('after inserting to card request ');
                exception
                    when card_error then
                        insert_card_request(x.card_id, x.acc_num, x.status, l_error_message, 'Y',
                                            x.created_by);
                end;

            end loop;

        end if;

        commit;
    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in updating debit card request ', l_sqlerrm);
            dbms_output.put_line('IN card request history ' || l_sqlerrm);
    end card_request_history;

    procedure insert_card_request (
        p_card_id        in number,
        p_acc_num        in varchar2,
        p_status         in number,
        p_error_message  in varchar2,
        p_dependant_card in varchar2,
        p_user_id        in number
    ) is
        l_sqlerrm varchar2(3200);
    begin
        insert into debit_card_request (
            debit_card_request_id,
            card_id,
            acc_num,
            status,
            error_message,
            processed_flag,
            dependant_card,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                debit_card_request_seq.nextval,
                p_card_id,
                p_acc_num,
                p_status,
                p_error_message,
                decode(p_error_message, null, 'N', 'E'),
                p_dependant_card,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                dual;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
    /*    mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
                           ,'Error in updating debit card request '
                           ,l_sqlerrm);*/
    end insert_card_request;

    procedure reprocess_file (
        p_file_name     in varchar2,
        x_error_message out varchar2,
        x_error_status  out varchar2
    ) is

        l_conn          utl_tcp.connection;
        l_creation_date date;
        l_file_name     varchar2(255);
        l_result_type   varchar2(30);
        l_action        varchar2(30);
        l_result_flag   varchar2(30);
        l_import_file   varchar2(30);
    begin
 -- pc_log.log_error('PC_DEBIT_CARD.REPROCESS_FILE',p_file_name);
        select
            creation_date,
            file_action,
            nvl(result_flag, 'N') result_flag
        into
            l_creation_date,
            l_action,
            l_result_flag
        from
            metavante_files
        where
            file_name = p_file_name;
  ---   pc_log.log_error('PC_DEBIT_CARD.REPROCESS_FILE, action',l_action);
        if l_action like 'DEP%' then
            l_result_type := 'DEP_ACC_RESULT';
            l_import_file := replace(p_file_name, 'mbi', 'res');
        elsif l_action in ( 'EN', 'EC', 'EM' ) then
            l_result_type := 'EXPORT';
            l_import_file := replace(p_file_name, 'mbi', 'exp');
        else
            l_result_type := 'ACC_RESULT';
            l_import_file := replace(p_file_name, 'mbi', 'res');
        end if;
  -- pc_log.log_error('PC_DEBIT_CARD.REPROCESS_FILE',l_import_file);
  -- pc_log.log_error('PC_DEBIT_CARD.REPROCESS_FILE, Result flag',l_result_flag);
  --pc_log.log_error('PC_DEBIT_CARD.REPROCESS_FILE, Creation Date',l_creation_date);
        if
            l_result_flag = 'N'
            and l_creation_date is not null
            and l_creation_date > sysdate - 1
        then
   --pc_log.log_error('PC_DEBIT_CARD.REPROCESS_FILE','File length '||'Before FTP');
            l_file_name := l_import_file;
            l_conn := ftp.login(g_ftp_url, '21', g_ftp_username, g_ftp_password);
            ftp.ascii(p_conn => l_conn);
            ftp.get(
                p_conn      => l_conn,
                p_from_file => l_import_file,
                p_to_dir    => 'DEBIT_CARD_DIR',
                p_to_file   => l_file_name
            );

            ftp.logout(l_conn);
     --  pc_log.log_error('PC_DEBIT_CARD.REPROCESS_FILE','File length '||file_length(l_file_name));
            if file_length(l_file_name) > 0 then
                if l_result_type = 'ACC_RESULT' then
                    process_result(l_file_name, x_error_message);
                elsif l_result_type = 'DEP_ACC_RESULT' then
                    process_dependant_result(l_file_name, x_error_message);
                elsif l_result_type = 'EXPORT' then
                    if l_action = 'EN' then
                        post_pending_authorizations(x_error_message, x_error_status, l_file_name);
                        process_settlements(x_error_message, x_error_status, l_file_name);
                    elsif l_action = 'EC' then
                        update_card_balance(x_error_message, x_error_status, l_file_name);
                    elsif l_action = 'EM' then
                        update_card_details(x_error_message, x_error_status, l_file_name);
                    end if;
                end if;
            end if;

        else
            if l_creation_date < sysdate - 1 then
                x_error_message := 'Cannot process old files';
                x_error_status := 'E';
            elsif l_result_flag = 'Y' then
                x_error_message := 'File is already processed';
                x_error_status := 'E';
            end if;
        end if;

    exception
        when others then
            x_error_message := sqlerrm;
            x_error_status := 'E';
    end;

    procedure hra_settlement_export (
        p_file_name out varchar2
    ) is

        l_utl_id     utl_file.file_type;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_reopen_tbl varchar2_tab;
        l_sqlerrm    varchar2(32000);
        l_file_id    number;
    begin
          /** will check with metavante if IL record is needed for this **/

        l_file_id := insert_file_seq('EN');
        l_file_name := 'MB_'
                       || l_file_id
                       || '_'
                       || 'EN'
                       || '.mbi';
        dbms_output.put_line('file id ' || l_file_id);
        update metavante_files
        set
            file_name = l_file_name
        where
            file_id = l_file_id;

        l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
        l_line := 'IA'
                  || ','
                  || 2
                  || ','
                  || g_edi_password
                  || ','
                  || 'STL_'
                  || 'EN'
                  || '_HRA_Import'
                  || ','
                  || 'STL_Export_Result'
                  || ','
                  || 'STL_'
                  || 'EN'
                  || '_Export';

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        l_line := 'IL'                            -- Record ID
                  || ','
                  || g_tpa_id                             -- TPA ID
                  || ','
                  || 'EN'                        -- Export Record Type
                  || ','
                  || 'HRA'                       -- account type code
                  || ','
                  || '7'                                  -- Transaction Origination, 'POS'
                  || ','
                  || '1'                                  -- Transaction TYpe, includes Pre-Auth, Force-Post, Refund
                  || ','
                  || '0'                                 -- Transaction Status
                  || ','
                  || '2';                                  -- Transaction Date Type, 1 -- Settlement Date
        l_line := l_line
                  || ','
                  || '20100101'; -- Export Date from
        l_line := l_line
                  || ','
                  || to_char(
            trunc(sysdate),
            'YYYYMMDD'
        )   -- Export Date to
                  || ','
                  || '2'                                 -- Output format
                  || ','
                  || '4';                                  -- Transaction Filter

        utl_file.put_line(
            file   => l_utl_id,
            buffer => l_line
        );
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Generating Export Request for ' || 'EN', l_sqlerrm);
    end hra_settlement_export;

    procedure employer_demg (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_employer_tbl      employer_tab;
        l_employer_plan_tbl emp_plan_tab;
        l_sqlerrm           varchar2(32000);
        l_message           varchar2(32000);
        l_file_id           number;
        l_record_count      number;
        result_exception exception;
    begin

      /*   IF get_file_name('EMPLOYER_DEMOG','RESULT') IS NOT NULL THEN
          l_message := 'ALERT!!!! Last Employer Demographic file  has not been processed yet ';
          RAISE result_exception;

       END IF;*/

        select
            nvl(bps_acc_num,
                replace(
                replace(
                    replace(
                        replace(acc_num, 'GHRA'),
                        'GFSA'
                    ),
                    chr(10),
                    ''
                ),
                chr(13),
                ''
            )) employer_id,
            '"'
            || b.name
            || '"',
            '"'
            || substr(b.address, 1, 75)
            || '"',
            '"'
            || b.city
            || '"',
            '"'
            || b.state
            || '"',
            '"'
            || b.zip
            || '"',
            'US',
            '"'
            || entrp_phones
            || '"',
            '"'
            || entrp_fax
            || '"',
            'Sarah.Soman@sterlingadministration.com' -- since employers should not get notification , ali's email used
          -- , '"'||entrp_email||'"'
            ,
            '"'
            || nvl(contact_email, entrp_email)
            || '"',
            10 -- projected accounts
            ,
            card_allowed -- card allowed
            ,
            32
        bulk collect
        into l_employer_tbl
        from
            enterprise b,
            account    a
        where
                b.entrp_id = a.entrp_id
            and a.account_type in ( 'FSA', 'HRA' )
            and a.account_status not in ( 4, 5 )
            and a.bps_acc_num is null
            and b.address is not null
            and b.city is not null
            and b.state is not null
            and b.zip is not null
            and exists (
                select
                    *
                from
                    ben_plan_enrollment_setup c
                where
                        b.entrp_id = c.entrp_id
                    and c.status = 'A'
                    and nvl(c.plan_docs_flag, 'Y') = 'N'
            );
     -- AND   TRUNC(a.creation_date) = TRUNC(sysdate);

        select
            *
        bulk collect
        into l_employer_plan_tbl
        from
            (
                select
                    nvl(bps_acc_num,
                        'STL'
                        || replace(
                        replace(
                            replace(
                                replace(acc_num, 'GHRA'),
                                'GFSA'
                            ),
                            chr(10),
                            ''
                        ),
                        chr(13),
                        ''
                    ))                         employer_id,
                    '"'
                    || c.ben_plan_name
                    || '"',
                    '"'
                    || c.plan_type
                    || '"',
                    '"'
                    || to_char(c.plan_start_date, 'YYYYMMDD')
                    || '"',
                    '"'
                    || to_char(c.plan_end_date, 'YYYYMMDD')
                    || '"',
                    '"'
                    || to_char(c.plan_end_date + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0),
                               'YYYYMMDD')
                    || '"',
                    nvl(c.minimum_election, 0) minimum_election,
                    c.maximum_election,
                    '"'
                    || to_char(c.plan_end_date + nvl(c.grace_period, 0),
                               'YYYYMMDD')
                    || '"',
                    c.ben_plan_id,
                    c.iias_enable,
                    c.iias_options,
                    c.external_deductible
                from
                    enterprise                b,
                    account                   a,
                    ben_plan_enrollment_setup c
                where
                        b.entrp_id = a.entrp_id
                    and a.acc_id = c.acc_id
                    and c.plan_end_date + nvl(c.grace_period, 0) + nvl(c.runout_period_days, 0) > sysdate - 90 --Vanitha 08/21/2017: added grace and runout
                    and b.address is not null
                    and b.city is not null
                    and b.state is not null
                    and b.zip is not null
                    and a.account_type in ( 'FSA', 'HRA' )
                    and a.account_status not in ( 4, 5 )
                    and c.status = 'A'
                    and nvl(c.plan_docs_flag, 'N') = 'N'
                    and nvl(c.created_in_bps, 'Y') = 'N'
                union
                select
                    nvl(bps_acc_num,
                        'STL'
                        || replace(
                        replace(
                            replace(
                                replace(acc_num, 'GHRA'),
                                'GFSA'
                            ),
                            chr(10),
                            ''
                        ),
                        chr(13),
                        ''
                    ))                         employer_id,
                    '"'
                    || c.ben_plan_name
                    || '"',
                    '"'
                    || c.plan_type
                    || '"',
                    '"'
                    || to_char(c.plan_start_date, 'YYYYMMDD')
                    || '"',
                    '"'
                    || to_char(c.plan_end_date, 'YYYYMMDD')
                    || '"',
                    '"'
                    || to_char(c.plan_end_date + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0),
                               'YYYYMMDD')
                    || '"',
                    nvl(c.minimum_election, 0) minimum_election,
                    c.maximum_election,
                    '"'
                    || to_char(c.plan_end_date + nvl(c.grace_period, 0),
                               'YYYYMMDD')
                    || '"',
                    c.ben_plan_id,
                    c.iias_enable,
                    c.iias_options,
                    c.external_deductible
                from
                    enterprise                b,
                    account                   a,
                    ben_plan_enrollment_setup c
                where
                        b.entrp_id = a.entrp_id
                    and a.acc_id = c.acc_id
                    and c.plan_end_date + nvl(c.grace_period, 0) + nvl(c.runout_period_days, 0) > sysdate - 90 --Vanitha 08/21/2017: added grace and runout
                    and b.address is not null
                    and b.city is not null
                    and b.state is not null
                    and b.zip is not null
                    and a.account_type in ( 'FSA', 'HRA' )
                    and a.account_status not in ( 4, 5 )
                    and c.status = 'A'
                    and nvl(c.plan_docs_flag, 'N') = 'N'
                    and nvl(c.created_in_bps, 'Y') = 'Y'
                union
                select
                    nvl(bps_acc_num,
                        'STL'
                        || replace(
                        replace(
                            replace(
                                replace(acc_num, 'GHRA'),
                                'GFSA'
                            ),
                            chr(10),
                            ''
                        ),
                        chr(13),
                        ''
                    ))                         employer_id,
                    '"'
                    || c.ben_plan_name
                    || '"',
                    '"'
                    || c.plan_type
                    || '"',
                    '"'
                    || to_char(c.plan_start_date, 'YYYYMMDD')
                    || '"',
                    '"'
                    || to_char(c.plan_end_date, 'YYYYMMDD')
                    || '"',
                    '"'
                    || to_char(c.plan_end_date + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0),
                               'YYYYMMDD')
                    || '"',
                    nvl(c.minimum_election, 0) minimum_election,
                    c.maximum_election,
                    '"'
                    || to_char(c.plan_end_date + nvl(c.grace_period, 0),
                               'YYYYMMDD')
                    || '"',
                    c.ben_plan_id,
                    c.iias_enable,
                    c.iias_options,
                    c.external_deductible
                from
                    enterprise                b,
                    account                   a,
                    ben_plan_enrollment_setup c,
                    ben_plan_history          d
                where
                        b.entrp_id = a.entrp_id
                    and c.ben_plan_id = d.ben_plan_id
                    and ( c.minimum_election <> d.minimum_election
                          or c.maximum_election <> d.minimum_election )
                    and a.acc_id = c.acc_id
                    and c.plan_end_date + nvl(c.grace_period, 0) + nvl(c.runout_period_days, 0) > sysdate - 90 --Vanitha 08/21/2017: added grace and runout
                    and b.address is not null
                    and b.city is not null
                    and b.state is not null
                    and b.zip is not null
                    and a.account_type in ( 'FSA', 'HRA' )
                    and a.account_status not in ( 4, 5 )
                    and c.status = 'A'
                    and nvl(c.plan_docs_flag, 'N') = 'N'
                    and nvl(c.created_in_bps, 'Y') = 'Y'
                    and d.ben_plan_history_id in (
                        select
                            max(ben_plan_history_id)
                        from
                            ben_plan_history e
                        where
                            e.ben_plan_id = d.ben_plan_id
                    )
            );

        l_record_count := 1 + nvl(l_employer_tbl.count, 0) + ( l_employer_plan_tbl.count ) * 1;

        if l_employer_tbl.count + l_employer_plan_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('EMPLOYER_DEMOG');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_employer_demog.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_record_count)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_ER_Demg_IS'
                      || ','
                      || 'STL_Result_ER_Demg'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IB record now, IB is for employee demographics ***/
        for i in 1..l_employer_tbl.count loop
            l_line := 'IS'                              -- Record ID
                      || ','
                      || g_tpa_id                        -- TPA ID
                      || ','
                      || l_employer_tbl(i).employer_id   -- Employer ID
                      || ','
                      || l_employer_tbl(i).employer_name -- Employer Name
                      || ','
                      || l_employer_tbl(i).address       -- Address
                      || ','
                      || l_employer_tbl(i).city          -- City
                      || ','
                      || l_employer_tbl(i).state         -- State
                      || ','
                      || l_employer_tbl(i).zip           -- Zip
                      || ','
                      || l_employer_tbl(i).country       -- Country
                      || ','
                      || l_employer_tbl(i).phone_number  -- phone_number
                      || ','
                      || l_employer_tbl(i).fax_number  -- fax_number
                      || ','
                      || l_employer_tbl(i).email_address  -- email_address
                      || ','
                      || l_employer_tbl(i).setup_email_address  -- setup_email_address
                      || ','
                      || l_employer_tbl(i).projected_accounts  -- projected_accounts
                      || ','
                      || l_employer_tbl(i).employer_card_option  -- employer_card_option
                      || ',GHRA'
                      || l_employer_tbl(i).employer_id        -- Record Tracking Number
                      || ',32'; -- employer options, Allow splitting across plan designs

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        for i in 1..l_employer_plan_tbl.count loop
            l_line := 'IU'                              -- Record ID
                      || ','
                      || g_tpa_id                        -- TPA ID
                      || ','
                      || l_employer_plan_tbl(i).employer_id   -- Employer ID
                      || ','
                      || l_employer_plan_tbl(i).plan_id -- plan_id
                      || ','
                      || l_employer_plan_tbl(i).plan_type       -- plan_type
                      || ','
                      || l_employer_plan_tbl(i).start_date          -- start_date
                      || ','
                      || l_employer_plan_tbl(i).end_date         -- end_date
                      || ','
                      || l_employer_plan_tbl(i).runout_period           -- runout_period
                      || ','
                      || l_employer_plan_tbl(i).minimum_election       -- minumum_election
                      || ','
                      || l_employer_plan_tbl(i).maximum_election  -- maximum_election
                      || ','
                      || l_employer_plan_tbl(i).record_number -- Record Tracking Number
                      || ','
                      || l_employer_plan_tbl(i).grace_period -- grace period
                      || ','
                      || l_employer_plan_tbl(i).iias_enable -- iias enable
                      || ','
                      || l_employer_plan_tbl(i).iias_options -- iias options
                      || ','
                      || l_employer_plan_tbl(i).external_deductible -- external_deductible
                      || ','
                      || '2' -- Default Plan Options
                      || ','
                      || '0'
                      || ','
                      || null
              /*  ||','||CASE WHEN l_employer_plan_tbl(i).plan_type IN ('"TRN"','"PKG"') THEN
                        1 ELSE 0 END   -- Spending Limit Period
                ||','||CASE WHEN l_employer_plan_tbl(i).plan_type IN ('"TRN"','"PKG"') THEN
                       260 /* pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT'
                                         ,l_employer_plan_tbl(i).plan_type
                                         ,CASE WHEN TO_CHAR(SYSDATE,'MON') IN ('NOV','DEC') THEN
                                             ADD_MONTHS(trunc(sysdate,'YEAR'),12)+1
                                          ELSE SYSDATE END) -- Spending Transaction Amount
                      ELSE NULL END*/;

            dbms_output.put_line('plan type '
                                 || l_employer_plan_tbl(i).plan_type
                                 || ':'
                                 || case
                when l_employer_plan_tbl(i).plan_type in('"TRN"', '"PKG"') then
                    1
                else 0
            end);

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            p_file_name := l_file_name;
            utl_file.fclose(file => l_utl_id);
        end if;

    exception
        when result_exception then
            insert_alert('Error in Creating Employer Demographic File', l_message);
            raise;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Employer Demographic File', l_sqlerrm);
            raise;
    end employer_demg;

    procedure hra_ee_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl hra_ee_creation_tab;
        l_plan_tbl        plan_tab;
        l_dep_plan_tbl    dep_plan_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        l_message         varchar2(32000);
        l_card_count      number;
        mass_card_create exception;
        no_card_create exception;
        l_term_date       varchar2(10) := null;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            a.acc_num                               employee_id,
            d.bps_acc_num                           employer_id,
            bp.ben_plan_name                        plan_id,
            bp.plan_type,
            '"'
            || substr(b.last_name, 1, 26)
            || '"'                                  last_name,
            '"'
            || substr(b.first_name, 1, 19)
            || '"'                                  first_name,
            '"'
            || substr(b.middle_name, 1, 1)
            || '"'                                  middle_name,
            '"'
            || b.address
            || '"'                                  address,
            '"'
            || b.city
            || '"'                                  city,
            '"'
            || b.state
            || '"'                                  state,
            '"'
            ||
            case
                when length(b.zip) < 5 then
                        lpad(b.zip, 5, '0')
                else
                    b.zip
            end
            || '"'                                  zip,
            decode(b.gender, 'M', 1, 'F', 2,
                   0)                               gender,
            to_char(b.birth_date, 'YYYYMMDD')       birth_date,
            substr(b.drivlic, 1, 20)                drivlic,
            to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
            to_char(a.start_date, 'YYYYMMDD')       effective_date,
            null                                    email,
            null                                    annual_election,
            c.status,
            decode(c.issue_conditional, 'Y', '4', 'Yes', '4',
                   'YES', '4', '2')                 issue_card,
            null,
            null,
            lpad(
                replace(
                    replace(b.ssn, '-'),
                    ' '
                ),
                9,
                '0'
            ),
            nvl(c.pin_mailer, 'N'),
            nvl(c.shipping_method, '1')
        bulk collect
        into l_card_create_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            card_debit                c,
            ben_plan_enrollment_setup bp
        where
                a.pers_id = b.pers_id
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type = 'HRA'
            and b.first_name is not null
            and b.last_name is not null
            and b.address is not null
            and b.city is not null
            and b.state is not null
            and bp.plan_type <> 'ACO'
            and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
            and c.status (+) = 1
            and bp.annual_election > 0
            and d.entrp_id = b.entrp_id
            and b.pers_id = c.card_id (+)
            and a.bps_acc_num is null
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
            and d.bps_acc_num is not null;

        select
            d.bps_acc_num                           employer_id,
            bp.ben_plan_name                        plan_id,
            a.acc_num                               employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
            2 -- Active
            ,
            bp.annual_election,
            '0'                                     employee_contrib,
            '0'                                     employer_contrib,
            to_char((case
                when bp.effective_date > bp.plan_end_date then
                    bp.plan_end_date
                when bp.effective_date < bp.plan_start_date then
                    bp.plan_start_date
                when bp.effective_date between bp.plan_start_date and bp.plan_end_date then
                    bp.effective_date
                else bp.plan_start_date
            end), 'YYYYMMDD')                       effective_date,
            to_char((case
                when bp.sf_ordinance_flag = 'Y' then
                    bp.effective_end_date + 90 -- As per SFHCO rules we need to make the card
                when bp.effective_end_date < bp.effective_date then
                    bp.effective_date
                when bp.effective_end_date > bp.plan_end_date then
                    bp.plan_end_date
                when bp.effective_end_date < bp.plan_start_date then
                    bp.plan_start_date
                else bp.effective_end_date
            end), 'YYYYMMDD')                       termination_date,
            bp.ben_plan_id
        bulk collect
        into l_plan_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            ben_plan_enrollment_setup bp
        where
                a.pers_id = b.pers_id
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type = 'HRA'
            and bp.plan_type <> 'ACO'
            and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
            and b.first_name is not null
            and b.last_name is not null
            and b.address is not null
            and b.city is not null
            and b.state is not null
            and d.entrp_id = b.entrp_id
            and d.bps_acc_num is not null
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
            and nvl(created_in_bps, 'N') = 'N'
            and d.bps_acc_num is not null
            and bp.annual_election > 0
        order by
            employee_id desc;

       -- Dependents gets renewed automatically
        select
            d.bps_acc_num                           employer_id,
            a.acc_num                               employee_id,
            dep.pers_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')   end_date
        bulk collect
        into l_dep_plan_tbl
        from
            account                   a,
            person                    b,
            person                    depe,
            account                   d,
            ben_plan_enrollment_setup bp,
            metavante_outbound        dep
        where
                a.pers_id = b.pers_id
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type = 'HRA'
            and depe.pers_main = b.pers_id
            and d.entrp_id = b.entrp_id
            and d.bps_acc_num is not null
            and dep.acc_num = a.acc_num
            and depe.pers_id = dep.pers_id
            and dep.action = 'DEPENDANT_INSERT'
            and dep.processed_flag = 'Y'
            and bp.plan_type <> 'ACO'
            and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
            and nvl(bp.effective_end_date, sysdate) >= sysdate
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
            and nvl(created_in_bps, 'N') = 'N'
            and d.bps_acc_num is not null
            and bp.annual_election > 0
        order by
            employee_id desc;

        l_card_count := l_card_create_tbl.count + l_plan_tbl.count + l_dep_plan_tbl.count;
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card is not null then
                l_card_count := l_card_count + 1;
            end if;
        end loop;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 5000 then
                l_message := 'ALERT!!!! More than 5000 HRA ee creations are requested, verify before sending the request';
                raise mass_card_create;
            else
                if get_file_name('HRA_EE_CREATION', 'RESULT') is not null then
                    l_message := 'ALERT!!!! Card creation file from previous day has not been processed yet ';
                    raise mass_card_create;
                end if;

                if p_file_name is null then
                    l_file_id := insert_file_seq('HRA_EE_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_hra_ee_create.mbi';
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char(l_card_count + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_HRA_EE_Create '
                          || ','
                          || 'STL_Result_HRA_EE_Create'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IB'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || l_card_create_tbl(i).employer_id     -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id     -- Employee ID
                      || ','
                      || l_card_create_tbl(i).last_name       -- Last Name
                      || ','
                      || l_card_create_tbl(i).first_name      -- First Name
                      || ','
                      || l_card_create_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_card_create_tbl(i).address         -- Address
                      || ','
                      || l_card_create_tbl(i).city            -- City
                      || ','
                      || l_card_create_tbl(i).state           -- State
                      || ','
                      || l_card_create_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ','
                      || '2'                                  -- Employee Status, 2 - Active
                      || ','
                      || l_card_create_tbl(i).gender          -- Gender
                      || ','
                      || l_card_create_tbl(i).birth_date      -- Birth Date
                      || ',CNEW_'
                      || l_card_create_tbl(i).employee_id    -- Record Tracking Number
                      || ','
                      || l_card_create_tbl(i).ssn
                      || ','
                      || '0'; -- Medicare Beneficiary

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;
        for i in 1..l_plan_tbl.count loop
            l_line := 'IC'                                -- Record ID
                      || ','
                      || g_tpa_id                          -- TPA ID
                      || ','
                      || l_plan_tbl(i).employer_id             -- Employer ID
                      || ','
                      || l_plan_tbl(i).plan_id                 -- Plan ID
                      || ','
                      || l_plan_tbl(i).employee_id             -- Employee ID
                      || ','
                      || l_plan_tbl(i).plan_type               -- Account Type Code
                      || ','
                      || l_plan_tbl(i).start_date              -- Plan Start Date
                      || ','
                      || l_plan_tbl(i).end_date                -- Plan End Date
                      || ','
                      || '2'                                   -- Account Status , 2 - Active
                      || ','
                      || l_plan_tbl(i).annual_election  -- Annual Election
                      || ','
                      || '0'                                   -- Employee Pay Period Election
                      || ','
                      || '0'                                   -- Employer Pay Period Election
                      || ','
                      || l_plan_tbl(i).effective_date          -- Effective Date
                      || ',CNEW_'
                      || l_plan_tbl(i).record_number        -- Record Tracking Number
                      || ','
                      || l_plan_tbl(i).termination_date;       -- termination date

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card = 1 then
                l_line := 'IF'                                           -- Record ID
                          || ','
                          || g_tpa_id                    -- TPA ID
                          || ','
                          || l_card_create_tbl(i).employer_id                -- Employer ID
                          || ','
                          || l_card_create_tbl(i).employee_id        -- Employee ID
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')              -- Issue Date
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')              -- Card Effective Date
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || l_card_create_tbl(i).issue_conditional           -- Issue Card
                          || ','
                          || l_card_create_tbl(i).shipping_method             -- Shipping Method Code, 1 - US Mail
                          || ',CNEW_'
                          || l_card_create_tbl(i).employee_id        -- Record Tracking Number
                          || ','
                          || l_card_create_tbl(i).pin_mailer;

                if l_line is not null then
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;

            end if;
        end loop;

       -- Dependent Renewal Plans
        for i in 1..l_dep_plan_tbl.count loop
            l_line := 'IE'                                     -- Record ID
                      || ','
                      || g_tpa_id                               -- TPA ID
                      || ','
                      || l_dep_plan_tbl(i).employer_id       -- Employer ID
                      || ','
                      || l_dep_plan_tbl(i).employee_id       -- Employee ID
                      || ','
                      || l_dep_plan_tbl(i).dep_id            -- Dependant ID
                      || ','
                      || l_dep_plan_tbl(i).plan_type         -- Account Type Code
                      || ','
                      || l_dep_plan_tbl(i).start_date        -- Plan Start Date
                      || ','
                      || l_dep_plan_tbl(i).end_date          -- Plan End Date
                      || ',CRENEWDEP_'
                      || l_dep_plan_tbl(i).dep_id;   -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_card_create then
            insert_alert('Error in Creating HRA Employee Creation File', l_message);
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating HRA Employee Creation File', l_sqlerrm);
    end hra_ee_creation;

    procedure hra_dep_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl hra_ee_creation_tab;
        l_plan_tbl        plan_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_card_create exception;
        no_card_create exception;
        l_card_count      number;
    begin


        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select distinct
            a.acc_num                            employee_id,
            d.bps_acc_num                        employer_id,
            null                                 plan_id,
            null                                 plan_type,
            '"'
            || substr(depe.last_name, 1, 26)
            || '"'                               last_name,
            '"'
            || substr(depe.first_name, 1, 19)
            || '"'                               first_name,
            '"'
            || substr(depe.middle_name, 1, 1)
            || '"'                               middle_name,
            '"'
            || b.address
            || '"'                               address,
            '"'
            || b.city
            || '"'                               city,
            '"'
            || b.state
            || '"'                               state,
            '"'
            ||
            case
                when length(b.zip) < 5 then
                        lpad(b.zip, 5, '0')
                else
                    b.zip
            end
            || '"'                               zip,
            decode(depe.gender, 'M', 1, 'F', 2,
                   0)                            gender,
            to_char(depe.birth_date, 'YYYYMMDD') birth_date,
            substr(depe.drivlic, 1, 20)          drivlic,
            null                                 start_date,
            null                                 end_date,
            to_char(a.start_date, 'YYYYMMDD')    effective_date,
            null                                 email,
            null                                 annual_election,
            c.status,
            case
                when c.card_id is null then
                    null
                else
                    decode(c.issue_conditional, 'Y', '4', 'YES', '4',
                           'Yes', '4', '2')
            end                                  issue_card,
            dep.pers_id,
            decode(depe.relat_code, 2, 1, 3, 2,
                   9, 0)                         relative,
            lpad(
                replace(
                    replace(depe.ssn, '-'),
                    ' '
                ),
                9,
                '0'
            ),
            nvl(c.pin_mailer, '0')               pin_mailer,
            nvl(c.shipping_method, '1')
        bulk collect
        into l_card_create_tbl
        from
            account            a,
            person             b,
            person             depe,
            account            d,
            card_debit         c,
            metavante_outbound dep
        where
                a.pers_id = b.pers_id
            and b.pers_id = depe.pers_main
            and a.acc_num = dep.acc_num
            and depe.pers_id (+) = dep.pers_id
            and dep.action = 'DEPENDANT_INSERT'
            and dep.processed_flag = 'N'
            and depe.pers_main = b.pers_id
            and dep.pers_id = c.card_id (+)
            and a.complete_flag = 1
            and a.account_status = 1
            and c.status (+) = 1
            and a.account_type = 'HRA'
            and d.entrp_id = b.entrp_id
            and a.bps_acc_num is not null
            and exists (
                select
                    *
                from
                    ben_plan_enrollment_setup bp
                where
                        bp.acc_id = a.acc_id
                    and plan_end_date > sysdate
                    and nvl(bp.effective_end_date, sysdate) >= sysdate
                    and bp.annual_election > 0
            );
                   --  AND plan_start_date < NVL(EFFECTIVE_END_DATE,SYSDATE) );
                   ---- Removed this condition on 12/23/2021 to allow dependent card for future effective date.
        /*AND bp.acc_id = d.acc_id
        AND bp.status = 'A'
        AND bp.plan_end_date > sysdate
        AND bp.plan_type IS NOT NULL*/

        select
            d.bps_acc_num                              employer_id,
            bp.ben_plan_name                           plan_id,
            a.acc_num                                  employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD')    start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')      end_date,
            null -- Active
            ,
            null,
            '0'                                        employee_contrib,
            '0'                                        employer_contrib,
            to_char(bp.effective_date, 'YYYYMMDD')     effective_date,
            to_char(bp.effective_end_date, 'YYYYMMDD') termination_date,
            c.pers_id
        bulk collect
        into l_plan_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            person                    c,
            ben_plan_enrollment_setup bp,
            metavante_outbound        dep
        where
                dep.action = 'DEPENDANT_INSERT'
            and dep.processed_flag = 'N'
            and a.pers_id = b.pers_id
            and b.pers_id = c.pers_main
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type = 'HRA'
            and d.entrp_id = b.entrp_id
            and c.pers_id = dep.pers_id
            and bp.acc_id = a.acc_id
            and a.bps_acc_num is not null
            and bp.status = 'A'
            and bp.annual_election > 0
            and bp.plan_end_date > sysdate
            and nvl(bp.effective_end_date, sysdate) >= sysdate
            and plan_start_date < nvl(effective_end_date, sysdate)
        order by
            a.acc_num desc;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 5000 then
                null;
            else
                if p_file_name is null then
                    l_file_id := insert_file_seq('HRA_DEP_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_hra_dep_create.mbi';
                    dbms_output.put_line('file id ' || l_file_id);
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_card_count := l_card_create_tbl.count + l_plan_tbl.count;
                for i in 1..l_card_create_tbl.count loop
                    if l_card_create_tbl(i).debit_card is not null then
                        l_card_count := l_card_count + 1;
                    end if;
                end loop;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char(l_card_count + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Dep_Card_Creation'
                          || ','
                          || 'STL_Result_Dep_Card_Creation'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'ID'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || l_card_create_tbl(i).employer_id     -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                      || ','
                      || l_card_create_tbl(i).last_name       -- Last Name
                      || ','
                      || l_card_create_tbl(i).first_name      -- First Name
                      || ','
                      || l_card_create_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_card_create_tbl(i).address         -- Address
                      || ','
                      || l_card_create_tbl(i).city            -- City
                      || ','
                      || l_card_create_tbl(i).state           -- State
                      || ','
                      || l_card_create_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ','
                      || l_card_create_tbl(i).dep_id          -- Dependant ID
                      || ','
                      || l_card_create_tbl(i).relative        -- Relation
                      || ',CNEWDEP_'
                      || l_card_create_tbl(i).dep_id   -- Record Tracking Number
                      || ','
                      || l_card_create_tbl(i).birth_date            -- Birth date
                      || ','
                      || l_card_create_tbl(i).ssn;    -- SSN
       --     ||'Y';    -- Medicare beneficiary

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;
        for i in 1..l_plan_tbl.count loop
            l_line := 'IE'                                     -- Record ID
                      || ','
                      || g_tpa_id                               -- TPA ID
                      || ','
                      || l_plan_tbl(i).employer_id       -- Employer ID
                      || ','
                      || l_plan_tbl(i).employee_id       -- Employee ID
                      || ','
                      || l_plan_tbl(i).record_number            -- Dependant ID
                      || ','
                      || l_plan_tbl(i).plan_type         -- Account Type Code
                      || ','
                      || l_plan_tbl(i).start_date        -- Plan Start Date
                      || ','
                      || l_plan_tbl(i).end_date          -- Plan End Date
                      || ',CNEWDEP_'
                      || l_plan_tbl(i).record_number;   -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card = 1 then
                l_line := 'IF'                                           -- Record ID
                          || ','
                          || g_tpa_id                                 -- TPA ID
                          || ','
                          || l_card_create_tbl(i).employer_id         -- Employer ID
                          || ','
                          || l_card_create_tbl(i).employee_id         -- Employee ID
                          || ','
                          || l_card_create_tbl(i).dep_id              -- Dependant ID
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || l_card_create_tbl(i).issue_conditional   -- Issue Card
                          || ','
                          || l_card_create_tbl(i).shipping_method             -- Shipping Method Code, 1 - US Mail
                          || ',CNEWDEP_'
                          || l_card_create_tbl(i).dep_id            -- Record Tracking Number
                          || ','
                          || l_card_create_tbl(i).pin_mailer;               -- PIN mailer

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_file_name := l_file_name;
    exception
        when mass_card_create then
            insert_alert('ALERT!!!! Error in Creating HRA Dependant Card Creation File', 'ALERT!!!! More than 200 dependant debit card creations are requested, verify before sending the request'
            );
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating HRA Dependant Card Creation File', l_sqlerrm);
    end hra_dep_creation;

    procedure fsa_dep_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl hra_ee_creation_tab;
        l_plan_tbl        plan_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_card_create exception;
        no_card_create exception;
        l_card_count      number;
    begin


        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            a.acc_num                            employee_id,
            d.bps_acc_num                        employer_id,
            null                                 plan_id,
            null                                 plan_type,
            '"'
            || substr(
                strip_special_char(depe.last_name),
                1,
                26
            )
            || '"'                               last_name,
            '"'
            || substr(
                strip_special_char(depe.first_name),
                1,
                19
            )
            || '"'                               first_name,
            '"'
            || substr(depe.middle_name, 1, 1)
            || '"'                               middle_name,
            '"'
            || b.address
            || '"'                               address,
            '"'
            || b.city
            || '"'                               city,
            '"'
            || b.state
            || '"'                               state,
            '"'
            ||
            case
                when length(b.zip) < 5 then
                        lpad(b.zip, 5, '0')
                else
                    b.zip
            end
            || '"'                               zip,
            decode(depe.gender, 'M', 1, 'F', 2,
                   0)                            gender,
            to_char(depe.birth_date, 'YYYYMMDD') birth_date,
            substr(depe.drivlic, 1, 20)          drivlic,
            null                                 start_date,
            null                                 end_date,
            to_char(a.start_date, 'YYYYMMDD')    effective_date,
            null                                 email,
            null                                 annual_election,
            c.status,
            case
                when c.card_id is null then
                    null
                else
                    decode(c.issue_conditional, 'Y', '4', 'YES', '4',
                           'Yes', '4', '2')
            end                                  issue_card,
            dep.pers_id,
            decode(depe.relat_code, 2, 1, 3, 2,
                   9, 0)                         relative,
            lpad(
                replace(
                    replace(depe.ssn, '-'),
                    ' '
                ),
                9,
                '0'
            ),
            nvl(c.pin_mailer, '0')               pin_mailer,
            nvl(c.shipping_method, '1')
        bulk collect
        into l_card_create_tbl
        from
            account            a,
            person             b,
            person             depe,
            account            d,
            card_debit         c,
            metavante_outbound dep
        where
                a.pers_id = b.pers_id
            and b.pers_id = depe.pers_main
            and a.acc_num = dep.acc_num
            and depe.pers_id (+) = dep.pers_id
            and dep.action = 'DEPENDANT_INSERT'
            and dep.processed_flag = 'N'
            and depe.pers_main = b.pers_id
            and dep.pers_id = c.card_id (+)
            and a.complete_flag = 1
            and a.account_status = 1
            and c.status (+) = 1
            and a.account_type = 'FSA'
            and d.entrp_id = b.entrp_id
            and a.bps_acc_num is not null
            and exists (
                select
                    *
                from
                    ben_plan_enrollment_setup bp
                where
                        bp.acc_id = a.acc_id
                    and plan_end_date > sysdate
                    and nvl(bp.effective_end_date, sysdate) >= sysdate
                    and bp.annual_election > 0
                    and plan_start_date < nvl(effective_end_date, sysdate)
            );
        /*AND bp.acc_id = d.acc_id
        AND bp.status = 'A'
        AND bp.plan_end_date > sysdate
        AND bp.plan_type IS NOT NULL*/

        select
            d.bps_acc_num                              employer_id,
            bp.ben_plan_name                           plan_id,
            a.acc_num                                  employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD')    start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')      end_date,
            null -- Active
            ,
            null,
            '0'                                        employee_contrib,
            '0'                                        employer_contrib,
            to_char(bp.effective_date, 'YYYYMMDD')     effective_date,
            to_char(bp.effective_end_date, 'YYYYMMDD') termination_date,
            c.pers_id
        bulk collect
        into l_plan_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            person                    c,
            ben_plan_enrollment_setup bp,
            metavante_outbound        dep
        where
                a.pers_id = b.pers_id
            and b.pers_id = c.pers_main
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type = 'FSA'
            and d.entrp_id = b.entrp_id
            and c.pers_id = dep.pers_id
            and dep.action = 'DEPENDANT_INSERT'
            and dep.processed_flag = 'N'
            and a.bps_acc_num is not null
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
            and d.bps_acc_num is not null
            and bp.plan_end_date > sysdate
            and nvl(bp.effective_end_date, sysdate) >= sysdate
            and plan_start_date < trunc(nvl(effective_end_date, sysdate))
            and plan_start_date <> trunc(nvl(effective_end_date, sysdate))
        order by
            a.acc_num desc;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 10000 then
                null;
            else
                if p_file_name is null then
                    l_file_id := insert_file_seq('FSA_DEP_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_fsa_dep_create.mbi';
                    dbms_output.put_line('file id ' || l_file_id);
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_card_count := l_card_create_tbl.count + l_plan_tbl.count;
                for i in 1..l_card_create_tbl.count loop
                    if l_card_create_tbl(i).debit_card is not null then
                        l_card_count := l_card_count + 1;
                    end if;
                end loop;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char(l_card_count + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Dep_Card_Creation'
                          || ','
                          || 'STL_Result_Dep_Card_Creation'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'ID'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || l_card_create_tbl(i).employer_id     -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                      || ','
                      || l_card_create_tbl(i).last_name       -- Last Name
                      || ','
                      || l_card_create_tbl(i).first_name      -- First Name
                      || ','
                      || l_card_create_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_card_create_tbl(i).address         -- Address
                      || ','
                      || l_card_create_tbl(i).city            -- City
                      || ','
                      || l_card_create_tbl(i).state           -- State
                      || ','
                      || l_card_create_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ','
                      || l_card_create_tbl(i).dep_id          -- Dependant ID
                      || ','
                      || l_card_create_tbl(i).relative        -- Relation
                      || ',CNEWDEP_'
                      || l_card_create_tbl(i).dep_id   -- Record Tracking Number
                      || ','
                      || l_card_create_tbl(i).birth_date            -- Birth date
                      || ','
                      || l_card_create_tbl(i).ssn;    -- SSN
       --     ||'Y';    -- Medicare beneficiary

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;
        for i in 1..l_plan_tbl.count loop
            l_line := 'IE'                                     -- Record ID
                      || ','
                      || g_tpa_id                               -- TPA ID
                      || ','
                      || l_plan_tbl(i).employer_id       -- Employer ID
                      || ','
                      || l_plan_tbl(i).employee_id       -- Employee ID
                      || ','
                      || l_plan_tbl(i).record_number            -- Dependant ID
                      || ','
                      || l_plan_tbl(i).plan_type         -- Account Type Code
                      || ','
                      || l_plan_tbl(i).start_date        -- Plan Start Date
                      || ','
                      || l_plan_tbl(i).end_date          -- Plan End Date
                      || ',CNEWDEP_'
                      || l_plan_tbl(i).record_number;   -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card = 1 then
                l_line := 'IF'                                           -- Record ID
                          || ','
                          || g_tpa_id                                 -- TPA ID
                          || ','
                          || l_card_create_tbl(i).employer_id         -- Employer ID
                          || ','
                          || l_card_create_tbl(i).employee_id         -- Employee ID
                          || ','
                          || l_card_create_tbl(i).dep_id              -- Dependant ID
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || l_card_create_tbl(i).issue_conditional   -- Issue Card
                          || ','
                          || l_card_create_tbl(i).shipping_method             -- Shipping Method Code, 1 - US Mail
                          || ',CNEWDEP_'
                          || l_card_create_tbl(i).dep_id            -- Record Tracking Number
                          || ','
                          || l_card_create_tbl(i).pin_mailer;               -- PIN mailer

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_file_name := l_file_name;
    exception
        when mass_card_create then
            insert_alert('ALERT!!!! Error in Creating FSA Dependant Card Creation File', 'ALERT!!!! More than 200 dependant debit card creations are requested, verify before sending the request'
            );
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating FSA Dependant Card Creation File', l_sqlerrm);
    end fsa_dep_creation;

  /** Use this to post annual election for plans other than HRA and FSA **/
    procedure plan_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id     utl_file.file_type;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_plan_tbl   plan_tab;
        l_sqlerrm    varchar2(32000);
        l_file_id    number;
        l_message    varchar2(32000);
        l_plan_count number;
        mass_card_create exception;
        no_card_create exception;
        l_term_date  varchar2(10) := null;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            d.bps_acc_num                              employer_id,
            bp.ben_plan_name                           plan_id,
            a.acc_num                                  employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD')    start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')      end_date,
            2 -- Active
            ,
            decode(bp.funding_type, 'PRE_FUND', null, bp.annual_election),
            '0'                                        employee_contrib,
            '0'                                        employer_contrib,
            to_char(bp.effective_date, 'YYYYMMDD')     effective_date,
            to_char(bp.effective_end_date, 'YYYYMMDD') termination_date,
            bp.ben_plan_id
        bulk collect
        into l_plan_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            ben_plan_enrollment_setup bp
        where
                a.pers_id = b.pers_id
     --   AND  TRUNC(A.start_date) <= TRUNC(SYSDATE)
            and a.complete_flag = 1
            and a.account_status = 1
            and bp.plan_type = 'HRP'
            and d.entrp_id = b.entrp_id
            and a.bps_acc_num is not null
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
            and d.acc_num = 'GHRA394912'
            and not exists (
                select
                    *
                from
                    metavante_card_balances mcb
                where
                        mcb.acc_num = a.acc_num
                    and mcb.plan_type = bp.plan_type
                    and mcb.plan_start_date = bp.plan_start_date
                    and mcb.plan_end_date = bp.plan_end_date
            )
       -- AND NVL(created_in_bps,'N') = 'N'
            and bp.plan_end_date > sysdate
        order by
            employee_id desc;

        l_plan_count := l_plan_tbl.count;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_plan_tbl.count = 0 then
            raise no_card_create;
        else

            /* IF get_file_name('HRA_EE_CREATION','RESULT') IS NOT NULL THEN
                 l_message := 'ALERT!!!! Card creation file from previous day has not been processed yet ';
                 RAISE mass_card_create;
              END IF;*/

            if p_file_name is null then
                l_file_id := insert_file_seq('HRA_EE_CREATION');
                l_file_name := 'MB_'
                               || l_file_id
                               || 'hrp_hr5.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_plan_count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_HRA_EE_Create '
                      || ','
                      || 'STL_Result_HRA_EE_Create'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );

       --   END IF;
        end if;

        l_line := null;
        for i in 1..l_plan_tbl.count loop
            l_line := 'IC'                                -- Record ID
                      || ','
                      || g_tpa_id                          -- TPA ID
                      || ','
                      || l_plan_tbl(i).employer_id             -- Employer ID
                      || ','
                      || l_plan_tbl(i).plan_id                 -- Plan ID
                      || ','
                      || l_plan_tbl(i).employee_id             -- Employee ID
                      || ','
                      || l_plan_tbl(i).plan_type               -- Account Type Code
                      || ','
                      || l_plan_tbl(i).start_date              -- Plan Start Date
                      || ','
                      || l_plan_tbl(i).end_date                -- Plan End Date
                      || ','
                      || '2'                                   -- Account Status , 2 - Active
                      || ','
                      || l_plan_tbl(i).annual_election  -- Annual Election
                      || ','
                      || '0'                                   -- Employee Pay Period Election
                      || ','
                      || '0'                                   -- Employer Pay Period Election
                      || ','
                      || l_plan_tbl(i).effective_date          -- Effective Date
                      || ',CNEW_'
                      || l_plan_tbl(i).record_number        -- Record Tracking Number
                      || ','
                      || l_plan_tbl(i).termination_date;       -- termination date

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;


    --   END LOOP;
        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_card_create then
            insert_alert('Error in Creating FSA Plan Creation File', l_message);
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating HRA Employee Creation File', l_sqlerrm);
    end plan_creation;

    procedure fsa_ee_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl hra_ee_creation_tab;
        l_plan_tbl        plan_tab;
        l_dep_plan_tbl    dep_plan_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        l_message         varchar2(32000);
        l_card_count      number;
        mass_card_create exception;
        no_card_create exception;
        l_term_date       varchar2(10) := null;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        /** Demographics and Card Creation **/
        select
            a.acc_num                         employee_id,
            d.bps_acc_num                     employer_id,
            null                              plan_id,
            null                              plan_type,
            '"'
            || substr(b.last_name, 1, 26)
            || '"'                            last_name,
            '"'
            || substr(b.first_name, 1, 19)
            || '"'                            first_name,
            '"'
            || substr(b.middle_name, 1, 1)
            || '"'                            middle_name,
            '"'
            || b.address
            || '"'                            address,
            '"'
            || b.city
            || '"'                            city,
            '"'
            || b.state
            || '"'                            state,
            '"'
            ||
            case
                when length(b.zip) < 5 then
                        lpad(b.zip, 5, '0')
                else
                    b.zip
            end
            || '"'                            zip,
            decode(b.gender, 'M', 1, 'F', 2,
                   0)                         gender,
            to_char(b.birth_date, 'YYYYMMDD') birth_date,
            substr(b.drivlic, 1, 20)          drivlic,
            null                              start_date,
            null                              end_date,
            to_char(a.start_date, 'YYYYMMDD') effective_date,
            null                              email,
            null                              annual_election,
            c.status,
            decode(
                upper(c.issue_conditional),
                'Y',
                '4',
                'YES',
                '4',
                '2'
            )                                 issue_card,
            null,
            null,
            lpad(
                replace(
                    replace(b.ssn, '-'),
                    ' '
                ),
                9,
                '0'
            ),
            nvl(c.pin_mailer, '0'),
            nvl(c.shipping_method, '1')
        bulk collect
        into l_card_create_tbl
        from
            account    a,
            person     b,
            account    d,
            card_debit c
        where
                a.pers_id = b.pers_id
     --   AND  TRUNC(A.start_date) <= TRUNC(SYSDATE)
            and a.complete_flag = 1
            and a.account_status = 1
            and c.status (+) = 1
            and a.account_type = 'FSA'
            and d.entrp_id = b.entrp_id
            and b.pers_id = c.card_id (+)
            and exists (
                select
                    *
                from
                    ben_plan_enrollment_setup bp
                where
                        bp.acc_id = a.acc_id
                     -- AND bp.annual_election > 0
                    and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
                    and nvl(bp.effective_end_date, sysdate) >= sysdate
            )
            and a.bps_acc_num is null
            and d.bps_acc_num is not null;

        -- Plan information
        select
            d.bps_acc_num                              employer_id,
            bp.ben_plan_name                           plan_id,
            a.acc_num                                  employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD')    start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')      end_date,
            2 -- Active
             --, DECODE(bp.funding_type,'PRE_FUND',null,bp.annual_election)
            ,
            bp.annual_election,
            '0'                                        employee_contrib,
            '0'                                        employer_contrib,
            to_char(bp.effective_date, 'YYYYMMDD')     effective_date,
            to_char(bp.effective_end_date, 'YYYYMMDD') termination_date,
            bp.ben_plan_id
        bulk collect
        into l_plan_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            ben_plan_enrollment_setup bp
        where
                a.pers_id = b.pers_id
     --   AND  TRUNC(A.start_date) <= TRUNC(SYSDATE)
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type = 'FSA'
            and d.entrp_id = b.entrp_id
            and d.bps_acc_num is not null
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
            and nvl(created_in_bps, 'N') = 'N'
            and nvl(bp.effective_end_date, sysdate) >= sysdate
            and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > trunc(sysdate, 'yyyy')
        --AND bp.annual_election > 0
   --     AND bp.plan_end_date > sysdate
        order by
            employee_id desc;
       -- Dependents gets renewed automatically
        select
            d.bps_acc_num                           employer_id,
            a.acc_num                               employee_id,
            dep.pers_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')   end_date
        bulk collect
        into l_dep_plan_tbl
        from
            account                   a,
            person                    b,
            person                    depe,
            account                   d,
            ben_plan_enrollment_setup bp,
            metavante_outbound        dep
        where
                a.pers_id = b.pers_id
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type = 'FSA'
            and depe.pers_main = b.pers_id
            and d.entrp_id = b.entrp_id
            and d.bps_acc_num is not null
            and dep.acc_num = a.acc_num
            and depe.pers_id = dep.pers_id
            and dep.action = 'DEPENDANT_INSERT'
            and dep.processed_flag = 'Y'
            and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
            and nvl(bp.effective_end_date, sysdate) >= sysdate
            and bp.annual_election > 0
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
    --    AND NVL(created_in_bps,'N') = 'N'
            and bp.plan_end_date > sysdate
        order by
            employee_id desc;

        l_card_count := l_card_create_tbl.count + l_plan_tbl.count + l_dep_plan_tbl.count;
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card is not null then
                l_card_count := l_card_count + 1;
            end if;
        end loop;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 2000 then
                l_message := 'ALERT!!!! More than 2000 HRA ee creations are requested, verify before sending the request';
                raise mass_card_create;
            else

            /* IF get_file_name('HRA_EE_CREATION','RESULT') IS NOT NULL THEN
                 l_message := 'ALERT!!!! Card creation file from previous day has not been processed yet ';
                 RAISE mass_card_create;
              END IF;*/

                if p_file_name is null then
                    l_file_id := insert_file_seq('FSA_EE_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_fsa_ee_create.mbi';
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char(l_card_count + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_HRA_EE_Create '
                          || ','
                          || 'STL_Result_HRA_EE_Create'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            l_line := 'IB'                    -- Record ID
                      || ','
                      || g_tpa_id                             -- TPA ID
                      || ','
                      || l_card_create_tbl(i).employer_id     -- Employer ID
                      || ','
                      || l_card_create_tbl(i).employee_id     -- Employee ID
    --            ||','||l_card_create_tbl(i).prefix          -- Prefix
                      || ','
                      || l_card_create_tbl(i).last_name       -- Last Name
                      || ','
                      || l_card_create_tbl(i).first_name      -- First Name
                      || ','
                      || l_card_create_tbl(i).middle_name     -- Middle Name
                      || ','
                      || l_card_create_tbl(i).address         -- Address
                      || ','
                      || l_card_create_tbl(i).city            -- City
                      || ','
                      || l_card_create_tbl(i).state           -- State
                      || ','
                      || l_card_create_tbl(i).zip             -- Zip
                      || ','
                      || 'US'                                 -- Country
                      || ','
                      || '2'                                  -- Employee Status, 2 - Active
                      || ','
                      || l_card_create_tbl(i).gender          -- Gender
                      || ','
                      || l_card_create_tbl(i).birth_date      -- Birth Date
                      || ',CNEW_'
                      || l_card_create_tbl(i).employee_id    -- Record Tracking Number
                      || ','
                      || l_card_create_tbl(i).ssn  -- ssn
                      || ','
                      || '0';       -- Medicare beneficiary

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;
        for i in 1..l_plan_tbl.count loop
            l_line := 'IC'                                -- Record ID
                      || ','
                      || g_tpa_id                          -- TPA ID
                      || ','
                      || l_plan_tbl(i).employer_id             -- Employer ID
                      || ','
                      || l_plan_tbl(i).plan_id                 -- Plan ID
                      || ','
                      || l_plan_tbl(i).employee_id             -- Employee ID
                      || ','
                      || l_plan_tbl(i).plan_type               -- Account Type Code
                      || ','
                      || l_plan_tbl(i).start_date              -- Plan Start Date
                      || ','
                      || l_plan_tbl(i).end_date                -- Plan End Date
                      || ','
                      || '2'                                   -- Account Status , 2 - Active
                      || ','
                      || l_plan_tbl(i).annual_election  -- Annual Election
                      || ','
                      || '0'                                   -- Employee Pay Period Election
                      || ','
                      || '0'                                   -- Employer Pay Period Election
                      || ','
                      || l_plan_tbl(i).effective_date          -- Effective Date
                      || ',CNEW_'
                      || l_plan_tbl(i).record_number        -- Record Tracking Number
                      || ','
                      || l_plan_tbl(i).termination_date;       -- termination date

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card = 1 then
                l_line := 'IF'                                           -- Record ID
                          || ','
                          || g_tpa_id                    -- TPA ID
                          || ','
                          || l_card_create_tbl(i).employer_id                -- Employer ID
                          || ','
                          || l_card_create_tbl(i).employee_id        -- Employee ID
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')              -- Issue Date
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')              -- Card Effective Date
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || l_card_create_tbl(i).issue_conditional           -- Issue Card
                          || ','
                          || l_card_create_tbl(i).shipping_method             -- Shipping Method Code, 1 - US Mail
                          || ',CNEW_'
                          || l_card_create_tbl(i).employee_id        -- Record Tracking Number
                          || ','
                          || l_card_create_tbl(i).pin_mailer;

                if l_line is not null then
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;

            end if;
        end loop;
       -- Dependent Renewal Plans
        for i in 1..l_dep_plan_tbl.count loop
            l_line := 'IE'                                     -- Record ID
                      || ','
                      || g_tpa_id                               -- TPA ID
                      || ','
                      || l_dep_plan_tbl(i).employer_id       -- Employer ID
                      || ','
                      || l_dep_plan_tbl(i).employee_id       -- Employee ID
                      || ','
                      || l_dep_plan_tbl(i).dep_id            -- Dependant ID
                      || ','
                      || l_dep_plan_tbl(i).plan_type         -- Account Type Code
                      || ','
                      || l_dep_plan_tbl(i).start_date        -- Plan Start Date
                      || ','
                      || l_dep_plan_tbl(i).end_date          -- Plan End Date
                      || ',CRENEWDEP_'
                      || l_dep_plan_tbl(i).dep_id;   -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_card_create then
            insert_alert('Error in Creating HRA Employee Creation File', l_message);
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating HRA Employee Creation File', l_sqlerrm);
    end fsa_ee_creation;

    procedure hra_deposits (
        p_acc_num_list      in varchar2 default null,
        p_deposit_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_deposit_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_deposit_tbl  deposit_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
        mass_card_create exception;
        l_message           varchar2(3200);
    begin
      /** Posting the deposits ***/
      /** IH record is for all deposits **/
        if get_file_name('HRA_FSA_DEPOSIT', 'RESULT') is not null then
            l_message := 'ALERT!!!! Deposit file from previous day has not been processed yet ';
            raise mass_card_create;
        end if;

        select
            d.bps_acc_num                           employer_id,
            a.acc_num                               employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
            bp.ben_plan_name,
            decode(inc.fee_code, 17, 6, 1) -- if hra/fsa rollover then it is other deposit
            ,
            decode(inc.fee_code,
                   17,
                   0,
                   nvl(inc.amount_add, 0)),
            decode(inc.fee_code,
                   17,
                   nvl(inc.amount_add, 0) + nvl(inc.amount, 0),
                   nvl(inc.amount, 0)) -- bps expects values like this, if not we get errorInvalid Employer Deposit Amount for Deposit Type.
                   ,
            inc.change_num,
            to_char(fee_date, 'YYYYMMDD')           fee_date,
            pc_lookups.get_fee_reason(inc.fee_code) merchant_name,
            null
        bulk collect
        into l_card_deposit_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            ben_plan_enrollment_setup bp,
            income                    inc
        where
                a.pers_id = b.pers_id
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type in ( 'FSA', 'HRA' )
            and d.entrp_id = b.entrp_id
            and trunc(inc.fee_date) >= trunc(bp.plan_start_date)
            and trunc(inc.fee_date) <= trunc(bp.plan_end_date)
            and nvl(bp.effective_end_date, sysdate) >= trunc(sysdate)
            and ( inc.fee_code = 17
                  or inc.fee_code <> 17
                  and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) >= trunc(sysdate) )
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
            and bp.created_in_bps = 'Y'
            and a.bps_acc_num is not null --IN ('GFSA012250')--= NVL(p_acc_num_list,a.acc_num)
       -- AND d.bps_acc_num  = 'STLPRONET'
            and inc.acc_id = a.acc_id
            and nvl(inc.debit_card_posted, 'N') = 'N'
            and inc.transaction_type <> 'P'
            and inc.fee_code <> 12
    --   and inc.fee_date > '30-JAN-2011'
            and d.bps_acc_num is not null
            and inc.plan_type = bp.plan_type
            and nvl(inc.amount, 0) + nvl(inc.amount_add, 0) <> 0
        order by
            employee_id desc;

        if l_card_deposit_tbl.count > 0 then
            if p_deposit_file_name is null then
                l_file_id := insert_file_seq('HRA_FSA_DEPOSIT');
                l_deposit_file_name := 'MB_'
                                       || l_file_id
                                       || '_hra_fsa_deposit.mbi';
            else
                l_deposit_file_name := p_deposit_file_name;
            end if;

            update metavante_files
            set
                file_name = l_deposit_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_deposit_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_deposit_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Annual_Election_Deposit'
                      || ','
                      || 'STL_Annual_Election_Deposit_Result'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_deposit_tbl.count loop
            l_line := 'IH'                                 -- Record ID
                      || ','
                      || g_tpa_id                              -- TPA ID
                      || ','
                      || l_card_deposit_tbl(i).employer_id     -- Employer ID
                      || ','
                      || l_card_deposit_tbl(i).employee_id     -- Employee ID
                      || ','
                      || l_card_deposit_tbl(i).account_type_code    -- Account Type Code
                      || ','
                      || l_card_deposit_tbl(i).plan_start_date -- Plan Start Date
                      || ','
                      || l_card_deposit_tbl(i).plan_end_date   -- Plan End Date
                      || ','
                      || l_card_deposit_tbl(i).deposit_type    -- Deposit Type, 1 - Other
                      || ','
                      || l_card_deposit_tbl(i).employee_amount    -- Employee Deposit Amount
                      || ','
                      || l_card_deposit_tbl(i).employer_amount    -- Employer Deposit Amount
                      || ','
                      || 0 -- Override Amount flag
                      || ','
                      || l_card_deposit_tbl(i).change_num          -- Record Tracking Number
                      || ','
                      || l_card_deposit_tbl(i).transaction_date    -- Display Date
                      || ','
                      || l_card_deposit_tbl(i).merchant_name;      -- Note

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_deposit_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_deposit_file_name := l_deposit_file_name;
    exception
        when mass_card_create then
            insert_alert('Error in Creating Deposit File', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);

       /* mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
               ,'Error in Creating Deposit/Payment file'
               ,l_sqlerrm);*/
    end hra_deposits;

 /** Use this to post annual election for plans other than HRA and FSA **/
 -- NOT USED
    procedure deposit_annual_election (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id              utl_file.file_type;
        l_file_name           varchar2(3200);
        l_line                varchar2(32000);
        l_plan_tbl            plan_tab;
        l_card_deposit_tbl    deposit_tab;
        l_annual_election_tbl deposit_tab;
        l_sqlerrm             varchar2(32000);
        l_file_id             number;
        l_message             varchar2(32000);
        l_plan_count          number;
        l_deposit_count       number;
        l_annual_election     number;
        mass_card_create exception;
        no_card_create exception;
        l_term_date           varchar2(10) := null;
    begin

        -- For all the plans send receipt records other than annual election

        select
            d.bps_acc_num                           employer_id,
            a.acc_num                               employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
            bp.ben_plan_name,
            1,
            nvl(inc.amount_add, 0),
            nvl(inc.amount, 0),
            inc.change_num,
            to_char(fee_date, 'YYYYMMDD')           fee_date,
            pc_lookups.get_fee_reason(inc.fee_code) merchant_name,
            null
        bulk collect
        into l_card_deposit_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            ben_plan_enrollment_setup bp,
            income                    inc
        where
                a.pers_id = b.pers_id
            and a.complete_flag = 1
            and a.account_status = 1
            and a.account_type in ( 'FSA', 'HRA' )
            and d.entrp_id = b.entrp_id
            and trunc(inc.fee_date) >= trunc(bp.plan_start_date)
            and trunc(inc.fee_date) <= trunc(bp.plan_end_date)
            and nvl(bp.effective_end_date, sysdate) >= trunc(sysdate)
            and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) >= trunc(sysdate)
            and bp.acc_id = a.acc_id
            and bp.status = 'A'
      --  AND d.acc_num= NVL(p_acc_num_list,a.acc_num)
            and inc.acc_id = a.acc_id
            and nvl(inc.debit_card_posted, 'N') = 'N'
            and inc.transaction_type <> 'P'
            and inc.fee_code <> 12
            and d.bps_acc_num = 'STL012495'
            and inc.plan_type = bp.plan_type
            and nvl(inc.amount, 0) + nvl(inc.amount_add, 0) <> 0
        order by
            employee_id desc;

        l_deposit_count := l_card_deposit_tbl.count;
        l_annual_election := l_annual_election_tbl.count;
       /*** Writing IB record now, IB is for employee demographics ***/
        if l_annual_election + l_deposit_count = 0 then
            raise no_card_create;
        else
            if get_file_name('HRA_ANNUAL_ELECTION_DEPOSITS', 'RESULT') is not null then
                l_message := 'ALERT!!!! Deposit/Annual election file has not been processed yet , please process the result before sending new one'
                ;
                raise mass_card_create;
            end if;

            if p_file_name is null then
                l_file_id := insert_file_seq('HRA_ANNUAL_ELECTION_DEPOSITS');
                l_file_name := 'MB_'
                               || l_file_id
                               || 'annual_election_deposits.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_annual_election + l_deposit_count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Annual_Election_Deposit'
                      || ','
                      || 'STL_Annual_Election_Deposit_Result'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );

       --   END IF;
        end if;

        l_line := null;
        for i in 1..l_card_deposit_tbl.count loop
            l_line := 'IH'                                 -- Record ID
                      || ','
                      || g_tpa_id                              -- TPA ID
                      || ','
                      || l_card_deposit_tbl(i).employer_id     -- Employer ID
                      || ','
                      || l_card_deposit_tbl(i).employee_id     -- Employee ID
                      || ','
                      || l_card_deposit_tbl(i).account_type_code    -- Account Type Code
                      || ','
                      || l_card_deposit_tbl(i).plan_start_date -- Plan Start Date
                      || ','
                      || l_card_deposit_tbl(i).plan_end_date   -- Plan End Date
                      || ','
                      || l_card_deposit_tbl(i).deposit_type    -- Deposit Type, 1 - Other
                      || ','
                      || l_card_deposit_tbl(i).employee_amount    -- Employee Deposit Amount
                      || ','
                      || l_card_deposit_tbl(i).employer_amount    -- Employer Deposit Amount
                      || ','
                      || 0 -- Override Amount flag
                      || ','
                      || l_card_deposit_tbl(i).change_num          -- Record Tracking Number
                      || ','
                      || l_card_deposit_tbl(i).transaction_date    -- Display Date
                      || ','
                      || l_card_deposit_tbl(i).merchant_name;      -- Note

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

    --   END LOOP;
        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_card_create then
            dbms_output.put_line('More than 2000 records ');
            insert_alert('Error in Creating FSA Plan Creation File', l_message);
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            dbms_output.put_line('OTHERS exception ' || sqlerrm);
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating HRA Employee Creation File', l_sqlerrm);
    end deposit_annual_election;

    procedure hra_fsa_terminate (
        p_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_terminate_tbl     plan_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
        l_message           varchar2(32000);
        l_termination_count number;
        mass_terminate exception;
        no_terminate exception;
        l_term_date         varchar2(10) := null;
    begin

    /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        if get_file_name('HRA_FSA_PLAN_TERMINATION', 'RESULT') is not null then
            l_message := 'ALERT!!!! Card creation file from previous day has not been processed yet ';
            raise mass_terminate;
        end if;

        select distinct
            *
        bulk collect
        into l_terminate_tbl
        from
            (
                select
                    d.bps_acc_num                           employer_id,
                    bp.ben_plan_name                        plan_id,
                    a.acc_num                               employee_id,
                    bp.plan_type,
                    to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
                    to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
                    case
                        when trunc(bp.effective_end_date) = trunc(sysdate) then
                            5
                        when bp.sf_ordinance_flag = 'Y'                    then
                            2
                        else
                            5
                    end
               -- , DECODE(bp.funding_type,'PRE_FUND',null,bp.annual_election)
                    ,
                    bp.annual_election,
                    '0'                                     employee_contrib,
                    '0'                                     employer_contrib,
                    to_char(bp.effective_date, 'YYYYMMDD')  effective_date,
                    to_char((case
                        when bp.sf_ordinance_flag = 'Y' then
                            greatest(
                                least(bp.effective_end_date, bp.plan_end_date),
                                bp.plan_end_date
                            ) + 90 -- As per SFHCO rules we need to make the card
                        when bp.effective_end_date < bp.effective_date then
                            bp.effective_date
                        when bp.effective_end_date > bp.plan_end_date then
                            bp.plan_end_date
                        when bp.effective_end_date < bp.plan_start_date then
                            bp.plan_start_date
                        else bp.effective_end_date
                    end),
                            'YYYYMMDD')                     termination_date            -- work for 90 days and allow service dates , so we terminate after 90 days
                            ,
                    bp.ben_plan_id
                from
                    account                   a,
                    person                    b,
                    account                   d,
                    ben_plan_enrollment_setup bp
                where
                        a.pers_id = b.pers_id
                    and a.complete_flag = 1
         -- AND a.account_status =1(Removed on 06/29/2017 so that terminations can move if Employer is closed. SK)
                    and d.entrp_id = b.entrp_id
                    and d.account_status = 1
                    and a.bps_acc_num is not null
                    and bp.acc_id = a.acc_id
                    and d.account_type in ( 'HRA', 'FSA' )
                    and bp.status <> 'R'
    --      AND bp.status = 'I'
                    and bp.created_in_bps = 'Y'
                    and bp.terminated = 'N'
                    and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
                    and trunc(bp.effective_end_date) <= trunc(sysdate)
         --  AND bp.annual_election > 0  commented by Joshi for 11020
                union all
                select
                    d.bps_acc_num                           employer_id,
                    bp.ben_plan_name                        plan_id,
                    a.acc_num                               employee_id,
                    bp.plan_type,
                    to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
                    to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
                    case
                        when trunc(bp.effective_end_date) = trunc(sysdate) then
                            5
                        when bp.sf_ordinance_flag = 'Y'                    then
                            2
                        else
                            5
                    end
               -- , DECODE(bp.funding_type,'PRE_FUND',null,bp.annual_election)
                    ,
                    bp.annual_election,
                    '0'                                     employee_contrib,
                    '0'                                     employer_contrib,
                    to_char(bp.effective_date, 'YYYYMMDD')  effective_date,
                    to_char((case
                        when bp.sf_ordinance_flag = 'Y' then
                            greatest(
                                least(bp.effective_end_date, bp.plan_end_date),
                                bp.plan_end_date
                            ) + 90 -- As per SFHCO rules we need to make the card
                        when bp.effective_end_date < bp.effective_date then
                            bp.effective_date
                        when bp.effective_end_date > bp.plan_end_date then
                            bp.plan_end_date
                        when bp.effective_end_date < bp.plan_start_date then
                            bp.plan_start_date
                        else bp.effective_end_date
                    end),
                            'YYYYMMDD')                     termination_date            -- work for 90 days and allow service dates , so we terminate after 90 days
                            ,
                    bp.ben_plan_id
                from
                    account                   a,
                    person                    b,
                    account                   d,
                    ben_plan_enrollment_setup bp
                where
                        a.pers_id = b.pers_id
                    and a.complete_flag = 1
         -- AND a.account_status =1(Removed on 06/29/2017 so that terminations can move if Employer is closed. SK)
                    and d.account_status = 1
                    and d.entrp_id = b.entrp_id
                    and a.bps_acc_num is not null
                    and bp.acc_id = a.acc_id
                    and d.account_type in ( 'HRA', 'FSA' )
                    and bp.status <> 'R'
    --      AND bp.status = 'I'
                    and bp.created_in_bps = 'Y'
                    and bp.terminated = 'Y'
                    and trunc(bp.effective_end_date + 90) = trunc(sysdate)
                    and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
                    and bp.sf_ordinance_flag = 'Y'
         --  AND bp.annual_election > 0  commented by Joshi for 11020
   -- AND ROWNUM < 4
                union all -- ADDED THIS CLAUSE AND UNIONING THE SAME ROWS BECAUSE OF BPS BUG WE FOUND ON 3/31/2014
                select
                    d.bps_acc_num                           employer_id,
                    bp.ben_plan_name                        plan_id,
                    a.acc_num                               employee_id,
                    bp.plan_type,
                    to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
                    to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
                    case
                        when trunc(bp.effective_end_date) = trunc(sysdate) then
                            5
                        when bp.sf_ordinance_flag = 'Y'                    then
                            2
                        else
                            5
                    end
               -- , DECODE(bp.funding_type,'PRE_FUND',null,bp.annual_election)
                    ,
                    bp.annual_election,
                    '0'                                     employee_contrib,
                    '0'                                     employer_contrib,
                    to_char(bp.effective_date, 'YYYYMMDD')  effective_date,
                    to_char((case
                        when bp.sf_ordinance_flag = 'Y' then
                            greatest(
                                least(bp.effective_end_date, bp.plan_end_date),
                                bp.plan_end_date
                            ) + 90 -- As per SFHCO rules we need to make the card
                        when bp.effective_end_date < bp.effective_date then
                            bp.effective_date
                        when bp.effective_end_date > bp.plan_end_date then
                            bp.plan_end_date
                        when bp.effective_end_date < bp.plan_start_date then
                            bp.plan_start_date
                        else bp.effective_end_date
                    end),
                            'YYYYMMDD')                     termination_date            -- work for 90 days and allow service dates , so we terminate after 90 days
                            ,
                    bp.ben_plan_id
                from
                    account                   a,
                    person                    b,
                    account                   d,
                    ben_plan_enrollment_setup bp
                where
                        a.pers_id = b.pers_id
                    and a.complete_flag = 1
                    and a.account_status = 1
         -- AND d.account_status =1(Removed on 06/29/2017 so that terminations can move if Employer is closed. SK)
                    and d.entrp_id = b.entrp_id
                    and a.bps_acc_num is not null
                    and bp.acc_id = a.acc_id
                    and d.account_type in ( 'HRA', 'FSA' )
                    and bp.status <> 'R'
    --      AND bp.status = 'I'
         --  AND bp.annual_election > 0  commented by Joshi for 11020
                    and bp.created_in_bps = 'Y'
                    and bp.terminated = 'N'
                    and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
                    and trunc(bp.effective_end_date) <= trunc(sysdate)
                union all -- ADDED THIS CLAUSE AND UNIONING THE SAME ROWS BECAUSE OF BPS BUG WE FOUND ON 3/31/2014
                select
                    d.bps_acc_num                           employer_id,
                    bp.ben_plan_name                        plan_id,
                    a.acc_num                               employee_id,
                    bp.plan_type,
                    to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
                    to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
                    case
                        when trunc(bp.effective_end_date) = trunc(sysdate) then
                            5
                        when bp.sf_ordinance_flag = 'Y'                    then
                            2
                        else
                            5
                    end
               -- , DECODE(bp.funding_type,'PRE_FUND',null,bp.annual_election)
                    ,
                    bp.annual_election,
                    '0'                                     employee_contrib,
                    '0'                                     employer_contrib,
                    to_char(bp.effective_date, 'YYYYMMDD')  effective_date,
                    to_char((case
                        when bp.sf_ordinance_flag = 'Y' then
                            greatest(
                                least(bp.effective_end_date, bp.plan_end_date),
                                bp.plan_end_date
                            ) + 90 -- As per SFHCO rules we need to make the card
                        when bp.effective_end_date < bp.effective_date then
                            bp.effective_date
                        when bp.effective_end_date > bp.plan_end_date then
                            bp.plan_end_date
                        when bp.effective_end_date < bp.plan_start_date then
                            bp.plan_start_date
                        else bp.effective_end_date
                    end),
                            'YYYYMMDD')                     termination_date            -- work for 90 days and allow service dates , so we terminate after 90 days
                            ,
                    bp.ben_plan_id
                from
                    account                   a,
                    person                    b,
                    account                   d,
                    ben_plan_enrollment_setup bp
                where
                        a.pers_id = b.pers_id
                    and a.complete_flag = 1
                    and a.account_status = 1
         -- AND d.account_status =1(Removed on 06/29/2017 so that terminations can move if Employer is closed. SK)
                    and d.entrp_id = b.entrp_id
                    and a.bps_acc_num is not null
                    and bp.acc_id = a.acc_id
                    and d.account_type in ( 'HRA', 'FSA' )
                    and bp.plan_type in ( 'TRN', 'PKG', 'UA1' )
                    and bp.status <> 'R'
    --      AND bp.status = 'I'
        --  AND nvl(bp.annual_election,0) = 0  commented by Joshi for 11020
                    and bp.created_in_bps = 'Y'
                    and bp.terminated = 'N'
                    and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) > sysdate
                    and trunc(bp.effective_end_date) <= trunc(sysdate)
            )
        order by
            employee_id desc;

        l_termination_count := l_terminate_tbl.count;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_termination_count = 0 then
            raise no_terminate;
        else
            if p_file_name is null then
                l_file_id := insert_file_seq('HRA_FSA_PLAN_TERMINATION');
                l_file_name := 'MB_'
                               || l_file_id
                               || 'hra_fsa_termination.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char((l_terminate_tbl.count) + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Terminate'
                      || ','
                      || 'STL_Result_Terminate'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );

       --   END IF;
        end if;

        l_line := null;
        for i in 1..l_terminate_tbl.count loop
            l_line := 'IC'                                -- Record ID
                      || ','
                      || g_tpa_id                          -- TPA ID
                      || ','
                      || l_terminate_tbl(i).employer_id             -- Employer ID
                      || ','
                      || l_terminate_tbl(i).plan_id                 -- Plan ID
                      || ','
                      || l_terminate_tbl(i).employee_id             -- Employee ID
                      || ','
                      || l_terminate_tbl(i).plan_type               -- Account Type Code
                      || ','
                      || l_terminate_tbl(i).start_date              -- Plan Start Date
                      || ','
                      || l_terminate_tbl(i).end_date                -- Plan End Date
                      || ','
                      || l_terminate_tbl(i).status                  -- Account Status , 5 - Terminated
                      || ','
                      || '0'                                        -- Employee Pay Period Election
                      || ','
                      || '0'                                        -- Employer Pay Period Election
                      || ','
                      || l_terminate_tbl(i).termination_date       -- termination date
                      || ',PTRM_'
                      || l_terminate_tbl(i).record_number        -- Record Tracking Number
                      || ','
                      || l_terminate_tbl(i).effective_date        -- effective_date
                      || ','
                      || l_terminate_tbl(i).annual_election;      -- Annual election

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_terminate then
            insert_alert('Error in Creating HRA/FSA Employee Termination File', l_message);
        when no_terminate then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating HRA/FSA Employee Termination File', l_sqlerrm);
    end hra_fsa_terminate;

    procedure hra_fsa_card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl hra_ee_creation_tab;
        l_plan_tbl        plan_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_card_create exception;
        no_card_create exception;
        l_card_count      number;
    begin


        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/
        select
            a.acc_num                            employee_id,
            d.bps_acc_num                        employer_id,
            null                                 plan_id,
            null                                 plan_type,
            '"'
            || substr(depe.last_name, 1, 26)
            || '"'                               last_name,
            '"'
            || substr(depe.first_name, 1, 19)
            || '"'                               first_name,
            '"'
            || substr(depe.middle_name, 1, 1)
            || '"'                               middle_name,
            '"'
            || b.address
            || '"'                               address,
            '"'
            || b.city
            || '"'                               city,
            '"'
            || b.state
            || '"'                               state,
            '"'
            ||
            case
                when length(b.zip) < 5 then
                        lpad(b.zip, 5, '0')
                else
                    b.zip
            end
            || '"'                               zip,
            decode(depe.gender, 'M', 1, 'F', 2,
                   0)                            gender,
            to_char(depe.birth_date, 'YYYYMMDD') birth_date,
            substr(depe.drivlic, 1, 20)          drivlic,
            null                                 start_date,
            null                                 end_date,
            to_char(a.start_date, 'YYYYMMDD')    effective_date,
            null                                 email,
            null                                 annual_election,
            c.card_id,
            case
                when c.card_id is null then
                    null
                else
                    decode(c.issue_conditional, 'Y', '4', 'YES', '4',
                           'Yes', '4', '2')
            end                                  issue_card,
            depe.pers_id,
            decode(depe.relat_code, 2, 1, 3, 2,
                   9, 0)                         relative,
            lpad(
                replace(
                    replace(b.ssn, '-'),
                    ' '
                ),
                9,
                '0'
            ),
            nvl(c.pin_mailer, '0'),
            nvl(c.shipping_method, '1')
        bulk collect
        into l_card_create_tbl
        from
            account    a,
            person     b,
            person     depe,
            account    d,
            card_debit c
        where
                a.pers_id = b.pers_id
            and depe.pers_main = b.pers_id
            and depe.pers_id = c.card_id
            and d.bps_acc_num = nvl(p_acc_num_list, d.bps_acc_num)
    /*   AND NOT EXISTS ( SELECT * FROM          metavante_outbound dep
                         WHERE depe.pers_id = dep.pers_id
                            AND dep.action = 'DEPENDANT_INSERT'
                            and dep.processed_flag = 'N'
                            AND dep.acc_num = a.acc_num
                            AND dep.pers_id = c.card_id)*/
            and a.complete_flag = 1
            and a.account_status = 1
            and c.status = 1
            and exists (
                select
                    *
                from
                    ben_plan_enrollment_setup bp
                where
                        bp.acc_id = a.acc_id
                    and bp.status = 'A'
            )
            and a.account_type in ( 'HRA', 'FSA' )
            and d.entrp_id = b.entrp_id
            and a.bps_acc_num is not null;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 5000 then
                null;
            else
                if p_file_name is null then
                    l_file_id := insert_file_seq('HRA_FSA_DEP_CARD_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_hra_fsa_dcard_create.mbi';
                    dbms_output.put_line('file id ' || l_file_id);
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_card_count := l_card_create_tbl.count;
                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char(l_card_count + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_Dep_Card_Creation'
                          || ','
                          || 'STL_Result_Dep_Card_Creation'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;

       /*** Writing IF record now, IF is for card creation ***/
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card is not null then
                l_line := 'IF'                                           -- Record ID
                          || ','
                          || g_tpa_id                                 -- TPA ID
                          || ','
                          || l_card_create_tbl(i).employer_id         -- Employer ID
                          || ','
                          || l_card_create_tbl(i).employee_id         -- Employee ID
                          || ','
                          || l_card_create_tbl(i).dep_id              -- Dependant ID
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || l_card_create_tbl(i).issue_conditional   -- Issue Card
                          || ','
                          || l_card_create_tbl(i).shipping_method             -- Shipping Method Code, 1 - US Mail
                          || ',CNEWDEP_'
                          || l_card_create_tbl(i).dep_id            -- Record Tracking Number
                          || ','
                          || l_card_create_tbl(i).pin_mailer;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_file_name := l_file_name;
    exception
        when mass_card_create then
            insert_alert('ALERT!!!! Error in Creating Dependant Card Creation File', 'ALERT!!!! More than 200 dependant debit card creations are requested, verify before sending the request'
            );
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating Dependant Card Creation File', l_sqlerrm);
    end hra_fsa_card_creation;

    procedure annual_election (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id              utl_file.file_type;
        l_file_name           varchar2(3200);
        l_line                varchar2(32000);
        l_plan_tbl            plan_tab;
        l_annual_election_tbl deposit_tab;
        l_sqlerrm             varchar2(32000);
        l_file_id             number;
        l_message             varchar2(32000);
        l_plan_count          number;
        l_deposit_count       number;
        l_annual_election     number;
        mass_card_create exception;
        no_card_create exception;
        l_term_date           varchar2(10) := null;
    begin
        pc_log.log_error('PC_DEBIT_CARD', 'in the beginnin ');
        if get_file_name('ANNUAL_ELECTION', 'RESULT') is not null then
            pc_log.log_error('PC_DEBIT_CARD', 'Previous day file has not been posted ');
            l_message := 'ALERT!!!! Annual Election file from previous day has not been processed yet ';
            raise mass_card_create;
        end if;

        pc_log.log_error('PC_DEBIT_CARD', 'file generation start ');

      -- Posting annual election for plan types
      -- other than ('HRA','FSA','LPF')
        if p_acc_num_list is not null then
            select
                d.bps_acc_num                           employer_id,
                a.acc_num                               employee_id,
                bp.plan_type,
                to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
                to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
                bp.ben_plan_name,
                2 -- Annual Election
                ,
                sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0)),
                '0'                                     employer_contrib,
                bp.acc_id,
                case
                    when bp.plan_end_date < sysdate then
                        to_char(bp.plan_end_date, 'YYYYMMDD')
                    else
                        to_char(sysdate, 'YYYYMMDD')
                end                                     fee_date,
                'Annual Election',
                to_char(bp.effective_date, 'YYYYMMDD')
            bulk collect
            into l_annual_election_tbl
            from
                account                   a,
                person                    b,
                account                   d,
                ben_plan_enrollment_setup bp,
                income                    inc
            where
                a.acc_num in (
                    select
                        *
                    from
                        table ( cast(str2tbl(p_acc_num_list) as varchar2_4000_tbl) )
                )
                and a.pers_id = b.pers_id
                and a.complete_flag = 1
                and a.account_status = 1
                and a.account_type in ( 'HRA', 'FSA' )
                and d.entrp_id = b.entrp_id
                and a.bps_acc_num is not null
                and bp.acc_id = a.acc_id
                and bp.status = 'A'
                and inc.acc_id = bp.acc_id
                and inc.fee_code = 12 -- annual election
                and bp.created_in_bps = 'Y'
                and trunc(inc.fee_date) >= trunc(bp.plan_start_date)
                and trunc(inc.fee_date) <= trunc(bp.plan_end_date)
                and nvl(bp.effective_end_date, sysdate) >= trunc(sysdate)
                and bp.plan_type = inc.plan_type
                and exists (
                    select
                        *
                    from
                        income k
                    where
                            k.acc_id = a.acc_id
                        and nvl(k.debit_card_posted, 'N') = 'N'
                        and fee_code = 12
                )
                and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) >= trunc(sysdate)
            group by
                d.bps_acc_num,
                a.acc_num,
                bp.plan_type,
                bp.plan_start_date,
                bp.plan_end_date,
                bp.ben_plan_name,
                bp.acc_id,
                to_char(bp.effective_date, 'YYYYMMDD')
            having
                sum(nvl(inc.amount, 0)) > 0
            order by
                a.acc_num desc;

        else
            select
                d.bps_acc_num                           employer_id,
                a.acc_num                               employee_id,
                bp.plan_type,
                to_char(bp.plan_start_date, 'YYYYMMDD') start_date,
                to_char(bp.plan_end_date, 'YYYYMMDD')   end_date,
                bp.ben_plan_name,
                2 -- Annual Election
                ,
                sum(nvl(inc.amount, 0) + nvl(inc.amount_add, 0)),
                '0'                                     employer_contrib,
                bp.acc_id,
                case
                    when bp.plan_end_date < sysdate then
                        to_char(bp.plan_end_date, 'YYYYMMDD')
                    else
                        to_char(
                            greatest(bp.plan_start_date, sysdate),
                            'YYYYMMDD'
                        )
                end                                     fee_date,
                'Annual Election',
                to_char(bp.effective_date, 'YYYYMMDD')
            bulk collect
            into l_annual_election_tbl
            from
                account                   a,
                person                    b,
                account                   d,
                ben_plan_enrollment_setup bp,
                income                    inc
            where
                    a.pers_id = b.pers_id
                and a.complete_flag = 1
                and a.account_status = 1
                and a.account_type in ( 'HRA', 'FSA' )
                and d.entrp_id = b.entrp_id
                and a.bps_acc_num is not null
                and bp.acc_id = a.acc_id
                and bp.status = 'A'
                and inc.acc_id = bp.acc_id
                and inc.fee_code = 12 -- annual election
                and bp.created_in_bps = 'Y'
                and trunc(inc.fee_date) >= trunc(bp.plan_start_date)
                and trunc(inc.fee_date) <= trunc(bp.plan_end_date)
                and nvl(bp.effective_end_date, sysdate) >= trunc(sysdate)
                and bp.plan_type = inc.plan_type
                and exists (
                    select
                        *
                    from
                        income k
                    where
                            k.acc_id = a.acc_id
                        and nvl(k.debit_card_posted, 'N') = 'N'
                        and fee_code = 12
                )
                and trunc(bp.plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0) >= trunc(sysdate)
            group by
                d.bps_acc_num,
                a.acc_num,
                bp.plan_type,
                bp.plan_start_date,
                bp.plan_end_date,
                bp.ben_plan_name,
                bp.acc_id,
                to_char(bp.effective_date, 'YYYYMMDD')
            having
                sum(nvl(inc.amount, 0)) > 0
            order by
                a.acc_num desc;

        end if;

        pc_log.log_error('PC_DEBIT_CARD', ' l_annual_election_tbl ' || l_annual_election_tbl.count);
        if l_annual_election_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('ANNUAL_ELECTION');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_annual_election.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_annual_election_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Annual_Election_Deposit'
                      || ','
                      || 'STL_Annual_Election_Deposit_Result'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_annual_election_tbl.count loop
            if l_annual_election_tbl(i).account_type_code in ( 'FSA', 'LPF', 'HRA' ) then
                l_line := 'IH'                                 -- Record ID
                          || ','
                          || g_tpa_id                              -- TPA ID
                          || ','
                          || l_annual_election_tbl(i).employer_id     -- Employer ID
                          || ','
                          || l_annual_election_tbl(i).employee_id     -- Employee ID
                          || ','
                          || l_annual_election_tbl(i).account_type_code    -- Account Type Code
                          || ','
                          || l_annual_election_tbl(i).plan_start_date -- Plan Start Date
                          || ','
                          || l_annual_election_tbl(i).plan_end_date   -- Plan End Date
                          || ','
                          || l_annual_election_tbl(i).deposit_type    -- Deposit Type, 1 - Other
                          || ','
                          || l_annual_election_tbl(i).employee_amount    -- Employee Deposit Amount
                          || ','
                          || l_annual_election_tbl(i).employer_amount    -- Employer Deposit Amount
                          || ','
                          || 1 -- Override Amount flag
                          || ',ALEC_'
                          || l_annual_election_tbl(i).change_num          -- Record Tracking Number
                          || ','
                          || l_annual_election_tbl(i).transaction_date    -- Display Date
                          || ','
                          || l_annual_election_tbl(i).merchant_name;      -- Note

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end loop;

        for i in 1..l_annual_election_tbl.count loop
            if l_annual_election_tbl(i).account_type_code not in ( 'FSA', 'LPF', 'HRA' ) then
                l_line := 'IC'                                -- Record ID
                          || ','
                          || g_tpa_id                          -- TPA ID
                          || ','
                          || l_annual_election_tbl(i).employer_id             -- Employer ID
                          || ','
                          || l_annual_election_tbl(i).plan_name                 -- Plan ID
                          || ','
                          || l_annual_election_tbl(i).employee_id             -- Employee ID
                          || ','
                          || l_annual_election_tbl(i).account_type_code       -- Account Type Code
                          || ','
                          || l_annual_election_tbl(i).plan_start_date         -- Plan Start Date
                          || ','
                          || l_annual_election_tbl(i).plan_end_date                -- Plan End Date
                          || ','
                          || '2'                                   -- Account Status , 2 - Active
                          || ','
                          || l_annual_election_tbl(i).employee_amount  -- Annual Election
                          || ','
                          || '0'                                   -- Employee Pay Period Election
                          || ','
                          || '0'                                   -- Employer Pay Period Election
                          || ','
                          || l_annual_election_tbl(i).effective_date          -- Effective Date
                          || ',ALEC_'
                          || l_annual_election_tbl(i).change_num        -- Record Tracking Number
                          || ','
                          || '';       -- termination date

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_card_create then
            pc_log.log_error('PC_DEBIT_CARD', 'Error in Creating Deposit File' || l_message);
        when no_data_found then
            pc_log.log_error('PC_DEBIT_CARD', 'Error in Creating Deposit File: NO DATA FOUND ' || l_message);
        when others then
            l_sqlerrm := sqlerrm;
            pc_log.log_error('PC_DEBIT_CARD', 'Error in Creating Deposit File' || l_sqlerrm);
            dbms_output.put_line('sqlerrm ' || sqlerrm);

       /* mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
               ,'Error in Creating Deposit/Payment file'
               ,l_sqlerrm);*/
    end annual_election;

    procedure hra_fsa_claims (
        p_acc_num_list      in varchar2 default null,
        p_payment_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_deposit_file_name varchar2(3200);
        l_payment_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_payment_tbl  claim_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
        mass_card_create exception;
        l_message           varchar2(3200);
    begin
        l_line := null;
        l_file_id := null;

       /*** Posting disbursements ***/
       /** II is for all disbursements, pre auth and debit card purchases are excluded **/
        if p_acc_num_list is null then
            select
                *
            bulk collect
            into l_card_payment_tbl
            from
                (
                    select
                        b.acc_num,
                        nvl(a.amount, 0)                     amount,
                        '"'
                        || substr(
                            nvl((
                                select
                                    strip_bad(prov_name)
                                from
                                    claimn
                                where
                                    claim_id = a.claimn_id
                            ),
                                (
                                select
                                    reason_name
                                from
                                    pay_reason
                                where
                                    reason_code = a.reason_code
                            )),
                            1,
                            48
                        )
                        || '"'                               merchant_name,
                        to_char(pay_date, 'YYYYMMDD'),
                        a.change_num,
                        a.plan_type,
                        pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id),
                        0                                    reimbursement_method,
                        0                                    pay_provider,
                        1                                    bypass_deductible,
                        (
                            select
                                vendor_id
                            from
                                payment_register
                            where
                                claim_id = a.claimn_id
                        )                                    provider_id,
                        to_char(plan_start_date, 'YYYYMMDD') plan_start_date,
                        to_char(plan_end_date, 'YYYYMMDD')   plan_end_date,
                        a.change_num                         tracking_number,
                        a.claimn_id
                    from
                        claimn  c,
                        payment a,
                        account b
                    where
                            a.acc_id = b.acc_id
                        and c.claim_id = a.claimn_id
                        and c.pers_id = b.pers_id
                        and c.claim_status in ( 'PARTIALLY_PAID', 'PAID', 'DENIED' )-- sk 09/30/2021 Added denied status to adjustments to denied claim can go to debit card.
                        and nvl(a.debit_card_posted, 'N') = 'N'
                        and ( nvl(a.pay_source, 'EB') = 'EB'
                              or pay_source = 'PAYMENT'
                              or pay_source = 'OFFSET_PREVIOUS_YEAR'
                              or pay_source = 'PAYROLL' )
                        and a.reason_mode = 'P'
                        and a.amount <> 0
                        and pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id) is not null
          -- and     a.reason_code = 11
                        and b.account_type <> 'HSA'
                        and not exists (
                            select
                                *
                            from
                                metavante_adjustment_outbound xx
                            where
                                    xx.change_num = a.change_num
                                and xx.record_type = 'PAYMENT'
                        )
                    union
                    select
                        b.acc_num,
                        nvl(c.deductible_amount, 0)          amount,
                        '"'
                        || substr(
                            nvl((
                                select
                                    strip_bad(prov_name)
                                from
                                    claimn
                                where
                                    claim_id = a.claimn_id
                            ),
                                (
                                select
                                    reason_name
                                from
                                    pay_reason
                                where
                                    reason_code = a.reason_code
                            )),
                            1,
                            48
                        )
                        || '"'                               merchant_name,
                        to_char(pay_date, 'YYYYMMDD'),
                        a.change_num,
                        a.plan_type,
                        pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id),
                        0                                    reimbursement_method,
                        0                                    pay_provider,
                        0                                    bypass_deductible,
                        (
                            select
                                vendor_id
                            from
                                payment_register
                            where
                                claim_id = a.claimn_id
                        )                                    provider_id,
                        to_char(plan_start_date, 'YYYYMMDD') plan_start_date,
                        to_char(plan_end_date, 'YYYYMMDD')   plan_end_date,
                        a.change_num                         tracking_number,
                        a.claimn_id
                    from
                        claimn  c,
                        payment a,
                        account b
                    where
                            a.acc_id = b.acc_id
                        and c.claim_id = a.claimn_id
                        and c.pers_id = b.pers_id
                        and c.claim_status in ( 'PARTIALLY_PAID', 'PAID' )
                        and nvl(a.debit_card_posted, 'N') = 'N'
                        and ( nvl(a.pay_source, 'EB') = 'EB'
                              or pay_source = 'PAYMENT' )
                        and a.reason_mode = 'P'
                        and c.deductible_amount <> 0
          -- and     a.reason_code = 11
                        and b.account_type in ( 'HRA', 'FSA' )
                        and pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id) is not null
                        and not exists (
                            select
                                *
                            from
                                metavante_adjustment_outbound xx
                            where
                                    xx.change_num = a.change_num
                                and xx.record_type = 'PAYMENT'
                        )
                    union
                    select
                        b.acc_num,
                        nvl(a.amount, 0)                       amount,
                        '"'
                        || substr(
                            nvl(
                                strip_bad(prov_name),
                                (
                                    select
                                        reason_name
                                    from
                                        pay_reason
                                    where
                                        reason_code = a.reason_code
                                )
                            ),
                            1,
                            48
                        )
                        || '"'                                 merchant_name,
                        to_char(pay_date, 'YYYYMMDD'),
                        a.change_num,
                        a.plan_type,
                        pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id),
                        0                                      reimbursement_method,
                        0                                      pay_provider,
                        1                                      bypass_deductible,
                        (
                            select
                                vendor_id
                            from
                                payment_register
                            where
                                claim_id = a.claimn_id
                        )                                      provider_id,
                        to_char(c.plan_start_date, 'YYYYMMDD') plan_start_date,
                        to_char(c.plan_end_date, 'YYYYMMDD')   plan_end_date,
                        a.change_num                           tracking_number,
                        a.claimn_id
                    from
                        claimn                    c,
                        payment                   a,
                        account                   b,
                        ben_plan_enrollment_setup d
                    where
                        c.claim_status in ( 'PARTIALLY_PAID', 'PAID' )
                        and nvl(a.debit_card_posted, 'N') = 'N'
                        and d.plan_end_date + nvl(runout_period_days, 0) + nvl(d.grace_period, 0) + 180 > sysdate
                        and a.pay_date between add_months(sysdate, -24) and d.plan_end_date + nvl(runout_period_days, 0) + nvl(d.grace_period
                        , 0) + 180
                        and a.reason_mode = 'P'
                        and a.acc_id = b.acc_id
                        and c.claim_id = a.claimn_id
                        and c.pers_id = b.pers_id
                        and a.amount <> 0
                        and b.account_type <> 'HSA'
                        and a.acc_id = d.acc_id
                        and a.reason_code in ( 73, 121 )
                        and d.plan_start_date = c.plan_start_date
                        and d.plan_end_date = c.plan_end_date
                        and d.plan_type = c.service_type
                        and exists (
                            select
                                *
                            from
                                metavante_adjustment_outbound xx
                            where
                                    xx.change_num = a.change_num
                                and xx.record_type = 'PAYMENT'
                                and nvl(xx.debit_card_posted, 'N') = 'N'
                        )
                        and pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id) is not null
                    union
                    select
                        b.acc_num,
                        nvl(a.amount, 0)                               amount,
                        '"'
                        || substr(
                            nvl((
                                select
                                    strip_bad(prov_name)
                                from
                                    claimn
                                where
                                    claim_id = a.claimn_id
                            ),
                                (
                                select
                                    reason_name
                                from
                                    pay_reason
                                where
                                    reason_code = a.reason_code
                            )),
                            1,
                            48
                        )
                        || '"'                                         merchant_name,
                        to_char(pay_date, 'YYYYMMDD')                  pay_date,
                        a.change_num,
                        a.plan_type,
                        pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id) bps_acc_num,
                        0                                              reimbursement_method,
                        0                                              pay_provider,
                        1                                              bypass_deductible,
                        (
                            select
                                vendor_id
                            from
                                payment_register
                            where
                                claim_id = a.claimn_id
                        )                                              provider_id,
                        to_char(plan_start_date, 'YYYYMMDD')           plan_start_date,
                        to_char(plan_end_date, 'YYYYMMDD')             plan_end_date,
                        a.change_num                                   tracking_number,
                        a.claimn_id
                    from
                        claimn  c,
                        payment a,
                        account b,
                        checks  ch
                    where
                            a.acc_id = b.acc_id
                        and c.claim_id = a.claimn_id
                        and c.pers_id = b.pers_id
                        and c.claim_status in ( 'READY_TO_PAY' )
                        and ch.entity_type = 'CLAIMN'
                        and ch.entity_id = c.claim_id
                        and ch.acc_id = a.acc_id
                        and ch.check_amount = a.amount
                        and ch.status in ( 'READY', 'SENT' )
                        and trunc(ch.check_date) >= to_date('02/01/2024', 'mm/dd/yyyy')
                        and nvl(a.debit_card_posted, 'N') = 'N'
                        and ( nvl(a.pay_source, 'EB') = 'EB'
                              or pay_source = 'PAYMENT'
                              or pay_source = 'OFFSET_PREVIOUS_YEAR'
                              or pay_source = 'PAYROLL' )
                        and a.reason_mode = 'P'
                        and a.amount <> 0
                        and pc_entrp.get_bps_acc_num_from_acc_id(b.acc_id) is not null
          -- and     a.reason_code = 11
                        and b.account_type <> 'HSA'
                        and not exists (
                            select
                                *
                            from
                                metavante_adjustment_outbound xx
                            where
                                    xx.change_num = a.change_num
                                and xx.record_type = 'PAYMENT'
                        )
                );

        end if;

        if get_file_name('HRA_FSA_CLAIM', 'RESULT') is not null then
            l_message := 'ALERT!!!! HRA/FSA Payment file from previous day has not been processed yet ' || get_file_name('HRA_FSA_CLAIM'
            , 'RESULT');
            raise mass_card_create;
        end if;

        if l_card_payment_tbl.count > 0 then
            if p_payment_file_name is null then
                l_file_id := insert_file_seq('HRA_FSA_CLAIM');
                l_payment_file_name := 'MB_'
                                       || l_file_id
                                       || '_hra_fsa_claim.mbi';
            else
                l_payment_file_name := p_payment_file_name;
            end if;

            update metavante_files
            set
                file_name = l_payment_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_payment_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_payment_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_FSA_HRA_Claims'
                      || ','
                      || 'STL_Result_Payment'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_payment_tbl.count loop
            insert into metavante_adjustment_outbound (
                acc_num,
                acc_id,
                record_type,
                change_num,
                amount,
                debit_card_posted,
                creation_date
            )
                select
                    l_card_payment_tbl(i).employee_id,
                    acc_id,
                    'PAYMENT',
                    l_card_payment_tbl(i).change_num,
                    l_card_payment_tbl(i).amount,
                    'N',
                    sysdate
                from
                    account
                where
                    acc_num = l_card_payment_tbl(i).employee_id;

            l_line := 'II'                        -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || l_card_payment_tbl(i).employer_id                -- Employer ID
                      || ','
                      || l_card_payment_tbl(i).employee_id        -- Employee ID
                      || ','
                      || l_card_payment_tbl(i).plan_type              -- Account Type Code
                      || ','
                      || l_card_payment_tbl(i).merchant_name        -- Merchant Name
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service from
                      || ','
                      || l_card_payment_tbl(i).transaction_date      -- Date of Service to
                      || ','
                      || l_card_payment_tbl(i).amount                -- Approved Claim Amount
                      || ','
                      || l_card_payment_tbl(i).change_num            -- Record Tracking Number
                      || ','
                      || l_card_payment_tbl(i).provider_id           -- provider_id
                      || ','
                      || l_card_payment_tbl(i).reimbursement_method            -- reimbursement_method
                      || ','
                      || l_card_payment_tbl(i).pay_provider             -- pay_provider
                      || ','
                      || l_card_payment_tbl(i).bypass_deductible             -- bypass_deductible
                      || ','
                      || l_card_payment_tbl(i).plan_start_date             -- plan_start_date
                      || ','
                      || l_card_payment_tbl(i).plan_end_date             -- plan_end_date
                      || ','
                      || l_card_payment_tbl(i).claim_number;      -- External Claim Number


            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_payment_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_payment_file_name := l_payment_file_name;
    exception
        when mass_card_create then
            insert_alert('Error in Creating Payment file ', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Payment file ', l_sqlerrm);
       /* mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
               ,'Error in Creating Deposit/Payment file'
               ,l_sqlerrm);*/
    end hra_fsa_claims;

    procedure vendors (
        p_acc_num_list     in varchar2 default null,
        p_vendor_file_name in out varchar2
    ) is

        l_utl_id           utl_file.file_type;
        l_vendor_file_name varchar2(3200);
        l_line             varchar2(32000);
        l_vendor_tbl       vendors_tab;
        l_sqlerrm          varchar2(32000);
        l_file_id          number;
        mass_card_create exception;
        l_message          varchar2(3200);
    begin
        l_line := null;
        l_file_id := null;

       /*** Posting disbursements ***/
       /** II is for all disbursements, pre auth and debit card purchases are excluded **/
        if p_acc_num_list is null then
            select
                *
            bulk collect
            into l_vendor_tbl
            from
                (
                    select
                        c.vendor_id,
                        c.vendor_name,
                        c.address1
                        || ' '
                        || c.address2,
                        c.city,
                        c.state,
                        c.zip,
                        c.vendor_tax_id
                    from
                        payment          a,
                        payment_register b,
                        vendors          c
                    where
                            a.claimn_id = b.claim_id
                        and c.vendor_id = b.vendor_id
                        and nvl(c.vendor_in_peachtree, 'N') = 'N'
                        and nvl(a.debit_card_posted, 'N') = 'N'
                        and ( nvl(a.pay_source, 'EB') = 'EB'
                              or pay_source = 'PAYMENT' )
                        and a.reason_code = 11
                        and a.reason_mode = 'P'
                        and c.vendor_type is not null
                );

        end if;

        if get_file_name('HRA_FSA_VENDORS', 'RESULT') is not null then
            l_message := 'ALERT!!!! Vendor file from previous day has not been processed yet ';
            raise mass_card_create;
        end if;

        if l_vendor_tbl.count > 0 then
            if l_vendor_file_name is null then
                l_file_id := insert_file_seq('HRA_FSA_VENDORS');
                l_vendor_file_name := 'MB_'
                                      || l_file_id
                                      || '_hra_fsa_vendor.mbi';
            else
                l_vendor_file_name := p_vendor_file_name;
            end if;

            update metavante_files
            set
                file_name = l_vendor_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_vendor_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_vendor_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Vendors'
                      || ','
                      || 'STL_Result_Vendors'
                      || ','
                      || 'STL_TP_Provider_Export';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_vendor_tbl.count loop
            l_line := 'FP'                                -- Record ID
                      || ','
                      || g_tpa_id                         -- TPA ID
                      || ','
                      || '1'                              -- New Provider
                      || ','
                      || l_vendor_tbl(i).vendor_id        -- Provider ID
                      || ','
                      || l_vendor_tbl(i).vendor_name      -- Vendor Name
                      || ','
                      || l_vendor_tbl(i).address1         -- Address1
                      || ','
                      || l_vendor_tbl(i).city             -- City
                      || ','
                      || l_vendor_tbl(i).state            -- State
                      || ','
                      || l_vendor_tbl(i).zip            -- State
                      || ','
                      || l_vendor_tbl(i).tax_id            -- State
                      || ','
                      || l_vendor_tbl(i).vendor_id;            -- State

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_vendor_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_vendor_file_name := l_vendor_file_name;
    exception
        when mass_card_create then
            insert_alert('Error in Creating Vendor file ', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Vendor file ', l_sqlerrm);
       /* mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
               ,'Error in Creating Deposit/Payment file'
               ,l_sqlerrm);*/
    end vendors;

    procedure hra_fsa_ee_card_creation (
        p_acc_num_list in varchar2 default null,
        p_file_name    in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_card_create_tbl hra_ee_creation_tab;
        l_plan_tbl        plan_tab;
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        l_message         varchar2(32000);
        l_card_count      number;
        mass_card_create exception;
        no_card_create exception;
        l_term_date       varchar2(10) := null;
    begin

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            *
        bulk collect
        into l_card_create_tbl
        from
            (
                select
                    a.acc_num                         employee_id,
                    d.bps_acc_num                     employer_id,
                    null                              plan_id,
                    null                              plan_type,
                    '"'
                    || substr(b.last_name, 1, 26)
                    || '"'                            last_name,
                    '"'
                    || substr(b.first_name, 1, 19)
                    || '"'                            first_name,
                    '"'
                    || substr(b.middle_name, 1, 1)
                    || '"'                            middle_name,
                    '"'
                    || b.address
                    || '"'                            address,
                    '"'
                    || b.city
                    || '"'                            city,
                    '"'
                    || b.state
                    || '"'                            state,
                    '"'
                    ||
                    case
                        when length(b.zip) < 5 then
                                lpad(b.zip, 5, '0')
                        else
                            b.zip
                    end
                    || '"'                            zip,
                    decode(b.gender, 'M', 1, 'F', 2,
                           0)                         gender,
                    to_char(b.birth_date, 'YYYYMMDD') birth_date,
                    substr(b.drivlic, 1, 20)          drivlic,
                    null                              start_date,
                    null                              end_date,
                    to_char(a.start_date, 'YYYYMMDD') effective_date,
                    null                              email,
                    null                              annual_election,
                    c.status,
                    decode(c.issue_conditional, 'Y', '4', 'Yes', '4',
                           'YES', '4', '2')           issue_card,
                    null                              dep_id,
                    null                              relative,
                    lpad(
                        replace(
                            replace(b.ssn, '-'),
                            ' '
                        ),
                        9,
                        '0'
                    )                                 ssn,
                    nvl(c.pin_mailer, '0')            pin_mailer,
                    nvl(c.shipping_method, '1')       shipping_method
                from
                    account    a,
                    person     b,
                    account    d,
                    card_debit c
                where
                        a.pers_id = b.pers_id
     --   AND  TRUNC(A.start_date) <= TRUNC(SYSDATE)
                    and a.complete_flag = 1
                    and a.account_status = 1
                    and c.status = 1
                    and a.account_type in ( 'FSA', 'HRA' )
                    and d.entrp_id = b.entrp_id
                    and b.pers_id = c.card_id
                    and a.bps_acc_num is not null
                    and exists (
                        select
                            *
                        from
                            ben_plan_enrollment_setup bp
                        where
                                bp.acc_id = a.acc_id
                            and bp.status = 'A'
                    )
                    and nvl(
                        pc_person.card_allowed(b.pers_id),
                        1
                    ) = 0
                    and not exists (
                        select
                            *
                        from
                            card_debit
                        where
                                card_debit.card_id = b.pers_id
                            and card_debit.card_number is not null
                            and card_debit.status_code <> 4
                    )
                union
                select
                    a.acc_num                         employee_id,
                    d.bps_acc_num                     employer_id,
                    null                              plan_id,
                    null                              plan_type,
                    '"'
                    || substr(b.last_name, 1, 26)
                    || '"'                            last_name,
                    '"'
                    || substr(b.first_name, 1, 19)
                    || '"'                            first_name,
                    '"'
                    || substr(b.middle_name, 1, 1)
                    || '"'                            middle_name,
                    '"'
                    || b.address
                    || '"'                            address,
                    '"'
                    || b.city
                    || '"'                            city,
                    '"'
                    || b.state
                    || '"'                            state,
                    '"'
                    ||
                    case
                        when length(b.zip) < 5 then
                                lpad(b.zip, 5, '0')
                        else
                            b.zip
                    end
                    || '"'                            zip,
                    decode(b.gender, 'M', 1, 'F', 2,
                           0)                         gender,
                    to_char(b.birth_date, 'YYYYMMDD') birth_date,
                    substr(b.drivlic, 1, 20)          drivlic,
                    null                              start_date,
                    null                              end_date,
                    to_char(a.start_date, 'YYYYMMDD') effective_date,
                    null                              email,
                    null                              annual_election,
                    c.status,
                    decode(c.issue_conditional, 'Y', '4', 'Yes', '4',
                           'YES', '4', '2')           issue_card,
                    null,
                    null,
                    lpad(
                        replace(
                            replace(b.ssn, '-'),
                            ' '
                        ),
                        9,
                        '0'
                    ),
                    nvl(c.pin_mailer, '0'),
                    nvl(c.shipping_method, '1')
                from
                    account    a,
                    person     b,
                    account    d,
                    card_debit c
                where
                        a.pers_id = b.pers_id
     --   AND  TRUNC(A.start_date) <= TRUNC(SYSDATE)
                    and a.complete_flag = 1
                    and a.account_status = 1
                    and c.status = 1
                    and a.account_type in ( 'FSA', 'HRA' )
                    and d.entrp_id = b.entrp_id
                    and b.pers_id = c.card_id
                    and a.bps_acc_num is not null
                    and exists (
                        select
                            *
                        from
                            ben_plan_enrollment_setup bp
                        where
                                bp.acc_id = a.acc_id
                            and bp.status = 'A'
                    )
                    and nvl(
                        pc_person.card_allowed(b.pers_id),
                        1
                    ) = 0
                    and exists (
                        select
                            *
                        from
                            card_debit
                        where
                                card_debit.card_id = b.pers_id
                            and card_debit.card_number is not null
                            and to_date(card_debit.expire_date, 'YYYYMMDD') < sysdate
                    )
            );

        l_card_count := l_card_create_tbl.count;

       /*** Writing IB record now, IB is for employee demographics ***/
        if l_card_create_tbl.count = 0 then
            raise no_card_create;
        else
            if l_card_create_tbl.count > 5000 then
                l_message := 'ALERT!!!! More than 200 HRA ee creations are requested, verify before sending the request';
                raise mass_card_create;
            else
                if get_file_name('HRA_FSA_EE_CARD_CREATION', 'RESULT') is not null then
                    l_message := 'ALERT!!!! Card creation file from previous day has not been processed yet ';
                    raise mass_card_create;
                end if;

                if p_file_name is null then
                    l_file_id := insert_file_seq('HRA_FSA_EE_CARD_CREATION');
                    l_file_name := 'MB_'
                                   || l_file_id
                                   || '_hra_fsa_ee_card_create.mbi';
                else
                    l_file_name := p_file_name;
                end if;

                update metavante_files
                set
                    file_name = l_file_name
                where
                    file_id = l_file_id;

                l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
                l_line := 'IA'
                          || ','
                          || to_char(l_card_count + 1)
                          || ','
                          || g_edi_password
                          || ','
                          || 'STL_Import_HRA_EE_Create '
                          || ','
                          || 'STL_Result_HRA_EE_Create'
                          || ','
                          || 'Standard Result Template';

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end if;
        end if;

        l_line := null;
        for i in 1..l_card_create_tbl.count loop
            if l_card_create_tbl(i).debit_card = 1 then
                l_line := 'IF'                                           -- Record ID
                          || ','
                          || g_tpa_id                    -- TPA ID
                          || ','
                          || l_card_create_tbl(i).employer_id                -- Employer ID
                          || ','
                          || l_card_create_tbl(i).employee_id        -- Employee ID
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')              -- Issue Date
                          || ','
                          || to_char(sysdate + 1, 'YYYYMMDD')              -- Card Effective Date
                          || ','
                          || '1'                                      -- Shipping Address Code, 1 - Cardholder Address
                          || ','
                          || l_card_create_tbl(i).issue_conditional           -- Issue Card
                          || ','
                          || l_card_create_tbl(i).shipping_method             -- Shipping Method Code, 1 - US Mail
                          || ',CNEW_'
                          || l_card_create_tbl(i).employee_id        -- Record Tracking Number
                          || ','
                          || l_card_create_tbl(i).pin_mailer;

                if l_line is not null then
                    utl_file.put_line(
                        file   => l_utl_id,
                        buffer => l_line
                    );
                end if;

            end if;
        end loop;

        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_card_create then
            insert_alert('Error in Creating HRA Employee Creation File', l_message);
        when no_card_create then
            null;
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);
            insert_alert('Error in Creating HRA Employee Creation File', l_sqlerrm);
    end hra_fsa_ee_card_creation;

    procedure hra_fsa_refunds (
        p_deposit_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_deposit_file_name varchar2(3200);
        l_line              varchar2(32000);
        l_card_deposit_tbl  deposit_tab;
        l_sqlerrm           varchar2(32000);
        l_file_id           number;
        mass_card_create exception;
        l_message           varchar2(3200);
    begin
      /** Posting the deposits ***/
      /** IH record is for all deposits **/
        if get_file_name('HRA_FSA_REFUND', 'RESULT') is not null then
            l_message := 'ALERT!!!! Refund file from previous day has not been processed yet ';
            raise mass_card_create;
        end if;

        select
            d.bps_acc_num                             employer_id,
            a.acc_num                                 employee_id,
            bp.plan_type,
            to_char(bp.plan_start_date, 'YYYYMMDD')   start_date,
            to_char(bp.plan_end_date, 'YYYYMMDD')     end_date,
            bp.ben_plan_name,
            1,
            0,
            abs(nvl(p.amount, 0)),
            p.change_num,
            to_char(pay_date, 'YYYYMMDD')             fee_date,
            pc_lookups.get_reason_name(p.reason_code) merchant_name,
            null
        bulk collect
        into l_card_deposit_tbl
        from
            account                   a,
            person                    b,
            account                   d,
            ben_plan_enrollment_setup bp,
            claimn                    clm,
            payment                   p
        where
                a.pers_id = b.pers_id
            and a.account_type in ( 'FSA', 'HRA' )
            and d.entrp_id = b.entrp_id
            and trunc(clm.plan_start_date) = trunc(bp.plan_start_date)
            and trunc(clm.plan_end_date) <= trunc(bp.plan_end_date)
            and bp.acc_id = a.acc_id
            and a.bps_acc_num is not null
            and clm.pers_id = a.pers_id
            and nvl(p.debit_card_posted, 'N') = 'N'
            and bp.status in ( 'A', 'I' )
            and d.bps_acc_num is not null
            and p.plan_type = bp.plan_type
            and p.plan_type = clm.service_type
            and p.claimn_id = clm.claim_id
            and p.amount < 0
        order by
            employee_id desc;

        if l_card_deposit_tbl.count > 0 then
            if p_deposit_file_name is null then
                l_file_id := insert_file_seq('HRA_FSA_REFUND');
                l_deposit_file_name := 'MB_'
                                       || l_file_id
                                       || '_hra_fsa_refund.mbi';
            else
                l_deposit_file_name := p_deposit_file_name;
            end if;

            update metavante_files
            set
                file_name = l_deposit_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_deposit_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_card_deposit_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Annual_Election_Deposit'
                      || ','
                      || 'STL_Annual_Election_Deposit_Result'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_card_deposit_tbl.count loop
            l_line := 'IH'                                 -- Record ID
                      || ','
                      || g_tpa_id                              -- TPA ID
                      || ','
                      || l_card_deposit_tbl(i).employer_id     -- Employer ID
                      || ','
                      || l_card_deposit_tbl(i).employee_id     -- Employee ID
                      || ','
                      || l_card_deposit_tbl(i).account_type_code    -- Account Type Code
                      || ','
                      || l_card_deposit_tbl(i).plan_start_date -- Plan Start Date
                      || ','
                      || l_card_deposit_tbl(i).plan_end_date   -- Plan End Date
                      || ','
                      || 6    -- Deposit Type, 6 - Other
                      || ','
                      || l_card_deposit_tbl(i).employee_amount    -- Employee Deposit Amount
                      || ','
                      || l_card_deposit_tbl(i).employer_amount    -- Employer Deposit Amount
                      || ','
                      || 0 -- Override Amount flag
                      || ','
                      || 'REFUND_'
                      || l_card_deposit_tbl(i).change_num          -- Record Tracking Number
                      || ','
                      || l_card_deposit_tbl(i).transaction_date    -- Display Date
                      || ','
                      || l_card_deposit_tbl(i).merchant_name;      -- Note

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_deposit_file_name is not null then
            utl_file.fclose(file => l_utl_id);
        end if;

        p_deposit_file_name := l_deposit_file_name;
    exception
        when mass_card_create then
            insert_alert('Error in Creating Refund File', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            dbms_output.put_line('sqlerrm ' || sqlerrm);

       /* mail_utility.send_email('metavante@sterlingadministration.com'
                           ,'vanitha.subramanyam@sterlingadministration.com'
               ,'Error in Creating Deposit/Payment file'
               ,l_sqlerrm);*/
    end hra_fsa_refunds;

    function get_ee_card_number (
        p_employee_id in varchar2
    ) return number is
        l_card_number number;
    begin
        for x in (
            select
                card_number
            from
                metavante_cards c
            where
                    to_date(c.issue_date, 'YYYYMMDD') = (
                        select
                            max(to_date(a.issue_date, 'YYYYMMDD'))
                        from
                            metavante_cards a
                        where
                                a.acc_num = p_employee_id
                            and a.acc_num = c.acc_num
                            and dependant_id is null
                        group by
                            a.acc_num,
                            c.acc_num
                    )
                and c.acc_num = p_employee_id
                and dependant_id is null
        ) loop
            l_card_number := x.card_number;
        end loop;

        return l_card_number;
    end get_ee_card_number;

    function get_dep_card_number (
        p_employee_id in varchar2,
        p_dep_id      in varchar2
    ) return number is
        l_card_number number;
    begin
        for x in (
            select
                card_number
            from
                metavante_cards c
            where
                    to_date(c.issue_date, 'YYYYMMDD') = (
                        select
                            max(to_date(a.issue_date, 'YYYYMMDD'))
                        from
                            metavante_cards a
                        where
                                a.acc_num = p_employee_id
                            and a.acc_num = c.acc_num
                            and a.dependant_id = p_dep_id
                        group by
                            a.acc_num,
                            c.acc_num,
                            a.dependant_id
                    )
                and c.acc_num = p_employee_id
                and dependant_id = p_dep_id
        ) loop
            l_card_number := x.card_number;
        end loop;

        return l_card_number;
    end get_dep_card_number;

    function get_card_proxy_number (
        p_card_number in number,
        p_pers_id     in number
    ) return number is
        l_card_proxy_number number;
    begin
        for x in (
            select
                card_proxy_number
            from
                metavante_cards
            where
                    acc_num = (
                        select
                            acc_num
                        from
                            account
                        where
                            pers_id = p_pers_id
                    )
                and card_number = p_card_number
        ) loop
            l_card_proxy_number := x.card_proxy_number;
        end loop;

        return l_card_proxy_number;
    end get_card_proxy_number;

    function get_debit_card (
        p_pers_id in number
    ) return debit_card_t
        pipelined
        deterministic
    is
        l_record_t debit_card_row_t;
    begin
        for x in (
            select
                'XXXX-XXXX-XXXX-'
                || substr(card_number, 13, 4)                              card_number,
                issue_date,
                mailed_date,
                b.first_name,
                b.last_name,
                '***-**-'
                || substr(b.ssn, 8, 5)                                     ssn,
                b.pers_id,
                a.card_id,
                case
                    when a.expire_date is null then
                        3
                    when to_date(a.expire_date, 'YYYYMMDD') < sysdate then
                        3
                    else
                        a.status
                end                                                        status,
                b.birth_date                                               dob,
                round(months_between(sysdate, to_date(b.birth_date)) / 12) age,
                case
                    when to_date(a.expire_date, 'YYYYMMDD') < sysdate then
                        'Closed'
                    else
                        (
                            select
                                nstat
                            from
                                cards_v
                            where
                                stat = a.status
                        )
                end                                                        card_status,
                decode(a.card_id, null, 'N', 'Y')                          card_exist,
                pc_debit_card.get_card_proxy_number(a.card_number,
                                                    nvl(b.pers_main, b.pers_id))                 card_proxy_number,
                decode(d.account_type,
                       'HSA',
                       'STLHSA',
                       pc_entrp.get_bps_acc_num(c.entrp_id))               employer_number,
                mod(rownum, 2)                                             rn
            from
                card_debit a,
                person     b,
                person     c,
                account    d
            where
                    nvl(b.pers_main, b.pers_id) = p_pers_id
                and nvl(b.pers_main, b.pers_id) = c.pers_id
                and c.pers_id = d.pers_id
                and a.card_id (+) = b.pers_id
                and b.pers_end_date is null
        ) loop
            l_record_t.card_number := x.card_number;
            l_record_t.issue_date := x.issue_date;
            l_record_t.mailed_date := x.mailed_date;
            l_record_t.first_name := x.first_name;
            l_record_t.last_name := x.last_name;
            l_record_t.ssn := x.ssn;
            l_record_t.pers_id := x.pers_id;
            l_record_t.card_id := x.card_id;
            l_record_t.status := x.status;
            l_record_t.dob := x.dob;
            l_record_t.age := x.age;
            l_record_t.card_status := x.card_status;
            l_record_t.card_exist := x.card_exist;
            l_record_t.card_proxy_number := x.card_proxy_number;
            l_record_t.employer_number := x.employer_number;
            l_record_t.rn := x.rn;
            pipe row ( l_record_t );
        end loop;
    end get_debit_card;

    procedure debit_card_offset (
        p_claim_id      in varchar2,
        p_amount        in number,
        p_reason        in varchar2,
        p_user_id       in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        v_transaction_id    number;
        v_updatecount       number := 0;
        v_amount            number;
        v_acc_id            varchar2(100);
        v_plan_end_date     date;
        v_tot_amount        number := 0;
        v_claim_amt         number;
        v_org_amount        number(15, 2);
        v_acct_type         varchar2(10);
        v_doc_amt           number(15, 2);
        v_pers_id           number;
        v_card_status       number;
        v_unsettled_claim   number := 0;
        v_future_offset_amt number := 0;
        v_bank_acct_id      number;
    begin
        pc_log.log_error('debit_card_offset', 'Loop');
        pc_log.log_error('Debit card', p_reason);
        x_return_status := 'S';
        if p_reason = 'SUPPORT_DOC_RECV' then
            begin
                select
                    nvl(doc_offset_amt, 0),
                    nvl(claim_amount, 0),
                    nvl(offset_amount, 0),
                    pers_id
                into
                    v_org_amount,
                    v_doc_amt,
                    v_amount,
                    v_pers_id
                from
                    claimn
                where
                    claim_id = p_claim_id;

            exception
                when others then
                    v_org_amount := 0;
                    v_doc_amt := 0;
                    v_amount := 0;
            end;

            if v_doc_amt - v_amount - p_amount = 0 then
                update claimn
                set
                    substantiation_reason = p_reason,
                    unsubstantiated_flag = 'N',
                    doc_offset_amt = v_org_amount + p_amount,
                    offset_amount = v_amount + p_amount,
                    claim_pending = 0,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate,
                    reviewed_by = p_user_id,
                    reviewed_date = sysdate
                where
                    claim_id = p_claim_id;

                select
                    count(*)
                into v_unsettled_claim
                from
                    claimn
                where
                        unsubstantiated_flag = 'Y'
                    and ( trunc(sysdate - creation_date) >= 46 )
                    and pers_id = v_pers_id;

                if v_unsettled_claim = 0 then
                    update card_debit
                    set
                        status = 7 --Un-Suspend
                        ,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            card_id = v_pers_id
                        and status = 4;

                    update card_debit
                    set
                        status = 7 --Un-Suspend
                        ,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        card_id in (
                            select
                                pers_id
                            from
                                person
                            where
                                pers_main = v_pers_id
                        )
                        and status = 4;

                end if;

            else
                update claimn
                set
                    substantiation_reason = p_reason,
                    doc_offset_amt = v_org_amount + p_amount,
                    offset_amount = v_amount + p_amount,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate,
                    reviewed_by = p_user_id,
                    reviewed_date = sysdate
                where
                    claim_id = p_claim_id;

            end if;

            x_return_status := 'S';
        elsif p_reason in ( 'PAYMENT', 'PAYROLL', 'OFFSET_PREVIOUS_YEAR' ) then
      --Create a negative payment in payment table

            for x in (
                select
                    b.acc_id,
                    a.claim_amount,
                    b.account_type,
                    nvl(a.doc_offset_amt, 0)      doc_offset_amount  --(To take the amt which has been substantiated due to doc received
                    ,
                    nvl(a.future_claim_offset, 0) future_offset_amt --(To take the amt which has been substantiated due to Future Claim
                    ,
                    a.pers_id,
                    a.service_type,
                    c.pay_date
                from
                    claimn  a,
                    account b,
                    payment c
                where
                        a.claim_id = p_claim_id
                    and c.claimn_id = a.claim_id
                    and c.reason_code = 13
                    and a.pers_id = b.pers_id
            ) loop

		-- Added by Joshi for 12748- Sprint 59: ACH Pull for FSA/HRA Claims Procedures
                v_transaction_id := null;
                if p_reason = 'PAYMENT' then
                    for b in (
                        select
                            u.bank_acct_id
                        from
                            claimn         c,
                            account        a,
                            person         p,
                            user_bank_acct u
                        where
                                a.pers_id = c.pers_id
                            and p.pers_id = c.pers_id
                            and a.acc_id = u.acc_id
                            and u.status = 'A'
                            and a.pers_id = p.pers_id
                            and u.bank_account_usage = 'ONLINE'
                            and c.claim_id = p_claim_id
                    ) loop
                        v_bank_acct_id := b.bank_acct_id;
                    end loop;

                    pc_log.log_error('debit_card_offset v_bank_Acct_id: ', v_bank_acct_id);
                    if v_bank_acct_id is not null then
                        pc_ach_transfer.ins_ach_transfer(
                            p_acc_id           => x.acc_id,
                            p_bank_acct_id     => v_bank_acct_id,
                            p_transaction_type => 'P',
                            p_amount           => p_amount,
                            p_fee_amount       => 0,
                            p_transaction_date => sysdate,
                            p_reason_code      => 12,
                            p_status           => 2,
                            p_user_id          => p_user_id,
                            p_pay_code         => 5,
                            x_transaction_id   => v_transaction_id,
                            x_return_status    => x_return_status,
                            x_error_message    => x_error_message
                        );

                        update ach_transfer
                        set
                            claim_id = p_claim_id,
                            plan_type = x.service_type
                        where
                            transaction_id = v_transaction_id;

                    end if;

                end if;    
         -- Code ends here Joshi for 12748- Sprint 59: ACH Pull for FSA/HRA Claims Procedures		
                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    claimn_id,
                    note,
                    debit_card_posted,
                    pay_source,
                    plan_type,
                    created_by,
                    creation_date,
                    paid_date,
                    pay_num -- Added by Joshi 12851
                ) values ( change_seq.nextval,
                           x.acc_id,
                           x.pay_date,
                           - p_amount,
                           case
                               when p_reason = 'OFFSET_PREVIOUS_YEAR' then
                                   73
                               else
                                   121
                           end, --Offset reason
                           p_claim_id,
                           'Offset Claim (Claim ID:'
                           || p_claim_id
                           || ') created on '
                           || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                           'N',
                           p_reason,
                           x.service_type,
                           p_user_id,
                           sysdate,
                           sysdate,
                           v_transaction_id  -- Added by Joshi 12851
                            );

                v_doc_amt := x.doc_offset_amount;
                v_pers_id := x.pers_id;
                v_claim_amt := x.claim_amount;  --Assigned by Puja
                v_future_offset_amt := x.future_offset_amt;
            end loop;

            begin
                select
                    sum(amount)
                into v_tot_amount
                from
                    payment
                where
                        claimn_id = p_claim_id
                    and pay_source in ( 'OFFSET_PREVIOUS_YEAR', 'PAYMENT', 'PAYROLL' );
        /*AND reason_code = case when p_reason in('OFFSET_PREVIOUS_YEAR','PAYMENT','PAYROLL') then 73 else 121 end;Commented as per Pujas code.SK(03/04)*/  --Change for Previous yr claim
                                   --Also if ealier settled by previous yr claim and then by PAYMENT ,modified to include these two codes also
            exception
                when others then
                    v_tot_amount := 0;
            end;

       --If a Claim has been earlier substantiated by doc received. Then add the substantiated amount to the new offset.
            if v_doc_amt > 0 then
                v_tot_amount := -( v_doc_amt ) + v_tot_amount;
            end if;

       --If a Claim has been earlier substantiated by Future Claim. Then add the substantiated amount to the new offset.
            if v_future_offset_amt > 0 then
                v_tot_amount := -( v_future_offset_amt ) + v_tot_amount;
            end if;
            update claimn
            set
                offset_amount = ( 0 - v_tot_amount ) --Payment table has negative values. So to counter balance it.
                ,
                unsubstantiated_flag =
                    case
                        when ( v_tot_amount + v_claim_amt ) = 0 then
                            'N'
                        else
                            unsubstantiated_flag
                    end,
                claim_pending =
                    case
                        when ( v_tot_amount + v_claim_amt ) = 0 then
                            0
                        else
                            claim_pending
                    end,
                substantiation_reason = p_reason,
                last_updated_by = p_user_id,
                last_update_date = sysdate,
                reviewed_by = p_user_id,
                reviewed_date = sysdate
            where
                claim_id = p_claim_id;

            if ( v_tot_amount + v_claim_amt ) = 0 then
                select
                    count(*)
                into v_unsettled_claim
                from
                    claimn
                where
                        unsubstantiated_flag = 'Y'
                    and ( trunc(sysdate - creation_date) >= 46 )
                    and pers_id = v_pers_id;

                if v_unsettled_claim = 0 then
                    update card_debit
                    set
                        status = 7 --Un-Suspend
                        ,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            card_id = v_pers_id
                        and status = 4;

                    update card_debit
                    set
                        status = 7 --Un-Suspend
                        ,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        card_id in (
                            select
                                pers_id
                            from
                                person
                            where
                                pers_main = v_pers_id
                        )
                        and status = 4;

                end if;

            end if;

            x_return_status := 'S';
        elsif p_reason = 'DOC_DENIED' then
            pc_log.log_error('Debit card', 'In proper loop');
            update claimn
            set
                substantiation_reason = 'DOC_DENIED',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                claim_id = p_claim_id;

            pc_notifications.insert_deny_debit_claim_event(p_claim_id, 'DEBIT_CLAIM_DENIAL', p_user_id);
            x_return_status := 'S';
        end if; --End of IF clauses for different offset reason
    end debit_card_offset;

    procedure hrafsa_suspend_card (
        p_file_name in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_suspend_tbl     varchar2_tab;
        l_card_number_tbl varchar2_tab;
        l_er_acc_num_tbl  varchar2_tab;
        l_pers_id_tbl     number_tab;
        l_bps_acc_num     varchar2(255);
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
        mass_suspend exception;
    begin

         --card_request_history (6,'SUBSCRIBER');

        /*** Use the limit clause when the daily debit card creation hits more than 5000 ***/

        select
            acc_num                              employee_id,
            c.card_number,
            a.pers_id,
            pc_entrp.get_bps_acc_num(p.entrp_id) bps_acc_num
        bulk collect
        into
            l_suspend_tbl,
            l_card_number_tbl,
            l_pers_id_tbl,
            l_er_acc_num_tbl
        from
            account    a,
            card_debit c,
            person     p
        where
                c.card_id = a.pers_id
            and p.pers_id = a.pers_id
            and c.card_id = p.pers_id
            and c.status = 6 -- suspend
            and c.status_code not in ( 4, 5 )
            and a.account_type in ( 'HRA', 'FSA' )
            and c.card_number is not null
            and pc_entrp.get_bps_acc_num(p.entrp_id) is not null;

        l_line := null;
        if l_suspend_tbl.count > 1000 then
            raise mass_suspend;
        elsif l_suspend_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('SUSPEND');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_suspend.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_suspend_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Suspend'
                      || ','
                      || 'STL_Result_Suspend'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IJ record now, IJ is for lost/stolen ***/
        for i in 1..l_suspend_tbl.count loop
            l_line := 'IJ'                   -- Record ID
                      || ','
                      || g_tpa_id               -- TPA ID
                      || ','
                      || l_er_acc_num_tbl(i)          -- Employer ID
                      || ','
                      || l_card_number_tbl(i)   -- dont have card number what to do
                      || ','
                      || '3'                   -- Card Status, 3 - Temporarily Inactive
                      || ','
                      || '6'                   -- Card Status Change Reason, 6 - Pending Card Holder Reimbursement
                      || ',SUSP_'
                      || to_char(sysdate, 'MMDD')
                      || l_suspend_tbl(i);  -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when mass_suspend then
            insert_alert('Error in suspend', 'ALERT!!!! More than 1000 debit card suspend are requested, verify before sending the request'
            );
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Suspenion ', l_sqlerrm);
    end hrafsa_suspend_card;

    procedure hrafsa_unsuspend (
        p_file_name in out varchar2
    ) is

        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_unsuspend_tbl   varchar2_tab;
        l_card_number_tbl varchar2_tab;
        l_pers_id_tbl     number_tab;
        l_bps_acc_num_tbl varchar2_tab;
        l_bps_acc_num     varchar2(255);
        l_sqlerrm         varchar2(32000);
        l_file_id         number;
    begin
        select
            acc_num                              employee_id,
            c.card_number,
            a.pers_id,
            pc_entrp.get_bps_acc_num(p.entrp_id) bps_acc_num
        bulk collect
        into
            l_unsuspend_tbl,
            l_card_number_tbl,
            l_pers_id_tbl,
            l_bps_acc_num_tbl
        from
            account    a,
            card_debit c,
            person     p
        where
                a.pers_id = c.card_id
            and p.pers_id = a.pers_id
            and c.card_id = p.pers_id
            and c.status = 7 -- unsuspend
            and status_code not in ( 4, 5 )
            and a.account_type in ( 'HRA', 'FSA' )
            and c.card_number is not null
            and pc_entrp.get_bps_acc_num(p.entrp_id) is not null
            and exists (
                select
                    *
                from
                    metavante_cards
                where
                        card_number = c.card_number
                    and status_code in ( 1, 2, 3 )
            );

        l_line := null;
        if l_unsuspend_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('UNSUSPEND');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_unsuspend.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_unsuspend_tbl.count + 1)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_Unsuspend'
                      || ','
                      || 'STL_Result_Unsuspend'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

       /*** Writing IJ record now, IJ is for Unsuspend ***/
        for i in 1..l_unsuspend_tbl.count loop
            l_bps_acc_num := null;
            l_line := 'IJ'                                           -- Record ID
                      || ','
                      || g_tpa_id                    -- TPA ID
                      || ','
                      || l_bps_acc_num_tbl(i)                  -- Employer ID
                      || ','
                      || l_card_number_tbl(i)         -- dont have card number what to do
                      || ','
                      || '2'                        -- Card Status, 2 - Active
                      || ','
                      || '1'                        -- Card Status Change Reason, 1 - IVR
                      || ',USUS_'
                      || to_char(sysdate, 'MMDD')
                      || l_unsuspend_tbl(i);        -- Record Tracking Number

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            p_file_name := l_file_name;
        end if;

    exception
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Unsuspension', l_sqlerrm);
    end hrafsa_unsuspend;

    procedure custom_card_creation (
        x_file_name out varchar2
    ) is
        l_acc_num_list varchar2(4000);
    begin
        for x in (
            select
                listagg(a.acc_num, ',') within group(
                order by
                    a.acc_num
                ) acc_num_list
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and b.entrp_id in ( 13476, 13475 )
                and a.complete_flag = 1
                and a.id_verified = 'Y'
                and exists (
                    select
                        *
                    from
                        card_debit
                    where
                            card_id = b.pers_id
                        and card_debit.status = 1
                )
                and ( a.blocked_flag = 'N'
                      or a.blocked_flag is null )
            union-- Ticket# 6588 change
            select
                listagg(a.acc_num, ',') within group(
                order by
                    a.acc_num
                ) acc_num_list
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and pc_plan.can_create_card_on_pend(a.plan_code) = 'Y' -- 6588 change
                and a.account_status = 3
                and a.id_verified = 'Y'
                and exists (
                    select
                        *
                    from
                        card_debit
                    where
                            card_id = b.pers_id
                        and card_debit.status = 1
                )
                and ( a.blocked_flag = 'N'
                      or a.blocked_flag is null )-- 6588 change
        ) loop
            l_acc_num_list := x.acc_num_list;
        end loop;

        if l_acc_num_list is not null then
            card_creation(
                p_acc_num_list => l_acc_num_list,
                p_file_name    => x_file_name
            );
        end if;

    end custom_card_creation;

    procedure custom_dep_card_creation (
        x_file_name out varchar2
    ) is
        l_acc_num_list varchar2(4000);
    begin
        for x in (
            select
                listagg(a.acc_num, ',') within group(
                order by
                    a.acc_num
                ) acc_num_list
            from
                account a,
                person  b,
                person  c
            where
                    a.pers_id = b.pers_id
                and b.entrp_id in ( 13476, 13475 )
                and a.complete_flag = 1
                and a.id_verified = 'Y'
                and c.pers_main = b.pers_id
                and exists (
                    select
                        *
                    from
                        card_debit
                    where
                            card_id = c.pers_id
                        and card_debit.status = 1
                )
                and ( a.blocked_flag = 'N'
                      or a.blocked_flag is null )
            union -- Ticket# 6588 change
            select
                listagg(a.acc_num, ',') within group(
                order by
                    a.acc_num
                ) acc_num_list
            from
                account a,
                person  b,
                person  c
            where
                    a.pers_id = b.pers_id
                and pc_plan.can_create_card_on_pend(a.plan_code) = 'Y'
                and a.account_status = 3
                and a.id_verified = 'Y'
                and c.pers_main = b.pers_id
                and exists (
                    select
                        *
                    from
                        card_debit
                    where
                            card_id = c.pers_id
                        and card_debit.status = 1
                )
                and ( a.blocked_flag = 'N'
                      or a.blocked_flag is null ) -- 6588 change
        ) loop
            l_acc_num_list := x.acc_num_list;
        end loop;

        if l_acc_num_list is not null then
            dep_card_creation(
                p_acc_num_list => l_acc_num_list,
                p_file_name    => x_file_name
            );
        end if;

    end custom_dep_card_creation;

  -- Procedure to process the suspend/unsuspensation of cards
  -- for substantiated/unsubstantiated debit cards

    procedure process_subst_hrafsa_cards is
    begin

    -- If there are no claims to substantiate for the claims that are older than 46 days
    -- and if we have substantiated
    -- all the claims, then this process will unsuspend the cards
        for x in (
            select
                pers_id
            from
                (
                    select distinct
                        (
                            select
                                count(*)
                            from
                                claimn c
                            where
                                    unsubstantiated_flag = 'Y'
                                and c.pers_id = a.card_id
                                and ( trunc(sysdate - c.creation_date) >= 46 )
                        ) card_count,
                        acc_num,
                        pers_id
                    from
                        card_debit                a,
                        account                   b,
                        ben_plan_enrollment_setup bp
                    where
                            a.status = 4
                        and b.acc_id = bp.acc_id
                        and a.card_id = b.pers_id
                        and b.account_type in ( 'HRA', 'FSA' )
                        and bp.plan_end_date > sysdate
                )
            where
                card_count = 0
        ) loop
            update card_debit
            set
                status = 7 --Un-Suspend
                ,
                last_update_date = sysdate
            where
                    card_id = x.pers_id
                and status = 4;

        end loop;

        for x in (
            select
                pers_id
            from
                (
                    select distinct
                        (
                            select
                                count(*)
                            from
                                claimn c
                            where
                                    unsubstantiated_flag = 'Y'
                                and c.pers_id = a.card_id
                                and ( trunc(sysdate - c.creation_date) >= 46 )
                        ) card_count,
                        acc_num,
                        p.pers_id
                    from
                        card_debit                a,
                        account                   b,
                        ben_plan_enrollment_setup bp,
                        card_debit                c,
                        person                    p
                    where
                        a.status in ( 2, 7 )
                        and b.acc_id = bp.acc_id
                        and a.card_id = b.pers_id
                        and b.account_type in ( 'HRA', 'FSA' )
                        and p.pers_main = b.pers_id
                        and c.card_id = p.pers_id
                        and c.status in ( 4, 6 )
                        and bp.plan_end_date > sysdate
                )
            where
                card_count = 0
        ) loop
            update card_debit
            set
                status = 7 --Un-Suspend
                ,
                last_update_date = sysdate
            where
                    card_id = x.pers_id
                and status = 4;

        end loop;

    -- If there are  claims to substantiate and even if there is one claim
    -- remaining, then this process will suspend the cards after 45 days

        for x in (
            select distinct
                acc_id,
                pers_id,
                acc_num
            from
                (
                    select
                        a.claim_id,
                        a.claim_date,
                        a.creation_date,
                        b.acc_id,
                        a.pers_id,
                        b.acc_num,
                        trunc(sysdate - a.creation_date) no_of_days
                    from
                        claimn     a,
                        account    b,
                        card_debit d
                    where
                            unsubstantiated_flag = 'Y'
                        and a.pers_id = b.pers_id
                        and b.account_type in ( 'HRA', 'FSA' )
                        and a.creation_date is not null
                        and a.pers_id = d.card_id
                        and d.status <> 4
                )
            where
                no_of_days >= 46
        ) loop
            update card_debit
            set
                status = 6 --Suspension Pending
                ,
                last_update_date = sysdate
            where
                    card_id = x.pers_id
                and status in ( 1, 2, 7 );

            update card_debit
            set
                status = 6 --Suspension Pending
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
                and status in ( 1, 2, 7 );

        end loop;

        for x in (
            select distinct
                acc_id,
                pers_id,
                acc_num
            from
                (
                    select
                        a.claim_id,
                        a.claim_date,
                        a.creation_date,
                        b.acc_id,
                        a.pers_id,
                        b.acc_num,
                        trunc(sysdate - a.creation_date) no_of_days
                    from
                        claimn     a,
                        account    b,
                        card_debit d,
                        card_debit c,
                        person     p
                    where
                            unsubstantiated_flag = 'Y'
                        and a.pers_id = b.pers_id
                        and b.account_type in ( 'HRA', 'FSA' )
                        and a.creation_date is not null
                        and p.pers_main = b.pers_id
                        and c.card_id = p.pers_id
                        and c.status in ( 1, 2, 7 )
                        and a.pers_id = d.card_id
                        and d.status in ( 4, 6 )
                )
            where
                no_of_days >= 46
        ) loop
            update card_debit
            set
                status = 6 --Suspension Pending
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
                and status in ( 1, 2, 7 );

        end loop;

    end process_subst_hrafsa_cards;

    procedure employer_plan_update (
        p_file_name in out varchar2
    ) is

        l_utl_id            utl_file.file_type;
        l_file_name         varchar2(3200);
        l_line              varchar2(32000);
        l_employer_plan_tbl emp_update_plan_tab;
        l_sqlerrm           varchar2(32000);
        l_message           varchar2(32000);
        l_file_id           number;
        l_record_count      number;
        result_exception exception;
    begin
        select
            nvl(bps_acc_num,
                'STL'
                || replace(
                replace(
                    replace(
                        replace(acc_num, 'GHRA'),
                        'GFSA'
                    ),
                    chr(10),
                    ''
                ),
                chr(13),
                ''
            ))                         employer_id,
            '"'
            || c.ben_plan_name
            || '"',
            '"'
            || c.plan_type
            || '"',
            '"'
            || to_char(bh.plan_start_date, 'YYYYMMDD')
            || '"',
            '"'
            || to_char(bh.plan_end_date, 'YYYYMMDD')
            || '"',
            nvl(c.minimum_election, 0) minimum_election,
            c.maximum_election,
            '"'
            || to_char(c.plan_start_date, 'YYYYMMDD')
            || '"',
            '"'
            || to_char(c.plan_end_date, 'YYYYMMDD')
            || '"',
            '"'
            || to_char(c.plan_end_date + nvl(c.grace_period, 0),
                       'YYYYMMDD')
            || '"',
            '"'
            || to_char(c.plan_end_date + nvl(c.runout_period_days, 0) + nvl(c.grace_period, 0),
                       'YYYYMMDD')
            || '"',
            c.ben_plan_id
        bulk collect
        into l_employer_plan_tbl
        from
            enterprise                b,
            account                   a,
            ben_plan_enrollment_setup c,
            ben_plan_history          bh
        where
                b.entrp_id = a.entrp_id
            and a.acc_id = c.acc_id
            and c.ben_plan_id = bh.ben_plan_id
            and trunc(bh.changed_on) = trunc(sysdate)
            and a.account_type in ( 'FSA', 'HRA' )
            and a.account_status not in ( 4, 5 )
            and ( bh.plan_start_date <> c.plan_start_date
                  or bh.plan_end_date <> c.plan_end_date
                  or bh.minimum_election <> c.minimum_election
                  or bh.maximum_election <> c.maximum_election
                  or nvl(c.grace_period, 0) <> nvl(bh.grace_period, 0)
                  or nvl(c.runout_period_days, 0) <> nvl(bh.runout_period_days, 0) )
    --  AND   C.STATUS = 'A'
            and nvl(c.plan_docs_flag, 'Y') = 'N'
            and c.created_in_bps = 'Y';

        l_record_count := 1 + ( l_employer_plan_tbl.count ) * 1;
        if l_employer_plan_tbl.count > 0 then
            if p_file_name is null then
                l_file_id := insert_file_seq('ER_PLAN_UPDATE');
                l_file_name := 'MB_'
                               || l_file_id
                               || '_ER_PLAN_UPDATE.mbi';
            else
                l_file_name := p_file_name;
            end if;

            update metavante_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('DEBIT_CARD_DIR', l_file_name, 'w');
            l_line := 'IA'
                      || ','
                      || to_char(l_record_count)
                      || ','
                      || g_edi_password
                      || ','
                      || 'STL_Import_ER_Update_IU'
                      || ','
                      || 'STL_Result_ER_Demg'
                      || ','
                      || 'Standard Result Template';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end if;

        for i in 1..l_employer_plan_tbl.count loop
            l_line := 'IU'                              -- Record ID
                      || ','
                      || g_tpa_id                        -- TPA ID
                      || ','
                      || l_employer_plan_tbl(i).employer_id   -- Employer ID
                      || ','
                      || l_employer_plan_tbl(i).plan_id -- plan_id
                      || ','
                      || l_employer_plan_tbl(i).plan_type       -- plan_type
                      || ','
                      || l_employer_plan_tbl(i).start_date          -- start_date
                      || ','
                      || l_employer_plan_tbl(i).end_date         -- end_date
                      || ','
                      || l_employer_plan_tbl(i).minimum_election       -- minumum_election
                      || ','
                      || l_employer_plan_tbl(i).maximum_election  -- maximum_election
                      || ','
                      || '1'                                      -- update plan dates flag
                      || ','
                      || l_employer_plan_tbl(i).new_start_date  -- new start date
                      || ','
                      || l_employer_plan_tbl(i).new_end_date  -- new end date
                      || ','
                      || l_employer_plan_tbl(i).grace_period -- grace period
                      || ','
                      || l_employer_plan_tbl(i).runout_period           -- runout_period
                      || ','
                      || l_employer_plan_tbl(i).record_number -- Record Tracking Number
                      || ','
                      || 0
                      || ','
                      || null
               /* ||','||CASE WHEN l_employer_plan_tbl(i).plan_type IN ('TRN','PKG') THEN
                        1 ELSE 0 END   -- Spending Limit Period
                ||','||CASE WHEN l_employer_plan_tbl(i).plan_type IN ('TRN','PKG') THEN
                        pc_param.get_fsa_irs_limit('TRANSACTION_LIMIT'
                                         ,l_employer_plan_tbl(i).plan_type
                                         ,CASE WHEN TO_CHAR(SYSDATE,'MON') IN ('NOV','DEC') THEN
                                             ADD_MONTHS(trunc(sysdate,'YEAR'),12)+1
                                          ELSE SYSDATE END) -- Spending Transaction Amount
                      ELSE NULL END*/;

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
        end loop;

        dbms_output.put_line('file name ' || l_file_name);
        if l_file_name is not null then
            p_file_name := l_file_name;
            utl_file.fclose(file => l_utl_id);
        end if;

    exception
        when result_exception then
            insert_alert('Error in Creating Employer Plan Update File', l_message);
        when no_data_found then
            null;
        when others then
            l_sqlerrm := sqlerrm;
            insert_alert('Error in Creating Employer Plan Update File', l_sqlerrm);
    end employer_plan_update;

    function get_webservice_password (
        p_user_name in varchar2
    ) return varchar2 is
        l_pwd varchar2(30);
    begin
        for x in (
            select
                password
            from
                external_vendor_credentials
            where
                user_name = p_user_name
        ) loop
            l_pwd := x.password;
        end loop;

        return l_pwd;
    end get_webservice_password;

end pc_debit_card;
/

