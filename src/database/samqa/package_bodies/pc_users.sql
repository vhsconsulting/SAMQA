create or replace package body samqa.pc_users is

    procedure insert_users (
        p_user_name      in varchar2,
        p_password       in varchar2,
        p_user_type      in varchar2,
        p_emp_reg_type   in varchar2 default null,
        p_find_key       in varchar2,
        p_locked_time    in varchar2 default null,
        p_succ_access    in number default null,
        p_last_login     in varchar2 default null,
        p_failed_att     in number default null,
        p_failed_ip      in varchar2 default null,
        p_create_pw      in varchar2 default null,
        p_change_pw      in varchar2 default null,
        p_email          in varchar2,
        p_pw_question    in varchar2,
        p_pw_answer      in varchar2,
        p_confirmed_flag in varchar2 default 'N',
        p_tax_id         in varchar2 default null,
        x_user_id        out varchar2,
        x_return_status  out varchar2,
        x_error_message  out varchar2,
        p_user_id        in number default null
    ) is

        setup_error exception;
        l_user_id          number;
        l_user_count       number;
        l_sqlerrm          varchar2(3200);
        l_confirmed_flag   varchar2(1) := 'N';
        l_tax_id           varchar2(255);
        l_phone            varchar2(30);
        l_first_name       varchar2(255);  -----9132 rprabu 04/06
        l_middle_name      varchar2(1);     -----9132 rprabu 04/06
        l_last_name        varchar2(50);  -----9132 rprabu 04/06
        l_gender           varchar2(1);     -----9132 Rprabu 04/06
        l_title            varchar2(20);  -----9132 Rprabu 04/06
        x_contact_id       number;                 -----9132 Rprabu 04/06
        l_count            number := 0; -----------  9527 09/11/20202
        l_authorize_req_id number;
    begin
        x_return_status := 'S';
        pc_log.log_error('USER_CREATION',
                         'p_password '
                         || nvl(p_password, null)
                         || ' user name '
                         || p_user_name);

        select
            decode(p_user_name, null, 'User Name cannot be null', 'xx')
            || decode(p_user_type, null, 'User Type cannot be null', 'xx')
            || decode(p_find_key, null, 'Account Number cannot be null', 'xx')
            || decode(p_email, null, 'Email cannot be null', 'xx')
        into x_error_message
        from
            dual;

        if
            x_error_message not like 'xx%'
            and x_error_message is not null
        then
            raise setup_error;
        end if;
        x_error_message := null;
        x_error_message := validate_user(
            p_tax_id       => p_tax_id,
            p_acc_num      => p_find_key,
            p_user_type    => p_user_type,
            p_emp_reg_type => p_emp_reg_type,
            p_user_name    => p_user_name,
            p_password     => p_password,
            p_user_id      => p_user_id
        );

        pc_log.log_error('USER_CREATION', 'Validated User ' || x_error_message);
        if x_error_message is not null then
            raise setup_error;
        end if;
        pc_log.log_error('USER_CREATION', 'User Name'
                                          || p_user_name
                                          || ' password question '
                                          || p_pw_question);
        if p_emp_reg_type = 1 then
            l_confirmed_flag := 'Y';
        else
            l_confirmed_flag := p_confirmed_flag;
        end if;

        if p_user_type = 'B' then
            l_tax_id := p_find_key;
        else
            if p_tax_id is null then
                for x in (
                    select
                        replace(p.ssn, '-')            ssn,
                        nvl(p.phone_day, p.phone_even) phone
                    from
                        person  p,
                        account b,
                        plans   c
                    where
                            acc_num = p_find_key
                        and p.pers_id = b.pers_id
                        and c.plan_code = b.plan_code
                        and c.plan_sign <> 'SHA'
                ) loop
                    l_tax_id := x.ssn;
                    l_phone := x.phone;
                end loop;

            else
                for x in (
                    select
                        replace(p.ssn, '-')            ssn,
                        nvl(p.phone_day, p.phone_even) phone
                    from
                        person  p,
                        account b,
                        plans   c
                    where
                            p.ssn = format_ssn(p_tax_id)
                        and p.pers_id = b.pers_id
                        and c.plan_code = b.plan_code
                        and c.plan_sign <> 'SHA'
                ) loop
                    l_tax_id := x.ssn;
                    l_phone := x.phone;
                end loop;
            end if;
        end if;

        insert into online_users (
            user_id,
            user_name,
            password,
            user_type,
            emp_reg_type,
            find_key,
            locked_time,
            succ_access,
            last_login,
            failed_att,
            failed_ip,
            create_pw,
            change_pw,
            email,
            pw_question,
            pw_answer,
            confirmed_flag,
            tax_id,
            security_setup_grace
        ) values ( online_users_seq.nextval,
                   p_user_name,
                   p_password,
                   p_user_type,
                   p_emp_reg_type,
                   p_find_key,
                   p_locked_time,
                   p_succ_access,
                   p_last_login,
                   p_failed_att,
                   p_failed_ip,
                   nvl(p_create_pw,
                       to_char(sysdate, 'MM/DD/YYYY HH:MI:SS')),
                   nvl(p_create_pw,
                       to_char(sysdate, 'MM/DD/YYYY HH:MI:SS')),
                   p_email,
                   p_pw_question,
                   p_pw_answer,
                   l_confirmed_flag,
                   nvl(
                       replace(p_tax_id, '-'),
                       l_tax_id
                   ),
                   trunc(sysdate) ) returning user_id into x_user_id;
       --PC_LOG.LOG_ERROR('USER_CREATION','User ID '|| l_user_id);
        pc_user_security_pkg.insert_user_security_info(
            p_user_id               => x_user_id,
            p_otp_verified          => 'N',
            p_verified_phone_type   => null,
            p_verified_phone_number => null
        );
    --  x_user_id := TO_CHAR(l_user_id);
     -- dbms_output.put_line('after inserting '||x_user_id);
        update online_enrollment
        set
            user_name = p_user_name
        where
            acc_num = p_find_key;
	   ------8890 04/06/2020   --- 9527 rprabu remove duplicate 06/11/2020
        if
            p_user_type = 'G'
            and pc_users.is_main_online_broker(x_user_id) = 'Y'
        then
            for t in (
                select
                    contact_name,
                    phone
                from
                    general_agent
                where
                    ga_lic = p_find_key
            ) loop
                l_last_name := t.contact_name;
                l_phone := t.phone;
            end loop;

            pc_contact.create_contact(
                p_first_name    => null,
                p_last_name     => l_last_name,
                p_middle_name   => null,
                p_title         => null,
                p_gender        => null,
                p_entity_id     => p_find_key,
                p_phone         => l_phone,
                p_fax           => null,
                p_email         => p_email,
                p_user_id       => x_user_id,
                x_contact_id    => x_contact_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            update contact
            set
                user_id = x_user_id,
                entity_type = 'MAIN_GA',
                note = 'Created from Online General Agent  Registration',
                contact_type = 'PRIMARY'
            where
                contact_id = x_contact_id;

        end if;      ------ End 8890 04/06/2020

          ----- End 9132 04/06/2020
        if
            p_user_type = 'B'
            and pc_users.is_main_online_broker(x_user_id) = 'Y'
        then
            for w in (
                select
                    b.first_name,
                    b.middle_name,
                    b.last_name,
                    title,
                    gender,
                    phone_day
                from
                    broker a,
                    person b
                where
                        a.broker_lic = p_find_key
                    and a.broker_id = b.pers_id
            ) loop
                l_middle_name := w.middle_name;
                l_last_name := w.last_name;
                l_first_name := w.first_name;
                l_title := w.title;
                l_gender := w.gender;
                l_phone := w.phone_day;
            end loop;

            pc_contact.create_contact(
                p_first_name    => l_first_name,
                p_last_name     => l_last_name,
                p_middle_name   => l_middle_name,
                p_title         => l_title,
                p_gender        => l_gender,
                p_entity_id     => p_find_key,
                p_phone         => l_phone,
                p_fax           => null,
                p_email         => p_email,
                p_user_id       => x_user_id,
                x_contact_id    => x_contact_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            update contact
            set
                user_id = x_user_id,
                entity_type = 'MAIN_BROKER',
                note = 'Created from Online Broker Registration',
                contact_type = 'PRIMARY'
            where
                contact_id = x_contact_id;

        end if;      ------ End 9132 04/06/2020

   -- Added by Joshi for 9902. create broker permission for new user.
        if p_user_type = 'B' then
            for x in (
                select distinct
                    b.broker_id,
                    a.acc_id,
                    ep.authorize_req_id
                from
                    account                  a,
                    broker                   b,
                    er_portal_authorizations ep
                where
                        a.broker_id = b.broker_id
                    and nvl(a.account_status, 1) <> 4
                    and b.broker_id = ep.broker_id
                    and a.acc_id = ep.acc_id
                    and lower(b.broker_lic) = lower(p_find_key)
                    and ep.request_status = 'APPROVED'
            ) loop
                pc_broker.insert_broker_auth_req(
                    p_broker_id        => x.broker_id,
                    p_acc_id           => x.acc_id,
                    p_broker_user_id   => x_user_id,
                    p_user_id          => p_user_id,
                    x_authorize_req_id => l_authorize_req_id,
                    x_error_status     => x_return_status,
                    x_error_message    => x_error_message
                );

                pc_broker.create_broker_authorize(
                    p_broker_id        => x.broker_id,
                    p_acc_id           => x.acc_id,
                    p_broker_user_id   => x_user_id,
                    p_authorize_req_id => x.authorize_req_id,
                    p_user_id          => p_user_id,
                    x_error_status     => x_return_status,
                    x_error_message    => x_error_message
                );

            end loop;
        end if;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            l_sqlerrm := sqlerrm;
            x_return_status := 'E';
            x_error_message := l_sqlerrm;
        --PC_LOG.LOG_ERROR('USER_CREATION',l_sqlerrm);

    end insert_users;

    procedure insert_contact_user (
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_type          in varchar2,
        p_emp_reg_type       in varchar2 default null,
        p_find_key           in varchar2,
        p_locked_time        in varchar2 default null,
        p_succ_access        in number default null,
        p_last_login         in varchar2 default null,
        p_failed_att         in number default null,
        p_failed_ip          in varchar2 default null,
        p_create_pw          in varchar2 default null,
        p_change_pw          in varchar2 default null,
        p_email              in varchar2,
        p_pw_question        in varchar2,
        p_pw_answer          in varchar2,
        p_confirmed_flag     in varchar2 default 'N',
        p_tax_id             in varchar2 default null,
        p_first_time_pw_flag in varchar2 default 'N',
        x_user_id            out varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        setup_error exception;
        l_user_id        number;
        l_user_count     number;
        l_sqlerrm        varchar2(3200);
        l_confirmed_flag varchar2(1) := 'N';
        l_tax_id         varchar2(255);
    begin
        x_return_status := 'S';
        select
            decode(p_user_name, null, 'User Name cannot be null', 'xx')
            || decode(p_user_type, null, 'User Type cannot be null', 'xx')
            || decode(p_find_key, null, 'Account Number cannot be null', 'xx')
            || decode(p_email, null, 'Email cannot be null', 'xx')
        into x_error_message
        from
            dual;

        if
            x_error_message not like 'xx%'
            and x_error_message is not null
        then
            raise setup_error;
        end if;
        x_error_message := null;
        x_error_message := validate_user(
            p_tax_id       => p_tax_id,
            p_acc_num      => p_find_key,
            p_user_type    => p_user_type,
            p_emp_reg_type => p_emp_reg_type,
            p_user_name    => p_user_name,
            p_password     => p_password
        );

        pc_log.log_error('USER_CREATION', 'Validated User ' || x_error_message);
        if x_error_message is not null then
            raise setup_error;
        end if;
        pc_log.log_error('USER_CREATION', 'User Name'
                                          || p_user_name
                                          || ' password question '
                                          || p_pw_question);
        if p_emp_reg_type = 1 then
            l_confirmed_flag := 'Y';
        else
            l_confirmed_flag := p_confirmed_flag;
        end if;

        if p_user_type = 'B' then
            l_tax_id := p_find_key;
        else
            if p_tax_id is null then
                for x in (
                    select
                        replace(p.ssn, '-') ssn
                    from
                        person  p,
                        account b,
                        plans   c
                    where
                            acc_num = p_find_key
                        and p.pers_id = b.pers_id
                        and c.plan_code = b.plan_code
                        and c.plan_sign <> 'SHA'
                ) loop
                    l_tax_id := x.ssn;
                end loop;

            end if;
        end if;

        insert into online_users (
            user_id,
            user_name,
            password,
            user_type,
            emp_reg_type,
            find_key,
            locked_time,
            succ_access,
            last_login,
            failed_att,
            failed_ip,
            create_pw,
            change_pw,
            email,
            pw_question,
            pw_answer,
            confirmed_flag,
            tax_id,
            security_setup_grace
        ) values ( online_users_seq.nextval,
                   p_user_name,
                   p_password,
                   p_user_type,
                   p_emp_reg_type,
                   p_find_key,
                   p_locked_time,
                   p_succ_access,
                   p_last_login,
                   p_failed_att,
                   p_failed_ip,
                   nvl(p_create_pw,
                       to_char(sysdate, 'MM/DD/YYYY HH:MI:SS')),
                   nvl(p_create_pw,
                       to_char(sysdate, 'MM/DD/YYYY HH:MI:SS')),
                   p_email,
                   p_pw_question,
                   p_pw_answer,
                   l_confirmed_flag,
                   nvl(
                       replace(p_tax_id, '-'),
                       l_tax_id
                   ),
                   trunc(sysdate) ) returning user_id into x_user_id;
       --PC_LOG.LOG_ERROR('USER_CREATION','User ID '|| l_user_id);

    --  x_user_id := TO_CHAR(l_user_id);
     -- dbms_output.put_line('after inserting '||x_user_id);
        update online_enrollment
        set
            user_name = p_user_name
        where
            acc_num = p_find_key;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            l_sqlerrm := sqlerrm;
            x_return_status := 'E';
            x_error_message := l_sqlerrm;
        --PC_LOG.LOG_ERROR('USER_CREATION',l_sqlerrm);

    end insert_contact_user;

    procedure update_users (
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_user_type     in varchar2,
        p_emp_reg_type  in varchar2 default null,
        p_find_key      in varchar2,
        p_email         in varchar2,
        p_pw_question   in varchar2,
        p_pw_answer     in varchar2,
        p_user_id       in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        setup_error exception;
    begin
        x_return_status := 'S';
        pc_log.log_error('UPDATE_USER', 'in update user '
                                        || p_user_name
                                        || ' EMAIL '
                                        || p_email
                                        || p_user_type
                                        || p_emp_reg_type);

        pc_log.log_error('UPDATE_USER',
                         'in update user ' || nvl(p_password, 'password not given'));
        if p_user_name is not null then
            update online_users
            set
                password = nvl(p_password, password),
                change_pw = to_char(sysdate, 'YYYY-MM-DD HH:MI:SS'),
                email = nvl(p_email, email),
                pw_question = decode(p_pw_question, null, pw_question, p_pw_question),
                pw_answer = decode(p_pw_answer, null, pw_answer, p_pw_answer),
                confirmed_flag = (
                    case
                        when nvl(confirmed_flag, 'N') = 'N'
                             and emp_reg_type = 1 then
                            'Y'
                        else
                            confirmed_flag
                    end
                ),
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    user_name = p_user_name
                and user_type = p_user_type
                and ( ( p_emp_reg_type is null )
                      or ( emp_reg_type = p_emp_reg_type ) );

        else
            pc_log.log_error('UPDATE_USER', 'in update user ,username not given');
        end if;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end update_users;

    procedure delete_users (
        p_contact_user_id in varchar2,
        p_user_id         in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
    begin
        x_return_status := 'S';

   /*   DELETE FROM ONLINE_USERS
    WHERE
        USER_NAME     = P_USER_NAME;*/
        pc_log.log_error('DELETE_USERS ', 'contact user id ' || p_contact_user_id);
        pc_log.log_error('DELETE_USERS ', 'deleting user id ' || p_user_id);
        update online_users
        set
            user_status = 'D',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            user_id = p_contact_user_id;

        x_error_message := 'User deleted successfully';
    exception
        when others then
            x_return_status := 'U';
            x_error_message := 'Error in deleting the user ';
        --sqlerrm;

    end delete_users;

    procedure delete_er_user (
        p_contact_user_id in number,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
    begin
        x_return_status := 'S';
        update online_users
        set
            user_status = 'D',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            user_id = p_contact_user_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end delete_er_user;
    -- Check if user account is failed attempt to login 3 times
  -- with in 30 min
    function check_user_locked (
        p_user_name in varchar2
    ) return varchar2 is
        l_user_locked varchar2(10) := '0';
    begin
        for x in (
            select
                failed_att,
                locked_time
            from
                online_users
            where
                user_name = p_user_name
        ) loop
            if
                x.failed_att >= 3
                and is_date(x.locked_time, 'YYYY-MM-DD HH:MI:SS') = 'Y'
            then
                l_user_locked := to_char(trunc((sysdate - to_date(x.locked_time, 'YYYY-MM-DD HH:MI:SS')) * 24 * 60));

            end if;
        end loop;

        return l_user_locked;
    exception
        when others then
       --PC_LOG.LOG_ERROR('PC_USERS.CHECK_USER_LOCKED',SQLERRM);
            return '0';
    end check_user_locked;

    function get_email (
        p_acc_num in varchar2,
        p_acc_id  in number,
        p_pers_id in number
    ) return varchar2 is
        l_email varchar2(255);
    begin
        for x in (
            select
                email
            from
                online_users a,
                account      b
            where
                    a.find_key = b.acc_num
                and b.acc_num = nvl(p_acc_num, b.acc_num)
                and b.acc_id = nvl(p_acc_id, b.acc_id)
                and b.pers_id = nvl(p_pers_id, b.pers_id)
        ) loop
            l_email := x.email;
        end loop;

        if
            l_email is null
            and p_pers_id is not null
        then
            for x in (
                select
                    nvl(a.email, b.email) email
                from
                    online_users a,
                    person       b
                where
                        a.tax_id (+) = replace(b.ssn, '-')   --- rprabu 13/05/2025  INC26941 OE Notices not sent to the QB COB1428822 ( GCOB1371250)
                    and b.pers_id = p_pers_id
            ) loop
                l_email := x.email;
            end loop;

        end if;

        return l_email;
    exception
        when others then
            return null;
    end;

    function get_email_from_taxid (
        p_tax_id in varchar2
    ) return varchar2 is
        l_email varchar2(255);
    begin
        for x in (
            select
                email
            into l_email
            from
                online_users a
            where
                    a.tax_id = replace(p_tax_id, '-')
                and a.user_status = 'A'
        ) -- Added by Swamy for Ticket#10978															
         loop
            l_email := x.email;
        end loop;

        if l_email is null then
            for x in (
                select
                    email
                from
                    person a
                where
                        a.ssn = format_ssn(p_tax_id)
                    and person_type = 'SUBSCRIBER'
            ) loop
                l_email := x.email;
            end loop;

        end if;

        return l_email;
    exception
        when others then
            return null;
    end get_email_from_taxid;

    function validate_user (
        p_tax_id       in varchar2,
        p_acc_num      in varchar2,
        p_user_type    in varchar2,
        p_emp_reg_type in varchar2,
        p_user_name    in varchar2,
        p_password     in varchar2,
        p_user_id      in number default null
    ) return varchar2 is

        l_error_message varchar2(3200);
        l_plan_sign     varchar2(30);
        l_user_count    number := 0;
        setup_error exception;
    begin
        if ( p_tax_id in ( '000-00-0000', '999-99-9999', '123-45-6789', '999-00-9999' )
             or p_tax_id like '999%' ) then
            l_error_message := g_invalid_ssn;
            raise setup_error;
        end if;

        pc_log.log_error('USER_CREATION', 'tax id  ' || p_tax_id);
        pc_log.log_error('USER_CREATION', 'password in insert user ' || p_password);
        if check_user_name(p_user_name) = 'N' then
            l_error_message := 'The username cannot contain spaces or special characters.  It can only be letters or a combination of letters and numbers.'
            ;
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
            raise setup_error;
        end if;

        if p_password is not null then
            if
                length(p_user_name) > 24
                and p_user_name is not null
            then
                l_error_message := 'Enter user name that is less than 24 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;

            if
                length(p_user_name) < 6
                and p_user_name is not null
            then
                l_error_message := 'Enter user name that is more than 6 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;

            if
                length(p_password) < 6
                and p_password is not null
            then
                l_error_message := 'Choose password that is more than 6 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;

            if
                length(p_password) > 25
                and p_password is not null
            then
                l_error_message := 'Choose password that is less than 24 character in length';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;

        end if;

        if instr(
            nls_lower(p_password),
            nls_lower(p_user_name)
        ) != 0 then
            l_error_message := 'User name and Password cannot be same';
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
            raise setup_error;
        end if;

        if p_password is not null then
            if regexp_like(p_password, '^.*[^A-Z,0-9].*$') then
                null;
            else
                l_error_message := 'Password value must include a mix of letters, numbers';
             --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;
        end if;

        for x in (
            select
                plan_sign
            from
                account a,
                plans   b
            where
                    a.plan_code = b.plan_code
                and a.acc_num = p_acc_num
        ) loop
            l_plan_sign := x.plan_sign;
        end loop;

        if
            p_user_type = 'S'
            and l_plan_sign = 'SHA'
        then
         /* SELECT COUNT(*)
          INTO l_user_count
          FROM online_users a, account b
          WHERE replace(tax_id,'-') = replace(p_tax_id,'-')
         -- AND   a.find_key = b.acc_num   -- commented by Joshi for INC23052/12714. A user can have only one login  across all accounts
          AND   a.user_type = 'S'
          AND   a.user_status <> 'D';*/
         -- AND   b.account_type IN ('FSA','HRA','HSA','COBRA','RB'); -- -- Added RB by Swamy for Ticket#9656 on 24/03/2021
         -- commented by Joshi for INC23052/12714. A user can have only one login  across all accounts

            select
                count(*)
            into l_user_count
            from
                online_users a
            where
                    replace(a.tax_id, '-') = replace(p_tax_id, '-')
                and a.user_type = 'S'
                and a.user_status <> 'D';

            if l_user_count > 0 then
                l_error_message := g_dup_user_for_tax;
                pc_log.log_error('USER_CREATION', l_error_message);
                raise setup_error;
            end if;

        elsif
            p_user_type = 'E'
            and l_plan_sign = 'SHA'
            and p_emp_reg_type = 2
            and p_user_id is null
        then
            select
                count(*)
            into l_user_count
            from
                online_users a,
                account      b
            where
                    replace(tax_id, '-') = replace(p_tax_id, '-')
                and a.find_key = b.acc_num
                and a.user_type = 'E'
          --AND   a.user_status <> 'D'          -- Commented by swamy for ticket#8123
                and a.user_status not in ( 'D', 'I' )  -- Added by swamy for ticket#8123
                and a.emp_reg_type = p_emp_reg_type
                and b.account_type in ( 'FSA', 'HRA', 'HSA', 'COBRA', 'ERISA_WRAP',
                                        'POP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                        'RB' ); -- ACA added by Swamy for Ticket#10844  -- LSA added by Swamy for Ticket#9912 -- RB Added by Jaggi #11869
            if l_user_count > 0 then
                l_error_message := g_dup_user_for_tax;
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;
        end if;

       -- Does account exist for this tax id
        if
            p_user_type = 'S'
            and l_plan_sign = 'SHA'
            and p_acc_num is not null
        then
            select
                count(*)
            into l_user_count
            from
                acc_overview_v
            where
                    replace(ssn, '-') = replace(p_tax_id, '-')
                and account_type in ( 'FSA', 'HRA', 'HSA', 'COBRA', 'RB',
                                      'LSA' )   -- LSA added by Swamy for Ticket#9912 on 10/08/2021 -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                and acc_num = p_acc_num;

            pc_log.log_error('USER_CREATION', 'SSN ' || p_tax_id);
            pc_log.log_error('USER_CREATION', 'ACC NUM ' || p_acc_num);
            if l_user_count = 0 then
                l_error_message := g_no_tax_ee;
                raise setup_error;
            end if;
        elsif
            p_user_type = 'E'
            and l_plan_sign = 'SHA'
            and p_acc_num is not null
        then
            select
                count(*)
            into l_user_count
            from
                emp_overview_v
            where
                    replace(ein, '-') = replace(p_tax_id, '-')
                and account_type in ( 'FSA', 'HRA', 'HSA', 'COBRA', 'ERISA_WRAP',
                                      'POP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                      'RB' )  -- ACA added by Swamy for Ticket#10844  -- LSA added by Swamy for Ticket#9912 on 10/08/2021
        --  AND   NVL(end_date,SYSDATE) >= SYSDATE                                                                 -- RB Added by Jaggi #11869
                and acc_num = p_acc_num;

            if l_user_count = 0 then
                l_error_message := g_no_tax_er;
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;
            select
                count(*)
            into l_user_count
            from
                emp_overview_v
            where
                    replace(ein, '-') = replace(p_tax_id, '-')
                and account_type in ( 'FSA', 'HRA', 'HSA', 'COBRA', 'ERISA_WRAP',
                                      'POP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                      'RB' ) -- ACA added by Swamy for Ticket#10844   -- LSA added by Swamy for Ticket#9912 on 10/08/2021
                and nvl(end_date, sysdate) >= sysdate;                                                            -- RB Added by Jaggi #11869
          /* Sugar CRM Case..If one of the Accts is closed,users of other accts should be able to create super admins etc*/
            if l_user_count = 0 then
                l_error_message := g_acct_closed_er;
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
                raise setup_error;
            end if;
        end if;

       -- User name not available
        select
            count(*)
        into l_user_count
        from
            online_users
        where
            user_name = p_user_name;

        if l_user_count > 0 then
            l_error_message := 'User Name '
                               || p_user_name
                               || ' not available ';
         --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
            raise setup_error;
        end if;

        return null;
    exception
        when setup_error then
            return l_error_message;
    end validate_user;

    function check_find_key (
        p_tax_id       in varchar2,
        p_acc_num      in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return number is
        l_user_id number;
    begin
        if p_user_type = 'S' then
            for x in (
                select
                    c.user_id
                from
                    person       a,
                    account      b,
                    online_users c
                where
                        a.pers_id = b.pers_id
                    and replace(a.ssn, '-') = replace(p_tax_id, '-')
                    and b.acc_num = p_acc_num
                    and c.user_type = 'S'
             --    AND    C.USER_STATUS = 'A'
                    and c.tax_id = replace(a.ssn, '-')
            ) loop
                l_user_id := x.user_id;
            end loop;
        end if;

        if p_user_type = 'E' then
            for x in (
                select
                    user_id,
                    b.acc_num
                from
                    enterprise   a,
                    account      b,
                    online_users c
                where
                        a.entrp_id = b.entrp_id
                    and replace(a.entrp_code, '-') = replace(p_tax_id, '-')
                    and b.acc_num = p_acc_num
                    and c.emp_reg_type = p_emp_reg_type
                    and c.user_type = 'E'
             --    AND    C.USER_STATUS = 'A'
                    and c.tax_id = replace(a.entrp_code, '-')
            ) loop
                l_user_id := x.user_id;
            end loop;

        end if;

        if p_user_type = 'B' then
            for x in (
                select
                    user_id
                from
                    online_users c
                where
                        replace(c.find_key, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = p_emp_reg_type	  --- 8837 rprabu 14/05/2020
                    and c.user_type = 'B'
            ) loop
                l_user_id := x.user_id;
            end loop;
        end if;

  --- 9527  04/11/2020
        if p_user_type = 'G' then
            for x in (
                select
                    user_id
                from
                    online_users c
                where
                        replace(c.find_key, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = p_emp_reg_type
                    and c.user_type = p_user_type
            ) loop
                l_user_id := x.user_id;
            end loop;
        end if;

        return l_user_id;
    end check_find_key;

    function get_find_key (
        p_tax_id       in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return varchar2 is
        l_find_key varchar2(30);
    begin
        if p_user_type = 'S' then
            for x in (
                select
                    user_id,
                    b.acc_num
                from
                    person       a,
                    account      b,
                    online_users c
                where
                        a.pers_id = b.pers_id
                    and replace(a.ssn, '-') = replace(p_tax_id, '-')
                    and c.user_type = 'S'
                    and b.account_status <> 4
                    and b.account_type not in ( 'COBRA', 'POP' )
                    and c.tax_id = replace(a.ssn, '-')
            ) loop
                l_find_key := x.acc_num;
            end loop;
        end if;

        if p_user_type = 'E' then
            for x in (
                select
                    user_id,
                    b.acc_num
                from
                    enterprise   a,
                    account      b,
                    online_users c
                where
                        a.entrp_id = b.entrp_id
                    and replace(a.entrp_code, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = p_emp_reg_type
                    and c.user_type = 'E'
                    and b.account_type <> 'POP'
                    and nvl(b.end_date, sysdate) >= sysdate
                    and c.tax_id = replace(a.entrp_code, '-')
            ) loop
                l_find_key := x.acc_num;
            end loop;

        end if;

        if p_user_type in ( 'B', 'G' ) then -- Added 'G' by Joshi for 9527
            l_find_key := p_tax_id;
        end if;
        return l_find_key;
    end get_find_key;

    function is_user_existing (
        p_user_name in varchar2
    ) return varchar2 is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            online_users
        where
            user_name = p_user_name;

        if l_count = 0 then
            return 'N';
        else
            return 'Y';
        end if;
    end is_user_existing;

    function is_email_registered (
        p_tax_id in varchar2,
        p_email  in varchar2
    ) return varchar2 is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            online_users
        where
                tax_id = p_tax_id
            and email = p_email;

        if l_count = 0 then
            return 'N';
        else
            return 'Y';
        end if;
    end is_email_registered;

    function get_user (
        p_tax_id       in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return number is
        l_user_id number;
    begin
        if p_user_type = 'S' then
            for x in (
                select
                    user_id,
                    b.acc_num
                from
                    person       a,
                    account      b,
                    online_users c
                where
                        a.pers_id = b.pers_id
                    and c.user_type = 'S'
                    and b.account_type <> 'POP'
                    and replace(a.ssn, '-') = replace(p_tax_id, '-')
                    and c.user_status <> 'D'
                    and c.tax_id = replace(a.ssn, '-')
            ) loop
                l_user_id := x.user_id;
            end loop;
        end if;

        if p_user_type = 'E' then
            for x in (
                select
                    user_id,
                    b.acc_num
                from
                    enterprise   a,
                    account      b,
                    online_users c
                where
                        a.entrp_id = b.entrp_id
                    and c.user_type = 'E'
                    and replace(a.entrp_code, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = p_emp_reg_type
                    and b.account_type <> 'POP'
                    and c.user_status <> 'D'
                    and nvl(b.end_date, sysdate) >= sysdate
                    and c.tax_id = replace(a.entrp_code, '-')
            ) loop
                l_user_id := x.user_id;
            end loop;

        end if;

        if p_user_type = 'B' then
            for x in (
                select
                    user_id
                from
                    online_users c
                where
                        replace(c.find_key, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = p_emp_reg_type    ----- 8837  rprabu 07/05/2020
                    and c.user_status <> 'D'
                    and c.user_type = 'B'
            ) loop
                l_user_id := x.user_id;
            end loop;
        end if;

    --------- 9527   04/11/2020
        if p_user_type = 'G' then
            for x in (
                select
                    user_id
                from
                    online_users c
                where
                        replace(c.find_key, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = p_emp_reg_type    -----
                    and c.user_status <> 'D'
                    and c.user_type = p_user_type
            ) loop
                l_user_id := x.user_id;
            end loop;
        end if;
  --------- ENd 9527   04/11/2020

        return l_user_id;
    end get_user;

    function get_user_name (
        p_user_id in number
    ) return varchar2 is
        l_user_name varchar2(255);
    begin
        for x in (
            select
                user_name
            from
                online_users c
            where
                c.user_id = p_user_id
        ) loop
            l_user_name := x.user_name;
        end loop;

        return l_user_name;
    end get_user_name;

    function get_user_id (
        p_user_name in varchar2
    ) return number is
        l_user_id number;
    begin
        pc_log.log_error('get_user_id ', 'user name ' || p_user_name);
        for x in (
            select
                user_id
            from
                online_users c
            where
                c.user_name = p_user_name
        ) loop
            l_user_id := x.user_id;
        end loop;

        pc_log.log_error('get_user_id ', 'user id ' || l_user_id);
        return l_user_id;
    end get_user_id;

    function get_email_from_user_id (
        p_user_id in number
    ) return varchar2 is
        l_email varchar2(255);
    begin
        for x in (
            select
                email
            from
                online_users c
            where
                c.user_id = p_user_id
        ) loop
            l_email := x.email;
        end loop;

        return l_email;
    end get_email_from_user_id;

    function get_user_count (
        p_tax_id       in varchar2,
        p_user_type    in varchar2 default 'S',
        p_emp_reg_type in number default 2
    ) return number is
        l_user_count number;
    begin
        if p_user_type = 'S' then
            for x in (
                select
                    count(*) cnt
                from
                    online_users c
                where
                        c.tax_id = replace(p_tax_id, '-')
            --   AND    C.USER_STATUS = 'A'
                    and exists (
                        select
                            *
                        from
                            person  a,
                            account b
                        where
                                a.pers_id = b.pers_id
                            and replace(a.ssn, '-') = replace(p_tax_id, '-')
                            and c.tax_id = replace(a.ssn, '-')
                    )
            ) loop
                l_user_count := x.cnt;
            end loop;
        end if;

        if p_user_type = 'E' then
            for x in (
                select
                    count(*) cnt
                from
                    online_users c
                where
                        c.tax_id = replace(p_tax_id, '-')
                    and exists (
                        select
                            *
                        from
                            enterprise a,
                            account    b
                        where
                                a.entrp_id = b.entrp_id
                            and replace(a.entrp_code, '-') = replace(p_tax_id, '-')
                            and c.tax_id = replace(a.entrp_code, '-')
                    )
            ) loop
                if x.cnt > 0 then
                    l_user_count := x.cnt;
                end if;
            end loop;

        end if;

        return l_user_count;
    end get_user_count;

    function is_confirmed (
        p_tax_id    in varchar2,
        p_user_type in varchar2
    ) return varchar2 is
        l_exists varchar2(1) := 'N';
    begin
        if p_user_type = 'S' then
            for x in (
                select
                    count(*) cnt
                from
                    person       a,
                    account      b,
                    online_users c
                where
                        a.pers_id = b.pers_id
                    and replace(a.ssn, '-') = replace(p_tax_id, '-')
               --  AND    C.USER_STATUS = 'A'
                    and c.confirmed_flag = 'Y'
                    and c.tax_id = replace(a.ssn, '-')
            ) loop
                if x.cnt > 0 then
                    l_exists := 'Y';
                end if;
            end loop;
        end if;

        if p_user_type = 'E' then
            for x in (
                select
                    count(*) cnt
                from
                    enterprise   a,
                    account      b,
                    online_users c
                where
                        a.entrp_id = b.entrp_id
                    and replace(a.entrp_code, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = 2
                    and c.confirmed_flag = 'Y'
                    and nvl(b.end_date, sysdate) >= sysdate
                    and c.tax_id = replace(a.entrp_code, '-')
            ) loop
                if x.cnt > 0 then
                    l_exists := 'Y';
                end if;
            end loop;

        end if;

        return l_exists;
    end is_confirmed;

    function check_user_registered (
        p_tax_id    in varchar2,
        p_user_type in varchar2
    ) return varchar2 is
        l_exists varchar2(1) := 'N';
    begin
        if p_user_type = 'S' then
            for x in (
                select
                    count(*) cnt
                from
                    person       a,
                    account      b,
                    online_users c
                where
                        a.pers_id = b.pers_id
                    and replace(a.ssn, '-') = replace(p_tax_id, '-')
              --   AND    C.USER_STATUS = 'A'
                    and c.tax_id = replace(a.ssn, '-')
            ) loop
                if x.cnt > 0 then
                    l_exists := 'Y';
                end if;
            end loop;
        end if;

        if p_user_type = 'E' then
            for x in (
                select
                    count(*) cnt
                from
                    enterprise   a,
                    account      b,
                    online_users c
                where
                        a.entrp_id = b.entrp_id
                    and replace(a.entrp_code, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = 2
                    and nvl(b.end_date, sysdate) >= sysdate
                    and c.tax_id = replace(a.entrp_code, '-')
            ) loop
                if x.cnt > 0 then
                    l_exists := 'Y';
                end if;
            end loop;

        end if;

        return l_exists;
    end check_user_registered;

    function is_active_user (
        p_tax_id    in varchar2,
        p_user_type in varchar2
    ) return varchar2 is
        l_exists varchar2(1) := 'N';
    begin
        if p_user_type = 'S' then
            for x in (
                select
                    count(*) cnt
                from
                    person       a,
                    account      b,
                    online_users c
                where
                        a.pers_id = b.pers_id
                    and replace(a.ssn, '-') = replace(p_tax_id, '-')
                    and c.user_status = 'A'
                    and b.account_status <> 4
                    and c.tax_id = replace(a.ssn, '-')
            ) loop
                if x.cnt > 0 then
                    l_exists := 'Y';
                end if;
            end loop;
        end if;

        if p_user_type = 'E' then
            for x in (
                select
                    count(*) cnt
                from
                    enterprise   a,
                    account      b,
                    online_users c
                where
                        a.entrp_id = b.entrp_id
                    and replace(a.entrp_code, '-') = replace(p_tax_id, '-')
                    and c.emp_reg_type = 2
                    and c.user_status = 'A'
                    and b.account_status <> 4
                    and nvl(b.end_date, sysdate) >= sysdate
                    and c.tax_id = replace(a.entrp_code, '-')
            ) loop
                if x.cnt > 0 then
                    l_exists := 'Y';
                end if;
            end loop;

        end if;

        return l_exists;
    end is_active_user;

    procedure inactivate_registration (
        p_acc_num         in varchar2 default null,
        p_user_id         in number default null,
        p_contact_user_id in number default null,
        p_user_name       in varchar2 default null
    ) is
        l_ssn    varchar2(30);
        l_no_acc number;
    begin
        pc_log.log_error('inactivate_registration', 'acc num ' || p_acc_num);
        pc_log.log_error('inactivate_registration', 'p_user_id ' || p_user_id);
        pc_log.log_error('inactivate_registration', 'p_contact_user_id ' || p_contact_user_id);
        pc_log.log_error('inactivate_registration', 'p_user_name ' || p_user_name);
        if
            p_user_name is not null
            and p_contact_user_id is null
        then
            update online_users
            set
                user_status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                user_name = p_user_name;

        elsif p_contact_user_id is not null then
            update online_users
            set
                user_status = 'I',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                user_id = p_contact_user_id;

        elsif p_acc_num is not null then
            for x in (
                select
                    tax_id,
                    user_id
                from
                    online_users
                where
                    find_key = p_acc_num
            ) loop
                select
                    count(*)
                into l_no_acc
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and a.ssn = format_ssn(x.tax_id);
         -- if only HSA present then inactivate the registration
                if l_no_acc = 1 then
                    update online_users
                    set
                        user_status = 'I',
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        user_id = x.user_id;

                end if;

            end loop;
        end if;

    end inactivate_registration;

    procedure reactivate_registration (
        p_acc_num in varchar2 default null,
        p_ssn     in varchar2 default null
    ) is
        l_ssn varchar2(30);
    begin
        if
            p_acc_num is not null
            and p_ssn is null
        then
            for x in (
                select
                    a.ssn
                from
                    person  a,
                    account b
                where
                        a.pers_id = b.pers_id
                    and b.acc_num = p_acc_num
            ) loop
                l_ssn := x.ssn;
            end loop;
        else
            l_ssn := p_ssn;
        end if;

        for x in (
            select
                a.acc_num,
                b.birth_date,
                replace(b.ssn, '-') tax_id
            from
                account a,
                person  b
            where
                replace(b.ssn, '-') in (
                    select
                        d.tax_id
                    from
                        account      c, online_users d
                    where
                            c.acc_num = d.find_key
                        and ( l_ssn is null
                              or d.tax_id = replace(l_ssn, '-') )
                        and c.account_status = 4
                )
                and a.pers_id = b.pers_id
                and a.account_status <> 4
                and ( l_ssn is null
                      or b.ssn = l_ssn )
                and not exists (
                    select
                        *
                    from
                        online_users c
                    where
                        c.find_key = a.acc_num
                )
        ) loop
            update online_users
            set
                user_status = 'A',
                reactivated_date = sysdate,
                last_update_date = sysdate
            where
                    tax_id = x.tax_id
                and user_type = 'S';

        end loop;

    end reactivate_registration;

    procedure reactivate_er_registration (
        p_acc_num         in varchar2 default null,
        p_ein             in varchar2 default null,
        p_contact_user_id in number default null,
        p_user_id         in number default null
    ) is
        l_ein varchar2(30);
    begin
        if p_contact_user_id is not null then
            update online_users
            set
                user_status = 'A',
                reactivated_date = sysdate,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    user_id = p_contact_user_id
                and user_type in ( 'B', 'E', 'G' );  -- 8874 12/05/2020 -- 9527 Joshi added 'G'
        elsif p_acc_num is not null then
            if p_ein is null then
                for x in (
                    select
                        a.entrp_code
                    from
                        enterprise a,
                        account    b
                    where
                            a.entrp_id = b.entrp_id
                        and b.acc_num = p_acc_num
                ) loop
                    l_ein := x.entrp_code;
                end loop;
            else
                l_ein := p_ein;
            end if;

            for x in (
                select
                    replace(b.entrp_code, '-') tax_id
                from
                    account    a,
                    enterprise b
                where
                    replace(b.entrp_code, '-') in (
                        select
                            d.tax_id
                        from
                            account      c, online_users d
                        where
                                c.acc_num = d.find_key
                            and ( l_ein is null
                                  or d.tax_id = replace(l_ein, '-') )
                            and ( c.account_status = 4
                                  or c.end_date is not null )
                    )
                    and a.entrp_id = b.entrp_id
                    and a.account_status <> 4
                    and ( l_ein is null
                          or replace(b.entrp_code, '-') = replace(l_ein, '-') )
                    and not exists (
                        select
                            *
                        from
                            online_users c
                        where
                            c.find_key = a.acc_num
                    )
            ) loop
                update online_users
                set
                    user_status = 'A',
                    reactivated_date = sysdate,
                    last_update_date = sysdate
                where
                        tax_id = x.tax_id
                    and user_type = 'E';

            end loop;

        end if;
    end reactivate_er_registration;

    function validate_ee_reg (
        p_acc_num    in varchar2,
        p_tax_id     in varchar2,
        p_user_name  in varchar2,
        p_birth_date in varchar2
    ) return varchar2 is
        validation_error exception;
        l_count         number := 0;
        l_error_message varchar2(3200) := 'SUCCESS';
    begin
        pc_log.log_error('validate_ee_reg,DOB ', p_birth_date);
        pc_log.log_error('validate_ee_reg,p_user_name ', p_user_name);
        pc_log.log_error('validate_ee_reg,p_acc_num ', p_acc_num);
        if p_acc_num is not null then
            select
                count(*)
            into l_count
            from
                account
            where
                acc_num = p_acc_num;

            if l_count = 0 then
                l_error_message := 'We are unable to process your request as the Account Number entered does not match with what we have on record.'
                ;
                raise validation_error;
            end if;
        end if;

     --We want to allow pending manual enrollments to be able to register , so updating with new code. 03/13/2018.

   /*FOR X IN (select CASE WHEN (ACCOUNT_STATUS NOT IN (1,2) OR COMPLETE_FLAG = 0)
                      AND ENROLL_FLAG = 0 THEN
                      'N'
                      WHEN  (ACCOUNT_STATUS <> 1 OR COMPLETE_FLAG = 0)
                      AND ENROLL_FLAG > 0 THEN
                                       'Y'
                      ELSE
                            'Y'
                END COMPLETE_FLAG, ACC_NUM ,
                BLOCKED_FLAG,
                BIRTH_DATE,
                ACCOUNT_TYPE,
                SSN
               from ACCOUNT_V
               where ACC_NUM=p_acc_num*/

        for x in (
            select
                case
                    when account_status in ( 1, 2, 3 )
                         and complete_flag = 1 then
                        'Y'
                    when account_status in ( 4, 5 ) then
                        'N'
                    when complete_flag = 0
                         and enroll_flag = 0 then
                        'N'
                    else
                        'Y'
                end complete_flag,
                acc_num,
                blocked_flag,
                birth_date,
                account_type,
                ssn
            from
                account_v
            where
                acc_num = p_acc_num
        ) loop
            if
                x.account_type in ( 'HSA', 'LSA' )
                and ( x.blocked_flag = 'Y'
                or x.complete_flag = 'N' )
            then   -- LSA Added by Swamy for Ticket#9912(10164)
                l_error_message := 'We have trouble processing your registration request at this time because your Account is in incomplete or closed, Contact Customer Service for further information'
                ;
                raise validation_error;
            end if;

            if to_char(x.birth_date, 'YYYY-MM-DD') <> p_birth_date then
                l_error_message := 'We are unable to process your request as the Date of Birth entered does not match with what we have in record'
                ;
                raise validation_error;
            end if;

            pc_log.log_error('validate_ee_reg,ssn ', p_tax_id);
            pc_log.log_error('validate_ee_reg,x.ssn ', x.ssn);
            if x.ssn <> p_tax_id then
                l_error_message := 'We are unable to process your request as the Social Security Number entered does not match with what we have in record'
                ;
                raise validation_error;
            end if;

     --Ticket#2487.Validate SSN w/o dashes
            if p_tax_id <> format_ssn(p_tax_id) then
                l_error_message := 'Please re-enter your Social Security Number with  dashes XXX-XX-XXXX';
                raise validation_error;
            end if;

            if
                x.ssn <> p_tax_id
                and to_char(x.birth_date, 'YYYY-MM-DD') <> p_birth_date
            then
                l_error_message := ' The information you entered does not match with our records. Please try again';
                raise validation_error;
            end if;

            l_count := 1;
        end loop;

        if l_count = 0 then
            l_error_message := 'Access has already been granted, please contact the person within your organization that has Super Administrative Access'
            ;
            raise validation_error;
        end if;
        pc_log.log_error('validate_ee_reg,l_error_message ', l_error_message);
        return l_error_message;
    exception
        when validation_error then
            return l_error_message;
    end validate_ee_reg;

    function validate_er_reg (
        p_acc_num   in varchar2,
        p_tax_id    in varchar2,
        p_user_name in varchar2,
        p_zip_code  in varchar2
    ) return varchar2 is
        validation_error exception;
        l_count         number := 0;
        l_error_message varchar2(3200) := 'SUCCESS';
    begin
        if p_acc_num is not null then
            select
                count(*)
            into l_count
            from
                account
            where
                acc_num = p_acc_num;

            if l_count = 0 then
                l_error_message := 'We are unable to process your request as the Account Number entered does not match with what we have on record.'
                ;
                raise validation_error;
            end if;
        end if;

        for x in (
            select
                zip,
                ein
            from
                emp_overview_v
            where
                acc_num = p_acc_num
        ) loop
            if substr(x.zip, 1, 5) <> substr(p_zip_code, 1, 5) then
                l_error_message := 'We are unable to process your request as the zip code entered does not match with what we have in record'
                ;
                raise validation_error;
            end if;

            if replace(x.ein, '-') <> replace(p_tax_id, '-') then
                l_error_message := 'We are unable to process your request as the Tax ID entered does not match with what we have in record'
                ;
                raise validation_error;
            end if;

            l_count := 1;
        end loop;

        if l_count = 0 then
            l_error_message := 'We are unable to process your request as the Tax ID entered does not match with what we have in record'
            ;
        end if;
        l_count := 0;
        select
            count(*)
        into l_count
        from
            online_users
        where
                tax_id = replace(p_tax_id, '-')
            and emp_reg_type = '2'
            and user_type = 'E'
            and user_status <> 'D';

        if l_count > 0 then
            l_error_message := 'Access has already been granted, please contact the person within your organization that has Super Administrative Access'
            ;
        end if;
        return l_error_message;
    exception
        when validation_error then
            return l_error_message;
    end validate_er_reg;

    procedure unlock_user (
        p_user_name in varchar2,
        p_password  in varchar2
    ) is
        pragma autonomous_transaction;
    begin
        if p_password is not null then
            update online_users
            set
                locked_time = null,
                failed_att = 0
     --   , blocked = 'N'
                ,
                locked_reason =
                    case
                        when locked_reason is not null then
                            null
                        else
                            locked_reason
                    end,
                last_login = to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
                security_setup_grace = nvl(security_setup_grace, sysdate + 30),
                succ_access = nvl(succ_access, 0) + 1
            where
                user_name = p_user_name;

        else
            update online_users
            set
                locked_time = null,
                failed_att = 0
    --    ,  blocked = 'N'
                ,
                locked_reason = null,
                last_login = to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
                security_setup_grace = nvl(security_setup_grace, sysdate + 30)
            where
                    user_name = p_user_name
                and ( sysdate - to_date(locked_time, 'YYYY-MM-DD HH24:MI:SS') ) * 1440 > 30
                and locked_reason = 'WRONG_PASSWORD';

        end if;

        commit;
    end unlock_user;

    function get_user_info (
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_skip_security in varchar2 default 'N',
        p_referrer      in varchar2 -- anticipating for future login request
        ,
        p_sso_user      in varchar2
    ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
     return user_info_t
        pipelined
        deterministic
    is

        e_user_exception exception;
        l_count              number := 0;
        l_error_message      varchar2(3200);
        l_login              varchar2(1) := 'N';
        l_loggedin           varchar2(1) := 'N';
        l_skip_security      varchar2(10) := 'N';
        l_no_of_registration number := 0;
        l_record_t           user_info_row_t;
        l_user_id            number;
        l_no_accounts        number := 0;
        l_old_acct           varchar2(2) := 'O';
        l_plans_enrolled     number := 0;
    begin
        for x in (
            select
                *
            from
                online_users
            where
                user_name = trim(p_user_name)
        ) loop
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'user_name ' || p_user_name);
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'password ' || p_password);
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'p_referrer ' || p_referrer);
            l_count := l_count + 1;
            l_record_t.user_id := x.user_id;
            l_record_t.user_name := p_user_name;
            l_record_t.error_status := 'S';
            l_record_t.password := x.password;
            l_record_t.user_type := x.user_type;
            l_record_t.emp_reg_type := x.emp_reg_type;
            l_record_t.tax_id := x.tax_id;
            l_record_t.confirmed_flag := nvl(x.confirmed_flag, 'N');
            l_record_t.email := x.email;
            l_record_t.acc_num := x.find_key;
            l_record_t.locked_reason := x.locked_reason;
            l_record_t.first_time_pw_flag := x.first_time_pw_flag;
            l_record_t.logged_in := 'N';
            l_record_t.security_setup := pc_user_security_pkg.security_setting_exist(x.user_id);
            if l_record_t.allow_login is null then
                l_record_t.allow_login := 'Y';
            end if;
            l_record_t.pw_reminder_qut := x.pw_question;
            l_record_t.pw_reminder_ans := x.pw_answer;
            l_skip_security := 'N';
            if nvl(x.sso_user, 'N') = 'Y' then
                l_record_t.sec_exist := 'Y';
            else
                l_record_t.sec_exist := nvl(
                    pc_user_security_pkg.security_setting_exist(x.user_id),
                    'N'
                );
            end if;

            l_record_t.locked_account := 'N';
            if
                p_skip_security = 'Y'
                and p_sso_user = 'Y'
            then
                l_skip_security := 'Y';
                l_record_t.sso_user := 'Y';
            else
                if x.creation_date < '10-OCT-2013' then
                    l_skip_security := nvl(p_skip_security, 'N');
                else
                    l_skip_security := 'N';
                end if;
            end if;

            if
                p_referrer in ( 'STERLING', 'PASSWORD_PAGE' )
                and p_password is null
            then
                l_error_message := '20016: Password is Required, Enter a valid password .';
                l_record_t.allow_login := 'Y';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            if
                p_password is not null
                and p_password = x.password
            then
                unlock_user(p_user_name, p_password);
            end if;

            pc_log.log_error('PC_USERS.GET_USER_INFO', 'locked_reason ' || x.locked_reason);
            if x.locked_reason = 'WRONG_PASSWORD' then
                if x.failed_att >= 3 then
                    if ( sysdate - to_date ( x.locked_time, 'YYYY-MM-DD HH24:MI:SS' ) ) * 1440 < 30 then
                        l_error_message := '20011: Your account is temporarily suspended for 30 minutes for invalid login attempts.';
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    end if;

                end if;
            elsif
                x.locked_reason <> 'WRONG_PASSWORD'
                and x.failed_att >= 3
            then
                l_error_message := '20012: Your account has been locked. Please contact customer service and verify your identity to unlock your account.'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            pc_log.log_error('PC_USERS.GET_USER_INFO', 'password ' || p_password);

    -- Added for spanish site support
            if
                p_referrer not in ( 'STERLING', 'PASSWORD_PAGE' )
                and l_record_t.password <> p_password
            then
                l_error_message := '20010: Your user name /password does not match our records, please verify your password once again'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                raise e_user_exception;
            end if;
     --
            if
                l_record_t.password <> p_password
                and p_password is not null
            then
                l_error_message := '20010: Your user name /password does not match our records, please verify your password once again'
                ;
                l_record_t.allow_login := 'Y';
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                raise e_user_exception;
            end if;

     -- check if user had confirmed registration
            if
                nvl(x.emp_reg_type, 0) <> 1
                and nvl(x.confirmed_flag, 'N') = 'N'
                and nvl(x.first_time_pw_flag, 'N') = 'N'
            then
                l_error_message := 'We''re sorry, but you cannot access your account until you have confirmed your email. The link for this confirmation can be found in the confirmation email that was sent to the email account that you provided during registration for online access. If you have any questions, please contact us at Customer.Service@sterlingadministration.com or call 800.617.4729 during business hours'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
     -- check if user is inactive
            if x.user_status in ( 'D', 'I' ) then
                l_error_message := '20003: Your account is no longer active, please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
     -- check if user failed attempts more than 3 times and tried with in 30 minutes
            if
                nvl(x.failed_att, 0) >= 3
                and is_date(x.locked_time, 'yyyy-mm-dd hh24:mi:ss') = 'Y'
                and 60 / ( ( sysdate - to_date ( x.locked_time, 'yyyy-mm-dd hh24:mi:ss' ) ) * 100 ) <= 30
                and p_password <> x.password
                and p_password is not null
            then
                l_error_message := '20004: Your account is temporarily locked. Please try again after 30 minutes';
                l_record_t.allow_login := 'N';
                raise e_user_exception;
            end if;
     -- check if SSN has invalid ones , I mean the generic ones
            if x.tax_id in ( '000000000', '999999999', '123456789', '999009999' ) then
                l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

     -- check if SSN has invalid ones , I mean the generic ones
     -- got this info from http:--www.aila.org/content/default.aspx?docid=36839
            if
                x.user_type = 'S'
                and ( substr(x.tax_id, 1, 3) in ( '000', '666', '900' )
                      or substr(x.tax_id, 4, 2) in ( '00' )
                or substr(x.tax_id, 6, 4) in ( '0000' ) )
            then
                l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
     -- http://www.irs.gov/irm/part21/irm_21-007-013r.html
     -- Invalid EIN Prefixes are 00, 07, 08, 09, 17, 18, 19, 28, 29, 49, 69, 70, 78, 79 and 89. EINs
     -- with one of these prefixes should never be put on Master File with a TC 000.
            if
                x.user_type = 'E'
                and substr(x.tax_id, 1, 2) in ( '00', '07', '08', '09', '17',
                                                '18', '19', '28', '29', '49',
                                                '69', '70', '78', '79', '89' )
            then
                l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            if x.tax_id is null then
                l_login := 'N';
                l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            select
                count(*)
            into l_no_of_registration
            from
                online_users
            where
                ( emp_reg_type is null
                  or emp_reg_type <> 1 )
                and tax_id = x.tax_id
                and user_status = 'A'
                and user_type = 'S'
                and user_type = x.user_type;

            if l_no_of_registration > 1 then
                l_error_message := '20006: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
    /*
     IF  (NVL(x.first_time_pw_flag,'N') = 'Y' AND x.user_type = 'E'
    -- OR  x.password = '5f4dcc3b5aa765d61d8327deb' -- this is encrypted word for password
     )
     THEN
        l_record_t.redirect_url := 'Accounts/Accounts/ChangePassword/';  -- new view to be created for this
        l_record_t.change_password := 'Y';
        l_login := 'N';
         RAISE  e_user_exception;
     END IF;
     */
            l_record_t.skip_security := 'Y';
            if
                nvl(x.failed_att, 0) < 3
                and is_date(x.locked_time, 'yyyy-mm-dd hh24:mi:ss') = 'Y'
                and 60 / ( ( sysdate - to_date ( x.locked_time, 'yyyy-mm-dd hh24:mi:ss' ) ) * 100 ) > 30
            then
                l_login := 'Y';
            end if;

            if
                x.user_type = 'E'
                and x.emp_reg_type = 1
            then
                if p_password is null then
                    l_record_t.sec_exist := 'Y';
                    l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                    l_login := 'Y';
                    raise e_user_exception;
                elsif p_password is not null then
                    l_record_t.sec_exist := 'Y';
                    l_record_t.redirect_url := 'EnrollmentExpress/Enrollment/';
                    l_login := 'Y';
                    raise e_user_exception;
                end if;
            else
                if l_skip_security = 'Y' then
                    l_record_t.sec_grace_days := 30;
                    l_record_t.sec_exist := 'Y';
                else
                    if p_password is null then
                        l_record_t.sec_grace_days :=
                            case
                                when
                                    x.security_setup_grace is null
                                    and x.creation_date < '19-OCT-2013'
                                then
                                    30
                                when
                                    x.security_setup_grace is null
                                    and x.creation_date > '19-OCT-2013'
                                then
                                    0
                                else round(x.security_setup_grace - sysdate)
                            end;

                        l_record_t.sec_exist := nvl(
                            pc_user_security_pkg.security_setting_exist(x.user_id),
                            'N'
                        );

                        l_skip_security := 'N';
                        if
                            nvl(l_record_t.sec_grace_days, 0) > 0
                            and l_record_t.sec_exist = 'N'
                        then
                            l_record_t.redirect_url := 'Accounts/Accounts/SecuritySkip/';
                        else
                            l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                        end if;

                        l_login := 'N';
                        raise e_user_exception;
                    end if;



      /*  ELSE
            IF  PC_USER_SECURITY_PKG.security_setting_exist(x.user_id) = 'N'
            AND ROUND(x.security_setup_grace-SYSDATE) <= 0
            THEN
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';  -- new view to be created for this
                l_record_t.sec_grace_days := ROUND(x.security_setup_grace-SYSDATE);
                l_record_t.sec_exist := 'N';
                l_login := 'N';
                RAISE  e_user_exception;
            ELSE
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';  -- new view to be created for this
                l_record_t.sec_grace_days := ROUND(x.security_setup_grace-SYSDATE);
                l_record_t.sec_exist := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id) ;
                l_login := 'N';
                RAISE  e_user_exception;
            END IF;*/
     --   END IF;
                end if;
            end if;

      -- all conditions passed , letting the user login

            if x.user_type = 'B' then
                l_record_t.redirect_url := 'Brokers/Detail/BrokerDashboard/';
                l_record_t.acc_num := x.find_key;
                l_record_t.account_type := '';
                for xx in (
                    select
                        b.first_name
                        || nvl(b.middle_name || ' ', '')
                        || b.last_name name
                    from
                        broker a,
                        person b
                    where
                            a.broker_lic = x.find_key
                        and a.broker_id = b.pers_id
                ) loop
                    l_record_t.display_name := xx.name;
                end loop;

                l_login := 'Y';
            end if;

            pc_log.log_error('PC_USERS.GET_USER_INFO', 'x.user_type ' || x.user_type);
            if x.user_type = 'S' then
                for xx in (
                    select
                        count(*) cnt
                    from
                        account a,
                        person  b
                    where
                            b.ssn = format_ssn(x.tax_id)
                        and a.pers_id = b.pers_id
                        and a.account_type in ( 'HSA', 'HRA', 'FSA', 'COBRA', 'LSA' )   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                    union
                    select
                        count(*) cnt
                    from
                        account a,
                        person  b
                    where
                            b.ssn = format_ssn(x.tax_id)
                        and a.pers_id = b.pers_id
                        and a.account_type = 'COBRA'    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                        and account_status <> 4
                ) loop
                    l_record_t.no_of_accounts := xx.cnt;
                    pc_log.log_error('PC_USERS.GET_USER_INFO', 'no_of_accounts ' || xx.cnt);
                    if xx.cnt > 1 then
                        l_record_t.portfolio_account := 'Y';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/';
                        for xxx in (
                            select
                                b.first_name
                                || nvl(b.middle_name || ' ', '')
                                || b.last_name name
                            from
                                person b
                            where
                                b.ssn = format_ssn(x.tax_id)
                        ) loop
                            l_record_t.display_name := xxx.name;
                        end loop;

                    elsif xx.cnt = 1 then
                        for xxx in (
                            select
                                a.account_type,
                                a.acc_id,
                                a.acc_num,
                                c.plan_sign,
                                a.complete_flag,
                                b.first_name
                                || ' '
                                || nvl(b.middle_name || ' ', '')
                                || b.last_name name
                            from
                                account a,
                                person  b,
                                plans   c
                            where
                                    b.ssn = format_ssn(x.tax_id)
                                and a.account_type in ( 'HSA', 'HRA', 'FSA', 'LSA' )     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                                and a.pers_id = b.pers_id
                                and c.plan_code = a.plan_code
                            union
                            select
                                a.account_type,
                                a.acc_id,
                                a.acc_num,
                                c.plan_sign,
                                a.complete_flag,
                                b.first_name
                                || ' '
                                || nvl(b.middle_name || ' ', '')
                                || b.last_name name
                            from
                                account a,
                                person  b,
                                plans   c
                            where
                                    b.ssn = format_ssn(x.tax_id)
                                and a.account_type = 'COBRA'
                                and a.pers_id = b.pers_id
                                and c.plan_code = a.plan_code
                                and account_status <> 4
                        ) loop
                            pc_log.log_error('PC_USERS.GET_USER_INFO', 'xxx.account_type ' || xxx.account_type);
                            if xxx.plan_sign <> 'SHA' then
                                l_login := 'N';
                                l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                                ;
                                l_record_t.allow_login := 'N';
                                l_record_t.locked_account := 'Y';
                                raise e_user_exception;
                            else
                                l_record_t.portfolio_account := 'N';
                                l_record_t.acc_num := xxx.acc_num;
                                l_record_t.acc_id := xxx.acc_id;
                                l_record_t.display_name := xxx.name;
                                l_record_t.account_type := xxx.account_type;
                                if xxx.complete_flag = 0 then
                                    l_record_t.redirect_url := 'AccountHolders/OnlineEnrollment/CompleteEnrollment/';
                                else
                                    if xxx.account_type = 'HSA' then
                                        l_record_t.redirect_url := 'AccountHolders/Detail/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'HRA' then
                                        l_record_t.redirect_url := 'HRA/AccountHolders/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'FSA' then
                                        l_record_t.redirect_url := 'FSA/AccountHolders/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'COBRA' then
                                        l_record_t.redirect_url := 'COBRA/AccountHolders/AccountHolderDashboard/';--'Accounts/Portfolio/';
                                    elsif xxx.account_type = 'LSA' then  -- Added LSA by Swamy for Ticket#9912 on 10/08/2021
                                        l_record_t.redirect_url := 'LSA/AccountHolders/Detail/AccountHolderDashboard/';
                                    end if;
                                end if;

                                l_login := 'Y';
                            end if;

                        end loop;
                    else
                        l_login := 'N';
                        l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                        ;
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    end if;

                end loop;
            end if;

            if
                x.user_type = 'E'
                and x.emp_reg_type in ( 4, 5, 2 )
            then
       --Employer Online Portal
       --We validate if it is a new user or old/existing one.
       --New user gets directed to a new URL whereas for existing users everything remains same

                if pc_users.enroll_new_acct(x.user_id) = 'Y' then
                    l_old_acct := 'N'; --New Acct
                else
                    l_old_acct := 'O'; --Old Acct
                end if;

     --   IF l_old_acct = 'O' THEN   --Old and existing User
                for xx in (
                    select
                        count(*) cnt,
                        sum(
                            case
                                when a.account_status = 3 then
                                    1
                                else
                                    0
                            end
                        )        pending,
                        sum(
                            case
                                when a.account_status <> 3 then
                                    1
                                else
                                    0
                            end
                        )        active_count
                    from
                        account    a,
                        enterprise b
                    where
                            replace(b.entrp_code, '-') = x.tax_id
                        and a.entrp_id = b.entrp_id
                        and ( ( x.emp_reg_type in ( 2, 5 )
                                and a.account_type in ( 'HRA', 'HSA', 'FSA', 'COBRA', 'ERISA_WRAP',
                                                        'POP', 'FORM_5500', 'LSA' ) )     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                              or ( x.emp_reg_type = 4
                                   and a.account_type in (
                            select
                                account_type
                            from
                                user_role_entries b, site_navigation   c
                            where
                                    b.user_id = x.user_id
                                and b.site_nav_id = c.site_nav_id
                        ) ) )
                        and account_status <> 4
                ) loop
                    l_record_t.no_of_accounts := xx.cnt;
                    if xx.active_count > 1 then
                        l_record_t.portfolio_account := 'Y';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/';
                        for xxx in (
                            select
                                b.name
                            from
                                enterprise b
                            where
                                replace(b.entrp_code, '-') = replace(x.tax_id, '-')
                        ) loop
                            l_record_t.display_name := xxx.name;
                        end loop;

                    elsif
                        xx.active_count = 0
                        and xx.pending >= 1
                    then
                        l_record_t.portfolio_account := 'N';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll';
                        for xxx in (
                            select
                                b.name
                            from
                                enterprise b
                            where
                                replace(b.entrp_code, '-') = replace(x.tax_id, '-')
                        ) loop
                            l_record_t.display_name := xxx.name;
                        end loop;

                    elsif xx.active_count = 1 then
                        for xxx in (
                            select
                                a.account_type,
                                a.acc_id,
                                a.acc_num,
                                c.plan_sign,
                                b.name
                            from
                                account    a,
                                enterprise b,
                                plans      c
                            where
                                    replace(b.entrp_code, '-') = x.tax_id
                                and c.plan_code = a.plan_code
                                and a.entrp_id = b.entrp_id
                                and a.account_status <> 3
                                and ( ( x.emp_reg_type in ( 2, 5 )
                                        and a.account_type in ( 'HRA', 'HSA', 'FSA', 'COBRA', 'ERISA_WRAP',
                                                                'POP', 'FORM_5500', 'LSA' ) )     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                                      or ( x.emp_reg_type = 4
                                           and a.account_type in (
                                    select
                                        account_type
                                    from
                                        user_role_entries b, site_navigation   c
                                    where
                                            b.user_id = x.user_id
                                        and b.site_nav_id = c.site_nav_id
                                ) ) )
                                and account_status <> 4
                        ) loop
                            if xxx.plan_sign <> 'SHA' then
                                l_login := 'N';
                                l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                                ;
                                l_record_t.allow_login := 'N';
                                l_record_t.locked_account := 'Y';
                                raise e_user_exception;
                            else
                                l_record_t.portfolio_account := 'N';
                                l_record_t.acc_num := xxx.acc_num;
                                l_record_t.acc_id := xxx.acc_id;
                                l_record_t.display_name := xxx.name;
                                l_record_t.account_type := xxx.account_type;
                                if xxx.account_type = 'HSA' then
                                    l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                                elsif xxx.account_type = 'HRA' then
                                    l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'FSA' then
                                    l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'COBRA' then
                                    l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'ERISA_WRAP' then
                                    l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'POP' then
                                    l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'FORM_5500' then
                                    l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'LSA' then
                                    l_record_t.redirect_url := 'Employers/LSADetail/EmployerDashboard/';   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                                else
                                    l_record_t.redirect_url := 'Accounts/Portfolio/';
                                end if;

                                l_login := 'Y';
                            end if;
                        end loop;
               --    END IF;
                        l_record_t.portfolio_account := 'N';
                        l_login := 'Y';
                    else
                        l_login := 'N';
                        l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                        ;
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    end if;

                end loop;
    /*   ELSE --New User
         --If New USer has not enrolled in any plans of the associated products
         --then we show Accounts/Portfolio/newEREnroll link.
         --Else even if one product is enrolled,we show other link.
          BEGIN
            SELECT count(*)
            INTO l_plans_enrolled
            from ACCOUNT A,ENTERPRISE B
            where a.entrp_id = b.entrp_id
            and replace(b.entrp_code,'-') = replace(X.tax_id,'-')
            and account_status <> 4 --Closed accts eliminated
            and a.complete_flag = 1; --enrollment complete
           -- AND EXISTS(select * from ben_plan_enrollment_setup d --HSA plans are not covered in ben plan setup
                  --           where d.acc_id = a.acc_id);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_plans_enrolled := 0;
          END ;
  pc_log.log_error('In users', l_plans_enrolled);
         IF l_plans_enrolled = 1 THEN --Only one plan enrolled takes to Account Summary
             FOR Y IN (SELECT acc_id ,account_type
                 from ACCOUNT A,ENTERPRISE B
                 where a.entrp_id = b.entrp_id
                 and replace(b.entrp_code,'-') = replace(X.tax_id,'-')
                 and complete_flag = 1--enrollment complete
                 and account_status <> 4 --Closed accts eliminated
                -- AND EXISTS(select * from ben_plan_enrollment_setup d
                  --           where d.acc_id = a.acc_id)
                       )
             LOOP
               pc_log.log_error('In users', 'In loop'||Y.account_type);

                l_plans_enrolled := '1';
                IF Y.account_type = 'POP' THEN
                   l_login := 'Y';
                   l_record_t.portfolio_account := 'N';
                   l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'COBRA' THEN
                   l_login := 'Y';
                   l_record_t.portfolio_account := 'N';
                   l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'ERISA_WRAP' THEN
                   l_login := 'Y';
                   l_record_t.portfolio_account := 'N';
                   l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'FORM_5500' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                ELSIF Y.account_type = 'HSA' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                 ELSIF Y.account_type = 'HRA' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                 ELSIF Y.account_type = 'FSA' THEN
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
               END IF;
             END LOOP;
         ELSIF l_plans_enrolled > 1 THEN   --more than one plans
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := '/Accounts/Portfolio/';
         ELSIF  l_plans_enrolled = 0 THEN --No plans enrolled
                  l_login := 'Y';
                  l_record_t.portfolio_account := 'N';
                  l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll/';
         END IF;

       END IF;--New user IF */
            end if;

            l_user_id := x.user_id;
            if p_skip_security = 'N' then
                if ( x.security_setup_grace is null
                     or (
                    x.security_setup_grace is not null
                    and round(x.security_setup_grace - sysdate) < 30
                ) ) then
                    l_record_t.sec_grace_days :=
                        case
                            when x.security_setup_grace is null then
                                30
                            else round(x.security_setup_grace - sysdate)
                        end;

                    l_login := 'Y';
                    l_record_t.sec_exist := nvl(
                        pc_user_security_pkg.security_setting_exist(x.user_id),
                        'N'
                    );

                    if
                        l_record_t.sec_exist = 'N'
                        and p_password is null
                        and l_record_t.sec_grace_days > 0
                    then
                        l_record_t.redirect_url := 'Accounts/Accounts/SecuritySkip/';  -- new view to be created for this
                    else
                        if p_password is null then
                            l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';  -- new view to be created for this
                        end if;
                    end if;

                end if;
            end if;

            l_loggedin := l_login;
            if p_password is null then
                l_loggedin := 'N';
            end if;
            if l_login = 'Y' then
                for xx in (
                    select
                        site_key,
                        site_image,
                        pw_question1,
                        pw_answer1,
                        pw_question2,
                        pw_answer2,
                        pw_question3,
                        pw_answer3,
                        remember_pc,
                        pc_insure.get_eob_status(x.tax_id) eob_status
                    from
                        user_security_info
                    where
                        user_id = x.user_id
                ) loop
                    l_record_t.site_key := xx.site_key;
                    l_record_t.site_image := xx.site_image;
                    l_record_t.pw_question1 := pc_user_security_pkg.get_security_question(xx.pw_question1);
                    l_record_t.pw_answer1 := xx.pw_answer1;
                    l_record_t.pw_question2 := pc_user_security_pkg.get_security_question(xx.pw_question2);
                    l_record_t.pw_answer2 := xx.pw_answer2;
                    l_record_t.pw_question3 := pc_user_security_pkg.get_security_question(xx.pw_question3);
                    l_record_t.pw_answer3 := xx.pw_answer3;
                    l_record_t.remember_pc := xx.remember_pc;
                    l_record_t.eob_status := xx.eob_status;
                end loop;
            end if;

            l_record_t.logged_in := l_loggedin;
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'redirect_url ' || l_record_t.redirect_url);
            pipe row ( l_record_t );
        end loop;

        if l_count = 0 then
            l_error_message := '20008: The username you have entered is not found in our records.Please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com '
            ;
            l_record_t.allow_login := 'N';
            l_record_t.locked_account := 'Y';
            raise e_user_exception;
        end if;

    exception
        when e_user_exception then
            l_record_t.user_name := p_user_name;
            pc_log.log_error('GET_USER_INFO', 'l_error_message ' || l_error_message);
            pc_log.log_error('GET_USER_INFO', 'redirect_url ' || l_record_t.redirect_url);
            if l_error_message is not null then
                l_record_t.error_message := l_error_message;
                l_record_t.error_status := 'E';
                if l_record_t.redirect_url is null then
                    l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                    l_record_t.allow_login := 'N';
                end if;

            end if;

            l_loggedin := l_login;
            if p_password is null then
                l_loggedin := 'N';
            end if;
            l_record_t.logged_in := nvl(l_loggedin, 'N');
            pipe row ( l_record_t );
        when others then
            l_record_t.user_name := p_user_name;
            l_record_t.error_message := sqlerrm;
            pc_log.log_error('GET_USER_INFO', ' l_record_t.error_message ' || l_record_t.error_message);
            l_record_t.error_status := 'E';
            if l_record_t.redirect_url is null then
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                l_record_t.allow_login := 'N';
            end if;

            l_loggedin := l_login;
            l_record_t.logged_in := nvl(l_loggedin, 'N');
            pipe row ( l_record_t );
    end get_user_info;

    function get_user_info_v2 (
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_skip_security in varchar2 default 'N',
        p_referrer      in varchar2 -- anticipating for future login request
        ,
        p_sso_user      in varchar2
    ) -- if they are SSO user, we will treat totally diff, for now keeping as placeholder
     return user_info_t
        pipelined
        deterministic
    is

        e_user_exception exception;
        l_count              number := 0;
        l_error_message      varchar2(3200);
        l_login              varchar2(1) := 'N';
        l_loggedin           varchar2(1) := 'N';
        l_skip_security      varchar2(10) := 'N';
        l_no_of_registration number := 0;
        l_record_t           user_info_row_t;
        l_user_id            number;
        l_no_accounts        number := 0;
        l_old_acct           varchar2(2) := 'O';
        l_plans_enrolled     number := 0;
    begin
        for x in (
            select
                *
            from
                online_users
            where
                user_name = trim(p_user_name)
        ) loop
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'user_name ' || p_user_name);
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'password ' || p_password);
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'p_referrer ' || p_referrer);
            pc_log.log_error('User INFO TAX IDD START', x.tax_id);
            l_count := l_count + 1;
            l_record_t.user_id := x.user_id;
            l_record_t.user_name := p_user_name;
            l_record_t.error_status := 'S';
            l_record_t.password := x.password;
            l_record_t.user_type := x.user_type;
            l_record_t.emp_reg_type := x.emp_reg_type;
            l_record_t.tax_id := x.tax_id;
            l_record_t.confirmed_flag := nvl(x.confirmed_flag, 'N');
            l_record_t.email := x.email;
            l_record_t.acc_num := x.find_key;
            l_record_t.locked_reason := x.locked_reason;
            l_record_t.first_time_pw_flag := x.first_time_pw_flag;
            l_record_t.logged_in := 'N';
--     l_record_t.security_setup := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id);
            if l_record_t.allow_login is null then
                l_record_t.allow_login := 'Y';
            end if;
            l_record_t.pw_reminder_qut := x.pw_question;
            l_record_t.pw_reminder_ans := x.pw_answer;
            l_skip_security := 'N';
            if nvl(x.sso_user, 'N') = 'Y' then
                l_record_t.sec_exist := 'Y';
            else
                l_record_t.sec_exist := nvl(
                    pc_user_security_pkg.security_setting_exist(x.user_id),
                    'N'
                );
            end if;

            l_record_t.locked_account := 'N';
            l_skip_security := 'Y';
            if p_sso_user = 'Y' then
                l_skip_security := 'Y';
                l_record_t.sso_user := 'Y';
            end if;

            if
                p_referrer in ( 'STERLING', 'PASSWORD_PAGE' )
                and p_password is null
            then
                l_error_message := '20016: Password is Required, Enter a valid password .';
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
   -- check if user is blocked
            if nvl(x.blocked, 'N') = 'Y' then
                l_error_message := '20001: Your account is blocked, please contact customer service.';
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            if x.locked_reason is not null then
                if x.failed_att >= 3 then
                    if ( sysdate - to_date ( x.locked_time, 'YYYY-MM-DD HH24:MI:SS' ) ) * 1440 < 30 then
                        l_error_message := '20011:  Your account is temporarily suspended for 30 minutes for invalid login attempts.;;Please try again after the suspended time or contact Customer Service at 800-617-4729 during regular business hours.'
                        ;
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    elsif ( sysdate - to_date ( x.locked_time, 'YYYY-MM-DD HH24:MI:SS' ) ) * 1440 >= 30 then
                        l_record_t.allow_login := 'Y';
                        l_record_t.locked_account := 'N';
                        unlock_user(p_user_name, p_password);
                    end if;

                elsif
                    x.failed_att < 3
                    and p_password = x.password
                    and nvl(x.blocked, 'N') = 'N'
                then
                    unlock_user(p_user_name, p_password);
                end if;
            end if;

            pc_log.log_error('PC_USERS.GET_USER_INFO', 'password ' || p_password);
            pc_log.log_error('PC_USERS.GET_USER_INFO',
                             'l_record_t.password'
                             || nvl(l_record_t.password, 'XXXXXX'));

            if
                nvl(l_record_t.password, 'XXXXXX') <> p_password
                and p_password is not null
            then /*If password is NULL then this condition fails */
                l_error_message := '20010: Your username/password does not match our records, please try again. Your account will be locked after 3 failed attempts.'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.redirect_url := 'Accounts/Login/';
                raise e_user_exception;
            end if;

     -- check if user had confirmed registration
            if
                nvl(x.emp_reg_type, 0) <> 1
                and nvl(x.confirmed_flag, 'N') = 'N'
                and nvl(x.first_time_pw_flag, 'N') = 'N'
            then
                l_error_message := 'We''re sorry, but you cannot access your account until you have confirmed your email. The link for this confirmation can be found in the confirmation email that was sent to the email account that you provided during registration for online access. If you have any questions, please contact us at Customer.Service@sterlingadministration.com or call 800.617.4729 during business hours'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
     -- check if user is inactive
            if x.user_status in ( 'D', 'I' ) then
                l_error_message := '20003: Your account is no longer active, please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
     -- check if user failed attempts more than 3 times and tried with in 30 minutes
            if
                nvl(x.failed_att, 0) >= 3
                and is_date(x.locked_time, 'yyyy-mm-dd hh24:mi:ss') = 'Y'
                and 60 / ( ( sysdate - to_date ( x.locked_time, 'yyyy-mm-dd hh24:mi:ss' ) ) * 100 ) <= 30
                and p_password <> x.password
                and p_password is not null
            then
                l_error_message := '20004: Your account is temporarily locked. Please try again after 30 minutes';
                l_record_t.allow_login := 'N';
                raise e_user_exception;
            end if;
     -- check if SSN has invalid ones , I mean the generic ones
            if x.tax_id in ( '000000000', '999999999', '123456789', '999009999' ) then
                l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

     -- check if SSN has invalid ones , I mean the generic ones
     -- got this info from http:--www.aila.org/content/default.aspx?docid=36839
            if
                x.user_type = 'S'
                and ( substr(x.tax_id, 1, 3) in ( '000', '666', '900' )
                      or substr(x.tax_id, 4, 2) in ( '00' )
                or substr(x.tax_id, 6, 4) in ( '0000' ) )
            then
                l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;
     -- http://www.irs.gov/irm/part21/irm_21-007-013r.html
     -- Invalid EIN Prefixes are 00, 07, 08, 09, 17, 18, 19, 28, 29, 49, 69, 70, 78, 79 and 89. EINs
     -- with one of these prefixes should never be put on Master File with a TC 000.
            if
                x.user_type = 'E'
                and substr(x.tax_id, 1, 2) in ( '00', '07', '08', '09', '17',
                                                '18', '19', '28', '29', '49',
                                                '69', '70', '78', '79', '89' )
            then
                l_error_message := '20005: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            if x.tax_id is null then
                l_login := 'N';
                l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            select
                count(*)
            into l_no_of_registration
            from
                online_users
            where
                ( emp_reg_type is null
                  or emp_reg_type <> 1 )
                and tax_id = x.tax_id
                and user_status = 'A'
                and user_type = 'S'
                and user_type = x.user_type;

            if l_no_of_registration > 1 then
                l_error_message := '20006: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                ;
                l_record_t.allow_login := 'N';
                l_record_t.locked_account := 'Y';
                raise e_user_exception;
            end if;

            if
                nvl(x.failed_att, 0) >= 3
                and is_date(x.locked_time, 'yyyy-mm-dd hh24:mi:ss') = 'Y'
                and 60 / ( ( sysdate - to_date ( x.locked_time, 'yyyy-mm-dd hh24:mi:ss' ) ) * 100 ) > 30
            then
                l_login := 'Y';
            end if;

            if
                x.user_type = 'E'
                and x.emp_reg_type = 1
            then
                if p_password is null then
                    l_record_t.sec_exist := 'Y';
                    l_record_t.redirect_url := 'Accounts/Login/';
                    l_login := 'N';
                    raise e_user_exception;
                elsif p_password is not null then
                    l_record_t.sec_exist := 'Y';
                    l_record_t.redirect_url := 'EnrollmentExpress/Enrollment/';
                    l_login := 'Y';
                    raise e_user_exception;
                end if;
            end if;

            for xx in (
                select
                    otp_verified,
                    verified_phone_type,
                    verified_phone_number,
                    remember_pc,
                    pc_insure.get_eob_status(x.tax_id) eob_status
                from
                    user_security_info
                where
                    user_id = x.user_id
            ) loop
                l_record_t.otp_verified := xx.otp_verified;
                l_record_t.verified_phone_type := xx.verified_phone_type;
                l_record_t.verified_phone_number := xx.verified_phone_number;
                l_record_t.remember_pc := xx.remember_pc;
                l_record_t.eob_status := pc_insure.get_eob_status(x.tax_id);
            end loop;

      -- all conditions passed , letting the user login
      -- check what kind of user and set url accordingly

            if x.user_type in ( 'G', 'B' ) then ----------  added by rprabu 11/06/2020 for ticket#8890
                if x.user_type = 'B' then
                    l_record_t.redirect_url := 'Brokers/Detail/BrokerDashboard/';
                    l_record_t.acc_num := x.find_key;
                    l_record_t.account_type := '';
                else
                    l_record_t.redirect_url := 'GA/Detail/GADashboard/';
                    l_record_t.acc_num := x.find_key;
                    l_record_t.account_type := '';
                end if;

                pc_log.log_error('get_user_info_v2', '  (x.user_id) :  ' || x.user_id);
                pc_log.log_error('get_user_info_v2',
                                 ' pc_users.Is_main_online_broker(x.user_id) '
                                 || pc_users.is_main_online_broker(x.user_id));

     --- commented for vanitha change     rprabu ticket#9132 04/06/2020
     /*
   if pc_users.Is_main_online_broker(x.user_id) =  'Y' And x.user_type = 'B' Then    --- shavee issue 9132 02/06/2020
        FOR xX IN ( SELECT b.first_name||NVL(b.middle_name||' ','')||b.last_name name
                        ,  b.phone_day
                    FROM  broker a, person b
                   WHERE  a.broker_lic = x.find_key
                   AND    a.broker_id = b.pers_id)
        LOOP
          l_record_t.display_name := Nvl(  l_record_t.display_name, xx.name) ;
	      l_record_t.number_to_be_verified := Nvl( l_record_t.number_to_be_verified ,  xx.phone_day);
        END LOOP;
       End If;   */

         ---    rprabu ticket#9132 29/05/2020
              ---  If      l_record_t.display_name  is null then
                for z in (
                    select
                        first_name
                        || ' '
                        || last_name display_name,
                        phone,
                        email
                    from
                        contact
                    where
                        user_id = x.user_id
                ) loop
                    l_record_t.display_name := z.display_name;
                                   --   l_record_t.email :=    z.email;   -- Commneted by Joshi #10610. emal should come from online_users always.
                    l_record_t.number_to_be_verified := z.phone;
                end loop;
         ----          ENd if;

        ---    rprabu ticket#9132 29/05/2020
                for xx in (
                    select
                        otp_verified,
                        verified_phone_type,
                        verified_phone_number, -----verified_email ,
                        remember_pc,
                        pc_insure.get_eob_status(x.tax_id) eob_status
                    from
                        user_security_info
                    where
                        user_id = x.user_id
                ) loop
                    l_record_t.verified_phone_number := xx.verified_phone_number;
                end loop;

                l_login := 'Y';
            end if;

            if x.user_type = 'S' then
                for xx in (
                    select
                        count(*)                    cnt,
                        count(distinct b.phone_day) phone_count
                    from
                        account a,
                        person  b
                    where
                            b.ssn = format_ssn(x.tax_id)
                        and a.pers_id = b.pers_id
                        and a.account_type in ( 'HSA', 'HRA', 'FSA', 'COBRA', 'RB',
                                                'LSA' )   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021  -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                        and nvl(a.show_account_online, 'Y') = 'Y'
                )   -- Added show_online by Swamy for Ticket#9575(Main ticket 9332) on 06/11/2020
                    -- AND   account_status <> 4)
                 loop
                    l_record_t.no_of_accounts := xx.cnt;
                    pc_log.log_error('PC_USERS.GET_USER_INFO', 'no_of_accounts ' || xx.cnt);
                    if xx.cnt > 1 then
                        l_record_t.portfolio_account := 'Y';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/';
                        for xxx in (
                            select distinct
                                b.first_name
                                || nvl(b.middle_name || ' ', '')
                                || b.last_name name,
                                b.phone_day
                            from
                                person b
                            where
                                b.ssn = format_ssn(x.tax_id)
                        ) loop
                            l_record_t.display_name := xxx.name;
                            if xx.phone_count = 1 then
                                l_record_t.number_to_be_verified := xxx.phone_day;
                            end if;

                        end loop;

                    elsif xx.cnt = 1 then
                        for xxx in (
                            select
                                a.account_type,
                                a.acc_id,
                                a.acc_num,
                                c.plan_sign,
                                a.complete_flag,
                                b.first_name
                                || ' '
                                || nvl(b.middle_name || ' ', '')
                                || b.last_name name,
                                b.phone_day
                            from
                                account a,
                                person  b,
                                plans   c
                            where
                                    b.ssn = format_ssn(x.tax_id)
                                and a.account_type in ( 'HSA', 'HRA', 'FSA', 'COBRA', 'RB',
                                                        'LSA' )  -- LSA Added by Swamy for Ticket#9912 on 10/08/2021  -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                                and a.pers_id = b.pers_id
                                and c.plan_code = a.plan_code
                                and nvl(a.show_account_online, 'Y') = 'Y'
                        )
                       -- AND   account_status <> 4)
                         loop
                            pc_log.log_error('PC_USERS.GET_USER_INFO', 'xxx.account_type ' || xxx.account_type);
                            if xxx.plan_sign <> 'SHA' then
                                l_login := 'N';
                                l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                                ;
                                l_record_t.allow_login := 'N';
                                l_record_t.locked_account := 'Y';
                                raise e_user_exception;
                            else
                                l_record_t.portfolio_account := 'N';
                                l_record_t.acc_num := xxx.acc_num;
                                l_record_t.acc_id := xxx.acc_id;
                                l_record_t.display_name := xxx.name;
                                l_record_t.number_to_be_verified := xxx.phone_day;
                                l_record_t.account_type := xxx.account_type;
                                if xxx.complete_flag = 0 then
                                    l_record_t.redirect_url := 'AccountHolders/OnlineEnrollment/CompleteEnrollment/';
                                else
                                    if xxx.account_type = 'HSA' then
                                        l_record_t.redirect_url := 'AccountHolders/Detail/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'HRA' then
                                        l_record_t.redirect_url := 'HRA/AccountHolders/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'FSA' then
                                        l_record_t.redirect_url := 'FSA/AccountHolders/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'COBRA' then
                                        l_record_t.redirect_url := 'COBRA/AccountHolders/AccountHolderDashboard/';--'Accounts/Portfolio/';
                                    elsif xxx.account_type = 'RB' then  -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                                        l_record_t.redirect_url := 'RB/AccountHolders/AccountHolderDashboard/';--'Accounts/Portfolio/';
                                    elsif xxx.account_type = 'LSA' then  -- Added LSA by Swamy for Ticket#9912 on 10/08/2021
                                        l_record_t.redirect_url := 'LSA/AccountHolders/Detail/AccountHolderDashboard/';
                                    end if;
                                end if;

                                l_login := 'Y';
                            end if;

                        end loop;
                    else
                        l_login := 'N';
                        l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                        ;
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    end if;

                end loop;
            end if;

            if
                x.user_type = 'E'
                and x.emp_reg_type in ( 4, 5, 2 )
            then
                for xx in (
                    select
                        count(*) cnt
                 --     ,sum(case when a.account_status = 3 then 1 else 0 end ) pending
               ---       ,sum(case when a.account_status <> 3 then 1 else 0 end ) active_count
                        ,
                        sum(
                            case
                                when a.account_status in(3, 6, 8, 9, 10) then
                                    1
                                else
                                    0
                            end
                        )        pending       ----9141 19/08/2020 rprabu
                        ,
                        sum(
                            case
                                when a.account_status not in(3, 6, 8, 9, 10) then
                                    1
                                else
                                    0
                            end
                        )        active_count     ----9141 19/08/2020 rprabu
                    from
                        account    a,
                        enterprise b
                    where
                            replace(b.entrp_code, '-') = x.tax_id
                        and a.entrp_id = b.entrp_id
                        and ( ( x.emp_reg_type in ( 2 ) -- Added by jaggi - role 5'id removed for #9829
                                and a.account_type in ( 'HRA', 'HSA', 'FSA', 'COBRA', 'ERISA_WRAP',
                                                        'POP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                                        'RB' ) ) -- ACA added by Swamy for Ticket#10844 -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                              or ( x.emp_reg_type in ( 4, 5 )    -- Added by jaggi - role 5'id for #9829                                 -- Added by Jaggi #11689
                                   and a.account_type in (
                            select
                                account_type
                            from
                                user_role_entries b, site_navigation   c
                            where
                                    b.user_id = x.user_id
                                and b.site_nav_id = c.site_nav_id
                        ) ) )
                        and account_status <> 4
                ) loop
                    l_record_t.no_of_accounts := xx.cnt;
                    if xx.active_count > 1 then
                        l_record_t.portfolio_account := 'Y';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/';
                        for xxx in (
                            select
                                b.name
                            from
                                enterprise b
                            where
                                replace(b.entrp_code, '-') = replace(x.tax_id, '-')
                        ) loop
                            l_record_t.display_name := xxx.name;
                        end loop;

                    elsif
                        xx.active_count = 0
                        and xx.pending >= 1
                    then
                        l_record_t.portfolio_account := 'N';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll';
                        for xxx in (
                            select
                                b.name,
                                entrp_phones
                            from
                                enterprise b
                            where
                                replace(b.entrp_code, '-') = replace(x.tax_id, '-')
                        ) loop
                            l_record_t.display_name := xxx.name;
                            l_record_t.number_to_be_verified := xxx.entrp_phones;
                        end loop;

                    elsif xx.active_count = 1 then
                        for xxx in (
                            select
                                a.account_type,
                                a.acc_id,
                                a.acc_num,
                                c.plan_sign,
                                b.name,
                                b.entrp_phones
                            from
                                account    a,
                                enterprise b,
                                plans      c
                            where
                                    replace(b.entrp_code, '-') = x.tax_id
                                and c.plan_code = a.plan_code
                                and a.entrp_id = b.entrp_id
                                and a.account_status not in ( 3, 9, 6, 8, 10 )---9491 rprabu 15/09/2020
                                and ( ( x.emp_reg_type in ( 2 )      -- Added by jaggi - role 5'id removed for #9829
                                        and a.account_type in ( 'HRA', 'HSA', 'FSA', 'COBRA', 'ERISA_WRAP',
                                                                'POP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                                                'RB' ) )   -- ACA added by Swamy for Ticket#10844 -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                                      or ( x.emp_reg_type in ( 4, 5 )      -- Added by jaggi - role 5'id removed for #9829                        -- RB -- Added by jaggi #11689
                                           and a.account_type in (
                                    select
                                        account_type
                                    from
                                        user_role_entries b, site_navigation   c
                                    where
                                            b.user_id = x.user_id
                                        and b.site_nav_id = c.site_nav_id
                                ) ) )
                                and account_status <> 4
                        ) loop
                            if xxx.plan_sign <> 'SHA' then
                                l_login := 'N';
                                l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                                ;
                                l_record_t.allow_login := 'N';
                                l_record_t.locked_account := 'Y';
                                raise e_user_exception;
                            else
                                l_record_t.portfolio_account := 'N';
                                l_record_t.acc_num := xxx.acc_num;
                                l_record_t.acc_id := xxx.acc_id;
                                l_record_t.display_name := xxx.name;
                                l_record_t.number_to_be_verified := xxx.entrp_phones;
                                pc_log.log_error('PC_USERS.GET_USER_INFO_V2', 'xxx.15/09 : '
                                                                              || xxx.account_type
                                                                              || l_record_t.redirect_url);

                                l_record_t.account_type := xxx.account_type;
                                if xxx.account_type = 'HSA' then
                                    l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                                elsif xxx.account_type = 'HRA' then
                                    l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'FSA' then
                                    l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'COBRA' then
                                    l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'ERISA_WRAP' then
                                    pc_log.log_error('PC_USERS.GET_USER_INFO_V2', 'ERISA_WRAP : 15/09 : '
                                                                                  || xxx.account_type
                                                                                  || l_record_t.redirect_url);

                                    l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'POP' then
                                    pc_log.log_error('PC_USERS.GET_USER_INFO_V2', 'POP  : 15/09 : '
                                                                                  || xxx.account_type
                                                                                  || l_record_t.redirect_url);

                                    l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'FORM_5500' then
                                    l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'LSA' then
                                    l_record_t.redirect_url := 'Employers/LSADetail/EmployerDashboard/';   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                                elsif xxx.account_type = 'ACA' then
                                    l_record_t.redirect_url := 'ACA/Employers/EmployerDashboard/';   -- ACA added by Swamy for Ticket#10844
                                elsif xxx.account_type = 'CMP' then
                                    l_record_t.redirect_url := 'CMP/Employers/EmployerDashboard/';   -- CMP added by jaggi for Ticket#11218
                                elsif xxx.account_type = 'RB' then
                                    l_record_t.redirect_url := 'RB/Employers/EmployerDashboard/';    -- Added RB by Swamy for Ticket#9656 on 24/03/2021
                                else
                                    l_record_t.redirect_url := 'Accounts/Portfolio/';                 -- Added by jaggi #11689
                                end if;

                                l_login := 'Y';
                            end if;
                        end loop;
               --    END IF;
                        for u in (
                            select
                                phone
                            from
                                contact
                            where
                                user_id = x.user_id
                        ) loop
                            l_record_t.number_to_be_verified := u.phone;
                        end loop;

                        l_record_t.portfolio_account := 'N';
                        l_login := 'Y';
                    else
                        l_login := 'N';
                        l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                        ;
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    end if;

                end loop;
            end if;

            l_user_id := x.user_id;
            l_loggedin := 'N';
            if p_password is null then
                l_loggedin := 'N';
            end if;
            l_record_t.show_modal_window := pc_user_security_pkg.show_phone_update_modal(x.user_id);
            l_record_t.logged_in := l_loggedin;
            pc_log.log_error('PC_USERS.GET_USER_INFO', 'redirect_url ' || l_record_t.redirect_url);

	-- Added by Joshi for 6596. page should be shown for individual.
            l_record_t.show_td_ameritrade_page := 'N';
            for y in (
                select
                    p.entrp_id
                from
                    account      a,
                    person       p,
                    online_users o
                where
                        o.find_key = a.acc_num
                    and o.user_type = 'S'
                    and a.account_type = 'HSA'
                    and a.pers_id = p.pers_id
                    and o.user_id = x.user_id
            ) loop
                if y.entrp_id is null then
                    l_record_t.show_td_ameritrade_page := 'Y';
                else
                    l_record_t.show_td_ameritrade_page := 'N';
                end if;
            end loop;
	-- code ends here 6596.

            pipe row ( l_record_t );
        end loop;

        pc_log.log_error('PC_USERS.GET_USER_INFO', 'l_count ' || l_count);
        if l_count = 0 then
            l_error_message := '20008: Your username/password does not match our records, please try again. Your account will be locked after 3 failed attempts.'
            ;
            l_record_t.allow_login := 'N';
            l_record_t.locked_account := 'Y';
            raise e_user_exception;
        end if;

    exception
        when e_user_exception then
            l_record_t.user_name := p_user_name;
            pc_log.log_error('GET_USER_INFO', 'l_error_message ' || l_error_message);
            pc_log.log_error('GET_USER_INFO', 'redirect_url ' || l_record_t.redirect_url);
           --l_record_t.allow_login := 'N';
          -- l_record_t.tax_id := null;
           -- l_record_t.password := null;

            if l_error_message is not null then
                l_record_t.error_message := l_error_message;
                l_record_t.error_status := 'E';
                if l_record_t.redirect_url is null then
                    l_record_t.redirect_url := 'Accounts/Login/';
                end if;
            end if;

            l_loggedin := l_login;
            pc_log.log_error('User INFO TAX IDD  END..2', l_record_t.tax_id);
            if p_password is null then
                l_loggedin := 'N';
            end if;
            l_record_t.logged_in := nvl(l_loggedin, 'N');
            pc_log.log_error('User INFO TAX IDD  END..3', l_record_t.tax_id);
            pipe row ( l_record_t );
        when others then
            l_record_t.user_name := p_user_name;
            l_record_t.error_message := sqlerrm;
            pc_log.log_error('GET_USER_INFO', ' l_record_t.error_message ' || l_record_t.error_message);
            l_record_t.error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
            ;
            l_record_t.error_status := 'E';
            if l_record_t.redirect_url is null then
                l_record_t.redirect_url := 'Accounts/Login/';
                l_record_t.allow_login := 'N';
            end if;

            l_loggedin := l_login;
            l_record_t.logged_in := nvl(l_loggedin, 'N');
            l_record_t.tax_id := null;
            l_record_t.password := null;
            pipe row ( l_record_t );
    end get_user_info_v2;

    function get_user_info_by_uname (
        p_user_name in varchar2
    ) return user_info_t
        pipelined
        deterministic
    is

        e_user_exception exception;
        l_count              number := 0;
        l_error_message      varchar2(3200);
        l_login              varchar2(1) := 'N';
        l_loggedin           varchar2(1) := 'N';
        l_skip_security      varchar2(10) := 'N';
        l_no_of_registration number := 0;
        l_record_t           user_info_row_t;
        l_user_id            number;
        l_no_accounts        number := 0;
    begin
        for x in (
            select
                *
            from
                online_users
            where
                user_name = trim(p_user_name)
        ) loop
            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'user_name ' || p_user_name);
            l_count := 1;
            l_record_t.user_id := x.user_id;
            l_record_t.user_name := p_user_name;
            l_record_t.error_status := 'S';
            l_record_t.password := x.password;
            l_record_t.user_type := x.user_type;
            l_record_t.emp_reg_type := x.emp_reg_type;
            l_record_t.tax_id := x.tax_id;
            l_record_t.confirmed_flag := nvl(x.confirmed_flag, 'N');
            l_record_t.email := x.email;
            l_record_t.acc_num := x.find_key;
            l_record_t.locked_reason := x.locked_reason;
            l_record_t.first_time_pw_flag := x.first_time_pw_flag;
            l_record_t.logged_in := 'N';
--     l_record_t.security_setup := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id);
            if l_record_t.allow_login is null then
                l_record_t.allow_login := 'Y';
            end if;
            l_record_t.pw_reminder_qut := x.pw_question;
            l_record_t.pw_reminder_ans := x.pw_answer;
            l_record_t.portfolio_account := 'N';
            if l_record_t.allow_login is null then
                l_record_t.allow_login := 'Y';
            end if;
            l_record_t.pw_reminder_qut := x.pw_question;
            l_record_t.pw_reminder_ans := x.pw_answer;
            l_skip_security := 'N';
            if nvl(x.sso_user, 'N') = 'Y' then
                l_record_t.sec_exist := 'Y';
            else
                l_record_t.sec_exist := nvl(
                    pc_user_security_pkg.security_setting_exist(x.user_id),
                    'N'
                );
            end if;

            l_record_t.locked_account := 'N';
            l_record_t.status :=
                case
                    when x.user_status = 'A' then
                        'Active'
                    when x.user_status = 'I' then
                        'Inactive'
                    else null
                end;  -- Added by Jaggi #11090 on 05/10/2022

     -- all conditions passed , letting the user login

            if x.user_type = 'B' then
                l_record_t.redirect_url := 'Brokers/Detail/BrokerDashboard/';
                l_record_t.acc_num := x.find_key;
                l_record_t.account_type := '';
                for xx in (
                    select
                        b.first_name
                        || nvl(b.middle_name || ' ', '')
                        || b.last_name name
                    from
                        broker a,
                        person b
                    where
                            a.broker_lic = x.find_key
                        and a.broker_id = b.pers_id
                ) loop
                    l_record_t.display_name := xx.name;
                end loop;

                l_login := 'Y';
            end if;

     -- Start Added by Swamy for Ticket#9559 on 06/11/2020
            if x.user_type = 'G' then
                l_record_t.redirect_url := 'GA/Detail/GADashboard/';
                l_record_t.acc_num := x.find_key;
                l_record_t.account_type := '';
                l_login := 'Y';
            end if;
	 -- End of Addition by Swamy for Ticket#9559

            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'x.user_type ' || x.user_type);
            if x.user_type = 'S' then
                for xx in (
                    select
                        count(*) cnt
                    from
                        account a,
                        person  b
                    where
                            b.ssn = format_ssn(x.tax_id)
                        and a.pers_id = b.pers_id
                        and a.account_type in ( 'HSA', 'HRA', 'FSA', 'COBRA', 'LSA' )    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                        and nvl(a.show_account_online, 'Y') = 'Y'  -- Added show_online by Swamy for Ticket#9839(Main ticket 9332) on 08/04/2021
                ) loop
                    l_record_t.no_of_accounts := xx.cnt;
                    pc_log.log_error('GET_USER_INFO_BY_UNAME', 'no_of_accounts ' || xx.cnt);
                    if xx.cnt > 1 then
                        l_record_t.portfolio_account := 'Y';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/';
                        for xxx in (
                            select
                                b.first_name
                                || nvl(b.middle_name || ' ', '')
                                || b.last_name name
                            from
                                person b
                            where
                                b.ssn = format_ssn(x.tax_id)
                        ) loop
                            l_record_t.display_name := xxx.name;
                        end loop;

                    elsif xx.cnt = 1 then
                        for xxx in (
                            select
                                a.account_type,
                                a.acc_id,
                                a.acc_num,
                                c.plan_sign,
                                a.complete_flag,
                                b.first_name
                                || ' '
                                || nvl(b.middle_name || ' ', '')
                                || b.last_name name
                            from
                                account a,
                                person  b,
                                plans   c
                            where
                                    b.ssn = format_ssn(x.tax_id)
                                and a.account_type in ( 'HSA', 'HRA', 'FSA', 'COBRA', 'LSA',
                                                        'ACA' )     -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                                and a.pers_id = b.pers_id
                                and c.plan_code = a.plan_code
                                and nvl(a.show_account_online, 'Y') = 'Y'   -- Added by Swamy for Ticket#Prodissue
                        ) loop
                            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'xxx.account_type ' || xxx.account_type);
                            if xxx.plan_sign <> 'SHA' then
                                l_login := 'N';
                                l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                                ;
                                l_record_t.allow_login := 'N';
                                l_record_t.locked_account := 'Y';
                                raise e_user_exception;
                            else
                                l_record_t.portfolio_account := 'N';
                                l_record_t.acc_num := xxx.acc_num;
                                l_record_t.acc_id := xxx.acc_id;
                                l_record_t.display_name := xxx.name;
                                l_record_t.account_type := xxx.account_type;
                                if xxx.complete_flag = 0 then
                                    l_record_t.redirect_url := 'AccountHolders/OnlineEnrollment/CompleteEnrollment/';
                                else
                                    if xxx.account_type = 'HSA' then
                                        l_record_t.redirect_url := 'AccountHolders/Detail/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'HRA' then
                                        l_record_t.redirect_url := 'HRA/AccountHolders/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'FSA' then
                                        l_record_t.redirect_url := 'FSA/AccountHolders/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'COBRA' then
                                        l_record_t.redirect_url := 'COBRA/AccountHolders/AccountHolderDashboard/';
                                    elsif xxx.account_type = 'LSA' then  -- Added LSA by Swamy for Ticket#9912 on 10/08/2021
                                        l_record_t.redirect_url := 'LSA/AccountHolders/Detail/AccountHolderDashboard/';
                                    end if;
                                end if;

                                l_login := 'Y';
                            end if;

                        end loop;
                    else
                        l_login := 'N';
                        l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                        ;
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    end if;

                end loop;
            end if;

            for xx in (
                select
                    otp_verified,
                    verified_phone_type,
                    verified_phone_number,
                    remember_pc,
                    pc_insure.get_eob_status(x.tax_id) eob_status
                from
                    user_security_info
                where
                    user_id = x.user_id
            ) loop
                l_record_t.otp_verified := xx.otp_verified;
                l_record_t.verified_phone_type := xx.verified_phone_type;
                l_record_t.verified_phone_number := xx.verified_phone_number;
                l_record_t.remember_pc := xx.remember_pc;
                l_record_t.eob_status := pc_insure.get_eob_status(x.tax_id);
            end loop;

            if
                x.user_type = 'E'
                and x.emp_reg_type in ( 4, 5, 2 )
            then
                for xx in (
                    select
                        count(*) cnt,
                        sum(
                            case
                                when a.account_status = 3 then
                                    1
                                else
                                    0
                            end
                        )        pending,
                        sum(
                            case
                                when a.account_status <> 3 then
                                    1
                                else
                                    0
                            end
                        )        active_count
                    from
                        account    a,
                        enterprise b
                    where
                            replace(b.entrp_code, '-') = x.tax_id
                        and a.entrp_id = b.entrp_id
                        and ( ( x.emp_reg_type in ( 2, 5 )
                                and a.account_type in ( 'HRA', 'HSA', 'FSA', 'COBRA', 'ERISA_WRAP',
                                                        'POP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                                        'RB' ) )    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021 --11744  added ACA/CMP/RB Joshi
                              or ( x.emp_reg_type = 4
                                   and a.account_type in (
                            select
                                account_type
                            from
                                user_role_entries b, site_navigation   c
                            where
                                    b.user_id = x.user_id
                                and b.site_nav_id = c.site_nav_id
                        ) ) )
                        and account_status <> 4
                ) loop
                    l_record_t.no_of_accounts := xx.cnt;
                    if xx.active_count > 1 then
                        l_record_t.portfolio_account := 'Y';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/';
                        for xxx in (
                            select
                                b.name
                            from
                                enterprise b
                            where
                                replace(b.entrp_code, '-') = replace(x.tax_id, '-')
                        ) loop
                            l_record_t.display_name := xxx.name;
                        end loop;

                    elsif
                        xx.active_count = 0
                        and xx.pending >= 1
                    then
                        l_record_t.portfolio_account := 'N';
                        l_login := 'Y';
                        l_record_t.redirect_url := 'Accounts/Portfolio/newEREnroll';
                        for xxx in (
                            select
                                b.name,
                                entrp_phones
                            from
                                enterprise b
                            where
                                replace(b.entrp_code, '-') = replace(x.tax_id, '-')
                        ) loop
                            l_record_t.display_name := xxx.name;
                            l_record_t.number_to_be_verified := xxx.entrp_phones;
                        end loop;

                    elsif xx.active_count = 1 then
                        pc_log.log_error('GET_USER_INFO_BY_UNAME', 'get_user_info_v2  active_count :   ' || xx.active_count);
                        for xxx in (
                            select
                                a.account_type,
                                a.acc_id,
                                a.acc_num,
                                c.plan_sign,
                                b.name,
                                b.entrp_phones
                            from
                                account    a,
                                enterprise b,
                                plans      c
                            where
                                    replace(b.entrp_code, '-') = x.tax_id
                                and c.plan_code = a.plan_code
                                and a.entrp_id = b.entrp_id
                                and a.account_status <> 3
                                and ( ( x.emp_reg_type in ( 2, 5 )
                                        and a.account_type in ( 'HRA', 'HSA', 'FSA', 'COBRA', 'ERISA_WRAP',
                                                                'POP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                                                'RB' ) )    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021--11744  added ACA/CMP/RB Joshi
                                      or ( x.emp_reg_type = 4
                                           and a.account_type in (
                                    select
                                        account_type
                                    from
                                        user_role_entries b, site_navigation   c
                                    where
                                            b.user_id = x.user_id
                                        and b.site_nav_id = c.site_nav_id
                                ) ) )
                                and account_status <> 4
                        ) loop
                            if xxx.plan_sign <> 'SHA' then
                                l_login := 'N';
                                l_error_message := '20008: We have trouble logging you in , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                                ;
                                l_record_t.allow_login := 'N';
                                l_record_t.locked_account := 'Y';
                                raise e_user_exception;
                            else
                                l_record_t.portfolio_account := 'N';
                                l_record_t.acc_num := xxx.acc_num;
                                l_record_t.acc_id := xxx.acc_id;
                                l_record_t.display_name := xxx.name;
                                l_record_t.number_to_be_verified := xxx.entrp_phones;
                                l_record_t.account_type := xxx.account_type;
                                if xxx.account_type = 'HSA' then
                                    l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                                elsif xxx.account_type = 'HRA' then
                                    l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'FSA' then
                                    l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'COBRA' then
                                    l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'ERISA_WRAP' then
                                    l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'POP' then
                                    l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'FORM_5500' then
                                    l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                                elsif xxx.account_type = 'LSA' then
                                    l_record_t.redirect_url := 'Employers/LSADetail/EmployerDashboard/';   -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                                elsif xxx.account_type = 'ACA' then
                                    l_record_t.redirect_url := 'ACA/Employers/EmployerDashboard';   --11744  added ACA/CMP/RB Joshi
                                elsif xxx.account_type = 'CMP' then
                                    l_record_t.redirect_url := 'CMP/Employers/EmployerDashboard';  --11744  added ACA/CMP/RB Joshi
                                elsif xxx.account_type = 'RB' then
                                    l_record_t.redirect_url := 'RB/Employers/EmployerDashboard';     --11744  added ACA/CMP/RB Joshi
                                else
                                    l_record_t.redirect_url := 'Accounts/Portfolio/';
                                end if;

                                l_login := 'Y';
                            end if;
                        end loop;
               --    END IF;
                        for u in (
                            select
                                phone
                            from
                                contact
                            where
                                user_id = x.user_id
                        ) loop
                            l_record_t.number_to_be_verified := u.phone;
                        end loop;

                        l_record_t.portfolio_account := 'N';
                        l_login := 'Y';
                    else
                        l_login := 'N';
                        l_error_message := '20007: No active accounts are associated with this user name , please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com'
                        ;
                        l_record_t.allow_login := 'N';
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    end if;

                end loop;
            end if;

            l_user_id := x.user_id;
            l_loggedin := l_login;
            l_record_t.portfolio_account := nvl(l_record_t.portfolio_account, 'N');
            l_record_t.logged_in := l_loggedin;
            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'redirect_url ' || l_record_t.redirect_url);
            l_record_t.show_modal_window := pc_user_security_pkg.show_phone_update_modal(x.user_id);
            pipe row ( l_record_t );
        end loop;

        if l_count = 0 then
            l_error_message := '20008: The username you have entered is not found in our records. Please contact customer service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com '
            ;
            l_record_t.allow_login := 'N';
            l_record_t.locked_account := 'Y';
            raise e_user_exception;
        end if;

    exception
        when e_user_exception then
            l_record_t.user_name := p_user_name;
            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'l_error_message ' || l_error_message);
            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'redirect_url ' || l_record_t.redirect_url);
            if l_error_message is not null then
                l_record_t.error_message := l_error_message;
                l_record_t.error_status := 'E';
                if l_record_t.redirect_url is null then
                    l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                    l_record_t.allow_login := 'N';
                end if;

            end if;

            l_loggedin := l_login;
            l_record_t.logged_in := nvl(l_loggedin, 'N');
            pipe row ( l_record_t );
        when others then
            l_record_t.user_name := p_user_name;
            l_record_t.error_message := sqlerrm;
            pc_log.log_error('GET_USER_INFO_BY_UNAME', ' l_record_t.error_message ' || l_record_t.error_message);
            l_record_t.error_status := 'E';
            if l_record_t.redirect_url is null then
                l_record_t.redirect_url := 'Accounts/Accounts/ValidateLogin/';
                l_record_t.allow_login := 'N';
            end if;

            l_loggedin := l_login;
            l_record_t.logged_in := nvl(l_loggedin, 'N');
            pipe row ( l_record_t );
    end get_user_info_by_uname;

    procedure lock_user (
        p_user_id     in number,
        p_lock_reason in varchar2,
        p_ip_address  in varchar2
    ) is
        l_blk varchar2(2);
    begin
        pc_log.log_error('lock_user', 'user id '
                                      || p_user_id
                                      || ' lock reason '
                                      || p_lock_reason);
        if p_lock_reason = 'WRONG_PASSWORD' then
            update online_users
            set
                locked_time = to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
                failed_att = nvl(failed_att, 0) + 1,
                failed_ip = p_ip_address,
                locked_reason = p_lock_reason
            where
                    user_id = p_user_id
                and ( emp_reg_type is null
                      or emp_reg_type <> 1 );

        else
            update online_users
            set
                locked_time = to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
                locked_reason = p_lock_reason,
                failed_ip = p_ip_address,
                failed_att = nvl(failed_att, 0) + 1
            where
                    user_id = p_user_id
                and ( emp_reg_type is null
                      or emp_reg_type <> 1 );

        end if;
     /*Block the user on 3 invalid attempts */
     -- Vanitha commented it as it doesnt make sense
   /*FOR X IN ( SELECT failed_att FROM online_users
                 WHERE user_id = p_user_id)
   LOOP
      IF x.failed_att = 3 THEN
        UPDATE online_users
        SET blocked = 'Y'
        WHERE user_id = p_user_id;
      END IF;
    END LOOP;*/

    end lock_user;

    procedure lock_user_with_ssn (
        p_ssn         in varchar2,
        p_lock_reason in varchar2,
        p_ip_address  in varchar2
    ) is
    begin
        update online_users
        set
            locked_time = to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
            locked_reason = p_lock_reason,
            failed_ip = p_ip_address,
            failed_att = failed_att + 1
        where
            tax_id = replace(p_ssn, '-');

    end lock_user_with_ssn;

    procedure create_role_entries (
        p_contact_user_id  in number,
        p_role_entries     in pc_online_enrollment.varchar2_tbl,
        p_user_id          in number,
        p_role_id          in number,
        p_authorize_req_id in number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('pc_users.create_role_entries: p_contact_user_id: ', p_contact_user_id);
        pc_log.log_error('pc_users.create_role_entries: p_authorize_req_id: ', p_authorize_req_id);

   -- Added by Joshi for 9902.
        if p_authorize_req_id is null then
            delete from user_role_entries
            where
                    user_id = p_contact_user_id
                and authorize_req_id is null;

        else
            delete from user_role_entries
            where
                    user_id = p_contact_user_id
                and authorize_req_id = p_authorize_req_id;  -- Added by Joshi for 9902.
        end if;

        pc_log.log_error('pc_users.create_role_entries: p_role_entries.COUNT: ', p_role_entries.count);
        forall i in 1..p_role_entries.count
            insert into user_role_entries (
                role_entry_id,
                site_nav_id,
                user_id,
                role_id,
                start_date,
                status,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                authorize_req_id
            ) values ( user_role_entries_seq.nextval,
                       p_role_entries(i),
                       p_contact_user_id,
                       p_role_id,
                       sysdate,
                       'A',
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       p_authorize_req_id );

        pc_log.log_error('pc_users.create_role_entries: SQLERRM: ', sqlerrm);
    end create_role_entries;

    function get_user_permissions (
        p_user_id   in number,
        p_role_type in number
    ) return user_roles_t
        pipelined
        deterministic
    is
        l_record_t user_roles_row_t;
    begin
        if p_role_type in ( 2 ) then   -- Added by jaggi - role 5'id removed for #9829
            for x in (
                select
                    site_nav_id,
                    nav_description,
                    account_type
                from
                    site_navigation
                where
                        status = 'A'
                    and nvl(end_date, sysdate) >= sysdate
                    and portal_type = 'EMPLOYER' -- added by jaggi#9912>10172
                order by
                    site_nav_id
            ) loop
                l_record_t.site_nav_id := x.site_nav_id;
                l_record_t.user_id := p_user_id;
                l_record_t.account_type := x.account_type;
                l_record_t.nav_description := x.nav_description;
                pipe row ( l_record_t );
            end loop;

        else
            for x in (
                select
                    sn.site_nav_id,
                    sn.nav_description,
                    sn.account_type
                from
                    online_users      x,
                    user_role_entries ur,
                    site_navigation   sn
                where
                        x.user_id = ur.user_id
                    and sn.site_nav_id = ur.site_nav_id
                    and x.user_id = p_user_id
                    and conditional_flag = 'N'  --- 8837 rprabu 14/05/2020
                    and portal_type = 'EMPLOYER'  -- added by jaggi#9912>10172
                order by
                    sn.site_nav_id
            ) loop
                l_record_t.site_nav_id := x.site_nav_id;
                l_record_t.user_id := p_user_id;
                l_record_t.account_type := x.account_type;
                l_record_t.nav_description := x.nav_description;
                pipe row ( l_record_t );
            end loop;
        end if;
    end get_user_permissions;

    function get_permissions (
        p_user_id   in number,
        p_role_type in number
    ) return user_roles_t
        pipelined
        deterministic
    is
        l_record_t user_roles_row_t;
    begin
        if p_role_type not in ( 1, 2 ) then
            for x in (
                select
                    sn.site_nav_id,
                    sn.nav_description,
                    sn.account_type
                from
                    site_navigation sn
                where
                    sn.account_type in (
                        select
                            a.account_type
                        from
                            account      a, enterprise   b, online_users x
                        where
                                a.entrp_id = b.entrp_id
                            and x.user_id = p_user_id
                            and conditional_flag = 'N' --- 8837 rprabu 14/05/2020
                            and replace(b.entrp_code, '-') = x.tax_id
                    )
                order by
                    sn.site_nav_id
            ) loop
                l_record_t.site_nav_id := x.site_nav_id;
                l_record_t.nav_description := x.nav_description;
                l_record_t.user_id := p_user_id;
                l_record_t.account_type := x.account_type;
                pipe row ( l_record_t );
            end loop;

        end if;
    end get_permissions;

    function get_forgotten_user (
        p_user_name in varchar2,
        p_find_key  in varchar2,
        p_email     in varchar2
    ) return user_info_t
        pipelined
        deterministic
    is

        e_user_exception exception;
        l_count              number := 0;
        l_error_message      varchar2(3200);
        l_login              varchar2(1) := 'N';
        l_skip_security      varchar2(10) := 'N';
        l_no_of_registration number := 0;
        l_record_t           user_info_row_t;
        l_user_id            number;
        l_no_accounts        number := 0;
    begin
        if
            p_user_name is not null
            and p_find_key is null
            and p_email is null
        then
            for x in (
                select
                    *
                from
                    online_users
                where
                    user_name = p_user_name
            ) loop
                l_record_t.user_name := p_user_name;
                l_record_t.user_type := x.user_type;
                l_record_t.pw_reminder_qut := x.pw_question;
                l_record_t.pw_reminder_ans := x.pw_answer;
                l_record_t.acc_num := x.find_key;
                l_record_t.email := x.email;
                pipe row ( l_record_t );
            end loop;

        else
            for x in (
                select
                    *
                from
                    online_users
                where
                        user_name = p_user_name
                    and find_key = p_find_key
                    and email = p_email
            ) loop
                l_record_t.user_name := p_user_name;
                l_record_t.user_type := x.user_type;
                l_record_t.pw_reminder_qut := x.pw_question;
                l_record_t.pw_reminder_ans := x.pw_answer;
                l_record_t.acc_num := x.find_key;
                l_record_t.email := x.email;
                pipe row ( l_record_t );
            end loop;
        end if;
    end get_forgotten_user;

    procedure reset_password (
        p_user_name in varchar2,
        p_password  in varchar2,
        p_user_id   in number
    ) is
    begin
        pc_log.log_error('reset_password,p_user_name', p_user_name);
        pc_log.log_error('reset_password,p_password', p_password);
        pc_log.log_error('reset_password,p_user_id', p_user_id);
        update online_users
        set
            password = p_password,
            change_pw = to_char(sysdate, 'yyyy-mm-dd hh:mi:ss'),
            last_update_date = sysdate,
            last_updated_by = p_user_id,
            failed_att = 0,
            failed_ip = null,
            confirmed_flag = 'Y',
            first_time_pw_flag = 'N'
        where
            user_name = p_user_name;

    end reset_password;

    procedure set_password (
        p_user_name   in varchar2,
        p_password    in varchar2,
        p_pw_question in varchar2,
        p_pw_answer   in varchar2
    ) is
    begin
        update online_users
        set
            password = p_password,
            change_pw = to_char(sysdate, 'yyyy-mm-dd hh:mi:ss'),
            last_update_date = sysdate,
            last_updated_by = user_id,
            pw_question = p_pw_question,
            pw_answer = p_pw_answer,
            confirmed_flag = 'Y',
            first_time_pw_flag = 'N'
        where
            user_name = p_user_name;

    end set_password;

    procedure confirm_registration (
        p_user_name     in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_user_id number;
    begin
        x_return_status := 'S';
        select
            get_user_id(p_user_name)
        into l_user_id
        from
            dual;

        if l_user_id is null then
            x_return_status := 'E';
            x_error_message := 'Error in Confirming your registration, Please contact customer service during business hours
                         or email us at customer.service@sterlingadministration.com';
        else
            update online_users
            set
                confirmed_flag = 'Y',
                last_update_date = sysdate,
                last_updated_by = user_id,
                first_time_pw_flag = 'N'
            where
                user_name = p_user_name;

            if sql%rowcount > 0 then
                x_return_status := 'S';
            end if;
        end if;

    end confirm_registration;

    function enroll_acc_exists (
        p_tax_id in varchar2
    ) return varchar2 is
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            online_users
        where
                user_type = 'E'
            and emp_reg_type = '1'
            and tax_id = p_tax_id
            and user_status = 'A';

        if l_count > 0 then
            return 'Y';
        else
            return 'N';
        end if;
    end enroll_acc_exists;

    function enroll_new_acct (
        p_user_id in varchar2
    ) return varchar2 is
        l_new_user varchar2(10) := 'N';
        l_count    number := 0;
    begin
        select
            count(*)
        into l_count
        from
            online_users a,
            enterprise   b,
            account      c
        where
                a.user_id = p_user_id
            and a.tax_id = b.entrp_code
            and b.entrp_id = c.entrp_id
            and c.account_status = 3
 -- and c.complete_flag <> 1
            and a.user_status = 'A';

        if l_count > 0 then
            return 'Y';
        end if;
        l_count := 0;
        select
            count(*)
        into l_count
        from
            lookups
        where
                lookup_name = 'ACCOUNT_TYPE'
            and lookup_code not in ( 'CMP', 'HRA', 'FSA' )
            and lookup_code not in (
                select
                    b.account_type
                from
                    enterprise   e, account      b, online_users ou
                where
                        ou.user_id = p_user_id
                    and e.entrp_id = b.entrp_id
                    and e.entrp_code = ou.tax_id
            );

        if l_count > 0 then
            return 'Y';
        else
            return 'N';
        end if;
    exception
        when too_many_rows then
            l_new_user := 'Y';
            return l_new_user;
        when others then
            return 'N';
    end enroll_new_acct;

    function get_products (
        p_user_id in number
    ) return accounts_t
        pipelined
        deterministic
    is
        l_record accounts_row_t;
    begin
        pc_log.log_error('get_products:user_id ', p_user_id);
        for x in (
            select
                emp_reg_type,
                tax_id,
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.emp_reg_type in ( '2' ) then   -- Added by jaggi - reg_type 5'id removed for #9829
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id,
                        decline_date
                    from
                        emp_overview_v
                    where
                            ein = x.tax_id
                      /* Employer Online portal */
                        and complete_flag = 1
                        and ( ( x.user_type = 'B'
                                and account_status in ( 1, 3 ) )
                              or ( x.user_type = 'G'
                                   and account_status in ( 1, 3 ) )
                              or ( x.user_type = 'E'
                                   and account_status in ( 1, 11 ) ) -- 11 Added by Swamy for Ticket#12309
                              or ( x.user_type = 'S'
                                   and account_status in ( 1 ) ) )  -- added by jaggi #11229
                        and account_type in ( 'HRA', 'FSA', 'HSA', 'COBRA', 'POP',
                                              'ERISA_WRAP', 'FORM_5500', 'LSA', 'ACA', 'CMP',
                                              'RB' )
                )  -- ACA Added by Swamy for Ticket#10844  -- LSA added by Swamy for Ticket#9912
                 loop                                                                                                             -- AB Added by Jaggi #11689
                    l_record.acc_num := xx.acc_num;
                    l_record.account_type := xx.account_type;
                    l_record.account_status := xx.account_status;
                    l_record.meaning := pc_lookups.get_account_type(xx.account_type);
                    l_record.acc_id := xx.acc_id;
                    l_record.entrp_id := xx.entrp_id;
                    l_record.broker_id := xx.broker_id;
                    l_record.decline_date := xx.decline_date;        -- Added by Swamy for Ticket#8949;

                    pipe row ( l_record );
                end loop;

            else
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id,
                        decline_date
                    from
                        emp_overview_v a
                    where
                            a.ein = x.tax_id
                        and complete_flag = 1
                        and ( ( x.user_type = 'B'
                                and account_status in ( 1, 3 ) )
                              or ( x.user_type = 'G'
                                   and account_status in ( 1, 3 ) )
                              or ( x.user_type = 'E'
                                   and account_status in ( 1, 11 ) )   -- 11 Added by Swamy for Ticket#12309
                              or ( x.user_type = 'S'
                                   and account_status in ( 1 ) ) )  -- added by jaggi #11229
                        and a.account_type in (
                            select
                                account_type
                            from
                                user_role_entries b, site_navigation   c
                            where
                                    b.user_id = p_user_id
                                and b.site_nav_id = c.site_nav_id
                        )
                ) loop
                    l_record.acc_num := xx.acc_num;
                    l_record.account_type := xx.account_type;
                    l_record.account_status := xx.account_status;
                    l_record.meaning := pc_lookups.get_account_type(xx.account_type);
                    l_record.acc_id := xx.acc_id;
                    l_record.entrp_id := xx.entrp_id;
                    l_record.broker_id := xx.broker_id;
                    l_record.decline_date := xx.decline_date;        -- Added by Swamy for Ticket#8949;

                    pipe row ( l_record );
                end loop;
            end if;
        end loop;

    end get_products;

-- Whether the ER has completed or not, all the ones he is associated with is listed here
    function get_all_products (
        p_user_id in number
    ) return accounts_t
        pipelined
        deterministic
    is
        l_record accounts_row_t;
    begin
        pc_log.log_error('get_products:user_id ', p_user_id);
        for x in (
            select
                emp_reg_type,
                tax_id
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.emp_reg_type in ( '5', '2' ) then
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id
                    from
                        emp_overview_v
                    where
                            ein = x.tax_id
                        and account_type in ( 'HRA', 'FSA', 'HSA', 'COBRA', 'POP',
                                              'ERISA_WRAP', 'FORM_5500' )
                        and decline_date is null
                )  -- Added by Swamy for Ticket#8949
                 loop
                    l_record.acc_num := xx.acc_num;
                    l_record.account_type := xx.account_type;
                    l_record.account_status := xx.account_status;
                    l_record.meaning := pc_lookups.get_account_type(xx.account_type);
                    l_record.acc_id := xx.acc_id;
                    l_record.entrp_id := xx.entrp_id;
                    l_record.broker_id := xx.broker_id;
                    pipe row ( l_record );
                end loop;

            else
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id
                    from
                        emp_overview_v a
                    where
                            a.ein = x.tax_id
                        and a.account_type in (
                            select
                                account_type
                            from
                                user_role_entries b, site_navigation   c
                            where
                                    b.user_id = p_user_id
                                and b.site_nav_id = c.site_nav_id
                        )
                        and a.decline_date is null
                )   -- Added by Swamy for Ticket#8949
                 loop
                    l_record.acc_num := xx.acc_num;
                    l_record.account_type := xx.account_type;
                    l_record.account_status := xx.account_status;
                    l_record.meaning := pc_lookups.get_account_type(xx.account_type);
                    l_record.acc_id := xx.acc_id;
                    l_record.entrp_id := xx.entrp_id;
                    l_record.broker_id := xx.broker_id;
                    pipe row ( l_record );
                end loop;
            end if;
        end loop;

    end get_all_products;

    function get_nav_list (
        p_user_id               in number,
        p_account_type          in varchar2,
        p_is_broker             in varchar2 default null,
        p_broker_enroll         in varchar2 default null,
        p_broker_renewal        in varchar2 default null,
        p_broker_invoices       in varchar2 default null,
        p_broker_enroll_ee      in varchar2 default null  --- ticket 7781 prabu on 17/05/2019
        ,
        p_broker_enroll_rpts    in varchar2 default null  --- ticket 7781 prabu on 17/05/2019
        ,
        p_broker_ee             in varchar2 default null    --- ticket 7781 prabu on 17/05/2019
        ,
        p_allow_bro_upd_pln_doc in varchar2 default null    --- ticket 8728  prabu on 18/02/2020
        ,
        p_tax_id                in varchar2 default null
    ) return roles_t
        pipelined
        deterministic
    is
        l_record roles_row_t;
        l_tax_id varchar2(100);
        l_renew  varchar2(10);
    begin
        if p_is_broker = 'Y' then /*Ticket#6834 Broker Details */
            for xx in (
                select
                    web_nav_code,
                    web_nav_url,
                    nav_description
                from
                    site_navigation c
                where
                        c.status = 'A'
                    and c.account_type = p_account_type
                    and ( c.nav_code like '%ACCSUM'
                          or ( c.nav_code like '%_EE'
                               and p_broker_ee = 'Y' )  --- 7781
                          or ( c.nav_code like '%_ENROLL'
                               and p_broker_enroll_ee = 'Y' )   --- 7781
                          or ( c.nav_code like '%_REP'
                               and p_broker_enroll_rpts = 'Y' ) )  --- 7781
                order by
                    c.seq_no asc
            ) loop
                l_record.nav_code := xx.web_nav_code;
                l_record.redirect_url := xx.web_nav_url;
                l_record.url_description := xx.nav_description;
                pipe row ( l_record );
            end loop;

            if p_broker_enroll = 'Y' then
                l_record.nav_code := 'products';
                l_record.redirect_url := '/Accounts/Portfolio/newEREnroll/';
                l_record.url_description := 'Products';
                pipe row ( l_record );
            end if;

            if p_broker_renewal = 'Y' then
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id
                    from
                        emp_overview_v
                    where
                            ein = p_tax_id
                        and account_type = p_account_type
                ) loop
                    if p_account_type = 'FORM_5500' then   -- Ticket#8049 done by rprabu
                        for x in (
                            select
                                renewed
                            from
                                table ( pc_web_compliance.get_er_plans(xx.acc_id, 'FORM_5500', p_tax_id) )
                        )/*Modified for Ticket#7306 */ loop
                            l_renew := x.renewed;
                            if l_renew = 'N' then
                                l_record.nav_code := 'form5500_renewal';
                                l_record.redirect_url := '/Employers/OnlineRenewal/';    -- Ticket#5759 done by rprabu
                                l_record.url_description := 'Renewal';
                                pipe row ( l_record );
                            end if;

                        end loop;
                    end if;

                    if p_account_type = 'ERISA_WRAP' then
                        for x in (
                            select
                                renewed
                            from
                                table ( pc_web_compliance.get_er_plans(xx.acc_id, 'ERISA_WRAP', p_tax_id) )
                        )/*Modified for Ticket#7306 */ loop
                            l_renew := x.renewed;
                            if l_renew = 'N' then
                        --AND PC_WEB_COMPLIANCE.EMP_PLAN_RENEWAL_DISP_ERISA(xx.acc_id) = 'Y'
                                l_record.nav_code := 'erisa_renewal';
                                 --- l_record.redirect_url    := '/ERISA/Employers/Renewal/';--  commented for Ticket#5759 done by rprabu
                                l_record.redirect_url := '/Employers/OnlineRenewal/';    -- Ticket#5759 done by rprabu
                                l_record.url_description := 'Renewal';
                                pipe row ( l_record );
                            end if;

                        end loop;

                    end if;

                    if
                        p_account_type = 'COBRA'
                        and pc_web_compliance.emp_plan_renewal_disp_cobra(xx.acc_id) = 'Y'
                    then
                        l_record.nav_code := 'cobra_renewal';
                     --       l_record.redirect_url    := '/COBRA/Employers/Renewal/';--  commented for Ticket#5759 done by rprabu
                        l_record.redirect_url := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                        l_record.url_description := 'Renewal';
                        pipe row ( l_record );
                    end if;

                    if
                        p_account_type in ( 'FSA', 'HRA' )
                        and pc_web_er_renewal.emp_plan_renewal_disp(xx.acc_id) = 'Y'
                    then
                        l_record.nav_code := 'online_Renewal';
                        l_record.redirect_url := '/Employers/OnlineRenewal/';
                        l_record.url_description := 'Plan Renewal';
                        pipe row ( l_record );
                    end if;

                end loop;
            end if; /*Broker renewal IF */
            pc_log.log_error('Here...123', p_broker_invoices);
            if p_broker_invoices = 'Y' then
                for xx in (
                    select
                        web_nav_code,
                        web_nav_url,
                        nav_description,
                        nav_code
                    from
                        site_navigation c
                    where
                            c.status = 'A'
                        and c.account_type = p_account_type
                        and upper(nav_code) like '%INV%'
                    order by
                        c.seq_no asc
                ) loop
                    l_record.nav_code := xx.web_nav_code;
                    l_record.redirect_url := xx.web_nav_url;
                    l_record.url_description := xx.nav_description;
                    pipe row ( l_record );
                end loop;
            end if; /*Broker Invoice IF */

    -------- 8728  rprabu 18/02/2020

            if p_allow_bro_upd_pln_doc = 'Y' then
                for xx in (
                    select
                        web_nav_code,
                        web_nav_url,
                        nav_description,
                        nav_code
                    from
                        site_navigation c
                    where
                            c.status = 'A'
                        and c.account_type = p_account_type
                        and upper(web_nav_code) = 'PLAN_DOC'
                    order by
                        c.seq_no asc
                ) loop
                    l_record.nav_code := xx.web_nav_code;
                    l_record.redirect_url := xx.web_nav_url;
                    l_record.url_description := xx.nav_description;
                    pipe row ( l_record );
                end loop;
            end if; /*Broker  plan document Yes */

    -------- 8728 END   rprabu 18/02/2020

        else /*Employer  */
            for x in (
                select
                    emp_reg_type,
                    tax_id
                from
                    online_users
                where
                    user_id = p_user_id
            ) loop
                l_tax_id := x.tax_id;
                if x.emp_reg_type in ( '5', '2' ) then
                    for xx in (
                        select
                            web_nav_url,
                            nav_description,
                            web_nav_code
                        from
                            site_navigation
                        where
                                account_type = p_account_type
                            and status = 'A'
                        order by
                            seq_no asc
                    ) loop
                        l_record.nav_code := xx.web_nav_code;
                        l_record.redirect_url := xx.web_nav_url;
                        l_record.url_description := xx.nav_description;
                        pipe row ( l_record );
                    end loop;

                else
                    for xx in (
                        select
                            web_nav_url,
                            nav_description,
                            web_nav_code
                        from
                            user_role_entries b,
                            site_navigation   c
                        where
                                b.site_nav_id = c.site_nav_id
                            and b.user_id = p_user_id
                            and c.status = 'A'
                            and c.account_type = p_account_type
                        order by
                            c.seq_no asc
                    ) loop
                        l_record.nav_code := xx.web_nav_code;
                        l_record.redirect_url := xx.web_nav_url;
                        l_record.url_description := xx.nav_description;
                        pipe row ( l_record );
                    end loop;
                end if;

                l_record.nav_code := 'user_profile';
                l_record.redirect_url := '/Accounts/Profiles/ERUserProfile/';
                l_record.url_description := 'User Profile';
                pipe row ( l_record );
                if pc_users.enroll_new_acct(p_user_id) = 'Y' then
                    l_record.nav_code := 'products';
                    l_record.redirect_url := '/Accounts/Portfolio/newEREnroll/';
                    l_record.url_description := 'Products';
                    pipe row ( l_record );
                end if;

                if x.emp_reg_type in ( '5', '2' ) then
                    l_record.nav_code := 'company_profile';
                    l_record.redirect_url := '/Accounts/Profiles/CompanyProfile/';
                    l_record.url_description := 'Company Profile';
                    pipe row ( l_record );
                    l_record.nav_code := 'manage_user';
                    l_record.redirect_url := '/Accounts/User/ManageAdmin/';
                    l_record.url_description := 'Manage Site Users';
                    pipe row ( l_record );
                end if;

                l_record.nav_code := 'messages';
                l_record.redirect_url := '/Accounts/Messages/MessageCenter/';
                l_record.url_description := 'Message Center';
                pipe row ( l_record );
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id
                    from
                        emp_overview_v
                    where
                            ein = l_tax_id
                        and account_type = p_account_type ---    fixed by prabu 17/05/2019  Ticket #7314
                ) loop
                    if p_account_type = 'FORM_5500' then   -- Ticket#8049 done by rprabu
                        for x in (
                            select
                                renewed
                            from
                                table ( pc_web_compliance.get_er_plans(xx.acc_id, 'FORM_5500', p_tax_id) )
                        )/*Modified for Ticket#7306 */ loop
                            l_renew := x.renewed;
                            if l_renew = 'N' then
                                l_record.nav_code := 'form5500_renewal';
                                l_record.redirect_url := '/Employers/OnlineRenewal/';    -- Ticket#5759 done by rprabu
                                l_record.url_description := 'Renewal';
                                pipe row ( l_record );
                            end if;

                        end loop;
                    end if;

                    if xx.account_type = 'ERISA_WRAP' then
                        select
                            renewed
                        into l_renew
                        from
                            table ( pc_web_compliance.get_er_plans(xx.acc_id, 'ERISA_WRAP', l_tax_id) );/*Modified for Ticket#7306 */
                        if l_renew = 'N' then
              --AND PC_WEB_COMPLIANCE.EMP_PLAN_RENEWAL_DISP_ERISA(xx.acc_id) = 'Y'
                            l_record.nav_code := 'erisa_renewal';
                     --- l_record.redirect_url    := '/ERISA/Employers/Renewal/'; -- commented for  Ticket#5759 done by rprabu
                            l_record.redirect_url := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                            l_record.url_description := 'Renewal';
                            pipe row ( l_record );
                        end if;

                    end if;

                    if
                        xx.account_type = 'COBRA'
                        and pc_web_compliance.emp_plan_renewal_disp_cobra(xx.acc_id) = 'Y'
                    then
                        l_record.nav_code := 'cobra_renewal';
               ---   l_record.redirect_url    := '/COBRA/Employers/Renewal/'; -- commented for  Ticket#5759 done by rprabu
                        l_record.redirect_url := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                        l_record.url_description := 'Renewal';
                        pipe row ( l_record );
                    end if;

                     --- 7794 rprabu 07/04/2020
                    if
                        xx.account_type = 'POP'
                        and pc_web_compliance.emp_plan_renewal_disp_pop(xx.acc_id, 'POP') = 'Y'
                    then
                        l_record.nav_code := 'pop_renewal';
                        l_record.redirect_url := '/Employers/OnlineRenewal/';  -- Ticket#5759 done by rprabu
                        l_record.url_description := 'Renewal';
                        pipe row ( l_record );
                    end if;
                    --- 7794 rprabu 07/04/2020

                    if
                        xx.account_type in ( 'FSA', 'HRA' )
                        and pc_web_er_renewal.emp_plan_renewal_disp(xx.acc_id) = 'Y'
                    then
                        l_record.nav_code := 'online_Renewal';
                        l_record.redirect_url := '/Employers/OnlineRenewal/';
                        l_record.url_description := 'Plan Renewal';
                        pipe row ( l_record );
                    end if;

                end loop;

            end loop;
        end if; /*Broker Employer IF */
    end get_nav_list;

 --- rprabu 06/05/2020 #ticket 8837
    function get_nav_list_v2_old (
        p_user_id               in number,
        p_account_type          in varchar2,
        p_is_broker             in varchar2 default null,
        p_broker_enroll         in varchar2 default null,
        p_broker_renewal        in varchar2 default null,
        p_broker_invoices       in varchar2 default null,
        p_broker_enroll_ee      in varchar2 default null,
        p_broker_enroll_rpts    in varchar2 default null,
        p_broker_ee             in varchar2 default null,
        p_allow_bro_upd_pln_doc in varchar2 default null,
        p_tax_id                in varchar2 default null
    ) return pc_users.roles_t
        pipelined
        deterministic
    is
        l_record pc_users.roles_row_t;
        l_tax_id varchar2(100);
        l_renew  varchar2(10);
    begin
        for x in (
            select
                tax_id,
                emp_reg_type,
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.user_type = 'E' then
                if nvl(p_is_broker, 'N') = 'N' then /*Ticket#6834 Broker Details */

                    for er_nav in (
                        select
                            web_nav_url,
                            nav_description,
                            web_nav_code,
                            seq_no
                        from
                            (
                                select
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no
                                from
                                    site_navigation
                                where
                                        account_type = p_account_type
                                    and status = 'A'
                                    and portal_type = 'EMPLOYER'
                                    and conditional_flag = 'N'
                                    and x.emp_reg_type in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                                union
                                select
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no
                                from
                                    site_navigation   s,
                                    user_role_entries ur
                                where
                                        s.account_type = p_account_type
                                    and s.status = 'A'
                                    and s.site_nav_id = ur.site_nav_id
                                    and ur.user_id = p_user_id
                                    and portal_type = 'EMPLOYER'
                                    and s.conditional_flag = 'N'
                                    and x.emp_reg_type not in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                                union
                                select
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no
                                from
                                    site_navigation s
                                where
                                    nav_code in ( 'user_profile', 'messages' )   -- Removed products nav_code by swamy for Ticket#9891 on 18/05/2021 and added it below
                                    and portal_type = 'EMPLOYER'
                                    and pc_users.enroll_new_acct(p_user_id) = 'Y'
                                union                                                -- Added Union cond by swamy for Ticket#9891 on 18/05/2021
                                select
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no
                                from
                                    site_navigation s
                                where
                                        nav_code = 'products'
                                    and portal_type = 'EMPLOYER'
                                    and pc_users.enroll_new_acct(p_user_id) = 'Y'
                                    and x.emp_reg_type <> '5'
                                union
                                select
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no
                                from
                                    (
                                        select
                                            account_type,
                                            case
                                                when account_type in ( 'HRA', 'FSA' ) then
                                                    pc_web_er_renewal.emp_plan_renewal_disp(xx.acc_id)
                                                when account_type = 'COBRA'      then
                                                    pc_web_compliance.emp_plan_renewal_disp_cobra(xx.acc_id)
                                                when account_type = 'POP'        then
                                                    nvl(
                                                        pc_web_compliance.emp_plan_renewal_disp_pop(xx.acc_id, 'POP'),
                                                        'N'
                                                    ) -- 8837
                                                when account_type = 'FORM_5500'  then
                                                    pc_web_compliance.emp_plan_renwl_disp_form_5500(xx.acc_id)
                                                when account_type = 'ERISA_WRAP' then
                                                    pc_web_compliance.emp_plan_renewal_disp_erisa(xx.acc_id)
                                            end renewed
                                        from
                                            emp_overview_v xx
                                        where
                                                ein = p_tax_id
                                            and account_type = p_account_type
                                            and account_type in ( 'HRA', 'FSA', 'COBRA', 'ERISA_WRAP', 'FORM_5500',
                                                                  'POP' )
                                    )               renewal,
                                    site_navigation s
                                where
                                        renewal.account_type = s.account_type
                                    and renewal.renewed = 'Y'
                                    and s.portal_type = 'EMPLOYER'
                                    and s.nav_code = 'renewal'
                                    and s.conditional_flag = 'Y'
                                    and x.emp_reg_type <> '5'      -- Added AND cond by swamy for Ticket#9891 on 18/05/2021
                                union
                                select
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no
                                from
                                    site_navigation s
                                where
                                    nav_code not in ( 'renewal', 'products' )
                                    and portal_type = 'EMPLOYER'
                                    and conditional_flag = 'Y'
                                    and x.emp_reg_type in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                                union
                  -- Added by Joshi for 9072 (EDI Feed menu option should be shown only when EDI flag is 'Y'
                                select
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no
                                from
                                    site_navigation s
                                where
                                        nav_code = 'edi_feeds'
                                    and portal_type = 'EMPLOYER'
                                    and x.emp_reg_type in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                                    and pc_account.get_edi_flag(p_tax_id) = 'Y'
                            )
                        order by
                            seq_no asc
                    ) loop
                        l_record.nav_code := er_nav.web_nav_code;
                        l_record.redirect_url := er_nav.web_nav_url;
                        l_record.url_description := er_nav.nav_description;
                        pipe row ( l_record );
                    end loop;

                    null;
                else
                    for nav_details in (
                        select
                            web_nav_url,
                            nav_description,
                            web_nav_code
                        from
                            (
                                select
                                    site_nav_id,
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no,
                                    nav_code
                                from
                                    site_navigation
                                where
                                        account_type = p_account_type
                                    and status = 'A'
                                    and portal_type = 'EMPLOYER'
                                    and conditional_flag = 'N'
                                union
                                select
                                    site_nav_id,
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no,
                                    nav_code
                                from
                                    site_navigation
                                where
                                        nav_code = 'products'
                                    and pc_users.enroll_new_acct(p_user_id) = 'Y'
                                    and p_broker_enroll = 'Y'
                                    and portal_type = 'EMPLOYER'
                                union
                                select
                                    site_nav_id,
                                    web_nav_url,
                                    nav_description,
                                    web_nav_code,
                                    seq_no,
                                    nav_code
                                from
                                    (
                                        select
                                            account_type,
                                            case
                                                when account_type in ( 'HRA', 'FSA' ) then
                                                    pc_web_er_renewal.emp_plan_renewal_disp(xx.acc_id)
                                                when account_type = 'COBRA'      then
                                                    pc_web_compliance.emp_plan_renewal_disp_cobra(xx.acc_id)
                                                when account_type = 'POP'        then
                                                    pc_web_compliance.emp_plan_renewal_disp_pop(xx.acc_id, 'POP')
                                                when account_type = 'FORM_5500'  then
                                                    pc_web_compliance.emp_plan_renwl_disp_form_5500(xx.acc_id)
                                                when account_type = 'ERISA_WRAP' then
                                                    pc_web_compliance.emp_plan_renewal_disp_erisa(xx.acc_id)
                                            end renewed
                                        from
                                            emp_overview_v xx
                                        where
                                                ein = p_tax_id
                                            and account_type = p_account_type
                                            and account_type in ( 'HRA', 'FSA', 'COBRA', 'ERISA_WRAP', 'FORM_5500',
                                                                  'POP' )
                                    )               renewal,
                                    site_navigation s
                                where
                                        renewal.account_type = s.account_type
                                    and renewal.renewed = 'Y'
                                    and s.portal_type = 'EMPLOYER'
                                    and s.nav_code = 'renewal'
                                    and s.conditional_flag = 'Y'
                                    and p_broker_renewal = 'Y'
                            ) c
                        where
                            c.web_nav_code = 'employer_dashboard'
                            or ( c.nav_code in ( 'products', 'renewal' ) )
                            or ( c.web_nav_code = 'employees'
                                 and p_broker_ee = 'Y' )
                            or ( c.web_nav_code = 'bulkenrollment'
                                 and p_broker_enroll_ee = 'Y' )
                            or ( upper(c.web_nav_code) like '%REPORT%'
                                 and p_broker_enroll_rpts = 'Y' )
                            or ( c.web_nav_code in ( 'plan_doc', 'upload_rate_plans' )
                                 and p_allow_bro_upd_pln_doc = 'Y' )
                            or ( upper(c.web_nav_code) like '%INV%'
                                 and p_broker_invoices = 'Y' )
                        order by
                            seq_no asc
                    ) loop
                        l_record.nav_code := nav_details.web_nav_code;
                        l_record.redirect_url := nav_details.web_nav_url;
                        l_record.url_description := nav_details.nav_description;
                        pipe row ( l_record );
                    end loop;
                end if;

            elsif x.user_type in ( 'G', 'B' ) then -- 8890 rprabu 17/06/2020

                l_record.nav_code := null;
                l_record.redirect_url := null;
                l_record.url_description := null;
                for broker_nav in (
                    select
                        web_nav_url,
                        nav_description,
                        web_nav_code,
                        seq_no
                    from
                        (
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation
                            where
                                    status = 'A'
                                and portal_type = decode(x.user_type, 'B', 'BROKER', 'G', 'GA')
                                and x.emp_reg_type in ( '5', '2' )
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation   s,
                                user_role_entries ur
                            where
                                    s.status = 'A'
                                and s.site_nav_id = ur.site_nav_id
                                and ur.user_id = p_user_id
                                and portal_type = decode(x.user_type, 'B', 'BROKER', 'G', 'GA')
                                and x.emp_reg_type not in ( '5', '2' )
                        )
                    order by
                        seq_no asc
                ) loop
                    l_record.nav_code := broker_nav.web_nav_code;
                    l_record.redirect_url := broker_nav.web_nav_url;
                    l_record.url_description := broker_nav.nav_description;
                    pipe row ( l_record );
                end loop;

            end if;
        end loop;
    end get_nav_list_v2_old;

    function get_user_details (
        p_tax_id          in varchar2,
        p_conf_email_type in varchar2
    ) return user_det_t
        pipelined
        deterministic
    is
        l_record_t user_detail_row_t;
    begin
        if p_conf_email_type = 'CONFIRMATION_EMAIL' then
            for x in (
                select
                    user_name,
                    email,
                    user_type,
                    confirmed_flag
                from
                    online_users
                where
                    tax_id = p_tax_id
            ) loop
                l_record_t.user_name := x.user_name;
                l_record_t.email := x.email;
                l_record_t.user_type := x.user_type;
                l_record_t.confirmed_flag := x.confirmed_flag;
                l_record_t.registered := 'Y';
            end loop;

            if l_record_t.user_type = 'E' then
                for x in (
                    select
                        name,
                        b.account_type,
                        b.acc_num
                    from
                        enterprise a,
                        account    b
                    where
                            regexp_replace(entrp_code, '[^[:digit:]]+', '') = ( regexp_replace(p_tax_id, '[^[:digit:]]+', '') )
                        and a.entrp_id = b.entrp_id
                        and b.account_type in ( 'HRA', 'FSA', 'HSA' )
                ) loop
                    l_record_t.name := x.name;
                    l_record_t.account_type := x.account_type;
                    l_record_t.acc_num := x.acc_num;
                end loop;

            end if;

            if l_record_t.user_type = 'S' then
                for x in (
                    select
                        first_name
                        || ' '
                        || last_name name,
                        b.account_type,
                        b.acc_num
                    from
                        person  a,
                        account b
                    where
                            ssn = format_ssn(p_tax_id)
                        and a.pers_id = b.pers_id
                        and b.account_type in ( 'HRA', 'FSA', 'HSA' )
                ) loop
                    l_record_t.name := x.name;
                    l_record_t.account_type := x.account_type;
                    l_record_t.acc_num := x.acc_num;
                end loop;
            end if;

            if l_record_t.user_type = 'B' then
                for x in (
                    select
                        first_name
                        || ' '
                        || last_name name
                    from
                        person a,
                        broker b
                    where
                            a.pers_id = b.broker_id
                        and b.broker_lic = p_tax_id
                ) loop
                    l_record_t.name := x.name;
                end loop;
            end if;

            pipe row ( l_record_t );
        end if;

        if p_conf_email_type = 'MASS_ENROLL_EMAIL' then
            for x in (
                select
                    a.entrp_id,
                    a.first_name
                    || ' '
                    || a.last_name name,
                    a.email,
                    b.acc_num,
                    b.account_type
                from
                    person  a,
                    account b
                where
                        a.ssn = format_ssn(p_tax_id)
                    and a.pers_id = b.pers_id
            ) loop
                l_record_t.name := x.name;
                l_record_t.account_type := x.account_type;
                l_record_t.acc_num := x.acc_num;
                l_record_t.employer_id := pc_entrp.get_acc_num(x.entrp_id);
            end loop;

            for x in (
                select
                    enrollment_id
                from
                    online_enrollment
                where
                    acc_num = l_record_t.acc_num
            ) loop
                l_record_t.enrollment_id := x.enrollment_id;
            end loop;

            for x in (
                select
                    user_name,
                    email,
                    user_type,
                    confirmed_flag
                from
                    online_users
                where
                    tax_id = p_tax_id
            ) loop
                l_record_t.user_name := x.user_name;
                l_record_t.email := x.email;
                l_record_t.user_type := x.user_type;
                l_record_t.confirmed_flag := x.confirmed_flag;
                l_record_t.registered := 'Y';
            end loop;

            if l_record_t.enrollment_id is not null then
                pipe row ( l_record_t );
            end if;
        end if;

    end get_user_details;

    function get_ee_enrolled_products (
        p_ssn in varchar2
    ) return accounts_t
        pipelined
        deterministic
    is
        l_record accounts_row_t;
    begin
        for x in (
            select
                acc_num,
                account_type,
                acc_num
                || '('
                || account_type
                || ')'                                              meaning,
                pc_lookups.get_account_type(account_type)           account_type_meaning,
                decode(account_type, 'COBRA', null, acc_balance)    acc_balance,
                decode(account_type, 'COBRA', 1, account_status)    account_status,
                pc_lookups.get_meaning(
                    p_lookup_code => account_status,
                    p_lookup_name => 'ACCOUNT_STATUS'
                )                                                   account_status_meaning  -- Added by Swamy for Ticket#10978 13062024
                ,
                decode(account_type,
                       'COBRA',
                       null,
                       pc_web_utility_pkg.has_active_plan(acc_num)) plan_count,
                decode(account_type, 'COBRA', null, closed_reason)  closed_reason,
                acc_id,
                entrp_id,
                show_account_online              -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                acc_overview_v
            where
                    tax_id = p_ssn
                and account_type in ( 'HRA', 'FSA', 'HSA', 'RB', 'LSA',
                                      'ACA', 'CMP' )  -- ACA added by Swamy for Ticket#10844      -- Added by Swamy for Ticket#9912 on 10/08/2021   -- Added RB by Swamy for Ticket#9656 on 24/03/2021
            union
            select
                acc_num,
                'COBRA',
                acc_num || '(COBRA)' meaning,
                'COBRA'              account_type_meaning,
                null,
                1,
                pc_lookups.get_meaning(
                    p_lookup_code => 1,
                    p_lookup_name => 'ACCOUNT_STATUS'
                )                    account_status_meaning   -- Added by Swamy for Ticket#10978 13062024
                ,
                null,
                null,
                b.acc_id,
                c.entrp_id,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                qb      a,
                account b,
                person  c
            where
                    a.ssn = c.ssn
                and c.ssn = format_ssn(p_ssn)
                and a.allowsso = 1
                and b.migrated_flag = 'N'
                and a.active = 1
        --AND    C.ORIG_SYS_VENDOR_REF = A.MEMBERID
                and b.pers_id = c.pers_id
                and b.account_type = 'COBRA'
            union
            select
                acc_num,
                'COBRA',
                acc_num || '(COBRA)' meaning,
                'COBRA'              account_type_meaning,
                null,
                1,
                pc_lookups.get_meaning(
                    p_lookup_code => 1,
                    p_lookup_name => 'ACCOUNT_STATUS'
                )                    account_status_meaning   -- Added by Swamy for Ticket#10978 13062024
                ,
                null,
                null,
                b.acc_id,
                c.entrp_id,
                b.show_account_online   -- Added by Swamy for Ticket#9332 on 06/11/2020
            from
                account b,
                person  c
            where
                    c.ssn = format_ssn(p_ssn)
         -- AND B.MIGRATED_FLAG = 'Y'
                and b.account_status = 1
        --AND    C.ORIG_SYS_VENDOR_REF = A.MEMBERID
                and b.pers_id = c.pers_id
                and b.account_type = 'COBRA'
        ) loop
            if nvl(x.closed_reason, '-1') <> 'CLOSED_NON_FUNDS' then
                l_record.acc_num := x.acc_num;
                l_record.account_type := x.account_type;
                l_record.meaning := x.meaning;
                l_record.account_type_meaning := x.account_type_meaning;
                l_record.acc_balance := x.acc_balance;
                l_record.account_status := x.account_status;
                l_record.plan_count := x.plan_count;
                l_record.acc_id := x.acc_id;
                l_record.entrp_id := x.entrp_id;
                l_record.show_account_online := x.show_account_online;  -- Added by Swamy for Ticket#9332 on 06/11/2020     
                l_record.account_status_meaning := x.account_status_meaning; -- Added by Swamy for Ticket#10978 13062024

                pipe row ( l_record );
            end if;
        end loop;
    end get_ee_enrolled_products;

    function get_er_enrolled_products (
        p_ein in varchar2
    ) return accounts_t
        pipelined
        deterministic
    is
        l_record accounts_row_t;
    begin
        for x in (
            select
                acc_id,
                acc_num,
                account_type,
                acc_num
                || '('
                || account_type
                || ')' meaning
            from
                emp_overview_v
            where
                    ein = replace(p_ein, '-')
                and account_type <> 'COBRA'
                and account_status = 1
            union
            select
                acc_id,
                acc_num,
                account_type,
                acc_num
                || '('
                || account_type
                || ')' meaning
            from
                emp_overview_v
            where
                    ein = replace(p_ein, '-')
                and account_type = 'COBRA'
                and account_status = 1
        )
                    -- Commented by Swamy for Ticket#11605 05/05/2023
					/*AND EXISTS (   SELECT LOWER(A.SSOIDENTIFIER) SSOIDENTIFIER,B.CLIENTID
                              FROM CLIENTCONTACT A, CLIENT B
                              WHERE A.CLIENTID = B.CLIENTID
                              AND   A.ALLOWSSO = 1
                              AND   a.firstname IS NOT NULL
                              AND   A.LASTNAME IS NOT NULL
                              AND   A.ACTIVE = 1
                              AND   TO_CHAR(B.EIN) = REPLACE(replace(emp_OVERVIEW_V.EIN,'-'),' ','')))*/ loop
            l_record.acc_num := x.acc_num;
            l_record.account_type := x.account_type;
            l_record.meaning := x.meaning;
            l_record.acc_id := x.acc_id;
            pipe row ( l_record );
        end loop;
    end get_er_enrolled_products;

    function is_portfolio_account (
        p_ssn in varchar2
    ) return varchar2 is
        l_flag  varchar2(1) := 'N';
        l_count number := 0;
    begin
        select
            count(*)
        into l_count
        from
            person  a,
            account b
        where
                a.ssn = format_ssn(p_ssn)
            and a.pers_id = b.pers_id
            and nvl(b.closed_reason, '-1') <> 'CLOSED_NO_FUNDS';

        if l_count > 1 then
            return 'Y';
        else
            select
                count(*)
            into l_count
            from
                enterprise a,
                account    b
            where
                    a.entrp_code = replace(
                        replace(p_ssn, '-'),
                        ' '
                    )
                and a.entrp_id = b.entrp_id;

            if l_count > 1 then
                return 'Y';
            else
                return 'N';
            end if;
        end if;

    end is_portfolio_account;

    function get_er_not_enrolled_plans (
        p_ein in varchar2
    ) return accounts_t
        pipelined
        deterministic
    is
        l_record            accounts_row_t;
        p_user_id           number;
        l_max_plan_end_date date;
    begin
        for x in (
            select
                acc_num,
                account_type,
                acc_num
                || '('
                || account_type
                || ')'    meaning,
                a.acc_id,
                b.entrp_id,
                a.complete_flag,
                a.account_status,
                c.meaning status_meaning    -- Added  By Rprabu For Ticket#9141 On 17/08/2020
                ,
                enrolle_type                          -- Added  By Rprabu For Ticket#9141 On 30/07/2020
                ,
                enrolled_by                           -- Added  By Rprabu For Ticket#9141 On 30/07/2020
                ,
                resubmit_flag                         -- Added  by Jagggi for Ticket#10430 on 04/11/2021
                ,
                a.signature_account_status             -- Added by Swamy for Tiecket#11364(Broker)
            from
                account    a,
                enterprise b,
                lookups    c
            where
                    b.entrp_code = replace(p_ein, '-')
                and b.entrp_id = a.entrp_id
             -- and complete_flag <> 1 --Not enrolled plans
                and decline_date is null --Plans not declined
                and c.lookup_code = to_char(a.account_status)           -- Added  By Rprabu For Ticket#9141 On 17/08/2020
                and lookup_name = 'ACCOUNT_STATUS'                       -- Added  By Rprabu For Ticket#9141 On 17/08/2020
                and a.account_status <> '4'   -- Added by Swamy for Ticket#8123
            union
            --Existing Users
            select
                null,
                lookup_code account_type,
                meaning,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
            from
                lookups
            where
                    lookup_name = 'ACCOUNT_TYPE'
                and lookup_code not in ( 'SBS', 'CMP', 'RB', 'ACA' ) -- added 'ACA' and 'RB' for ticket 8238.
                and not exists (
                    select
                        *
                    from
                        account    a,
                        enterprise b
                    where
                            b.entrp_code = replace(p_ein, '-')
                        and b.entrp_id = a.entrp_id
                        and a.account_type = lookups.lookup_code
                )
        ) loop
            l_record.acc_num := x.acc_num;
            l_record.account_type := x.account_type;
            l_record.meaning := x.meaning;
            l_record.entrp_id := x.entrp_id;
            l_record.acc_id := x.acc_id;
            l_record.account_status := x.account_status;
            l_record.complete_flag := x.complete_flag;
            l_record.account_status_meaning := x.status_meaning;          -- rprabu 9141 17/08/2020
            l_record.enrolle_type := x.enrolle_type;                -- Added  By Rprabu For Ticket#9141 On 30/07/2020
            l_record.enrolled_by := x.enrolled_by;                 -- Added  By Rprabu For Ticket#9141 On 30/07/2020
            l_record.resubmit_flag := x.resubmit_flag;               -- Added by Jagggi for Ticket#10430 on 04/11/2021
            l_record.signature_account_status := x.signature_account_status;       -- Added by Swamy for Tiecket#11364(Broker)

     -- Added By Joshi for 10430.
            l_record.inactive_plan_flag := 'N';
            if
                x.acc_id is not null
                and x.account_type not in ( 'SBS', 'CMP', 'RB', 'ACA' )
            then
                for y in (
                    select
                        plan_type,
                        max(plan_end_date) plan_end_date
                    from
                        account                   a,
                        ben_plan_enrollment_setup b
                    where
                            a.acc_id = b.acc_id
                        and a.acc_id = x.acc_id
                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        and a.account_type in ( 'FSA', 'HRA' )
                    group by
                        plan_type
                    union
                    select
                        'TRN',
                        max(b.end_date) plan_end_date
                    from
                        ben_plan_renewals b,
                        account           a
                    where
                            a.acc_id = b.acc_id
                        and b.acc_id = x.acc_id
                        and a.account_type in ( 'FSA', 'HRA' )
                        and b.plan_type in ( 'TRN', 'PKG', 'UA1' )
                    group by
                        b.acc_id
                    union
                    select
                        account_type,
                        max(plan_end_date) plan_end_date
                    from
                        account                   a,
                        ben_plan_enrollment_setup b
                    where
                            a.acc_id = b.acc_id
                        and a.acc_id = x.acc_id
                        and a.account_type not in ( 'FSA', 'HRA' )
                    group by
                        account_type
                ) loop

              -- Added code by Joshi for 11271.
                    if nvl(x.resubmit_flag, 'N') = 'N' then
                        if pc_account.get_account_type_from_entrp_id(x.entrp_id) = 'FORM_5500' then
                        -- For FORM5500 resubmit option is changed from 365 to 730 days as per Ticket#11131
                            if trunc(sysdate) - y.plan_end_date >= 730 then
                                l_record.inactive_plan_flag := 'Y';
                                l_record.complete_flag := 0;
                            else
                                l_record.inactive_plan_flag := 'N';
                                l_record.complete_flag := 1;
                            end if;

                        else
                            if ( sysdate - y.plan_end_date ) <= 365 then
                                l_record.inactive_plan_flag := 'N';
                                l_record.complete_flag := x.complete_flag;
                                exit; -- Added by Joshi for 10750
                            end if;

                     -- Added by Joshi for 10750
                            l_record.inactive_plan_flag := 'Y';
                            l_record.complete_flag := 0;
                        end if;

                    end if;
                end loop;
            end if;

            pipe row ( l_record );
        end loop;
    end get_er_not_enrolled_plans;

    function chk_all_product_enroll (
        p_tax_id in varchar2
    ) return varchar2 is
        l_plans_enrolled number := 0;
        l_tot_products   number := 0;
    begin
        select
            count(*)
        into l_tot_products
        from
            account    a,
            enterprise b
        where
                a.entrp_id = b.entrp_id
            and replace(b.entrp_code, '-') = replace(p_tax_id, '-');

        select
            count(*)
        into l_plans_enrolled
        from
            account    a,
            enterprise b
        where
                a.entrp_id = b.entrp_id
            and replace(b.entrp_code, '-') = replace(p_tax_id, '-')
            and exists (
                select
                    *
                from
                    ben_plan_enrollment_setup d
                where
                    d.acc_id = a.acc_id
            );

        if l_tot_products = l_plans_enrolled then
            return 'Y';
        else
            return 'N';
        end if;
    exception
        when no_data_found then
            return 'N';
    end chk_all_product_enroll;

    function get_products_er_online (
        p_user_id in number
    ) return accounts_t
        pipelined
        deterministic
    is
        l_record accounts_row_t;
    begin
        pc_log.log_error('get_products:user_id ', p_user_id);
        for x in (
            select
                emp_reg_type,
                tax_id
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.emp_reg_type in ( '5', '2' ) then
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id
                    from
                        emp_overview_v
                    where
                            ein = x.tax_id
                        and complete_flag = 1
                        and account_type in ( 'HRA', 'FSA', 'HSA', 'COBRA', 'POP',
                                              'ERISA_WRAP', 'FORM_5500' )
                ) loop
                    l_record.acc_num := xx.acc_num;
                    l_record.account_type := xx.account_type;
                    l_record.account_status := xx.account_status;
                    l_record.meaning := pc_lookups.get_account_type(xx.account_type);
                    l_record.acc_id := xx.acc_id;
                    l_record.entrp_id := xx.entrp_id;
                    l_record.broker_id := xx.broker_id;
                    pipe row ( l_record );
                end loop;

            else
                for xx in (
                    select
                        acc_num,
                        account_type,
                        account_status,
                        acc_id,
                        entrp_id,
                        broker_id
                    from
                        emp_overview_v a
                    where
                            a.ein = x.tax_id
                        and a.account_type in (
                            select
                                account_type
                            from
                                user_role_entries b, site_navigation   c
                            where
                                    b.user_id = p_user_id
                                and b.site_nav_id = c.site_nav_id
                        )
                ) loop
                    l_record.acc_num := xx.acc_num;
                    l_record.account_type := xx.account_type;
                    l_record.account_status := xx.account_status;
                    l_record.meaning := pc_lookups.get_account_type(xx.account_type);
                    l_record.acc_id := xx.acc_id;
                    l_record.entrp_id := xx.entrp_id;
                    l_record.broker_id := xx.broker_id;
                    pipe row ( l_record );
                end loop;
            end if;
        end loop;

    end get_products_er_online;

    function show_alert (
        p_user_id in varchar2
    ) return varchar2 is

        l_new_user_alert varchar2(10) := 'N';
        l_cnt            number := 0;
        l_cnt_enrolled   number := 0;
    begin
  --New User
        select
            count(*)
        into l_cnt
        from
            online_users a,
            enterprise   b,
            account      c
        where
                a.user_id = p_user_id
            and a.tax_id = b.entrp_code
            and b.entrp_id = c.entrp_id
--  and c.account_status = 3
            and c.complete_flag <> 1
            and a.user_status = 'A'
  --and c.account_type NOT in ( 'HRA','FSA')--Remove it later when FSA/HRA are included, 01152017, removing
            and c.decline_date is null;

        if l_cnt > 0 then --New users
            l_new_user_alert := 'Y';
        else --Existing users
            if l_cnt = 0 then
                select
                    count(*)
                into l_cnt_enrolled
                from
                    lookups
                where
                        lookup_name = 'ACCOUNT_TYPE'
                    and lookup_code not in ( 'CMP' ) -- 01152017, removing HRA/FSA
                    and lookup_code not in (
                        select
                            b.account_type
                        from
                            enterprise   e, account      b, online_users c
                        where
                                e.entrp_id = b.entrp_id
                            and replace(c.tax_id, '-') = replace(e.entrp_code, '-')
                            and c.user_id = p_user_id
                    );

                if l_cnt_enrolled = 0 then  --All products enrolled
                    l_new_user_alert := 'ALL';
                else
                    l_new_user_alert := 'N';
                end if;

            end if; --Existing users
        end if;--Outer Loop

        return l_new_user_alert;
    exception
        when no_data_found then
            l_new_user_alert := 'N';
            return l_new_user_alert;
    end show_alert;

    function skip_now_func (
        p_tax_id in varchar2
    ) return roles_t
        pipelined
        deterministic
    is
        l_record    roles_row_t;
        l_acct_type varchar2(100);
        l_acc_num   varchar2(100);
    begin
        for x in (
            select
                count(*) cnt,
                sum(
                    case
                        when a.account_status = 3 then
                            1
                        else
                            0
                    end
                )        pending,
                sum(
                    case
                        when a.account_status <> 3 then
                            1
                        else
                            0
                    end
                )        active_count
            from
                account    a,
                enterprise b
            where
                    replace(b.entrp_code, '-') = replace(p_tax_id, '-')
                and a.entrp_id = b.entrp_id
                and account_status <> 4
        ) loop
            if
                x.pending >= 1
                and x.active_count = 0
            then
                l_record.redirect_url := 'Accounts/Portfolio/newEREnroll';
            elsif
                x.pending >= 1
                and x.active_count > 1
            then
                l_record.redirect_url := 'Accounts/Portfolio/';
            elsif
                x.pending >= 1
                and x.active_count = 1
            then
                select
                    a.account_type,
                    a.acc_num
                into
                    l_acct_type,
                    l_acc_num
                from
                    account    a,
                    enterprise b
                where
                        replace(b.entrp_code, '-') = p_tax_id
                    and a.entrp_id = b.entrp_id
                    and account_status = 1;

                if l_acct_type = 'HSA' then
                    l_record.redirect_url := 'Employers/Detail/EmployerDashboard/';
                elsif l_acct_type = 'HRA' then
                    l_record.redirect_url := 'HRA/Employers/EmployerDashboard/';
                elsif l_acct_type = 'FSA' then
                    l_record.redirect_url := 'FSA/Employers/EmployerDashboard/';
                elsif l_acct_type = 'COBRA' then
                    l_record.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                elsif l_acct_type = 'ERISA_WRAP' then
                    l_record.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                elsif l_acct_type = 'POP' then
                    l_record.redirect_url := 'POP/Employers/EmployerDashboard/';
                elsif l_acct_type = 'FORM_5500' then
                    l_record.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                else
                    l_record.redirect_url := 'Accounts/Portfolio/';
                end if;

                l_record.nav_code := l_acc_num;
            end if;

            pipe row ( l_record );
        end loop;
    end skip_now_func;

    function get_pwd_recovery (
        p_user_name in varchar2
    ) return user_info_t
        pipelined
        deterministic
    is

        e_user_exception exception;
        l_count              number := 0;
        l_error_message      varchar2(3200);
        l_login              varchar2(1) := 'N';
        l_loggedin           varchar2(1) := 'N';
        l_skip_security      varchar2(10) := 'N';
        l_no_of_registration number := 0;
        l_record_t           user_info_row_t;
        l_user_id            number;
        l_no_accounts        number := 0;
    begin
        for x in (
            select
                *
            from
                online_users
            where
                user_name = trim(p_user_name)
        ) loop
            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'user_name ' || p_user_name);
            l_count := l_count + 1;
            l_record_t.user_id := x.user_id;
            l_record_t.user_name := p_user_name;
            l_record_t.error_status := 'S';
            l_record_t.user_type := x.user_type;
            l_record_t.emp_reg_type := x.emp_reg_type;
            l_record_t.tax_id := x.tax_id;
            l_record_t.confirmed_flag := nvl(x.confirmed_flag, 'N');
            l_record_t.email := x.email;
            l_record_t.acc_num := x.find_key;
            l_record_t.locked_reason := x.locked_reason;
            l_record_t.first_time_pw_flag := x.first_time_pw_flag;
            l_record_t.pw_reminder_qut := x.pw_question;
            l_record_t.pw_reminder_ans := x.pw_answer;
            l_record_t.locked_account := 'N';
            if x.locked_reason is not null then
                if x.failed_att >= 3 then
                    if ( sysdate - to_date ( x.locked_time, 'YYYY-MM-DD HH24:MI:SS' ) ) * 1440 < 30 then
                        l_error_message := 'Your account is temporarily suspended for 30 minutes for invalid login attempts.;;Please try again after the suspended time or contact Customer Service at 800-617-4729 during regular business hours.'
                        ;
                        l_record_t.locked_account := 'Y';
                        raise e_user_exception;
                    elsif ( sysdate - to_date ( x.locked_time, 'YYYY-MM-DD HH24:MI:SS' ) ) * 1440 >= 30 then
                        l_record_t.locked_reason := null;
                    end if;

                end if;
            end if;
     -- all conditions passed , letting the user login

            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'x.user_type ' || x.user_type);
            l_user_id := x.user_id;
            for xx in (
                select
                    otp_verified,
                    verified_phone_type,
                    verified_phone_number,
                    remember_pc,
                    pc_insure.get_eob_status(x.tax_id) eob_status
                from
                    user_security_info
                where
                    user_id = x.user_id
            ) loop
                l_record_t.otp_verified := xx.otp_verified;
                l_record_t.verified_phone_type := xx.verified_phone_type;
                l_record_t.verified_phone_number := xx.verified_phone_number;
                l_record_t.remember_pc := xx.remember_pc;
            end loop;

            pipe row ( l_record_t );
        end loop;

        if l_count = 0 then
            l_error_message := '20008: The username you have entered is not found in our records. Please contact Customer Service at 800-617-4729 during regular business hours or email  customer.service@sterlingadministration.com.'
            ;
            raise e_user_exception;
        end if;
    exception
        when e_user_exception then
            l_record_t.user_name := p_user_name;
            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'l_error_message ' || l_error_message);
            pc_log.log_error('GET_USER_INFO_BY_UNAME', 'redirect_url ' || l_record_t.redirect_url);
            if l_error_message is not null then
                l_record_t.error_message := l_error_message;
                l_record_t.error_status := 'E';
            end if;

            pipe row ( l_record_t );
        when others then
            l_record_t.user_name := p_user_name;
            l_record_t.error_message := sqlerrm;
            pc_log.log_error('GET_USER_INFO_BY_UNAME', ' l_record_t.error_message ' || l_record_t.error_message);
            l_record_t.error_status := 'E';
            pipe row ( l_record_t );
    end get_pwd_recovery;

    procedure verify_pwd_recovery (
        p_user_id       in number,
        p_user_type     in varchar2,
        p_id_info       in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_verify varchar2(1) := 'N';
    begin
        x_error_status := 'S';
        for x in (
            select
                tax_id
            from
                online_users
            where
                    user_id = p_user_id
                and tax_id = p_id_info
        ) loop
            l_verify := 'Y';
        end loop;

        if l_verify = 'Y' then
            x_error_status := 'S';
        else
            x_error_status := 'E';
            x_error_message := 'The information you''ve provided does not match the information on file. This recovery method will be disabled after 3 failed attempts, please check your entry and try again. If you feel you''ve received this message in error, please reach out to our Customer Service team at 800-617-4729 for assistance.'
            ;
        end if;

    end verify_pwd_recovery;

  /*Ticket#6834 */

    function get_broker_to_user_info (
        p_acc_num   in varchar2,
        p_user_id   in varchar2  --- 8837 12/05/2020
        ,
        p_broker_id in number,
        p_is_broker in varchar2
    ) return user_info_t
        pipelined
        deterministic
    is
        l_record_t user_info_row_t;
    begin
        if p_is_broker = 'E' then

 -- Added by Joshi for 9902.
            for x in (
                select
                    a.*
                from
                    online_users a,
                    broker       b
                where
                        upper(a.find_key) = upper(b.broker_lic)
                    and b.broker_id = p_broker_id
                    and a.user_id = p_user_id
            ) loop
     --l_record_t.user_id       := x.user_id;
                l_record_t.user_id := p_user_id;
                l_record_t.user_name := x.user_name;
                l_record_t.error_status := 'S';
                l_record_t.password := x.password;
                l_record_t.user_type := x.user_type;
                l_record_t.emp_reg_type := x.emp_reg_type;
                l_record_t.confirmed_flag := nvl(x.confirmed_flag, 'N');
                l_record_t.email := x.email;
                l_record_t.locked_reason := x.locked_reason;
                l_record_t.first_time_pw_flag := x.first_time_pw_flag;
                l_record_t.logged_in := 'N';
                for y in (
                    select
                        a.acc_id,
                        a.account_type,
                        a.acc_num,
                        l.description,
                        e.entrp_code
                    from
                        account    a,
                        enterprise e,
                        lookups    l
                    where
                            a.acc_num = p_acc_num
                        and a.entrp_id = e.entrp_id
                        and a.account_type = l.lookup_code
                        and l.lookup_name = 'ACCOUNT_TYPE'
                ) loop
                    l_record_t.tax_id := y.entrp_code;
                    l_record_t.acc_num := y.acc_num;   -- Joshi : 9902 x.find_key;
                    l_record_t.no_of_accounts := 1;
                    l_record_t.account_type := y.account_type;
                    l_record_t.acc_type_description := y.description;
                    l_record_t.acc_id := y.acc_id;
                    l_record_t.portfolio_account := 'N';
                    if y.account_type = 'HSA' then
                        l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                    elsif y.account_type = 'HRA' then
                        l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                    elsif y.account_type = 'FSA' then
                        l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                    elsif y.account_type = 'COBRA' then
                        l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                    elsif y.account_type = 'POP' then
                        l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                    elsif y.account_type = 'FORM_5500' then
                        l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                    elsif y.account_type = 'ERISA_WRAP' then
                        l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                    end if;

                end loop;

	--     l_record_t.security_setup := PC_USER_SECURITY_PKG.security_setting_exist(x.user_id);
                for ap in (
                    select
                        ap.allow_broker_enroll,
                        ap.allow_broker_renewal,
                        ap.allow_broker_invoice,
                        ap.allow_broker_enroll_ee,
                        ap.allow_broker_enroll_rpts,
                        ap.allow_broker_ee,
                        ap.allow_bro_upd_pln_doc
                    from
                        account_preference ap
                    where
                        ap.acc_id = l_record_t.acc_id
                ) loop
                    l_record_t.allow_broker_enroll := ap.allow_broker_enroll;
                    l_record_t.allow_broker_renewal := ap.allow_broker_renewal;
                    l_record_t.allow_broker_invoice := ap.allow_broker_invoice;
                    l_record_t.allow_broker_enroll_ee := ap.allow_broker_enroll_ee;
                    l_record_t.allow_broker_enroll_rpts := ap.allow_broker_enroll_rpts;
                    l_record_t.allow_broker_ee := ap.allow_broker_ee;
                    l_record_t.allow_bro_upd_pln_doc := ap.allow_bro_upd_pln_doc;
                end loop;

                if l_record_t.tax_id is not null then
                    for z in (
                        select
                            user_id
                        from
                            online_users
                        where
                                tax_id = l_record_t.tax_id
                            and emp_reg_type = 2
                            and user_type = 'E'
                            and user_status = 'A'   -- Added by Swamy for Ticket#INC31006 22/07/2025
                            and rownum < 2
                    ) loop
                        l_record_t.employer_user_id := z.user_id;
                    end loop;
                end if;

                if l_record_t.allow_login is null then
                    l_record_t.allow_login := 'Y';
                end if;
                l_record_t.pw_reminder_qut := x.pw_question;
                l_record_t.pw_reminder_ans := x.pw_answer;
                l_record_t.locked_account := 'N';
                pipe row ( l_record_t );
            end loop;

        elsif p_is_broker = 'B' then /* Back to Broker Dashboard */
            for x in (
                select
                    a.*
                from
                    online_users a,
                    broker       b
                where
                        upper(a.find_key) = upper(b.broker_lic)
                    and b.broker_id = p_broker_id
                    and a.user_id = p_user_id
            ) ---8837 12/05/2020
             loop
                l_record_t.user_id := x.user_id;
                l_record_t.user_name := x.user_name;
                l_record_t.error_status := 'S';
                l_record_t.password := x.password;
                l_record_t.user_type := x.user_type;
                l_record_t.emp_reg_type := x.emp_reg_type;
                l_record_t.tax_id := x.tax_id;
                l_record_t.confirmed_flag := nvl(x.confirmed_flag, 'N');
                l_record_t.email := x.email;
                l_record_t.acc_num := x.find_key;
                l_record_t.locked_reason := x.locked_reason;
                l_record_t.first_time_pw_flag := x.first_time_pw_flag;
                l_record_t.logged_in := 'N';
                l_record_t.no_of_accounts := 1;
                l_record_t.account_type := '';
       --l_record_t.acc_id := x.acc_id;
                l_record_t.portfolio_account := 'N';
                l_record_t.redirect_url := 'Brokers/Detail/AccountManagement/'; -- 'Brokers/Detail/BrokerDashboard/';
                for xx in (
                    select
                        b.first_name
                        || nvl(b.middle_name || ' ', '')
                        || b.last_name name
                    from
                        broker a,
                        person b
                    where
                            upper(a.broker_lic) = upper(x.find_key)
                        and a.broker_id = b.pers_id
                ) loop
                    l_record_t.display_name := xx.name;
                end loop;

                pipe row ( l_record_t );
            end loop;

    ----------- 9527  04/11/2020
    /*
 ELSIF p_is_broker = 'G' THEN   Back to Broker Dashboard
       FOR X IN (select  a.user_id, a.user_name, a.password, a.user_type, a. emp_reg_type,   b.ga_lic ,a.tax_id ,
                         a.first_time_pw_flag, a.locked_reason, a.find_key ,   a.email, a.confirmed_flag , b.agency_name
                 FROM  ONLINE_USERS a , General_agent  B
				   WHERE  a.find_key = b.ga_Lic
            		AND  b.ga_id = p_broker_id
                    AND a.user_id = p_user_id )
    LOOP
        l_record_t.user_id       := x.user_id;
       l_record_t.user_name      := x.user_name;
       l_record_t.error_status   := 'S';
       l_record_t.password       := x.password;
       l_record_t.user_type      := x.user_type;
       l_record_t.emp_reg_type   := x.emp_reg_type;
        l_record_t.tax_id         := x.tax_id;
       l_record_t.confirmed_flag  := NVL(x.confirmed_flag,'N');
       l_record_t.email    := x.email;
       l_record_t.acc_num    := x.find_key;
       l_record_t.locked_reason := x.locked_reason;
       l_record_t.first_time_pw_flag := x.first_time_pw_flag;
       l_record_t.logged_in   := 'N';
       l_record_t.no_of_accounts := 1;
       l_record_t.account_type := '';
       l_record_t.portfolio_account := 'N';
        l_record_t.redirect_url := 'GA/Detail/AccountManagement/' ; -- confirm on this with PHP team and replace this url 9527  04/11/2020
         l_record_t.display_name := x.agency_name ;
    	PIPE ROW(l_record_t);
	    END LOOP;  */

        end if;/* Broker Employer End If */
    end get_broker_to_user_info;

-- 9132 rprabu added to identify the broker is main or sub broker account
    function is_main_online_broker (
        p_user_id number
    ) return varchar2 is
        l_broker_lic varchar2(100);
        l_user_id    number;
    begin
        for i in (
            select
                find_key
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            l_broker_lic := i.find_key;
        end loop;

        select
            min(user_id)
        into l_user_id
        from
            online_users
        where
            find_key = l_broker_lic;

        if l_user_id = p_user_id then
            return 'Y';
        else
            return 'N';
        end if;
    end is_main_online_broker;

 -- Added by Jaggi #9771
    procedure update_login_info (
        p_user_id   number,
        p_ip_addess in varchar2
    ) is
    begin
        update online_users
        set
            last_login = to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
            last_login_ip = p_ip_addess
        where
            user_id = p_user_id;

    exception
        when others then
            pc_log.log_error('UPDATE_LOGIN_INFO',
                             ' error_message ' || sqlerrm(sqlcode));
    end update_login_info;

-- Added By Jaggi #9731
    function get_user_type (
        p_user_id in number
    ) return varchar2 is
        l_user_type varchar2(1);
    begin
        for x in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            l_user_type := x.user_type;
        end loop;

        return l_user_type;
    end get_user_type;

-- Added by Jaggi for ticket. #9804
    procedure sam_users_pwd_history (
        p_user_id  in number,
        p_password in varchar2
    ) is
    begin
        insert into sam_users_pwd_history (
            user_id,
            password,
            created_by,
            creation_date
        ) values ( p_user_id,
                   p_password,
                   p_user_id,
                   sysdate );

    exception
        when others then
            pc_log.log_error('SAM_USERS_PWD_HISTORY',
                             ' error_message ' || sqlerrm(sqlcode));
    end sam_users_pwd_history;

-- Added by Joshi #9902
    function enroll_new_acct_by_ein (
        p_tax_id in varchar2
    ) return varchar2 is
        l_new_user varchar2(10) := 'N';
        l_count    number := 0;
    begin
        select
            count(*)
        into l_count
        from
            online_users a,
            enterprise   b,
            account      c
        where
                a.tax_id = p_tax_id
            and a.tax_id = b.entrp_code
            and b.entrp_id = c.entrp_id
            and c.account_status = 3
            and a.user_status = 'A';

        if l_count > 0 then
            return 'Y';
        end if;
        l_count := 0;
        select
            count(*)
        into l_count
        from
            lookups
        where
                lookup_name = 'ACCOUNT_TYPE'
            and lookup_code not in ( 'CMP', 'HRA', 'FSA' )
            and lookup_code not in (
                select
                    b.account_type
                from
                    enterprise   e, account      b, online_users ou
                where
                        ou.tax_id = p_tax_id
                    and e.entrp_id = b.entrp_id
                    and e.entrp_code = ou.tax_id
                    and ou.emp_reg_type <> '5'
            );

        if l_count > 0 then
            return 'Y';
        else
            return 'N';
        end if;
    exception
        when too_many_rows then
            l_new_user := 'Y';
            return l_new_user;
        when others then
            return 'N';
    end enroll_new_acct_by_ein;

-- Added by Joshi #9902
    function get_nav_list_v2 (
        p_user_id      in number,
        p_account_type in varchar2,
        p_auth_req_id  in number,
        p_tax_id       in varchar2 default null
    ) return pc_users.roles_t
        pipelined
        deterministic
    is
        l_record pc_users.roles_row_t;
    begin
        pc_log.log_error('pc_users.get_nav_list_v2 begin', 'p_user_id '
                                                           || p_user_id
                                                           || ' p_account_type :='
                                                           || p_account_type
                                                           || 'p_auth_req_id :='
                                                           || p_auth_req_id
                                                           || 'p_tax_id :='
                                                           || p_tax_id);

        for x in (
            select
                tax_id,
                emp_reg_type,
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.user_type = 'E' then
                for er_nav in (
                    select
                        web_nav_url,
                        nav_description,
                        web_nav_code,
                        seq_no
                    from
                        (
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation
                            where
                                    account_type = p_account_type
                                and status = 'A'
                                and portal_type = 'EMPLOYER'
                                and conditional_flag = 'N'
                                and x.emp_reg_type in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation   s,
                                user_role_entries ur
                            where
                                    s.account_type = p_account_type
                                and s.status = 'A'
                                and s.site_nav_id = ur.site_nav_id
                                and ur.user_id = p_user_id
                                and portal_type = 'EMPLOYER'
                                and s.conditional_flag = 'N'
                                and x.emp_reg_type not in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation s
                            where
                                nav_code in ( 'USER_PROFILE', 'MESSAGES' )
                                and portal_type = 'EMPLOYER'
                                and pc_users.enroll_new_acct(p_user_id) = 'Y'
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation s
                            where
                                    nav_code = 'PRODUCTS'
                                and portal_type = 'EMPLOYER'
                                and pc_users.enroll_new_acct(p_user_id) = 'Y'
                                and x.emp_reg_type <> ( '5' )
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                (
                                    select
                                        account_type,
                                        case
                                            when account_type in ( 'HRA', 'FSA' ) then
                                                pc_web_er_renewal.emp_plan_renewal_disp(xx.acc_id)
                                            when account_type = 'COBRA'      then
                                                pc_web_compliance.emp_plan_renewal_disp_cobra(xx.acc_id)
                                            when account_type = 'POP'        then
                                                nvl(
                                                    pc_web_compliance.emp_plan_renewal_disp_pop(xx.acc_id, 'POP'),
                                                    'N'
                                                ) -- 8837
                                            when account_type = 'FORM_5500'  then
                                                pc_web_compliance.emp_plan_renwl_disp_form_5500(xx.acc_id)
                                            when account_type = 'ERISA_WRAP' then
                                                pc_web_compliance.emp_plan_renewal_disp_erisa(xx.acc_id)
                                        end renewed
                                    from
                                        emp_overview_v xx
                                    where
                                            ein = p_tax_id
                                        and account_type = p_account_type
                                        and account_type in ( 'HRA', 'FSA', 'COBRA', 'ERISA_WRAP', 'FORM_5500',
                                                              'POP' )
                                )               renewal,
                                site_navigation s
                            where
                                    renewal.account_type = s.account_type
                                and renewal.renewed = 'Y'
                                and s.portal_type = 'EMPLOYER'
                                and s.nav_code = 'RENEWAL'
                                and s.conditional_flag = 'Y'
                                and x.emp_reg_type <> ( '5' )
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation s
                            where
                                nav_code not in ( 'RENEWAL', 'PRODUCTS', 'PLAN_AMENDMENT' )
                                and portal_type = 'EMPLOYER'
                                and conditional_flag = 'Y'
                                and x.emp_reg_type in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation s
                            where
                                    nav_code = 'EDI_FEEDS'
                                and portal_type = 'EMPLOYER'
                                and x.emp_reg_type in ( '2' ) -- Added by jaggi - role 5'id removed for #9829
                                and pc_account.get_edi_flag(p_tax_id) = 'Y'
             -- added by jaggi #10742
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation s
                            where
                                    account_type = p_account_type
                                and nav_code = 'PLAN_AMENDMENT'
                                and portal_type = 'EMPLOYER'
                                and conditional_flag = 'Y'
                                and x.emp_reg_type in ( '2' )
                                and exists (
                                    select
                                        *
                                    from
                                        pc_employer_enroll_compliance.get_amendment_plans ( p_tax_id )
                                    where
                                        account_type = p_account_type
                                )
                        )
                    order by
                        seq_no asc
                ) loop
                    l_record.nav_code := er_nav.web_nav_code;
                    l_record.redirect_url := er_nav.web_nav_url;
                    l_record.url_description := er_nav.nav_description;
                    pipe row ( l_record );
                end loop;

            elsif
                x.user_type = 'B'
                and p_auth_req_id is not null
            then
                for nav_details in (
                    select
                        web_nav_url,
                        nav_description,
                        web_nav_code
                    from
                        (
                            select
                                s.site_nav_id,
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no,
                                nav_code
                            from
                                site_navigation   s,
                                user_role_entries b
                            where
                                    s.account_type = p_account_type
                                and s.status = 'A'
                                and s.portal_type = 'BROKER_EMPLOYER'
                                and s.conditional_flag = 'N'
                                and s.site_nav_id = b.site_nav_id
                                and b.user_id = p_user_id
                                and b.authorize_req_id = p_auth_req_id
                            union
                            select
                                site_nav_id,
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no,
                                nav_code
                            from
                                site_navigation
                            where
                                web_nav_code in ( 'employer_dashboard', 'eeSearch', 'enroll_npm', 'standard_report', 'disbursementreport'
                                ,
                                                  'plans', 'subsidy_create' ) ---- 'eeSearch',,standard_report, 'enroll_npm' added rprabu 13/01/2023
                                and account_type = p_account_type       ---  'disbursementreport' , 'plans' , 'edi_feeds' added in above statement by rprabu 25/01/2023   subsidy_create added by rprabu on 06/07/2023 for subsidy
                                and portal_type = 'BROKER_EMPLOYER'
                            union -- Added by Joshi for 12705. broker should be allowed to enroll employee only when account is active
                            select
                                site_nav_id,
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no,
                                nav_code
                            from
                                site_navigation
                            where
                                web_nav_code in ( 'employees', 'bulkenrollment', 'employer_reports', 'hsa_invoicing' )
                                and portal_type = 'BROKER_EMPLOYER'
                                and account_type = p_account_type
                                and p_account_type = 'HSA'
                                and pc_users.enable_employer_tab(p_auth_req_id, p_user_id) = 'Y'
                            union
                            select
                                s.site_nav_id,
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no,
                                nav_code
                            from
                                site_navigation   s,
                                user_role_entries b
                            where
                                    s.account_type = p_account_type
                                and s.status = 'A'
                                and s.portal_type = 'BROKER_EMPLOYER'
                                and nav_code = 'PRODUCTS'
                                and pc_users.enroll_new_acct_by_ein(p_tax_id) = 'Y'
                                and s.conditional_flag = 'Y'
                                and s.site_nav_id = b.site_nav_id
                                and b.user_id = p_user_id
                                and b.authorize_req_id = p_auth_req_id
                            union
                            select
                                s.site_nav_id,
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no,
                                nav_code
                            from
                                (
                                    select
                                        account_type,
                                        case
                                            when account_type in ( 'HRA', 'FSA' ) then
                                                pc_web_er_renewal.emp_plan_renewal_disp(xx.acc_id)
                                            when account_type = 'COBRA'      then
                                                pc_web_compliance.emp_plan_renewal_disp_cobra(xx.acc_id)
                                            when account_type = 'POP'        then
                                                pc_web_compliance.emp_plan_renewal_disp_pop(xx.acc_id, 'POP')
                                            when account_type = 'FORM_5500'  then
                                                pc_web_compliance.emp_plan_renwl_disp_form_5500(xx.acc_id)
                                            when account_type = 'ERISA_WRAP' then
                                                pc_web_compliance.emp_plan_renewal_disp_erisa(xx.acc_id)
                                        end renewed
                                    from
                                        emp_overview_v xx
                                    where
                                            ein = p_tax_id
                                        and account_type = p_account_type
                                        and account_type in ( 'HRA', 'FSA', 'COBRA', 'ERISA_WRAP', 'FORM_5500',
                                                              'POP' )
                                )                 renewal,
                                site_navigation   s,
                                user_role_entries b
                            where
                                    renewal.account_type = s.account_type
                                and renewal.renewed = 'Y'
                                and s.portal_type = 'BROKER_EMPLOYER'
                                and s.nav_code = 'renewal'
                                and s.conditional_flag = 'Y'
                                and s.site_nav_id = b.site_nav_id
                                and b.user_id = p_user_id
                                and b.authorize_req_id = p_auth_req_id
                            order by
                                seq_no asc
                        )
                ) loop
                    l_record.nav_code := nav_details.web_nav_code;
                    l_record.redirect_url := nav_details.web_nav_url;
                    l_record.url_description := nav_details.nav_description;
                    pipe row ( l_record );
                end loop;
            elsif
                x.user_type in ( 'G', 'B' )
                and p_auth_req_id is null
            then -- 8890 rprabu 17/06/2020

                l_record.nav_code := null;
                l_record.redirect_url := null;
                l_record.url_description := null;
                for broker_nav in (
                    select
                        web_nav_url,
                        nav_description,
                        web_nav_code,
                        seq_no
                    from
                        (
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation
                            where
                                    status = 'A'
                                and portal_type = decode(x.user_type, 'B', 'BROKER', 'G', 'GA')
                                and x.emp_reg_type in ( '5', '2' )
                            union
                            select
                                web_nav_url,
                                nav_description,
                                web_nav_code,
                                seq_no
                            from
                                site_navigation   s,
                                user_role_entries ur
                            where
                                    s.status = 'A'
                                and s.site_nav_id = ur.site_nav_id
                                and ur.user_id = p_user_id
                                and portal_type = decode(x.user_type, 'B', 'BROKER', 'G', 'GA')
                                and x.emp_reg_type not in ( '5', '2' )
                        )
                    order by
                        seq_no asc
                ) loop
                    l_record.nav_code := broker_nav.web_nav_code;
                    l_record.redirect_url := broker_nav.web_nav_url;
                    l_record.url_description := broker_nav.nav_description;
                    pipe row ( l_record );
                end loop;

            end if;
        end loop;

    end get_nav_list_v2;

-- Added by Jaggi #11368
    function get_ga_to_user_info (
        p_acc_num in varchar2,
        p_user_id in varchar2,
        p_ga_id   in number
    ) return user_info_t
        pipelined
        deterministic
    is
        l_record_t user_info_row_t;
    begin
        pc_log.log_error('Get_ga_To_User_Info', 'P_GA_Id :='
                                                || p_ga_id
                                                || 'p_user_id :='
                                                || p_user_id);

 -- Added by Joshi for 9902.
        for x in (
            select
                a.*
            from
                online_users  a,
                general_agent g
            where
                    upper(a.find_key) = upper(g.ga_lic)
                and g.ga_id = p_ga_id
                and a.user_id = p_user_id
        ) loop
            l_record_t.user_id := p_user_id;
            l_record_t.user_name := x.user_name;
            l_record_t.error_status := 'S';
            l_record_t.password := x.password;
            l_record_t.user_type := x.user_type;
            l_record_t.emp_reg_type := x.emp_reg_type;
            l_record_t.confirmed_flag := nvl(x.confirmed_flag, 'N');
            l_record_t.email := x.email;
            l_record_t.locked_reason := x.locked_reason;
            l_record_t.first_time_pw_flag := x.first_time_pw_flag;
            l_record_t.logged_in := 'N';
            for y in (
                select
                    a.acc_id,
                    a.account_type,
                    a.acc_num,
                    l.description,
                    e.entrp_code
                from
                    account    a,
                    enterprise e,
                    lookups    l
                where
                        a.acc_num = p_acc_num
                    and a.entrp_id = e.entrp_id
                    and a.account_type = l.lookup_code
                    and l.lookup_name = 'ACCOUNT_TYPE'
            ) loop
                l_record_t.tax_id := y.entrp_code;
                l_record_t.acc_num := y.acc_num;
                l_record_t.no_of_accounts := 1;
                l_record_t.account_type := y.account_type;
                l_record_t.acc_type_description := y.description;
                l_record_t.acc_id := y.acc_id;
                l_record_t.portfolio_account := 'N';
                if y.account_type = 'HSA' then
                    l_record_t.redirect_url := 'Employers/Detail/EmployerDashboard/';
                elsif y.account_type = 'HRA' then
                    l_record_t.redirect_url := 'HRA/Employers/EmployerDashboard/';
                elsif y.account_type = 'FSA' then
                    l_record_t.redirect_url := 'FSA/Employers/EmployerDashboard/';
                elsif y.account_type = 'COBRA' then
                    l_record_t.redirect_url := 'COBRA/Employers/EmployerDashboard/';
                elsif y.account_type = 'POP' then
                    l_record_t.redirect_url := 'POP/Employers/EmployerDashboard/';
                elsif y.account_type = 'FORM_5500' then
                    l_record_t.redirect_url := 'Form5500/Employers/EmployerDashboard/';
                elsif y.account_type = 'ERISA_WRAP' then
                    l_record_t.redirect_url := 'ERISA/Employers/EmployerDashboard/';
                end if;

            end loop;

            for ap in (
                select
                    ap.allow_broker_enroll,
                    ap.allow_broker_renewal,
                    ap.allow_broker_invoice,
                    ap.allow_broker_enroll_ee,
                    ap.allow_broker_enroll_rpts,
                    ap.allow_broker_ee,
                    ap.allow_bro_upd_pln_doc
                from
                    account_preference ap
                where
                    ap.acc_id = l_record_t.acc_id
            ) loop
                l_record_t.allow_broker_enroll := ap.allow_broker_enroll;
                l_record_t.allow_broker_renewal := ap.allow_broker_renewal;
                l_record_t.allow_broker_invoice := ap.allow_broker_invoice;
                l_record_t.allow_broker_enroll_ee := ap.allow_broker_enroll_ee;
                l_record_t.allow_broker_enroll_rpts := ap.allow_broker_enroll_rpts;
                l_record_t.allow_broker_ee := ap.allow_broker_ee;
                l_record_t.allow_bro_upd_pln_doc := ap.allow_bro_upd_pln_doc;
            end loop;

            if l_record_t.tax_id is not null then
                for z in (
                    select
                        user_id
                    from
                        online_users
                    where
                            tax_id = l_record_t.tax_id
                        and emp_reg_type = 2
                        and user_type = 'E'
                        and rownum < 2
                ) loop
                    l_record_t.employer_user_id := z.user_id;
                end loop;
            end if;

            if l_record_t.allow_login is null then
                l_record_t.allow_login := 'Y';
            end if;
            l_record_t.pw_reminder_qut := x.pw_question;
            l_record_t.pw_reminder_ans := x.pw_answer;
            l_record_t.locked_account := 'N';
            pipe row ( l_record_t );
        end loop;

    end get_ga_to_user_info;

-- Added by Joshi for 12705
    function enable_employer_tab (
        p_auth_req_id in number,
        p_user_id     in number
    ) return varchar2 is
        l_count number := 0;
    begin
        for x in (
            select
                count(*) cnt
            from
                account                  a,
                er_portal_authorizations er
            where
                    a.acc_id = er.acc_id
                and er.authorize_req_id = p_auth_req_id
                and a.account_status = 1
                and er.user_id = p_user_id
        ) loop
            l_count := x.cnt;
        end loop;

        if l_count > 0 then
            return 'Y';
        else
            return 'N';
        end if;
    end enable_employer_tab;

end pc_users;
/


-- sqlcl_snapshot {"hash":"0fbf1826b77f571aa726d59def67577e8027e312","type":"PACKAGE_BODY","name":"PC_USERS","schemaName":"SAMQA","sxml":""}