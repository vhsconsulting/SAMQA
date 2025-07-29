create or replace package body samqa.pc_contact as

    procedure create_contact (
        p_first_name    in varchar2,
        p_last_name     in varchar2,
        p_middle_name   in varchar2,
        p_title         in varchar2,
        p_gender        in varchar2,
        p_entity_id     in varchar2,
        p_phone         in varchar2,
        p_fax           in varchar2,
        p_email         in varchar2,
        p_user_id       in number,
        x_contact_id    out number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_tax_id      varchar2(100);
        l_user_id     number(10);
        l_contact_id  number;
        l_entity_type varchar2(200);    --- rprabu 06/05/2020 #ticket 8837
        l_note        varchar2(1000); 		   --- rprabu 06/05/2020 #ticket 8837
    begin
        x_return_status := 'S';
      --- rprabu 06/05/2020 #ticket 8837
        for x in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.user_type = 'E' then
                l_entity_type := 'ENTERPRISE';
                l_note := 'Created from Super Admin';
            elsif x.user_type = 'B' then
                l_entity_type := 'BROKER';
                l_note := 'Created from  Broker ';
            elsif x.user_type = 'G' then
                l_entity_type := 'GA';  -----------9527 04/11/2020
                l_note := 'Created from  General Agent ';
            end if;
        end loop;
       --- End  rprabu 06/05/2020 #ticket 8837


         -----04/02/2021 rprabu CP Project
        if l_entity_type is null then
            l_entity_type := 'ENTERPRISE';
            l_note := ' Created from COBRA SAM';
        end if;
        pc_log.log_error('create_contact', 'b4 CONTACT insertion ');
        insert into contact (
            contact_id,
            entity_id,
            entity_type,
            first_name,
            last_name,
            middle_name,
            title,
            gender,
            phone,
            email,
            fax,
            start_date,
            status,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( contact_seq.nextval,
                   p_entity_id,
                   l_entity_type,
                   p_first_name,
                   p_last_name,
                   p_middle_name,
                   p_title,
                   p_gender,
                   p_phone,
                   p_email,
                   p_fax,
                   sysdate,
                   'A',
                   l_note,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id ) returning contact_id into x_contact_id;

        pc_log.log_error('create_contact', 'inserted  CONTACT  records ');
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end create_contact;

    procedure delete_user_contact (
        p_contact_user_id in number,
        p_contact_id      in number,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_note varchar(20);  --- 8837 rprabu
    begin
        x_return_status := 'S';

   --- rprabu 06/05/2020 #ticket 8837
        for x in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.user_type = 'E' then
                l_note := 'Removed by Employer ';
            elsif x.user_type = 'B' then
                l_note := 'Removed by Broker ';
            end if;
        end loop;
       --- End  rprabu 06/05/2020 #ticket 8837
        update contact
        set
            end_date = sysdate,
            status = 'D',
            note = 'Removed by employer ',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            contact_id = p_contact_id;

        if p_contact_user_id is not null then --rprabu 09/08/2021  CP Project
            update online_users
            set
                user_status = 'D',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                user_id = p_contact_user_id;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end delete_user_contact;

    procedure inactivate_user_contact (
        p_contact_user_id in number,
        p_contact_id      in number,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_note varchar(20);  --- 8837 rprabu
    begin
        x_return_status := 'S';
		 --- rprabu 06/05/2020 #ticket 8837
        for x in (
            select
                user_type
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.user_type = 'E' then
                l_note := 'Inactivated by Employer ';
            elsif x.user_type = 'B' then
                l_note := 'Inactivated by Broker ';
            elsif x.user_type = 'G' then  ----9527 04/2020
                l_note := 'Inactivated by General Agent  ';
            end if;
        end loop;
       --- End  rprabu 06/05/2020 #ticket 8837
        update contact
        set
            end_date = sysdate,
            status = 'I',
            note = 'Inactivated by employer ',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            contact_id = p_contact_id;

        update online_users
        set
            user_status = 'I',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            user_id = p_contact_user_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end inactivate_user_contact;

    procedure update_user_contact (
        p_contact_id      in number,
        p_first_name      in varchar2,
        p_last_name       in varchar2,
        p_middle_name     in varchar2,
        p_title           in varchar2,
        p_entity_id       in varchar2,
        p_ein             in varchar2,
        p_phone           in varchar2,
        p_fax             in varchar2,
        p_email           in varchar2,
        p_role_id         in varchar2,
        p_role_entries    in pc_online_enrollment.varchar2_tbl,
        p_contact_user_id in varchar2,
        p_user_id         in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
    begin
        pc_log.log_error('update_user_contact', 'in update');
        x_return_status := 'S';
        update contact
        set
            first_name = nvl(p_first_name, first_name),
            last_name = nvl(p_last_name, last_name),
            middle_name = nvl(p_middle_name, middle_name),
            title = nvl(p_title, title),
            phone = nvl(p_phone, phone),
            fax = nvl(p_fax, fax),
            email = nvl(p_email, email),
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            contact_id = p_contact_id;

        if p_contact_user_id is null then      ----rprabu 06/08/2021 CP project
            update contact_role
            set
                role_type = p_role_entries(1)
            where
                contact_id = p_contact_id;

            update contact
            set
                contact_type = p_role_entries(1)
            where
                contact_id = p_contact_id;

        elsif p_contact_user_id is not null then      ----rprabu 06/08/2021 CP project

            update online_users
            set
                email = nvl(p_email, email),
                emp_reg_type = nvl(p_role_id, emp_reg_type),
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                user_id = p_contact_user_id;

    --IF p_role_id = 4 AND p_role_entries.COUNT > 0 THEN
            if
                p_role_id in ( 4, 5 )
                and p_role_entries.count > 0
            then  -- Added by jaggi - role 5'id for #9829
       -- commented and added by Joshi 9902.
       --pc_users.create_role_entries (p_contact_user_id,p_role_entries,p_user_id,p_role_id,x_return_status,x_error_message);
                pc_users.create_role_entries(p_contact_user_id, p_role_entries, p_user_id, p_role_id, null,
                                             x_return_status, x_error_message);

            end if;

        end if; ----rprabu 06/08/2021 CP project
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_user_contact;

    procedure create_user_contact (
        p_first_name         in varchar2,
        p_last_name          in varchar2,
        p_middle_name        in varchar2,
        p_title              in varchar2,
        p_gender             in varchar2,
        p_entity_id          in varchar2,
        p_ein                in varchar2,
        p_phone              in varchar2,
        p_fax                in varchar2,
        p_email              in varchar2,
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_id            in number,
        p_role_id            in number,
        p_first_time_pw_flag in varchar2 default 'N',
        p_role_entries       in pc_online_enrollment.varchar2_tbl,
        x_contact_id         out number,
        x_user_id            out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        user_error exception;
        l_find_key         varchar2(3000);
        l_ein              varchar2(3000);
        l_enroll_acc_count number := 0;
        l_count            number := 0;
    begin
        x_return_status := 'S';
        pc_log.log_error('create_user_contact', p_first_name);
        pc_log.log_error('create_user_contact', 'role id ' || p_role_id);
        pc_log.log_error('role_entries', 'count of role entries' || p_role_entries.count);
        pc_log.log_error('create_user_contact', 'p_email: ' || p_email);
        if p_role_id = 1 then
            select
                count(*)
            into l_enroll_acc_count
            from
                online_users
            where
                    tax_id = p_entity_id
                and emp_reg_type = 1
                and nvl(user_status, 'A') = 'A';

            if l_enroll_acc_count > 0 then
                x_error_message := 'Enrollment Account already exist, More than one enrollment account cannot be created';
                x_return_status := 'E';
            end if;
        end if;

        for x in (
            select
                find_key,
                tax_id
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            l_find_key := x.find_key;
            l_ein := x.tax_id;
        end loop;

        select
            count(*)
        into l_count
        from
            contact
        where
                lower(email) = lower(p_email)
            and entity_type = 'ENTERPRISE'
            and entity_id = l_ein;

 ----rprabu 06/08/2021 CP project  
        if
            p_user_name is null
            and l_count > 0
        then
            x_error_message := 'Email id already exists for Employer ';
            x_return_status := 'E';
        end if;

        if l_count = 0 then
            create_contact(
                p_first_name    => p_first_name,
                p_last_name     => p_last_name,
                p_middle_name   => p_middle_name,
                p_title         => p_title,
                p_gender        => p_gender
                     --,p_entity_id    => p_entity_id
                ,
                p_entity_id     => p_ein /*Ticket#6792 */,
                p_phone         => p_phone,
                p_fax           => p_fax,
                p_email         => p_email,
                p_user_id       => p_user_id,
                x_contact_id    => x_contact_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            pc_log.log_error('create_user_contact', 'x_contact_id' || x_contact_id);
            pc_log.log_error('create_user_contact', 'x_return_status' || x_return_status);
            pc_log.log_error('create_user_contact', 'x_error_message' || x_error_message);
        end if;

        if x_return_status <> 'S' then
            raise user_error;
        end if;
        if p_user_name is not null then   ----rprabu 06/08/2021 CP project  

            pc_users.insert_users(
                p_user_name      => p_user_name,
                p_password       => p_password,
                p_user_type      => 'E',
                p_emp_reg_type   => to_char(p_role_id),
                p_find_key       => l_find_key,
                p_locked_time    => null,
                p_succ_access    => null,
                p_last_login     => null,
                p_failed_att     => 0,
                p_failed_ip      => null,
                p_create_pw      => to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
                p_change_pw      => null,
                p_email          => p_email,
                p_pw_question    => null,
                p_pw_answer      => null,
                p_confirmed_flag => 'N',
                p_tax_id         => nvl(p_ein,
                                replace(l_ein, '-')),
                x_user_id        => x_user_id,
                x_return_status  => x_return_status,
                x_error_message  => x_error_message,
                p_user_id        => p_user_id
            );

            pc_log.log_error('create_user_contact', 'x_user_id' || x_user_id);
            pc_log.log_error('create_user_contact', 'x_return_status' || x_return_status);
            pc_log.log_error('create_user_contact', 'x_error_message' || x_error_message);
            if x_return_status <> 'S' then
                raise user_error;
            end if;
            update online_users
            set
                first_time_pw_flag = p_first_time_pw_flag,
                last_update_date = sysdate
            where
                user_id = x_user_id;

    /*Upadte the user ID's in contact table.Ticket#6792 */
            update contact
            set
                user_id = x_user_id
            where
                contact_id = x_contact_id;

            if l_count > 0 then
  --    FOR X IN ( SELECT contact_id FROM contact WHERE lower(email) = p_email
  -- commented above and added below by Joshi for #12561
                for x in (
                    select
                        contact_id
                    from
                        contact
                    where
                            lower(email) = lower(p_email)
                        and entity_type = 'ENTERPRISE'
                        and entity_id = l_ein
                        and rownum = 1
                ) loop
                    pc_log.log_error('create_user_contact', 'contact_id: ' || x.contact_id);
                    insert into contact_user_map (
                        contact_user_id,
                        contact_id,
                        user_id,
                        created_by,
                        last_updated_by
                    ) values ( contact_user_map_seq.nextval,
                               x.contact_id,
                               x_user_id,
                               p_user_id,
                               p_user_id );

                    insert into contact_role (
                        contact_role_id,
                        contact_id,
                        role_type,
                        description,
                        effective_date,
                        created_by,
                        last_updated_by
                    ) values ( contact_role_seq.nextval,
                               x.contact_id,
                               case
                                   when p_role_id = 1 then
                                       'ENROLLMENT_EXPRESS'
                                   when p_role_id = 2 then
                                       'SUPER_ADMINISTRATOR'
                                   when p_role_id = 4 then
                                       'CUSTOM_PERMISSION'
                               end,
                               'Online User Permission',
                               sysdate,
                               p_user_id,
                               p_user_id );

                end loop;
            else
                insert into contact_user_map (
                    contact_user_id,
                    contact_id,
                    user_id,
                    created_by,
                    last_updated_by
                ) values ( contact_user_map_seq.nextval,
                           x_contact_id,
                           x_user_id,
                           p_user_id,
                           p_user_id );

                insert into contact_role (
                    contact_role_id,
                    contact_id,
                    role_type,
                    description,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           x_contact_id,
                           case
                               when p_role_id = 1 then
                                   'ENROLLMENT_EXPRESS'
                               when p_role_id = 2 then
                                   'SUPER_ADMINISTRATOR'
                               when p_role_id = 4 then
                                   'CUSTOM_PERMISSION'
                           end,
                           'Online User Permission',
                           sysdate,
                           p_user_id,
                           p_user_id );

            end if;

            if p_role_id in ( 4, 5 ) then -- Added by jaggi - role 5'id for #9829 
            -- commented and added by Joshi 9902.
            --  pc_users.create_role_entries (x_user_id,p_role_entries,p_user_id,p_role_id,x_return_status,x_error_message);
                pc_users.create_role_entries(x_user_id, p_role_entries, p_user_id, p_role_id, null,
                                             x_return_status, x_error_message);
            end if;

        end if;    ----rprabu 06/08/2021 CP project  
    exception
        when user_error then
            null;
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('create_user_contact', 'x_error_message: ' || x_error_message);
    end create_user_contact;

        ----8837 rprabu 07/05/2020
    procedure create_broker_user_contact (
        p_first_name         in varchar2,
        p_last_name          in varchar2,
        p_middle_name        in varchar2,
        p_title              in varchar2,
        p_gender             in varchar2,
        p_ein                in varchar2,
        p_phone              in varchar2,
        p_fax                in varchar2,
        p_email              in varchar2,
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_id            in number,
        p_role_id            in number,
        p_first_time_pw_flag in varchar2 default 'N',
        p_role_entries       in pc_online_enrollment.varchar2_tbl,
        x_contact_id         out number,
        x_user_id            out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        user_error exception;
        l_find_key         varchar2(3000);
        l_ein              varchar2(3000);
        l_enroll_acc_count number := 0;
        l_count            number := 0;
    begin
        x_return_status := 'S';
        pc_log.log_error('create_Broker_user_contact', p_first_name);
        pc_log.log_error('create_Broker_user_contact', 'role id ' || p_role_id);
        pc_log.log_error('role_entries', 'count of role entries' || p_role_entries.count);
           ----   pc_log.log_error('p_entity_id','Entity_id'||p_entity_id);

        for x in (
            select
                find_key,
                tax_id
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            l_find_key := x.find_key;
            l_ein := x.tax_id;
        end loop;

        select
            count(*)
        into l_count
        from
            contact
        where
                lower(email) = lower(p_email)
            and entity_type = 'BROKER'
            and entity_id = l_ein;

        if l_count = 0 then
            create_contact(
                p_first_name    => p_first_name,
                p_last_name     => p_last_name,
                p_middle_name   => p_middle_name,
                p_title         => p_title,
                p_gender        => p_gender,
                p_entity_id     => p_ein,
                p_phone         => p_phone,
                p_fax           => p_fax,
                p_email         => p_email,
                p_user_id       => p_user_id,
                x_contact_id    => x_contact_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            pc_log.log_error('create_Broker_user_contact', 'x_contact_id' || x_contact_id);
            pc_log.log_error('create_Broker_user_contact', 'x_return_status' || x_return_status);
            pc_log.log_error('create_Broker_user_contact', 'x_error_message' || x_error_message);
        end if;

        if x_return_status <> 'S' then
            raise user_error;
        end if;
        pc_users.insert_users(
            p_user_name      => p_user_name,
            p_password       => p_password,
            p_user_type      => 'B',
            p_emp_reg_type   => to_char(p_role_id),
            p_find_key       => l_ein            ---- find key broker
            ,
            p_locked_time    => null,
            p_succ_access    => null,
            p_last_login     => null,
            p_failed_att     => 0,
            p_failed_ip      => null,
            p_create_pw      => to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
            p_change_pw      => null,
            p_email          => p_email,
            p_pw_question    => null,
            p_pw_answer      => null,
            p_confirmed_flag => 'N',
            p_tax_id         => nvl(p_ein,
                            replace(l_ein, '-')),
            x_user_id        => x_user_id,
            x_return_status  => x_return_status,
            x_error_message  => x_error_message,
            p_user_id        => p_user_id
        );

        pc_log.log_error('create_Broker_user_contact', 'x_user_id' || x_user_id);
        pc_log.log_error('create_Broker_user_contact', 'x_return_status' || x_return_status);
        pc_log.log_error('create_Broker_user_contact', 'x_error_message' || x_error_message);
        if x_return_status <> 'S' then
            raise user_error;
        end if;
        update online_users
        set
            first_time_pw_flag = p_first_time_pw_flag,
            last_update_date = sysdate
        where
            user_id = x_user_id;

-----   9132 rprabu 29/05/2020
        update user_security_info
        set
            verified_phone_number = p_phone
     ---        VERIFIED_EMAIL   =   p_email
        where
            user_id = x_user_id;

    /*Upadte the user ID's in contact table.Ticket#6792 */
        update contact
        set
            user_id = x_user_id
        where
            contact_id = x_contact_id;

        if l_count > 0 then
            for x in (
                select
                    contact_id
                from
                    contact
                where
                        lower(email) = p_email
                    and entity_type = 'BROKER'
                    and entity_id = l_ein
                    and rownum = 1
            ) loop
                insert into contact_user_map (
                    contact_user_id,
                    contact_id,
                    user_id,
                    created_by,
                    last_updated_by
                ) values ( contact_user_map_seq.nextval,
                           x.contact_id,
                           x_user_id,
                           p_user_id,
                           p_user_id );

                insert into contact_role (
                    contact_role_id,
                    contact_id,
                    role_type,
                    description,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           x.contact_id,
                           case     ----- WHEN p_role_id = 1 THEN 'ENROLLMENT_EXPRESS'
                               when p_role_id = 2 then
                                   'SUPER_ADMINISTRATOR'
                               when p_role_id = 4 then
                                   'CUSTOM_PERMISSION'
                           end,
                           'Online User Permission',
                           sysdate,
                           p_user_id,
                           p_user_id );

            end loop;
        else
            insert into contact_user_map (
                contact_user_id,
                contact_id,
                user_id,
                created_by,
                last_updated_by
            ) values ( contact_user_map_seq.nextval,
                       x_contact_id,
                       x_user_id,
                       p_user_id,
                       p_user_id );

            insert into contact_role (
                contact_role_id,
                contact_id,
                role_type,
                description,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       x_contact_id,
                       case --- WHEN p_role_id = 1 THEN 'ENROLLMENT_EXPRESS'
                           when p_role_id = 2 then
                               'SUPER_ADMINISTRATOR'
                           when p_role_id = 4 then
                               'CUSTOM_PERMISSION'
                       end,
                       'Online User Permission',
                       sysdate,
                       p_user_id,
                       p_user_id );

        end if;

        if p_role_id = 4 then
       -- commented and added by Joshi 9902.
       -- pc_users.create_role_entries (x_user_id,p_role_entries,p_user_id,p_role_id,x_return_status,x_error_message);
            pc_users.create_role_entries(x_user_id, p_role_entries, p_user_id, p_role_id, null,
                                         x_return_status, x_error_message);
        end if;

    exception
        when user_error then
            null;
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end create_broker_user_contact;

    function get_user_contact_info (
        p_tax_id in varchar2
    ) return contact_info_t
        pipelined
        deterministic
    is
        l_record_t contact_info_row_t;
    begin
        for x in (
            select
                c.first_name,
                c.last_name,
                c.middle_name,
                c.title,
                to_char(c.start_date, 'MM/DD/YYYY')                     effective_date,
                pc_lookups.get_meaning(ou.emp_reg_type, 'EMP_REG_TYPE') role_permission,
                ou.emp_reg_type,
                c.contact_id,
                ou.user_id,
                ou.user_type,
                ou.email,
                c.fax,
                c.phone,
                c.entity_type,
                c.entity_id,
                ou.user_name,
                decode(ou.user_status, 'A', 'Active', 'I', 'Inactive')  status
            from
                contact          c,
                online_users     ou,
                contact_user_map d
            where
                    d.user_id (+) = ou.user_id
                and d.contact_id = c.contact_id (+)
                and upper(ou.tax_id) = upper(p_tax_id)
                and ou.user_status <> 'D'
        /* ou.user_id  = c.user_id
       AND   d.CONTACT_ID = c.CONTACT_ID(+) -- commented and added by Joshi below for 9527
            d.user_id(+) = ou.user_id
         and  d.contact_id= c.contact_id(+)
	     AND    ou.tax_id = p_tax_id*/
     --  AND    ou.emp_reg_type <> '1'

    /*   union
       SELECT c.first_name
		     , c.last_name
		     , c.middle_name
		     , c.title
		     , TO_CHAR(c.start_date,'MM/DD/YYYY') effective_date
		     , PC_LOOKUPS.GET_meaning(ou.emp_reg_type,'EMP_REG_TYPE') role_permission
		     , c.contact_id
		     , ouc.user_id
		     , c.email
		     , c.fax
		     , c.phone
		     , c.entity_type
		     , c.entity_id
	     FROM   contact c, online_users ou,online_users ouc
	     WHERE  ouc.user_id = c.user_id
       AND    ouc.find_key = ou.find_key
	     AND    ou.tax_id = p_tax_id*/
        ) loop
            l_record_t.first_name := x.first_name;
            l_record_t.last_name := x.last_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.title := x.title;
            l_record_t.effective_date := x.effective_date;
            l_record_t.role_permission := x.role_permission;
            l_record_t.contact_id := x.contact_id;
            l_record_t.user_id := x.user_id;
            l_record_t.user_type := x.user_type;
            l_record_t.email := x.email;
            l_record_t.fax := x.fax;
            l_record_t.phone := x.phone;
            l_record_t.entity_type := x.entity_type;
            l_record_t.entity_id := x.entity_id;
            l_record_t.user_name := x.user_name;
            l_record_t.status := x.status;
            l_record_t.role_id := x.emp_reg_type;
             ---- 8837 rprabu 15/05/2020
            if
                x.first_name is null
                and x.last_name is null
            then
                for z in (
                    select
                        c.first_name,
                        c.last_name,
                        c.middle_name,
                        b.creation_date
                    from
                        broker       a,
                        online_users b,
                        person       c
                    where
                            a.broker_lic = b.tax_id
                        and b.tax_id = p_tax_id
                        and a.broker_id = c.pers_id
                ) loop
                    l_record_t.first_name := z.first_name;
                    l_record_t.last_name := z.last_name;
                    l_record_t.middle_name := z.middle_name;
                    l_record_t.effective_date := to_char(z.creation_date, 'mm/dd/yyyy');
                end loop;
            end if;

            pipe row ( l_record_t );
        end loop;
    end get_user_contact_info;

    function get_user_contact_profile (
        p_user_id in varchar2
    ) return contact_info_t
        pipelined
        deterministic
    is
        l_record_t contact_info_row_t;
    begin
        for x in (
            select
                c.first_name,
                c.last_name,
                c.middle_name,
                c.title,
                to_char(c.start_date, 'MM/DD/YYYY')                     effective_date,
                pc_lookups.get_meaning(ou.emp_reg_type, 'EMP_REG_TYPE') role_permission,
                ou.emp_reg_type,
                c.contact_id,
                ou.user_id,
                c.email,
                c.fax,
                c.phone,
                c.entity_type,
                c.entity_id,
                ou.user_name,
                decode(ou.user_status, 'A', 'Active', 'I', 'Inactive')  status,
                case
                    when ou.password is null
                         and ou.first_time_pw_flag = 'Y' then
                        'N'
                    else
                        'Y'
                end                                                     pw_setup
            from
                contact          c,
                online_users     ou,
                contact_user_map d
            where
                    ou.user_id = d.user_id
                and ou.user_id = p_user_id
                and d.contact_id = c.contact_id
                and ou.emp_reg_type <> '1'
                and ou.user_status <> 'D'
    /*   union
       SELECT c.first_name
		     , c.last_name
		     , c.middle_name
		     , c.title
		     , TO_CHAR(c.start_date,'MM/DD/YYYY') effective_date
		     , PC_LOOKUPS.GET_meaning(ou.emp_reg_type,'EMP_REG_TYPE') role_permission
		     , c.contact_id
		     , ouc.user_id
		     , c.email
		     , c.fax
		     , c.phone
		     , c.entity_type
		     , c.entity_id
	     FROM   contact c, online_users ou,online_users ouc
	     WHERE  ouc.user_id = c.user_id
       AND    ouc.find_key = ou.find_key
	     AND    ou.tax_id = p_tax_id*/
        ) loop
            l_record_t.first_name := x.first_name;
            l_record_t.last_name := x.last_name;
            l_record_t.middle_name := x.middle_name;
            l_record_t.title := x.title;
            l_record_t.effective_date := x.effective_date;
            l_record_t.role_permission := x.role_permission;
            l_record_t.contact_id := x.contact_id;
            l_record_t.user_id := x.user_id;
            l_record_t.email := x.email;
            l_record_t.fax := x.fax;
            l_record_t.phone := x.phone;
            l_record_t.entity_type := x.entity_type;
            l_record_t.entity_id := x.entity_id;
            l_record_t.user_name := x.user_name;
            l_record_t.status := x.status;
            l_record_t.role_id := x.emp_reg_type;
            l_record_t.pw_setup := x.pw_setup;
            pipe row ( l_record_t );
        end loop;
    end get_user_contact_profile;

    function get_contact_id_for_cobra (
        p_cobra_number in number
    ) return number is
        l_contact_id number;
    begin
        for x in (
            select
                contact_id
            from
                contact_role
            where
                cobra_id_number = p_cobra_number
        ) loop
            l_contact_id := x.contact_id;
        end loop;

        return l_contact_id;
    exception
        when others then
            null;
    end get_contact_id_for_cobra;

    function get_contact_roles (
        p_contact_id in number
    ) return varchar2 is
        l_contact_role varchar2(4000);
    begin
        for x in (
            select --WM_CONCAT( pc_lookups.get_meaning(ROLE_TYPE,'CONTACT_TYPE')) ROLE_TYPE
                listagg(pc_lookups.get_meaning(role_type, 'CONTACT_TYPE'),
                        ',') within group(
                order by
                    role_type
                ) role_type
           -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
            from
                contact_role
            where
                    contact_role.contact_id = p_contact_id
                and effective_end_date is null
        ) loop
            l_contact_role := x.role_type;
        end loop;

        return l_contact_role;
    end get_contact_roles;

    function get_notify_emails (
        p_ein          in varchar2,
        p_notify_type  in varchar2,
        p_product_type in varchar2,
        p_inv_id       in number default null
    ) return contact_info_t
        pipelined
        deterministic
    is
        l_record_t   contact_info_row_t;
        l_charged_to varchar2(50);
    begin
       /* commente the code by Joshi for 11266
       IF p_inv_id IS NOT NULL THEN
             FOR XX IN ( SELECT email
			             FROM CONTACT a , ar_invoice_contacts b
                   WHERE B.invoice_id = p_inv_id
                    AND  a.contact_id = b.contact_id
                    AND nvl(a.status,'A') = 'A' and a.end_date is null
                    AND  A.CAN_CONTACT = 'Y' )
	       LOOP
	          IF  l_record_t.email IS NULL THEN
                    l_record_t.email := xx.email;

            ELSE
                    l_record_t.email := l_record_t.email||','||xx.email;

            END IF;
	       END LOOP;
       END IF;
       */
        if p_inv_id is not null then
            l_charged_to := pc_invoice.get_charged_to(p_inv_id);
            pc_log.log_error('get_notify_emails l_charged_to : ', l_charged_to);

           -- Added by Joshi for 11686
            if p_notify_type in ( 'FEE', 'FEE_BILLING' ) then
                if l_charged_to = 'BROKER' then
                    for x in (
                        select
                            email
                        from
                            contact      a,
                            contact_role b
                        where
                                replace(
                                    strip_bad(a.entity_id),
                                    '-'
                                ) = replace(
                                    strip_bad(p_ein),
                                    '-'
                                )
                            and nvl(a.status, 'A') = 'A'
                            and a.end_date is null
                            and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                            and a.contact_id = b.contact_id
                            and a.can_contact = 'Y'
                            and b.effective_end_date is null
                            and b.role_type = 'BROKER'
                        group by
                            a.entity_id,
                            email
                    ) loop
                        if l_record_t.email is null then
                            l_record_t.email := x.email;
                        else
                            l_record_t.email := l_record_t.email
                                                || ','
                                                || x.email;
                        end if;
                    end loop;

                elsif l_charged_to = 'GA' then
                    for x in (
                        select
                            email
                        from
                            contact      a,
                            contact_role b
                        where
                                replace(
                                    strip_bad(a.entity_id),
                                    '-'
                                ) = replace(
                                    strip_bad(p_ein),
                                    '-'
                                )
                            and nvl(a.status, 'A') = 'A'
                            and a.end_date is null
                            and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                            and a.contact_id = b.contact_id
                            and a.can_contact = 'Y'
                            and b.effective_end_date is null
                            and b.role_type = 'GA'
                        group by
                            a.entity_id,
                            email
                    ) loop
                        if l_record_t.email is null then
                            l_record_t.email := x.email;
                        else
                            l_record_t.email := l_record_t.email
                                                || ','
                                                || x.email;
                        end if;
                    end loop;
                elsif l_charged_to = 'EMPLOYER' then
                    for x in (
                        select
                            email
                        from
                            contact      a,
                            contact_role b
                        where
                                replace(
                                    strip_bad(a.entity_id),
                                    '-'
                                ) = replace(
                                    strip_bad(p_ein),
                                    '-'
                                )
                            and nvl(a.status, 'A') = 'A'
                            and a.end_date is null
                            and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                            and a.contact_id = b.contact_id
                            and a.can_contact = 'Y'
                            and b.effective_end_date is null
                            and b.role_type = 'PRIMARY'
                        group by
                            a.entity_id,
                            email
                        union
                        select
                            email
                        from
                            online_users
                        where
                                tax_id = replace(
                                    strip_bad(p_ein),
                                    '-'
                                )
                            and user_type = 'E'
                            and emp_reg_type = 2
                            and user_status = 'A'
                    ) loop
                        if l_record_t.email is null then
                            l_record_t.email := x.email;
                        else
                            l_record_t.email := l_record_t.email
                                                || ','
                                                || x.email;
                        end if;
                    end loop;
                end if;
            -- code ends here by Joshi for 11686

                /*  commented by Joshi for ticket 11686
                 IF  p_product_type NOT IN ('COMPLIANCE','COBRA') THEN
                      FOR X IN (  SELECT email
                                            FROM CONTACT a, CONTACT_ROLE b
                                          WHERE REPLACE(strip_bad(a.entity_id),'-') = REPLACE(strip_bad(p_ein),'-')
                                               AND nvl(a.status,'A') = 'A' and a.end_date is null
                                               AND a.entity_type IN ('CLIENTCONTACT','CLIENTDIVISIONCONTACT', 'ENTERPRISE')
                                               AND a.contact_id = b.contact_id
                                               AND A.CAN_CONTACT = 'Y'
                                               AND b.EFFECTIVE_END_DATE IS NULL
                                               AND b.ROLE_TYPE IN ('PRIMARY','FEE_BILLING','HRA','FSA','HSA')
                                               AND ( ( l_charged_to= 'BROKER' AND a.contact_type='BROKER' ) OR ( l_charged_to ='GA' and  a.contact_type='GA') OR
                                                          ( l_charged_to ='EMPLOYER' and a.contact_type in ( 'PRIMARY','FEE_BILLING')) )
                                              GROUP by a.entity_id,email  )
                             LOOP
                                IF  l_record_t.email IS NULL THEN
                                        l_record_t.email := x.email;
                                ELSE
                                        l_record_t.email := l_record_t.email||','||x.email;
                                END IF;
                            END LOOP;
                ELSIF p_product_type = 'COBRA' THEN
                     FOR X IN ( SELECT email
                                          FROM CONTACT a, CONTACT_ROLE b
                                        WHERE REPLACE(strip_bad(a.entity_id),'-')  = REPLACE(strip_bad(p_ein),'-')
                                             AND  nvl(a.status,'A') = 'A' and a.end_date is null
                                             AND  a.entity_type IN ('CLIENTCONTACT','CLIENTDIVISIONCONTACT', 'ENTERPRISE')
                                             AND  a.contact_id = b.contact_id
                                             AND   b.EFFECTIVE_END_DATE IS NULL
                                           --  AND  b.ROLE_TYPE = 'FEE_BILLING'
                                             AND  A.CAN_CONTACT = 'Y'
                                             AND ( ( l_charged_to= 'BROKER' AND a.contact_type='BROKER' ) OR ( l_charged_to ='GA' and  a.contact_type='GA') OR
                                                          ( l_charged_to ='EMPLOYER' and a.contact_type in ( 'PRIMARY','FEE_BILLING')) )
                                             GROUP by a.entity_id,email )
                     LOOP
                       pc_log.log_error('get_notify_emails  l_record_t.email : ', l_record_t.email);
                       IF  l_record_t.email IS NULL THEN
                                l_record_t.email := x.email;
                        ELSE
                                l_record_t.email := l_record_t.email||','||x.email;
                        END IF;
                     END LOOP;
                ELSIF p_product_type = 'COMPLIANCE' THEN
                     FOR X IN ( SELECT email
                                          FROM CONTACT a, CONTACT_ROLE b
                                       WHERE REPLACE(strip_bad(a.entity_id),'-')  = REPLACE(strip_bad(p_ein),'-')
                                             AND  nvl(a.status,'A') = 'A' and a.end_date is null
                                             AND  a.entity_type IN ('CLIENTCONTACT','CLIENTDIVISIONCONTACT', 'ENTERPRISE')
                                             AND  a.contact_id = b.contact_id
                                             AND   b.EFFECTIVE_END_DATE IS NULL
                                             AND  b.ROLE_TYPE = 'FEE_BILLING'
                                             AND  A.CAN_CONTACT = 'Y'
                                             AND ( ( l_charged_to= 'BROKER' AND a.contact_type='BROKER' ) OR ( l_charged_to ='GA' and  a.contact_type='GA') OR
                                                         ( l_charged_to ='EMPLOYER' and a.contact_type in ( 'PRIMARY','FEE_BILLING')) )
                                             GROUP by a.entity_id,email )
                     LOOP
                          IF  l_record_t.email IS NULL THEN
                                l_record_t.email := x.email;
                          ELSE
                                l_record_t.email := l_record_t.email||','||x.email;
                         END IF;
                     END LOOP;
                END IF;
                */
              -- code ends here by Joshi for 11266.

            else
                for xx in (
                    select
                        email
                    from
                        contact             a,
                        ar_invoice_contacts b
                    where
                            b.invoice_id = p_inv_id
                        and a.contact_id = b.contact_id
                        and nvl(a.status, 'A') = 'A'
                        and a.end_date is null
                        and a.can_contact = 'Y'
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := xx.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || xx.email;
                    end if;
                end loop;
            end if;

        end if;

        pc_log.log_error('get_notify_emails after p_inv_id section  : ', l_record_t.email);
        if l_record_t.email is null then
            if p_notify_type in ( 'CLAIM', 'CLAIM_BILLING' ) then
                for x in (
                    select
                        email
                    from
                        contact      a,
                        contact_role b
                    where
                            replace(
                                strip_bad(a.entity_id),
                                '-'
                            ) = replace(
                                strip_bad(p_ein),
                                '-'
                            )
                        and nvl(a.status, 'A') = 'A'
                        and a.end_date is null
                        and a.can_contact = 'Y'
                        and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                        and a.contact_id = b.contact_id
                        and b.effective_end_date is null
                        and b.role_type in ( 'PRIMARY', 'CLAIM_BILLING', 'HRA', 'FSA' )
                    group by
                        a.entity_id,
                        email
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := x.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || x.email;
                    end if;
                end loop;
            end if;

            if
                p_notify_type in ( 'FEE', 'FEE_BILLING' )
                and p_product_type not in ( 'COMPLIANCE', 'COBRA' )
            then
                for x in (
                    select
                        email
                    from
                        contact      a,
                        contact_role b
                    where
                            replace(
                                strip_bad(a.entity_id),
                                '-'
                            ) = replace(
                                strip_bad(p_ein),
                                '-'
                            )
                        and nvl(a.status, 'A') = 'A'
                        and a.end_date is null
                        and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                        and a.contact_id = b.contact_id
                        and a.can_contact = 'Y'
                        and b.effective_end_date is null
                        and b.role_type in ( 'PRIMARY', 'FEE_BILLING', 'HRA', 'FSA', 'HSA' )
                    group by
                        a.entity_id,
                        email
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := x.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || x.email;
                    end if;
                end loop;

            end if;

            if
                p_notify_type in ( 'FEE', 'FEE_BILLING', 'RENEWAL' )
                and p_product_type = 'COBRA'
            then
                for x in (
                    select
                        email
                    from
                        contact      a,
                        contact_role b
                    where
                            replace(
                                strip_bad(a.entity_id),
                                '-'
                            ) = replace(
                                strip_bad(p_ein),
                                '-'
                            )
                        and nvl(a.status, 'A') = 'A'
                        and a.end_date is null
                        and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                        and a.contact_id = b.contact_id
                        and b.effective_end_date is null
                        and b.role_type = 'FEE_BILLING'
                        and a.can_contact = 'Y'
                    group by
                        a.entity_id,
                        email
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := x.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || x.email;
                    end if;
                end loop;
            end if;

            if
                p_notify_type in ( 'FEE', 'FEE_BILLING' )
                and p_product_type = 'COMPLIANCE'
            then
                for x in (
                    select
                        email
                    from
                        contact      a,
                        contact_role b
                    where
                            replace(
                                strip_bad(a.entity_id),
                                '-'
                            ) = replace(
                                strip_bad(p_ein),
                                '-'
                            )
                        and nvl(a.status, 'A') = 'A'
                        and a.end_date is null
                        and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                        and a.contact_id = b.contact_id
                        and b.effective_end_date is null
                        and b.role_type = 'FEE_BILLING'
                        and a.can_contact = 'Y'
                    group by
                        a.entity_id,
                        email
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := x.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || x.email;
                    end if;
                end loop;
            end if;

            if p_notify_type in ( 'FUNDING', 'FUND_BILLING' ) then
                for x in (
                    select
                        email
                    from
                        contact      a,
                        contact_role b
                    where
                            replace(
                                strip_bad(a.entity_id),
                                '-'
                            ) = replace(
                                strip_bad(p_ein),
                                '-'
                            )
                        and nvl(a.status, 'A') = 'A'
                        and a.end_date is null
                        and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                        and a.contact_id = b.contact_id
                        and a.can_contact = 'Y'
                        and b.effective_end_date is null
                        and b.role_type in ( 'HRA', 'FSA', 'PRIMARY', 'FUND_BILLING' )
                    group by
                        a.entity_id,
                        email
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := x.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || x.email;
                    end if;
                end loop;
            end if;

            if p_notify_type = 'COMPLIANCE' then
                for x in (
                    select
                        email
                    from
                        contact      a,
                        contact_role b
                    where
                            replace(
                                strip_bad(a.entity_id),
                                '-'
                            ) = replace(
                                strip_bad(p_ein),
                                '-'
                            )
                        and nvl(a.status, 'A') = 'A'
                        and a.end_date is null
                        and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                        and a.contact_id = b.contact_id
                        and a.can_contact = 'Y'
                        and b.role_type in ( 'PRIMARY', 'COMPLIANCE' )
                    group by
                        a.entity_id,
                        email
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := x.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || x.email;
                    end if;
                end loop;
            end if;

        end if;

        if user = 'SAMDEV' then
            l_record_t.email := 'IT-team@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com';
        end if;
        pipe row ( l_record_t );
    end get_notify_emails;

    function get_contact_name (
        p_ein          in varchar2,
        p_notify_type  in varchar2,
        p_product_type in varchar2
    ) return contact_info_t
        pipelined
        deterministic
    is
        l_record_t contact_info_row_t;
    begin
        if p_notify_type in ( 'CLAIM', 'CLAIM_BILLING' ) then
            for x in (
                select
                    a.first_name
                    || ' '
                    || a.last_name contact_name
                from
                    contact      a,
                    contact_role b
                where
                        replace(
                            strip_bad(a.entity_id),
                            '-'
                        ) = replace(
                            strip_bad(p_ein),
                            '-'
                        )
                    and nvl(a.status, 'A') = 'A'
                    and a.end_date is null
                    and a.can_contact = 'Y'
                    and a.first_name is not null
                    and a.last_name is not null
                    and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                    and a.contact_id = b.contact_id
                    and b.effective_end_date is null
                    and b.role_type in ( 'PRIMARY', 'CLAIM_BILLING', 'HRA', 'FSA' )
                group by
                    a.entity_id,
                    a.first_name
                    || ' '
                    || a.last_name
            ) loop
                if l_record_t.contact_name is null then
                    l_record_t.contact_name := x.contact_name;
                else
                    l_record_t.contact_name := l_record_t.contact_name
                                               || ','
                                               || x.contact_name;
                end if;
            end loop;
        end if;

        if
            p_notify_type in ( 'FEE', 'FEE_BILLING' )
            and p_product_type not in ( 'COMPLIANCE', 'COBRA' )
        then
            for x in (
                select
                    a.first_name
                    || ' '
                    || a.last_name contact_name
                from
                    contact      a,
                    contact_role b
                where
                        replace(
                            strip_bad(a.entity_id),
                            '-'
                        ) = replace(
                            strip_bad(p_ein),
                            '-'
                        )
                    and nvl(a.status, 'A') = 'A'
                    and a.end_date is null
                    and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                    and a.contact_id = b.contact_id
                    and a.first_name is not null
                    and a.last_name is not null
                    and a.can_contact = 'Y'
                    and b.effective_end_date is null
                    and b.role_type in ( 'PRIMARY', 'FEE_BILLING', 'HRA', 'FSA', 'HSA' )
                group by
                    a.entity_id,
                    a.first_name
                    || ' '
                    || a.last_name
            ) loop
                if l_record_t.contact_name is null then
                    l_record_t.contact_name := x.contact_name;
                else
                    l_record_t.contact_name := l_record_t.contact_name
                                               || ','
                                               || x.contact_name;
                end if;
            end loop;

        end if;

        if
            p_notify_type in ( 'FEE', 'FEE_BILLING' )
            and p_product_type in ( 'COMPLIANCE', 'COBRA' )
        then
            for x in (
                select
                    a.first_name
                    || ' '
                    || a.last_name contact_name
                from
                    contact      a,
                    contact_role b
                where
                        replace(
                            strip_bad(a.entity_id),
                            '-'
                        ) = replace(
                            strip_bad(p_ein),
                            '-'
                        )
                    and nvl(a.status, 'A') = 'A'
                    and a.end_date is null
                    and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                    and a.first_name is not null
                    and a.last_name is not null
                    and a.contact_id = b.contact_id
                    and b.effective_end_date is null
                    and b.role_type in ( 'COBRA', 'FEE_BILLING' )
                    and a.can_contact = 'Y'
                group by
                    a.entity_id,
                    a.first_name
                    || ' '
                    || a.last_name
            ) loop
                if l_record_t.contact_name is null then
                    l_record_t.contact_name := x.contact_name;
                else
                    l_record_t.contact_name := l_record_t.contact_name
                                               || ','
                                               || x.contact_name;
                end if;
            end loop;
        end if;

        if p_notify_type in ( 'FUNDING', 'FUND_BILLING' ) then
            for x in (
                select
                    a.first_name
                    || ' '
                    || a.last_name contact_name
                from
                    contact      a,
                    contact_role b
                where
                        replace(
                            strip_bad(a.entity_id),
                            '-'
                        ) = replace(
                            strip_bad(p_ein),
                            '-'
                        )
                    and nvl(a.status, 'A') = 'A'
                    and a.end_date is null
                    and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                    and a.contact_id = b.contact_id
                    and a.first_name is not null
                    and a.last_name is not null
                    and a.can_contact = 'Y'
                    and b.effective_end_date is null
                    and b.role_type in ( 'HRA', 'FSA', 'PRIMARY', 'FUND_BILLING' )
                group by
                    a.entity_id,
                    a.first_name
                    || ' '
                    || a.last_name
            ) loop
                if l_record_t.contact_name is null then
                    l_record_t.contact_name := x.contact_name;
                else
                    l_record_t.contact_name := l_record_t.contact_name
                                               || ','
                                               || x.contact_name;
                end if;
            end loop;
        end if;

        if p_notify_type = 'COMPLIANCE' then
            for x in (
                select
                    a.first_name
                    || ' '
                    || a.last_name contact_name
                from
                    contact      a,
                    contact_role b
                where
                        replace(
                            strip_bad(a.entity_id),
                            '-'
                        ) = replace(
                            strip_bad(p_ein),
                            '-'
                        )
                    and nvl(a.status, 'A') = 'A'
                    and a.end_date is null
                    and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                    and a.contact_id = b.contact_id
                    and a.first_name is not null
                    and a.last_name is not null
                    and a.can_contact = 'Y'
                    and b.role_type in ( 'PRIMARY', 'COMPLIANCE' )
                group by
                    a.entity_id,
                    a.first_name
                    || ' '
                    || a.last_name
            ) loop
                if l_record_t.contact_name is null then
                    l_record_t.contact_name := x.contact_name;
                else
                    l_record_t.contact_name := l_record_t.contact_name
                                               || ','
                                               || x.contact_name;
                end if;
            end loop;
        end if;

        pipe row ( l_record_t );
    end get_contact_name;

    function get_contact_info (
        p_ein          varchar2,
        p_contact_type in varchar2 default null
    ) return contact_info_t
        pipelined
    is
        rec contact_info_row_t;
    begin
        for i in (
            select
                a.contact_id,
                a.first_name
                || ' '
                || a.last_name name,
                a.first_name,
                a.last_name,
                a.email,
                c.role_type    entity_type,
                a.account_type,                                -- added by Jaggi #10742
                a.phone,
                a.start_date,
                a.status,        -- Added By Rprabu 08/06/2021 For Cp Project
                a.title,
                a.contact_type,
                a.middle_name     -- Added By Rprabu 08/06/2021 For Cp Project
            from
                contact      a,
                contact_role c
            where
                    a.entity_id = p_ein
                and nvl(a.status, 'A') = 'A'
                and c.role_type = nvl(p_contact_type, c.role_type)
                and a.contact_id = c.contact_id
                and c.effective_end_date is null
                and a.email is not null
                and a.can_contact = 'Y'
        ) loop
            rec.contact_id := i.contact_id;
            rec.name := i.name;
            rec.first_name := i.first_name;
            rec.last_name := i.last_name;
            rec.middle_name := i.middle_name;
            rec.phone := i.phone;          -- Added By Rprabu 08/06/2021 For Cp Project
            rec.title := i.title;
            rec.effective_date := i.start_date;
            rec.contact_type := i.contact_type;
            rec.account_type := i.account_type;   -- added by Jaggi #10742
            rec.status := i.status;         --  End  By Rprabu 08/06/2021 For Cp Project
            rec.email := i.email;
            rec.entity_type := i.entity_type;
            pipe row ( rec );
        end loop;
    end get_contact_info;

    function get_salesrep_email (
        p_entrp_id in number
    ) return varchar2 is
        l_email_detail varchar2(4000);
        l_user         varchar2(4000);
    begin
        l_user := user;
        if l_user = 'SAM' then
            for i in (
                select
                    d.email email
                from
                    active_sales_team_member_v a,
                    employee                   d,
                    salesrep                   e
                where
                        a.emplr_id = p_entrp_id
                    and e.status = 'A'
                    and d.emp_id = e.emp_id
                    and e.salesrep_id = primary_salerep
                    and d.email is not null
            ) loop
                l_email_detail := l_email_detail
                                  || ','
                                  || i.email;
            end loop;

        else
            l_email_detail := 'IT-Team@sterlingadministration.com';
        end if;

        return l_email_detail;
    exception
        when others then
            return null;
    end get_salesrep_email;

    function get_super_admin_email (
        p_tax_id in varchar2
    ) return varchar2 is
        l_email_detail varchar2(4000);
        l_user         varchar2(4000);
    begin
        l_user := user;
        pc_log.log_error('GET_SUPER_ADMIN_EMAIL, L_USER', user);
        -- added SAMQA for testing. later to be removed
        if l_user in ( 'SAM', 'SHAVEE', 'SAMQA', 'SAMDEMO', 'APEX_PUBLIC_USER',
                       'SAMQA' ) then    -- remove samqa -- APEX_PUBLIC_USER added by Swamy for Ticket#10978 Included SAMQA and SAMDEMO for QA team to test Ticket#10747 by Swamy
            for i in (
                select --WM_CONCAT(EMAIL) EMAIL
                    listagg(email, ',') within group(
                    order by
                        email
                    ) email
                                 -- Wm_Concat function replaced by listagg by RPRABU on 17/10/2017
                from
                    online_users
                where
                        tax_id = p_tax_id
                    and emp_reg_type = 2
                    and user_status = 'A'
            )  -- added by Joshi. notification should go only active users
             loop
               -- L_EMAIL_DETAIL := L_EMAIL_DETAIL||','||I.EMAIL; -- changed by Joshi for PPP. prefing ',' bcz of which email is not trigeering
                l_email_detail := i.email;
            end loop;
        else
            l_email_detail := 'IT-Team@sterlingadministration.com';
        end if;

        return l_email_detail;
    exception
        when others then
            return null;
    end get_super_admin_email;

-- Added by Joshi for getting parimaty contact emails - PPP
    function get_primary_email (
        p_ein          in varchar2,
        p_account_type in varchar2,
        p_entity_type  in varchar2 default 'ENTERPRISE'   -- Added by Swamy for Ticket#11087
    ) return contact_info_t
        pipelined
        deterministic
    is
        l_record_t contact_info_row_t;
        l_user     varchar2(100);
    begin
        l_user := user;
        if l_user in ( 'SAM', 'SAMQA' ) then
            for x in (
                select
                    email
                from
                    contact      a,
                    contact_role b
                where
                        replace(
                            strip_bad(a.entity_id),
                            '-'
                        ) = replace(
                            strip_bad(p_ein),
                            '-'
                        )
                    and nvl(a.status, 'A') = 'A'
                    and a.end_date is null
                    and a.entity_type = p_entity_type     -- Replaced 'ENTERPRISE' with p_entity_type by Swamy for Ticket#11087
                    and a.contact_id = b.contact_id
                    and a.can_contact = 'Y'
                    and b.effective_end_date is null
                    and b.role_type = 'PRIMARY'
                    and a.account_type = p_account_type
                group by
                    a.entity_id,
                    email
            ) loop
                if l_record_t.email is null then
                    l_record_t.email := x.email;
                else
                    l_record_t.email := l_record_t.email
                                        || ','
                                        || x.email;
                end if;
            end loop;

        else
            l_record_t.email := 'IT-Team@sterlingadministration.com';
        end if;

        pipe row ( l_record_t );
    end get_primary_email;

-- Below Procedure Added By Swamy For Ticket#6794(ACN Migration)
    procedure get_names (
        p_entrp_code     in varchar2,
        p_entrp_contact  in varchar2,
        p_first_name     out varchar2,
        p_last_name      out varchar2,
        p_gender         out varchar2,
        x_process_status out varchar2,
        x_error_message  out varchar2
    ) is

        v_first_name varchar2(100);
        v_found      boolean := false;
        v_tax_id     varchar2(30);
        v_user_id    number;
    begin
        p_first_name := p_entrp_contact;
        p_last_name := null;
        p_gender := 'M';
        if nvl(p_first_name, '*') = '*' then
            for i in (
                select
                    first_name,
                    last_name,
                    gender
                from
                    contact
                where
                        entity_id = p_entrp_code
                    and ( nvl(first_name, '*') <> '*'
                          or ( nvl(last_name, '*') <> '*' ) )
                    and rownum = 1
            ) loop
                p_first_name := i.first_name;
                p_last_name := i.last_name;
                p_gender := nvl(i.gender, 'M');
            end loop;
        end if;

    exception
        when others then
            x_process_status := 'E';
            x_error_message := ' Error In Procedure Pc_contact.get_names Others Error Message :=' || sqlerrm(sqlcode);
    end get_names;

    procedure create_br_ga_user_contact (
        p_first_name         in varchar2,
        p_last_name          in varchar2,
        p_middle_name        in varchar2,
        p_title              in varchar2,
        p_gender             in varchar2,
        p_ein                in varchar2,
        p_phone              in varchar2,
        p_fax                in varchar2,
        p_email              in varchar2,
        p_user_name          in varchar2,
        p_password           in varchar2,
        p_user_id            in number,
        p_role_id            in number,
        p_first_time_pw_flag in varchar2 default 'N',
        p_role_entries       in pc_online_enrollment.varchar2_tbl,
        p_entity_type        in varchar2           -----  9527   05/11/2020
        ,
        x_contact_id         out number,
        x_user_id            out number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        user_error exception;
        l_find_key         varchar2(3000);
        l_ein              varchar2(3000);
        l_enroll_acc_count number := 0;
        l_count            number := 0;
        l_entity_type      varchar2(300);    ---9527 05/11/2020  l_entity_type added

    begin
        x_return_status := 'S';
        pc_log.log_error('create_Broker_user_contact', p_first_name);
        pc_log.log_error('create_Broker_user_contact', 'role id ' || p_role_id);
        pc_log.log_error('role_entries', 'count of role entries' || p_role_entries.count);

           ----   pc_log.log_error('p_entity_id','Entity_id'||p_entity_id);

          ---9527 05/11/2020  entity_type added
        for x in (
            select
                decode(p_entity_type, 'GA', 'G', 'BROKER', 'B') entity_type,
                find_key,
                tax_id
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            l_find_key := x.find_key;
            l_ein := x.tax_id;
            l_entity_type := x.entity_type;
        end loop;

        select
            count(*)
        into l_count
        from
            contact
        where
                lower(email) = lower(p_email)
            and entity_type = p_entity_type ---  'BROKER'   ------9527   05/11/2020
            and entity_id = l_ein;

        if l_count = 0 then
            create_contact(
                p_first_name    => p_first_name,
                p_last_name     => p_last_name,
                p_middle_name   => p_middle_name,
                p_title         => p_title,
                p_gender        => p_gender,
                p_entity_id     => p_ein,
                p_phone         => p_phone,
                p_fax           => p_fax,
                p_email         => p_email,
                p_user_id       => p_user_id,
                x_contact_id    => x_contact_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            pc_log.log_error('create_BR_GA_user_contact', 'x_contact_id' || x_contact_id);
            pc_log.log_error('create_BR_GA_user_contact', 'x_return_status' || x_return_status);
            pc_log.log_error('create_BR_GA_user_contact', 'x_error_message' || x_error_message);
        end if;

        if x_return_status <> 'S' then
            raise user_error;
        end if;
        pc_users.insert_users(
            p_user_name      => p_user_name,
            p_password       => p_password,
            p_user_type      => l_entity_type     ---9527 05/11/2020
            ,
            p_emp_reg_type   => to_char(p_role_id),
            p_find_key       => l_ein            ---- find key broker
            ,
            p_locked_time    => null,
            p_succ_access    => null,
            p_last_login     => null,
            p_failed_att     => 0,
            p_failed_ip      => null,
            p_create_pw      => to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'),
            p_change_pw      => null,
            p_email          => p_email,
            p_pw_question    => null,
            p_pw_answer      => null,
            p_confirmed_flag => 'N',
            p_tax_id         => nvl(p_ein,
                            replace(l_ein, '-')),
            x_user_id        => x_user_id,
            x_return_status  => x_return_status,
            x_error_message  => x_error_message,
            p_user_id        => p_user_id
        );

        pc_log.log_error('create_Broker_user_contact', 'x_user_id' || x_user_id);
        pc_log.log_error('create_Broker_user_contact', 'x_return_status' || x_return_status);
        pc_log.log_error('create_Broker_user_contact', 'x_error_message' || x_error_message);
        if x_return_status <> 'S' then
            raise user_error;
        end if;

    -----   9132 rprabu 29/05/2020
        update user_security_info
        set
            verified_phone_number = p_phone
    ----         VERIFIED_EMAIL   =   p_email
        where
            user_id = x_user_id;

        update online_users
        set
            first_time_pw_flag = p_first_time_pw_flag,
            last_update_date = sysdate
        where
            user_id = x_user_id;

    /*Upadte the user ID's in contact table.Ticket#6792 */
        update contact
        set
            user_id = x_user_id
        where
            contact_id = x_contact_id;

        if l_count > 0 then
            for x in (
                select
                    contact_id
                from
                    contact
                where
                        lower(email) = p_email
                    and entity_type = p_entity_type
                    and entity_id = l_ein
                    and rownum = 1
            )   -----------  9527 05/11/2020 p_entity_type added
             loop
                insert into contact_user_map (
                    contact_user_id,
                    contact_id,
                    user_id,
                    created_by,
                    last_updated_by
                ) values ( contact_user_map_seq.nextval,
                           x.contact_id,
                           x_user_id,
                           p_user_id,
                           p_user_id );

                insert into contact_role (
                    contact_role_id,
                    contact_id,
                    role_type,
                    description,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           x.contact_id,
                           case     ----- WHEN p_role_id = 1 THEN 'ENROLLMENT_EXPRESS'
                               when p_role_id = 2 then
                                   'SUPER_ADMINISTRATOR'
                               when p_role_id = 4 then
                                   'CUSTOM_PERMISSION'
                           end,
                           'Online User Permission',
                           sysdate,
                           p_user_id,
                           p_user_id );

            end loop;
        else
            insert into contact_user_map (
                contact_user_id,
                contact_id,
                user_id,
                created_by,
                last_updated_by
            ) values ( contact_user_map_seq.nextval,
                       x_contact_id,
                       x_user_id,
                       p_user_id,
                       p_user_id );

            insert into contact_role (
                contact_role_id,
                contact_id,
                role_type,
                description,
                effective_date,
                created_by,
                last_updated_by
            ) values ( contact_role_seq.nextval,
                       x_contact_id,
                       case --- WHEN p_role_id = 1 THEN 'ENROLLMENT_EXPRESS'
                           when p_role_id = 2 then
                               'SUPER_ADMINISTRATOR'
                           when p_role_id = 4 then
                               'CUSTOM_PERMISSION'
                       end,
                       'Online User Permission',
                       sysdate,
                       p_user_id,
                       p_user_id );

        end if;

        if p_role_id = 4 then
       -- commented and added by Joshi 9902.
       -- pc_users.create_role_entries (x_user_id,p_role_entries,p_user_id,p_role_id,x_return_status,x_error_message);
            pc_users.create_role_entries(x_user_id, p_role_entries, p_user_id, p_role_id, null,
                                         x_return_status, x_error_message);
        end if;

    exception
        when user_error then
            null;
            pc_log.log_error('create_BR_GA_user_contact', 'user_error , x_return_status' || x_return_status);
            pc_log.log_error('create_BR_GA_user_contact', 'user_error, x_error_message' || x_error_message);
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('create_BR_GA_user_contact', 'x_return_status' || x_return_status);
            pc_log.log_error('create_BR_GA_user_contact', 'x_error_message' || x_error_message);
    end create_br_ga_user_contact;

 -- Added by Joshi for 9527
    function get_user_info (
        p_user_id number
    ) return contact_info_t
        pipelined
    is
        l_find_key  varchar2(15);
        l_user_type varchar2(1);
        l_record_t  contact_info_row_t;
    begin
        for x in (
            select
                user_id,
                user_type,
                find_key,
                tax_id,
                email
            from
                online_users
            where
                user_id = p_user_id
        ) loop
            if x.user_type = 'B' then
                for y in (
                    select
                        p.first_name,
                        p.last_name
                    from
                        broker b,
                        person p
                    where
                            b.broker_id = p.pers_id
                        and b.broker_lic = x.find_key
                ) loop
                    l_record_t.first_name := y.first_name;
                    l_record_t.last_name := y.last_name;
                end loop;

                if l_record_t.first_name is null then
                    for y in (
                        select
                            first_name,
                            middle_name,
                            last_name
                        from
                            contact
                        where
                            user_id = p_user_id
                    ) loop
                        l_record_t.first_name := y.first_name;
                        l_record_t.middle_name := y.middle_name;
                        l_record_t.last_name := y.last_name;
                    end loop;

                end if;

            elsif x.user_type = 'G' then
                for y in (
                    select
                        first_name,
                        middle_name,
                        last_name
                    from
                        contact
                    where
                        user_id = p_user_id
                ) loop
                    l_record_t.first_name := y.first_name;
                    l_record_t.middle_name := y.middle_name;
                    l_record_t.last_name := y.last_name;
                end loop;
            end if;

            l_record_t.email := x.email;
        end loop;

        pipe row ( l_record_t );
    end get_user_info;

-- Added by Jaggi #11699
    function get_notify_all_contacts (
        p_ein          in varchar2,
        p_notify_type  in varchar2,
        p_product_type in varchar2,
        p_inv_id       in number default null
    ) return contact_info_t
        pipelined
        deterministic
    is
        l_record_t contact_info_row_t;
    begin
        if p_inv_id is not null then
            if p_notify_type in ( 'FEE', 'FEE_BILLING' ) then
                for x in (
                    select distinct
                        email
                    from
                        (
                            select
                                email
                            from
                                contact      a,
                                contact_role b
                            where
                                    replace(
                                        strip_bad(a.entity_id),
                                        '-'
                                    ) = replace(
                                        strip_bad(p_ein),
                                        '-'
                                    )
                                and nvl(a.status, 'A') = 'A'
                                and a.end_date is null
                                and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                                and a.contact_id = b.contact_id
                                and a.can_contact = 'Y'
                                and b.effective_end_date is null
                                and b.role_type = 'PRIMARY'
                            group by
                                a.entity_id,
                                email
                            union
                            select
                                email
                            from
                                online_users
                            where
                                    tax_id = replace(
                                        strip_bad(p_ein),
                                        '-'
                                    )
                                and user_type = 'E'
                                and emp_reg_type = 2
                                and user_status = 'A'
                            union
                            select
                                email
                            from
                                contact      a,
                                contact_role b
                            where
                                    replace(
                                        strip_bad(a.entity_id),
                                        '-'
                                    ) = replace(
                                        strip_bad(p_ein),
                                        '-'
                                    )
                                and nvl(a.status, 'A') = 'A'
                                and a.end_date is null
                                and a.entity_type in ( 'CLIENTCONTACT', 'CLIENTDIVISIONCONTACT', 'ENTERPRISE' )
                                and a.contact_id = b.contact_id
                                and a.can_contact = 'Y'
                                and b.effective_end_date is null
                                and b.role_type in ( 'GA', 'BROKER' )
                            group by
                                a.entity_id,
                                email
                        )
                ) loop
                    if l_record_t.email is null then
                        l_record_t.email := x.email;
                    else
                        l_record_t.email := l_record_t.email
                                            || ','
                                            || x.email;
                    end if;
                end loop;

            end if;
        end if;

        pc_log.log_error('Get_Notify_All_Contacts after p_inv_id section  : ', l_record_t.email);

     /*   IF USER = 'SAMDEV' THEN
                 l_record_t.email :=  'IT-team@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com';
        END IF;*/
        pipe row ( l_record_t );
    end get_notify_all_contacts;

-- Added by Joshi for 12396 Sprint 57: GIACT Reminder email
    function get_broker_super_admin_email (
        p_broker_lic in varchar2
    ) return varchar2 is
        l_email_detail varchar2(4000);
        l_user         varchar2(4000);
    begin
        l_user := user;
        if l_user in ( 'SAM', 'SHAVEE', 'APEX_PUBLIC_USER', 'SAMQA' ) then  -- remove samqa -- APEX_PUBLIC_USER added by Swamy for Ticket#10978
            for i in (
                select
                    listagg(email, ',') within group(
                    order by
                        email
                    ) email
                from
                    online_users
                where
                        find_key = p_broker_lic
                    and emp_reg_type = 2
                    and user_type = 'B'
                    and user_status = 'A'
            ) loop
                l_email_detail := i.email;
            end loop;

        else
            l_email_detail := 'IT-Team@sterlingadministration.com';
        end if;

        return l_email_detail;
    exception
        when others then
            return null;
    end get_broker_super_admin_email;

-- Added by Joshi for 12396 Sprint 57: GIACT Reminder email    
    function get_ga_super_admin_email (
        p_ga_lic in varchar2
    ) return varchar2 is
        l_email_detail varchar2(4000);
        l_user         varchar2(4000);
    begin
        l_user := user;
        if l_user in ( 'SAM', 'SHAVEE', 'APEX_PUBLIC_USER', 'SAMQA' ) then
            for i in (
                select --WM_CONCAT(EMAIL) EMAIL
                    listagg(email, ',') within group(
                    order by
                        email
                    ) email
                from
                    online_users
                where
                        find_key = p_ga_lic
                    and emp_reg_type = 2
                    and user_type = 'G'
                    and user_status = 'A'
            ) loop
                l_email_detail := i.email;
            end loop;

        else
            l_email_detail := 'IT-Team@sterlingadministration.com';
        end if;

        return l_email_detail;
    exception
        when others then
            return null;
    end get_ga_super_admin_email;

end pc_contact;
/


-- sqlcl_snapshot {"hash":"31e6ffcc6202cda6ad333980b884bf524be9727e","type":"PACKAGE_BODY","name":"PC_CONTACT","schemaName":"SAMQA","sxml":""}