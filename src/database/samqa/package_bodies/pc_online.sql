create or replace package body samqa.pc_online is

    function array_fill (
        p_array       varchar2_tbl,
        p_array_count number
    ) return varchar2_tbl is
        l_array varchar2_tbl;
    begin
        for i in 1..p_array_count loop
            if ( p_array.exists(i) ) then
                l_array(i) := p_array(i);
            else
                l_array(i) := null;
            end if;
        end loop;

        return l_array;
    end;

    procedure terminate_employee (
        p_pers_tbl      in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_employer_name varchar2(3200);
        l_error_message varchar2(3000);
        l_return_status varchar2(1);
    begin
        x_return_status := 'S';
        for i in 1..p_pers_tbl.count loop
            for x in (
                select
                    pc_person.get_person_name(c.pers_id)      pers_name,
                    pc_entrp.get_entrp_name(e.entrp_id)       employer_name,
                    to_char(a.transaction_date, 'MM/DD/YYYY') transaction_date,
                    d.email,
                    a.acc_id
                from
                    ach_transfer_v       a,
                    ach_transfer_details b,
                    account              c,
                    online_users         d,
                    enterprise           e
                where
                        a.transaction_type = 'C'
                    and a.entrp_id is not null
                    and a.status in ( 1, 2 )
                    and a.transaction_date > sysdate
                    and a.transaction_id = b.transaction_id
                    and c.acc_id = b.acc_id
                    and d.tax_id = e.entrp_code
                    and a.entrp_id = e.entrp_id
                    and d.emp_reg_type = 2
                    and d.user_status = 'A'
                    and c.pers_id = p_pers_tbl(i)
            ) loop
                pc_notifications.ach_terminated_ee_notification(
                    p_person_name   => x.pers_name,
                    p_acc_id        => x.acc_id,
                    p_transfer_date => x.transaction_date,
                    p_email         => x.email,
                    p_template_name => 'EMPLOYER_ACH_TERMINATION',
                    p_user_id       => p_user_id
                );

                l_employer_name := x.employer_name;
            end loop;

            update person
            set
                entrp_id = null,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                pers_id = p_pers_tbl(i);

            update account
            set
                note = note
                       || 'Terminated by employer '
                       || l_employer_name
                       || ' on '
                       || to_char(sysdate, 'mm/dd/yyyy'),
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                pers_id = p_pers_tbl(i);

        end loop;

	 -- Added by Joshi for 9382. if any contribution is scheduled. delete it.
        for i in 1..p_pers_tbl.count loop
            for xx in (
                select
                    s.scheduler_id,
                    sd.acc_id
                from
                    scheduler_master  s,
                    scheduler_details sd,
                    account           a,
                    person            p
                where
                        p.pers_id = p_pers_tbl(i)
                    and a.pers_id = p.pers_id
                    and s.scheduler_id = sd.scheduler_id
                    and sd.acc_id = a.acc_id
                    and s.recurring_flag = 'Y'
                    and sd.status = 'A'
                    and exists (
                        select
                            *
                        from
                            scheduler_calendar
                        where
                                schedule_id = s.scheduler_id
                            and trunc(period_date) >= trunc(sysdate)
                    )
            ) loop
                pc_log.log_error('PC_ONLINE.delete_scheduler_line xx.scheduler_id  ', xx.scheduler_id);
                pc_log.log_error('PC_ONLINE.delete_scheduler_line xx.acc_id ', xx.acc_id);
                pc_schedule.delete_scheduler_line(xx.scheduler_id, xx.acc_id, null, p_user_id, l_error_message,
                                                  l_return_status);

            end loop;
        end loop;
		-- code ends here. 9382
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end terminate_employee;

    procedure change_plan (
        p_acc_id        in number,
        p_plan_code     in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_plan_code   number;
        l_annual_flag varchar2(1) := 'N';
        l_exception exception;
    begin
        x_return_status := 'S';
        dbms_output.put_line('  P_ACC_ID' || p_acc_id);
        for x in (
            select
                a.plan_code,
                annual_flag,
                plan_change_date,
                pc_account.fee_bucket_balance(a.acc_id) fee_bucket_balance,
                pc_account.acc_balance(a.acc_id)        acc_balance,
                (
                    select
                        trunc(max(b.pay_date))
                    from
                        payment b
                    where
                            a.acc_id = b.acc_id
                        and a.account_status <> 4
                        and a.account_type = 'HSA'
                        and b.reason_code = 100
                )                                       renewal_date
            from
                account a,
                plans   p
            where
                    acc_id = p_acc_id
                and a.plan_code = p.plan_code
        ) loop
            dbms_output.put_line('  X.PLAN_CODE' || x.plan_code);
            if x.plan_code <> p_plan_code then
                for xx in (
                    select
                        annual_flag
                    from
                        plans
                    where
                        plan_code = p_plan_code
                ) loop
                    l_annual_flag := xx.annual_flag;
                end loop;

                dbms_output.put_line('  L_ANNUAL_FLAG' || l_annual_flag);
                dbms_output.put_line('  X.PLAN_CODE' || x.plan_code);
                dbms_output.put_line('  X.ANNUAL_FLAG ' || x.annual_flag);
                dbms_output.put_line('  RENEWAL_DATE' || x.renewal_date);
                if x.annual_flag = 'Y'
                or l_annual_flag = 'Y' then
                    if
                        x.renewal_date is not null
                        and add_months(x.renewal_date, 12) - 1 > trunc(sysdate)
                    then
                        dbms_output.put_line('  P_PLAN_CODE' || p_plan_code);
                        x_error_message := 'Your change request cannot be completed at this time because your account has an annual service fee and can only be changed during renewal.'
                        ;
                        raise l_exception;
                    end if;
                end if;

                dbms_output.put_line('   PC_PLAN.fannual(p_PLAN_CODE)' || pc_plan.fannual(p_plan_code));
                dbms_output.put_line('    x.acc_balance' || x.acc_balance);
                dbms_output.put_line('    X.fee_bucket_balance' || x.fee_bucket_balance);
                if l_annual_flag = 'Y' then
                    if pc_plan.fannual(p_plan_code) > x.acc_balance + nvl(x.fee_bucket_balance, 0) then
                        x_error_message := 'We are unable to complete your request to change plans because your service fee balance is not enough to cover the annual fee for the plan you selected.  Please make a deposit for service fees and make sure the funds available before changing your plan.'
                        ;
                        raise l_exception;
                    end if;
                end if;

            end if;

        end loop;

        pc_account.upgrade_account(p_acc_id, sysdate, p_plan_code, 'Plan Changed by Online User', p_user_id);
    exception
        when l_exception then
            x_return_status := 'E';
            null;
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end change_plan;

    procedure end_date_dependant (
        p_pers_id       in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        pc_log.log_error('END_DATE_DEPENDANT', p_pers_id.count);
        for i in 1..p_pers_id.count loop
            pc_log.log_error('END_DATE_DEPENDANT',
                             p_pers_id(i));
            update person
            set
                pers_end_date = sysdate
            where
                pers_id = p_pers_id(i);

            update card_debit
            set
                end_date = sysdate,
                terminated = 'N',
                status = 3
            where
                card_id = p_pers_id(i);

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    procedure update_insure (
        p_pers_id        in number,
        p_insur_id       in number,
        p_deductible     in number,
        p_effective_date in varchar2,
        p_plan_type      in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
        l_insur_count number := 0;
    begin
        x_return_status := 'S';
        pc_log.log_error('UPDATE INSURE ', 'plan type ' || p_plan_type);
        select
            count(*)
        into l_insur_count
        from
            insure
        where
            pers_id = p_pers_id;

        if l_insur_count = 0 then
            insert into insure (
                pers_id,
                insur_id,
                start_date,
                deductible,
                note,
                plan_type,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( p_pers_id,
                       p_insur_id,
                       nvl(p_effective_date, sysdate),
                       nvl(p_deductible, 0),
                       'Health plan added from online',
                       decode(p_plan_type, 0, 0, 1) -- Added by jaggi#10456 coverage tiers  EE+SPOUSE  EE+CHILDREN  should come as FAMILY
                       ,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

        else
            update insure
            set
                insur_id = nvl(p_insur_id, insur_id),
                deductible = nvl(p_deductible, deductible),
                start_date = nvl(p_effective_date, start_date),
                plan_type = decode(p_plan_type, 0, 0, 1) -- Added by jaggi#10456 coverage tiers  EE+SPOUSE  EE+CHILDREN  should come as FAMILY
                ,
                note = 'Health plan changed by online user'
            where
                pers_id = p_pers_id;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    procedure create_card (
        p_pers_id       in varchar2_tbl,
        p_acc_id        in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_card_count number;
        card_exception exception;
    begin
        x_return_status := 'S';
        for i in 1..p_pers_id.count loop
            pc_log.log_error('PC_ONLINE.CREATE_CARD',
                             p_pers_id(i));

      	--- Part of 8728 ticket   start  Ticket #8472 rprabu
            l_card_count := 0;
            for x in (
                select
                    first_name
                    || '  '
                    || last_name primary_name
                from
                    card_debit a,
                    person     c
                where
                    a.card_id in (
                        select
                            pers_main
                        from
                            person b
                        where
                            b.pers_id = p_pers_id(i)
                    )
                    and a.status = 3
                    and a.card_id = c.pers_id
            ) loop
                pc_log.log_error('PC_ONLINE.CREATE_CARD primary having closed card   ',
                                 p_pers_id(i));
                x_error_message := 'Dependent card cannot be ordered as Primary card is closed. ';
                x_return_status := 'E';
                raise card_exception;
            end loop;
     --- Ticket#8472  End rprabu

	              ----Here below For loop is added to avoid exceptions as part of the Ticket#8472 .rprabu
            for y in (
                select
                    *
                from
                    card_debit
                where
                        card_id = p_pers_id(i)
                    and card_number is not null
                    and status in ( 1, 2, 4, 5, 6,
                                    7, 9 )
            ) loop
                x_error_message := 'Cannot reorder debit card at this point since you already have card';
                x_return_status := 'E';
                raise card_exception;
            end loop;

            pc_log.log_error('PC_ONLINE.CREATE_CARD 1',
                             p_pers_id(i));
            if pc_account.acc_balance(p_acc_id) < 0 then
                x_error_message := 'Cannot order debit card at this point since you do not have sufficient balance';
                x_return_status := 'E';
                raise card_exception;
            end if;
              /*** Dependant does not have account, check if main card holder has card ***/
            if pc_person.count_account(p_pers_id(i)) = 0 then
          -- Main card holder does not have card
                if pc_person.acc_card_count(p_pers_id(i)) = 0 then
                    x_error_message := 'Cannot order debit card at this point since account holder does not have card';
                    x_return_status := 'E';
                    raise card_exception;
                end if;
            end if;

            for x in (
                select
                    *
                from
                    person
                where
                        pers_id = p_pers_id(i)
                    and months_between(sysdate, birth_date) / 12 < 10
            ) loop
                x_error_message := 'Cannot order debit cards for dependents under 10 years of age.';
                x_return_status := 'E';
                raise card_exception;
            end loop;

            for x in (
                select
                    *
                from
                    account
                where
                    acc_id = p_acc_id
            ) loop
                update person
                set
                    card_issue_flag = 'Y'
                where
                    pers_id = p_pers_id(i);

                insert into card_debit (
                    card_id,
                    start_date,
                    emitent,
                    status,
                    note,
                    max_card_value,
                    last_update_date
                ) values ( p_pers_id(i),
                           greatest(
                               nvl(to_date(x.start_date), sysdate),
                               sysdate
                           ),
                           6763,
                           case
                               when trunc(nvl(to_date(x.start_date), sysdate)) > trunc(sysdate) then
                                   decode(
                                       pc_plan.can_create_card_on_pend(x.plan_code),
                                       'Y',
                                       1,
                                       9
                                   )
                               else
                                   1
                           end,
                           'Ordered from online',
                           0,
                           sysdate );

            end loop;

        end loop;

    exception
        when card_exception then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    procedure close_card (
        p_pers_id       in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        for i in 1..p_pers_id.count loop
            pc_log.log_error('PC_ONLINE.CLOSE_CARD',
                             p_pers_id(i));
            update card_debit
            set
                end_date = sysdate,
                status = 3,
                terminated = 'N',
                note = note || ' closed from online '
            where
                card_id = p_pers_id(i);

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

------  Ticket 8472-Lost  Debit card added by rprabu 27/01/2020
    procedure order_lost_stolen (
        p_pers_id       in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        for i in 1..p_pers_id.count loop
            pc_log.log_error('PC_ONLINE.ORDER_LOST_STOLEN',
                             p_pers_id(i));
            update card_debit
            set
                end_date = sysdate,
                status = 5  ----------changed to Lost / stolen status
                ,
                terminated = 'N',
                note = note || ' Lost and Stolen from online '
            where
                card_id = p_pers_id(i);

        end loop;

        x_return_status := 'S';
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    procedure create_vendor (
        p_vendor_name         in varchar2,
        p_vendor_acc_num      in varchar2,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zipcode             in varchar2,
        p_acc_num             in varchar2,
        p_user_id             in varchar2,
        p_orig_sys_vendor_ref in varchar2 default null,
        x_vendor_id           out number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is
        l_vendor_id number;
    begin
        x_return_status := 'S';
        insert into vendors (
            vendor_id,
            orig_sys_vendor_ref,
            vendor_name,
            address1,
            address2,
            city,
            state,
            zip,
            expense_account,
            acc_num,
            vendor_in_peachtree,
            vendor_acc_num,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( vendor_seq.nextval,
                   nvl(p_orig_sys_vendor_ref, p_vendor_name),
                   p_vendor_name -- Payee Name
                   ,
                   p_address        -- Payee Address
                   ,
                   null,
                   p_city             -- Payee City
                   ,
                   p_state            -- Payee State
                   ,
                   p_zipcode		  -- Payee Zip
                   ,
                   2400		  -- Expense Account
                   ,
                   p_acc_num,
                   'N',
                   p_vendor_acc_num -- Payee Account Number
                   ,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id ) returning vendor_id into x_vendor_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end create_vendor;

    procedure create_disbursement (
        p_acc_num         in varchar2,
        p_acc_id          in number,
        p_vendor_id       in number,
        p_vendor_acc_num  in varchar2,
        p_date_of_service in varchar2,
        p_amount          in number,
        p_patient_name    in varchar2,
        p_note            in varchar2,
        p_user_id         in number,
        x_claim_id        out number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_batch_number varchar2(30);
        setup_error exception;
        l_check_number number;
    begin
        x_return_status := 'S';
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
        for x in (
            select
                account_status
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            if x.account_status = 3 then
                x_error_message := 'Your account has not been activated yet, You cannot schedule Disbursement at this time';
                raise setup_error;
            end if;
        end loop;

        for x in (
            select
                orig_sys_vendor_ref
            from
                vendors
            where
                vendor_id = p_vendor_id
        ) loop
            if
                x.orig_sys_vendor_ref <> p_vendor_acc_num
                and p_vendor_acc_num is not null
                and p_vendor_acc_num <> ''
            then
                update vendors
                set
                    orig_sys_vendor_ref = p_vendor_acc_num
                where
                    vendor_id = p_vendor_id;

            end if;
        end loop;

        if is_number(p_amount) = 'N' then
            x_error_message := 'Enter only numeric values for amount';
            raise setup_error;
        end if;

        if
            pc_fin.get_bill_pay_fee(p_acc_id) > 0
            and pc_account.acc_balance(p_acc_id) - p_amount > 0
            and pc_account.acc_balance(p_acc_id) - ( p_amount + nvl(
                pc_fin.get_bill_pay_fee(p_acc_id),
                0
            ) ) < 0
        then
            x_error_message := 'A '
                               || format_money(pc_fin.get_bill_pay_fee(p_acc_id))
                               || ' charge is applied for checks requested
                         from  your plan and you do not have sufficient funds to cover the disbursement and the charge. '
                               || 'Please reduce your claim by at least '
                               || format_money(pc_fin.get_bill_pay_fee(p_acc_id))
                               || ' and resubmit.';

            raise setup_error;
        end if;

        if pc_account.acc_balance(p_acc_id) - ( p_amount + nvl(
            pc_fin.get_bill_pay_fee(p_acc_id),
            0
        ) ) >= 0 then
            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                date_of_service,
                patient_name,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            )
                select
                    payment_register_seq.nextval,
                    l_batch_number,
                    p_acc_num,
                    a.acc_id,
                    b.pers_id,
                    vendor_name,
                    vendor_id,
                    p_vendor_acc_num,
                    upper(substr(last_name, 1, 4))
                    || to_char(sysdate, 'YYYYMMDDHHMISS'),
                    doc_seq.nextval,
                    sysdate,
                    (
                        select
                            account_num
                        from
                            payment_acc_info
                        where
                                account_type = 'GL_ACCOUNT'
                            and status = 'A'
                    ),
                    nvl((
                        select
                            account_num
                        from
                            payment_acc_info
                        where
                            substr(account_type, 1, 3) like substr(a.acc_num, 1, 3)
                                                            || '%'
                            and status = 'A'
                    ),
                        (
                        select
                            account_num
                        from
                            payment_acc_info
                        where
                                substr(account_type, 1, 3) = 'SHA'
                            and status = 'A'
                    )),
                    p_amount,
                    '('
                    || ( a.acc_num )
                    || ') '
                    || decode(p_date_of_service, null, '', ' DOS:')
                    || p_date_of_service
                    || decode(p_vendor_acc_num, null, '', ' Acct#: ' || p_vendor_acc_num)
                    || ' Patient Name: '
                    || p_patient_name
                    || p_note,
                    'PROVIDER_ONLINE',
                    'N',
                    'N',
                    'N',
                    p_date_of_service,
                    p_patient_name,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id
                from
                    account a,
                    person  b,
                    vendors c
                where
                        a.acc_num = c.acc_num
                    and a.pers_id = b.pers_id
                    and a.acc_num = p_acc_num
                    and a.acc_id = p_acc_id
                    and c.vendor_id = p_vendor_id;

            insert into claimn (
                claim_id,
                pers_id,
                pers_patient,
                claim_code,
                prov_name,
                claim_date_start,
                claim_date_end,
                service_status,
                claim_amount,
                claim_paid,
                claim_pending,
                note
            )
                select
                    claim_id,
                    pers_id,
                    pers_id,
                    claim_code,
                    provider_name,
                    sysdate,
                    trans_date,
                    2,
                    claim_amount,
                    claim_amount,
                    0,
                    'Disbursement Created on '
                    || to_char(trans_date, 'RRRRMMDD')
                    || ' from Online'
                from
                    payment_register a
                where
                        a.batch_number = l_batch_number
                    and a.acc_num = p_acc_num
                    and claim_error_flag = 'N';

            insert into payment (
                change_num,
                claimn_id,
                pay_date,
                amount,
                reason_code,
                pay_num,
                note,
                acc_id
            )
                select
                    change_seq.nextval,
                    a.claim_id,
                    trans_date,
                    b.claim_paid,
                    11,
                    null,
                    'Generate Disbursement ' || to_char(trans_date, 'RRRRMMDD'),
                    acc_id
                from
                    payment_register a,
                    claimn           b
                where
                        a.batch_number = l_batch_number
                    and a.claim_id = b.claim_id
                    and a.acc_num = p_acc_num
                    and b.claim_paid > 0
                    and claim_error_flag = 'N'
                    and insufficient_fund_flag = 'N';

        -- INSERT INTO CHECKS TABLE HERE
            for x in (
                select
                    a.claim_id,
                    c.amount,
                    c.acc_id
                from
                    payment_register a,
                    claimn           b,
                    payment          c
                where
                        a.batch_number = l_batch_number
                    and a.acc_num = p_acc_num
                    and nvl(a.cancelled_flag, 'N') = 'N'
                    and nvl(a.claim_error_flag, 'N') = 'N'
                    and nvl(a.insufficient_fund_flag, 'N') = 'N'
                    and nvl(a.peachtree_interfaced, 'N') = 'N'
                    and a.claim_id = b.claim_id
                    and b.claim_id = c.claimn_id
                    and c.acc_id = a.acc_id
                    and c.reason_code in ( 11, 12 )
            ) loop
                pc_check_process.insert_check(
                    p_claim_id     => x.claim_id,
                    p_check_amount => x.amount,
                    p_acc_id       => x.acc_id,
                    p_user_id      => p_user_id,
                    p_status       => 'OPEN',
                    p_source       => 'HSA_CLAIM',
                    x_check_number => l_check_number
                );
            end loop;

        else
            x_return_status := 'E';
            x_error_message := 'You do not have sufficient balance to schedule this disbursement';
        end if;

        pc_fin.bill_pay_fee(p_acc_id);
        for x in (
            select
                payment_register_id,
                a.created_by
            from
                payment_register a
            where
                a.batch_number = l_batch_number
        ) loop
            for xx in (
                select
                    case
                        when pc_claim.get_claim_3000_per_week(p_acc_id) > 0
                             and pc_claim.get_claim_8000_per_month(p_acc_id) = 0 then
                            'CLAIM_OVER_3000'
                    end template_name
                from
                    dual
                union
                select
                    case
                        when pc_claim.get_claim_8000_per_month(p_acc_id) > 0 then
                            'CLAIM_OVER_8000'
                    end
                from
                    dual
                union
                select
                    case
                        when pc_claim.get_denied_bank_draft(p_acc_id) > 0 then
                            'DENIED_BANK_DRAFT'
                    end
                from
                    dual
            ) loop
                pc_notifications.audit_review_notification(x.payment_register_id, xx.template_name, x.created_by);
            end loop;
        end loop;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end create_disbursement;

    procedure update_disbursement (
        p_register_id     in number,
        p_change_num      in number,
        p_claim_id        in number,
        p_vendor_id       in number,
        p_vendor_acc_num  in varchar2,
        p_date_of_service in varchar2,
        p_amount          in number,
        p_patient_name    in varchar2,
        p_note            in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_vendor_name varchar2(30);
    begin
        x_return_status := 'S';
  /* pc_log.log_error('PC_ONLINE.update_disbursement, Vendor id',P_VENDOR_ID);
   pc_log.log_error('PC_ONLINE.update_disbursement, amount',P_AMOUNT);
   pc_log.log_error('PC_ONLINE.update_disbursement, Vendor acc num',P_VENDOR_ACC_NUM);
    pc_log.log_error('PC_ONLINE.update_disbursement, P_REGISTER_ID',P_REGISTER_ID);*/

        for x in (
            select
                vendor_id,
                nvl(peachtree_interfaced, 'N') peachtree_interfaced,
                pc_account.acc_balance(acc_id) - ( claim_amount + nvl(
                    pc_fin.get_bill_pay_fee(acc_id),
                    0
                ) )                            balance
            from
                payment_register
            where
                payment_register_id = p_register_id
        ) loop
            pc_log.log_error('PC_ONLINE.update_disbursement',
                             'Updated vendors'
                             || x.balance
                             || ' '
                             || nvl(p_amount, 0));

            if x.peachtree_interfaced = 'N' then
                if x.balance > nvl(p_amount, 0) then
                    update payment_register
                    set
                        vendor_orig_sys = nvl(p_vendor_acc_num, vendor_orig_sys),
                        claim_amount = nvl(p_amount, claim_amount),
                        date_of_service = nvl(p_date_of_service, date_of_service),
                        patient_name = nvl(p_patient_name, patient_name),
                        note = nvl(p_note, note),
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        payment_register_id = p_register_id;

                    pc_log.log_error('PC_ONLINE.update_disbursement', 'Updated vendors');
                    update claimn
                    set
                        claim_paid = p_amount
                    where
                        claim_id = p_claim_id;

                    update payment
                    set
                        amount = p_amount
                    where
                        change_num = p_change_num;

                    update checks
                    set
                        check_amount = p_amount
                    where
                            entity_id = p_claim_id
                        and entity_type = 'HSA_CLAIM';

                else
                    x_return_status := 'E';
                    x_error_message := 'Cannot update disbursement, You do not have sufficient balance';
                end if;

            else
                x_return_status := 'E';
                x_error_message := 'Your disbursement has been processed already, cannot make any more changes';
            end if;

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_disbursement;

    procedure cancel_disbursement (
        p_register_id   in number,
        p_change_num    in number,
        p_claim_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('REGISTER_ID ', p_register_id);
        pc_log.log_error('P_CHANGE_NUM ', p_change_num);
        pc_log.log_error('P_CLAIM_ID ', p_claim_id);
        delete from payment
        where
            change_num = p_change_num;

        delete from payment b
        where
                reason_code = 14
            and claimn_id = p_claim_id;

        delete from claimn
        where
            claim_id = p_claim_id;

        update payment_register
        set
            cancelled_flag = 'Y',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            payment_register_id = p_register_id;

        update checks
        set
            status = 'CANCELLED'
        where
                entity_id = p_claim_id
            and entity_type = 'HSA_CLAIM';

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end cancel_disbursement;

    procedure pc_insert_enrollment_dep (
        p_first_name                 in varchar2,
        p_last_name                  in varchar2,
        p_middle_name                in varchar2,
        p_title                      in varchar2,
        p_gender                     in varchar2,
        p_birth_date                 in date,
        p_ssn                        in varchar2,
        p_id_type                    in varchar2,
        p_id_number                  in varchar2,
        p_address                    in varchar2,
        p_city                       in varchar2,
        p_state                      in varchar2,
        p_zip                        in varchar2,
        p_phone                      in varchar2,
        p_email                      in varchar2,
        p_carrier_id                 in number,
        p_plan_type                  in varchar2,
        p_health_plan_eff_date       in date,
        p_deductible                 in number,
        p_plan_code                  in number,
        p_broker_lic                 in varchar2,
        p_entrp_id                   in number,
        p_fee_pay_type               in number,
        p_er_contribution            in number,
        p_ee_contribution            in number,
        p_er_fee_contribution        in number,
        p_ee_fee_contribution        in number,
        p_contribution_frequency     in varchar2,
        p_debit_card_flag            in varchar2,
        p_user_name                  in varchar2,
        p_user_password              in varchar2,
        p_password_reminder_question in varchar2,
        p_password_reminder_answer   in varchar2,
        p_bank_name                  in varchar2,
        p_routing_number             in number,
        p_account_type               in varchar2,
        p_bank_account_number        in varchar2,
        p_enrollment_status          in varchar2,
        p_ip_address                 in varchar2,
        p_id_verification_status     in varchar2,
        p_transaction_id             in varchar2,
        p_verification_date          in varchar2,
        p_dep_first_name             in varchar2_tbl,
        p_dep_middle_name            in varchar2_tbl,
        p_dep_last_name              in varchar2_tbl,
        p_dep_gender                 in varchar2_tbl,
        p_dep_birth_date             in varchar2_tbl,
        p_dep_ssn                    in varchar2_tbl,
        p_dep_relative               in varchar2_tbl,
        p_dep_flag                   in varchar2_tbl,
        p_beneficiary_name           in varchar2_tbl,
        p_beneficiary_type           in varchar2_tbl,
        p_beneficiary_relation       in varchar2_tbl,
        p_ben_distiribution          in varchar2_tbl,
        p_dep_debit_card_flag        in varchar2_tbl,
        p_lang_perf                  in varchar2,
        p_business_name              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gverify                    in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gauthenticate              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gresponse                  in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_giact_verify               in varchar2      -- Added by Swamy for Ticket#10978 13062024
        ,
        p_bank_status                in varchar2       -- Added by Swamy for Ticket#10978 13062024
        ,
        p_bank_acct_id               out number       -- Added by Swamy for Ticket#10978 13062024
        ,
        x_enrollment_id              out number,
        x_error_message              out varchar2,
        x_return_status              out varchar2
    ) is

        l_sqlerrm                varchar2(3200);
        l_pers_id                number;
        l_acc_id                 number;
        l_card_id                number;
        l_bank_acct_id           number;
        l_transaction_id         number;
        l_action                 varchar2(255);
        l_create_error exception;
        l_setup_error exception;
        l_fraud_account          varchar2(30);
        l_return_status          varchar2(30);
        l_error_message          varchar2(3200);
        l_acc_num                varchar2(30);
        l_user_id                number;
        l_account_type           varchar2(30);
        l_deductible             number;
        l_primary_dist           number;
        l_contingent_dist        number;
        l_effective_date         date;
        l_dep_sp_count           number := 0;
        l_dep_pers_id            number;
        l_count                  number := 0;
        l_dep_enroll_id          number_tbl;
        l_dep_first_name         varchar2_tbl;
        l_dep_middle_name        varchar2_tbl;
        l_dep_last_name          varchar2_tbl;
        l_dep_gender             varchar2_tbl;
        l_dep_birth_date         varchar2_tbl;
        l_dep_ssn                varchar2_tbl;
        l_dep_relative           varchar2_tbl;
        l_dep_flag               varchar2_tbl;
        l_beneficiary_type       varchar2_tbl;
        l_beneficiary_relation   varchar2_tbl;
        l_ben_distiribution      varchar2_tbl;
        l_dep_debit_card_flag    varchar2_tbl;
        l_beneficiary_name       varchar2_tbl;
        l_bank_status            varchar2(50) := p_bank_status;
        l_id_verification_status varchar2(1);
    begin
        x_return_status := 'S';
        pc_log.log_error('START OF PROCEDURE', 'Inside Online Enrollment ');
        l_dep_first_name := array_fill(p_dep_first_name, p_dep_first_name.count);
        l_dep_middle_name := array_fill(p_dep_middle_name, p_dep_first_name.count);
        l_dep_last_name := array_fill(p_dep_last_name, p_dep_first_name.count);
        l_dep_gender := array_fill(p_dep_gender, p_dep_first_name.count);
        l_dep_birth_date := array_fill(p_dep_birth_date, p_dep_first_name.count);
        l_dep_ssn := array_fill(p_dep_ssn, p_dep_first_name.count);
        l_dep_relative := array_fill(p_dep_relative, p_dep_first_name.count);
        l_dep_flag := array_fill(p_dep_flag, p_dep_first_name.count);
        l_dep_debit_card_flag := array_fill(p_dep_debit_card_flag, p_dep_first_name.count);
        l_beneficiary_name := array_fill(p_beneficiary_name, p_beneficiary_name.count);
        l_beneficiary_type := array_fill(p_beneficiary_type, p_beneficiary_name.count);
        l_beneficiary_relation := array_fill(p_beneficiary_relation, p_beneficiary_name.count);
        l_ben_distiribution := array_fill(p_ben_distiribution, p_beneficiary_name.count);
        pc_log.log_error('PC_ONLINE', 'account_type ' || p_account_type);
        pc_log.log_error('PC_ONLINE', 'ee contribution ' || p_ee_contribution);

    -- Added this condition below to always mark the individual with no employer
    -- as fraud so that back office can request for form of ID to verify the account
        l_id_verification_status := p_id_verification_status;
        if p_entrp_id is null then
            l_id_verification_status := 1;
        end if;
        if p_account_type in ( 'CK', 'C' ) then
            l_account_type := 'C';
        else
            l_account_type := 'S';
        end if;

    -- Validations
        if p_ssn is null then
            x_error_message := 'Enter valid social security number';
            raise l_setup_error;
        end if;
        if p_birth_date > sysdate then
            x_error_message := 'Birth Date cannot be in future';
            raise l_setup_error;
        end if;
    /*IF P_DEDUCTIBLE IS NULL THEN
       x_error_message := 'Enter valid deductible';
       RAISE l_setup_error;
    END IF;*/
        if p_email is null then
            x_error_message := 'Enter valid email';
            raise l_setup_error;
        end if;
        if p_id_number is null then
            x_error_message := 'Enter valid ID Number';
            raise l_setup_error;
        end if;
        if p_plan_code is null then
            x_error_message := 'Enter valid plan';
            raise l_setup_error;
        end if;
        if nvl(
            pc_users.check_user_registered(p_ssn, 'S'),
            'N'
        ) = 'N' then
            if p_user_name is null then
                x_error_message := 'Enter valid user name';
                raise l_setup_error;
            end if;
            if p_user_password is null then
                x_error_message := 'Enter valid password';
                raise l_setup_error;
            end if;
            if p_password_reminder_question is null then
                x_error_message := 'Enter valid password reminder question';
                raise l_setup_error;
            end if;
            if p_password_reminder_answer is null then
                x_error_message := 'Enter valid password reminder answer';
                raise l_setup_error;
            end if;
        end if;

        if isalphanumeric(p_last_name) is not null then
            x_error_message := l_error_message
                               || ' Special Characters '
                               || isalphanumeric(p_last_name)
                               || ' are not allowed for last name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_first_name) is not null then
            x_error_message := l_error_message
                               || ' Special Characters '
                               || isalphanumeric(p_first_name)
                               || ' are not allowed for first name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_middle_name) is not null then
            x_error_message := l_error_message
                               || ' Special Characters '
                               || isalphanumeric(p_middle_name)
                               || ' are not allowed for middle name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_user_name) is not null then
            x_error_message := l_error_message
                               || ' Special Characters '
                               || isalphanumeric(p_user_name)
                               || ' are not allowed for user name ';
            raise l_setup_error;
        end if;
 /*   IF months_between(SYSDATE,TO_DATE(P_BIRTH_DATE))/12 < 16
    AND P_DEBIT_CARD_FLAG = 'Y' THEN
         x_error_message := 'Debit card cannot be ordered for you since you are less than 16 years ';
         RAISE l_setup_error;
    END IF;*/
        for i in 1..l_dep_birth_date.count loop
            if
                l_dep_flag(i) = 'DEPENDANT'
                and l_dep_last_name(i) is not null
                and ( l_dep_birth_date(i) is null
                      or to_date ( l_dep_birth_date(i) ) > sysdate )
            then
                x_error_message := 'Enter valid birth date for dependent '
                                   || l_dep_first_name(i)
                                   || ' '
                                   || l_dep_last_name(i);

                raise l_setup_error;
            end if;
        end loop;

        pc_log.log_error('PC_ONLINE', 'dependant relative checking');
        for i in 1..l_dep_relative.count loop
            if
                l_dep_flag(i) = 'DEPENDANT'
                and l_dep_relative(i) = '2'
                and l_dep_last_name(i) is not null
            then
                l_dep_sp_count := l_dep_sp_count + 1;
            end if;

            if l_dep_sp_count > 1 then
                x_error_message := 'Two dependent spouse cannot be present';
                raise l_setup_error;
            end if;
        end loop;

        for i in 1..l_dep_first_name.count loop
            if isalphanumeric(l_dep_last_name(i)) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(l_dep_last_name(i))
                                   || ' are not allowed for last name ';
                raise l_setup_error;
            end if;

            if isalphanumeric(l_dep_first_name(i)) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(l_dep_first_name(i))
                                   || ' are not allowed for first name ';
                raise l_setup_error;
            end if;

            if isalphanumeric(l_dep_middle_name(i)) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(l_dep_middle_name(i))
                                   || ' are not allowed for middle name ';
                raise l_setup_error;
            end if;

        end loop;

        pc_log.log_error('PC_ONLINE', 'dependant debit card checking');
        for i in 1..l_dep_debit_card_flag.count loop
            if
                l_dep_flag(i) = 'DEPENDANT'
                and nvl(p_debit_card_flag, 'N') = 'N'
                and l_dep_debit_card_flag(i) = 'Y'
                and l_dep_last_name(i) is not null
            then
                x_error_message := 'Debit card cannot be ordered for dependent '
                                   || l_dep_first_name(i)
                                   || ' '
                                   || l_dep_last_name(i)
                                   || 'unless account holder requests for card ';

                raise l_setup_error;
            end if;

            if
                l_dep_flag(i) = 'DEPENDANT'
                and l_dep_last_name(i) is not null
                and l_dep_debit_card_flag(i) = 'Y'
                and months_between(sysdate,
                                   to_date(l_dep_birth_date(i))) / 12 < 10
            then
                x_error_message := 'Debit card cannot be ordered for dependent '
                                   || l_dep_first_name(i)
                                   || ' '
                                   || l_dep_last_name(i)
                                   || 'since dependent age is less than 10 years ';

                raise l_setup_error;
            end if;

        end loop;

        pc_log.log_error('PC_ONLINE', 'dependant ssn checking');
        for i in 1..l_dep_ssn.count loop
            if
                l_dep_flag(i) = 'DEPENDANT'
                and ( l_dep_ssn(i) is null
                      or l_dep_ssn(i) like '--' )
                and l_dep_last_name(i) is not null
                and l_dep_debit_card_flag(i) in ( '1', 'Y' )
            then
                x_error_message := 'Enter valid social security number for dependent '
                                   || l_dep_first_name(i)
                                   || ' '
                                   || l_dep_last_name(i)
                                   || ' if a debit card is being requested ';

                raise l_setup_error;
            end if;
        end loop;

        pc_log.log_error('PC_ONLINE',
                         'l_BENEFICIARY_TYPE checking'
                         || l_beneficiary_type(1)
                         || l_ben_distiribution(1));

        for i in 1..l_beneficiary_type.count loop
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'l_BENEFICIARY_TYPE in loop ' ||(i));
            if instr(
                translate(
                    l_ben_distiribution(i),
                    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                ),
                'X'
            ) > 0 then
                x_error_message := 'Enter valid value for distribution , distribution cannot contain characters';
                raise l_setup_error;
            elsif instr(
                translate(
                    l_ben_distiribution(i),
                    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                    'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                ),
                'X'
            ) = 0 then
                if l_ben_distiribution(i) is null
                   or l_ben_distiribution(i) = '' then
                    x_error_message := 'Enter valid value for distribution , distribution cannot be null';
                    raise l_setup_error;
                end if;

                pc_log.log_error('PC_ONLINE', 'Checking BEN_DISTIRIBUTION ' ||(i));
                if is_number(replace(
                    l_ben_distiribution(i),
                    '%'
                )) = 'Y' then
                    if to_number ( replace(
                        l_ben_distiribution(i),
                        '%'
                    ) ) < 0 then
                        x_error_message := 'Enter valid value for distribution , distribution cannot be zero/negative';
                        raise l_setup_error;
                    end if;
                end if;

            end if;

            pc_log.log_error('PC_ONLINE', 'l_BENEFICIARY_distribution checking ');
            if
                l_ben_distiribution(i) is null
                and l_beneficiary_name(i) is not null
            then
                x_error_message := 'Enter valid value for distribution , distribution cannot be null';
                raise l_setup_error;
            end if;

            pc_log.log_error('PC_ONLINE', 'primary/contingent distribution checking ');
            if l_beneficiary_type(i) = '1' then
                pc_log.log_error('PC_ONLINE_ENROLLMENT', 'adding to primary/contingent distribution checking ');
                if is_number(replace(
                    l_ben_distiribution(i),
                    '%'
                )) = 'Y' then
                    l_primary_dist := nvl(l_primary_dist, 0) + trim(replace(
                        l_ben_distiribution(i),
                        '%'
                    ));

                end if;

                if l_primary_dist > 100 then
                    x_error_message := 'Distribution cannot exceed 100% for primary beneficiary type';
                    raise l_setup_error;
                end if;
            else
                if is_number(l_ben_distiribution(i)) = 'Y' then
                    l_contingent_dist := nvl(l_contingent_dist, 0) + trim(replace(
                        l_ben_distiribution(i),
                        '%'
                    ));
                end if;

                if l_contingent_dist > 100 then
                    x_error_message := 'Distribution cannot exceed 100% for contingent beneficiary type';
                    raise l_setup_error;
                end if;
            end if;

        end loop;

--    END IF;

    -- End of Validations

        insert into online_enrollment (
            enrollment_id,
            first_name,
            last_name,
            middle_name,
            title,
            gender,
            birth_date,
            ssn,
            id_type,
            id_number,
            address,
            city,
            state,
            zip,
            phone,
            email,
            carrier_id,
            plan_type,
            health_plan_eff_date,
            deductible,
            plan_code,
            broker_lic,
            entrp_id,
            fee_pay_type,
            er_contribution,
            ee_contribution,
            er_fee_contribution,
            ee_fee_contribution,
            contribution_frequency,
            debit_card_flag,
            user_name,
            user_password,
            password_reminder_question,
            password_reminder_answer,
            bank_name,
            routing_number,
            account_type,
            bank_account_number,
            enrollment_status,
            ip_address,
            lang_perf,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( mass_enrollments_seq.nextval,
                   initcap(p_first_name),
                   initcap(p_last_name),
                   p_middle_name,
                   p_title,
                   p_gender,
                   p_birth_date,
                   p_ssn,
                   p_id_type,
                   p_id_number,
                   p_address,
                   initcap(p_city),
                   upper(p_state),
                   p_zip,
                   p_phone,
                   p_email,
                   p_carrier_id,
                   decode(p_plan_type, 0, 0, 1) -- Added by jaggi#10456 coverage tiers  EE+SPOUSE  EE+CHILDREN  should come as FAMILY
                   ,
                   nvl(p_health_plan_eff_date, sysdate),
                   p_deductible,
                   p_plan_code,
                   p_broker_lic,
                   p_entrp_id,
                   p_fee_pay_type,
                   p_er_contribution,
                   p_ee_contribution,
                   p_er_fee_contribution,
                   p_ee_fee_contribution,
                   p_contribution_frequency,
                   p_debit_card_flag,
                   p_user_name,
                   p_user_password,
                   p_password_reminder_question,
                   p_password_reminder_answer,
                   p_bank_name,
                   p_routing_number,
                   l_account_type,
                   p_bank_account_number,
                   p_enrollment_status,
                   p_ip_address,
                   p_lang_perf,
                   sysdate,
                   421,
                   sysdate,
                   421 ) returning enrollment_id into x_enrollment_id;

        pc_log.log_error('PC_ONLINE', 'Inserted into enrollment table  ' || x_enrollment_id);
        pc_log.log_error('PC_ONLINE', 'First Name  '
                                      || p_first_name
                                      || 'Last Name  '
                                      || p_last_name
                                      || 'SSN '
                                      || p_ssn
                                      || 'Health plan effective date '
                                      || p_health_plan_eff_date);

        pc_log.log_error('PC_ONLINE', 'Generated acc num  ' || l_acc_num);
        savepoint enroll_savepoint;
        for x in (
            select
                enrollment_id,
                first_name,
                last_name,
                middle_name,
                title,
                gender,
                birth_date,
                ssn,
                decode(id_type, 'D', id_number)            drivers_lic,
                decode(id_type, 'P', id_number)            passport,
                address,
                city,
                state,
                zip,
                phone,
                email,
                carrier_id,
                plan_type,
                health_plan_eff_date,
                deductible,
                plan_code,
                broker_lic,
                entrp_id,
                fee_pay_type,
                er_contribution,
                ee_contribution,
                er_fee_contribution,
                ee_fee_contribution,
                contribution_frequency,
                debit_card_flag,
                user_name,
                user_password,
                password_reminder_question,
                password_reminder_answer,
                bank_name,
                routing_number,
                account_type,
                bank_account_number,
                enrollment_status,
                error_message,
                ip_address,
                pc_account.get_salesrep_id(null, entrp_id) salesrep_id,
                lang_perf
            from
                online_enrollment
            where
                enrollment_id = x_enrollment_id
        ) loop
            begin
                l_fraud_account := 'N';
                l_return_status := 'S';
                check_fraud(
                    p_first_name    => x.first_name,
                    p_last_name     => x.last_name,
                    p_ssn           => x.ssn,
                    p_address       => x.address,
                    p_city          => x.city,
                    p_state         => x.state,
                    p_zip           => x.zip,
                    p_drivlic       => x.drivers_lic,
                    p_phone         => x.phone,
                    p_email         => x.email,
                    x_fraud_accunt  => l_fraud_account,
                    x_return_status => l_return_status,
                    x_error_message => l_error_message
                );

                if l_fraud_account = 'Y'
                or l_return_status = 'E' then
                    x_error_message := 'Cannot enroll account. Please contact customer service at 800-617-4729 between 8AM-6PM Pacific Time.'
                    ;
                    raise l_create_error;
                end if;

                if pc_account.check_duplicate(x.ssn, null, null, 'HSA', x.entrp_id) = 'Y' then
                    x_error_message := 'Cannot enroll, this ssn already has an account ';       -- SSN removed by Jaggi #9957
                    raise l_create_error;
                end if;
            /*** Creating Person ****/
                l_action := 'Creating Person';
                for xx in (
                    select
                        effective_date,
                        decode(x.plan_type, 0, single_deductible, 1, family_deductible) deductible
                    from
                        employer_health_plans
                    where
                            entrp_id = x.entrp_id
                        and carrier_id = x.carrier_id
                ) loop
                    l_effective_date := xx.effective_date;
                    l_deductible := xx.deductible;
                    l_count := l_count + 1;
                end loop;

                if
                    l_effective_date is null
                    and l_count > 0
                then
                    x_error_message := 'Employer Health plan does not have a effective date defined, Cannot enroll without effective date'
                    ;
                    raise l_setup_error;
                end if;

                if
                    l_deductible is null
                    and x.deductible is null
                then
                    x_error_message := 'Enter valid deductible';
                    raise l_setup_error;
                end if;

                insert into person (
                    pers_id,
                    first_name,
                    middle_name,
                    last_name,
                    birth_date,
                    title,
                    gender,
                    ssn,
                    drivlic,
                    passport,
                    address,
                    city,
                    state,
                    zip,
                    phone_day,
                    email,
                    relat_code,
                    note,
                    entrp_id,
                    person_type,
                    mass_enrollment_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( pers_seq.nextval,
                           x.first_name,
                           x.middle_name,
                           x.last_name,
                           x.birth_date,
                           pc_lookups.get_title(x.title),
                           x.gender,
                           x.ssn,
                           x.drivers_lic,
                           x.passport,
                           x.address,
                           x.city,
                           x.state,
                           x.zip,
                           decode(x.phone, '--', null, x.phone),
                           x.email,
                           1,
                           'Online Enrollment',
                           x.entrp_id,
                           'SUBSCRIBER',
                           x_enrollment_id,
                           sysdate,
                           421,
                           sysdate,
                           421 ) returning pers_id into l_pers_id;

                l_acc_num := pc_account.generate_acc_num(x.plan_code,
                                                         upper(x.state));

            /*** Insert Account, Insurance, Income and Debit Card ****/
                l_action := 'Creating Account';
                insert into account (
                    acc_id,
                    pers_id,
                    acc_num,
                    plan_code,
                    start_date,
                    start_amount,
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
                    blocked_flag,
                    id_verified
                ) values ( acc_seq.nextval,
                           l_pers_id,
                           l_acc_num,
                           x.plan_code,
                           greatest(
                               nvl(l_effective_date, sysdate),
                               sysdate
                           ),
                           nvl(x.er_contribution, 0) + nvl(x.ee_contribution, 0) + nvl(x.ee_fee_contribution, 0) + nvl(x.er_fee_contribution
                           , 0),
                           case
                               when x.broker_lic is null
                                    and x.entrp_id is not null then
                                   (
                                       select
                                           broker_id
                                       from
                                           account
                                       where
                                           entrp_id = x.entrp_id
                                   )
                               when x.broker_lic is null then
                                   0
                               else
                                   (
                                       select
                                           broker_id
                                       from
                                           broker
                                       where
                                           broker_lic = x.broker_lic
                                   )
                           end,
                           'Online Enrollment',
                           decode(x.entrp_id,
                                  null,
                                  pc_plan.fsetup_online(-1),
                                  nvl(
                               pc_plan.fsetup_custom_rate(x.plan_code, x.entrp_id),
                               least(
                                   pc_plan.fsetup_er(x.entrp_id),
                                   pc_plan.fsetup_online(0)
                               )
                           )),
                           nvl(
                               pc_plan.fmonth_er(x.entrp_id),
                               pc_plan.fmonth(x.plan_code)
                           ),
                           sysdate,
                           3,
                           1,
                           'Y',
                           greatest(
                               nvl(l_effective_date, sysdate),
                               sysdate
                           ),
                           'HSA',
                           'ONLINE',
                           x.salesrep_id,
                           x.lang_perf,
                           decode(l_id_verification_status, 0, 'N', 'Y') -- added for id verification with veratad
                           ,
                           decode(p_id_verification_status, 0, 'Y', 'N') ) -- added for id verification with veratad
                                                                 -- if successful then id is verified , if not
                                                                 -- then include in the batch
                            returning acc_id into l_acc_id;

                dbms_output.put_line('creating insure ');

           /*** Creating Insurance Information ***/

                l_action := 'Creating Health Plan';
                insert into insure (
                    pers_id,
                    insur_id,
                    start_date,
                    deductible,
                    note,
                    plan_type
                ) values ( l_pers_id,
                           x.carrier_id,
                           nvl(
                               nvl(l_effective_date, x.health_plan_eff_date),
                               sysdate
                           ),
                           case
                               when nvl(l_deductible, x.deductible) is null then
                                   decode(x.plan_type, 0, 1200, 1, 2400)
                               else
                                   nvl(l_deductible, x.deductible)
                           end,
                           'Online Enrollment',
                           x.plan_type );

                dbms_output.put_line('creating card ');

           /*** Creating Debit Card Information ***/
                pc_log.log_error('PC_ONLINE', 'Creating Debit Card for ' || l_pers_id);
                if
                    x.debit_card_flag = 'Y'
                    and ( (
                        x.entrp_id is not null
                        and nvl(
                            pc_person.card_allowed(l_pers_id),
                            0
                        ) = 0
                    )
                    or x.entrp_id is null )
                then
                    pc_log.log_error('PC_ONLINE', 'Inserting Debit Card for ' || l_pers_id);
                    insert into card_debit (
                        card_id,
                        start_date,
                        emitent,
                        status,
                        note,
                        max_card_value,
                        last_update_date
                    ) values ( l_pers_id,
                               greatest(
                                   nvl(l_effective_date, x.health_plan_eff_date),
                                   sysdate
                               ),
                               6763,
                               case
                                   when pc_plan.can_create_card_on_pend(x.plan_code) = 'Y' then
                                       1
                                   else
                                       9
                               end,
                               'Automatic Online Enrollment',
                               0,
                               sysdate ) returning card_id into l_card_id;
                --  PC_FIN.CARD_OPEN_FEE(l_pers_id);
                end if;

           /*** Creating Bank Account Information ***/
                if x.bank_name is not null then
                    l_action := 'Creating Bank Account';
             -- Commented by Swamy for Ticket#10978 13062024
             /*
             pc_user_bank_acct.insert_user_bank_acct
             (p_acc_num             => l_acc_num
             ,p_display_name       => x.bank_name
             ,p_bank_acct_type     => x.account_type
             ,p_bank_routing_num   => x.routing_number
             ,p_bank_acct_num      => x.bank_account_number
             ,p_bank_name          => x.bank_name
             ,p_user_id            => 421
             ,x_bank_acct_id       => l_bank_acct_id
             ,x_return_status      => l_return_status
             ,x_error_message      => x_error_message);

             IF l_return_status <> 'S' THEN
                RAISE l_setup_error;
             END IF;
             */
                    pc_log.log_error('PC_ONLINE', 'Creating Debit Card for  l_bank_status' || l_bank_status);
                    pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#10978 13062024
                    (
                        p_acc_num          => l_acc_num,
                        p_entity_id        => l_acc_id     -- Added by Swamy for Ticket#12309
                        ,
                        p_entity_type      => 'ACCOUNT'    -- Added by Swamy for Ticket#12309
                        ,
                        p_display_name     => x.bank_name,
                        p_bank_acct_type   => x.account_type,
                        p_bank_routing_num => x.routing_number,
                        p_bank_acct_num    => x.bank_account_number,
                        p_bank_name        => x.bank_name,
                        p_business_name    => p_business_name,
                        p_user_id          => 421,
                        p_gverify          => p_gverify,
                        p_gauthenticate    => p_gauthenticate,
                        p_gresponse        => p_gresponse,
                        p_giact_verify     => p_giact_verify,
                        p_bank_status      => l_bank_status,
                        p_auto_pay         => 'N'         -- Added by Swamy for Ticket#12309 13062024
                        ,
                        p_bank_acct_usage  => 'ONLINE'    -- Added by Swamy for Ticket#12309
                        ,
                        p_division_code    => null,
                        p_source           => null,
                        x_bank_acct_id     => l_bank_acct_id,
                        x_return_status    => l_return_status,
                        x_error_message    => x_error_message
                    );

                    p_bank_acct_id := l_bank_acct_id;
                    if l_return_status not in ( 'S', 'P', 'R' ) then   -- Added by Swamy for Ticket#10978 13062024
                        raise l_create_error;
                    end if;
                    if nvl(l_bank_status, '*') = 'A' then  -- If cond.Added by Swamy for Ticket#10978 13062024
           /*** Scheduling for ACH transfer ***/
                        pc_log.log_error('PC_ONLINE',
                                         'ee contribution '
                                         || to_char(nvl(x.er_contribution, 0) + nvl(x.ee_contribution, 0) + nvl(x.er_fee_contribution
                                         , 0) + nvl(x.ee_fee_contribution, 0)));

                        if nvl(x.er_contribution, 0) + nvl(x.ee_contribution, 0) + nvl(x.er_fee_contribution, 0) + nvl(x.ee_fee_contribution
                        , 0) > 0 then
                            l_action := 'Scheduling ACH transfer';
                            pc_ach_transfer.ins_ach_transfer(
                                p_acc_id           => l_acc_id,
                                p_bank_acct_id     => l_bank_acct_id,
                                p_transaction_type => 'C',
                                p_amount           => nvl(x.er_contribution, 0) + nvl(x.ee_contribution, 0),
                                p_fee_amount       => nvl(x.er_fee_contribution, 0) + nvl(x.ee_fee_contribution, 0),
                                p_transaction_date => greatest(
                                    nvl(l_effective_date, x.health_plan_eff_date),
                                    sysdate
                                ),
                                p_reason_code      => 3 -- initial contribution
                                ,
                                p_status           => 1 -- Pending
                                ,
                                p_user_id          => 421,
                                x_transaction_id   => l_transaction_id,
                                x_return_status    => l_return_status,
                                x_error_message    => x_error_message
                            );

                            pc_log.log_error('pc_ach_transfer', 'l_transaction_id ' || l_transaction_id);
                            if l_return_status <> 'S' then
                                raise l_create_error;
                            end if;
                        end if;

                    end if;

                    pc_log.log_error('PC_ONLINE', '**1 Creating Debit Card for  l_bank_status'
                                                  || l_bank_status
                                                  || ' l_Acc_id :='
                                                  || l_acc_id);   
           -- Added by Swamy for Ticket#10978 13062024
           -- Only for individuals the account status should change to pending bank verification 
                    if
                        nvl(l_bank_status, '*') = 'W'
                        and nvl(x.entrp_id, 0) = 0
                    then
                        update account
                        set
                            account_status = '11'
                        where
                            acc_id = l_acc_id;

                    end if;

                end if;
          -- SELECT acc_num INTO l_acc_num FROM account WHERE acc_id = l_acc_id;

                l_action := 'Creating User';
                if pc_users.check_user_registered(x.ssn, 'S') = 'N' then
                    pc_users.insert_users(
                        p_user_name     => p_user_name,
                        p_password      => p_user_password,
                        p_user_type     => 'S',
                        p_find_key      => l_acc_num,
                        p_email         => p_email,
                        p_pw_question   => p_password_reminder_question,
                        p_pw_answer     => p_password_reminder_answer,
                        p_tax_id        => x.ssn,
                        x_user_id       => l_user_id,
                        x_return_status => l_return_status,
                        x_error_message => x_error_message
                    );

                    if l_return_status <> 'S' then
                        raise l_create_error;
                    end if;
                else
                    if pc_users.get_user_count(x.ssn, 'S') > 1 then
                        x_error_message := pc_users.g_dup_user_for_tax;
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                        raise l_create_error;
                    else
                        l_user_id := pc_users.get_user(x.ssn, 'S');
                    end if;
                end if;
          -- added for id verification with veratad
           -- if successful then id is verified , if not
           -- then include in the batch
                if l_user_id is not null then
                    if p_id_verification_status <> 0 then
                        update online_users
                        set
                            blocked = 'Y'
                        where
                            user_id = l_user_id;

                    else
                        pc_webservice_batch.process_online_verification(
                            p_acc_num           => l_acc_num,
                            p_transaction_id    => p_transaction_id,
                            p_verification_date => p_verification_date,
                            x_return_status     => l_return_status,
                            x_error_message     => x_error_message
                        );

                        if l_return_status <> 'S' then
                            raise l_create_error;
                        end if;
                    end if;
                end if;

		    -- Added by Joshi for 6794 : Migrate individual to ACN.
                if x.plan_code = 1 then
                    insert into acn_employee_migration (
                        mig_seq_no,
                        acc_id,
                        pers_id,
                        account_type,
                        action_type,
                        subscriber_type,
                        creation_date,
                        created_by
                    ) values ( mig_seq.nextval,
                               l_acc_id,
                               l_pers_id,
                               'HSA',
                               'I',
                               'I',
                               sysdate,
                               0 );

                    pc_log.log_error('PC_ONLINE_ENROLLMENT', 'inserted in acn_employee_migration table ' || l_pers_id);
                end if;
           -- code ends here: 6794

                update online_enrollment
                set
                    acc_id = l_acc_id,
                    pers_id = l_pers_id,
                    acc_num = l_acc_num,
                    enrollment_status = 'S',
                    error_message = null,
                    user_password = decode(user_name, null, null, user_password),
                    password_reminder_question = decode(user_name, null, null, password_reminder_question)
                where
                    enrollment_id = x_enrollment_id;

            exception
                when l_create_error then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || x_error_message;
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E',
                        fraud_flag = l_fraud_account
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                when others then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = x_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                    dbms_output.put_line('error message ' || sqlerrm);
            end;
        end loop;

        pc_log.log_error('PC_INSERT_DEPENDANT', 'Inserting into dependant'
                                                || p_dep_first_name.count
                                                || 'last name '
                                                || p_dep_last_name.count
                                                || 'birth date '
                                                || p_dep_birth_date.count
                                                || 'ssn '
                                                || p_dep_ssn.count
                                                || 'relative '
                                                || p_dep_relative.count
                                                || 'dep_flag '
                                                || p_dep_flag.count
                                                || 'dep_gender '
                                                || p_dep_gender.count
                                                || 'ben type '
                                                || p_beneficiary_type.count
                                                || 'ben relation count '
                                                || p_beneficiary_relation.count
                                                || ' dist '
                                                || p_ben_distiribution.count
                                                || 'debit card flag '
                                                || p_dep_debit_card_flag.count);

     --END IF;
        if x_return_status = 'S' then
     /** Dependant Insert **/
            for i in 1..l_dep_first_name.count loop
                pc_log.log_error('PC_INSERT_DEPENDANT',
                                 'Inserting into dependant'
                                 || l_dep_first_name(i)
                                 || 'last name '
                                 || l_dep_last_name(i)
                                 || 'birth date '
                                 || l_dep_birth_date(i)
                                 || 'ssn '
                                 || l_dep_ssn(i)
                                 || 'relative '
                                 || l_dep_relative(i)
                                 || 'debit card flag '
                                 || l_dep_debit_card_flag(i));

                insert into mass_enroll_dependant (
                    mass_enrollment_id,
                    subscriber_ssn,
                    first_name,
                    middle_name,
                    last_name,
                    gender,
                    birth_date,
                    ssn,
                    relative,
                    dep_flag,
                    beneficiary_type,
                    beneficiary_relation,
                    effective_date,
                    distiribution,
                    debit_card_flag,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                )
                    select
                        mass_enrollments_seq.nextval,
                        p_ssn,
                        l_dep_first_name(i),
                        decode(
                            l_dep_middle_name(i),
                            '',
                            null,
                            l_dep_middle_name(i)
                        ),
                        decode(
                            l_dep_last_name(i),
                            '',
                            null,
                            l_dep_last_name(i)
                        ),
                        null,
                        l_dep_birth_date(i),
                        l_dep_ssn(i),
                        l_dep_relative(i),
                        'DEPENDANT',
                        null,
                        null,
                        sysdate,
                        null,
                        l_dep_debit_card_flag(i),
                        sysdate,
                        421,
                        sysdate,
                        421
                    from
                        dual
                    where
                        decode(
                            l_dep_last_name(i),
                            null,
                            '-1',
                            '',
                            '-1',
                            l_dep_last_name(i)
                        ) <> '-1';

                pc_log.log_error('INSERTed DEPENDANT', sql%rowcount);
            end loop;

            for i in 1..l_beneficiary_name.count loop
                pc_log.log_error('PC_INSERT_BENEFICAIRY',
                                 'ben name '
                                 || l_beneficiary_name(i)
                                 || 'ben type '
                                 || l_beneficiary_type(i)
                                 || 'ben relation count '
                                 || l_beneficiary_relation(i)
                                 || ' dist '
                                 || l_ben_distiribution(i));

                insert into mass_enroll_dependant (
                    mass_enrollment_id,
                    subscriber_ssn,
                    first_name,
                    middle_name,
                    last_name,
                    gender,
                    birth_date,
                    ssn,
                    relative,
                    dep_flag,
                    beneficiary_type,
                    beneficiary_relation,
                    effective_date,
                    distiribution,
                    debit_card_flag,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                )
                    select
                        mass_enrollments_seq.nextval,
                        p_ssn,
                        null,
                        null,
                        l_beneficiary_name(i),
                        null,
                        null,
                        null,
                        null,
                        'BENEFICIARY',
                        l_beneficiary_type(i),
                        l_beneficiary_relation(i),
                        sysdate,
                        l_ben_distiribution(i),
                        null,
                        sysdate,
                        421,
                        sysdate,
                        421
                    from
                        dual
                    where
                        decode(
                            l_beneficiary_name(i),
                            null,
                            '-1',
                            '',
                            '-1',
                            l_beneficiary_name(i)
                        ) <> '-1';

                pc_log.log_error('INSERTed BENEFICIARY', sql%rowcount);
            end loop;

            x_return_status := 'S';
     --savepoint  dep_savepoint;

            for x in (
                select
                    subscriber_ssn,
                    a.first_name,
                    a.middle_name,
                    a.last_name,
                    a.gender,
                    a.birth_date,
                    a.ssn,
                    a.relative,
                    a.dep_flag,
                    a.beneficiary_type,
                    a.beneficiary_relation,
                    a.effective_date,
                    a.distiribution,
                    a.debit_card_flag,
                    b.pers_id,
                    c.start_date,
                    (
                        select
                            status
                        from
                            card_debit
                        where
                            card_id = b.pers_id
                    ) card_status,
                    a.mass_enrollment_id
                from
                    mass_enroll_dependant a,
                    person                b,
                    insure                c
                where
                        a.subscriber_ssn = b.ssn
                    and b.pers_id = c.pers_id
                    and a.subscriber_ssn = p_ssn
                    and a.last_name is not null
                    and a.error_column is null
                    and a.error_message is null
                    and not exists (
                        select
                            *
                        from
                            person
                        where
                            person.mass_enrollment_id = a.mass_enrollment_id
                    )
            ) loop
                pc_log.log_error('INSERTING DEPENDANT', x.first_name
                                                        || ' '
                                                        || x.last_name
                                                        || ' '
                                                        || x.birth_date
                                                        || x.dep_flag);

                if upper(x.dep_flag) = 'DEPENDANT' then
                    insert into person (
                        pers_id,
                        first_name,
                        middle_name,
                        last_name,
                        birth_date,
                        gender,
                        ssn,
                        relat_code,
                        note,
                        pers_main,
                        person_type,
                        mass_enrollment_id,
                        card_issue_flag,
                        pers_start_date
                    ) values ( pers_seq.nextval,
                               x.first_name,
                               x.middle_name,
                               x.last_name,
                               to_date(x.birth_date, 'DD-MON-YYYY'),
                               x.gender,
                               trim(x.ssn),
                               to_number(x.relative),
                               'Online Enrollments',
                               x.pers_id,
                               'DEPENDANT',
                               x.mass_enrollment_id,
                               x.debit_card_flag,
                               sysdate ) returning pers_id into l_dep_pers_id;

                    if
                        x.debit_card_flag = 'Y'
                        and nvl(
                            pc_person.card_allowed(l_pers_id),
                            0
                        ) = 0
                    then
                        insert into card_debit (
                            card_id,
                            start_date,
                            emitent,
                            status,
                            note,
                            max_card_value,
                            last_update_date
                        ) values ( l_dep_pers_id,
                                   greatest(x.start_date, sysdate),
                                   6763,
                                   decode(x.card_status, 9, 9, 1),
                                   'Automatic Online Enrollment',
                                   0,
                                   sysdate );

                --  PC_FIN.CARD_OPEN_FEE(x.pers_id);
                    end if;

                end if;

                if ( x.dep_flag in ( 'BENEFICIARY', 'Beneficiary' )
                     or (
                    x.dep_flag in ( 'Dependant', 'Dependent' )
                    and x.beneficiary_type is not null
                    and x.distiribution is not null
                ) ) then
                    insert into beneficiary (
                        beneficiary_id,
                        beneficiary_name,
                        beneficiary_type,
                        relat_code,
                        effective_date,
                        pers_id,
                        creation_date,
                        created_by,
                        distribution,
                        note,
                        mass_enrollment_id
                    ) values ( beneficiary_seq.nextval,
                               x.last_name,
                               decode(x.beneficiary_type, 'PRIMARY', 1, 'CONTINGENT', 2,
                                      x.beneficiary_type),
                               x.beneficiary_relation,
                               sysdate,
                               x.pers_id,
                               sysdate,
                               421,
                               trim(x.distiribution),
                               'Online Automatic Enrollments',
                               x.mass_enrollment_id );

                end if;

            end loop;

        end if;

    exception
        when l_setup_error then
            rollback;
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLLMENT', x_error_message);
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := x_error_message;
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Exception in enrollment  '
                                                     || x_error_message
                                                     || sqlerrm);
    end pc_insert_enrollment_dep;

    procedure check_fraud (
        p_first_name    in varchar2,
        p_last_name     in varchar2,
        p_ssn           in varchar2,
        p_address       in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zip           in varchar2,
        p_drivlic       in varchar2,
        p_phone         in varchar2,
        p_email         in varchar2,
        x_fraud_accunt  out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_fraud_error exception;
    begin
        x_fraud_accunt := 'N';
        x_return_status := 'S';
        for x in (
            select
                *
            from
                blocked_accounts_mv
        ) loop
            if soundex(upper((replace(x.first_name, ' '))))
               || soundex(upper((replace(x.last_name, ' ')))) = soundex(upper((replace(p_first_name, ' '))))
                                                                || soundex(upper((replace(p_last_name, ' ')))) then
                x_fraud_accunt := 'Y';
                x_return_status := 'E';
                x_error_message := 'Name matches with fraud database with account ' || x.acc_num;
                raise l_fraud_error;
            end if;

            if upper((replace(x.address, ' ')))
               || upper(replace(x.city, ' '))
               || upper(replace(x.state, ' ')) = upper((replace(p_address, ' ')))
                                                 || upper(replace(p_city, ' '))
                                                 || upper(replace(p_state, ' ')) then
                x_fraud_accunt := 'Y';
                x_return_status := 'E';
                x_error_message := 'Address matches with fraud database with account ' || x.acc_num;
                raise l_fraud_error;
            end if;

            if substr(
                replace(x.ssn, '-'),
                1,
                8
            ) = substr(
                replace(p_ssn, '-'),
                1,
                8
            ) then
                x_fraud_accunt := 'Y';
                x_return_status := 'E';
                x_error_message := 'SSN matches with fraud database with account ' || x.acc_num;
                raise l_fraud_error;
            end if;

            if upper((replace(x.drivlic, ' '))) = upper((replace(p_drivlic, ' '))) then
                x_fraud_accunt := 'Y';
                x_return_status := 'E';
                x_error_message := 'Driver License matches with fraud database with account ' || x.acc_num;
                raise l_fraud_error;
            end if;

            if ( replace(x.phone_day, '-') ) = ( replace(p_phone, ' ') ) then
                x_fraud_accunt := 'Y';
                x_return_status := 'E';
                x_error_message := 'Phone matches with fraud database with account ' || x.acc_num;
                raise l_fraud_error;
            end if;

            if ( replace(x.email, '-') ) = ( replace(p_email, ' ') ) then
                x_fraud_accunt := 'Y';
                x_return_status := 'E';
                x_error_message := 'Email matches with fraud database with account ' || x.acc_num;
                raise l_fraud_error;
            end if;

        end loop;

    exception
        when l_fraud_error then
            null;
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end;

    function alert_box_message (
        p_tax_id       in varchar2,
        p_account_type in varchar2
    ) return alerts_t
        pipelined
        deterministic
    is

        l_record             alerts_row;
        l_renewal_count      number := 0;
        l_enrolled_count     number := 0;
        l_not_enrolled_count number := 0;
        l_ben_approve_count  number := 0;
        l_ann_count          number := 0;
        i                    number := 0;
        l_table              varchar2_tbl;
    begin

    -- Renewal alerts
        if p_account_type is not null then
            select
                count(a.acc_num)
            into l_renewal_count
            from
                enterprise                                                                   c,
                account                                                                      b,
                table ( pc_web_compliance.get_er_plans(acc_id, p_account_type, entrp_code) ) a
            where
                    c.entrp_id = b.entrp_id
                and c.entrp_code = p_tax_id
                and b.account_type = p_account_type
                and a.renewed = 'N'
                and a.declined = 'N';

            if l_renewal_count > 0 then
                i := i + 1;
                l_table(i) := '; Attention! Please click; '
                              || '<a href="/'
                              ||
                    case
                        when p_account_type = 'ERISA_WRAP' then
                            'ERISA'
                        else p_account_type
                    end
                              || '/Employers/Renewal/" class="here_sty"><b>here</b></a>;to renew '
                              || pc_lookups.get_account_type(p_account_type)
                              || ' Plan.';

            end if;

        else
            select
                count(a.acc_num)
            into l_renewal_count
            from
                enterprise                                                                   c,
                account                                                                      b,
                table ( pc_web_compliance.get_er_plans(acc_id, b.account_type, entrp_code) ) a
            where
                    c.entrp_id = b.entrp_id
                and c.entrp_code = p_tax_id
                and a.renewed = 'N'
                and a.declined = 'N';

            if l_renewal_count > 0 then
                i := i + 1;
                l_table(i) := '; Attention! Please click; '
                              || '<a href="/Employers/OnlineRenewal/" class="here_sty"><b>here</b></a>;to renew '
                              || pc_lookups.get_account_type(p_account_type)
                              || ' Plan.';

            end if;

        end if;

        select
            count(*)
        into l_enrolled_count
        from
            online_users a,
            enterprise   b,
            account      c
        where
                a.tax_id = p_tax_id
            and a.tax_id = b.entrp_code
            and b.entrp_id = c.entrp_id
            and c.account_status = 3
            and c.complete_flag <> 1
            and a.user_status = 'A'
            and c.account_type not in ( 'HRA', 'FSA' )--Remove it later when FSA/HRA are included
            and c.decline_date is null;

        if l_enrolled_count > 1 then
            i := i + 1;
            l_table(i) := '; Attention! You have pending product enrollments that need to be completed. '
                          || 'Please click <a  href="/Accounts/Portfolio/newEREnroll/" class="here_sty"><strong>here</strong></a> '
                          || 'to begin finalizing your benefits.';
        end if;

        if l_enrolled_count = 0 then
            select
                count(*)
            into l_not_enrolled_count
            from
                lookups
            where
                    lookup_name = 'ACCOUNT_TYPE'
                and lookup_code not in ( 'CMP', 'HRA', 'FSA' )
                and lookup_code not in (
                    select
                        b.account_type
                    from
                        enterprise   e, account      b, online_users c
                    where
                            e.entrp_id = b.entrp_id
                        and replace(c.tax_id, '-') = replace(e.entrp_code, '-')
                        and c.tax_id = p_tax_id
                );

            if l_not_enrolled_count > 1 then
                i := i + 1;
                l_table(i) := 'Attention! You now have the ability to enroll in Sterling''s full suite of products directly from your online account. ' || 'Please click <a  href="/Accounts/Portfolio/newEREnroll/" class="here_sty"><strong>here</strong></a>  to see what other products are available'
                ;
            end if;

        end if;

        if p_account_type in ( 'FSA', 'HRA' ) then
            select
                count(*)
            into l_ben_approve_count
            from
                ben_plan_enrollment_setup a,
                account                   c,
                person                    d,
                enterprise                e
            where
                    a.status = 'P'
                and a.acc_id = c.acc_id
                and c.pers_id = d.pers_id
                and a.product_type in ( 'HRA', 'FSA' )
                and a.product_type = p_account_type
                and e.entrp_id = d.entrp_id
                and e.entrp_code = p_tax_id;

            select
                count(*)
            into l_ann_count
            from
                ben_life_event_history a,
                enterprise             e
            where
                    a.status = 'P'
                and a.status = 'Not Processed'
                and e.entrp_id = a.entrp_id
                and e.entrp_code = p_tax_id;

            if nvl(l_ben_approve_count, 0) + nvl(l_ann_count, 0) > 0 then
                i := i + 1;
                l_table(i) := '; Attention! Please click;<a class="here_sty" href="/'
                              || p_account_type
                              || '/Employers/ActivateEmployeesNew" ><b>here</b></a>
				  ;to review and activate employee(s) with newly added Benefit Plans.';
            end if;

        end if;

        for j in 1..l_table.count loop
            l_record.message := l_table(j);
            pipe row ( l_record );
        end loop;

    end alert_box_message;

    function allow_change_plan (
        p_ssn in varchar2
    ) return varchar2 is
        l_change_plan varchar2(1) := 'Y';
    begin
        -- ticket #832
        -- HSA plan change project
        for x in (
            select
                b.plan_code,
                a.maint_fee_paid_by,
                pc_plan.plan_name(b.plan_code) plan_name,
                d.plan_code                    ee_plan_code
            from
                account_preference a,
                account            b,
                person             c,
                account            d
            where
                    a.entrp_id = b.entrp_id
                and c.ssn = format_ssn(p_ssn)
                and c.entrp_id = a.entrp_id
                and c.pers_id = d.pers_id
        ) loop

        -- dont allow to change plan for Veritas-Standard
        -- Added by Joshi for 5363. dont allow plan change for e-HSA plan.
            if x.ee_plan_code = 4
            or x.ee_plan_code = 8 then
                l_change_plan := 'N';
            end if;

        -- if employer pays for the fees
        -- and employer has value plan then aloow to change and alert
            if
                x.maint_fee_paid_by = 2
                and x.plan_code = 2
            then
                l_change_plan := 'Y';
            end if;

            if
                x.maint_fee_paid_by = 2
                and x.plan_code = 1
                and x.plan_code = x.ee_plan_code
            then
                l_change_plan := 'N';
            end if;
        -- if employer pays for the fees
        -- and employer has standard plan then aloow to change and alert
        -- and employee doesnt have standard then allow to change
            if
                x.maint_fee_paid_by = 2
                and x.plan_code in ( 1, 2 )
                and x.ee_plan_code <> 1
            then
                l_change_plan := 'S';
            end if;
        /*
        -- if employer doesnt pay for the fees
        -- employee has Veritas-Standard, Gold,Silver,Platinum
        -- dont allow to change
	      IF x.MAINT_FEE_PAID_BY <> 2
	      AND x.ee_plan_code <> 4 THEN
	          l_change_plan := 'Y';
	       END IF;
        -- if employer doesnt pay for the fees
        -- employee has Veritas-Standard, Gold,Silver,Platinum
        -- dont allow to change
	      IF x.MAINT_FEE_PAID_BY <> 2
	      AND x.ee_plan_code =4 THEN
	          l_change_plan := 'N';
	       END IF;*/
        end loop;

        return l_change_plan;
    end allow_change_plan;

end pc_online;
/


-- sqlcl_snapshot {"hash":"f08e5bbf977a0b585764f5714b3ae7be920b9862","type":"PACKAGE_BODY","name":"PC_ONLINE","schemaName":"SAMQA","sxml":""}