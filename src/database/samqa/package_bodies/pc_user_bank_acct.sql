create or replace package body samqa.pc_user_bank_acct as

    procedure insert_user_bank_acct (
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        x_bank_acct_id     out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        setup_error exception;
        l_acc_id                number;
        l_entity_type           varchar2(100);   -- Added by Swamy for Ticket#10747
        l_broker_id             broker.broker_id%type;
        l_count                 number := 0;
        l_bank_details_exists   varchar2(1);
        l_entity_id             number;
        l_duplicate_bank_exists varchar2(1) := 'N';
        l_account_type          varchar2(100);
    begin
        x_return_status := 'S';
        pc_log.log_error('insert_user_bank_acct', 'bank account type ' || p_bank_acct_type);
        select
            decode(p_acc_num, null, 'Account number cannot be null', '1')
            || decode(p_display_name, null, 'Account Name cannot be null', '1')
            || decode(p_bank_acct_type, null, 'Bank Account Type cannot be null', '1')
            || decode(p_bank_routing_num, null, 'Bank Routing number cannot be null', '1')
            || decode(p_bank_acct_num, null, 'Bank Account number cannot be null', '1')
            || decode(p_bank_name, null, 'Bank Name cannot be null', '1')
        into x_error_message
        from
            dual;

        if nvl(x_error_message, '1') like '1%' then
            x_error_message := null;
        else
            raise setup_error;
        end if;

     -- addded by jaggi #10994
        select
            acc_id,
            broker_id,
            account_type
        into
            l_acc_id,
            l_broker_id,
            l_account_type
        from
            account
        where
            acc_num = p_acc_num;  -- ga_id Added by Swamy for Ticket#12309 

        for k in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if nvl(k.user_type, '*') <> ( 'B' ) then
                l_entity_id := l_acc_id;
                l_entity_type := 'ACCOUNT';
            else
                l_entity_id := l_broker_id;
                l_entity_type := 'BROKER';
            end if;
        end loop;

     -- Added by Swamy Ticket#12058 18/03/2024
        if l_account_type in ( 'HSA', 'FSA', 'HRA', 'LSA', 'COBRA' ) then
            l_duplicate_bank_exists := pc_user_bank_acct.check_duplicate_bank_account(
                p_routing_number    => p_bank_routing_num,
                p_bank_acct_num     => p_bank_acct_num,
                p_bank_acct_id      => null,
                p_bank_name         => p_bank_name,
                p_bank_account_type => p_bank_acct_type,
                p_acc_id            => l_acc_id,
                p_ssn               => null,
                p_user_id           => p_user_id  -- Added by Swamy for Ticket#12309
            );

            if l_duplicate_bank_exists = 'Y' then
                x_error_message := 'The bank details already exist in our system. Please enter different bank details to proceed.';
                raise setup_error;
            end if;
        end if;

        for x in (
            select
                count(*) cnt
            from
                user_bank_acct_v
            where
                    acc_id = l_acc_id
                and bank_routing_num = p_bank_routing_num
                and bank_acct_num = p_bank_acct_num
                and lower(bank_name) = lower(ltrim(rtrim(p_bank_name)))   -- Added by swamy for ticket#11800
                and status = 'A'
        ) loop
            if x.cnt > 1 then
                x_error_message := 'Your account has bank records with same routing number and account number';
                raise setup_error;
            end if;
        end loop;

         -- Added by Joshi for 10573
        l_bank_details_exists := validate_bank_info(
            p_entity_id       => l_entity_id,
            p_entity_type     => l_entity_type,
            p_routing_number  => p_bank_routing_num,
            p_bank_acct_num   => p_bank_acct_num,
            p_bank_name       => p_bank_name,
            p_bank_acct_id    => null,
            p_bank_acct_usage => 'ONLINE'  -- Added by Swamy for Ticket#12309
        );

        if l_bank_details_exists = 'I' then
            x_error_message := 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details'
            ;
            raise setup_error;
        elsif l_bank_details_exists = 'D' then -- Added by jaggi #11015
            x_error_message := 'You already have a Active bank account with the same routing and account numbers setup!';
            raise setup_error;
        end if;

        insert into user_bank_acct (
            bank_acct_id,
            acc_id,
            display_name,
            bank_acct_type,
            bank_routing_num,
            bank_acct_num,
            bank_name,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date
        ) values ( user_bank_acct_seq.nextval,
                   l_acc_id,
                   p_display_name,
                   p_bank_acct_type,
                   lpad(p_bank_routing_num, 9, 0),
                   p_bank_acct_num,
                   p_bank_name,
                   p_user_id,
                   p_user_id,
                   sysdate,
                   sysdate ) returning bank_acct_id into x_bank_acct_id;

       --Added by Joshi for #11276
       -- updating all schedulers with new bank account for HSA
       -- all pending ACH transactions where bank_id is invalid. replace with new bank account.
        for x in (
            select
                account_type
            from
                account
            where
                    acc_id = l_acc_id
                and entrp_id is not null
        ) loop
            if
                x.account_type = 'HSA'
                and x_bank_acct_id is not null
            then
                pc_log.log_error('insert_user_bank_acct', 'l_acc_id: ' || l_acc_id);
                pc_log.log_error('insert_user_bank_acct', 'x_bank_acct_id: ' || x_bank_acct_id);
                for s in (
                    select
                        scheduler_id
                    from
                        scheduler_master
                    where
                            acc_id = l_acc_id
                        and ( ( recurring_flag = 'N'
                                and payment_start_date >= trunc(sysdate)
                                and nvl(status, 'A') in ( 'A', 'P' ) )
                              or ( recurring_flag = 'Y'
                                   and payment_end_date >= trunc(sysdate)
                                   and nvl(status, 'A') = 'A' ) )
                ) loop
                    pc_log.log_error('insert_user_bank_acct', 'scheduler_id: ' || p_bank_acct_type);
                    update scheduler_master
                    set
                        bank_acct_id = x_bank_acct_id,
                        note = nvl(note, ' ')
                               || ' Bank account changed online on '
                               || to_char(sysdate, 'mm/dd/yyyy')
                               || ' by username '
                               || pc_users.get_user_name(p_user_id),
                        last_updated_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            scheduler_id = s.scheduler_id
                        and payment_method = 'ACH'
                        and amount > 0;

                    update ach_transfer
                    set
                        bank_acct_id = x_bank_acct_id,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            scheduler_id = s.scheduler_id
                        and status in ( 1, 2 );

                end loop;

            end if;
        end loop;

       -- Added by Joshi. For QB employee the bank accunt usage should be invoice.
        for x in (
            select
                acc_id
            from
                account a,
                person  p
            where
                    acc_id = l_acc_id
                and a.pers_id = p.pers_id
                and a.account_type = 'COBRA'
                and p.person_type = 'QB'
        ) loop
            if
                x.acc_id is not null
                and x_bank_acct_id is not null
            then
                update bank_accounts
                set
                    bank_account_usage = 'INVOICE'
                where
                        bank_acct_id = x_bank_acct_id
                    and entity_id = x.acc_id
                    and entity_type = 'ACCOUNT';

            end if;
        end loop;
        -- code ends here by Joshi. For QB employee the bank accunt usage should be invoice.

   -- END IF;
    exception
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('insert_user_bank_acct', x_error_message);
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('insert_user_bank_acct', sqlerrm);
    end insert_user_bank_acct;

    procedure update_user_bank_acct (
        p_bank_acct_id      in number,
        p_display_name      in varchar2,
        p_bank_routing_num  in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_user_id           in number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is

        setup_error exception;
   --l_acc_id           NUMBER;
        l_bank_count          number;
        l_acc_id              user_bank_acct.acc_id%type;  -- Added by Swamy for Ticket#7920
        l_entity_id           bank_accounts.entity_id%type;
        l_pers_id             account.pers_id%type;        -- Added by Swamy for Ticket#7920
        l_bank_name           user_bank_acct.bank_name%type;  -- Added by Swamy for Ticket#7920
        l_user_type           online_users.user_type%type;
        l_entity_type         user_bank_acct.entity_type%type;        -- Added by Jaggi for Ticket#8998
        l_display_name        user_bank_acct.display_name%type;       -- Added by Jaggi for Ticket#8998
        l_bank_acct_type      user_bank_acct.bank_acct_type%type;     -- Added by Jaggi for Ticket#8998
        l_bank_routing_num    user_bank_acct.bank_routing_num%type;   -- Added by Jaggi for Ticket#8998
        l_bank_acct_num       user_bank_acct.bank_acct_num%type;      -- Added by Jaggi for Ticket#8998
        l_bank_entity_type    varchar2(100); -- Added by Swamy for Ticket#10747
        l_bank_details_exists varchar2(1);
        l_bank_acct_usage     varchar2(100); -- Added by Swamy for Ticket#12309
    begin
        x_return_status := 'S';
        pc_log.log_error('UPDATE_USER_BANK_ACCT', 'updating ' || p_bank_acct_id);
        pc_log.log_error('insert_user_bank_acct', 'bank account type ' || p_bank_account_type);

    /* SELECT DECODE(p_display_name,NULL,'Account Name cannot be null','1')
      ||DECODE(p_bank_acct_type,NULL,'Bank Account Type cannot be null','1')
      ||DECODE(p_bank_routing_num,NULL,'Bank Routing number cannot be null','1')
      ||DECODE(p_bank_acct_num,NULL,'Bank Account number cannot be null','1')
      ||DECODE(p_bank_name,NULL,'Bank Name cannot be null','1')
      INTO x_error_message
      FROM DUAL;
*/
      /*
      IF x_error_message not like '11%' THEN
         x_error_message := NULL;
      ELSE
         RAISE setup_error;
      END IF;*/

       -- Below FOR Loop Added by Swamy for Ticket#7920(Alert Notification)

        for k in (
            select
                entity_id,
                bank_name,
                entity_type,
                display_name,
                bank_acct_type,
                bank_routing_num,
                bank_acct_num,
                bank_account_usage   -- Added by Swamy for Ticket#12309
            from
                bank_accounts
            where
                bank_acct_id = p_bank_acct_id
        ) loop
            l_entity_id := k.entity_id;
            l_bank_name := k.bank_name;
            l_display_name := k.display_name;
            l_entity_type := k.entity_type;
            l_bank_acct_type := k.bank_acct_type;
            l_bank_routing_num := k.bank_routing_num;
            l_bank_acct_num := k.bank_acct_num;
            l_bank_acct_usage := k.bank_account_usage;  -- Added by Swamy for Ticket#12309
        end loop;

        select
            count(*)
        into l_bank_count
        from
            bank_accounts
        where
                bank_routing_num = p_bank_routing_num
            and bank_acct_num = p_bank_acct_num
            and status = 'A'
            and entity_id = l_entity_id
            and entity_type = l_entity_type
            and bank_acct_id <> p_bank_acct_id;

        if l_bank_count = 1 then
            x_error_message := 'Your account already has bank name with same routing number and account number';
            raise setup_error;
        end if;

      /*UPDATE user_bank_acct   -- existing code
       SET  display_name = NVL(p_display_name,display_name)
           ,bank_routing_num = NVL(lpad(p_bank_routing_num,9,0),bank_routing_num)
           ,bank_acct_num = NVL(p_bank_acct_num,bank_acct_num)
           ,bank_name = NVL(p_bank_name,bank_name)
           ,bank_acct_type = NVL(p_bank_account_type,bank_acct_type)
           ,last_updated_by = p_user_id
           ,last_update_date = SYSDATE
      WHERE  bank_acct_id = p_bank_acct_id;
      */

     -- Added by Joshi for 10573
        l_bank_details_exists := validate_bank_info(
            p_entity_id       => l_entity_id,
            p_entity_type     => l_entity_type,
            p_routing_number  => p_bank_routing_num,
            p_bank_acct_num   => p_bank_acct_num,
            p_bank_name       => p_bank_name,
            p_bank_acct_id    => p_bank_acct_id,
            p_bank_acct_usage => l_bank_acct_usage  -- Added by Swamy for Ticket#12309
        );

        if l_bank_details_exists = 'I' then
            x_error_message := 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details'
            ;
            raise setup_error;
        elsif l_bank_details_exists = 'D' then -- Added by jaggi #11015
            x_error_message := 'You already have a Active bank account with the same routing and account numbers setup!';
            raise setup_error;
        end if;

   --added by Jaggi for Ticket ##8998
        if lower(p_bank_name) <> lower(l_bank_name)
        or lower(p_display_name) <> lower(l_display_name)
        or p_bank_account_type <> l_bank_acct_type
        or p_bank_routing_num <> l_bank_routing_num
        or p_bank_acct_num <> l_bank_acct_num then
      -- Start Added by Swamy for Ticket#7920(Alert Notification)
            update bank_accounts
            set
                status = 'I',
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                bank_acct_id = p_bank_acct_id;

            pc_log.log_error('insert_user_bank_acct', 'l_bank_entity_type ' || l_bank_entity_type);
            insert into bank_accounts (
                bank_acct_id,
                entity_id,
                display_name,
                bank_acct_type,
                bank_routing_num,
                bank_acct_num,
                bank_name,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                entity_type   -- Added by Swamy for Ticket#10747
            ) values ( user_bank_acct_seq.nextval,
                       l_entity_id,
                       p_display_name,
                       p_bank_account_type,
                       lpad(p_bank_routing_num, 9, 0),
                       p_bank_acct_num,
                       p_bank_name,
                       p_user_id,
                       p_user_id,
                       sysdate,
                       sysdate,
                       l_entity_type --l_bank_entity_type   -- Added by Swamy for Ticket#10747
                        );

        end if;

     -- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
     -- Only for Subscriber and bank_account_usage = 'ONLINE' the notification should be triggered.
     -- The default of bank_account_usage is 'ONLINE', so did not use this condition in the below IF statement.

        if nvl(l_user_type, 'N') = 'S' then
            for j in (
                select
                    pers_id
                from
                    account
                where
                    acc_id = l_acc_id
            ) loop
                l_pers_id := j.pers_id;
            end loop;

            pc_log.log_error('pc_user_bank_account pers_id :=', l_pers_id
                                                                || 'acc_id := '
                                                                || l_acc_id);
            pc_notification2.insert_events(
                p_acc_id      => l_acc_id,
                p_pers_id     => l_pers_id,
                p_event_name  => 'BANK_ACCOUNT',
                p_entity_type => 'USER_BANK_ACCT',
                p_entity_id   => l_acc_id,
                p_ssn         => null
            );

        end if;
        -- end of Addition by Swamy

    exception
        when setup_error then
            x_return_status := 'E';
        --x_error_message := 'Error updating '||p_bank_name||' '||x_error_message;
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end update_user_bank_acct;

    procedure delete_user_bank_acct (
        p_acc_num       in varchar2,
        p_bank_acct_id  in varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_bank_count number;
        setup_error exception;
    begin
        x_return_status := 'S';
        for i in 1..p_bank_acct_id.count loop
        /* commented by Joshi for #11276.
          SELECT COUNT(*)
          INTO   l_bank_count
          FROM   ach_transfer_v
          WHERE  bank_acct_id = p_bank_acct_id(i)
           AND   acc_num = p_acc_num
           AND   status  IN (1,2);
           IF l_bank_count > 0 THEN
             x_error_message := 'Cannot delete bank account as there are pending transactions associated with this account.';
             RAISE setup_error;
           END IF;
           */

            update user_bank_acct
            set
                status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                inactive_reason = 'DELETED_BY_CUSTOMER',
                inactive_date = sysdate
            where
                bank_acct_id = p_bank_acct_id(i);

         -- Added by Joshi for #11276. canel pending transactions/update payment method in invoice setting to ACH_PUSH for bank account associated
         -- update payment method in invoices (generated and processed status) to ACH_PUSH for bank account associated.
          -- Added by Joshi for #11276. canel pending transactions/update payment method in invoice setting to ACH_PUSH for bank account associated
         -- update payment method in invoices (generated and processed status) to ACH_PUSH for bank account associated.
            for x in (
                select
                    a.account_type
                from
                    user_bank_acct u,
                    account        a
                where
                        u.acc_id = a.acc_id
                    and bank_acct_id = p_bank_acct_id(i)
            ) loop
                if x.account_type <> 'HSA' then
                    pc_claim.cancel_invalid_bank_txns(
                        p_bank_acct_id(i),
                        null,
                        p_user_id
                    );
                end if;
            end loop;

        end loop;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := 'Error in deleting bank account, Contact customer service ';
            pc_log.log_error('DELETE_USER_BANK_ACCT', sqlerrm);
    end delete_user_bank_acct;

    function get_active_bank_acct (
        p_acc_id      in number,
        p_account_num in varchar2,
        p_routing_num in varchar2,
        p_bank_name   in varchar2
    ) return number is
        l_bank_acct_id number;
    begin
        for x in (
            select
                bank_acct_id
            from
                user_bank_acct
            where
                    acc_id = p_acc_id
                and status = 'A'
                and bank_name = nvl(p_bank_name, bank_name)
                and bank_acct_num = nvl(bank_acct_num, p_account_num)
                and ( p_account_num is null
                      or ltrim(bank_acct_num, '0') = ltrim(p_account_num, '0') )
                and ( p_routing_num is null
                      or ltrim(bank_routing_num, '0') = ltrim(p_routing_num, '0') )
        ) loop
            l_bank_acct_id := x.bank_acct_id;
        end loop;

        return l_bank_acct_id;
    end get_active_bank_acct;

    function get_user_bank_acct_from_acc_id (
        p_acc_id in number
    ) return number is
        l_bank_acct_id number;
    begin
        for x in (
            select
                bank_acct_id
            from
                user_bank_acct
            where
                    acc_id = p_acc_id
                and rownum = 1
        ) loop
            l_bank_acct_id := x.bank_acct_id;
        end loop;

        return l_bank_acct_id;
    end get_user_bank_acct_from_acc_id;

    function get_user_bank_acct_from_bank (
        p_acc_id      in number,
        p_account_num in varchar2,
        p_routing_num in varchar2,
        p_bank_name   in varchar2
    ) return number is
        l_bank_acct_id number;
    begin
        for x in (
            select
                bank_acct_id
            from
                user_bank_acct
            where
                    bank_name = nvl(p_bank_name, bank_name)
                and ltrim(bank_acct_num, '0') = ltrim(p_account_num, '0')
                and ltrim(bank_routing_num, '0') = ltrim(p_routing_num, '0')
                and acc_id = p_acc_id
                and status = 'A'
                and rownum = 1
        ) loop
            l_bank_acct_id := x.bank_acct_id;
        end loop;

        return l_bank_acct_id;
    end get_user_bank_acct_from_bank;

    function get_bank_name (
        p_bank_acc_id in number
    ) return varchar2 is
        l_bank_name varchar2(3200);
    begin
        for x in (
            select
                bank_name
                || '('
                || bank_acct_num
                || ')' bank_name
            from
                user_bank_acct
            where
                bank_acct_id = p_bank_acc_id
        ) loop
            l_bank_name := x.bank_name;
        end loop;

        return l_bank_name;
    end get_bank_name;

    function get_bank_acct_status (
        p_bank_acct_id in number
    ) return varchar2 is
        l_status varchar2(30);
    begin
        for x in (
            select
                status
            from
                user_bank_acct
            where
                bank_acct_id = p_bank_acct_id
        ) loop
            l_status := x.status;
        end loop;

        return l_status;
    end get_bank_acct_status;

    procedure upload_bank_acct (
        p_file_name in varchar2,
        p_user_id   in number
    ) is

        l_file       utl_file.file_type;
        l_buffer     raw(32767);
        l_amount     binary_integer := 32767;
        l_pos        integer := 1;
        l_blob       blob;
        l_blob_len   integer;
        exc_no_file exception;
        l_create_ddl varchar2(32000);
        lv_dest_file varchar2(300);
    begin
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = p_file_name;

            l_file := utl_file.fopen('ONLINE_ENROLL_DIR', lv_dest_file, 'w', 32767);
            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
            -- Open / Creates the destination file.

             -- Read chunks of the BLOB and write them to the file
            -- until complete.
            while l_pos < l_blob_len loop
                dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
                utl_file.put_raw(l_file, l_buffer, true);
                l_pos := l_pos + l_amount;
            end loop;

            -- Close the file.
            utl_file.fclose(l_file);

            -- Delete file from wwv_flow_files
            delete from wwv_flow_files
            where
                name = p_file_name;

        exception
            when others then
                null;
        end;

        if file_length(lv_dest_file, 'ONLINE_ENROLL_DIR') > 0 then
            begin
                dbms_output.put_line('In Loop');
                execute immediate '
                           ALTER TABLE BANK_ACCT_EXT
                            location (ONLINE_ENROLL_DIR:'''
                                  || lv_dest_file
                                  || ''')';
                dbms_output.put_line('After alter');
            end;

        end if;

        insert into user_bank_acct (
            bank_acct_id,
            acc_id,
            display_name,
            bank_acct_type,
            bank_routing_num,
            bank_acct_num,
            bank_name,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date,
            status,
            bank_account_usage,
            note
        )
            select
                user_bank_acct_seq.nextval,
                acc_id,
                bank_name,
                nvl(bank_acct_type, 'C'),
                bank_routing_num,
                bank_acct_num,
                bank_name,
                p_user_id,
                p_user_id,
                sysdate,
                sysdate,
                'A',
                'IN_OFFICE',
                'Uploaded from file '
            from
                bank_acct_ext a,
                account       b,
                person        c
            where
                    format_ssn(a.ssn) = c.ssn
                and b.pers_id = c.pers_id
                and b.account_type = a.account_type
                and a.bank_routing_num is not null
                and not exists (
                    select
                        *
                    from
                        user_bank_acct
                    where
                            user_bank_acct.acc_id = b.acc_id
                        and user_bank_acct.bank_routing_num = a.bank_routing_num
                        and user_bank_acct.bank_acct_num = a.bank_acct_num
                );

    exception
        when others then
            rollback;

-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

-- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = p_file_name;

            raise_application_error('-20001', 'Error in Exporting dependant File ' || sqlerrm);
    end upload_bank_acct;

    function get_bank_details (
        p_acc_num in varchar2
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
            bank_account_usage,        -- Added by Jaggi #11263
            giac_verify,              -- P Added by Swamy for Ticket#12309
            giac_response,            -- Added by Swamy for Ticket#12534
            giac_authenticate,         -- Added by Swamy for Ticket#12534
            status,
            decode(bank_acct_type, 'S', 'Saving', 'Checking') bank_acct_type_description
        from
            user_bank_acct_v
        where
            status in ( 'A', 'P', 'W' )    -- P Added by Swamy for Ticket#12309
            and acc_num = p_acc_num
        order by
            bank_acct_id desc;

    begin
        x_error_status := 'E';
        for c1 in cur_bank_det loop
            l_record.bank_acc_id := c1.bank_acct_id;
            l_record.acc_id := c1.acc_id;
            l_record.acc_num := c1.acc_num;
            l_record.display_name := c1.display_name;
            l_record.bank_account_usage := c1.bank_account_usage;  -- Added by Jaggi #11263
            l_record.bank_acct_type := c1.bank_acct_type;
            l_record.account_type := c1.account_type;
            l_record.bank_acct_num := c1.bank_acct_num;
            l_record.bank_routing_num := c1.bank_routing_num;
            l_record.giac_verify := c1.giac_verify;       -- Added by Swamy for Ticket#12309
            l_record.giac_response := c1.giac_response;       -- Added by Swamy for Ticket#12534
            l_record.giac_authenticate := c1.giac_authenticate;   -- Added by Swamy for Ticket#12534
            l_record.status := c1.status;              -- Added by Swamy for Ticket#12534
            l_record.status_description := pc_lookups.get_meaning(c1.status, 'STATUS');   -- Added by Swamy for Ticket#12534
            l_record.bank_acct_type_description := c1.bank_acct_type_description;
            x_error_status := 'S';
            pipe row ( l_record );
        end loop;

        if x_error_status = 'E' then
            l_record.bank_acc_id := null;
            l_record.error_message := 'You do not have a bank account on record.You must add a bank account by logging into sterlinghsa.com '
            ;
            pipe row ( l_record );
        end if;

    end get_bank_details;

    procedure upsert_bank_acct (
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        p_account_type     in varchar2,
        x_bank_acct_id     in out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        l_bank_acct_id  number;
        l_error_status  varchar2(10);
        l_error_message varchar2(1000);
        l_entity_type   varchar2(100);           -- Added by Swamy for Ticket#10747
        l_broker_id     broker.broker_id%type;   -- Added by Swamy for Ticket#10747
        setup_error exception;               -- Added by Swamy for Ticket#10747
    begin
        pc_log.log_error('upsert_bank_acct', 'p_acc_num '
                                             || p_acc_num
                                             || 'p_user_id :='
                                             || p_user_id);
    -- Start Added by swmay for ticket#10747
        pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);
        pc_log.log_error('upsert_bank_acct', 'l_entity_type '
                                             || l_entity_type
                                             || 'p_user_id :='
                                             || p_user_id);
        if
            nvl(l_entity_type, '*') = 'BROKER'
            and p_acc_num is not null
        then
            for x in (
                select
                    count(*) cnt
                from
                    user_bank_acct_broker_v
                where
                        bank_routing_num = p_bank_routing_num
                    and bank_acct_num = p_bank_acct_num
                    and bank_name = p_bank_name
                    and status = 'A'
                    and entity_id = l_broker_id
                    and bank_account_usage = 'INVOICE'
            ) loop
                if nvl(x.cnt, 0) = 0 then
                    pc_user_bank_acct.insert_bank_account(
                        p_entity_id          => l_broker_id,
                        p_entity_type        => l_entity_type,
                        p_display_name       => p_display_name,
                        p_bank_acct_type     => p_bank_acct_type,
                        p_bank_routing_num   => p_bank_routing_num,
                        p_bank_acct_num      => p_bank_acct_num,
                        p_bank_name          => p_bank_name,
                        p_bank_account_usage => 'INVOICE',
                        p_user_id            => p_user_id,
                        x_bank_acct_id       => x_bank_acct_id,
                        x_return_status      => x_return_status,
                        x_error_message      => x_error_message
                    );

                    if nvl(x_return_status, '*') <> 'S' then
                        raise setup_error;
                    end if;
                else
                        -- Added by Jaggi #11317
                    for j in (
                        select
                            bank_acct_id
                        from
                            bank_accounts
                        where
                                entity_id = l_broker_id
                            and entity_type = l_entity_type
                            and bank_routing_num = p_bank_routing_num
                            and bank_acct_num = p_bank_acct_num
                            and bank_name = p_bank_name
                            and status = 'A'
                    ) loop
                        x_bank_acct_id := j.bank_acct_id;
                    end loop;
                end if;
            end loop;
        else
     -- End of Addition by swmay for Ticket#10747
            for x in (
                select
                    count(*) cnt
                from
                    user_bank_acct_v
                where
                        acc_num = p_acc_num
                    and account_type = p_account_type
                    and status = 'A'
            ) loop
                if x.cnt = 0 then
                    pc_log.log_error('upsert_bank_acct', 'Enter into new bank insert section');
                    pc_user_bank_acct.insert_user_bank_acct(p_acc_num, p_display_name, p_bank_acct_type, p_bank_routing_num, p_bank_acct_num
                    ,
                                                            p_bank_name, p_user_id, x_bank_acct_id    --l_bank_acct_id Commented and Added by Swamy for Ticket#11233(11119)
                                                            , l_error_status, l_error_message);

                else
                    pc_log.log_error('upsert_bank_acct', 'Enter into update bank insert section');
                    pc_log.log_error('upsert_bank_acct', 'Enter into update bank insert section x_bank_acct_id' || x_bank_acct_id);
                    for y in (
                        select
                            bank_acct_id
                        from
                            user_bank_acct_v
                        where
                                acc_num = p_acc_num
                            and account_type = p_account_type
                            and status = 'A'
                    ) loop
                        l_bank_acct_id := y.bank_acct_id;
                        x_bank_acct_id := l_bank_acct_id;   -- Added by Swamy for Ticket#11233(11119)

                    end loop;

                --  PC_USER_BANK_ACCT.update_user_bank_acct(x_bank_acct_id -- Joshi 10431
                    pc_user_bank_acct.update_user_bank_acct(l_bank_acct_id, p_display_name, p_bank_routing_num, p_bank_acct_num, p_bank_name
                    ,
                                                            p_bank_acct_type, p_user_id, l_error_status, l_error_message);

                -- Added by Jaggi #11119
                    for j in (
                        select
                            bank_acct_id
                        from
                            user_bank_acct_v
                        where
                                acc_num = p_acc_num
                            and account_type = p_account_type
                            and bank_routing_num = p_bank_routing_num
                            and bank_acct_num = p_bank_acct_num
                            and bank_name = p_bank_name
                            and status = 'A'
                    ) loop
                        x_bank_acct_id := j.bank_acct_id;
                    end loop;

                end if;
            end loop;
        end if;

    end upsert_bank_acct;

-- Added by Joshi for 6322
-- This function is used for getting bank details/rate plan association for employer. called from website
    function get_fhra_bank_details (
        p_entity_id    in number,
        p_entity_type  in varchar2,
        p_invoice_type in varchar2 default null
    ) return fhra_bank_record_t
        pipelined
        deterministic
    is
        l_record       fhra_bank_record_row_t;
        l_account_type varchar2(100);
    begin
        pc_log.log_error('pc_user_bank_Acct.get_fhra_Bank_Details', 'P_ENTITY_TYPE: '
                                                                    || p_entity_type
                                                                    || ' P_entity_id :='
                                                                    || p_entity_id
                                                                    || 'P_INVOICE_TYPE :='
                                                                    || p_invoice_type);

-- Added by Joshi for 9412
        if p_entity_type = 'ACCOUNT' then

 -- Added by Joshi for 9515
            select
                account_type
            into l_account_type
            from
                account
            where
                acc_id = p_entity_id;

            if l_account_type in ( 'FSA', 'HRA' ) then
                for c1 in (
                    select
                        u.display_name,
                        u.bank_routing_num,
                        u.bank_acct_num,
                        u.bank_acct_type,
                        pc_lookups.get_meaning(u.bank_acct_type, 'BANK_ACCOUNT_TYPE') bank_acct_type_name,
                        i.invoice_type,
                        i.division_code,
                        e.division_name,
                        i.invoice_param_id,
                        nvl(i.product_type, a.account_type)                           account_type,
                        u.bank_acct_id,
                        a.acc_id,
                        a.acc_num,
                        u.bank_account_usage,
                        u.status,          -- Added by Swamy for Ticket#12309
                        u.giac_verify,    -- Added by Swamy for Ticket#12309
                        u.business_name -- Added by Joshi for Ticket#12309
                    from
                        user_bank_acct     u,
                        invoice_parameters i,
                        account            a,
                        employer_divisions e
                    where
                            a.acc_id = u.acc_id
                        and u.bank_acct_id = i.bank_acct_id (+)
                        and a.entrp_id = i.entity_id (+)
                        and i.entity_type (+) = 'EMPLOYER'
                        and ( p_invoice_type is null
                              or ( p_invoice_type is not null
                                   and invoice_type = p_invoice_type ) )
                        and u.status in ( 'A', 'P', 'W' )   -- P,W Added by Swamy for Ticket#12309 
                        and i.entity_id = e.entrp_id (+)
                        and i.division_code = e.division_code (+)
                        and a.acc_id = p_entity_id
                    order by
                        i.division_code,
                        i.invoice_type
                ) loop
                    l_record.bank_acc_id := c1.bank_acct_id;
                    l_record.acc_id := c1.acc_id;
                    l_record.acc_num := c1.acc_num;
                    l_record.display_name := c1.display_name;
                    l_record.bank_acct_type := c1.bank_acct_type;
                    l_record.bank_acct_type_name := c1.bank_acct_type_name;
                    l_record.account_type := c1.account_type;
                    l_record.bank_acct_num := c1.bank_acct_num;
                    l_record.bank_routing_num := c1.bank_routing_num;
--        l_record.bank_Account_usage     := NVL(c1.INVOICE_TYPE, C1.bank_Account_usage) ;
                    l_record.bank_account_usage := c1.bank_account_usage; -- added by Jaggi #11617
                    l_record.division_code := c1.division_code;
                    l_record.division_name := c1.division_name;
                    l_record.invoice_param_id := c1.invoice_param_id;
                    l_record.bank_status := c1.status;          -- Added by Swamy for Ticket#12309
                    l_record.status_description := pc_lookups.get_meaning(c1.status, 'STATUS');   -- Added by Swamy for Ticket#12309
                    l_record.giac_verify := c1.giac_verify;     -- Added by Swamy for Ticket#12309
                    l_record.business_name := c1.business_name;     -- Added by Joshi for Ticket#12534
                    pipe row ( l_record );
                end loop;

            else
                for ba in (
                    select
                        *
                    from
                        bank_accounts
                    where
                            entity_id = p_entity_id
                        and entity_type = p_entity_type
                        and status in ( 'A', 'P', 'W' )   -- P,W Added by Swamy for Ticket#12309 
                        and bank_account_usage in ( 'ONLINE', 'INVOICE', 'COBRA_DISBURSE' )
                ) loop
                    l_record.bank_acc_id := ba.bank_acct_id;
                    l_record.acc_id := ba.entity_id;
                    l_record.acc_num := null;
                    l_record.display_name := ba.display_name;
                    l_record.bank_acct_type := ba.bank_acct_type;
                    l_record.bank_acct_type_name := null;
                    l_record.account_type := ba.entity_type;
                    l_record.bank_acct_num := ba.bank_acct_num;
                    l_record.bank_routing_num := ba.bank_routing_num;
                    l_record.bank_account_usage := ba.bank_account_usage;
                    l_record.bank_account_usage_display := pc_lookups.get_meaning(ba.bank_account_usage, 'BANK_ACCOUNT_USAGE');
                    l_record.division_code := null;
                    l_record.division_name := null;
                    l_record.invoice_param_id := null;
                    l_record.bank_status := ba.status;          -- Added by Swamy for Ticket#12309
                    l_record.status_description := pc_lookups.get_meaning(ba.status, 'STATUS');   -- Added by Swamy for Ticket#12309
                    l_record.giac_verify := ba.giac_verify;   -- Added by Swamy for Ticket#12309
                    l_record.business_name := ba.business_name;     --Added by Joshi for Ticket#12534
                    pipe row ( l_record );
                end loop;
            end if;

        else
   -- Added by Joshi for 9412
            for ba in (
                select
                    *
                from
                    bank_accounts
                where
                        entity_id = p_entity_id
                    and entity_type = p_entity_type
                    and status in ( 'A', 'P', 'W' )   -- P,W Added by Swamy for Ticket#12309 
            ) loop
                l_record.bank_acc_id := ba.bank_acct_id;
                l_record.acc_id := null;
                l_record.acc_num := null;
                l_record.display_name := ba.display_name;
                l_record.bank_acct_type := ba.bank_acct_type;
                l_record.bank_acct_type_name := null;
                l_record.account_type := ba.entity_type;
                l_record.bank_acct_num := ba.bank_acct_num;
                l_record.bank_routing_num := ba.bank_routing_num;
                l_record.bank_account_usage := ba.bank_account_usage; -- added by Jaggi #11617
                l_record.division_code := null;
                l_record.division_name := null;
                l_record.invoice_param_id := null;
                l_record.bank_status := ba.status;          -- Added by Swamy for Ticket#12309
                l_record.status_description := pc_lookups.get_meaning(ba.status, 'STATUS');   -- Added by Swamy for Ticket#12309
                l_record.giac_verify := ba.giac_verify;   -- Added by Swamy for Ticket#12309
                l_record.business_name := ba.business_name;     -- Added by Joshi for Ticket#12534
                pipe row ( l_record );
            end loop;
        end if;

    end get_fhra_bank_details;

-- This function is used for inserting/updateing bank details for employer and also updates bank details in
-- invoice settings.
    procedure fhra_upsert_bank_acct (
        p_entrp_id         in number,
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        p_account_type     in varchar2,
        p_account_usage    in varchar2,
        p_division_code    in varchar2,
        p_edit_flag        in varchar2,
        p_entity_id        in number    -- Added by Joshi for 9412
        ,
        p_entity_type      in varchar2  -- Added by Joshi for 9412
        ,
        x_bank_acct_id     in number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        l_bank_acct_id          number;
        l_error_status          varchar2(10);
        l_error_message         varchar2(1000);
        l_account_usage         varchar2(100);
        setup_error exception;
        l_bank_exist            number;
        l_account_type          varchar2(100);
        l_bank_details_exists   varchar2(1);
        l_inv_bank_acct_id      number;
        l_cnt                   number := 0;
        l_cnt_usage             number := 0;
        l_duplicate_bank_exists varchar2(1);
    begin
        x_return_status := 'S';
        pc_log.log_error('FHRA_upsert_bank_acct', 'Enter into procedure');

 -- Added by Joshi for 9515
        if p_account_usage in ( 'FEE', 'ONLINE' ) then --'CLAIM','FUNDING' Removed by Jaggi #11276  bank account usage should be stored as ¿CLAIM¿ and ¿FUNDING¿.
            l_account_usage := 'INVOICE';--'ONLINE' ; -- Added By Jaggi #11501 on  04/24/2023
        elsif p_account_usage in ( 'CLAIM' ) then
            l_account_usage := 'CLAIMS';
        else
            l_account_usage := p_account_usage;
        end if;
       -- Added by Joshi for 9515
        for x in (
            select
                account_type
            from
                account
            where
                acc_id = p_entity_id
        ) loop
            l_account_type := x.account_type;
        end loop;

              -- Added by Swamy for Ticket#12259 08072024 
        l_duplicate_bank_exists := pc_user_bank_acct.check_duplicate_bank_account(
            p_routing_number    => p_bank_routing_num,
            p_bank_acct_num     => p_bank_acct_num,
            p_bank_acct_id      => null,
            p_bank_name         => p_bank_name,
            p_bank_account_type => p_bank_acct_type,
            p_acc_id            => p_entity_id,
            p_ssn               => null,
            p_user_id           => p_user_id  -- Added by Swamy for Ticket#12309
        );

        if l_duplicate_bank_exists = 'Y' then
            x_error_message := 'The bank details already exist in our system. Please enter different bank details to proceed.';
            raise setup_error;
        end if;     

       -- Added by Joshi for 10573
        l_bank_details_exists := pc_user_bank_acct.validate_bank_info(
            p_entity_id       => p_entity_id,
            p_entity_type     => p_entity_type,
            p_routing_number  => p_bank_routing_num,
            p_bank_acct_num   => p_bank_acct_num,
            p_bank_name       => p_bank_name,
            p_bank_acct_id    => x_bank_acct_id,
            p_bank_acct_usage => l_account_usage  -- Added by Swamy for Ticket#12309
        );

        if l_bank_details_exists = 'I' then
            x_error_message := 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details'
            ;
            raise setup_error;
        elsif
            nvl(l_account_type, '*') not in ( 'FSA', 'HRA', 'COBRA' )
            and l_bank_details_exists = 'D'
        then -- Added by jaggi #11015
            x_error_message := 'You already have a Active bank account with the same routing and account numbers setup!';
            raise setup_error;
        end if;

        if p_entity_type = 'ACCOUNT' then
            if p_edit_flag = 'N' then
                if l_account_type in ( 'FSA', 'HRA', 'COBRA' ) then

           /*SELECT COUNT(*) INTO L_BANK_EXIST
             FROM INVOICE_PARAMETERS
            WHERE ENTITY_TYPE = 'EMPLOYER'
              AND ENTITY_ID = P_ENTRP_ID
              AND PAYMENT_METHOD = 'DIRECT_DEPOSIT'
              AND AUTOPAY = 'Y'
              AND BANK_ACCT_ID IS NOT NULL
              AND INVOICE_TYPE = P_ACCOUNT_USAGE
              AND ( P_DIVISION_CODE is null or ( P_DIVISION_CODE is not null and DIVISION_CODE = P_DIVISION_CODE))
              AND ( P_ACCOUNT_TYPE is null or  ( P_ACCOUNT_TYPE is not null and PRODUCT_TYPE  = P_ACCOUNT_TYPE))
              AND STATUS = 'A' ;

              pc_log.log_error('FHRA_upsert_bank_acct', 'P_ACCOUNT_TYPE: ' || P_ACCOUNT_TYPE);
              pc_log.log_error('FHRA_upsert_bank_acct', 'L_BANK_EXIST: ' ||  L_BANK_EXIST);
              pc_log.log_error('FHRA_upsert_bank_acct','Enter into procedure');

              IF L_BANK_EXIST >  0 THEN
                x_return_status := 'E';
                x_error_message := 'One account usage option cannot be selected for multiple bank accounts.';
                RAISE setup_error ;
              END IF ;
			  */

			        -- Added by Jaggi #11640 
				/*FOR X IN ( SELECT COUNT(*) Cnt 
							 FROM invoice_parameters
							WHERE entity_type = 'EMPLOYER'
							  AND entity_id = p_entrp_id
							  AND payment_method = 'DIRECT_DEPOSIT'
							  AND autopay = 'Y'
							  AND bank_acct_id IS NOT NULL
							  AND invoice_type = p_account_usage
							  AND (p_division_code IS NULL OR ( p_division_code IS NOT NULL AND division_code = p_division_code))
							  AND (p_account_type IS NULL OR  ( p_account_type IS NOT NULL AND product_type  = p_account_type))
							  AND status = 'A' )
				LOOP
					l_cnt := x.cnt;
				END LOOP;*/  -- Commented by Swamy for Ticket#11874 on 16/11/2023

		         -- Added by Swamy, for same account usage multiple banks should NOT be added.
                    for x in (
                        select
                            count(*) cnt_usage
                        from
                            user_bank_acct_v
                        where
                                acc_num = p_acc_num
                            and bank_account_usage = upper(decode(p_account_usage, 'FEE', 'INVOICE', 'CLAIM', 'CLAIMS',
                                                                  p_account_usage))
                            and account_type = l_account_type
                            and status = 'A'
                    ) loop
                        l_cnt_usage := x.cnt_usage;
                    end loop;

                    pc_log.log_error('FHRA_upsert_bank_acct', 'P_ACCOUNT_TYPE: '
                                                              || p_account_type
                                                              || ' L_ACCOUNT_TYPE :='
                                                              || l_account_type
                                                              || 'p_account_usage :='
                                                              || p_account_usage
                                                              || 'p_acc_num :='
                                                              || p_acc_num);

                    pc_log.log_error('FHRA_upsert_bank_acct', 'l_cnt: '
                                                              || l_cnt
                                                              || ' l_cnt_usage :='
                                                              || l_cnt_usage);
                    pc_log.log_error('FHRA_upsert_bank_acct', 'Enter into procedure');

					--IF l_cnt > 0 OR l_cnt_usage > 0 THEN  -- Added by Jaggi #11640 
                    if nvl(l_cnt_usage, 0) > 0 then  -- Commented above and Added by Swamy for Ticket#11874 on 16/11/2023
                        x_return_status := 'E';
                        x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.'
                        ;
                        raise setup_error;
                    end if;

                end if;

                pc_log.log_error('FHRA_upsert_bank_acct', 'Entered into New bank block');
                for x in (
                    select distinct
                        bank_acct_id
                    from
                        user_bank_acct_v
                    where
                            acc_num = p_acc_num
                        and bank_routing_num = p_bank_routing_num
                        and bank_acct_num = p_bank_acct_num
                        and lower(bank_name) = lower(ltrim(rtrim(p_bank_name)))   -- Added by swamy for ticket#11800
                        and bank_account_usage = p_account_usage  -- Added by Jaggi #11109
                        and status = 'A'
                        and rownum = 1
                ) loop
                    pc_log.log_error('FHRA_upsert_bank_acct', 'before calling insert_user_bank_acct');
                    l_bank_acct_id := x.bank_acct_id;
                end loop;

                if l_bank_acct_id is null then
                    pc_log.log_error('FHRA_upsert_bank_acct', 'Enter into loop');
                    /* commented for 9515
                     PC_USER_BANK_ACCT.insert_user_bank_acct
                        (
                           p_acc_num
                          ,p_display_name
                          ,p_bank_acct_type
                          ,p_bank_routing_num
                          ,p_bank_acct_num
                          ,p_bank_name
                          ,p_user_id
                          ,l_bank_acct_id
                          ,l_error_status
                          ,l_error_message
                       ); */

                    insert_bank_account(
                        p_entity_id          => p_entity_id,
                        p_entity_type        => p_entity_type,
                        p_display_name       => p_display_name,
                        p_bank_acct_type     => p_bank_acct_type,
                        p_bank_routing_num   => lpad(p_bank_routing_num, 9, 0),
                        p_bank_acct_num      => p_bank_acct_num,
                        p_bank_name          => p_bank_name,
                        p_bank_account_usage => l_account_usage,
                        p_user_id            => p_user_id,
                        x_bank_acct_id       => l_bank_acct_id,
                        x_return_status      => l_error_status,
                        x_error_message      => l_error_message
                    );

                    if l_error_status = 'E' then
                        raise setup_error;
                    end if;
                end if;
              --update invoice setting.
                pc_log.log_error('FHRA_upsert_bank_acct', 'update rate plan before loop');
                if
                    p_account_usage is not null
                    and l_account_type in ( 'FSA', 'HRA' )
                then
                    update invoice_parameters
                    set
                        payment_method = 'DIRECT_DEPOSIT',
                        autopay = 'Y',
                        bank_acct_id = l_bank_acct_id,
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                            entity_type = 'EMPLOYER'
                        and entity_id = p_entrp_id
                        and invoice_type = p_account_usage
                        and ( p_division_code is null
                              or ( p_division_code is not null
                                   and division_code = p_division_code ) )
                        and ( p_account_type is null
                              or ( p_account_type is not null
                                   and product_type = p_account_type ) )
                        and status = 'A';

                end if;

            else
            -- update Bank account.
                if p_edit_flag = 'E' then
                    update user_bank_acct
                    set
                        display_name = nvl(p_display_name, display_name),
                        bank_routing_num = nvl(
                            lpad(p_bank_routing_num, 9, 0),
                            bank_routing_num
                        ),
                        bank_acct_num = nvl(p_bank_acct_num, bank_acct_num),
                        bank_name = nvl(p_bank_name, bank_name),
                        bank_acct_type = nvl(p_bank_acct_type, bank_acct_type),
                        last_updated_by = p_user_id,
                        last_update_date = sysdate
                    where
                        bank_acct_id = x_bank_acct_id;

                end if;
            end if;
        else
        -- Added by Joshi for 9412.
            if p_edit_flag = 'N' then

           /* commented as multiple bank accounts should be allowed to BROKER.
           SELECT COUNT(*) INTO L_BANK_EXIST
             FROM BANK_ACCOUNTS
            WHERE ENTITY_TYPE = p_entity_type
              AND ENTITY_ID  = p_entity_id
              AND STATUS = 'A';

           IF L_BANK_EXIST >  0 THEN
                    x_return_status := 'E';
                    x_error_message := 'One account usage option cannot be selected for multiple bank accounts.';
                    RAISE setup_error ;
           END IF ;
            */
                insert_bank_account(
                    p_entity_id          => p_entity_id,
                    p_entity_type        => p_entity_type,
                    p_display_name       => p_display_name,
                    p_bank_acct_type     => p_bank_acct_type,
                    p_bank_routing_num   => lpad(p_bank_routing_num, 9, 0),
                    p_bank_acct_num      => p_bank_acct_num,
                    p_bank_name          => p_bank_name,
                    p_bank_account_usage => l_account_usage   --  p_account_usage (9490) JOshi
                    ,
                    p_user_id            => p_user_id,
                    x_bank_acct_id       => l_bank_acct_id,
                    x_return_status      => l_error_status,
                    x_error_message      => l_error_message
                );

            else
                update bank_accounts
                set
                    display_name = nvl(p_display_name, display_name),
                    bank_routing_num = nvl(
                        lpad(p_bank_routing_num, 9, 0),
                        bank_routing_num
                    ),
                    bank_acct_num = nvl(p_bank_acct_num, bank_acct_num),
                    bank_name = nvl(p_bank_name, bank_name),
                    bank_acct_type = nvl(p_bank_acct_type, bank_acct_type),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                    bank_acct_id = x_bank_acct_id;

            end if;
         -- code ends her  9412
        end if;

    exception
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('insert_user_bank_acct', x_error_message);
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
            pc_log.log_error('insert_user_bank_acct', sqlerrm);
    end fhra_upsert_bank_acct;

 -- This function is used for deleting the bank account and disassociating the bank account from Rate plan
 -- once bank is disassociated from all invoice types. bank is made inactive
    procedure fhra_delete_user_bank_acct (
        p_entrp_id         in number,
        p_acc_num          in varchar2,
        p_bank_acct_id     in varchar2_tbl,
        p_invoice_type     in varchar2_tbl,
        p_invoice_param_id in varchar2_tbl,
        p_user_id          in number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is
        l_bank_count integer;
        setup_error exception;
    begin
        x_return_status := 'S';
        for i in 1..p_bank_acct_id.count loop
      /* Commented by jaggi for #11276.
          SELECT COUNT(*)
          INTO   l_bank_count
          FROM   ach_transfer_v
          WHERE  bank_acct_id = p_bank_acct_id(i)
          --  AND   acc_num = p_acc_num (commented by Joshi for 9350)
           AND   status  IN (1,2);

           IF l_bank_count > 0 THEN
             x_error_message := 'Cannot delete bank account as there are pending transactions associated with this account.';
             RAISE setup_error;
           END IF;

		-- update the payment method to CHECK.
/* Commented by jaggi for #11276.
		IF p_invoice_param_id(i) IS NOT NULL THEN

            UPDATE INVOICE_PARAMETERS
            SET PAYMENT_METHOD = 'CHECK'
              ,AUTOPAY = 'N'
              ,BANK_ACCT_ID = null
              ,last_update_date = SYSDATE
              ,last_updated_by  = p_user_id
            WHERE ENTITY_TYPE='EMPLOYER'
            AND   ENTITY_ID = P_ENTRP_ID
            AND   invoice_param_id = p_invoice_param_id(i)
            AND   INVOICE_TYPE = p_invoice_type(i)
            AND   STATUS = 'A' ;

        -- check if there are any rateplans asscoiated with bank. if not remove the account.
        SELECT COUNT(*)
        INTO   l_bank_count
        FROM   INVOICE_PARAMETERS
        WHERE  bank_acct_id = p_bank_acct_id(i)
            AND   ENTITY_TYPE='EMPLOYER'
            AND   ENTITY_ID = P_ENTRP_ID
            AND   status = 'A';

        IF  l_bank_count = 0 THEN
             -- Commented by Joshi for 9142
            UPDATE user_bank_acct
            SET   status = 'I'
            ,   last_update_date = SYSDATE
            ,   last_updated_by  = p_user_id
            ,   inactive_reason = 'DELETED_BY_CUSTOMER'
            ,   inactive_date = SYSDATE
           WHERE  bank_acct_id = p_bank_acct_id(i);
         --

           -- Added below by Joshi for 9142
           UPDATE Bank_accounts
            SET status = 'I'
             ,last_update_date = SYSDATE
             ,last_updated_by  = p_user_id
             ,inactive_reason = 'DELETED_BY_CUSTOMER'
             ,inactive_date = SYSDATE
           WHERE  bank_acct_id = p_bank_acct_id(i);
         END IF;
    ELSE
*/
       -- Added below by Joshi for 9515.
            update bank_accounts
            set
                status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                inactive_reason = 'DELETED_BY_CUSTOMER',
                inactive_date = sysdate
            where
                bank_acct_id = p_bank_acct_id(i);
		--END IF;
         -- Added by Joshi for #11276. canel pending transactions/update payment method in invoice setting to ACH_PUSH for bank account associated
         -- update payment method in invoices (generated and processed status) to ACH_PUSH for bank account associated.
            pc_claim.cancel_invalid_bank_txns(
                p_bank_acct_id(i),
                null,
                p_user_id
            );
        end loop;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            x_error_message := 'Error in deleting bank account, Contact customer service ';
            pc_log.log_error('DELETE_USER_BANK_ACCT', sqlerrm);
    end fhra_delete_user_bank_acct;

-- Code ends here - 6322

-- Added by Joshi for 9142 on 07/23/2020
    procedure insert_bank_account (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_display_name       in varchar2,
        p_bank_acct_type     in varchar2,
        p_bank_routing_num   in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_account_usage in varchar2 default 'ONLINE',
        p_user_id            in number,
        x_bank_acct_id       out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is
    begin
        x_error_message := 'S';
        x_return_status := 'S'; -- added by jaggi #10431

        pc_log.log_error('pc_user_bank_acct.insert_bank_account INSERT INTO bank_accounts p_entity_id ', p_entity_id);
        insert into bank_accounts (
            bank_acct_id,
            entity_id,
            entity_type,
            display_name,
            bank_acct_type,
            bank_routing_num,
            bank_acct_num,
            bank_name,
            bank_account_usage,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date
        ) values ( user_bank_acct_seq.nextval,
                   p_entity_id,
                   p_entity_type,
                   p_display_name,
                   p_bank_acct_type,
                   lpad(p_bank_routing_num, 9, 0),
                   p_bank_acct_num,
                   p_bank_name,
                   p_bank_account_usage,
                   p_user_id,
                   p_user_id,
                   sysdate,
                   sysdate ) returning bank_acct_id into x_bank_acct_id;

        pc_log.log_error('pc_user_bank_acct.insert_bank_account end INSERT INTO bank_accounts p_entity_id ', p_entity_id
                                                                                                             || ' x_bank_acct_id :='
                                                                                                             || x_bank_acct_id);
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('insert_bank_account', sqlerrm);
    end insert_bank_account;

 -- Added by Swamy for Ticket#9387 on 21/08/2020
    function check_bank_acct (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_acct_type     in varchar2,
        p_routing_number     in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_account_usage in varchar2
    ) -- Added by Joshi for 10431
     return varchar2 is
        l_bank_exists varchar2(1) := 'N';
    begin
        if upper(p_entity_type) in ( 'GA', 'BROKER' ) then
            for j in (
                select
                    'Y' bank_exists
                from
                    bank_accounts
                where
                        entity_id = p_entity_id
                    and entity_type = p_entity_type
                    and bank_acct_type = p_bank_acct_type
                    and bank_routing_num = p_routing_number
                    and bank_acct_num = p_bank_acct_num
                    and lower(bank_name) = lower(ltrim(rtrim(p_bank_name)))
                    and status = 'A'
            )         -- added by jaggi #11119
             loop
                l_bank_exists := j.bank_exists;
            end loop;
        else
            for j in (
                select
                    'Y' bank_exists
                from
                    bank_accounts
                where
                        entity_id = p_entity_id
                    and entity_type = p_entity_type
                    and bank_acct_type = p_bank_acct_type
                    and bank_routing_num = p_routing_number
                    and bank_acct_num = p_bank_acct_num
                    and bank_account_usage = p_bank_account_usage
                    and lower(bank_name) = lower(ltrim(rtrim(p_bank_name)))
                    and status = 'A'
            )        -- added by jaggi #11119
             loop
                l_bank_exists := j.bank_exists;
            end loop;
        end if;

        return l_bank_exists;
    exception
        when others then
            pc_log.log_error('pc_user_bank_acct.check_bank_acct others := ', sqlerrm);
            l_bank_exists := 'N';
    end check_bank_acct;

-- Added by Joshi 10105.
    procedure export_user_bank_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) as

        l_file          utl_file.file_type;
        l_buffer        raw(32767);
        l_amount        binary_integer := 32767;
        l_pos           integer := 1;
        l_blob          blob;
        l_blob_len      integer;
        file_is_empty exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
        l_batch_number  number;
        l_file_name     varchar2(300);
        ll_row_cnt      integer := 0;
        l_error_message varchar2(4000);
    begin
        pc_log.log_error('PC_USER_BANK_ACCT.export_user_bank_upload_file', 'pv_file_name: ' || pv_file_name);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('PC_USER_BANK_ACCT.export_user_bank_upload_file lv_dest_file: ', lv_dest_file);

    --  pc_log.log_error('PC_INVOICE.export_invoice_upload_file','lv_dest_file: ' || lv_dest_file);

      --l_file_name := 'invoice_upload_new_june.csv';
        l_create_ddl := 'ALTER TABLE BANK_ACCOUNTS_EXTERNAL ACCESS PARAMETERS ('
                        || '  records delimited by newline skip 1'
                        || '  badfile '''
                        || lv_dest_file
                        || '.bad'
                        || ''' '
                        || '  logfile '''
                        || lv_dest_file
                        || '.log'
                        || ''' '
                        || '  fields terminated by '','' '
                        || '  optionally enclosed by ''"'' '
                        || '  LRTRIM '
                        || '  MISSING FIELD VALUES ARE NULL)  '
                        || '  LOCATION (INVOICE_UPLOAD_DIR:'''
                        || lv_dest_file
                        || ''')';

      /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            pc_log.log_error('PC_INVOICE.export_invoice_upload_file', 'Before opening file');
            l_file := utl_file.fopen('INVOICE_UPLOAD_DIR', lv_dest_file, 'w', 32767);
            pc_log.log_error('PC_INVOICE.export_invoice_upload_file', 'after opening file');
            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
            while l_pos < l_blob_len loop
                dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
                utl_file.put_raw(l_file, l_buffer, true);
                l_pos := l_pos + l_amount;
            end loop;
        -- Close the file.
            utl_file.fclose(l_file);

        -- Delete file from wwv_flow_files
            delete from wwv_flow_files
            where
                name = pv_file_name;

        exception
            when others then
                pc_log.log_error('PC_INVOICE.export_invoice_upload_file', 'in reading file : ' || sqlerrm);
        --  NULL;
        end;

        execute immediate l_create_ddl;
        select
            count(*)
        into ll_row_cnt
        from
            bank_accounts_external;

        if ll_row_cnt = 0 then
            l_error_message := 'File '
                               || lv_dest_file
                               || ' must be empty or records are invalid';
            raise file_is_empty;
        end if;

        select
            invoice_batch_seq.nextval
        into l_batch_number
        from
            dual;

        x_batch_number := l_batch_number;
        pc_log.log_error('PC_INVOICE.export_invoice_upload_file', 'Batch number: ' || l_batch_number);
        insert into user_bank_acct_staging (
            batch_number,
            user_bank_acct_stg_id,
            acc_num,
            bank_name,
            display_name,
            bank_routing_num,
            bank_acct_num,
            acct_usage,
            bank_acct_type,
            validity,
            enrollment_source,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date
        )
            select
                l_batch_number,
                user_bank_acct_stg_seq.nextval,
                acc_num,
                bank_name,
                display_name,
                bank_routing_num,
                bank_acct_num,
                upper(bank_account_usage),
                bank_acct_type,
                'V',
                'SAM',
                p_user_id,
                sysdate,
                p_user_id,
                null
            from
                bank_accounts_external;

        commit;
    exception
        when file_is_empty then
            raise_application_error('-20001', l_error_message);
        when others then
            pc_log.log_error('pc_user_bank_acct.export_user_bank_upload_file', 'in reading file : ' || sqlerrm);
            raise_application_error('-20001', 'Error in Exporting File ' || ' Please check the field length of each column or File template format'
            );
            rollback;

-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

-- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;
  /*  mail_utility.send_email('oracle@sterlingadministration.com'
                  ,'techsupport@sterlingadministration.com'
                  ,'Error in Enrollment file Upload'||pv_file_name
                  ,SQLERRM);*/
            pc_file.extract_error_from_log(pv_file_name || '.log', 'INVOICE_UPLOAD_DIR', l_log_file_name);
            l_files.delete;
            l_files.extend(3);
            l_files(1) := '/u01/app/oracle/oradata/invoice_files/' || pv_file_name;
            l_files(2) := '/u01/app/oracle/oradata/invoice_files/'
                          || pv_file_name
                          || '.bad';
            l_files(3) := '/u01/app/oracle/oradata/invoice_files/' || l_log_file_name;
            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
                to_names     => 'it-team@sterlingadministration.com', -- 'techsupport@sterlingadministration.com',
                subject      => 'Error in Enrollment file Upload ' || pv_file_name,
                html_message => sqlerrm,
                attach       => l_files
            );
    --mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);

    end export_user_bank_upload_file;

    procedure validate_userbank_upload_data (
        p_batch_number in number,
        p_user_id      in number
    ) is
        l_error_desc varchar2(32000);
        ind          number;
    begin
        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Account number cannot be blank'
        where
                batch_number = p_batch_number
            and acc_num is null;
    /*
    UPDATE USER_BANK_ACCT_STAGING
       SET error_status   = 'E'
         ,error_message  = nvl(error_message,'') ||' Account Name cannot be null'
     WHERE batch_number   =  p_batch_number
       AND DISPLAY_NAME is null; */

        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Bank Account Type cannot be null'
        where
                batch_number = p_batch_number
            and bank_acct_type is null
            or ltrim(rtrim(bank_acct_type)) = '';

        update user_bank_acct_staging u
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Enter Valid Bank Account Type'
        where
                batch_number = p_batch_number
            and bank_acct_type is not null
            and not exists (
                select
                    *
                from
                    bank_account_type
                where
                    upper(bank_acct_name) = upper(u.bank_acct_type)
            );

        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Bank Routing number cannot be null'
        where
                batch_number = p_batch_number
            and bank_routing_num is null;

        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Bank Account number cannot be null'
        where
                batch_number = p_batch_number
            and bank_acct_num is null;

        update user_bank_acct_staging u
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Bank Account usage cannot be null'
        where
                batch_number = p_batch_number
            and acct_usage is null;

        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Bank Account number must be numeric value'
        where
                batch_number = p_batch_number
            and bank_acct_num is not null
            and is_number(bank_acct_num) = 'N'
            and error_message is null;

        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Bank Name cannot be null'
        where
                batch_number = p_batch_number
            and bank_name is null;

        update user_bank_acct_staging u
        set
            acc_id = (
                select
                    acc_id
                from
                    account
                where
                        acc_num = u.acc_num
                    and entrp_id is null
            )
        where
                u.batch_number = p_batch_number
            and u.acc_num is not null;

        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Account number do not exist'
        where
                batch_number = p_batch_number
            and acc_id is null
            and error_message is null;

        update user_bank_acct_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Bank routing no is invalid'
        where
                batch_number = p_batch_number
            and verify_bannk_routing_num(bank_routing_num) = 'N'
            and bank_routing_num is not null
            and error_message is null;

        update user_bank_acct_staging u
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Bank Account usage is not valid'
        where
                batch_number = p_batch_number
            and error_message is null
            and acct_usage is not null
            and not exists (
                select
                    *
                from
                    bank_acct_usage
                where
                    upper(meaning) = upper(u.acct_usage)
            );

        update user_bank_acct_staging u
        set
            error_status = 'E',
            error_message = ' There is already record in file with same account and bank detail'
        where
                batch_number = p_batch_number
            and rowid in (
                select
                    rowid
                from
                    (
                        select
                            acc_num, bank_name, bank_routing_num, bank_acct_num, bank_acct_type,
                            acct_usage, row_number()
                                        over(partition by acc_num, bank_name, bank_routing_num, bank_acct_num, bank_acct_type,
                                                          acct_usage
                                             order by
                                                 acc_num
                            ) as row_number
                        from
                            user_bank_acct_staging
                        where
                            batch_number = u.batch_number
                    )
                where
                    row_number > 1
            );

        update user_bank_acct_staging u
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Subscriber has bank records with same routing number and account number'
        where
                batch_number = p_batch_number
            and error_message is null
            and exists (
                select
                    *
                from
                    user_bank_acct_v
                where
                        acc_id = u.acc_id
                    and bank_routing_num = u.bank_routing_num
                    and bank_acct_num = u.bank_acct_num
                    and bank_name = u.bank_name
                    and status = 'A'
            );

    end validate_userbank_upload_data;

    procedure process_user_bank_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) is
        l_batch_number  number;
        l_return_status varchar2(1);
        l_error_message varchar2(32000);
    begin
        export_user_bank_upload_file(pv_file_name, p_user_id, l_batch_number);
        validate_userbank_upload_data(l_batch_number, p_user_id);
        process_user_bank_accounts(l_batch_number, l_return_status, l_error_message);
        x_batch_number := l_batch_number;
        commit;
    end process_user_bank_upload_file;

    procedure process_user_bank_accounts (
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_bank_acct_id      number;
        l_error_status      varchar2(10);
        l_error_message     varchar2(1000);
        l_account_usage     varchar2(100);
        setup_error exception;
        l_bank_account_type varchar2(2);
    begin
        for x in (
            select
                *
            from
                user_bank_acct_staging
            where
                    batch_number = p_batch_number
                and error_status is null
        ) loop
            for y in (
                select
                    bank_acct_type
                from
                    bank_account_type
                where
                    upper(bank_acct_name) = upper(x.bank_acct_type)
            ) loop
                l_bank_account_type := y.bank_acct_type;
            end loop;

            pc_user_bank_acct.insert_bank_account(
                p_entity_id          => x.acc_id,
                p_entity_type        => 'ACCOUNT',
                p_display_name       => nvl(x.display_name, x.bank_name),
                p_bank_acct_type     => l_bank_account_type,
                p_bank_routing_num   => lpad(x.bank_routing_num, 9, 0),
                p_bank_acct_num      => x.bank_acct_num,
                p_bank_name          => x.bank_name,
                p_bank_account_usage => x.acct_usage,
                p_user_id            => x.created_by,
                x_bank_acct_id       => l_bank_acct_id,
                x_return_status      => l_error_status,
                x_error_message      => l_error_message
            );

            if l_error_status = 'E' then
                raise setup_error;
            else
                update user_bank_acct_staging
                set
                    error_status = 'S',
                    error_message = 'Bank account is added successfully'
                where
                        acc_id = x.acc_id
                    and user_bank_acct_stg_id = x.user_bank_acct_stg_id;

            end if;

        end loop;
    exception
        when setup_error then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('pc_user_bank_acct.process_user_bank_accounts',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('pc_user_bank_acct.process_user_bank_accounts',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end process_user_bank_accounts;

 -- Start Added by swmay for ticket#10747
    function get_broker_bank_details (
        p_acc_id        in number,
        p_user_id       in number,
        p_bank_acct_num in varchar2
    ) return bank_record_t
        pipelined
        deterministic
    is

        l_record       bank_record_row_t;
        x_error_status varchar2(10);
        l_broker_id    number;
        l_entity_type  varchar2(30);
        cursor cur_broker_bank_det (
            lc_broker_id number
        ) is
        select
            u.bank_acct_id,
            a.acc_id,
            a.acc_num,
            u.display_name,
            u.bank_acct_type,
            a.account_type,
            u.bank_acct_num,
            u.bank_routing_num,
            u.bank_account_usage,     -- Added by Jaggi #11263
            u.giac_verify,            -- Added by Swamy for Ticket#12309
            u.status                  -- Added by Swamy for Ticket#12670
        from
            user_bank_acct_broker_v u,
            account                 a
        where
                u.entity_id = a.broker_id
      --AND u.status    = 'A' 
            and u.entity_id = lc_broker_id
            and a.acc_id = p_acc_id
            and u.bank_acct_num = p_bank_acct_num
        order by
            u.bank_acct_id desc;

    begin
        x_error_status := 'E';
        pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);

      /*FOR k IN (SELECT a.user_type, b.broker_id
	              FROM online_users a, broker b
				 WHERE a.user_id = p_user_id
				   AND a.find_key = b.broker_lic) LOOP  -- Added by Swamy for Ticket#10747
          IF NVL(k.user_type,'*') = 'B' THEN
             l_broker_id := k.broker_id;
          END IF;
      END LOOP;
       */
        for c1 in cur_broker_bank_det(l_broker_id) loop
            l_record.bank_acc_id := c1.bank_acct_id;
            l_record.acc_id := c1.acc_id;
            l_record.acc_num := c1.acc_num;
            l_record.display_name := c1.display_name;
            l_record.bank_acct_type := c1.bank_acct_type;
            l_record.account_type := c1.account_type;
            l_record.bank_account_usage := c1.bank_account_usage;
            l_record.bank_acct_num := c1.bank_acct_num;
            l_record.bank_routing_num := c1.bank_routing_num;  -- Added by Jaggi #11263
            l_record.giac_verify := c1.giac_verify; -- Added by Swamy for Ticket#12309
            l_record.status := c1.status; -- Added by Swamy for Ticket#12670
            x_error_status := 'S';
            pipe row ( l_record );
        end loop;

        if x_error_status = 'E' then
            l_record.bank_acc_id := null;
            l_record.error_message := 'You do not have a bank account on record.You must add a bank account by logging into sterlinghsa.com '
            ;
            pipe row ( l_record );
        end if;

    end get_broker_bank_details;

 --  Added by Jaggi for ticket#10747
/*FUNCTION Validate_Bank_Info( p_entity_id      IN NUMBER
                           , p_entity_type    IN VARCHAR2 DEFAULT 'ACCOUNT'
                           , p_routing_number IN VARCHAR2
                           , p_bank_acct_num  IN VARCHAR2
                           , p_bank_name      IN VARCHAR2
                           , p_bank_acct_id   IN NUMBER
                           , p_bank_acct_usage IN VARCHAR2 DEFAULT 'ONLINE' -- Added by Swamy for Ticket#12309
                           ) RETURN VARCHAR2
 IS
 l_bank_details_exists varchar2(1) := 'N';
 l_entrp_code VARCHAR2(20);
 l_pers_id    NUMBER(9);
 l_entrp_id   NUMBER;
 l_cnt_usage  NUMBER;
 l_account_type  VARCHAR2(200);
 l_ssn        VARCHAR2(200);

  BEGIN

   pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info','p_entity_id '||p_entity_id||' p_entity_type :='||p_entity_type||'p_routing_number :='||p_routing_number||'p_bank_acct_num :='||p_bank_acct_num||' p_bank_name :='||p_bank_name||' p_bank_acct_id :='||p_bank_acct_id);
  IF p_entity_type = 'ACCOUNT' THEN
   FOR Z IN ( SELECT entrp_code,account_type
                FROM account A, enterprise E
               WHERE A.entrp_id = E.entrp_id
                 AND a.acc_id = p_entity_id)
   LOOP
         l_entrp_code   :=  z.entrp_code;
         l_account_type := z.account_type;
   END LOOP;

   pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info','l_entrp_code '||l_entrp_code);
   IF NVL(l_entrp_code,'*') = '*' THEN
       FOR J IN (SELECT pers_id FROM Account WHERE acc_id = p_entity_id)
       LOOP
           l_pers_id    :=  J.pers_id   ;
       END LOOP;

       FOR k IN (SELECT entrp_id FROM person WHERE pers_id = l_pers_id)
       LOOP
           l_entrp_id    :=  k.entrp_id   ;
       END LOOP;

       FOR m IN (SELECT format_ssn(ssn) ssn FROM person WHERE pers_id = l_pers_id)
       LOOP
          l_ssn := m.ssn;
       END LOOP;      

   END IF;

   pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info','l_ssn '||l_ssn||' l_pers_id :='||l_pers_id||'l_entrp_id :='||l_entrp_id);

   -- INACTIVE bank  check
  IF ( l_pers_id is NOT NULL AND p_entity_type = 'ACCOUNT') OR p_entity_type in ('GA','BROKER') THEN -- EE/BROKER/GA
      FOR X IN (SELECT COUNT(*) CNT
                  FROM BANK_ACCOUNTS
                 WHERE entity_id  = p_entity_id
                   AND ENTITY_TYPE = p_entity_type
                   AND bank_routing_num = p_routing_number
                   AND bank_acct_num = p_bank_acct_num
                   --AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667  -- Added by swamy for ticket#11800
                   AND status = 'I'
                   -- AND UPPER(inactive_reason) <> 'DELETED_BY_CUSTOMER' -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024 
                   AND UPPER(inactive_reason) NOT IN ( 'DELETED_BY_CUSTOMER','SYSTEM_INACTIVATED') -- commented above and added by Joshi for 12396.
                   --AND UPPER(inactive_reason) = 'INVALID_ACCOUNT'   -- Commented by Swamy for Ticket#12267(Main ticket 10978) 11072024 
                   AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id)
                         OR p_bank_acct_id IS NULL))
      LOOP
            IF X.CNT > 0 THEN
                -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
                l_bank_details_exists:= 'I';
         END IF;
         pc_log.log_error('Validate_Bank_Info','l_bank_details_exists **1'||l_bank_details_exists);
      END LOOP;

      -- Added by Swamy for Ticket#12496(Development Ticket#12259)
      IF NVL(l_bank_details_exists,'N') = 'N' AND l_pers_id is NOT NULL THEN
       FOR X IN (SELECT COUNT(*) CNT
                  FROM BANK_ACCOUNTS
                 WHERE entity_id  IN (SELECT a.acc_id from account a,person p where a.pers_id = p.pers_id and format_ssn(p.ssn) = l_ssn)
                   AND ENTITY_TYPE = p_entity_type
                   AND bank_routing_num = p_routing_number
                   AND bank_acct_num = p_bank_acct_num
                   --AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))   -- Commented by Ticket#12667 
                   AND status = 'I'
                 --  AND UPPER(inactive_reason) <> 'DELETED_BY_CUSTOMER' 
                   AND UPPER(inactive_reason) NOT IN ( 'DELETED_BY_CUSTOMER','SYSTEM_INACTIVATED') -- commented above and added by Joshi for 12396.
                   AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id)
                         OR p_bank_acct_id IS NULL))
      LOOP
            IF X.CNT > 0 THEN
               --'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
                l_bank_details_exists:= 'I';
         END IF;
         pc_log.log_error('Validate_Bank_Info','l_bank_details_exists **2'||l_bank_details_exists);
      END LOOP;
      END IF;

  ELSE -- ER
      FOR X IN (SELECT COUNT(*) CNT
                  FROM BANK_ACCOUNTS B, ACCOUNT A,ENTERPRISE E
                 WHERE B.ENTITY_TYPE = p_entity_type
                   AND A.ENTRP_ID = E.ENTRP_ID
                   AND B.ENTITY_ID = A.ACC_ID
                   AND ENTRP_CODE = l_entrp_code
                   AND B.bank_routing_num = p_routing_number
                   AND B.bank_acct_num = p_bank_acct_num
                   --AND LOWER(b.bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))   -- Commented by Ticket#12667  -- Added by swamy for ticket#11800
                   AND B.status = 'I'
                   --AND UPPER(inactive_reason) <> 'DELETED_BY_CUSTOMER' -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024
                   AND UPPER(inactive_reason) NOT IN ( 'DELETED_BY_CUSTOMER','SYSTEM_INACTIVATED') -- commented above and added by Joshi for 12396.
                   --AND UPPER(B.inactive_reason) = 'INVALID_ACCOUNT'   -- Commented by Swamy for Ticket#12267(Main ticket 10978) 11072024 
                   AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id)
                                 OR p_bank_acct_id IS NULL))
      LOOP
         IF X.CNT > 0 THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'I';
         END IF;
      END LOOP;

     IF l_bank_details_exists = 'N' AND L_ACCOUNT_TYPE IN ('FSA','HRA','COBRA') THEN
        FOR X IN ( SELECT COUNT(*) Cnt_usage 
	  		         FROM user_bank_acct_v
			        WHERE acc_id = p_entity_id
			          AND bank_account_usage = p_bank_acct_usage
			          AND account_type = L_ACCOUNT_TYPE
			          AND status = 'A'
                  )
         LOOP
	        l_cnt_usage := x.Cnt_usage;
         END LOOP;

         pc_log.log_error('Validate_Bank_Info', 'l_ACCOUNT_TYPE: ' || L_ACCOUNT_TYPE||'p_bank_acct_usage :='||p_bank_acct_usage||'p_entity_id :='||p_entity_id||' l_cnt_usage :='||l_cnt_usage); 

        IF NVL(l_cnt_usage,0) > 0 THEN  -- Commented above and Added by Swamy for Ticket#11874 on 16/11/2023
	    	l_bank_details_exists := 'E';
		   --x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.';
        END IF ;
     END IF;
  END IF;
    -- Added by Swamy #10978
    IF l_bank_details_exists = 'N' THEN
      FOR X IN ( SELECT COUNT(*) CNT 
		           FROM user_bank_acct_v
                  WHERE acc_id = p_entity_id
                    AND bank_account_usage = p_bank_acct_usage  -- Added by Swamy for Ticket#12309
                    AND status IN ('P','W')
                )
        LOOP
            IF X.CNT > 0 THEN
               -- 'Cannot add New Bank account as Your account has bank records which are Pending for Review.';
               l_bank_details_exists:= 'W';
            END IF;
        END LOOP;
    END IF;
  ELSIF p_entity_type = 'BROKER' THEN
      FOR X IN (SELECT COUNT(*) CNT
                  FROM BANK_ACCOUNTS B
                 WHERE B.ENTITY_TYPE = p_entity_type
                   AND B.ENTITY_ID = p_ENTITY_ID
                   AND B.bank_routing_num = p_routing_number
                   AND B.bank_acct_num = p_bank_acct_num
                   --AND LOWER(b.bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))   -- Commented by Ticket#12667 -- Added by swamy for ticket#11800
                   AND B.status = 'I'
                  -- AND UPPER(inactive_reason) <> 'DELETED_BY_CUSTOMER' -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024
                  AND UPPER(inactive_reason) NOT IN ( 'DELETED_BY_CUSTOMER','SYSTEM_INACTIVATED') -- commented above and added by Joshi for 12396.
                   AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id)
                                 OR p_bank_acct_id IS NULL))
      LOOP
         IF X.CNT > 0 THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'I';
         END IF;
      END LOOP;

     IF l_bank_details_exists = 'N' THEN
       FOR X IN ( SELECT COUNT(*) CNT 
		           FROM user_bank_acct_broker_v
                  WHERE entity_id = p_entity_id
                    AND bank_account_usage = p_bank_acct_usage  -- Added by Swamy for Ticket#12309
                    AND status IN ('W','P')
                 )
        LOOP
            IF X.CNT > 0 THEN
               -- 'Cannot add New Bank account as Your account has bank records which are Pending for Review.';
               l_bank_details_exists:= 'W';
            END IF;
        END LOOP;
     END IF;
  ELSIF p_entity_type IN ('GENERAL_AGENT','GA') THEN
      FOR X IN (SELECT COUNT(*) CNT
                  FROM BANK_ACCOUNTS B
                 WHERE B.ENTITY_TYPE = p_entity_type
                   AND B.ENTITY_ID = p_entity_id
                   AND B.bank_routing_num = p_routing_number
                   AND B.bank_acct_num = p_bank_acct_num
                   --AND LOWER(b.bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))   -- Commented by Ticket#12667  -- Added by swamy for ticket#11800
                   AND B.status = 'I'
                  -- AND UPPER(inactive_reason) <> 'DELETED_BY_CUSTOMER' -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024
                  AND UPPER(inactive_reason) NOT IN ( 'DELETED_BY_CUSTOMER','SYSTEM_INACTIVATED') -- commented above and added by Joshi for 12396.
                   AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id)
                                 OR p_bank_acct_id IS NULL))
      LOOP
         IF X.CNT > 0 THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'I';
         END IF;
      END LOOP;

     IF l_bank_details_exists = 'N' THEN
        FOR X IN ( SELECT COUNT(*) CNT 
		           FROM user_bank_acct_ga_v
                  WHERE entity_id = p_entity_id
                    AND bank_account_usage = p_bank_acct_usage  -- Added by Swamy for Ticket#12309
                    AND status IN ('P','W')
                  )
        LOOP
            IF X.CNT > 0 THEN
               -- 'Cannot add New Bank account as Your account has bank records which are Pending for Review.';
               l_bank_details_exists:= 'W';
            END IF;
        END LOOP;
     END IF;
  END IF;
  -- Added by jaggi #11015
   IF l_bank_details_exists = 'N' THEN
      FOR Y IN ( SELECT COUNT(*) count
                   FROM bank_accounts
                  WHERE entity_id = p_entity_id
                    AND entity_type = p_entity_type
                    AND bank_routing_num = p_routing_number
                    AND bank_acct_num = p_bank_acct_num
                    --AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667  -- Added by swamy for ticket#11800
                    AND upper(status) = 'A'
                    AND UPPER(bank_account_usage) = UPPER(p_bank_acct_usage)  -- Added by Swamy for Ticket#12309
                    AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id)
                                OR p_bank_acct_id IS NULL))
      LOOP
         IF Y.count > 0 THEN
            -- 'You already have a Active bank account with the same routing and account numbers setup!';
            l_bank_details_exists:= 'D';
         END IF;
      END LOOP;
    END IF;

  -- Added by Swamy #10978
   IF l_bank_details_exists = 'N' AND L_ACCOUNT_TYPE NOT IN ('FSA','HRA','COBRA') THEN   
      FOR Y IN ( SELECT COUNT(*) count 
                   FROM bank_accounts
                  WHERE entity_id = p_entity_id
                    AND entity_type = p_entity_type
                    AND bank_routing_num = p_routing_number
                    AND bank_acct_num = p_bank_acct_num
                   -- AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))  -- Ticket#12667 -- Added by swamy for ticket#11800
                    AND upper(status) = 'P'
                    AND UPPER(bank_account_usage) = UPPER(p_bank_acct_usage) -- Ticket#12667
                    AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id)
                                OR p_bank_acct_id IS NULL))
      LOOP
         IF Y.count > 0 THEN
            -- 'You already have a bank account with the same routing and account numbers setup!';
            l_bank_details_exists:= 'P';
         END IF;
      END LOOP;
    END IF;

    pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info','l_bank_details_exists '||l_bank_details_exists);
  RETURN l_bank_details_exists;

 END Validate_Bank_Info;
*/

    function validate_bank_info (
        p_entity_id       in number,
        p_entity_type     in varchar2 default 'ACCOUNT',
        p_routing_number  in varchar2,
        p_bank_acct_num   in varchar2,
        p_bank_name       in varchar2,
        p_bank_acct_id    in number,
        p_bank_acct_usage in varchar2 default 'ONLINE' -- Added by Swamy for Ticket#12309
    ) return varchar2 is

        l_bank_details_exists varchar2(1) := 'N';
        l_entrp_code          varchar2(20);
        l_pers_id             number(9);
        l_entrp_id            number;
        l_cnt_usage           number;
        l_account_type        varchar2(200);
        l_ssn                 varchar2(200);
    begin
        pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info', 'p_entity_id '
                                                                 || p_entity_id
                                                                 || ' p_entity_type :='
                                                                 || p_entity_type
                                                                 || 'p_routing_number :='
                                                                 || p_routing_number
                                                                 || 'p_bank_acct_num :='
                                                                 || p_bank_acct_num
                                                                 || ' p_bank_name :='
                                                                 || p_bank_name
                                                                 || ' p_bank_acct_id :='
                                                                 || p_bank_acct_id);

        if p_entity_type = 'ACCOUNT' then
            for z in (
                select
                    entrp_code,
                    account_type
                from
                    account    a,
                    enterprise e
                where
                        a.entrp_id = e.entrp_id
                    and a.acc_id = p_entity_id
            ) loop
                l_entrp_code := z.entrp_code;
                l_account_type := z.account_type;
            end loop;

            pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info', 'l_entrp_code ' || l_entrp_code);
            if nvl(l_entrp_code, '*') = '*' then
                for j in (
                    select
                        pers_id
                    from
                        account
                    where
                        acc_id = p_entity_id
                ) loop
                    l_pers_id := j.pers_id;
                end loop;

                for k in (
                    select
                        entrp_id
                    from
                        person
                    where
                        pers_id = l_pers_id
                ) loop
                    l_entrp_id := k.entrp_id;
                end loop;

                for m in (
                    select
                        format_ssn(ssn) ssn
                    from
                        person
                    where
                        pers_id = l_pers_id
                ) loop
                    l_ssn := m.ssn;
                end loop;

            end if;

            pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info', 'l_ssn '
                                                                     || l_ssn
                                                                     || ' l_pers_id :='
                                                                     || l_pers_id
                                                                     || 'l_entrp_id :='
                                                                     || l_entrp_id);

   -- INACTIVE bank  check
            if (
                l_pers_id is not null
                and p_entity_type = 'ACCOUNT'
            )
            or p_entity_type in ( 'GA', 'BROKER' ) then -- EE/BROKER/GA
     /* FOR X IN (SELECT B.*
                  FROM BANK_ACCOUNTS B
                 WHERE b.entity_id  = p_entity_id
                   AND b.ENTITY_TYPE = p_entity_type
                   AND b.bank_routing_num = p_routing_number
                   AND b.bank_acct_num = p_bank_acct_num
                   --AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667  -- Added by swamy for ticket#11800
                   AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER')) -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024 
                   --AND UPPER(inactive_reason) = 'INVALID_ACCOUNT'   -- Commented by Swamy for Ticket#12267(Main ticket 10978) 11072024 
                   AND ((p_bank_acct_id IS NOT NULL AND b.bank_acct_id <> p_bank_acct_id)  OR p_bank_acct_id IS NULL)

                                       )
      LOOP
         l_bank_details_exists:= 'I';   
         IF X.status = 'A' THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'N';
         END IF;
         pc_log.log_error('Validate_Bank_Info','l_bank_details_exists **1'||l_bank_details_exists);
      END LOOP;
      -- Added by Swamy for Ticket#12496(Development Ticket#12259)
      IF NVL(l_bank_details_exists,'N') = 'N' AND l_pers_id is NOT NULL THEN
       FOR X IN (SELECT B.*
                  FROM BANK_ACCOUNTS B
                 WHERE b.entity_id  IN (SELECT a.acc_id from account a,person p where a.pers_id = p.pers_id and format_ssn(p.ssn) = l_ssn)
                   AND b.ENTITY_TYPE = p_entity_type
                   AND b.bank_routing_num = p_routing_number
                   AND b.bank_acct_num = p_bank_acct_num
                   --AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))   -- Commented by Ticket#12667 
                   AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER')) -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024  
                   AND ((p_bank_acct_id IS NOT NULL AND b.bank_acct_id <> p_bank_acct_id) OR p_bank_acct_id IS NULL)                   
                         )
      LOOP

         l_bank_details_exists:= 'I';   
         IF X.status = 'A' THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'N';
         END IF;
         pc_log.log_error('Validate_Bank_Info','l_bank_details_exists **2'||l_bank_details_exists);
      END LOOP;
      END IF;
      */

                begin
                    l_bank_details_exists := 'N';
                    for x in (
                        with rws as (
                            select
                                b.bank_acct_num bank_acct_num,
                                b.status
                            from
                                bank_accounts b
                            where
                                b.entity_id in (
                                    select
                                        a.acc_id
                                    from
                                        account a, person  p
                                    where
                                            a.pers_id = p.pers_id
                                        and format_ssn(p.ssn) = l_ssn
                                )
                                and b.entity_type = p_entity_type
                                and b.bank_routing_num = p_routing_number
                                and b.bank_acct_num = p_bank_acct_num
   -- AND ( B.status = 'A' OR (B.STATUS = 'I' AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER')))
                                and ( b.status = 'A'
                                      or ( b.status = 'I'
                                           and upper(b.inactive_reason) not in ( 'DELETED_BY_CUSTOMER', 'DELETED_IN_OFFICE' ) ) )
                        )  -- Added by Joshi  for 12732
                        select
                            *
                        from
                            rws pivot (
                                count(status)
                                for status
                                in ( 'A' active, 'I' inactive )
                            )
                    ) loop
                        if
                            x.inactive > 0
                            and x.active = 0
                        then
                            l_bank_details_exists := 'I';
                        else
                            l_bank_details_exists := 'N';
                        end if;

                        pc_log.log_error('Validate_Bank_Info', 'x.inactive **2'
                                                               || x.inactive
                                                               || 'x.active :='
                                                               || x.active
                                                               || ' l_bank_details_exists :='
                                                               || l_bank_details_exists);

                    end loop;

                end;
            else -- ER
     /* FOR X IN (SELECT b.*
                  FROM BANK_ACCOUNTS B, ACCOUNT A,ENTERPRISE E
                 WHERE B.ENTITY_TYPE = p_entity_type
                   AND A.ENTRP_ID = E.ENTRP_ID
                   AND B.ENTITY_ID = A.ACC_ID
                   AND ENTRP_CODE = l_entrp_code
                   AND B.bank_routing_num = p_routing_number
                   AND B.bank_acct_num = p_bank_acct_num
                   AND ((p_bank_acct_id IS NOT NULL AND bank_acct_id <> p_bank_acct_id) OR p_bank_acct_id IS NULL) 
                   AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER') )  )-- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024           
      LOOP
         l_bank_details_exists:= 'I';   
         IF X.status = 'A' THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'N';
         END IF;
      END LOOP;
*/

                begin
                    l_bank_details_exists := 'N';
                    for x in (
                        with rws as (
                            select
                                b.bank_acct_num bank_acct_num,
                                b.status
                            from
                                bank_accounts b,
                                account       a,
                                enterprise    e
                            where
                                    b.entity_type = p_entity_type
                                and a.entrp_id = e.entrp_id
                                and b.entity_id = a.acc_id
                                and entrp_code = l_entrp_code
                                and b.bank_routing_num = p_routing_number
                                and b.bank_acct_num = p_bank_acct_num
                                and ( ( p_bank_acct_id is not null
                                        and bank_acct_id <> p_bank_acct_id )
                                      or p_bank_acct_id is null ) 
                  -- AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER') )  )-- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024           
                                and ( b.status = 'A'
                                      or ( b.status = 'I'
                                           and upper(b.inactive_reason) not in ( 'DELETED_BY_CUSTOMER', 'DELETED_IN_OFFICE' ) ) )
                        )   -- Added by Joshi  for 12732
                        select
                            *
                        from
                            rws pivot (
                                count(status)
                                for status
                                in ( 'A' active, 'I' inactive )
                            )
                    ) loop
                        if
                            x.inactive > 0
                            and x.active = 0
                        then
                            l_bank_details_exists := 'I';
                        else
                            l_bank_details_exists := 'N';
                        end if;

                        pc_log.log_error('Validate_Bank_Info', 'x.inactive **3'
                                                               || x.inactive
                                                               || 'x.active :='
                                                               || x.active
                                                               || ' l_bank_details_exists :='
                                                               || l_bank_details_exists);

                    end loop;

                end;

                if
                    l_bank_details_exists = 'N'
                    and l_account_type in ( 'FSA', 'HRA', 'COBRA' )
                then
                    for x in (
                        select
                            count(*) cnt_usage
                        from
                            user_bank_acct_v
                        where
                                acc_id = p_entity_id
                            and bank_account_usage = p_bank_acct_usage
                            and account_type = l_account_type
                            and status = 'A'
                    ) loop
                        l_cnt_usage := x.cnt_usage;
                    end loop;

                    pc_log.log_error('Validate_Bank_Info', 'l_ACCOUNT_TYPE: '
                                                           || l_account_type
                                                           || 'p_bank_acct_usage :='
                                                           || p_bank_acct_usage
                                                           || 'p_entity_id :='
                                                           || p_entity_id
                                                           || ' l_cnt_usage :='
                                                           || l_cnt_usage);

                    if nvl(l_cnt_usage, 0) > 0 then  -- Commented above and Added by Swamy for Ticket#11874 on 16/11/2023
                        l_bank_details_exists := 'E';
		   --x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.';
                    end if;
                end if;

            end if;
    -- Added by Swamy #10978
            if l_bank_details_exists = 'N' then
                for x in (
                    select
                        count(*) cnt
                    from
                        user_bank_acct_v
                    where
                            acc_id = p_entity_id
                        and bank_account_usage = p_bank_acct_usage  -- Added by Swamy for Ticket#12309
                        and status in ( 'P', 'W' )
                ) loop
                    if x.cnt > 0 then
               -- 'Cannot add New Bank account as Your account has bank records which are Pending for Review.';
                        l_bank_details_exists := 'W';
                    end if;
                end loop;
            end if;

        elsif p_entity_type = 'BROKER' then
    /*  FOR X IN (SELECT B.*
                  FROM BANK_ACCOUNTS B
                 WHERE B.ENTITY_TYPE = p_entity_type
                   AND B.ENTITY_ID = p_ENTITY_ID
                   AND B.bank_routing_num = p_routing_number
                   AND B.bank_acct_num = p_bank_acct_num
                   AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER')) -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024
                    AND ((p_bank_acct_id IS NOT NULL AND b.bank_acct_id <> p_bank_acct_id) OR p_bank_acct_id IS NULL)
                    )
      LOOP
         l_bank_details_exists:= 'I';   
         IF X.status = 'A' THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'N';
         END IF;
      END LOOP;
      */

            begin
                l_bank_details_exists := 'N';
                for x in (
                    with rws as (
                        select
                            b.bank_acct_num bank_acct_num,
                            b.status
                        from
                            bank_accounts b
                        where
                                b.entity_type = p_entity_type
                            and b.entity_id = p_entity_id
                            and b.bank_routing_num = p_routing_number
                            and b.bank_acct_num = p_bank_acct_num
                  -- AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER')) -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024
                            and ( b.status = 'A'
                                  or ( b.status = 'I'
                                       and upper(b.inactive_reason) not in ( 'DELETED_BY_CUSTOMER', 'DELETED_IN_OFFICE' ) ) )   -- Added by Joshi  for 12732
                            and ( ( p_bank_acct_id is not null
                                    and b.bank_acct_id <> p_bank_acct_id )
                                  or p_bank_acct_id is null )
                    )
                    select
                        *
                    from
                        rws pivot (
                            count(status)
                            for status
                            in ( 'A' active, 'I' inactive )
                        )
                ) loop
                    if
                        x.inactive > 0
                        and x.active = 0
                    then
                        l_bank_details_exists := 'I';
                    else
                        l_bank_details_exists := 'N';
                    end if;

                    pc_log.log_error('Validate_Bank_Info', 'x.inactive **4'
                                                           || x.inactive
                                                           || 'x.active :='
                                                           || x.active
                                                           || ' l_bank_details_exists :='
                                                           || l_bank_details_exists);

                end loop;

            end;

    /* IF l_bank_details_exists = 'N' THEN
        FOR X IN ( SELECT COUNT(*) Cnt_usage 
	  		         FROM user_bank_acct_broker_v
			        WHERE entity_id = p_entity_id
			          AND bank_account_usage = p_bank_acct_usage
			          AND status = 'A' )
         LOOP
	        l_cnt_usage := x.Cnt_usage;
         END LOOP;

         pc_log.log_error('Validate_Bank_Info', 'l_ACCOUNT_TYPE: ' || L_ACCOUNT_TYPE||'p_bank_acct_usage :='||p_bank_acct_usage||'p_entity_id :='||p_entity_id||' l_cnt_usage :='||l_cnt_usage); 

        IF NVL(l_cnt_usage,0) > 0 THEN  -- Commented above and Added by Swamy for Ticket#11874 on 16/11/2023
	    	l_bank_details_exists := 'E';
		   --x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.';
        END IF ;
     END IF;
     */
            if l_bank_details_exists = 'N' then
                for x in (
                    select
                        count(*) cnt
                    from
                        user_bank_acct_broker_v
                    where
                            entity_id = p_entity_id
                        and bank_account_usage = p_bank_acct_usage  -- Added by Swamy for Ticket#12309
                        and status in ( 'W', 'P' )
                ) loop
                    if x.cnt > 0 then
               -- 'Cannot add New Bank account as Your account has bank records which are Pending for Review.';
                        l_bank_details_exists := 'W';
                    end if;
                end loop;

            end if;

        elsif p_entity_type in ( 'GENERAL_AGENT', 'GA' ) then
     /* FOR X IN (SELECT B.*
                  FROM BANK_ACCOUNTS B
                 WHERE B.ENTITY_TYPE = p_entity_type
                   AND B.ENTITY_ID = p_entity_id
                   AND B.bank_routing_num = p_routing_number
                   AND B.bank_acct_num = p_bank_acct_num
                   AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER')) -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024
                   AND ((p_bank_acct_id IS NOT NULL AND b.bank_acct_id <> p_bank_acct_id) OR p_bank_acct_id IS NULL)
                                 )
      LOOP
          l_bank_details_exists:= 'I';   
         IF X.status = 'A' THEN
            -- 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details';
            l_bank_details_exists:= 'N';
         END IF;
      END LOOP;
*/

            begin
                l_bank_details_exists := 'N';
                for x in (
                    with rws as (
                        select
                            b.bank_acct_num bank_acct_num,
                            b.status
                        from
                            bank_accounts b
                        where
                                b.entity_type = p_entity_type
                            and b.entity_id = p_entity_id
                            and b.bank_routing_num = p_routing_number
                            and b.bank_acct_num = p_bank_acct_num
                   --AND ( B.status = 'A'  OR (B.STATUS = 'I'  AND UPPER(B.inactive_reason) <> 'DELETED_BY_CUSTOMER')) -- Added by Swamy for Ticket#12267(Main ticket 10978) 11072024
                            and ( b.status = 'A'
                                  or ( b.status = 'I'
                                       and upper(b.inactive_reason) not in ( 'DELETED_BY_CUSTOMER', 'DELETED_IN_OFFICE' ) ) )   -- Added by Joshi  for 12732
                            and ( ( p_bank_acct_id is not null
                                    and b.bank_acct_id <> p_bank_acct_id )
                                  or p_bank_acct_id is null )
                    )
                    select
                        *
                    from
                        rws pivot (
                            count(status)
                            for status
                            in ( 'A' active, 'I' inactive )
                        )
                ) loop
                    if
                        x.inactive > 0
                        and x.active = 0
                    then
                        l_bank_details_exists := 'I';
                    else
                        l_bank_details_exists := 'N';
                    end if;

                    pc_log.log_error('Validate_Bank_Info', 'x.inactive **5'
                                                           || x.inactive
                                                           || 'x.active :='
                                                           || x.active
                                                           || ' l_bank_details_exists :='
                                                           || l_bank_details_exists);

                end loop;

            end;

    /* IF l_bank_details_exists = 'N' THEN
        FOR X IN ( SELECT COUNT(*) Cnt_usage 
	  		         FROM user_bank_acct_ga_v
			        WHERE entity_id = p_entity_id
			          AND bank_account_usage = p_bank_acct_usage
			          AND status = 'A' )
         LOOP
	        l_cnt_usage := x.Cnt_usage;
         END LOOP;

         pc_log.log_error('Validate_Bank_Info', 'l_ACCOUNT_TYPE: ' || L_ACCOUNT_TYPE||'p_bank_acct_usage :='||p_bank_acct_usage||'p_entity_id :='||p_entity_id||' l_cnt_usage :='||l_cnt_usage); 

        IF NVL(l_cnt_usage,0) > 0 THEN  -- Commented above and Added by Swamy for Ticket#11874 on 16/11/2023
	    	l_bank_details_exists := 'E';
		   --x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.';
        END IF ;
     END IF;
     */
            if l_bank_details_exists = 'N' then
                for x in (
                    select
                        count(*) cnt
                    from
                        user_bank_acct_ga_v
                    where
                            entity_id = p_entity_id
                        and bank_account_usage = p_bank_acct_usage  -- Added by Swamy for Ticket#12309
                        and status in ( 'P', 'W' )
                ) loop
                    if x.cnt > 0 then
               -- 'Cannot add New Bank account as Your account has bank records which are Pending for Review.';
                        l_bank_details_exists := 'W';
                    end if;
                end loop;

            end if;

        end if;
  -- Added by jaggi #11015
        if l_bank_details_exists = 'N' then
            for y in (
                select
                    count(*) count
                from
                    bank_accounts
                where
                        entity_id = p_entity_id
                    and entity_type = p_entity_type
                    and bank_routing_num = p_routing_number
                    and bank_acct_num = p_bank_acct_num
                    --AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667  -- Added by swamy for ticket#11800
                    and upper(status) = 'A'
                    and upper(bank_account_usage) = upper(p_bank_acct_usage)  -- Added by Swamy for Ticket#12309
                    and ( ( p_bank_acct_id is not null
                            and bank_acct_id <> p_bank_acct_id )
                          or p_bank_acct_id is null )
            ) loop
                if y.count > 0 then
            -- 'You already have a Active bank account with the same routing and account numbers setup!';
                    l_bank_details_exists := 'D';
                end if;
            end loop;
        end if;

  -- Added by Swamy #10978
        if
            l_bank_details_exists = 'N'
            and l_account_type not in ( 'FSA', 'HRA', 'COBRA' )
        then
            for y in (
                select
                    count(*) count
                from
                    bank_accounts
                where
                        entity_id = p_entity_id
                    and entity_type = p_entity_type
                    and bank_routing_num = p_routing_number
                    and bank_acct_num = p_bank_acct_num
                   -- AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))  -- Ticket#12667 -- Added by swamy for ticket#11800
                    and upper(status) = 'P'
                    and upper(bank_account_usage) = upper(p_bank_acct_usage) -- Ticket#12667
                    and ( ( p_bank_acct_id is not null
                            and bank_acct_id <> p_bank_acct_id )
                          or p_bank_acct_id is null )
            ) loop
                if y.count > 0 then
            -- 'You already have a bank account with the same routing and account numbers setup!';
                    l_bank_details_exists := 'P';
                end if;
            end loop;
        end if;

        pc_log.log_error('pc_user_bank_acct.Validate_Bank_Info', 'l_bank_details_exists ' || l_bank_details_exists);
        return l_bank_details_exists;
    end validate_bank_info;
 -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
    procedure update_bro_emp_bank_stage (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_user_id        in number,
        p_account_type   in varchar2,
        p_page_validity  in varchar2,
        p_bank_authorize in varchar2,
        p_acct_usage     in varchar2,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is

        l_entity_type           varchar2(100);
        l_broker_id             number;
        l_acc_id                number;
        l_stage_flag            varchar2(1) := 'N';
        l_bank_flag             varchar2(1) := 'N';
        l_user_bank_acct_stg_id number;
        x_user_bank_acct_stg_id number;
        x_bank_status           varchar2(100);
        v_bank_details          user_bank_acct%rowtype;
    begin
        pc_log.log_error('pc_user_bank_acct.update_Bro_emp_bank_stage', 'p_entrp_id '
                                                                        || p_entrp_id
                                                                        || ' p_batch_number :='
                                                                        || p_batch_number
                                                                        || 'p_user_id :='
                                                                        || p_user_id
                                                                        || 'p_account_type :='
                                                                        || p_account_type);

        if p_account_type in ( 'ERISA_WRAP', 'POP' ) then
            pc_broker.get_broker_id(
                p_user_id     => p_user_id,
                p_entity_type => l_entity_type,
                p_broker_id   => l_broker_id
            );

            l_entity_type := nvl(l_entity_type, 'EMPLOYER');
            l_acc_id := pc_entrp.get_acc_id(p_entrp_id);
            pc_log.log_error('pc_user_bank_acct.update_Bro_emp_bank_stage', 'l_entity_type ' || l_entity_type);
            for j in (
                select
                    user_bank_acct_stg_id,
                    bank_name,
                    bank_routing_num,
                    bank_acct_num,
                    bank_acct_type,
                    bank_authorize
                from
                    user_bank_acct_staging
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id
                    and renewed_by = l_entity_type
            ) loop
                pc_log.log_error('pc_user_bank_acct.update_Bro_emp_bank_stage', 'User_Bank_acct_stg_Id ' || j.user_bank_acct_stg_id);
                if nvl(j.user_bank_acct_stg_id, 0) <> 0 then
                    if p_account_type in ( 'ERISA_WRAP', 'POP' ) then
                        pc_log.log_error('pc_user_bank_acct.update_Bro_emp_bank_stage', 'j.BANK_NAME '
                                                                                        || j.bank_name
                                                                                        || 'j.BANK_ACCt_NUM :='
                                                                                        || j.bank_acct_num
                                                                                        || 'j.BANK_ACCt_TYPE :='
                                                                                        || j.bank_acct_type
                                                                                        || 'j.Bank_Authorize :='
                                                                                        || j.bank_authorize);

                        update online_compliance_staging
                        set
                            bank_name = j.bank_name,
                            routing_number = j.bank_routing_num,
                            bank_acc_num = j.bank_acct_num,
                            bank_acc_type = j.bank_acct_type,
                            bank_authorize = j.bank_authorize
                        where
                                batch_number = p_batch_number
                            and entrp_id = p_entrp_id;

                    end if;

                    l_stage_flag := 'Y';
                end if;

            end loop;

            pc_log.log_error('pc_user_bank_acct.update_Bro_emp_bank_stage', 'l_entity_type '
                                                                            || l_entity_type
                                                                            || 'l_stage_flag :='
                                                                            || l_stage_flag
                                                                            || 'p_account_type :='
                                                                            || p_account_type);

            if l_entity_type in ( 'BROKER', 'EMPLOYER' ) then
                if l_stage_flag = 'N' then
                    pc_log.log_error('pc_user_bank_acct.update_Bro_emp_bank_stage', 'l_acc_id ' || l_acc_id);
                    if l_entity_type = 'EMPLOYER' then
                        for j in (
                            select
                                *
                            from
                                user_bank_acct
                            where
                                    status = 'A'
                                and acc_id = l_acc_id
                        ) loop
                            v_bank_details := j;
                        end loop;

                    end if;

                    if p_account_type in ( 'ERISA_WRAP', 'POP' ) then
                        update online_compliance_staging
                        set
                            bank_name = v_bank_details.bank_name,
                            routing_number = v_bank_details.bank_routing_num,
                            bank_acc_num = v_bank_details.bank_acct_num,
                            bank_acc_type = v_bank_details.bank_acct_type
                        where
                                batch_number = p_batch_number
                            and entrp_id = p_entrp_id;

                    end if;

                    pc_log.log_error('pc_user_bank_acct.update_Bro_emp_bank_stage', 'l_entity_type calling pc_employer_enroll.Upsert_Bank_Info'
                    );
                    pc_employer_enroll.upsert_bank_info(
                        p_user_bank_acct_stg_id => l_user_bank_acct_stg_id,
                        p_entrp_id              => p_entrp_id,
                        p_batch_number          => p_batch_number,
                        p_account_type          => p_account_type,
                        p_acct_usage            => p_acct_usage,
                        p_display_name          => v_bank_details.bank_name,
                        p_bank_acct_type        => v_bank_details.bank_acct_type,
                        p_bank_routing_num      => v_bank_details.bank_routing_num,
                        p_bank_acct_num         => v_bank_details.bank_acct_num,
                        p_bank_name             => v_bank_details.bank_name,
                        p_user_id               => p_user_id,
                        p_validity              => nvl(p_page_validity, 'V'),
                        p_bank_authorize        => p_bank_authorize,
                        p_giac_response         => v_bank_details.giac_response,   -- Added by Swamy for Ticket#12309 
                        p_giac_verify           => v_bank_details.giac_verify,   -- Added by Swamy for Ticket#12309 
                        p_giac_authenticate     => v_bank_details.giac_authenticate,   -- Added by Swamy for Ticket#12309 
                        p_bank_acct_verified    => v_bank_details.bank_acct_verified,   -- Added by Swamy for Ticket#12309 
                        p_business_name         => v_bank_details.business_name,   -- Added by Swamy for Ticket#12309 
                        p_annual_optional_remit => null,   -- Added by Swamy for Ticket#12534 
                        p_existing_bank_flag    => 'Y',     -- Added by Swamy for Ticket#12534
                        p_bank_acct_id          => v_bank_details.bank_acct_id,   -- Added by Swamy for Ticket#12534(12624)
                        x_user_bank_acct_stg_id => x_user_bank_acct_stg_id,
                        x_bank_status           => x_bank_status,    -- Added by Swamy for Ticket#12534 
                        x_error_status          => x_return_status,
                        x_error_message         => x_error_message
                    );

                end if;
            end if;

        end if;

    end update_bro_emp_bank_stage;

-- Added by Jaggi #11262
    procedure remit_insert_bank_account (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_display_name       in varchar2,
        p_bank_acct_type     in varchar2,
        p_bank_routing_num   in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_account_usage in varchar2 default 'COBRA_DISBURSE',
        p_user_id            in number,
        x_bank_acct_id       out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is
    begin
        x_error_message := 'S';
        x_return_status := 'S';
        for x in (
            select
                count(*) cnt
            from
                bank_accounts
            where
                    entity_id = p_entity_id
                and entity_type = p_entity_type
                and bank_routing_num = p_bank_routing_num
                and bank_acct_num = p_bank_acct_num
                and bank_acct_type = bank_acct_type
                and bank_name = p_bank_name
                and bank_account_usage = p_bank_account_usage
                and status = 'A'
        ) loop
            if nvl(x.cnt, 0) = 0 then
                pc_user_bank_acct.insert_bank_account(
                    p_entity_id          => p_entity_id,
                    p_entity_type        => p_entity_type,
                    p_display_name       => p_display_name,
                    p_bank_acct_type     => p_bank_acct_type,
                    p_bank_routing_num   => p_bank_routing_num,
                    p_bank_acct_num      => p_bank_acct_num,
                    p_bank_name          => p_bank_name,
                    p_bank_account_usage => p_bank_account_usage,
                    p_user_id            => p_user_id,
                    x_bank_acct_id       => x_bank_acct_id,
                    x_return_status      => x_return_status,
                    x_error_message      => x_error_message
                );

            end if;
        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('remit_insert_bank_account', sqlerrm);
    end remit_insert_bank_account;

 --  Added by Swamy for Ticket#12058
    function check_duplicate_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_acc_id            in number,
        p_ssn               in varchar2 default null,
        p_user_id           in number   -- Added by Swamy for Ticket#12309 
    ) return varchar2 is

        l_duplicate_exists varchar2(1) := 'N';
        l_ssn              varchar2(100);
        l_account_type     varchar2(100);
        l_entrp_id         number;
        l_pers_id          number;
        l_entrp_code       varchar2(20);
        l_broker_id        number;
        l_ga_id            number;
        l_user_type        varchar2(2);
    begin
        pc_log.log_error('Check_Duplicate_Bank_Account', 'p_routing_number'
                                                         || p_routing_number
                                                         || 'p_user_id :='
                                                         || p_user_id
                                                         || ' p_bank_acct_num :='
                                                         || p_bank_acct_num
                                                         || 'p_bank_acct_num :='
                                                         || p_bank_acct_num
                                                         || 'p_bank_acct_id :='
                                                         || p_bank_acct_id
                                                         || 'p_bank_name :='
                                                         || p_bank_name
                                                         || 'p_bank_account_type :='
                                                         || p_bank_account_type
                                                         || 'p_acc_id:='
                                                         || p_acc_id
                                                         || ' p_ssn :='
                                                         || p_ssn);

        for k in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        )  --  Added by Swamy for Ticket#12309
         loop
            l_user_type := k.user_type;
        end loop;

        if l_user_type = 'B' then
            l_broker_id := p_acc_id;
        elsif l_user_type = 'G' then
            l_ga_id := p_acc_id;
        end if;

        for m in (
            select
                broker_id,
                ga_id
            from
                account
            where
                    acc_id = p_acc_id
                and l_user_type not in ( 'B', 'G' )
        ) loop  -- Added by Swamy for Ticket#12309  
            l_broker_id := m.broker_id;
            l_ga_id := m.ga_id;
        end loop;

        pc_log.log_error('Check_Duplicate_Bank_Account', 'l_user_type' || l_user_type);
        if nvl(l_user_type, '*') not in ( 'B', 'G' ) then    -- Added by Swamy for Ticket#12309  
            for m in (
                select
                    entrp_id,
                    pers_id
                from
                    account
                where
                    acc_id = p_acc_id
            ) loop
                l_entrp_id := m.entrp_id;
                l_pers_id := m.pers_id;
            end loop;
        end if;   -- Added by Swamy for Ticket#12309  

        pc_log.log_error('Check_Duplicate_Bank_Account', 'l_entrp_id'
                                                         || l_entrp_id
                                                         || 'l_pers_id :='
                                                         || l_pers_id);
        if nvl(l_entrp_id, 0) <> 0 then
            for j in (
                select
                    entrp_code
                from
                    enterprise
                where
                    entrp_id = l_entrp_id
            ) loop
                l_entrp_code := j.entrp_code;
            end loop;
        end if;

        pc_log.log_error('Check_Duplicate_Bank_Account', 'l_entrp_code'
                                                         || l_entrp_code
                                                         || 'l_pers_id :='
                                                         || l_pers_id);
        if nvl(l_pers_id, 0) <> 0 then
            for k in (
                select
                    format_ssn(ssn) ssn
                from
                    person
                where
                    pers_id = l_pers_id
            ) loop
                l_ssn := k.ssn;
            end loop;
        elsif nvl(p_ssn, '*') <> '*' then
            l_ssn := format_ssn(p_ssn);
        end if;

        pc_log.log_error('Check_Duplicate_Bank_Account', 'l_ssn'
                                                         || l_ssn
                                                         || ' l_entrp_code :='
                                                         || l_entrp_code);
        if nvl(l_entrp_code, 0) <> 0 then
            for x in (
                select
                    count(*) cnt
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and ( b.status <> 'I' )
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                       --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Ticket#12667
                       --AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Ticket#12667
                    and b.entity_id not in (
                        select
                            acc_id
                        from
                            account    ac, enterprise en
                        where
                                ac.entrp_id = en.entrp_id
                            and en.entrp_code = l_entrp_code
                    )
            ) loop
                if x.cnt > 0 then
                    l_duplicate_exists := 'Y';
                end if;
                pc_log.log_error('Check_Duplicate_Bank_Account for employer ', 'l_duplicate_exists' || l_duplicate_exists);
            end loop;
        end if;

        if nvl(l_ssn, '*') <> '*' then
            for x in (
                select
                    count(*) cnt
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and ( b.status <> 'I' ) -- OR (b.status = 'I' AND b.inactive_reason = 'INVALID_ACCOUNT'))
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                       --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name))) -- Ticket#12667
                       --AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Ticket#12667
                    and b.entity_id not in (
                        select
                            acc_id
                        from
                            account ac, person  p
                        where
                                ac.pers_id = p.pers_id
                            and format_ssn(p.ssn) = l_ssn
                    )
            ) loop
                if x.cnt > 0 then
                    l_duplicate_exists := 'Y';
                end if;
                pc_log.log_error('Check_Duplicate_Bank_Account for employee and individual', 'l_duplicate_exists' || l_duplicate_exists
                );
            end loop;
        end if;

        if nvl(l_user_type, '*') = 'B' then   -- Added by Swamy for Ticket#12309  
            for x in (
                select
                    count(*) cnt
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and ( b.status <> 'I' ) -- OR (b.status = 'I' AND b.inactive_reason = 'INVALID_ACCOUNT'))
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                       --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Ticket#12667
                      -- AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Ticket#12667
                    and b.entity_id <> l_broker_id
            ) loop
                if x.cnt > 0 then
                    l_duplicate_exists := 'Y';
                end if;
                pc_log.log_error('Check_Duplicate_Bank_Account for broker ', 'l_duplicate_exists' || l_duplicate_exists);
                pc_log.log_error('Check_Duplicate_Bank_Account for broker ', 'p_routing_number'
                                                                             || p_routing_number
                                                                             || ' p_bank_acct_num :='
                                                                             || p_bank_acct_num
                                                                             || 'p_bank_acct_id :='
                                                                             || p_bank_acct_id
                                                                             || 'p_bank_name :='
                                                                             || p_bank_name
                                                                             || 'p_bank_account_type :='
                                                                             || p_bank_account_type
                                                                             || 'l_broker_id :='
                                                                             || l_broker_id);

            end loop;
        end if;

        if nvl(l_user_type, '*') = 'G' then   -- Added by Swamy for Ticket#12309  
            for x in (
                select
                    count(*) cnt
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and ( b.status <> 'I' ) -- OR (b.status = 'I' AND b.inactive_reason = 'INVALID_ACCOUNT'))
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                      -- AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Ticket#12667
                      -- AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Ticket#12667
                    and b.entity_id <> l_ga_id
            ) loop
                if x.cnt > 0 then
                    l_duplicate_exists := 'Y';
                end if;
                pc_log.log_error('Check_Duplicate_Bank_Account for employee and individual', 'l_duplicate_exists' || l_duplicate_exists
                );
            end loop;
        end if;

        pc_log.log_error('Check_Duplicate_Bank_Account end', 'l_duplicate_exists' || l_duplicate_exists);
        return l_duplicate_exists;
    end check_duplicate_bank_account;

-- Added by Swamy for 10978. 
    function get_giact_verify_response (
        p_gverify       in varchar2,
        p_gauthenticate in varchar2
    ) return varchar2 is
        l_gresult varchar2(100) := '*';
    begin
        pc_log.log_error('get_giact_verify_response', 'p_gVerify '
                                                      || p_gverify
                                                      || ' p_gAuthenticate :='
                                                      || p_gauthenticate);
        for i in (
            select
                gresult
            from
                giact_api_response_code
            where
                    gverify = p_gverify
                and nvl(gauthenticate, '*') = nvl(p_gauthenticate, '*')
        ) loop
            l_gresult := i.gresult;
        end loop;

        pc_log.log_error('get_giact_verify_response', 'l_gRESULT ' || l_gresult);
        return l_gresult;
    end get_giact_verify_response;

-- Added by Swamy for 10978.
    procedure giac_insert_user_bank_acct (
        p_acc_num          in varchar2,
        p_entity_id        in number      -- Added by Swamy for Ticket#12309
        ,
        p_entity_type      in varchar2    -- Added by Swamy for Ticket#12309
        ,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_business_name    in varchar2,
        p_user_id          in number,
        p_gverify          in varchar2,
        p_gauthenticate    in varchar2,
        p_gresponse        in varchar2,
        p_giact_verify     in varchar2,
        p_bank_status      in varchar2,
        p_auto_pay         in varchar2   -- Added by Swamy for Ticket#12309
        ,
        p_bank_acct_usage  in varchar2   -- Added by Swamy for Ticket#12309
        ,
        p_division_code    in varchar2 default null  -- Added by Swamy for Ticket#12309
        ,
        p_source           in varchar2 default null  -- Added by Swamy for Ticket#12362 (12309)
        ,
        x_bank_acct_id     out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        setup_error exception;
        l_acc_id                number;
        l_entity_type           varchar2(100);   -- Added by Swamy for Ticket#10747
        l_broker_id             broker.broker_id%type;
        l_count                 number := 0;
        l_bank_details_exists   varchar2(1);
        l_entity_id             number;
        l_duplicate_bank_exists varchar2(1) := 'N';
        l_account_type          varchar2(100);
        l_giact_verify          varchar2(1) := p_giact_verify;
        l_bank_status           varchar(1) := p_bank_status;
        --giact_response_rejected EXCEPTION;
        l_bank_usage_type       varchar(50);
        lc_bank_usage_type      varchar(50);
        l_entrp_id              number;
        l_ga_id                 number;
        l_active_bank_exists    varchar(50);
        l_check_desc            varchar(50);
        l_check_flag            varchar(50);
        l_pers_id               number;
        l_employer              number;
    begin
        x_return_status := 'S';
        pc_log.log_error('giac_insert_user_bank_acct', 'p_acc_num '
                                                       || p_acc_num
                                                       || ' p_entity_id '
                                                       || p_entity_id
                                                       || 'bank account type '
                                                       || p_bank_acct_type
                                                       || 'p_gVerify :='
                                                       || p_gverify
                                                       || 'p_gAuthenticate :='
                                                       || p_gauthenticate
                                                       || 'p_gresponse :='
                                                       || p_gresponse
                                                       || 'p_giact_verify :='
                                                       || p_giact_verify
                                                       || 'p_bank_status :='
                                                       || p_bank_status
                                                       || 'P_AUTO_PAY :='
                                                       || p_auto_pay
                                                       || ' p_bank_acct_usage :='
                                                       || p_bank_acct_usage
                                                       || ' p_user_id :='
                                                       || p_user_id
                                                       || ' p_source :='
                                                       || p_source
                                                       || ' p_entity_type :='
                                                       || p_entity_type
                                                       || ' p_bank_acct_usage :='
                                                       || p_bank_acct_usage); -- Added by Swamy for Ticket#12309
        if nvl(p_source, '*') not in ( 'R', 'E' ) then
            -- During Broker login from add/update the acc numm will be passed as null.   
            if
                p_entity_type = 'BROKER'
                and nvl(p_acc_num, '*') = '*'
            then
                l_check_flag := p_entity_id;
                l_check_desc := 'Broker ID cannot be Null ';
            elsif
                p_entity_type = 'GA'
                and nvl(p_acc_num, '*') = '*'
            then
                l_check_flag := p_entity_id;
                l_check_desc := 'GA ID cannot be Null ';
            else
                l_check_flag := p_acc_num;
                l_check_desc := 'Account number cannot be Null ';
            end if;
        else
            l_check_flag := p_acc_num;
            l_check_desc := 'Account number cannot be Null ';
            l_entity_id := p_entity_id;
            l_entity_type := p_entity_type;
            l_bank_usage_type := upper(p_bank_acct_usage);
        end if;

        select
            decode(l_check_flag, null, l_check_desc, '1')
            || decode(p_display_name, null, 'Account Name cannot be null', '1')
            || decode(p_bank_acct_type, null, 'Bank Account Type cannot be null', '1')
            || decode(p_bank_routing_num, null, 'Bank Routing number cannot be null', '1')
            || decode(p_bank_acct_num, null, 'Bank Account number cannot be null', '1')
            || decode(p_bank_name, null, 'Bank Name cannot be null', '1')
        into x_error_message
        from
            dual;

        pc_log.log_error('giac_insert_user_bank_acct', 'x_error_message ' || x_error_message);
        if nvl(x_error_message, '1') in ( '1', '111111' ) then
            x_error_message := null;
        else
            raise setup_error;
        end if;

        if nvl(p_source, '*') = 'E' then
            for k in (
                select
                    account_type
                from
                    account
                where
                    acc_num = p_acc_num
            ) loop
                l_account_type := k.account_type;
            end loop;
        end if;

        if nvl(p_source, '*') not in ( 'R', 'E' ) then
        -- Added by Swamy for Ticket#12309 
            for k in (
                select
                    acc_id,
                    broker_id,
                    account_type,
                    entrp_id,
                    ga_id,
                    pers_id
                from
                    account
                where
                    acc_num = p_acc_num
            ) loop
                l_acc_id := k.acc_id;
                l_broker_id := k.broker_id;
                l_account_type := k.account_type;
                l_entrp_id := k.entrp_id;
                l_ga_id := k.ga_id;
                l_pers_id := k.pers_id;
            end loop;

            for k in (
                select
                    user_type
                from
                    online_users
                where
                    user_id = p_user_id
            ) loop
                if nvl(k.user_type, '*') not in ( 'B', 'G' ) then
                    l_entity_id := l_acc_id;
                    l_entity_type := 'ACCOUNT';
                elsif nvl(k.user_type, '*') = 'B' then
                    l_entity_id := nvl(l_broker_id, p_entity_id);
                    l_entity_type := 'BROKER';
                elsif nvl(k.user_type, '*') = 'G' then
                    l_entity_id := nvl(l_ga_id, p_entity_id);
                    l_entity_type := 'GA';
                end if;

                if upper(p_bank_acct_usage) = 'FEE' then
                    l_bank_usage_type := 'INVOICE';
                elsif upper(p_bank_acct_usage) = 'CLAIM' then
                    l_bank_usage_type := 'CLAIMS';
                else
             -- For Employee sidenav add/update bank account, the p_bank_acct_usage will be passed as NULL, and it should be stored as ONLINE.
                    l_bank_usage_type := nvl(
                        upper(p_bank_acct_usage),
                        'ONLINE'
                    );
                end if;

            end loop;

        end if;
        -- FOR HSA individual enrollment, the user in online_user would be created after the insert into bank account table. due to this the above for loop will not execute and 
        -- l_entity_id and l_entity_type will be null during insert into bank accounts.
        if
            l_account_type = 'HSA'
            and nvl(l_entity_id, 0) = 0
        then
            for j in (
                select
                    nvl(entrp_id, 0) entrp_id
                from
                    person
                where
                    pers_id = l_pers_id
            ) loop
                l_employer := j.entrp_id;
            end loop;

            if l_employer = 0 then
                l_entity_id := l_acc_id;
                l_entity_type := 'ACCOUNT';
                l_bank_usage_type := nvl(
                    upper(p_bank_acct_usage),
                    'ONLINE'
                );
            end if;

        end if;

        if (
            nvl(p_gverify, '*') = '*'
            and ( nvl(p_giact_verify, '*') not in ( 'V' ) )
        ) then  -- And cond added for Ticket#12750 Swamy
            x_error_message := 'Please verify the accuracy of the account details. If corrections are needed, Please resubmit the application'
            ;
            raise setup_error;
        end if;

        pc_log.log_error('giac_insert_user_bank_acct', 'bank account type  l_entity_id :='
                                                       || l_entity_id
                                                       || 'l_entity_type :='
                                                       || l_entity_type
                                                       || 'l_Account_type'
                                                       || l_account_type
                                                       || 'p_bank_acct_num :='
                                                       || p_bank_acct_num
                                                       || 'p_bank_routing_num :='
                                                       || p_bank_routing_num
                                                       || 'p_bank_name :='
                                                       || p_bank_name
                                                       || 'p_bank_acct_type :='
                                                       || p_bank_acct_type
                                                       || 'l_acc_id :='
                                                       || l_acc_id);

        pc_user_bank_acct.validate_giac_bank_details(
            p_bank_routing_num      => p_bank_routing_num,
            p_bank_acct_num         => p_bank_acct_num,
            p_bank_acct_id          => null,
            p_bank_name             => p_bank_name,
            p_bank_account_type     => p_bank_acct_type,
            p_acc_id                => l_acc_id,
            p_entrp_id              => l_entrp_id,
            p_ssn                   => null,
            p_entity_type           => l_entity_type,
            p_user_id               => p_user_id,
            p_account_usage         => nvl(l_bank_usage_type, 'ONLINE'),
            p_pay_invoice_online    => 'N',
            p_duplicate_bank_exists => l_duplicate_bank_exists,
            p_bank_details_exists   => l_bank_details_exists,
            p_active_bank_exists    => l_active_bank_exists,
            x_error_message         => x_error_message,
            x_return_status         => x_return_status
        );

        pc_log.log_error('giac_insert_user_bank_acct', 'bank account type  l_bank_details_exists :='
                                                       || l_bank_details_exists
                                                       || 'p_source :='
                                                       || p_source
                                                       || ' l_Account_type :='
                                                       || l_account_type);

        if x_return_status = 'O' then
            raise setup_error;
        elsif l_duplicate_bank_exists = 'Y' then
            raise setup_error;
        elsif l_bank_details_exists in ( 'I', 'D', 'W', 'P' ) then
            raise setup_error;
                -- Only for Side NAV Bank addition the below error should be fired, for enrollment and renewal this error should NOT be fired
        elsif
            l_bank_details_exists = 'E'
            and p_source not in ( 'E', 'R' )
            and l_account_type in ( 'FSA', 'HRA', 'COBRA' )
        then
            raise setup_error;
        end if;

        pc_log.log_error('giac_insert_user_bank_acct', 'INSERT INTO bank_accounts  p_giact_verify :='
                                                       || p_giact_verify
                                                       || 'p_gVerify '
                                                       || p_gverify
                                                       || ' p_gAuthenticate:='
                                                       || p_gauthenticate
                                                       || ' l_giact_verify :='
                                                       || l_giact_verify); 
       -- Resetting the return status
        x_return_status := 'S';
        x_error_message := null;
        if nvl(p_giact_verify, '*') = '*' then
            pc_user_bank_acct.validate_giact_response(
                p_gverify       => p_gverify,
                p_gauthenticate => p_gauthenticate,
                x_giact_verify  => l_giact_verify,
                x_bank_status   => l_bank_status,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            if l_giact_verify = 'R' then
                raise setup_error;
            end if;
        else
            l_bank_status := p_bank_status;
        end if;

        pc_log.log_error('giac_insert_user_bank_acct', ' l_bank_status ' || l_bank_status);
        if nvl(l_giact_verify, '*') <> '*' then
            pc_log.log_error('giac_insert_user_bank_acct', 'INSERT INTO bank_accounts  l_bank_status '
                                                           || l_bank_status
                                                           || ' l_giact_verify :='
                                                           || l_giact_verify
                                                           || ' l_bank_usage_type :='
                                                           || l_bank_usage_type);

            insert into bank_accounts (
                bank_acct_id,
                entity_id,
                entity_type   -- Added by Swamy for Ticket#12309
                ,
                display_name,
                bank_acct_type,
                bank_routing_num,
                bank_acct_num,
                bank_name,
                business_name,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date,
                status,
                giac_response,
                giac_verify,
                giac_authenticate,
                bank_account_usage   -- Added by Swamy for Ticket#12309
            ) values ( user_bank_acct_seq.nextval,
                       l_entity_id       -- Added by Swamy for Ticket#12309   --, L_acc_id
                       ,
                       l_entity_type   -- Added by Swamy for Ticket#12309
                       ,
                       p_display_name,
                       p_bank_acct_type,
                       lpad(p_bank_routing_num, 9, 0),
                       p_bank_acct_num,
                       p_bank_name,
                       p_business_name,
                       p_user_id,
                       p_user_id,
                       sysdate,
                       sysdate,
                       l_bank_status,
                       p_gresponse,
                       p_gverify,
                       p_gauthenticate,
                       l_bank_usage_type ) returning bank_acct_id into x_bank_acct_id;

        --Added by Joshi for #11276
        -- updating all schedulers with new bank account for HSA 
        -- all pending ACH transactions where bank_id is invalid. replace with new bank account.
            for x in (
                select
                    account_type
                from
                    account
                where
                        acc_id = l_acc_id
                    and entrp_id is not null
            ) loop
                pc_log.log_error('giac_insert_user_bank_acct', 'X.ACCOUNT_TYPE := '
                                                               || x.account_type
                                                               || ' x_bank_acct_id :='
                                                               || x_bank_acct_id
                                                               || ' l_bank_status :='
                                                               || l_bank_status
                                                               || ' l_acc_id :='
                                                               || l_acc_id
                                                               || ' p_bank_acct_usage :='
                                                               || p_bank_acct_usage
                                                               || ' P_DIVISION_CODE :='
                                                               || p_division_code
                                                               || ' l_Account_type :='
                                                               || l_account_type);

                if
                    x_bank_acct_id is not null
                    and l_bank_status = 'A'
                then
                    if x.account_type = 'HSA' then
                        for s in (
                            select
                                scheduler_id
                            from
                                scheduler_master
                            where
                                    acc_id = l_acc_id
                                and ( ( recurring_flag = 'N'
                                        and payment_start_date >= trunc(sysdate)
                                        and nvl(status, 'A') in ( 'A', 'P' ) )
                                      or ( recurring_flag = 'Y'
                                           and payment_end_date >= trunc(sysdate)
                                           and nvl(status, 'A') = 'A' ) )
                        ) loop
                            pc_log.log_error('giac_insert_user_bank_acct', 'scheduler_id: ' || s.scheduler_id);
                            update scheduler_master
                            set
                                bank_acct_id = x_bank_acct_id,
                                note = nvl(note, ' ')
                                       || ' Bank account changed online on '
                                       || to_char(sysdate, 'mm/dd/yyyy')
                                       || ' by username '
                                       || pc_users.get_user_name(p_user_id),
                                last_updated_date = sysdate,
                                last_updated_by = p_user_id
                            where
                                    scheduler_id = s.scheduler_id
                                and payment_method = 'ACH'
                                and amount > 0;

                            update ach_transfer
                            set
                                bank_acct_id = x_bank_acct_id,
                                last_update_date = sysdate,
                                last_updated_by = p_user_id
                            where
                                    scheduler_id = s.scheduler_id
                                and status in ( 1, 2 );

                        end loop;

                    elsif x.account_type in ( 'FSA', 'HRA', 'COBRA' ) then
                 -- Invoice_parameters, the invoice type is stored as FEE,CLAIM,FUNDING. but in bank_accounts the bank acct usage is stored as INVOICE,CLAIMS,FUNDING.
                        if upper(l_bank_usage_type) = 'INVOICE' then
                            lc_bank_usage_type := 'FEE';
                        elsif upper(l_bank_usage_type) = 'CLAIMS' then
                            lc_bank_usage_type := 'CLAIM';
                        elsif upper(l_bank_usage_type) = 'FUNDING' then
                            lc_bank_usage_type := 'FUNDING';
                        else
                     -- For Employee sidenav add/update bank account, the p_bank_acct_usage will be passed as NULL, and it should be stored as ONLINE.
                            lc_bank_usage_type := nvl(
                                upper(p_bank_acct_usage),
                                'ONLINE'
                            );
                        end if;

                        update invoice_parameters
                        set
                            payment_method = 'DIRECT_DEPOSIT',
                            autopay = 'Y',
                            bank_acct_id = x_bank_acct_id,
                            last_update_date = sysdate,
                            last_updated_by = p_user_id
                        where
                                entity_type = 'EMPLOYER'
                            and entity_id = l_entrp_id
                            and invoice_type = lc_bank_usage_type
                            and nvl(division_code, '*') = nvl(p_division_code,
                                                              nvl(division_code, '*'))
                            and product_type = l_account_type
                            and status = 'A';

                    end if;

                end if;

            end loop;

        -- Added by Joshi. For QB employee the bank accunt usage should be invoice.
            for x in (
                select
                    acc_id
                from
                    account a,
                    person  p
                where
                        acc_id = l_acc_id
                    and a.pers_id = p.pers_id
                    and a.account_type = 'COBRA'
                    and p.person_type = 'QB'
            ) loop
                pc_log.log_error('giac_insert_user_bank_acct', ' X.ACC_ID := '
                                                               || x.acc_id
                                                               || ' x_bank_acct_id :='
                                                               || x_bank_acct_id
                                                               || ' l_bank_status :='
                                                               || l_bank_status
                                                               || ' X.ACC_ID :='
                                                               || x.acc_id
                                                               || 'x_bank_acct_id :='
                                                               || x_bank_acct_id);

                if
                    x.acc_id is not null
                    and x_bank_acct_id is not null
                    and l_bank_status = 'A'
                then
                    update bank_accounts
                    set
                        bank_account_usage = 'INVOICE'
                    where
                            bank_acct_id = x_bank_acct_id
                        and entity_id = x.acc_id
                        and entity_type = 'ACCOUNT';

                end if;

            end loop;
         -- code ends here by Joshi. For QB employee the bank accunt usage should be invoice.

        end if;

        x_return_status := x_return_status;
        x_error_message := x_error_message;
    exception
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('giac_insert_user_bank_acct exception setup_error', x_error_message);
        when others then
            x_return_status := 'O';
            x_error_message := sqlerrm;
            pc_log.log_error('giac_insert_user_bank_acct', sqlerrm || dbms_utility.format_error_backtrace);
    end giac_insert_user_bank_acct;

-- Added by Swamy for 10978.
    procedure giac_update_user_bank_acct (
        p_bank_acct_id      in out number,
        p_display_name      in varchar2,
        p_bank_routing_num  in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_user_id           in number,
        p_gverify           in varchar2,
        p_gauthenticate     in varchar2,
        p_gresponse         in varchar2,
        p_giact_verify      in varchar2,
        p_bank_status       in varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is

        setup_error exception;
   --l_acc_id               NUMBER;
        l_bank_count            number;
        l_acc_id                user_bank_acct.acc_id%type;  -- Added by Swamy for Ticket#7920
        l_entity_id             bank_accounts.entity_id%type;
        l_pers_id               account.pers_id%type;        -- Added by Swamy for Ticket#7920
        l_bank_name             user_bank_acct.bank_name%type;  -- Added by Swamy for Ticket#7920
        l_user_type             online_users.user_type%type;
        l_entity_type           user_bank_acct.entity_type%type;        -- Added by Jaggi for Ticket#8998
        l_display_name          user_bank_acct.display_name%type;       -- Added by Jaggi for Ticket#8998
        l_bank_acct_type        user_bank_acct.bank_acct_type%type;     -- Added by Jaggi for Ticket#8998
        l_bank_routing_num      user_bank_acct.bank_routing_num%type;   -- Added by Jaggi for Ticket#8998
        l_bank_acct_num         user_bank_acct.bank_acct_num%type;      -- Added by Jaggi for Ticket#8998
        l_bank_entity_type      varchar2(100); -- Added by Swamy for Ticket#10747
        l_bank_details_exists   varchar2(1);
        l_giact_verify          varchar2(1) := p_giact_verify;
        l_bank_status           varchar2(1) := p_bank_status;
        l_duplicate_bank_exists varchar2(10);
        giact_response_rejected exception;
        x_bank_acct_id          number;
    begin
        x_return_status := 'S';
        pc_log.log_error('giac_update_user_bank_acct', 'updating p_bank_acct_id :='
                                                       || p_bank_acct_id
                                                       || ' bank account type '
                                                       || p_bank_account_type
                                                       || 'p_gVerify :='
                                                       || p_gverify
                                                       || 'p_gAuthenticate :='
                                                       || p_gauthenticate);

        if (
            nvl(p_gverify, '*') = '*'
            and ( nvl(p_giact_verify, '*') not in ( 'V' ) )
        ) then  -- And cond added for Ticket#12750 Swamy
            x_error_message := 'Please verify the accuracy of the account details. If corrections are needed, Please resubmit the application'
            ;
            raise setup_error;
        end if;

        for k in (
            select
                entity_id,
                bank_name,
                entity_type,
                display_name,
                bank_acct_type,
                bank_routing_num,
                bank_acct_num
            from
                bank_accounts
            where
                bank_acct_id = p_bank_acct_id
        ) loop
            l_entity_id := k.entity_id;
            l_bank_name := k.bank_name;
            l_display_name := k.display_name;
            l_entity_type := k.entity_type;
            l_bank_acct_type := k.bank_acct_type;
            l_bank_routing_num := k.bank_routing_num;
            l_bank_acct_num := k.bank_acct_num;
        end loop;

        pc_log.log_error('giac_update_user_bank_acct', 'updating l_entity_id :='
                                                       || l_entity_id
                                                       || ' L_bank_name := '
                                                       || l_bank_name
                                                       || 'L_display_Name :='
                                                       || l_display_name
                                                       || 'L_entity_type :='
                                                       || l_entity_type
                                                       || ' L_bank_acct_type :='
                                                       || l_bank_acct_type
                                                       || ' L_bank_routing_num :='
                                                       || l_bank_routing_num
                                                       || 'L_bank_acct_num := '
                                                       || l_bank_acct_num);

        select
            count(*)
        into l_bank_count
        from
            bank_accounts
        where
                bank_routing_num = p_bank_routing_num
            and bank_acct_num = p_bank_acct_num
            and status = 'A'
            and entity_id = l_entity_id
            and entity_type = l_entity_type
            and bank_acct_id <> p_bank_acct_id;

        pc_log.log_error('giac_update_user_bank_acct', 'updating l_bank_count :=' || l_bank_count);
        if l_bank_count > 0 then
            x_error_message := 'Your account already has bank name with same routing number and account number';
            raise setup_error;
        end if;

        -- Check for duplicate bank accounts with other accounts
        l_duplicate_bank_exists := pc_user_bank_acct.check_duplicate_bank_account(
            p_routing_number    => p_bank_routing_num,
            p_bank_acct_num     => p_bank_acct_num,
            p_bank_acct_id      => null,
            p_bank_name         => p_bank_name,
            p_bank_account_type => p_bank_account_type,
            p_acc_id            => l_entity_id,
            p_ssn               => null,
            p_user_id           => p_user_id   -- Added by Swamy for Ticket#12309
        );

        pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details **1.1', 'bank account type  l_duplicate_bank_exists' || l_duplicate_bank_exists
        );
        if l_duplicate_bank_exists = 'Y' then
            x_error_message := 'The bank details already exist in our system. Please enter different bank details to proceed.';
            raise setup_error;
        end if;            

     -- Added by Joshi for 10573
        l_bank_details_exists := validate_bank_info(
            p_entity_id       => l_entity_id,
            p_entity_type     => l_entity_type,
            p_routing_number  => p_bank_routing_num,
            p_bank_acct_num   => p_bank_acct_num,
            p_bank_name       => p_bank_name,
            p_bank_acct_id    => p_bank_acct_id,
            p_bank_acct_usage => 'ONLINE' -- Added by Swamy for Ticket#12309
        );

        pc_log.log_error('giac_update_user_bank_acct', 'updating l_bank_details_exists :=' || l_bank_details_exists);
        if l_bank_details_exists = 'I' then
            x_error_message := 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details'
            ;
            raise setup_error;
        elsif l_bank_details_exists = 'D' then
            x_error_message := 'You already have a Active bank account with the same routing and account numbers setup!';
            raise setup_error;
        elsif l_bank_details_exists = 'W' then
            x_error_message := 'You already have a bank account record pending our review. You are unable to add additional bank accounts until the review process has been completed.'
            ;  -- Ticket#12658
            raise setup_error;
        elsif l_bank_details_exists = 'P' then
            x_error_message := 'You already have a bank account with the same routing and account numbers setup!';
            raise setup_error;
        elsif l_bank_details_exists = 'E' then
            x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.'
            ;
            raise setup_error;
        end if;  

      --added by Jaggi for Ticket ##8998
      --IF LOWER(P_bank_name) <> LOWER(L_bank_name) OR LOWER(P_display_Name) <> LOWER(L_display_Name) OR -- Commented by Ticket#12667 
        if p_bank_account_type <> l_bank_acct_type
        or p_bank_routing_num <> l_bank_routing_num
        or p_bank_acct_num <> l_bank_acct_num then
            pc_log.log_error('giac_update_user_bank_acct', 'l_bank_entity_type '
                                                           || l_bank_entity_type
                                                           || ' p_gVerify :='
                                                           || p_gverify
                                                           || 'p_gAuthenticate :='
                                                           || p_gauthenticate);

            if nvl(p_giact_verify, '*') = '*' then
                pc_user_bank_acct.validate_giact_response(
                    p_gverify       => p_gverify,
                    p_gauthenticate => p_gauthenticate,
                    x_giact_verify  => l_giact_verify,
                    x_bank_status   => l_bank_status,
                    x_return_status => x_return_status,
                    x_error_message => x_error_message
                );

                if l_giact_verify = 'R' then
                    raise giact_response_rejected;
                end if;
            else
                l_bank_status := p_bank_status;
            end if;

            pc_log.log_error('giac_update_user_bank_acct', 'l_giact_verify '
                                                           || l_giact_verify
                                                           || 'l_bank_status :='
                                                           || l_bank_status
                                                           || ' x_return_status :='
                                                           || x_return_status
                                                           || ' x_error_message :='
                                                           || x_error_message);

            if nvl(l_giact_verify, '*') <> '*' then
                pc_log.log_error('giac_update_user_bank_acct updating', 'p_user_id '
                                                                        || p_user_id
                                                                        || ' p_bank_acct_id :='
                                                                        || p_bank_acct_id);
      -- Start Added by Swamy for Ticket#7920(Alert Notification)
                update bank_accounts
                set
                    status = 'I',
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                    bank_acct_id = p_bank_acct_id;

                pc_log.log_error('giac_update_user_bank_acct', 'inserting p_user_id '
                                                               || p_user_id
                                                               || ' p_bank_acct_id :='
                                                               || p_bank_acct_id);
                insert into bank_accounts (
                    bank_acct_id,
                    entity_id,
                    display_name,
                    bank_acct_type,
                    bank_routing_num,
                    bank_acct_num,
                    bank_name,
                    last_updated_by,
                    created_by,
                    last_update_date,
                    creation_date,
                    entity_type   -- Added by Swamy for Ticket#10747
                    ,
                    status,
                    giac_response,
                    giac_verify,
                    giac_authenticate
                ) values ( user_bank_acct_seq.nextval,
                           l_entity_id,
                           p_display_name,
                           p_bank_account_type,
                           lpad(p_bank_routing_num, 9, 0),
                           p_bank_acct_num,
                           p_bank_name,
                           p_user_id,
                           p_user_id,
                           sysdate,
                           sysdate,
                           l_entity_type --l_bank_entity_type   -- Added by Swamy for Ticket#10747
                           ,
                           l_bank_status,
                           p_gresponse,
                           p_gverify,
                           p_gauthenticate ) returning bank_acct_id into x_bank_acct_id;

            end if;

     -- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
     -- Only for Subscriber and bank_account_usage = 'ONLINE' the notification should be triggered.
     -- The default of bank_account_usage is 'ONLINE', so did not use this condition in the below IF statement.
            pc_log.log_error('pc_user_bank_account.giac_update_user_bank_acct l_user_type :=', l_user_type
                                                                                               || ' x_bank_acct_id :='
                                                                                               || x_bank_acct_id);
            if nvl(l_user_type, 'N') = 'S' then
                for j in (
                    select
                        pers_id
                    from
                        account
                    where
                        acc_id = l_acc_id
                ) loop
                    l_pers_id := j.pers_id;
                end loop;

                pc_log.log_error('pc_user_bank_account.giac_update_user_bank_acct pers_id :=', l_pers_id
                                                                                               || 'acc_id := '
                                                                                               || l_acc_id);
                pc_notification2.insert_events(
                    p_acc_id      => l_acc_id,
                    p_pers_id     => l_pers_id,
                    p_event_name  => 'BANK_ACCOUNT',
                    p_entity_type => 'USER_BANK_ACCT',
                    p_entity_id   => l_acc_id,
                    p_ssn         => null
                );

            end if;

        end if;

        p_bank_acct_id := x_bank_acct_id;
    exception
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('giac_update_user_bank_acct setup_error', x_error_message);
        when giact_response_rejected then
            x_return_status := 'E';
            pc_log.log_error('giac_update_user_bank_acct giact_response_rejected', x_error_message);
        when others then
            x_return_status := 'O';
            x_error_message := sqlerrm;
            pc_log.log_error('giac_update_user_bank_acct others', sqlerrm);
    end giac_update_user_bank_acct;

-- Added by Swamy for 10978.
    procedure validate_giact_response (
        p_gverify       in varchar2,
        p_gauthenticate in varchar2,
        x_giact_verify  out varchar2,
        x_bank_status   out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_giact_verify varchar2(10);
        l_bank_status  varchar2(10);
        setup_error exception;
    begin
        pc_log.log_error('pc_user_bank_Acct.validate_giact_response', 'p_gVerify '
                                                                      || p_gverify
                                                                      || ' p_gAuthenticate :='
                                                                      || p_gauthenticate);
        if nvl(p_gverify, '*') = '*' then
            raise setup_error;
        else
            x_return_status := 'S';
            l_giact_verify := pc_user_bank_acct.get_giact_verify_response(p_gverify, p_gauthenticate);
            pc_log.log_error('pc_user_bank_Acct.validate_giact_response', 'l_giact_verify ' || l_giact_verify);
            if l_giact_verify = 'V' then
                pc_log.log_error('validate_giact_response', '**1  ' || x_giact_verify);
           -- A = Active
           -- P = Pending
           -- W = Pending Review
           -- R = Rejected
           -- Q = Pending Review Rejected

                l_bank_status := 'A';
                x_return_status := 'S';
                x_error_message := 'Your bank account has been added successfully!';
            elsif l_giact_verify = 'S' then
                pc_log.log_error('validate_giact_response', '**2  ' || x_giact_verify);
                l_bank_status := 'P';
                x_return_status := 'P';
                x_error_message := 'FURTHER ACTION REQUIRED: We need more information to verify your bank account before you can use it. Please upload the required documents below. Without these documents, you won''t be able to use this bank account with your Sterling account.'
                ;
            elsif l_giact_verify = 'R' then
                pc_log.log_error('validate_giact_response', '**3  ' || x_giact_verify);
                l_bank_status := 'R';
                x_return_status := 'R';
                x_error_message := 'BANK VERIFICATION FAILURE: We were unable to verify your bank account information.Please recheck your entry and confirm the accuracy of your account and routing number directly with your bank.'
                ;  -- Ticket#12658
            else
                raise setup_error;
            end if;

        end if;

        x_giact_verify := l_giact_verify;
        x_bank_status := l_bank_status;
        pc_log.log_error('validate_giact_response', 'x_giact_verify '
                                                    || x_giact_verify
                                                    || ' x_bank_status :='
                                                    || x_bank_status
                                                    || ' l_bank_status :='
                                                    || l_bank_status
                                                    || ' l_giact_verify :='
                                                    || l_giact_verify
                                                    || ' x_return_status :='
                                                    || x_return_status
                                                    || ' x_error_message :='
                                                    || x_error_message);

    exception
        when setup_error then
            x_return_status := 'E';
            x_error_message := 'Please verify the accuracy of the account details. If corrections are needed, Please resubmit the application'
            ;
            pc_log.log_error('validate_giact_response', 'setup_error x_error_message ' || x_error_message);
        when others then
            x_return_status := 'O';
            x_error_message := sqlerrm;
            pc_log.log_error('validate_giact_response', 'OTHERS_error x_error_message ' || sqlerrm);
    end validate_giact_response;

-- Added by Swamy for 10978.
-- Check if any active bank account exists for an individual/employee.
    function check_active_user_bank_acct (
        p_acc_id in number
    ) return number is
        l_bank_acct_id number;
    begin
        for x in (
            select
                bank_acct_id
            from
                user_bank_acct
            where
                    acc_id = p_acc_id
                and status = 'A'
                and rownum = 1
        ) loop
            l_bank_acct_id := x.bank_acct_id;
        end loop;

        pc_log.log_error('check_active_user_bank_acct', 'l_bank_acct_id'
                                                        || l_bank_acct_id
                                                        || ' p_acc_id :='
                                                        || p_acc_id);
        return nvl(l_bank_acct_id, 0);
    end check_active_user_bank_acct;

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    function check_active_employer_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_entrp_id          in number
    ) return varchar2 is

        l_active_exists varchar2(1) := 'N';
        l_ssn           varchar2(100);
        l_account_type  varchar2(100);
        l_entrp_id      number;
        l_pers_id       number;
        l_entrp_code    varchar2(20);
    begin
        pc_log.log_error('check_active_employer_bank_account', 'p_routing_number'
                                                               || p_routing_number
                                                               || ' p_bank_acct_num :='
                                                               || p_bank_acct_num
                                                               || 'p_bank_acct_num :='
                                                               || p_bank_acct_num
                                                               || 'p_bank_acct_id :='
                                                               || p_bank_acct_id
                                                               || 'p_bank_name :='
                                                               || p_bank_name
                                                               || 'p_bank_account_type :='
                                                               || p_bank_account_type
                                                               || 'p_entrp_id:='
                                                               || p_entrp_id);

        l_entrp_code := pc_entrp.get_tax_id(p_entrp_id);
        pc_log.log_error('check_active_employer_bank_account', 'l_entrp_code' || l_entrp_code);
        if nvl(l_entrp_code, 0) <> 0 then
            for x in (
                select
                    count(*) cnt
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A'
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                   --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name))) -- Commented by Ticket#12667 
                   --AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Commented by Ticket#12667  
                    and b.entity_id in (
                        select
                            acc_id
                        from
                            account    ac, enterprise en
                        where
                                ac.entrp_id = en.entrp_id
                            and en.entrp_code = l_entrp_code
                    )
            ) loop
                if x.cnt > 0 then
                    l_active_exists := 'Y';
                end if;
                pc_log.log_error('check_active_employer_bank_account', 'l_active_exists' || l_active_exists);
            end loop;
        end if;

        return l_active_exists;
    end check_active_employer_bank_account;

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    function check_active_employee_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_ssn               in varchar2
    ) return varchar2 is

        l_active_exists varchar2(1) := 'N';
        l_ssn           varchar2(100);
        l_account_type  varchar2(100);
        l_entrp_id      number;
        l_pers_id       number;
        l_entrp_code    varchar2(20);
    begin
        pc_log.log_error('check_active_employer_bank_account', 'p_routing_number'
                                                               || p_routing_number
                                                               || ' p_bank_acct_num :='
                                                               || p_bank_acct_num
                                                               || 'p_bank_acct_num :='
                                                               || p_bank_acct_num
                                                               || 'p_bank_acct_id :='
                                                               || p_bank_acct_id
                                                               || 'p_bank_name :='
                                                               || p_bank_name
                                                               || 'p_bank_account_type :='
                                                               || p_bank_account_type
                                                               || 'p_ssn:='
                                                               || p_ssn);

        pc_log.log_error('check_active_employer_bank_account', 'l_ssn' || l_ssn);
        if nvl(p_ssn, '*') <> '*' then
            for x in (
                select
                    count(*) cnt
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A'
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                   --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667  
                   --AND lower(b.bank_acct_type) = lower(p_bank_account_type)                 -- Commented by Ticket#12667  
                    and b.entity_id in (
                        select
                            acc_id
                        from
                            account ac, person  p
                        where
                                ac.pers_id = p.pers_id
                            and p.ssn = format_ssn(p_ssn)
                    )
            ) loop
                if x.cnt > 0 then
                    l_active_exists := 'Y';
                end if;
                pc_log.log_error('check_active_employer_bank_account', 'l_active_exists' || l_active_exists);
            end loop;
        end if;

        return l_active_exists;
    end check_active_employee_bank_account;

-- Added by Swamy for 10978. 
    function giac_enable_side_navigation (
        p_acc_id in number
    ) return varchar2 is

        l_enable         varchar2(1) := 'N';
        l_account_status number;
        l_bank_status    varchar2(1);
        l_pers_id        number;
        l_entrp_id       number;
        l_account_type   varchar2(100);
    begin
-- Only for individuals the side nav should be display when atleast one bank account is active during enrollment.
-- once the individual account status is active then side nav will be displayed irrespective of the bank account active or not.
-- This logic is applicable only for idividuals. For ER and EE side nav will always be displayed irrespective of bank status.
        for j in (
            select
                account_status,
                pers_id,
                account_type
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_account_status := j.account_status;
            l_pers_id := j.pers_id;
            l_account_type := j.account_type;
        end loop;

        for m in (
            select
                entrp_id
            from
                person
            where
                pers_id = l_pers_id
        ) loop
            l_entrp_id := m.entrp_id;
        end loop;

        if nvl(l_entrp_id, 0) <> 0 then
   --l_enable := 'Y';
   -- Added by Swamy for employer 
            for k in (
                select
                    status
                from
                    bank_accounts
                where
                        entity_id = p_acc_id
                    and status = 'A'
            ) loop
                l_bank_status := k.status;
            end loop;

            if l_account_status = '11' then
                l_enable := 'N';
            else
                l_enable := 'Y';
            end if;

        else
            for k in (
                select
                    status
                from
                    bank_accounts
                where
                        entity_id = p_acc_id
                    and status = 'A'
            ) loop
                l_bank_status := k.status;
            end loop;

   -- For active and Suspended accounts the side nav should be displayed.
   -- Added 2 by Swamy for ticket#12327 18092024
            if l_account_status in ( 1, 2 ) then
                l_enable := 'Y';
            elsif
                l_account_status = 3
                and l_bank_status = 'A'
            then
                l_enable := 'Y';
            else
                l_enable := 'N';
            end if;

        end if;

        return l_enable;
    end giac_enable_side_navigation; 

-- Added by Swamy for 10978. 
    procedure validate_giac_bank_details (
        p_bank_routing_num      in varchar2,
        p_bank_acct_num         in varchar2,
        p_bank_acct_id          in number,
        p_bank_name             in varchar2,
        p_bank_account_type     in varchar2,
        p_acc_id                in number,
        p_entrp_id              in number,
        p_ssn                   in varchar2,
        p_entity_type           in varchar2,
        p_user_id               in number       -- Added by Swamy for Ticket#12309
        ,
        p_account_usage         in varchar2 default null   -- Added by Swamy for Ticket#12309
        ,
        p_pay_invoice_online    in varchar2 default 'N'   -- Added by Swamy for Ticket#12309
        ,
        p_source                in varchar2 default null  -- Added by Swamy for Ticket#12309
        ,
        p_duplicate_bank_exists out varchar2,
        p_bank_details_exists   out varchar2,
        p_active_bank_exists    out varchar2,
        x_error_message         out varchar2,
        x_return_status         out varchar2
    ) is
        setup_error exception;
        l_bank_usage_type      varchar2(100);
        l_is_active_bank_exist varchar2(100);
    begin
        x_return_status := 'S';
        pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details Begin **1', 'bank account type  p_bank_routing_num'
                                                                                   || p_bank_routing_num
                                                                                   || ' p_bank_acct_num :='
                                                                                   || p_bank_acct_num
                                                                                   || 'p_bank_acct_id :='
                                                                                   || p_bank_acct_id
                                                                                   || 'p_bank_name :='
                                                                                   || p_bank_name
                                                                                   || 'p_bank_account_type :='
                                                                                   || p_bank_account_type
                                                                                   || ' p_acc_id :='
                                                                                   || p_acc_id
                                                                                   || 'p_entrp_id :='
                                                                                   || p_entrp_id
                                                                                   || 'p_ssn :='
                                                                                   || p_ssn
                                                                                   || 'p_entity_type :='
                                                                                   || p_entity_type
                                                                                   || 'p_user_id :='
                                                                                   || p_user_id
                                                                                   || 'p_account_usage :='
                                                                                   || p_account_usage);

        if nvl(p_source, '*') in ( 'E', 'R' ) then 
    -- Check if there is already an existing bank account with Active status for the same emplyer/broker/ga
            l_is_active_bank_exist := pc_user_bank_acct.is_active_bank_exist(
                p_entity_type      => p_entity_type,
                p_entity_id        => p_acc_id,
                p_bank_routing_num => p_bank_routing_num,
                p_bank_acct_num    => p_bank_acct_num
            );
        end if;
    -- If there is already active bank existing, then below validation checking is not required.
    -- Ticket#12611
        if nvl(l_is_active_bank_exist, 'N') = 'N' then
            pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details **2', 'p_entrp_id '
                                                                                 || p_entrp_id
                                                                                 || ' p_ssn :='
                                                                                 || p_ssn);
            if p_entity_type in ( 'BROKER', 'GA' ) then
                p_active_bank_exists := pc_user_bank_acct.check_active_broker_ga_bank_account(
                    p_routing_number    => p_bank_routing_num,
                    p_bank_acct_num     => p_bank_acct_num,
                    p_bank_acct_id      => p_bank_acct_id,
                    p_bank_name         => p_bank_name,
                    p_bank_account_type => p_bank_account_type,
                    p_broker_ga_id      => p_acc_id
                );

            elsif p_entity_type = 'ACCOUNT' then
                if
                    nvl(p_entrp_id, 0) <> 0
                    and nvl(p_ssn, '*') = '*'
                then
            	-- For the same tax id check if the given bank account already exists with any other account type with active status, if yes then you can add the bank account to other account type without
                -- validating with giac.Because it is already validated with giac.
                    p_active_bank_exists := pc_user_bank_acct.check_active_employer_bank_account(
                        p_routing_number    => p_bank_routing_num,
                        p_bank_acct_num     => p_bank_acct_num,
                        p_bank_acct_id      => p_bank_acct_id,
                        p_bank_name         => p_bank_name,
                        p_bank_account_type => p_bank_account_type,
                        p_entrp_id          => p_entrp_id
                    );
                end if;

                if
                    nvl(p_entrp_id, 0) = 0
                    and nvl(p_ssn, '*') <> '*'
                then
            	-- For the same ssn check if the given bank account already exists with any other account type with active status, if yes then you can add the bank account to other account type without
                -- validating with giac.Because it is already validated with giac.
                    p_active_bank_exists := pc_user_bank_acct.check_active_employee_bank_account(
                        p_routing_number    => p_bank_routing_num,
                        p_bank_acct_num     => p_bank_acct_num,
                        p_bank_acct_id      => p_bank_acct_id,
                        p_bank_name         => p_bank_name,
                        p_bank_account_type => p_bank_account_type,
                        p_ssn               => p_ssn
                    );

                end if;

            end if;

            pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details **2', 'p_active_bank_exists ' || p_active_bank_exists); 

        -- Check for duplicate bank accounts with other accounts
            p_duplicate_bank_exists := pc_user_bank_acct.check_duplicate_bank_account(
                p_routing_number    => p_bank_routing_num,
                p_bank_acct_num     => p_bank_acct_num,
                p_bank_acct_id      => null,
                p_bank_name         => p_bank_name,
                p_bank_account_type => p_bank_account_type,
                p_acc_id            => p_acc_id,
                p_ssn               => p_ssn,
                p_user_id           => p_user_id   -- Added by Swamy for Ticket#12309
            );

            pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details **1.1', 'bank account type  p_duplicate_bank_exists' || p_duplicate_bank_exists
            );
            if p_duplicate_bank_exists = 'Y' then
                x_error_message := 'The bank details already exist in our system. Please enter different bank details to proceed.';
                raise setup_error;
            end if;            

        -- Check the validations within the same account 
            if upper(p_account_usage) in ( 'FEE', 'ONLINE' ) then
                l_bank_usage_type := 'INVOICE';
            elsif upper(p_account_usage) in ( 'CLAIM' ) then
                l_bank_usage_type := 'CLAIMS';
            else
                l_bank_usage_type := upper(p_account_usage);
            end if;

            pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details Begin **1.1', 'bank account type  p_account_usage'
                                                                                         || p_account_usage
                                                                                         || ' l_bank_usage_type :='
                                                                                         || l_bank_usage_type);
            p_bank_details_exists := pc_user_bank_acct.validate_bank_info(
                p_entity_id       => p_acc_id,
                p_entity_type     => p_entity_type,
                p_routing_number  => p_bank_routing_num,
                p_bank_acct_num   => p_bank_acct_num,
                p_bank_name       => p_bank_name,
                p_bank_acct_id    => null,
                p_bank_acct_usage => nvl(l_bank_usage_type, 'ONLINE') -- Added by Swamy for Ticket#12309
            );

            pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details **2', 'p_bank_details_exists '
                                                                                 || p_bank_details_exists
                                                                                 || ' p_pay_invoice_online :='
                                                                                 || p_pay_invoice_online);
            if p_bank_details_exists = 'I' then
                x_error_message := 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details'
                ;
                raise setup_error;
            elsif
                p_bank_details_exists = 'D'
                and nvl(p_pay_invoice_online, 'N') = 'N'
                and nvl(p_source, '*') not in ( 'E', 'R' )
            then
                x_error_message := 'You already have a Active bank account with the same routing and account numbers setup!';
                raise setup_error;
            elsif
                p_bank_details_exists = 'W'
                and nvl(p_pay_invoice_online, 'N') = 'N'
                and nvl(p_source, '*') not in ( 'E', 'R' )
            then
                x_error_message := 'You already have a bank account record pending our review. You are unable to add additional bank accounts until the review process has been completed.'
                ;  -- Ticket#12658
                raise setup_error;
            elsif
                p_bank_details_exists = 'P'
                and nvl(p_pay_invoice_online, 'N') = 'N'
            then
                x_error_message := 'You already have a bank account with the same routing and account numbers setup!';
                raise setup_error;
            elsif
                p_bank_details_exists = 'E'
                and nvl(p_pay_invoice_online, 'N') = 'N'
                and nvl(p_source, '*') not in ( 'E', 'R' )
            then
                x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.'
                ;
                raise setup_error;
            elsif
                p_bank_details_exists in ( 'E', 'W', 'D' )
                and nvl(p_pay_invoice_online, 'N') = 'N'
                and nvl(p_source, '*') in ( 'E', 'R' )
            then
              -- For all Enrollment and Renewal(employer/broker/ga/broker sso), if there are exisitng bank details in pending review or pending documentation, the system should all the user to 
              -- proceed with the enrollment/renewal.
                p_bank_details_exists := 'N';
            elsif
                p_bank_details_exists in ( 'W', 'D', 'P', 'E' )
                and nvl(p_pay_invoice_online, 'N') = 'Y'
            then
                if p_bank_details_exists = 'W' then
                    x_error_message := 'You already have a bank account record pending our review. You are unable to add additional bank accounts until the review process has been completed.'
                    ;  -- Ticket#12658
                elsif p_bank_details_exists = 'D' then
                    p_bank_details_exists := 'N';
                elsif p_bank_details_exists = 'P' then
                    x_error_message := 'You already have a bank account with the same routing and account numbers setup!';
                elsif p_bank_details_exists = 'E' then
                    x_error_message := 'There is already one bank associated with the same account usage in our system. Please contact us to get more information.'
                    ;
                end if;
            end if;

        else
            p_active_bank_exists := 'Y';
        end if;
/*        pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details **2','p_entrp_id '||p_entrp_id||' p_ssn :='||p_ssn);  
        IF NVL(p_entrp_id,0) <> 0 AND NVL(p_ssn,'*') = '*' THEN
        	-- For the same tax id check if the given bank account already exists with any other account type with active status, if yes then you can add the bank account to other account type without
            -- validating with giac.Because it is already validated with giac.
            p_active_bank_exists := pc_user_bank_Acct.check_active_employer_bank_account
                                                       ( p_routing_number => p_bank_routing_num
                                                       , p_bank_acct_num  => p_bank_acct_num
                                                       , p_bank_acct_id   => p_bank_acct_id
                                                       , p_bank_name      => p_bank_name
                                                       , p_bank_account_type => p_bank_account_type
                                                       , p_entrp_id          => p_entrp_id
                                                       );
        END IF;

        IF NVL(p_entrp_id,0) = 0 AND NVL(p_ssn,'*') <> '*' THEN
        	-- For the same ssn check if the given bank account already exists with any other account type with active status, if yes then you can add the bank account to other account type without
            -- validating with giac.Because it is already validated with giac.
            p_active_bank_exists := pc_user_bank_Acct.check_active_employee_bank_account
                                                       ( p_routing_number => p_bank_routing_num
                                                       , p_bank_acct_num  => p_bank_acct_num
                                                       , p_bank_acct_id   => p_bank_acct_id
                                                       , p_bank_name       => p_bank_name
                                                       , p_bank_account_type => p_bank_account_type
                                                       , p_ssn           => p_ssn
                                                       );
        END IF;
        pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details **2','p_active_bank_exists '||p_active_bank_exists); 
*/


    exception
        when setup_error then
            x_error_message := x_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details exception setup_error ', 'x_error_message ' || x_error_message
            );
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_user_bank_Acct.Validate_giac_bank_details exception others ', 'x_error_message ' || x_error_message)
            ;
    end validate_giac_bank_details;

-- Added by Swamy for Ticket#12309
    function get_bank_acct_id (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_name          in varchar2,
        p_bank_routing_num   in varchar2,
        p_bank_account_usage in varchar2,
        p_bank_acct_type     in varchar2
    ) return number is
        l_bank_acct_id number := 0;
    begin
        for j in (
            select
                bank_acct_id
            from
                bank_accounts
            where
                    bank_routing_num = p_bank_routing_num
                and bank_acct_num = p_bank_acct_num
              --AND LOWER(bank_name)          = LOWER(p_bank_name)
                and status in ( 'A', 'P', 'W' )
                and entity_id = p_entity_id
                and lower(entity_type) = lower(p_entity_type)
                and lower(bank_account_usage) = lower(nvl(p_bank_account_usage, bank_account_usage))
              --AND LOWER(bank_acct_type)     = LOWER(p_bank_acct_type)
            order by
                bank_acct_id
        ) loop
            l_bank_acct_id := j.bank_acct_id;
        end loop;

        return nvl(l_bank_acct_id, 0);
    end get_bank_acct_id;

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    procedure get_active_employer_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_entrp_id          in number,
        x_gverify           out varchar2,
        x_gauthenticate     out varchar2,
        x_gresponse         out varchar2,
        x_bank_acct_id      out number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is
        l_entrp_id   number;
        l_entrp_code varchar2(20);
    begin
        pc_log.log_error('get_active_employer_bank_account', 'p_routing_number'
                                                             || p_routing_number
                                                             || ' p_bank_acct_num :='
                                                             || p_bank_acct_num
                                                             || 'p_bank_acct_num :='
                                                             || p_bank_acct_num
                                                             || 'p_bank_acct_id :='
                                                             || p_bank_acct_id
                                                             || 'p_bank_name :='
                                                             || p_bank_name
                                                             || 'p_bank_account_type :='
                                                             || p_bank_account_type
                                                             || 'p_entrp_id:='
                                                             || p_entrp_id);

        x_return_status := 'S';
        l_entrp_code := pc_entrp.get_tax_id(p_entrp_id);
        pc_log.log_error('get_active_employer_bank_account', 'l_entrp_code' || l_entrp_code);
        if nvl(l_entrp_code, 0) <> 0 then
            for x in (
                select
                    bank_acct_id,
                    giac_verify,
                    giac_authenticate,
                    giac_response
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A'
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
					  -- AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667 
					  -- AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Commented by Ticket#12667 
                    and nvl(giac_verify, '*') <> '*'
                    and b.entity_id in (
                        select
                            acc_id
                        from
                            account    ac, enterprise en
                        where
                                ac.entrp_id = en.entrp_id
                            and en.entrp_code = l_entrp_code
                    )
            ) loop
                if x.bank_acct_id > 0 then
                    x_bank_acct_id := x.bank_acct_id;
                    x_gverify := x.giac_verify;
                    x_gauthenticate := x.giac_authenticate;
                    x_gresponse := x.giac_response;
                end if;

                pc_log.log_error('get_active_employer_bank_account', 'x_bank_acct_id'
                                                                     || x_bank_acct_id
                                                                     || ' x_gVerify :='
                                                                     || x_gverify
                                                                     || 'x_gAuthenticate :='
                                                                     || x_gauthenticate);

            end loop;
        end if;

    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_user_bank_Acct.get_active_employer_bank_account exception others ', 'x_error_message ' || x_error_message
            );
    end get_active_employer_bank_account;

-- Added by Swamy for 10978. 
-- For the same tax id(entrp code), check if for the same tax id, if any product has the same active bank account ,if yes then it should not go to giact.It should directly add the account,
-- bcos if the account is already verified by giact and is active then rechecking the same bank details will cost double for sterling.in order to avoid this we need directly add the account without sending to giact.
    procedure get_active_employee_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_ssn               in varchar2,
        x_gverify           out varchar2,
        x_gauthenticate     out varchar2,
        x_gresponse         out varchar2,
        x_bank_acct_id      out number,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is
    begin
        pc_log.log_error('get_active_employee_bank_account', 'p_routing_number'
                                                             || p_routing_number
                                                             || 'p_ssn'
                                                             || p_ssn
                                                             || ' p_bank_acct_num :='
                                                             || p_bank_acct_num
                                                             || 'p_bank_acct_num :='
                                                             || p_bank_acct_num
                                                             || 'p_bank_acct_id :='
                                                             || p_bank_acct_id
                                                             || 'p_bank_name :='
                                                             || p_bank_name
                                                             || 'p_bank_account_type :='
                                                             || p_bank_account_type
                                                             || 'p_ssn:='
                                                             || p_ssn);

        if nvl(p_ssn, '*') <> '*' then
            for x in (
                select
                    bank_acct_id,
                    giac_verify,
                    giac_authenticate,
                    giac_response
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A'
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
					   --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667 
					   --AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Commented by Ticket#12667 
                    and nvl(giac_verify, '*') <> '*'
                    and b.entity_id in (
                        select
                            acc_id
                        from
                            account ac, person  p
                        where
                                ac.pers_id = p.pers_id
                            and p.ssn = format_ssn(p_ssn)
                    )
            ) loop
                if x.bank_acct_id > 0 then
                    x_bank_acct_id := x.bank_acct_id;
                    x_gverify := x.giac_verify;
                    x_gauthenticate := x.giac_authenticate;
                    x_gresponse := x.giac_response;
                end if;

                pc_log.log_error('get_active_employee_bank_account', 'x_bank_acct_id'
                                                                     || x_bank_acct_id
                                                                     || ' x_gVerify :='
                                                                     || x_gverify
                                                                     || 'x_gAuthenticate :='
                                                                     || x_gauthenticate);

            end loop;

        end if;

    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_user_bank_Acct.get_active_employee_bank_account exception others ', 'x_error_message ' || x_error_message
            );
    end get_active_employee_bank_account;

-- Added by Joshi for 6322
-- This function is used for getting bank details/rate plan association for employer. called from website
    function get_existing_bank_details (
        p_entity_id    in number,
        p_entity_type  in varchar2,
        p_invoice_type in varchar2 default null
    ) return fhra_bank_record_t
        pipelined
        deterministic
    is
        l_record       fhra_bank_record_row_t;
        l_account_type varchar2(100);
    begin
        pc_log.log_error('pc_user_bank_Acct.get_fhra_Bank_Details', 'P_ENTITY_TYPE: '
                                                                    || p_entity_type
                                                                    || ' P_entity_id :='
                                                                    || p_entity_id
                                                                    || 'P_INVOICE_TYPE :='
                                                                    || p_invoice_type);

-- Added by Joshi for 9412
        if p_entity_type = 'ACCOUNT' then

 -- Added by Joshi for 9515
            select
                account_type
            into l_account_type
            from
                account
            where
                acc_id = p_entity_id;

            if l_account_type in ( 'FSA', 'HRA' ) then
                for c1 in (
                    select
                        u.display_name,
                        u.bank_routing_num,
                        u.bank_acct_num,
                        u.bank_acct_type,
                        pc_lookups.get_meaning(u.bank_acct_type, 'BANK_ACCOUNT_TYPE') bank_acct_type_name,
                        a.account_type,
                        u.bank_acct_id,
                        a.acc_id,
                        a.acc_num,
                        u.bank_account_usage,
                        u.status,
                        u.giac_verify,
                        u.business_name
                    from
                        user_bank_acct u,
                        account        a
                    where
                            a.acc_id = u.acc_id
                        and u.status = 'A'
                        and u.bank_account_usage = decode(p_invoice_type, 'CLAIM', 'CLAIMS', 'FEE', 'INVOICE',
                                                          p_invoice_type)
                        and a.acc_id = p_entity_id
                ) loop
                    l_record.bank_acc_id := c1.bank_acct_id;
                    l_record.acc_id := c1.acc_id;
                    l_record.acc_num := c1.acc_num;
                    l_record.display_name := c1.display_name;
                    l_record.bank_acct_type := c1.bank_acct_type;
                    l_record.bank_acct_type_name := c1.bank_acct_type_name;
                    l_record.account_type := c1.account_type;
                    l_record.bank_acct_num := c1.bank_acct_num;
                    l_record.bank_routing_num := c1.bank_routing_num;
                    l_record.bank_account_usage := c1.bank_account_usage; -- added by Jaggi #11617
                    l_record.bank_status := c1.status;          -- Added by Swamy for Ticket#12309
                    l_record.status_description := pc_lookups.get_meaning(c1.status, 'STATUS');   -- Added by Swamy for Ticket#12309
                    l_record.business_name := c1.business_name;
                    pipe row ( l_record );
                end loop;

            else
                for ba in (
                    select
                        *
                    from
                        bank_accounts
                    where
                            entity_id = p_entity_id
                        and entity_type = p_entity_type
                        and status = 'A'
                        and bank_account_usage in ( 'ONLINE', 'INVOICE', 'COBRA_DISBURSE' )
                ) loop
                    l_record.bank_acc_id := ba.bank_acct_id;
                    l_record.acc_id := ba.entity_id;
                    l_record.acc_num := null;
                    l_record.display_name := ba.display_name;
                    l_record.bank_acct_type := ba.bank_acct_type;
                    l_record.bank_acct_type_name := null;
                    l_record.account_type := ba.entity_type;
                    l_record.bank_acct_num := ba.bank_acct_num;
                    l_record.bank_routing_num := ba.bank_routing_num;
                    l_record.bank_account_usage := ba.bank_account_usage;
                    l_record.bank_account_usage_display := pc_lookups.get_meaning(ba.bank_account_usage, 'BANK_ACCOUNT_USAGE');
                    l_record.division_code := null;
                    l_record.division_name := null;
                    l_record.invoice_param_id := null;
                    l_record.bank_status := ba.status;          -- Added by Swamy for Ticket#12309
                    l_record.status_description := pc_lookups.get_meaning(ba.status, 'STATUS');   -- Added by Swamy for Ticket#12309
                    l_record.giac_verify := ba.giac_verify;   -- Added by Swamy for Ticket#12309
                    l_record.business_name := ba.business_name;
                    pipe row ( l_record );
                end loop;
            end if;

        else
   -- Added by Joshi for 9412
            for ba in (
                select
                    *
                from
                    bank_accounts
                where
                        entity_id = p_entity_id
                    and entity_type = p_entity_type
                    and status = 'A'
            ) loop
                l_record.bank_acc_id := ba.bank_acct_id;
                l_record.acc_id := null;
                l_record.acc_num := null;
                l_record.display_name := ba.display_name;
                l_record.bank_acct_type := ba.bank_acct_type;
                l_record.bank_acct_type_name := null;
                l_record.account_type := ba.entity_type;
                l_record.bank_acct_num := ba.bank_acct_num;
                l_record.bank_routing_num := ba.bank_routing_num;
                l_record.bank_account_usage := ba.bank_account_usage; -- added by Jaggi #11617
                l_record.division_code := null;
                l_record.division_name := null;
                l_record.invoice_param_id := null;
                l_record.bank_status := ba.status;          -- Added by Swamy for Ticket#12309
                l_record.status_description := pc_lookups.get_meaning(ba.status, 'STATUS');   -- Added by Swamy for Ticket#12309
                l_record.giac_verify := ba.giac_verify;   -- Added by Swamy for Ticket#12309
                l_record.business_name := ba.business_name;
                pipe row ( l_record );
            end loop;
        end if;

    end get_existing_bank_details;

-- Added by Swamy for Ticket#12309
-- For Pay Now Invoice, the all the Pay now button should be disabled for the employer
-- if there is any pending review/pending documentation status.
    function check_pending_bank_exisits (
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_account_usage in varchar2
    ) return varchar2 is
        l_pending_exists varchar2(10) := 'N';
    begin
        for x in (
            select
                'Y' pending_exists
            from
                bank_accounts
            where
                    entity_id = p_entity_id
                and status in ( 'P', 'W' )
                and entity_type = p_entity_type
                and bank_account_usage = p_bank_account_usage
        ) loop
            l_pending_exists := x.pending_exists;
        end loop;

        pc_log.log_error('check_pending_bank_exisits', 'l_pending_exists'
                                                       || l_pending_exists
                                                       || ' p_entity_id :='
                                                       || p_entity_id
                                                       || ' p_entity_type :='
                                                       || p_entity_type
                                                       || ' p_bank_account_usage :='
                                                       || p_bank_account_usage);

        return nvl(l_pending_exists, 'N');
    end check_pending_bank_exisits;

-- Added by Swamy for Ticket#12534 
    procedure insert_user_bank_acct_staging (
        p_user_bank_acct_stg_id  in number,
        p_entrp_id               in number,
        p_batch_number           in number,
        p_account_type           in varchar2,
        p_acct_usage             in varchar2,
        p_display_name           in varchar2,
        p_bank_acct_type         in varchar2,
        p_bank_routing_num       in varchar2,
        p_bank_acct_num          in varchar2,
        p_bank_name              in varchar2,
        p_validity               in varchar2,
        p_bank_authorize         in varchar2,
        p_user_id                in number,
        p_entity_type            in varchar2,
        p_giac_response          in varchar2,
        p_giac_verify            in varchar2,
        p_giac_authenticate      in varchar2,
        p_bank_acct_verified     in varchar2,
        p_bank_status            in varchar2,
        p_business_name          in varchar2,
        p_giac_verified_response in varchar2,
        p_annual_optional_remit  in varchar2,
        x_user_bank_acct_stg_id  out number,
        x_error_status           out varchar2,
        x_error_message          out varchar2
    ) is
        l_user_bank_acct_stg_id number;
        l_renewed_by            varchar2(100);
    begin
        if p_user_bank_acct_stg_id is not null then
            delete from user_bank_acct_staging
            where
                    user_bank_acct_stg_id = p_user_bank_acct_stg_id
                and p_entrp_id = p_entrp_id
                and p_batch_number = p_batch_number;

        end if;

        l_renewed_by := pc_users.get_user_type(p_user_id);
        if l_renewed_by = 'E' then
            l_renewed_by := 'EMPLOYER';
        elsif l_renewed_by = 'B' then
            l_renewed_by := 'BROKER';
        elsif l_renewed_by = 'G' then
            l_renewed_by := 'GA';
        end if;

        select
            user_bank_acct_stg_seq.nextval
        into l_user_bank_acct_stg_id
        from
            dual;

        insert into user_bank_acct_staging (
            user_bank_acct_stg_id,
            entrp_id,
            batch_number,
            account_type,
            acct_usage,
            display_name,
            bank_acct_type,
            bank_routing_num,
            bank_acct_num,
            bank_name,
            validity,
            bank_authorize,
            created_by,
            creation_date,
            renewed_by,
            giac_response,
            giac_verify,
            giac_authenticate,
            bank_acct_verified,
            bank_status,
            business_name,
            giac_verified_response,
            annual_optional_remit
        ) values ( l_user_bank_acct_stg_id,
                   p_entrp_id,
                   p_batch_number,
                   p_account_type,
                   p_acct_usage,
                   p_display_name,
                   p_bank_acct_type,
                   p_bank_routing_num,
                   p_bank_acct_num,
                   p_bank_name,
                   p_validity,
                   p_bank_authorize,
                   p_user_id,
                   sysdate,
                   l_renewed_by,
                   p_giac_response,
                   p_giac_verify,
                   p_giac_authenticate,
                   p_bank_acct_verified,
                   p_bank_status,
                   p_business_name,
                   p_giac_verified_response,
                   p_annual_optional_remit );

        x_user_bank_acct_stg_id := l_user_bank_acct_stg_id;
        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'U';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('pc_user_bank_acct.insert_user_bank_acct_staging', sqlerrm || dbms_utility.format_error_backtrace);
    end insert_user_bank_acct_staging;

    procedure giact_manage_bank_account (
        p_bank_status     in varchar2,
        p_entity_type     in varchar2,
        p_entity_id       in number,
        p_bank_acct_id    in number,
        p_inactive_reason in varchar2,
        p_user_id         in number,
        x_error_status    out varchar2,
        x_error_message   out varchar2
    ) is

        x_notification_id         number;
        l_acc_id                  number := p_entity_id;
        l_transaction_id          number;
        l_user_id                 number := p_user_id;
        l_return_status           varchar2(100);
        l_ach_exists              varchar2(1) := 'N';
        l_entrp_id                number;
        l_account_status          number;
        l_account_type            varchar2(100);
        v_account_status          varchar2(100);
        l_pending_bank_count      number;
        l_broker_id               number;
        l_ga_id                   number;
        l_batch_no                number;
        l_person_type             varchar2(50);
        l_employer_pending_status varchar2(100) := 'N';
        l_create_error exception;
    begin
        if
            p_bank_status in ( 'A', 'I', 'P' )
            and p_entity_type = 'ACCOUNT'
        then
            l_entrp_id := 0;
            l_account_status := 0;
    -- Check for employees
            for n in (
                select
                    a.entrp_id,
                    a.account_status,
                    a.account_type,
                    a.broker_id,
                    a.ga_id
                from
                    account a
                where
                    acc_id = l_acc_id
            ) loop
                l_entrp_id := n.entrp_id;
                l_account_status := n.account_status;
                l_account_type := n.account_type;
                l_broker_id := n.broker_id;
                l_ga_id := n.ga_id;
            end loop;

            if nvl(l_entrp_id, 0) = 0 then
        -- Check for employees
                for m in (
                    select
                        a.entrp_id,
                        p.person_type
                    from
                        account a,
                        person  p
                    where
                            acc_id = l_acc_id
                        and a.pers_id = p.pers_id
                ) loop
                    l_entrp_id := m.entrp_id;
                    l_person_type := m.person_type;
                end loop;
            end if;

   -- For HSA Only for Individuals the account status should change to Pending bank verification, not applicable for employer and employee
   -- For FSA/HRA its applicable for employer and employee
            if nvl(l_account_status, 0) <> 1 then
                v_account_status := l_account_status;
                if (
                    l_account_type = 'HSA'
                    and nvl(l_entrp_id, 0) = 0
                ) then
                    v_account_status := '3';
                elsif ( l_account_type in ( 'HRA', 'FSA', 'COBRA', 'FORM_5500', 'POP',
                                            'ERISA_WRAP' ) ) then  -- POP added 12675 -- FORM_5500 Added by Swamy for Ticket#12527
          -- For FSA/HRA, no bank accounts should be in pending status for the Account status to be pending activation.
          -- If there are pending bank accounts then the account status will be in pending bank verification (11)
                    for j in (
                        select
                            count(*) cnt
                        from
                            bank_accounts
                        where
                                entity_id = l_acc_id
                            and status in ( 'P', 'W' )
                    ) loop
                        l_pending_bank_count := j.cnt;
                    end loop;

                    l_batch_no := null;
                    l_employer_pending_status := 'N';
           -- If user is activating the employer account, but if there is any broker/ga associated to the account is having bank status in 'P','W'
           -- Then account status should not become Active, it should be in pending bank verification.
                    if
                        l_pending_bank_count = 0
                        and nvl(l_entrp_id, 0) <> 0
                    then
                        for b in (
                            select
                                batch_number
                            from
                                user_bank_acct_staging
                            where
                                bank_acct_id = p_bank_acct_id
                        ) loop
                            l_batch_no := b.batch_number;
                        end loop;               
               -- Need to get entrp_id so using User_Bank_Acct_Staging instead of bank_Accounts table
                        for j in (
                            select
                                'Y' flg_exists
                            from
                                user_bank_acct_staging ub,
                                bank_accounts          ba
                            where
                                    ub.batch_number = l_batch_no
                                and ub.entrp_id = l_entrp_id
                                and ub.bank_acct_id = ba.bank_acct_id
                                and ba.status in ( 'P', 'W' )
                        ) loop
                            l_employer_pending_status := j.flg_exists;
                        end loop;

                    end if;

                    if
                        l_pending_bank_count = 0
                        and nvl(l_employer_pending_status, 'N') = 'N'
                    then
                        v_account_status := '3';
                    end if;

                end if;
       -- If bank status in Active/Inactive the account status should change to Pending Activation if the account status = 11 (Pending Bank Verification)
                if
                    p_bank_status in ( 'A', 'I' )
                    and v_account_status = '3'
                then
                    update account
                    set
                        account_status = v_account_status
                    where
                            acc_id = l_acc_id
                        and account_status = '11';

                end if;

            end if;

            pc_log.log_error('p_bank_status', p_bank_status
                                              || ' p_bank_status :='
                                              || p_bank_status
                                              || 'l_acc_id :='
                                              || l_acc_id
                                              || ' l_account_type :='
                                              || l_account_type);

    -- Added by Joshi for 12396. if bank account is inactivated from GIAC reminder then notification should not be sent.
            if nvl(p_inactive_reason, '*') not in ( 'SYSTEM_INACTIVATED' ) then
                pc_notifications.bank_email_notifications(
                    p_bank_acct_id    => p_bank_acct_id,
                    p_bank_status     => p_bank_status,
                    p_entity_type     => p_entity_type,
                    p_entity_id       => p_entity_id,
                    p_denial_reason   => p_inactive_reason,
                    p_user_id         => l_user_id,
                    x_notification_id => x_notification_id
                );
            end if;

            pc_log.log_error('l_acc_id', l_acc_id
                                         || ':P_BANK_ACCT_ID :='
                                         || p_bank_acct_id);
            if
                p_bank_status in ( 'A', 'I' )
                and p_entity_type = 'ACCOUNT'
            then
                if p_bank_status = 'I' then
                    pc_log.log_error('Manage bank account screen, call cancel_invalid_bank_txns', p_bank_acct_id);
                    pc_claim.cancel_invalid_bank_txns(p_bank_acct_id,
                                                      'Denied because of invalid bank account ' || to_char(sysdate, 'mm/dd/yyyy'),
                                                      l_user_id);

                elsif p_bank_status = 'A' then
                    for j in (
                        select
                            a.transaction_id,
                            a.invoice_id
                        from
                            ach_transfer a,
                            ar_invoice   r
                        where
                                a.status = '6'
                            and r.status = 'IN_PROCESS'
                            and a.invoice_id = r.invoice_id
                    ) loop
                        update ach_transfer
                        set
                            status = '2'
                        where
                                status = '6'
                            and bank_acct_id = p_bank_acct_id
                            and transaction_id = j.transaction_id;

                        pc_log.log_error('Manage bank account screen, **1 l_person_type', l_person_type);
                        if nvl(l_person_type, '*') <> 'QB' then
                            update ar_invoice_lines
                            set
                                status = 'PROCESSED'
                            where
                                invoice_id = j.invoice_id;

                            update ar_invoice
                            set
                                status = 'PROCESSED'
                            where
                                    bank_acct_id = p_bank_acct_id
                                and invoice_id = j.invoice_id
                                and upper(status) = 'IN_PROCESS';

                        end if;

                    end loop;

                    for m in (
                        select
                            'Y'
                        from
                            ach_transfer
                        where
                                acc_id = l_acc_id
                            and transaction_type = 'C'
                            and reason_code = 3
                            and status <> 9
                    ) loop
                        l_ach_exists := 'Y';
                    end loop;

                    if l_ach_exists = 'N' then
                        for x in (
                            select
                                e.er_contribution,
                                e.ee_contribution,
                                e.er_fee_contribution,
                                e.ee_fee_contribution,
                                a.start_date,
                                e.health_plan_eff_date
                            from
                                online_enrollment e,
                                account           a
                            where
                                    e.acc_id = l_acc_id
                                and a.acc_id = e.acc_id
                        ) loop
                            if nvl(x.er_contribution, 0) + nvl(x.ee_contribution, 0) + nvl(x.er_fee_contribution, 0) + nvl(x.ee_fee_contribution
                            , 0) > 0 then
                                pc_ach_transfer.ins_ach_transfer(
                                    p_acc_id           => l_acc_id,
                                    p_bank_acct_id     => p_bank_acct_id,
                                    p_transaction_type => 'C',
                                    p_amount           => nvl(x.er_contribution, 0) + nvl(x.ee_contribution, 0),
                                    p_fee_amount       => nvl(x.er_fee_contribution, 0) + nvl(x.ee_fee_contribution, 0),
                                    p_transaction_date => greatest(
                                        nvl(x.start_date, x.health_plan_eff_date),
                                        sysdate
                                    ),
                                    p_reason_code      => 3 -- initial contribution
                                    ,
                                    p_status           => 1 -- Pending
                                    ,
                                    p_user_id          => l_user_id,
                                    x_transaction_id   => l_transaction_id,
                                    x_return_status    => l_return_status,
                                    x_error_message    => x_error_message
                                );

                                pc_log.log_error('l_transaction_id', l_transaction_id
                                                                     || 'P_BANK_ACCT_ID :='
                                                                     || p_bank_acct_id);
                                if l_return_status <> 'S' then
                                    raise l_create_error;
                                end if;
                            end if;
                        end loop;
                    end if;

                end if;
            end if;

        elsif
            p_bank_status in ( 'A', 'I', 'P' )
            and p_entity_type in ( 'BROKER', 'GA' )
        then
       -- FOR FSA/HRA there is no broker enrollments.
            pc_log.log_error('broker page p_bank_status', p_bank_status
                                                          || 'P_ENTITY_TYPE :='
                                                          || p_entity_type
                                                          || ' P_BANK_ACCT_ID :='
                                                          || p_bank_acct_id);

            pc_log.log_error('** BROKER p_bank_status', p_bank_status
                                                        || ' p_bank_status :='
                                                        || p_bank_status
                                                        || 'l_acc_id :='
                                                        || l_acc_id
                                                        || ' l_account_type :='
                                                        || l_account_type);
     -- Need to get entrp_id so using User_Bank_Acct_Staging instead of bank_Accounts table
            for j in (
                select
                    entrp_id
                from
                    user_bank_acct_staging
                where
                    bank_acct_id = p_bank_acct_id
            ) loop
        -- If bank status in Active/Inactive the account status should change to Pending Activation if the account status = 11 (Pending Bank Verification)
                if p_bank_status in ( 'A', 'I' ) then
           -- Check for employer which is associated to the broker/ga, if any penk is in pending?, if it is in pending then the account status should not be active.
                    for k in (
                        select
                            'Y' flg_exists
                        from
                            bank_accounts
                        where
                                entity_id = pc_entrp.get_acc_id(j.entrp_id)
                            and status in ( 'P', 'W' )
                    ) loop
                        l_employer_pending_status := k.flg_exists;
                    end loop;

                    pc_log.log_error('** BROKER l_employer_pending_status', l_employer_pending_status
                                                                            || ' j.entrp_id :='
                                                                            || j.entrp_id);
                    update account
                    set
                        account_status = '3'
                    where
                            entrp_id = j.entrp_id
                        and account_status = '11'
                        and nvl(l_employer_pending_status, 'N') = 'N';

                end if;
            end loop;

            if p_bank_status = 'I' then   -- Added by Swamy for Ticket#12557
                pc_log.log_error('Manage bank account screen, call cancel_invalid_bank_txns', p_bank_acct_id);
                pc_claim.cancel_invalid_bank_txns(p_bank_acct_id,
                                                  'Denied because of invalid bank account ' || to_char(sysdate, 'mm/dd/yyyy'),
                                                  l_user_id);

            elsif p_bank_status = 'A' then
                for a in (
                    select
                        a.transaction_id,
                        a.invoice_id
                    from
                        ach_transfer a,
                        ar_invoice   r
                    where
                            a.status = '6'
                        and r.status = 'IN_PROCESS'
                        and a.invoice_id = r.invoice_id
                        and a.bank_acct_id = p_bank_acct_id
                ) loop
                    update ach_transfer
                    set
                        status = '2'
                    where
                            status = '6'
                        and bank_acct_id = p_bank_acct_id
                        and transaction_id = a.transaction_id;

                    update ar_invoice_lines
                    set
                        status = 'PROCESSED'
                    where
                        invoice_id = a.invoice_id;

                    update ar_invoice
                    set
                        status = 'PROCESSED'
                    where
                            bank_acct_id = p_bank_acct_id
                        and invoice_id = a.invoice_id
                        and bank_acct_id = p_bank_acct_id
                        and upper(status) = 'IN_PROCESS';

                end loop;
            end if;
    -- Added by Joshi for 12396. if bank account is inactivated from GIAC reminder then notification should not be sent.
            if nvl(p_inactive_reason, '*') not in ( 'SYSTEM_INACTIVATED' ) then
                pc_notifications.bank_email_notifications(
                    p_bank_acct_id    => p_bank_acct_id,
                    p_bank_status     => p_bank_status,
                    p_entity_type     => p_entity_type,
                    p_entity_id       => p_entity_id,
                    p_denial_reason   => p_inactive_reason,
                    p_user_id         => l_user_id,
                    x_notification_id => x_notification_id
                );
            end if;

        end if;
    exception
        when l_create_error then
            x_error_status := 'E';    -- Added by Swamy for Ticket#12534 
            x_error_message := x_error_message;   -- Added by Swamy for Ticket#12534 
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
    end giact_manage_bank_account;

-- Added by Swamy for Ticket#12534 
-- Used in ADD/UPDATE module for employer and employee
    procedure giact_insert_bank_account (
        p_entity_id             in number,
        p_entity_type           in varchar2,
        p_display_name          in varchar2,
        p_bank_acct_type        in varchar2,
        p_bank_routing_num      in varchar2,
        p_bank_acct_num         in varchar2,
        p_bank_name             in varchar2,
        p_bank_account_usage    in varchar2 default 'ONLINE',
        p_user_id               in number,
        p_bank_status           in varchar2,
        p_giac_verify           in varchar2,
        p_giac_authenticate     in varchar2,
        p_giac_response         in varchar2,
        p_business_name         in varchar2,
        p_bank_acct_verified    in varchar2,
        p_existing_bank_account in varchar2,
        x_bank_status           out varchar2,
        x_bank_acct_id          out number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    ) is

        l_bank_status   varchar2(10);
        l_giact_verify  varchar2(10);
        l_return_status varchar2(10);
        l_error_message varchar2(500);
        setup_error exception;
    begin
    -- FOr cobra employee,in add/update bank account module the p_bank_status is passed as null.
    -- If user is already adding an existing active bank, then p_bank_status is A
    -- if no bank_status is provided then derive the bank status
        if nvl(p_bank_status, '*') <> '*' then
            l_bank_status := p_bank_status;
        elsif nvl(p_existing_bank_account, '*') = 'Y' then
            l_bank_status := 'A';
        elsif nvl(p_bank_status, '*') = '*' then
            pc_user_bank_acct.validate_giact_response(
                p_gverify       => p_giac_verify,
                p_gauthenticate => p_giac_authenticate,
                x_giact_verify  => l_giact_verify,
                x_bank_status   => l_bank_status,
                x_return_status => l_return_status,
                x_error_message => l_error_message
            );

            if l_giact_verify = 'R' then
                raise setup_error;
            end if;
        end if;

        pc_log.log_error('pc_user_bank_acct.giact_insert_bank_account INSERT INTO bank_accounts p_existing_bank_Account ', p_existing_bank_account
                                                                                                                           || ' l_bank_status :='
                                                                                                                           || l_bank_status
                                                                                                                           || ' p_bank_status :='
                                                                                                                           || p_bank_status
                                                                                                                           );

        pc_log.log_error('pc_user_bank_acct.giact_insert_bank_account INSERT INTO bank_accounts p_entity_id ', p_entity_id
                                                                                                               || ' p_giac_verify :='
                                                                                                               || p_giac_verify
                                                                                                               || ' p_giac_authenticate :='
                                                                                                               || p_giac_authenticate
                                                                                                               || 'p_giac_response :='
                                                                                                               || p_giac_response
                                                                                                               || ' x_bank_status :='
                                                                                                               || x_bank_status);

        insert into bank_accounts (
            bank_acct_id,
            entity_id,
            entity_type,
            display_name,
            bank_acct_type,
            bank_routing_num,
            bank_acct_num,
            bank_name,
            bank_account_usage,
            last_updated_by,
            created_by,
            last_update_date,
            creation_date,
            giac_verify,
            giac_authenticate,
            giac_response,
            status,
            business_name,
            bank_acct_verified
        ) values ( user_bank_acct_seq.nextval,
                   p_entity_id,
                   p_entity_type,
                   p_display_name,
                   p_bank_acct_type,
                   lpad(p_bank_routing_num, 9, 0),
                   p_bank_acct_num,
                   p_bank_name,
                   nvl(p_bank_account_usage, 'ONLINE'),
                   p_user_id,
                   p_user_id,
                   sysdate,
                   sysdate,
                   p_giac_verify,
                   p_giac_authenticate,
                   p_giac_response,
                   l_bank_status,
                   p_business_name,
                   p_bank_acct_verified ) returning bank_acct_id into x_bank_acct_id;

        -- Added by Joshi. For QB employee the bank accunt usage should be invoice.
        for x in (
            select
                acc_id
            from
                account a,
                person  p
            where
                    acc_id = p_entity_id
                and a.pers_id = p.pers_id
                and a.account_type = 'COBRA'
                and p.person_type = 'QB'
        ) loop
            pc_log.log_error('giact_insert_bank_account', ' X.ACC_ID := '
                                                          || x.acc_id
                                                          || ' x_bank_acct_id :='
                                                          || x_bank_acct_id
                                                          || ' l_bank_status :='
                                                          || l_bank_status
                                                          || ' X.ACC_ID :='
                                                          || x.acc_id
                                                          || 'x_bank_acct_id :='
                                                          || x_bank_acct_id);

            if
                x.acc_id is not null
                and x_bank_acct_id is not null
            then
                update bank_accounts
                set
                    bank_account_usage = 'INVOICE'
                where
                        bank_acct_id = x_bank_acct_id
                    and entity_id = x.acc_id
                    and entity_type = 'ACCOUNT';

            end if;

        end loop;

        x_bank_status := l_bank_status;
        x_error_message := nvl(l_error_message, 'Success');
        x_return_status := nvl(l_return_status, 'S');
        pc_log.log_error('pc_user_bank_acct.giact_insert_bank_account end INSERT INTO bank_accounts p_entity_id ', p_entity_id
                                                                                                                   || ' x_bank_acct_id :='
                                                                                                                   || x_bank_acct_id)
                                                                                                                   ;
    exception
        when setup_error then
            x_return_status := 'E';
            x_error_message := l_error_message;
            pc_log.log_error('giact_insert_bank_account exception setup_error', x_error_message);
        when others then
            x_return_status := 'O';
            x_error_message := sqlerrm;
            pc_log.log_error('giact_insert_bank_account', sqlerrm || dbms_utility.format_error_backtrace);
    end giact_insert_bank_account;

-- Added by Swamy for Ticket#12534 
    function check_active_broker_ga_bank_account (
        p_routing_number    in varchar2,
        p_bank_acct_num     in varchar2,
        p_bank_acct_id      in number,
        p_bank_name         in varchar2,
        p_bank_account_type in varchar2,
        p_broker_ga_id      in number
    ) return varchar2 is

        l_active_exists varchar2(1) := 'N';
        l_ssn           varchar2(100);
        l_account_type  varchar2(100);
        l_entrp_id      number;
        l_pers_id       number;
        l_entrp_code    varchar2(20);
    begin
        pc_log.log_error('check_active_broker_ga_bank_account', 'p_routing_number'
                                                                || p_routing_number
                                                                || ' p_bank_acct_num :='
                                                                || p_bank_acct_num
                                                                || 'p_bank_acct_num :='
                                                                || p_bank_acct_num
                                                                || 'p_bank_acct_id :='
                                                                || p_bank_acct_id
                                                                || 'p_bank_name :='
                                                                || p_bank_name
                                                                || 'p_bank_account_type :='
                                                                || p_bank_account_type
                                                                || 'p_broker_ga_id:='
                                                                || p_broker_ga_id);

        if nvl(p_broker_ga_id, -1) <> -1 then
            for x in (
                select
                    count(*) cnt
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A'
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                   --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))   -- Commented by Ticket#12667  
                   --AND lower(b.bank_acct_type) = lower(p_bank_account_type)    -- Commented by Ticket#12667 
                    and b.entity_id = p_broker_ga_id
                    and b.entity_type in ( 'BROKER', 'GA' )
            ) loop
                if x.cnt > 0 then
                    l_active_exists := 'Y';
                end if;
                pc_log.log_error('check_active_broker_ga_bank_account', 'l_active_exists' || l_active_exists);
            end loop;

        end if;

        return l_active_exists;
    end check_active_broker_ga_bank_account;

    function get_bank_acct_num (
        p_bank_acct_id in number
    ) return varchar2 is
        l_bank_acct_num varchar2(300);
    begin
        for x in (
            select
                bank_acct_num
            from
                bank_accounts
            where
                bank_acct_id = p_bank_acct_id
        ) loop
            l_bank_acct_num := x.bank_acct_num;
        end loop;

        return l_bank_acct_num;
    end get_bank_acct_num;

    function get_existing_bank_giact_details (
        p_routing_number     in varchar2,
        p_bank_acct_num      in varchar2,
        p_bank_acct_id       in number,
        p_bank_name          in varchar2,
        p_bank_account_type  in varchar2,
        p_ssn                in varchar2,
        p_entity_id          in number,
        p_entity_type        in varchar2,
        p_bank_account_usage in varchar2
    ) return giact_record_t
        pipelined
        deterministic
    is

        l_record        giact_details_record_row_t;
        l_active_exists varchar2(1) := 'N';
        l_ssn           varchar2(100);
        l_account_type  varchar2(100);
        l_entrp_id      number;
        l_pers_id       number;
        l_entrp_code    varchar2(20);
    begin
        pc_log.log_error('pc_user_bank_Acct.get_existing_bank_giact_details', 'p_routing_number'
                                                                              || p_routing_number
                                                                              || ' p_bank_acct_num :='
                                                                              || p_bank_acct_num
                                                                              || 'p_bank_acct_num :='
                                                                              || p_bank_acct_num
                                                                              || 'p_bank_acct_id :='
                                                                              || p_bank_acct_id
                                                                              || 'p_bank_name :='
                                                                              || p_bank_name
                                                                              || 'p_bank_account_type :='
                                                                              || p_bank_account_type
                                                                              || 'p_ssn:='
                                                                              || p_ssn
                                                                              || ' p_entity_type :='
                                                                              || p_entity_type
                                                                              || ' p_entity_id :='
                                                                              || p_entity_id);

        l_entrp_code := null;
        l_entrp_id := null;
        if nvl(p_bank_acct_id, 0) <> 0 then
            for x in (
                select
                    bank_acct_id,
                    bank_acct_num,
                    giac_verify,
                    giac_response,
                    giac_authenticate,
                    bank_acct_verified
                from
                    bank_accounts b
                where
                        b.status = 'A'
                    and b.bank_acct_id = nvl(p_bank_acct_id, b.bank_acct_id)
            ) loop
                l_record.bank_acct_id := x.bank_acct_id;
                l_record.bank_acct_num := x.bank_acct_num;
                l_record.giac_authenticate := x.giac_authenticate;
                l_record.giac_verify := x.giac_verify;
                l_record.giac_response := x.giac_response;
                l_record.bank_acct_verified := x.bank_acct_verified;

         --pc_log.log_error('pc_user_bank_Acct.get_giact_details ','l_record.giac_verify '||l_record.giac_verify||' l_record.giac_response :='||l_record.giac_response||' l_record.giac_authenticate  :='||l_record.giac_authenticate||' l_record.bank_acct_id :='||l_record.bank_acct_id  );  
                pipe row ( l_record );
            end loop;
        elsif nvl(p_entity_type, '*') in ( 'BROKER', 'GA' ) then
            for x in (
                select
                    bank_acct_id,
                    bank_acct_num,
                    giac_verify,
                    giac_response,
                    giac_authenticate,
                    bank_acct_verified
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A' 
                  -- AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667 
                  -- AND lower(b.bank_acct_type) = lower(p_bank_account_type)    -- Commented by Ticket#12667 
                    and lower(b.bank_account_usage) = lower(p_bank_account_usage)
                    and b.entity_id = p_entity_id
                    and b.entity_type = p_entity_type
            ) loop
                l_record.bank_acct_id := x.bank_acct_id;
                l_record.bank_acct_num := x.bank_acct_num;
                l_record.giac_authenticate := x.giac_authenticate;
                l_record.giac_verify := x.giac_verify;
                l_record.giac_response := x.giac_response;
                l_record.bank_acct_verified := x.bank_acct_verified;

         --pc_log.log_error('pc_user_bank_Acct.get_giact_details ','l_record.giac_verify '||l_record.giac_verify||' l_record.giac_response :='||l_record.giac_response||' l_record.giac_authenticate  :='||l_record.giac_authenticate||' l_record.bank_acct_id :='||l_record.bank_acct_id  );  
                pipe row ( l_record );
            end loop;
        elsif
            nvl(p_entity_type, '*') = 'ACCOUNT'
            and nvl(p_ssn, '*') = '*'
        then
            for j in (
                select
                    entrp_id
                from
                    account
                where
                    acc_id = p_entity_id
            ) loop
                l_entrp_id := j.entrp_id;
            end loop;

            l_entrp_code := pc_entrp.get_tax_id(l_entrp_id);
            for x in (
                select
                    bank_acct_id,
                    bank_acct_num,
                    giac_verify,
                    giac_response,
                    giac_authenticate,
                    bank_acct_verified
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A'
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                   --AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))  -- Commented by Ticket#12667 
                   --AND lower(b.bank_acct_type) = lower(p_bank_account_type)  -- Commented by Ticket#12667 
                    and b.entity_id in (
                        select
                            acc_id
                        from
                            account    ac, enterprise en
                        where
                                ac.entrp_id = en.entrp_id
                            and en.entrp_code = l_entrp_code
                    )
            ) loop
                l_record.bank_acct_id := x.bank_acct_id;
                l_record.bank_acct_num := x.bank_acct_num;
                l_record.giac_authenticate := x.giac_authenticate;
                l_record.giac_verify := x.giac_verify;
                l_record.giac_response := x.giac_response;
                l_record.bank_acct_verified := x.bank_acct_verified;

         --pc_log.log_error('pc_user_bank_Acct.get_giact_details ','l_record.giac_verify '||l_record.giac_verify||' l_record.giac_response :='||l_record.giac_response||' l_record.giac_authenticate  :='||l_record.giac_authenticate||' l_record.bank_acct_id :='||l_record.bank_acct_id  );  
                pipe row ( l_record );
            end loop;

        elsif
            nvl(p_entity_type, '*') = 'ACCOUNT'
            and nvl(p_ssn, '*') <> '*'
        then
            for x in (
                select
                    bank_acct_id,
                    bank_acct_num,
                    giac_verify,
                    giac_response,
                    giac_authenticate,
                    bank_acct_verified
                from
                    bank_accounts b
                where
                        b.bank_routing_num = p_routing_number
                    and b.bank_acct_num = p_bank_acct_num
                    and b.status = 'A'
                    and b.bank_acct_id <> nvl(p_bank_acct_id, 0)
                  -- AND lower(LTRIM(RTRIM(b.bank_name))) = lower(LTRIM(RTRIM(p_bank_name)))   -- Commented by Ticket#12667 
                  -- AND lower(b.bank_acct_type) = lower(p_bank_account_type)   -- Commented by Ticket#12667 
                    and b.entity_id in (
                        select
                            acc_id
                        from
                            account ac, person  p
                        where
                                ac.pers_id = p.pers_id
                            and p.ssn = format_ssn(p_ssn)
                    )
            ) loop
                l_record.bank_acct_id := x.bank_acct_id;
                l_record.bank_acct_num := x.bank_acct_num;
                l_record.giac_authenticate := x.giac_authenticate;
                l_record.giac_verify := x.giac_verify;
                l_record.giac_response := x.giac_response;
                l_record.bank_acct_verified := x.bank_acct_verified;

         --pc_log.log_error('pc_user_bank_Acct.get_giact_details ','l_record.giac_verify '||l_record.giac_verify||' l_record.giac_response :='||l_record.giac_response||' l_record.giac_authenticate  :='||l_record.giac_authenticate||' l_record.bank_acct_id :='||l_record.bank_acct_id  );  
                pipe row ( l_record );
            end loop;
        end if;

    end get_existing_bank_giact_details;

    procedure update_giac_details (
        p_entity_id         in number,
        p_entity_type       in varchar2,
        p_bank_acct_id      in number,
        p_gresponse         in varchar2,
        p_giac_verify       in varchar2,
        p_giac_authenticate in varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is
    begin
        pc_log.log_error('pc_user_bank_acct.update_giac_details begin p_gresponse := ', p_gresponse
                                                                                        || 'p_giac_verify :='
                                                                                        || p_giac_verify
                                                                                        || ' p_giac_Authenticate :='
                                                                                        || p_giac_authenticate
                                                                                        || 'p_bank_acct_id :='
                                                                                        || p_bank_acct_id
                                                                                        || 'P_ENTITY_ID :='
                                                                                        || p_entity_id
                                                                                        || 'P_ENTITY_TYPE :='
                                                                                        || p_entity_type);

        update bank_accounts
        set
            giac_response = p_gresponse,
            giac_verify = p_giac_verify,
            giac_authenticate = p_giac_authenticate
        where
                bank_acct_id = p_bank_acct_id
            and entity_id = p_entity_id
            and entity_type = p_entity_type;

    exception
        when others then
            x_return_status := 'O';
            x_error_message := sqlerrm;
            pc_log.log_error('pc_user_bank_acct.update_giac_details', sqlerrm || dbms_utility.format_error_backtrace);
    end update_giac_details;

-- To display the banner in account summary and in portfolio page that the bank account is in pending documentation
    function check_bank_pending_document (
        p_acc_id    in number,
        p_broker_id in number,
        p_ga_id     in number
    ) return varchar2 is
        l_bank_pending_document varchar2(1) := 'N';
    begin
        if nvl(p_acc_id, 0) <> 0 then
            for j in (
                select
                    'Y' flg_exists
                from
                    bank_accounts
                where
                        entity_id = p_acc_id
                    and status = 'P'
                    and entity_type = 'ACCOUNT'
            ) loop
                l_bank_pending_document := j.flg_exists;
            end loop;
        elsif nvl(p_broker_id, 0) <> 0 then
            for j in (
                select
                    'Y' flg_exists
                from
                    bank_accounts
                where
                        entity_id = p_broker_id
                    and status = 'P'
                    and entity_type = 'BROKER'
            ) loop
                l_bank_pending_document := j.flg_exists;
            end loop;
        elsif nvl(p_ga_id, 0) <> 0 then
            for j in (
                select
                    'Y' flg_exists
                from
                    bank_accounts
                where
                        entity_id = p_ga_id
                    and status = 'P'
                    and entity_type = 'GA'
            ) loop
                l_bank_pending_document := j.flg_exists;
            end loop;
        end if;

        return nvl(l_bank_pending_document, 'N');
    end check_bank_pending_document;

-- Added by Joshi for 12396. 
    procedure insert_gaict_bank_remind_notif (
        p_bank_acct_id    in number,
        p_bank_age        in number,
        p_notif_type      in varchar2,
        p_email           in varchar2,
        p_notification_id in number,
        p_template_name   in varchar2
    ) is
    begin
        pc_log.log_error('insert_gaict_bank_remind_notif p_bank_acct_id  ', p_bank_acct_id);
        pc_log.log_error('insert_gaict_bank_remind_notif p_bank_age  ', p_bank_age);
        pc_log.log_error('insert_gaict_bank_remind_notif p_email  ', p_email);
        pc_log.log_error('insert_gaict_bank_remind_notif p_notification_id  ', p_notification_id);
        pc_log.log_error('insert_gaict_bank_remind_notif p_template_name  ', p_template_name);
--pc_log.log_error('insert_gaict_bank_remind_notif l_notif_id  ', l_notif_id );

        insert into giact_bank_verify_notification (
            bank_notif_id,
            bank_acct_id,
            age_of_bank_notify,
            notification_type,
            mailed_to,
            mailed_date,
            creation_date,
            notification_id,
            template_name
        ) values ( bank_notif_id_seq.nextval,
                   p_bank_acct_id,
                   p_bank_age,
                   p_notif_type,
                   substr(p_email, 1, 4000),
                   sysdate,
                   sysdate,
                   p_notification_id,
                   p_template_name );

    end insert_gaict_bank_remind_notif;

    procedure send_giact_bank_remind_notif is

        v_template_name     varchar2(3200);
        v_template_subject  varchar2(3200);
        v_template_body     varchar2(32000);
        v_bank_acc_id       number;
        bank_cur            sys_refcursor;
        l_notif_id          number;
        l_email             varchar2(4000);
        num_tbl             pc_notifications.number_tbl;
        l_send_notification varchar2(1) := 'Y';
        l_notice_type       varchar2(100);
        l_subject           varchar2(500);
        l_tax_id            varchar2(25);
        l_acct_holder_name  varchar2(2500);
        l_acct_holder_num   varchar2(25);
        l_error_status      varchar2(1);
        l_error_msg         varchar2(4000);
    begin
        for x in (
            select
                ns.entrp_id,
                ns.description,
                nt.template_name,
                nt.template_subject,
                template_body,
                'no-reply@sterlingadministration.com' from_address,
                to_address,
                nt.cc_address,
                ( 'SELECT '
                  || trigger_column
                  || ' FROM '
                  || trigger_table
                  || ' WHERE '
                  || trigger_condition
                  || ' '
                  || trigger_on )                       bank_sql
            from
                notification_schedule ns,
                notification_template nt
            where
                    ns.notif_template_id = nt.notif_template_id
                and ns.notification_entity = 'BANK'
                and ns.send_notification = 'Y'
        ) loop
            begin
                pc_log.log_error('send_giact_bank_remind_notif begin bank_sql ', x.bank_sql);
                bank_cur := get_cursor(x.bank_sql);
                l_email := null;
                l_notice_type := x.description;
                pc_log.log_error('send_giact_bank_remind_notif begin l_Notice_Type ', l_notice_type);
                loop
                    fetch bank_cur into v_bank_acc_id;
                    exit when bank_cur%notfound;
                    pc_log.log_error('send_giact_bank_remind_notif begin v_bank_acc_id ', v_bank_acc_id);
                    for ba in (
                        select
                            bank_acct_id,
                            entity_type,
                            entity_id,
                            trunc(sysdate) - trunc(creation_date) bank_age
                        from
                            bank_accounts
                        where
                                bank_acct_id = v_bank_acc_id
                            and status = 'P'
                    ) loop
                        if ba.entity_type = 'ACCOUNT' then
                            for xx in (
                                select
                                    a.acc_id,
                                    a.acc_num,
                                    a.entrp_id,
                                    a.pers_id,
                                    case
                                        when a.entrp_id is null then
                                            pc_person.get_person_name(a.pers_id)
                                        else
                                            pc_entrp.get_entrp_name(a.entrp_id)
                                    end entity_name
                                from
                                    account a
                                where
                                    a.acc_id = ba.entity_id
                            ) loop
                                l_acct_holder_name := xx.entity_name;
                                l_acct_holder_num := xx.acc_num;
                                if xx.entrp_id is not null then
                                    l_tax_id := pc_entrp.get_tax_id(xx.entrp_id);
                                    l_email := pc_contact.get_super_admin_email(l_tax_id);
                                else
                                    l_email := pc_users.get_email(xx.acc_num, xx.acc_id, xx.pers_id);
                                end if;

                                l_subject := x.template_subject
                                             || ' - '
                                             || l_acct_holder_num;
                            end loop;
                        elsif ba.entity_type = 'BROKER' then
                            for br in (
                                select
                                    broker_name,
                                    broker_lic
                                from
                                    table ( pc_broker.get_broker_info(ba.entity_id) )
                            ) loop
                                l_acct_holder_name := br.broker_name;
                                l_acct_holder_num := br.broker_lic;
                                l_email := pc_contact.get_broker_super_admin_email(br.broker_lic);
                                l_subject := x.template_subject
                                             || ' - '
                                             || l_acct_holder_name;
                            end loop;
                        else
                            for ga in (
                                select
                                    agency_name,
                                    ga_lic
                                from
                                    table ( pc_general_agent.get_ga_info(ba.entity_id) )
                            ) loop
                                l_acct_holder_name := ga.agency_name;
                                l_acct_holder_num := ga.ga_lic;
                                l_email := pc_contact.get_ga_super_admin_email(ga.ga_lic);
                                l_subject := x.template_subject
                                             || ' - '
                                             || l_acct_holder_name;
                            end loop;
                        end if;

                        pc_log.log_error('send_giact_bank_remind_notif l_acct_holder_name  ', l_acct_holder_name);
                        pc_log.log_error('send_giact_bank_remind_notif l_acct_holder_num  ', l_acct_holder_num);
                        if nvl(l_email, x.to_address) is not null then
                            pc_notifications.insert_notifications(
                                p_from_address    => x.from_address,
                                p_to_address      => nvl(l_email, x.to_address),
                                p_cc_address      => x.cc_address,
                                p_subject         => l_subject,
                                p_message_body    => x.template_body,
                                p_acc_id          => ba.entity_id    --Replaced NULL by ba.entity_id by Swamy for Ticket#12681
                                ,
                                p_user_id         => 0,
                                x_notification_id => l_notif_id
                            );

                            pc_notifications.set_token('ENTITY_NAME', l_acct_holder_name, l_notif_id);
                            num_tbl(1) := 0;                                          --Added by Swamy for Ticket#12681
                            pc_notifications.add_notify_users(num_tbl, l_notif_id);    --Added by Swamy for Ticket#12681
                            pc_log.log_error('send_giact_bank_remind_notif l_notif_id  ', l_notif_id);
                            insert_gaict_bank_remind_notif(
                                p_bank_acct_id    => v_bank_acc_id,
                                p_bank_age        => ba.bank_age,
                                p_notif_type      => x.description,
                                p_email           => nvl(l_email, x.to_address),
                                p_notification_id => l_notif_id,
                                p_template_name   => x.template_name
                            );

                            update email_notifications
                            set
                                mail_status = 'READY',
                                template_name = x.template_name
                            where
                                notification_id = l_notif_id; 

              -- once the Final notice is sent, the bank should be inactivated.
                            if x.template_name = 'GIACT_REMINDER_CANCELLED_BANK' then
                                update bank_accounts
                                set
                                    status = 'I',
                                    inactive_date = sysdate,
                                    last_updated_by = 0,
                                    last_update_date = sysdate,
                                    inactive_reason = 'SYSTEM_INACTIVATED',
                                    note = nvl(note, ' ')
                                           || 'System Inactivated Bank Account due to insufficient documentation.'
                                where
                                        bank_acct_id = v_bank_acc_id
                                    and status = 'P';

                --update account status and other flags   
                                giact_manage_bank_account(
                                    p_bank_status     => 'I',
                                    p_entity_type     => ba.entity_type,
                                    p_entity_id       => ba.entity_id,
                                    p_bank_acct_id    => v_bank_acc_id,
                                    p_inactive_reason => 'SYSTEM_INACTIVATED',
                                    p_user_id         => 0,
                                    x_error_status    => l_error_status,
                                    x_error_message   => l_error_msg
                                );

                            end if;

                        end if;

                    end loop;

                end loop;

            exception
                when others then
                    pc_log.log_error('send_giact_bank_remind_notif;', x.template_name
                                                                      || ' '
                                                                      || sqlerrm);
                    raise;
            end;
        end loop;

        close bank_cur;
    end send_giact_bank_remind_notif;

    procedure bank_staging_validations (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_user_id       in number,
        p_acct_usage    in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_entity_type  varchar2(100);
        l_account_type varchar2(100);
        l_broker_id    number;
        l_bank_exist   number;
        setup_error exception;
    begin
        l_account_type := pc_account.get_account_type_from_entrp_id(p_entrp_id);
        if l_account_type = 'FORM_5500' then
            pc_broker.get_broker_id(
                p_user_id     => p_user_id,
                p_entity_type => l_entity_type,
                p_broker_id   => l_broker_id
            );

            l_entity_type := nvl(l_entity_type, 'EMPLOYER');
            select
                count(*)
            into l_bank_exist
            from
                user_bank_acct_staging
            where
                    entrp_id = p_entrp_id
                and p_batch_number = p_batch_number
                and acct_usage = p_acct_usage;

            if l_bank_exist > 0 then
                raise setup_error;
            end if;
        end if;

        x_error_message := 'Success';
        x_return_status := 'S';
    exception
        when setup_error then
            x_error_message := 'One account usage option cannot be selected for multiple bank accounts.';
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.bank_Staging_validations exception others ', 'x_error_message ' || x_error_message
            );
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.bank_Staging_validations exception others ', 'x_error_message ' || x_error_message
            );
    end bank_staging_validations;

-- Added by Swamy for Ticket#12527
    procedure get_bank_account_usage (
        p_product_type    in varchar2,
        p_account_usage   in varchar2,
        x_bank_acct_usage out varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_account_usage varchar2(100);
    begin
        if p_product_type = 'FORM_5500' then
            x_bank_acct_usage := 'INVOICE';
        else
            if p_account_usage in ( 'FEE', 'ONLINE' ) then
                x_bank_acct_usage := 'INVOICE';
            elsif p_account_usage in ( 'CLAIM' ) then
                x_bank_acct_usage := 'CLAIMS';
            else
                x_bank_acct_usage := p_account_usage;
            end if;
        end if;
    exception
        when others then
            x_error_message := dbms_utility.format_error_backtrace || sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.get_bank_Account_usage exception others ', 'x_error_message ' || x_error_message);
    end get_bank_account_usage;

-- Added by Swamy for Ticket#12527
    procedure giact_pay_invoice_online (
        p_bank_json     in clob,
        p_entity_id     in number,
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_auto_pay      in varchar2,
        p_division_code in varchar2,
        p_user_id       in number,
        x_bank_acct_id  out number,
        x_bank_status   out varchar2,
        x_bank_message  out varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_bank_acct_id  number;
        l_bank_status   varchar2(10);
        l_bank_message  varchar2(1000);
        l_return_status varchar2(10);
        l_error_message varchar2(1000);
        erreur exception;
        setup_error exception;
    begin
        l_bank_acct_id := null;
        pc_giact_validations.process_bank_giact(
            p_bank_json     => p_bank_json,
            p_batch_number  => null,
            p_user_id       => p_user_id,
            p_bank_acct_id  => l_bank_acct_id,
            p_bank_status   => l_bank_status,
            p_bank_message  => l_bank_message,
            x_return_status => l_return_status,
            x_error_message => l_error_message
        );

        x_bank_status := l_bank_status;
        x_bank_message := l_bank_message;
        if nvl(l_return_status, 'S') not in ( 'S', 'P', 'R' ) then
            raise setup_error;
        end if;

        for ba in (
            select
                entity_id,
                entity_type,
                bank_acct_id,
                bank_acct_type,
                bank_routing_num,
                bank_acct_num,
                bank_name,
                bank_account_usage,
                business_name
            from
                bank_accounts
            where
                    status = 'A'
                and bank_acct_id = l_bank_acct_id
                and entity_id = p_entity_id
        ) loop
            pc_invoice.pay_invoice_online(
                p_invoice_id       => p_invoice_id,
                p_entrp_id         => p_entrp_id,
                p_entity_id        => ba.entity_id,
                p_entity_type      => ba.entity_type,
                p_bank_acct_id     => ba.bank_acct_id,
                p_bank_acct_type   => ba.bank_acct_type,
                p_bank_routing_num => ba.bank_routing_num,
                p_bank_acct_num    => ba.bank_acct_num,
                p_bank_name        => ba.bank_name,
                p_auto_pay         => p_auto_pay,
                p_account_usage    => ba.bank_account_usage,
                p_division_code    => p_division_code,
                p_user_id          => p_user_id,
                p_business_name    => ba.business_name,
                x_bank_acct_id     => l_bank_acct_id,
                x_return_status    => l_return_status,
                x_error_message    => l_error_message
            );

            if l_return_status <> 'S' then
                raise erreur;
            end if;
            if nvl(l_bank_status, '*') <> 'A' then
                update ach_transfer
                set
                    status = '6'
                where
                        invoice_id = p_invoice_id
                    and bank_acct_id = x_bank_acct_id;

                update ar_invoice
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

                update ar_invoice_lines
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

            end if;

        end loop;

        x_bank_acct_id := l_bank_acct_id;
        x_return_status := 'S';
    exception
        when erreur then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('pc_giact_validations.giact_PAY_INVOICE_ONLINE exception erreur ', 'x_error_message ' || x_error_message
            );
        when setup_error then
            x_return_status := 'E';
            x_error_message := l_error_message;
            pc_log.log_error('pc_giact_validations.giact_PAY_INVOICE_ONLINE exception setup_error', x_error_message);
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.giact_PAY_INVOICE_ONLINE exception others ', 'x_error_message ' || x_error_message
            );
    end giact_pay_invoice_online;

    procedure giact_cancel_pay_now (
        p_bank_acct_id  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        update bank_accounts
        set
            status = 'I',
            last_update_date = sysdate,
            last_updated_by = p_user_id,
            inactive_reason = 'DELETED_BY_CUSTOMER',
            inactive_date = sysdate,
            note = 'User cancelled Paynow'
        where
            bank_acct_id = p_bank_acct_id;

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.giact_cancel_pay_now exception others ', 'x_error_message ' || x_error_message);
    end giact_cancel_pay_now;

    function is_active_bank_exist (
        p_entity_type      varchar2,
        p_entity_id        number,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2
    ) return varchar2 is
        l_active_exists varchar2(1) := 'N';
    begin
        for x in (
            select
                count(*) cnt
            from
                bank_accounts
            where
                    bank_routing_num = p_bank_routing_num
                and bank_acct_num = p_bank_acct_num
                and status = 'A'
                and entity_id = p_entity_id
                and entity_type = p_entity_type
        ) loop
            if x.cnt > 0 then
                l_active_exists := 'Y';
            end if;
            pc_log.log_error('is_active_bank_exist', 'l_active_exists' || l_active_exists);
        end loop;

        return l_active_exists;
    end is_active_bank_exist;

-- Added by Swamy for Ticket#12527
    procedure get_entity_details (
        p_acc_id            in number,
        p_product_type      in varchar2,
        p_acct_payment_fees in varchar2,
        x_entity_id         out number,
        x_entity_type       out varchar2,
        x_return_status     out varchar2,
        x_error_message     out varchar2
    ) is
        l_entity_id   number;
        l_entity_type varchar2(100);
    begin
        if upper(p_acct_payment_fees) = 'EMPLOYER' then
            l_entity_id := p_acc_id;
            l_entity_type := 'ACCOUNT';
        elsif upper(p_acct_payment_fees) = 'BROKER' then
            l_entity_id := pc_account.get_broker_id(p_acc_id);
            l_entity_type := 'BROKER';
        elsif upper(p_acct_payment_fees) = 'GA' then
            l_entity_id := pc_account.get_ga_id(p_acc_id);
            l_entity_type := 'GA';
        end if;

        x_entity_id := l_entity_id;
        x_entity_type := l_entity_type;
        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('pc_giact_validations.get_entity_details exception others ', 'x_error_message ' || x_error_message);
    end get_entity_details;

end pc_user_bank_acct;
/


-- sqlcl_snapshot {"hash":"f216aa7638effd779b9b0f36cb86568e38a1d9f2","type":"PACKAGE_BODY","name":"PC_USER_BANK_ACCT","schemaName":"SAMQA","sxml":""}