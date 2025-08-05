create or replace package body samqa.pc_employer_enroll is

    procedure insert_employer (
        p_name                         in varchar2,
        p_ein_number                   in varchar2,
        p_address                      in varchar2,
        p_city                         in varchar2,
        p_state                        in varchar2,
        p_zip                          in varchar2,
        p_contact_name                 in varchar2,
        p_phone                        in varchar2,
        p_email                        in varchar2,
        p_fee_plan_type                in number,
        p_plan_code                    in number,
        p_broker_lic                   in varchar2,
        p_card_allowed                 in varchar2,
        p_er_contribution_freq         in number,
        p_ee_contribution_freq         in number,
        p_er_contribution_flag         in number,
        p_ee_contribution_flag         in number,
        p_setup_fee_paid_by            in number,
        p_maint_fee_paid_by            in number,
        p_management_account_user_name in varchar2,
        p_enrollment_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_enrollment_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_lang_perf                    in varchar2,
        p_peo_ein                      in varchar2 default null,
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_setup_error exception;
        l_create_error exception;
        l_return_status  varchar2(30) := 'S';
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_entrp_id       number;
        l_user_id        number;
        l_count          number := 0;
        l_acc_pref       pc_account.acc_pref_t;
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'Inserting Enroll');
        if
            p_management_account_user_name is not null
            and p_enrollment_account_user_name is not null
            and p_management_account_user_name = p_enrollment_account_user_name
        then
            l_error_message := 'Enrollment User Name '
                               || p_enrollment_account_user_name
                               || ' and '
                               || p_management_account_user_name
                               || ' cannot be the same ';
            raise l_setup_error;
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking length of EIN');
        if length(p_ein_number) > 20 then
            l_error_message := 'Employee ID Number '
                               || p_ein_number
                               || ' cannot be more than 20 characters ';
            raise l_setup_error;
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking User registered');
        if nvl(
            pc_users.check_user_registered(p_ein_number, 'E'),
            'N'
        ) = 'N' then
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking User if alphanumeric');
            if isalphanumeric(p_management_account_user_name) is not null then
                pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking if User has alphanumeric');
                x_error_message := ' Special Characters '
                                   || isalphanumeric(p_management_account_user_name)
                                   || ' are not allowed for user name ';
                raise l_setup_error;
            end if;

            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking is user name null');
            if p_management_account_user_name is null then
                x_error_message := 'Enter valid Management Account User Name';
                raise l_setup_error;
            end if;
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking is password null');
            if p_management_account_password is null then
                x_error_message := 'Enter valid Management Account Password';
                raise l_setup_error;
            end if;
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking is password question null');
            if p_password_question is null then
                x_error_message := 'Enter valid password reminder question';
                raise l_setup_error;
            end if;
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'checking is password answer null');
            if p_password_answer is null then
                x_error_message := 'Enter valid password reminder answer';
                raise l_setup_error;
            end if;
        end if;

        insert into employer_online_enrollment (
            enrollment_id,
            name,
            ein_number,
            address,
            city,
            state,
            zip,
            contact_name,
            phone,
            email,
            fee_plan_type,
            plan_code,
            er_contribution_frequency,
            ee_contribution_frequency,
            er_contribution_flag,
            ee_contribution_flag,
            setup_fee_paid_by,
            maint_fee_paid_by,
            management_account_user_name,
            enrollment_account_user_name,
            management_account_password,
            enrollment_account_password,
            password_question,
            password_answer,
            lang_perf,
            peo_ein,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( mass_enrollments_seq.nextval,
                   p_name,
                   p_ein_number,
                   p_address,
                   p_city,
                   p_state,
                   p_zip,
                   p_contact_name,
                   p_phone,
                   p_email,
                   p_fee_plan_type,
                   p_plan_code,
                   p_er_contribution_freq,
                   p_ee_contribution_freq,
                   p_er_contribution_flag,
                   p_ee_contribution_flag,
                   p_setup_fee_paid_by,
                   p_maint_fee_paid_by,
                   p_management_account_user_name,
                   p_enrollment_account_user_name,
                   p_management_account_password,
                   p_enrollment_account_password,
                   p_password_question,
                   p_password_answer,
                   p_lang_perf,
                   p_peo_ein,
                   sysdate,
                   421,
                   sysdate,
                   421 ) returning enrollment_id into x_enrollment_id;

        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'x_enrollment_id ' || x_enrollment_id);
        savepoint enroll;
        for x in (
            select
                *
            from
                employer_online_enrollment
            where
                enrollment_id = x_enrollment_id
        ) loop
            l_action := 'Creating Employer ';
            begin
                if p_peo_ein is not null then
                    select
                        count(*)
                    into l_count
                    from
                        entrp_relationships a,
                        account             b
                    where
                            replace(a.tax_id, '-') = replace(x.ein_number, '-')
                        and replace(a.entity_id, '-') = replace(p_peo_ein, '-')
                        and a.entity_type = 'PEO'
                        and a.entrp_id = b.entrp_id
                        and b.account_type = 'HSA';

                elsif
                    p_peo_ein is null
                    and x.ein_number is not null
                then
                    select
                        count(*)
                    into l_count
                    from
                        enterprise a,
                        account    b
                    where
                            replace(a.entrp_code, '-') = replace(x.ein_number, '-')
                        and a.en_code = 1
                        and a.entrp_id = b.entrp_id
                        and b.account_type = 'HSA';

                end if;

                if l_count <> 0 then
                    pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'EIN COUNT ' || l_count);
                    x_error_message := 'Employer Already Exists for EIN ' || x.ein_number;
                    raise l_create_error;
                else
                    insert into enterprise (
                        entrp_id,
                        en_code,
                        name,
                        entrp_code,
                        address,
                        city,
                        state,
                        zip,
                        entrp_pay,
                        entrp_contact,
                        entrp_phones,
                        entrp_email,
                        note,
                        card_allowed,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by
                    ) values ( entrp_seq.nextval,
                               1,
                               x.name,
                               x.ein_number,
                               x.address,
                               x.city,
                               x.state,
                               x.zip,
                               x.fee_plan_type,
                               x.contact_name,
                               x.phone,
                               x.email,
                               'Online Enrollment',
                               decode(
                                   upper(p_card_allowed),
                                   'Y',
                                   0,
                                   'YES',
                                   0,
                                   'NO',
                                   1,
                                   'N',
                                   1,
                                   p_card_allowed
                               ),
                               sysdate,
                               421,
                               sysdate,
                               421 ) returning entrp_id into l_entrp_id;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'l_entrp_id ' || l_entrp_id);
                    l_acc_num := 'G'
                                 || substr(
                        pc_account.generate_acc_num(x.plan_code, x.state),
                        2
                    );

                    l_action := 'Creating Account';
                    l_acc_num := 'G'
                                 || case
                        when x.plan_code in ( 1, 2, 3 ) then
                            substr(
                                pc_account.generate_acc_num(x.plan_code,
                                                            upper(x.state)),
                                2
                            )
                        else pc_account.generate_acc_num(x.plan_code, null)
                    end;

                    insert into account (
                        acc_id,
                        entrp_id,
                        acc_num,
                        plan_code,
                        start_date,
                        broker_id,
                        note,
                        fee_setup,
                        fee_maint,
                        reg_date,
                        pay_code,
                        pay_period,
                        account_status,
                        complete_flag,
                        account_type,
                        enrollment_source,
                        lang_perf
                    ) values ( acc_seq.nextval,
                               l_entrp_id,
                               l_acc_num,
                               x.plan_code,
                               sysdate,
                               nvl((
                                   select
                                       broker_id
                                   from
                                       broker
                                   where
                                       broker_lic = x.broker_lic
                               ), 0),
                               'Online Enrollment',
                               pc_plan.fsetup_online(0),
                               pc_plan.fmonth(x.plan_code),
                               sysdate,
                               x.fee_plan_type,
                               x.er_contribution_frequency,
                               1,
                               1,
                               'HSA',
                               'ONLINE',
                               p_lang_perf ) returning acc_id into l_acc_id;

                    if l_return_status <> 'S' then
                        raise l_create_error;
                    end if;
                    if p_peo_ein is not null then
                        insert into entrp_relationships (
                            relationship_id,
                            entrp_id,
                            tax_id,
                            entity_id,
                            entity_type,
                            relationship_type,
                            start_date,
                            status,
                            note,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by
                        ) values ( entrp_relationship_seq.nextval,
                                   l_entrp_id,
                                   x.ein_number,
                                   p_peo_ein,
                                   'PEO',
                                   'PEO_ER',
                                   sysdate,
                                   'A',
                                   'Online Enrollment',
                                   sysdate,
                                   1,
                                   sysdate,
                                   1 );

                    end if;

                    l_action := 'Creating Management Account';
                    l_action := 'Creating Management Account';
                    if nvl(
                        pc_users.check_user_registered(x.ein_number, 'E'),
                        'N'
                    ) = 'N' then
                        pc_users.insert_users(
                            p_user_name     => x.management_account_user_name,
                            p_password      => x.management_account_password,
                            p_user_type     => 'E',
                            p_emp_reg_type  => 2 -- check if this is for management
                            ,
                            p_find_key      => l_acc_num,
                            p_email         => x.email,
                            p_pw_question   => x.password_question,
                            p_pw_answer     => x.password_answer,
                            p_tax_id        => x.ein_number,
                            x_user_id       => l_user_id,
                            x_return_status => l_return_status,
                            x_error_message => x_error_message
                        );

                        if l_return_status <> 'S' then
                            raise l_create_error;
                        end if;
                    else
                        if pc_users.get_user_count(x.ein_number, 'E') > 1 then
              --     x_error_message := pc_users.g_dup_user_for_tax;
              --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
              --   RAISE l_create_error;
                            null;
                        else
                            l_user_id := pc_users.get_user(x.ein_number, 'E');
                        end if;
                    end if;
          /* 10/18/2011: no longer used
          IF x.enrollment_account_user_name IS NOT NULL THEN
          l_action := 'Creating Enrollment Account';
          pc_users.INSERT_USERS
          (p_user_name       => x.enrollment_account_user_name
          ,p_password        => x.enrollment_account_password
          ,p_user_type       => 'E'
          ,p_emp_reg_type    => 1 -- check if this is for enrollment
          ,p_find_key        => l_acc_num
          ,p_email           => x.email
          ,p_pw_question     => x.password_question
          ,p_pw_answer       => x.password_answer
          ,p_tax_id          => x.ein_number
          ,x_user_id         => l_user_id
          ,x_return_status   => l_return_status
          ,x_error_message   => l_error_message);
          IF l_return_status <> 'S' THEN
          RAISE l_create_error;
          END IF;
          END IF;*/
                    update employer_online_enrollment
                    set
                        entrp_id = l_entrp_id,
                        acc_num = l_acc_num,
                        enrollment_status = 'S'
                    where
                        enrollment_id = x_enrollment_id;

                    select
                        l_acc_id,
                        l_entrp_id,
                        null,
                        lang_perf,
                        null,
                        'A',
                        null,
                        null,
                        'Y',
                        null,
                        null,
                        'Y',
                        er_contribution_frequency,
                        ee_contribution_frequency,
                        er_contribution_flag,
                        ee_contribution_flag,
                        setup_fee_paid_by,
                        maint_fee_paid_by
                    bulk collect
                    into l_acc_pref
                    from
                        employer_online_enrollment
                    where
                        enrollment_id = x_enrollment_id;

                    l_action := 'CREATING ACCOUNT PREFERENCE';
                    pc_account.insert_acc_pref(l_acc_pref, 421, l_return_status, l_error_message);
                    if l_return_status <> 'S' then
                        raise l_create_error;
                    end if;
                end if;

            exception
                when l_create_error then
                    rollback to savepoint enroll;
                    x_error_message := l_action
                                       || ' '
                                       || x_error_message;
                    x_return_status := 'E';
                    update employer_online_enrollment
                    set
                        error_message = x_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;
        -- RAISE;
                when others then
                    rollback to savepoint enroll;
                    x_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    x_return_status := 'E';
                    update employer_online_enrollment
                    set
                        error_message = x_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;
        --  RAISE;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'error in when others ' || sqlerrm);
                    dbms_output.put_line('error message ' || sqlerrm);
            end;

        end loop;

    exception
        when l_setup_error then
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'error in l_setup_error ' || x_error_message);
            x_return_status := 'E';
            x_error_message := x_error_message;
        when others then
            x_return_status := 'E';
            x_error_message := x_error_message
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'error in when others ' || sqlerrm);
    end insert_employer;

    procedure update_employer (
        p_entrp_id            in number,
        p_name                in varchar2,
        p_ein_number          in varchar2 default null,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zip                 in varchar2,
        p_contact_name        in varchar2,
        p_phone               in varchar2,
        p_email               in varchar2,
        p_user_id             in number,
        p_office_phone_number in varchar2 default null,  -- Added by Joshi for 10430
        p_fax_id              in varchar2 default null,              -- Added by Joshi for 10430
        x_error_message       out varchar2,
        x_return_status       out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('EMPLOYER INSERT , employer name', p_name);
        pc_log.log_error('EMPLOYER INSERT , p_address', p_address);
        update enterprise
        set
            name = nvl(p_name, name),
            address = nvl(p_address, address),
            city = nvl(p_city, city),
            state = nvl(p_state, state),
            zip = nvl(p_zip, zip),
            entrp_contact = nvl(p_contact_name, entrp_contact),
            entrp_email = nvl(p_email, entrp_email),
            entrp_phones = nvl(p_phone, entrp_phones),
            last_updated_by = p_user_id,
            last_update_date = sysdate,
            office_phone_number = nvl(p_office_phone_number, office_phone_number), -- Added by Joshi for 10430
            entrp_fax = nvl(p_fax_id, entrp_fax)                                                                -- Added by Joshi for 10430
        where
            entrp_id = p_entrp_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_employer;

    procedure delete_employer (
        p_enrollment_id in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        x_return_status := 'S';
        delete from employer_online_enrollment
        where
            enrollment_id = p_enrollment_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end delete_employer;

    procedure insert_emp_health_plan (
        p_entrp_id            in number,
        p_carrier_id          in number,
        p_plan_type           in number,
        p_deductible          in number,
        p_single_contribution in number,
        p_family_contribution in number,
        p_effective_date      in varchar2,
        x_error_message       out varchar2,
        x_return_status       out varchar2
    ) is
    begin
        x_return_status := 'S';
        if
            p_carrier_id is not null
            and p_deductible is not null
            and p_effective_date is not null
        then
            insert into employer_health_plans (
                health_plan_id,
                entrp_id,
                carrier_id,
                plan_type,
                deductible,
                single_contribution,
                family_contribution,
                effective_date,
                renewal_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( health_plan_seq.nextval,
                       p_entrp_id,
                       p_carrier_id,
                       p_plan_type,
                       p_deductible,
                       decode(p_single_contribution, 0, null, p_single_contribution),
                       decode(p_family_contribution, 0, null, p_family_contribution),
                       to_date(p_effective_date, 'DD-MON-YYYY'),
                       add_months(to_date(p_effective_date, 'DD-MON-YYYY'), 12),
                       sysdate,
                       421,
                       sysdate,
                       421 );

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_emp_health_plan;

    procedure bulk_insert_emp_health_plan (
        p_entrp_id       in number,
        p_carrier_id     in varchar2_tbl,
        p_deductible     in varchar2_tbl,
        p_plan_type      in varchar2_tbl,
        p_effective_date in varchar2_tbl,
        x_error_message  out varchar2,
        x_return_status  out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('BULK_INSERT_EMP_HEALTH_PLAN', 'carrier count ' || p_carrier_id.count);
        for i in 1..p_carrier_id.count loop
            if
                p_carrier_id(i) is not null
                and p_deductible(i) is not null
                and p_plan_type(i) is not null
                and p_effective_date(i) is not null
            then
                insert into employer_health_plans (
                    health_plan_id,
                    entrp_id,
                    carrier_id,
                    deductible,
                    plan_type,
                    effective_date,
                    renewal_date,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( health_plan_seq.nextval,
                           p_entrp_id,
                           p_carrier_id(i),
                           p_deductible(i),
                           p_plan_type(i),
                           to_date(p_effective_date(i),
                                   'MM/DD/YYYY'),
                           add_months(to_date(p_effective_date(i),
                                      'MM/DD/YYYY'),
                                      12),
                           sysdate,
                           0,
                           sysdate,
                           0 );

            end if;
        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end bulk_insert_emp_health_plan;

    procedure insert_emp_health_plan_renew (
        p_entrp_id            in number,
        p_carrier_id          in number,
        p_plan_type           in number,
        p_deductible          in number,
        p_single_contribution in number,
        p_family_contribution in number,
        p_effective_date      in varchar2,
        p_renewal_date        in varchar2,
        p_user_id             in number,
        x_error_message       out varchar2,
        x_return_status       out varchar2
    ) is
    begin
        x_return_status := 'S';
        if
            p_carrier_id is not null
            and p_deductible is not null
            and p_effective_date is not null
        then
            insert into employer_health_plans (
                health_plan_id,
                entrp_id,
                carrier_id,
                plan_type,
                deductible,
                single_contribution,
                family_contribution,
                effective_date,
                renewal_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( health_plan_seq.nextval,
                       p_entrp_id,
                       p_carrier_id,
                       p_plan_type,
                       p_deductible,
                       decode(p_single_contribution, 0, null, p_single_contribution),
                       decode(p_family_contribution, 0, null, p_family_contribution),
                       to_date(p_effective_date, 'MM/DD/YYYY'),
                       nvl(to_date(p_renewal_date, 'MM/DD/YYYY'), to_date(p_effective_date, 'MM/DD/YYYY') + 365),
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id );

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_emp_health_plan_renew;

    procedure update_emp_health_plan (
        p_health_plan_id      in number,
        p_entrp_id            in number,
        p_carrier_id          in number,
        p_plan_type           in number,
        p_deductible          in number,
        p_contribution_amount in number,
        p_user_id             in number,
        x_error_message       out varchar2,
        x_return_status       out varchar2
    ) is
    begin
        x_return_status := 'S';
    /*  UPDATE employer_health_plans
    SET entrp_id    = p_entrp_id
    , carrier_id  = p_carrier_id
    , plan_type   = p_plan_type
    , deductible  = p_deductible
    , last_updated_by = p_user_id
    WHERE health_plan_id = p_health_plan_id; */
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_emp_health_plan;

    procedure delete_emp_health_plan (
        p_entrp_id       in number,
        p_health_plan_id in varchar2_tbl,
        p_user_id        in number,
        x_error_message  out varchar2,
        x_return_status  out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('DELETE_EMP_HEALTH_PLAN', 'Entrp_id ' || p_entrp_id);
        for i in 1..p_health_plan_id.count loop
            update employer_health_plans
            set
                status = 'I',
                effective_end_date = sysdate,
                last_updated_by = p_user_id
            where
                    health_plan_id = p_health_plan_id(i)
                and entrp_id = p_entrp_id;

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end delete_emp_health_plan;
/** Called from SAM **/
    procedure create_employer (
        p_name                   in varchar2,
        p_ein_number             in varchar2,
        p_address                in varchar2,
        p_city                   in varchar2,
        p_state                  in varchar2,
        p_zip                    in varchar2,
        p_account_type           in varchar2,
        p_start_date             in varchar2,
        p_phone                  in varchar2,
        p_email                  in varchar2,
        p_fax                    in varchar2,
        p_contact_name           in varchar2,
        p_contact_phone          in varchar2,
        p_broker_id              in number,
        p_salesrep_id            in number,
        p_ga_id                  in number,
        p_plan_code              in number,
        p_card_allowed           in varchar2,
        p_setup_fee              in number,
        p_note                   in varchar2,
        p_pin_mailer             in varchar2,
        p_cust_svc_rep           in number,
        p_allow_eob              in varchar2,
        p_teamster_group         in varchar2,
        p_user_id                in number,
        p_takeover_flag          in varchar2 default null,
        p_total_employees        in number,
        p_maint_fee_flag         in number,
        x_acc_num                out varchar2,
        x_error_message          out varchar2,
        x_return_status          out varchar2,
        p_allow_online_renewal   in varchar2,
        p_allow_election_changes in varchar2
    ) is

        setup_error exception;
        l_entrp_id            number;
        l_acc_num             varchar2(30);
        l_acc_id              number;
        l_salesteam_member_id number;
        l_rate_plan_id        number;
        l_setup_fee           number;
        l_monthly_fee         number;
        l_ben_plan_id         number;
        l_batch_number        number;
    begin
        x_return_status := 'S';
        pc_log.log_error('Here', p_plan_code);
        if p_plan_code is null then
            x_error_message := 'Enter valid value for plan code';
            raise setup_error;
        end if;
        if
            p_account_type = 'HRA'
            and pc_plan.get_account_type(p_plan_code) <> 'HRA'
        then
            x_error_message := 'Not a valid plan for HRA accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'POP'
            and pc_plan.get_account_type(p_plan_code) <> 'POP'
        then
            x_error_message := 'Not a valid plan for POP accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'FSA'
            and pc_plan.get_account_type(p_plan_code) <> 'FSA'
        then
            x_error_message := 'Not a valid plan for FSA accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'HSA'
            and pc_plan.get_account_type(p_plan_code) <> 'HSA'
        then
            x_error_message := 'Not a valid plan for HSA accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'LSA'
            and pc_plan.get_account_type(p_plan_code) <> 'LSA'
        then    -- Added by Swamy for Ticket#9912 on 10/08/2021
            x_error_message := 'Not a valid plan for LSA accounts';
            raise setup_error;
        end if;

    -- Added by Joshi for 11599  on 04/27/2023
        if
            p_account_type = 'CMP'
            and pc_plan.get_account_type(p_plan_code) <> 'CMP'
        then
            x_error_message := 'Not a valid plan for CMP accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'COBRA'
            and pc_plan.get_account_type(p_plan_code) <> 'COBRA'
        then
            x_error_message := 'Not a valid plan for COBRA accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'FORM_5500'
            and pc_plan.get_account_type(p_plan_code) <> 'FORM_5500'
        then
            x_error_message := 'Not a valid plan for Form 5500 accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'ERISA_WRAP'
            and pc_plan.get_account_type(p_plan_code) <> 'ERISA_WRAP'
        then
            x_error_message := 'Not a valid plan for ERISA Wrap accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'ERISA_WRAP'
            and pc_plan.get_account_type(p_plan_code) <> 'ERISA_WRAP'
        then
            x_error_message := 'Not a valid plan for ERISA Wrap accounts';
            raise setup_error;
        end if;

        if
            p_account_type = 'ACA'
            and pc_plan.get_account_type(p_plan_code) <> 'ACA'
        then
            x_error_message := 'Not a valid plan for ACA accounts';
            raise setup_error;
        end if;

        if p_ein_number is null then
            x_error_message := 'Enter Tax Code ';
            raise setup_error;
        end if;
        if p_name is null then
            x_error_message := 'Enter Employer Name ';
            raise setup_error;
        end if;
    /*   IF p_salesrep_id IS NULL THEN
    x_error_message := 'Sales Representative must be selected';
    RAISE setup_error;
    END IF;*/
        for x in (
            select
                count(*) cnt
            from
                enterprise a,
                account    b
            where
                    entrp_code = p_ein_number
                and a.entrp_id = b.entrp_id
                and b.account_type = p_account_type
        ) loop
            if x.cnt > 0 then
                x_error_message := p_name || ' already has account  ';
                raise setup_error;
            end if;
        end loop;

        pc_log.log_error('Here2..', p_plan_code);
        insert into enterprise (
            entrp_id,
            en_code,
            name,
            entrp_code,
            address,
            city,
            state,
            zip,
            entrp_contact,
            entrp_phones,
            entrp_email,
            note,
            card_allowed,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            contact_phone,
            entrp_fax,
            no_of_eligible
        ) values ( entrp_seq.nextval,
                   1,
                   p_name,
                   p_ein_number,
                   p_address,
                   p_city,
                   upper(p_state),
                   p_zip,
                   p_contact_name,
                   p_phone,
                   p_email,
                   p_note,
                   p_card_allowed,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   p_contact_phone,
                   p_fax,
                   p_total_employees ) returning entrp_id into l_entrp_id;

        select
            decode(p_teamster_group,
                   'Y',
                   20,
                   nvl(p_setup_fee,
                       pc_plan.fsetup(p_plan_code)))
        into l_setup_fee
        from
            dual;

        select
            decode(p_teamster_group,
                   'Y',
                   5.75,
                   pc_plan.fmonth(p_plan_code))
        into l_monthly_fee
        from
            dual;

        insert into account (
            acc_id,
            entrp_id,
            acc_num,
            plan_code,
            start_date,
            broker_id,
            fee_setup,
            fee_maint,
            reg_date,
            pay_code,
            pay_period,
            account_status,
            complete_flag,
            signature_on_file,
            account_type,
            note,
            salesrep_id,
            ga_id,
            takeover_flag
        ) values ( acc_seq.nextval,
                   l_entrp_id --Added new codes for new HSA plans.Employer online portal
                   ,
                   'G'
                   ||
                   case
                       when p_account_type = 'HSA'
                            and p_plan_code in ( 1, 2, 3, 5, 6,
                                                 7 ) then
                               substr(
                                   pc_account.generate_acc_num(p_plan_code,
                                                               upper(p_state)),
                                   2
                               )
                       else
                           pc_account.generate_acc_num(p_plan_code, null)
                   end,
                   p_plan_code,
                   nvl(to_date(p_start_date, 'MM/DD/YYYY'), sysdate),
                   nvl(p_broker_id, 0),
                   l_setup_fee,
                   l_monthly_fee,
                   sysdate,
                   4,
                   5,
                   1,
                   1,
                   'Y',
                   p_account_type,
                   p_note,
                   p_salesrep_id,
                   p_ga_id,
                   p_takeover_flag ) returning acc_num,
                                               acc_id into l_acc_num, l_acc_id;

        for x in (
            select
                p_broker_id entity_id,
                'BROKER'    entity_type
            from
                dual
            union
            select
                p_salesrep_id entity_id,
                'SALES_REP'   entity_type
            from
                dual
            union
            select
                p_cust_svc_rep entity_id,
                'CS_REP'       entity_type
            from
                dual
            union
            select
                p_ga_id         entity_id,
                'GENERAL_AGENT' entity_type
            from
                dual
        ) loop
            if x.entity_id is not null then
                pc_sales_team.upsert_sales_team_member(
                    p_entity_type           => x.entity_type,
                    p_entity_id             => x.entity_id,
                    p_mem_role              => 'PRIMARY',
                    p_entrp_id              => l_entrp_id,
                    p_start_date            => nvl(to_date(p_start_date, 'MM/DD/YYYY'), sysdate),
                    p_end_date              => null,
                    p_status                => 'A',
                    p_user_id               => p_user_id,
                    p_pay_commission        => 'Y',
                    p_note                  => 'From create enrollment',
                    p_no_of_days            => null,
                    px_sales_team_member_id => l_salesteam_member_id,
                    x_return_status         => x_return_status,
                    x_error_message         => x_error_message
                );

                if x_return_status <> 'S' then
                    raise setup_error;
                end if;
            end if;
        end loop;

        insert into account_preference (
            account_preference_id,
            acc_id,
            entrp_id,
            status,
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
            allow_election_changes
        ) values ( account_preference_seq.nextval,
                   l_acc_id,
                   l_entrp_id,
                   'A',
                   'Y',
                   nvl(p_pin_mailer, 'N'),
                   nvl(p_teamster_group, 'N'),
                   'Y',
                   p_maint_fee_flag,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   p_allow_online_renewal,
                   p_allow_election_changes );

        if
            p_account_type = 'HSA'
            and p_teamster_group = 'Y'
        then
            setup_teamster_group(l_entrp_id, p_name, p_user_id);
        end if;

        if p_account_type = 'POP' then
            pc_benefit_plans.create_pop_plan(l_acc_id);

      -- Swamy #12057 08032024
            for i in (
                select
                    ben_plan_id,
                    batch_num_seq.nextval batch_number
                from
                    ben_plan_enrollment_setup
                where
                    acc_id = l_acc_id
            ) loop
                l_ben_plan_id := i.ben_plan_id;
                l_batch_number := i.batch_number;
            end loop;

            if nvl(l_ben_plan_id, 0) <> 0 then
                pc_employer_enroll.upsert_rto_api_plan_doc(
                    p_entrp_id      => l_entrp_id,
                    p_acc_id        => l_acc_id,
                    p_ben_plan_id   => l_ben_plan_id,
                    p_batch_number  => l_batch_number,
                    p_user_id       => p_user_id,
                    p_source        => 'ENROLLMENT',
                    x_error_message => x_error_message,
                    x_return_status => x_return_status
                );
            end if;

        end if;

        x_acc_num := l_acc_num;
        x_error_message := 'Account Created Successfully';
    exception
        when setup_error then
            x_return_status := 'E';
    end create_employer;

    procedure setup_teamster_group (
        p_entrp_id in number,
        p_name     in varchar2,
        p_user_id  in number
    ) is

        l_entrp_name      varchar2(2000);
        l_rate_plan_id    number;
        l_rate_plan_count number := 0;
        l_setup_fee       number;
        l_monthly_fee     number;
    begin
        l_entrp_name := nvl(p_name,
                            pc_entrp.get_entrp_name(p_entrp_id));
        for x in (
            select
                rate_plan_id
            from
                rate_plans
            where
                    entity_id = p_entrp_id
                and entity_type = 'EMPLOYER'
        ) loop
            l_rate_plan_count := 1;
        end loop;

        if l_rate_plan_count = 0 then
            update account
            set
                fee_setup = 20,
                fee_maint = 5.75
            where
                entrp_id = p_entrp_id;

            insert into rate_plans (
                rate_plan_id,
                rate_plan_name,
                entity_type,
                entity_id,
                status,
                effective_date,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_plan_type
            ) values ( rate_plans_seq.nextval,
                       l_entrp_name,
                       'EMPLOYER',
                       p_entrp_id,
                       'A',
                       sysdate,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       'INVOICE' ) returning rate_plan_id into l_rate_plan_id;

            for x in (
                select
                    reason_code,
                    reason_name,
                    decode(reason_code, 1, 20, 2, 5.75,
                           null) amount
                from
                    pay_reason
                where
                    reason_code in ( 1, 2 )
            ) loop
                if x.amount is not null then
                    insert into rate_plan_detail (
                        rate_plan_detail_id,
                        rate_plan_id,
                        calculation_type,
                        rate_code,
                        rate_plan_cost,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        rate_basis,
                        effective_date
                    ) values ( rate_plan_detail_seq.nextval,
                               l_rate_plan_id,
                               'AMOUNT',
                               to_char(x.reason_code),
                               x.amount,
                               sysdate,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               'ACTIVE',
                               sysdate );

                end if;
            end loop;

        end if;

    end setup_teamster_group;

    procedure create_enterprise_relation (
        p_entrp_id      in number,
        p_entity_id     in number,
        p_entity_type   in varchar2,
        p_relat_type    in varchar2,
        p_user_id       in number default 0,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_tax_id varchar2(20);
    begin
        x_return_status := 'S';
        l_tax_id := pc_entrp.get_tax_id(p_entrp_id);
        insert into entrp_relationships (
            relationship_id,
            entrp_id,
            tax_id,
            entity_id,
            entity_type,
            relationship_type,
            start_date,
            status,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( entrp_relationship_seq.nextval,
                   p_entrp_id,
                   l_tax_id,
                   p_entity_id,
                   p_entity_type,
                   p_relat_type,
                   sysdate,
                   'A',
                   'Creating relationship on ' || to_char(sysdate, 'MM/DD/YYYY'),
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id );

    exception
        when others then
            x_return_status := 'E';
            x_error_message := 'Error creating relation ' || sqlerrm;
    end create_enterprise_relation;

    function get_er_health_plan (
        p_entrp_id in number
    ) return ret_er_health_plan_t
        pipelined
        deterministic
    is
        l_record er_health_plan_t;
    begin
        for x in (
            select
                a.entrp_id,
                a.acc_num,
                c.name                                  carrier_name,
                to_char(b.effective_date, 'MM/DD/YYYY') effective_date,
                deductible,
                plan_type,
                pc_lookups.get_plan_type(plan_type)     plan_name,
                c.id                                    carrier_id,
                health_plan_id,
                b.status
            from
                account               a,
                employer_health_plans b,
                myhealthplan          c
            where
                    b.carrier_id = c.entrp_id
                and a.entrp_id = b.entrp_id
                and b.show_online_flag = 'Y'
                and a.entrp_id = p_entrp_id
                and b.effective_end_date is null
        ) loop
            l_record.entrp_id := x.entrp_id;
            l_record.acc_num := x.acc_num;
            l_record.carrier_name := x.carrier_name;
            l_record.effective_date := x.effective_date;
            l_record.deductible := x.deductible;
            l_record.plan_type := x.plan_type;
            l_record.plan_name := x.plan_name;
            l_record.carrier_id := x.carrier_id;
            l_record.health_plan_id := x.health_plan_id;
            l_record.status := x.status;
            pipe row ( l_record );
        end loop;
    end get_er_health_plan;

    function validate_ein (
        p_ein in varchar2
    ) return employer_ein_record_t
        pipelined
        deterministic
    is

        l_count           number;
        l_record          employer_ein_row_t;
        l_user_cnt        number := 0;
        l_cmp_er          varchar2(2) := 'N';
        l_active_acct     number;   -- Added by swamy for Ticket#8123
        l_active_user_cnt number;   -- Added by swamy for Ticket#8123
        l_active_users    number;   -- Added by swamy for Ticket#8123
        l_active_sa_cnt   number; -- Added by Joshi for 10430

    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Validate EIN', 'EIN# ' || p_ein);
    --Some ER have tax id in 8 digits.To handle those we add lpad
        select
            count(*)
        into l_count
        from
            enterprise a,
            account    b
        where
                lpad(
                    replace(a.entrp_code, '-'),
                    9,
                    0
                ) = replace(p_ein, '-')
            and a.en_code = 1
            and a.entrp_id = b.entrp_id;

        if l_count <> 0 then
      --If user exists then validate if he has online access
            select
                count(*)
            into l_user_cnt
            from
                online_users
            where
                replace(tax_id, '-') = replace(p_ein, '-');

            if l_user_cnt > 0 then --Has online access
	    /*
        l_record.error_flag    := 'O';
        l_record.EIN           := p_ein;
		*/  -- Commented by swamy for Ticket#8123
         -- START Added by swamy for Ticket#8123
         -- User should be allowed to reenroll with a different username/password only if the existing user status is inactive and all the accounts for that tax_id should be in closed status.
         -- below cursor to Check if any user exists with active status for that tax_id and has account status other than closed, that means user should not be allowed to reenroll with different username/password.
                for j in (
                    select
                        count(*) cnt
                    from
                        enterprise a,
                        account    b
                    where
                            lpad(
                                replace(a.entrp_code, '-'),
                                9,
                                0
                            ) = replace(p_ein, '-')
                        and a.entrp_id = b.entrp_id
                        and b.account_status <> '4'
                        and a.en_code = 1
                ) loop
                    l_active_acct := j.cnt;
                end loop;

                for k in (
                    select
                        count(*) cnt
                    from
                        online_users o
                    where
                            lpad(
                                replace(o.tax_id, '-'),
                                9,
                                0
                            ) = replace(p_ein, '-')
                        and o.user_status not in ( 'I', 'D' )
                ) loop    -- 'D' Added by Swamy for Ticket#8953, continuation of 8123
                    l_active_users := k.cnt;
                end loop;

                if
                    nvl(l_active_acct, 0) = 0
                    and nvl(l_active_users, 0) = 0
                then
                    l_record.error_flag := 'Y';
                    l_record.ein := p_ein;
                else
                    l_record.error_flag := 'O';
                    l_record.ein := p_ein;
                end if;
		 -- End of addition by swamy for ticket#8123
            else
                pc_log.log_error('PC_EMPLOYER_ENROLL.Validate EIN', 'EIN COUNT ' || l_count);
        --If EIN exist and no online access then validate if it is CMP employer
        --If yes then user should be allowed to create new account
                if validate_compliance_acct(p_ein) = 'Y' then --Only compliance acct.We allow user with flow
                    l_record.error_flag := 'Y';
                    l_record.ein := p_ein;
                else
          --User has another acct associated with compliance acct
                    l_record.error_flag := 'N';
                    l_record.ein := p_ein;
                    l_record.error_message := 'Employer with this EIN already exist';
                end if; --Compliance ER
            end if;   --Online access loop
        else
      /* New User */
            l_record.error_flag := 'Y';
            l_record.ein := p_ein;
        end if;

       -- Added by Joshi for 10430.
        for u in (
            select
                count(*) cnt
            from
                online_users o
            where
                    lpad(
                        replace(o.tax_id, '-'),
                        9,
                        0
                    ) = replace(p_ein, '-')
                and o.user_status not in ( 'I', 'D' )
                and o.emp_reg_type = 2
        ) loop
            l_active_sa_cnt := u.cnt;
        end loop;

        if nvl(l_active_sa_cnt, 0) > 0 then
            l_record.active_sa_user_exists := 'Y';
        else
            l_record.active_sa_user_exists := 'N';
        end if;

        pipe row ( l_record );
    end validate_ein;

    function validate_user (
        p_user_name  in varchar2,
        p_password   in varchar2,
        p_email_addr in varchar2,
        p_tax_id     in varchar2
    ) return user_record_t
        pipelined
        deterministic
    is
        l_record      user_row_t;
        l_user_count  number;
        l_email_count number;
    begin
        l_record.error_flag := 'N';
        select
            count(*)
        into l_user_count
        from
            online_users
        where
            user_name = p_user_name;

        if l_user_count > 0 then
            l_record.error_message := 'Username '
                                      || p_user_name
                                      || ' not available';
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            pipe row ( l_record );
        end if;

        if check_user_name(p_user_name) = 'N' then
            l_record.error_message := 'The username cannot contain spaces or special characters.  It can only be letters or a combination of letters and numbers.'
            ;
      --PC_LOG.LOG_ERROR('USER_CREATION',L_error_message);
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            pipe row ( l_record );
        end if;

        if
            length(p_user_name) < 6
            and p_user_name is not null
        then
            l_record.error_message := 'Enter user name that is more than 6 character in length';
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            pipe row ( l_record );
        end if;

        if
            length(p_user_name) > 24
            and p_user_name is not null
        then
            l_record.error_message := 'Enter user name that is less than 24 character in length';
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            pipe row ( l_record );
        end if;

        if
            length(p_password) < 6
            and p_password is not null
        then
            l_record.error_message := 'Choose password that is more than 6 character in length';
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            l_record.password := p_password;
            pipe row ( l_record );
        end if;

        if
            length(p_password) > 25
            and p_password is not null
        then
            l_record.error_message := 'Choose password that is less than 24 character in length';
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            l_record.password := p_password;
            pipe row ( l_record );
        end if;

        if instr(
            nls_lower(p_password),
            nls_lower(p_user_name)
        ) != 0 then
            l_record.error_message := 'User name and Password cannot be same';
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            l_record.password := p_password;
            pipe row ( l_record );
        end if;

        if p_password is not null then
            if regexp_like(p_password, '^.*[^A-Z,0-9].*$') then
                null;
            else
                l_record.error_message := 'Password value must include a mix of letters, numbers';
                l_record.error_flag := 'Y';
                l_record.user_name := p_user_name;
                l_record.password := p_password;
                pipe row ( l_record );
            end if;
        end if;

        if pc_users.is_email_registered(p_tax_id, p_email_addr) = 'Y' then
            l_record.error_message := 'This email ID('
                                      || p_email_addr
                                      || ') has already been registered';
            l_record.error_flag := 'Y';
            l_record.user_name := p_user_name;
            l_record.password := p_password;
            pipe row ( l_record );
        else
            null;
        end if;

        if l_record.error_flag = 'N' then
            pipe row ( l_record );
        end if;
    end validate_user;

    procedure insert_employer_online (
        p_name                         in varchar2,
        p_ein_number                   in varchar2,
        p_address                      in varchar2,
        p_city                         in varchar2,
        p_state                        in varchar2,
        p_zip                          in varchar2,
        p_contact_name                 in varchar2,
        p_phone                        in varchar2,
        p_fax_id                       in varchar2,
        p_email                        in varchar2,
        p_card_allowed                 in varchar2,
        p_management_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_account_type                 in varchar2,
        p_office_phone_no              in varchar2, /* 7857 Joshi% */
        p_referral_url                 in varchar2 default null, /* 9049 Jagadeesh% */
        p_referral_code                in varchar2 default null, /* 9049 Jagadeesh% */
        p_enrolled_by                  in number default null,     ----9141 added by rprabu on 30/07/2020
        p_enrolle_type                 in varchar2 default 'E',    ----9141 added by rprabu on 30/07/2020
        p_industry_type                in varchar2,                 ----9141 added by rprabu on 30/07/2020
        p_user_id                      in number, ---Ticket 9392 rprabu
        p_salesrep_flag                in varchar2, /*Ticket#11509*/
        p_salesrep_name                in varchar2, /*Ticket#11509*/
        p_salesrep_id                  in number,                --- Added by Jaggi #11629
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    ) is

        l_sqlerrm              varchar2(3200);
        l_pers_id              number;
        l_acc_id               number;
        l_bank_acct_id         number;
        l_transaction_id       number;
        l_action               varchar2(255);
        l_setup_error exception;
        l_create_error exception;
        l_return_status        varchar2(30) := 'S';
        l_error_message        varchar2(3200);
        l_acc_num              varchar2(30);
        l_entrp_id             number;
        l_user_id              number;
        l_count                number := 0;
        l_exist                varchar2(2) := 'N';
        l_create               varchar2(10) := 'N';
        l_account_type         varchar2(10);
        l_batch_number         number;
        l_broker_id            account.broker_id%type;
        l_effective_date       varchar2(20);
        l_sales_team_member_id number;
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE', 'Inserting Enroll');

  --Ticket#7016
        generate_batch_number(
            pc_entrp.get_entrp_id_from_ein_act(p_ein_number, p_account_type),
            p_account_type,
            null,
            l_batch_number
        );
        create_employer_staging(
            p_name                         => p_name,
            p_ein_number                   => p_ein_number,
            p_address                      => p_address,
            p_city                         => p_city,
            p_state                        => p_state,
            p_zip                          => p_zip,
            p_contact_name                 => p_contact_name,
            p_phone                        => p_phone,
            p_email                        => p_email,
            p_card_allowed                 => null,
            p_management_account_user_name => p_management_account_user_name,
            p_management_account_password  => p_management_account_password,
            p_password_question            => p_password_question,
            p_password_answer              => p_password_answer,
            p_account_type                 => p_account_type,
            p_fax_id                       => p_fax_id,
            p_batch_number                 => l_batch_number,
            p_office_phone_no              => p_office_phone_no, /* 7857 */
            p_salesrep_flag                => p_salesrep_flag, /*Ticket#11509*/
            p_salesrep_name                => p_salesrep_name, /*Ticket#11509*/
            x_enrollment_id                => x_enrollment_id,
            x_error_message                => x_error_message,
            x_return_status                => l_return_status
        );
            ---------9141 done by rprabu on 30/07/2020
        update employer_online_enrollment
        set
            industry_type = p_industry_type
        where
            enrollment_id = x_enrollment_id;

        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER', 'x_enrollment_id ' || x_enrollment_id);
        savepoint enroll;
        for x in (
            select
                *
            from
                employer_online_enrollment
            where
                enrollment_id = x_enrollment_id
        ) loop
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE', l_action);
            l_entrp_id := null;
            l_broker_id := 0;   -- Added by Swamy for Ticket#9617
            l_effective_date := to_char(sysdate, 'MM/DD/YYYY');   -- Added by Swamy for Ticket#9617
            begin
        -- Stacked Account Logic : Vanitha 01/25/2017
                for xx in (
                    select
                        'FSA'
                    from
                        dual
                    where
                        p_account_type in ( 'FSA', 'HRA' )
                    union
                    select
                        'HRA'
                    from
                        dual
                    where
                        p_account_type in ( 'FSA', 'HRA' )
                    union
                    select
                        p_account_type
                    from
                        dual
                ) loop
                    if l_entrp_id is null then
                        l_entrp_id := pc_entrp.get_entrp_id_from_ein_act(x.ein_number, p_account_type);
                    end if;
                end loop;

                if
                    p_account_type in ( 'FSA', 'HRA' )
                    and pc_account.is_stacked_account(l_entrp_id) = 'Y'
                then
                    update account
                    set
                        account_type = 'FSA'
                    where
                            account_type = 'HRA'
                        and entrp_id = l_entrp_id;

                end if;
        -- Added by Swamy for Ticket#9617
                if p_enrolle_type = 'BROKER' then
                    l_broker_id := p_enrolled_by;
                end if;

        -- end of stacked account logic
                if l_entrp_id is not null then
                    l_action := 'Employer Exist ';
           -- Commented by Joshi for EMployer rerigistration. -- 10430
          -- x_error_message := 'Employer already exist';
          -- RAISE l_create_error;
          -- Added by Joshi for 10430. incase of Inactive plan reregistration
         -- need to update enterprise table.
         -- Bug: 10654 and 10655.

                    pc_employer_enroll.update_employer(
                        p_entrp_id            => l_entrp_id,
                        p_name                => x.name,
                        p_ein_number          => x.ein_number,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zip                 => x.zip,
                        p_contact_name        => x.contact_name,
                        p_phone               => x.phone,
                        p_email               => x.email,
                        p_user_id             => p_user_id,
                        p_fax_id              => x.fax_no,                                                 -- Added by Joshi for 10430
                        p_office_phone_number => x.office_phone_number,   -- Added by Joshi for 10430
                        x_error_message       => x_error_message,
                        x_return_status       => x_return_status
                    );

                else
                    l_action := 'Creating Employer ';
                    pc_entrp.insert_enterprise(
                        p_name                => x.name,
                        p_ein_number          => x.ein_number,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zip                 => x.zip,
                        p_contact_name        => x.contact_name,
                        p_phone               => x.phone,
                        p_email               => x.email,
                        p_fee_plan_type       => x.fee_plan_type,
                        p_card_allowed        => x.debit_card_allowed,
                        p_office_phone_number => x.office_phone_number,
                        x_entrp_id            => l_entrp_id,
                        p_industry_type       => x.industry_type,      -----9141 rprabu 03/08/2020
                        p_fax_id              => x.fax_no,
                        x_error_status        => l_return_status,
                        x_error_message       => l_error_message
                    );

                    if l_return_status <> 'S' then
                        raise l_create_error;
                    end if;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE', 'l_entrp_id ' || l_entrp_id);
                    l_action := 'Creating Account';
                    pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE', l_action);
                    insert into account (
                        acc_id,
                        entrp_id,
                        acc_num,
                        plan_code,
                        start_date,
                        note,
                        fee_setup,
                        fee_maint,
                        reg_date,
                        pay_code,
                        pay_period,
                        account_status,
                        complete_flag,
                        account_type,
                        enrollment_source,
                        broker_id,
                        referral_url,  -- 9049 Jagadeesh
                        referral_code, -- 9049 Jagadeesh
                        enrolled_by,         ----9141 added by rprabu on 30/07/2020
                        enrolle_type,        ----9141 added by rprabu on 30/07/2020
                        created_by,             ----9392 added by rprabu on 30/10/2020
                        last_updated_by         ----9392  added by rprabu on 14/10/2020
                    ) values ( acc_seq.nextval,
                               l_entrp_id,
                               'G'
                               ||
                               case
                                   when p_account_type = 'HSA'
                                        and x.plan_code in ( 1, 2, 3 ) then
                                           substr(
                                               pc_account.generate_acc_num(x.plan_code,
                                                                           upper(p_state)),
                                               2
                                           )
                                   else
                                       pc_account.generate_acc_num(x.plan_code, null)
                               end,
                               x.plan_code,
                               sysdate,
                               'Online Enrollment',
                               case
                                   when p_account_type = 'HSA' then
                                       pc_plan.fsetup_online(0)
                                   else
                                       0
                               end,
                               case
                                   when p_account_type = 'HSA' then
                                       pc_plan.fmonth(x.plan_code) --- This plan code has to be hard coded
                                   else
                                       0
                               end,
                               sysdate,
                               x.fee_plan_type,
                               null ---x.er_contribution_frequency
                               ,
                               decode(p_enrolle_type, 'EMPLOYER', 3, 'GA', 9,
                                      'BROKER', 10) -- BROKER Added by Swamy for Ticket#9617 --------9141 added by rprabu on 18/08/2020
                                      ,
                               decode(p_account_type, 'LSA', 1, 0)  -- Added by Swamy for Ticket#10311



              --0,--Setup NOT complete           -- Commented by Swamy for Ticket#10311
                               ,
                               x.account_type,
                               'ONLINE',
                               0,
                               p_referral_url,
                               p_referral_code,
                               p_enrolled_by, ----9141 added by rprabu on 30/07/2020
                               p_enrolle_type,  ----9141 added by rprabu on 30/07/2020
                               p_user_id,              ----9392 added by rprabu on 30/10/2020
                               p_user_id                ----9392 added by rprabu on 30/10/2020
                                ) returning acc_id into l_acc_id;

                    select
                        acc_num
                    into l_acc_num
                    from
                        account
                    where
                        acc_id = l_acc_id;

                    if p_enrolle_type = 'BROKER' then   -- Added by Swamy for Ticket#9617

                        pc_sales_team.insert_broker_data(
                            p_broker_id      => p_enrolled_by,
                            p_entrp_id       => l_entrp_id,
                            p_pers_id        => null,
                            p_effective_date => l_effective_date,
                            p_user_id        => p_enrolled_by,
                            x_return_status  => l_return_status,
                            x_error_message  => l_error_message
                        );
                    end if;

                    update employer_online_enrollment
                    set
                        entrp_id = l_entrp_id,
                        acc_num = l_acc_num,
                        enrollment_status = 'S'
                    where
                        enrollment_id = x_enrollment_id;

                end if;

            exception
                when l_create_error then
                    x_error_message := l_action
                                       || ' '
                                       || x_error_message;
                    x_return_status := 'E';
                    update employer_online_enrollment
                    set
                        error_message = x_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                when others then
                    x_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    x_return_status := 'E';
                    update employer_online_enrollment
                    set
                        error_message = x_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;
        --  RAISE;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE', 'error in when others ' || sqlerrm);
                    dbms_output.put_line('error message ' || sqlerrm);
            end;
       -- Added by Jaggi #11629
            if p_salesrep_id is not null then
                pc_sales_team.upsert_sales_team_member(
                    p_entity_type           => 'SALES_REP',
                    p_entity_id             => p_salesrep_id,
                    p_mem_role              => 'PRIMARY',
                    p_entrp_id              => l_entrp_id,
                    p_start_date            => trunc(sysdate),
                    p_end_date              => null,
                    p_status                => 'A',
                    p_user_id               => p_user_id,
                    p_pay_commission        => null,
                    p_note                  => null,
                    p_no_of_days            => null,
                    px_sales_team_member_id => l_sales_team_member_id,
                    x_return_status         => x_return_status,
                    x_error_message         => x_error_message
                );
            end if;

        end loop;
    /* Create Online Users entry */
        if p_enrolle_type = 'EMPLOYER' then   ----9141 added by rprabu on 30/07/2020
            update account              ----9141 added by rprabu on 30/07/2020
            set
                enrolled_by = l_acc_id,
                enrolle_type = p_enrolle_type
            where
                acc_id = l_acc_id;

            l_action := 'Creating Management Account';
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE', l_action);
            begin

     /* commented by Joshi for 10430. For Inactive plans, registration.
     user should be allwoed to create when no speradmins active.
      SELECT 'Y', user_id   --9392 14/10/2020
      INTO l_create , l_user_id  --9392 14/10/2020
      FROM ONLINE_USERS
      WHERE REPLACE(tax_id,'-') = REPLACE(p_ein_number,'-')
        AND user_status NOT IN ('I','D')   -- Added by swamy for Ticket#8123, -- 'D' Added by Swamy for Ticket#8953, continuation of 8123
        AND EXISTS (SELECT '1' FROM account a,enterprise e WHERE e.entrp_code = p_ein_number AND a.account_status NOT IN ('1','2','5') AND a.entrp_id = e.entrp_id);   -- Added by swamy for Ticket#8123
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_create := 'N';
    END ;
    */

                if pc_employer_enroll_compliance.is_inactive_plan_exists(p_ein_number) = 'Y' then
                    select
                        'Y',
                        user_id   --9392 14/10/2020
                    into
                        l_create,
                        l_user_id  --9392 14/10/2020
                    from
                        online_users
                    where
                            replace(tax_id, '-') = replace(p_ein_number, '-')
                        and emp_reg_type = 2
                        and user_status not in ( 'I', 'D' )   -- Added by swamy for Ticket#8123, -- 'D' Added by Swamy for Ticket#8953, continuation of 8123
                        and exists (
                            select
                                '1'
                            from
                                account    a,
                                enterprise e
                            where
                                    e.entrp_code = p_ein_number
                                and a.account_status not in ( '1', '2', '5' )
                                and a.entrp_id = e.entrp_id
                        );   -- Added by swamy for Ticket#8123
                else
                    select
                        'Y',
                        user_id   --9392 14/10/2020
                    into
                        l_create,
                        l_user_id  --9392 14/10/2020
                    from
                        online_users
                    where
                            replace(tax_id, '-') = replace(p_ein_number, '-')
                        and user_status not in ( 'I', 'D' )   -- Added by swamy for Ticket#8123, -- 'D' Added by Swamy for Ticket#8953, continuation of 8123
                        and exists (
                            select
                                '1'
                            from
                                account    a,
                                enterprise e
                            where
                                    e.entrp_code = p_ein_number
                                and a.account_status not in ( '1', '2', '5' )
                                and a.entrp_id = e.entrp_id
                        );   -- Added by swamy for Ticket#8123
                end if;
            exception
                when no_data_found then
                    l_create := 'N';
            end;

            if l_create = 'N' then --only if user not created
      /*SELECT acc_num
      INTO l_acc_num
      FROM employer_online_enrollment
      WHERE REPLACE(ein_number,'-') = REPLACE(p_ein_number,'-');
      --and rownum < 2;
	  */  -- Commented by Swamy for Ticket#8123
	   -- Added below by swamy for ticket#8123
                for k in (
                    select
                        acc_num
                    from
                        employer_online_enrollment
                    where
                        replace(ein_number, '-') = replace(p_ein_number, '-')
                ) loop
                    l_acc_num := k.acc_num;
                    exit;
                end loop;

                pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE-Acc#', l_acc_num);
                pc_users.insert_users(
                    p_user_name     => p_management_account_user_name,
                    p_password      => p_management_account_password,
                    p_user_type     => 'E',
                    p_emp_reg_type  => 2 -- check if this is for management
                    ,
                    p_find_key      => l_acc_num,
                    p_email         => p_email,
                    p_pw_question   => p_password_question,
                    p_pw_answer     => p_password_answer,
                    p_tax_id        => p_ein_number,
                    x_user_id       => l_user_id,
                    x_return_status => l_return_status,
                    x_error_message => x_error_message
                );

            end if;

        end if;           ----9141 added by rprabu on 30/07/2020
 ----9392 14/10/2020
        if l_user_id is not null then
            update account
            set
                created_by = l_user_id,
                last_updated_by = l_user_id
            where
                acc_id = l_acc_id;

        end if;

        if l_return_status <> 'S' then
            x_return_status := 'E';
        end if;
    exception
        when others then
            x_return_status := 'E';
            x_error_message := x_error_message
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_EMPLOYER_ONLINE', 'error in when others ' || sqlerrm);
    end insert_employer_online;

    procedure create_employer_staging (
        p_name                         in varchar2,
        p_ein_number                   in varchar2,
        p_address                      in varchar2,
        p_city                         in varchar2,
        p_state                        in varchar2,
        p_zip                          in varchar2,
        p_contact_name                 in varchar2,
        p_phone                        in varchar2,
        p_fax_id                       in varchar2,
        p_email                        in varchar2,
        p_card_allowed                 in varchar2,
        p_management_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_account_type                 in varchar2,
        p_batch_number                 in varchar2,/*Ticket#7016 */
        p_office_phone_no              in varchar2,/*Ticket#7857  Joshi */
        p_salesrep_flag                in varchar2, /*Ticket#11509*/
        p_salesrep_name                in varchar2, /*Ticket#11509*/
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    ) is
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_EMPLOYER_STAGING', 'Inserting Enroll');
        insert into employer_online_enrollment (
            enrollment_id,
            name,
            ein_number,
            address,
            city,
            state,
            zip,
            contact_name,
            phone,
            fax_no,
            email,
            fee_plan_type,
            plan_code,
            management_account_user_name,
            management_account_password,
            password_question,
            password_answer,
            account_type,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            batch_number,  /*Ticket#7016 */
            office_phone_number, /* 7857*/
            salesrep_flag, /*Ticket#11509*/
            salesrep_name     /*Ticket#11509*/
        ) values ( mass_enrollments_seq.nextval,
                   p_name,
                   p_ein_number,
                   p_address,
                   p_city,
                   p_state,
                   p_zip,
                   p_contact_name,
                   p_phone,
                   p_fax_id,
                   p_email,
                   null --Fee plan Type
                   ,
                   case
                       when p_account_type = 'ERISA_WRAP' then
                           516
                       when p_account_type = 'FSA'        then
                           513
                       when p_account_type = 'HRA'        then
                           507
                       when p_account_type = 'COBRA'      then
                           514
                       when p_account_type = 'FORM_5500'  then
                           515
                       when p_account_type = 'POP'        then
                           511
                       when p_account_type = 'LSA'     -- Added by Swamy for Ticket#9912 on 10/08/2021
                               then
                           525
                       else
                           1
                   end,
                   p_management_account_user_name,
                   p_management_account_password,
                   p_password_question,
                   p_password_answer,
                   p_account_type,
                   sysdate,
                   421,
                   sysdate,
                   421,
                   p_batch_number,    /*Ticket#7016 */
                   p_office_phone_no, /* 7857 */
                   p_salesrep_flag, /*Ticket#11509*/
                   p_salesrep_name     /*Ticket#11509*/ ) returning enrollment_id into x_enrollment_id;

        x_return_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_EMPLOYER_STAGING', sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end create_employer_staging;

    procedure create_stacked_acct (
        p_ein_number     in varchar2,
        x_return_status  out varchar2,
        x_return_message out varchar2
    ) is
        l_exists number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_STACKED_ACCOUNT', 'Creating Stacked Acct');
        begin
            select
                count(*)
            into l_exists
            from
                employer_online_enrollment
            where
                    replace(ein_number, '-') = replace(p_ein_number, '-')
                and account_type in ( 'FSA', 'HRA' );

        exception
            when no_data_found then
                l_exists := 0;
        end;

        if l_exists = 2 then --Both FSA and HRA have been selected
            pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_STACKED_ACCOUNT', 'Stacked Account Exist');
            for x in (
                select
                    *
                from
                    employer_online_enrollment
                where
                        replace(ein_number, '-') = replace(p_ein_number, '-')
                    and account_type = 'HRA'
            ) loop
                delete from employer_online_enrollment
                where
                    enrollment_id = x.enrollment_id;

                delete from account
                where
                    acc_num = x.acc_num;

                delete from enterprise
                where
                    entrp_id = x.entrp_id;

            end loop;

        end if;

        x_return_status := 'S';
    exception
        when others then
            pc_log.log_error('Create Stacked Account', sqlerrm);
            x_return_status := 'E';
            x_return_message := sqlerrm;
    end create_stacked_acct;

    function validate_compliance_acct (
        p_ein in varchar2
    ) return varchar2 is
        l_cmp_er varchar2(10) := 'N';
        l_exist  varchar2(20) := 'N';
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Validate Compliance acct', 'EIN# ' || p_ein);
        for x in (
            select
                a.entrp_code
            from
                enterprise a,
                account    b
            where
                    replace(a.entrp_code, '-') = replace(p_ein, '-')
                and a.en_code = 1
                and a.entrp_id = b.entrp_id
                and b.account_type = 'CMP'
                and b.account_status <> '4'     -- Added by swamy for Ticket#8123
        ) loop
            if x.entrp_code is not null then
        --Check if compliance ER has other associated accts
                begin
                    select
                        'Y'
                    into l_exist
                    from
                        enterprise a,
                        account    b
                    where
                            replace(a.entrp_code, '-') = replace(x.entrp_code, '-')
                        and a.en_code = 1
                        and a.entrp_id = b.entrp_id
                        and account_type <> 'CMP'
                        and account_status <> '4'; -- Added by swamy for ticket#8123;
                exception
                    when no_data_found then
                        l_cmp_er := 'Y'; -- Only compliance acct
                        return ( l_cmp_er );
                end;

                if l_exist = 'Y' then
                    l_cmp_er := 'N'; --Compliance acct along with other acct ,then do not allow further
                else
                    l_cmp_er := 'Y';
                end if;

            end if;
        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL.Validate Compliance acct', 'Flag# ' || l_cmp_er);
        return ( l_cmp_er );
    end validate_compliance_acct;

    function get_company_name (
        p_ein_number in varchar2
    ) return varchar2 is
        l_name varchar2(100);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Get company name', 'In function');
        for x in (
            select distinct
                name
            from
                enterprise
            where
                    replace(entrp_code, '-') = replace(p_ein_number, '-')
                and en_code = 1     ---- Added By rprabu 07/09/2019  created task#382
        ) loop
            l_name := x.name;
        end loop;

        return l_name;
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.Get company name', sqlerrm);
            return ( null );
    end get_company_name;
/*Ticket#5862 */
/*Ticket#5862 */
    procedure update_pop_info (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_user_id        in number,
        p_source         in varchar2 default null    --Ticket#5020
        ,
        p_new_ben_pln_id in out varchar2             -- Added by Jaggi for Ticket#10431(Renewal Resubmit)
        ,
        x_er_ben_plan_id out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    ) is

        l_acc_id                number;
        l_return_status         varchar2(10);
        l_error_message         varchar2(1000);
        l_er_ben_plan_id        number;
        l_aff_entrp_id          number;
        l_ctrl_entrp_id         number;
        x_quote_header_id       number;
        l_acc_num               varchar2(100);
        l_bank_id               number;
        l_plan_name             varchar2(100);
        l_plan_type             varchar2(100);
    /*Tickjet#6702 */
      ----9141 rprabu 05/08/2020
        l_entity_type           varchar2(50);
        l_entity_id             number;
        l_enrolle_type          varchar2(50);
        l_enrolled_by           number;
        l_ga_broker_flg         varchar2(50);
        erreur exception;
    ----9141 rprabu 05/08/2020
        l_renewed_by            varchar2(30); -- Joshi 10431
        l_resubmit_flag         varchar2(1);
        l_ben_plan_id           number;
        l_inactive_plan_exist   varchar2(1);
        v_resubmit_flag         varchar2(1); -- Added by jaggi for Ticket#10431
        l_new_ben_pln_id        number;      -- Added by jaggi for Ticket#10431
        l_eligibility_id        number;      -- Added by swamy for Ticket#10431
        l_renewal_resubmit_flag varchar2(1); -- Added by jaggi for Ticket#10431
        l_account_type          varchar2(30); -- Added by jaggi for Ticket#10431
        l_bank_exist_flag       varchar2(1) := 'N';  -- Added by swamy for Ticket#10431
        l_broker_id             number;
        l_bank_name             user_bank_acct_staging.bank_name%type;          -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        l_bank_acc_type         user_bank_acct_staging.bank_acct_type%type;     -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        l_routing_number        user_bank_acct_staging.bank_routing_num%type;   -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        l_bank_acc_num          user_bank_acct_staging.bank_acct_num%type;      -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        l_authorize_req_id      number;
        l_sales_team_member_id  number;
        l_source                varchar2(100);
        l_acct_usage            varchar2(100);
        l_bank_count            integer;
        l_bank_status           varchar2(1);
        lc_source               varchar2(1);
        l_bank_acct_num         varchar2(20);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..ID', 'In Proc' || p_entrp_id);
        for x in (
            select
                *
            from
                online_compliance_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            l_bank_acct_num := null;  -- Added by Swamy for Ticket#12675
            l_bank_id := null;         -- Added by Swamy for Ticket#12675

            select
                acc_id,
                acc_num,
                enrolled_by,
                enrolle_type,
                resubmit_flag,
                renewal_resubmit_flag,
                account_type            -- 9141 rprabu 11/08/2020
            into
                l_acc_id,
                l_acc_num,
                l_enrolled_by,
                l_enrolle_type,
                l_resubmit_flag,
                l_renewal_resubmit_flag,
                l_account_type  -- 9141 rprabu 11/08/2020
            from
                account
            where
                entrp_id = p_entrp_id;

            l_inactive_plan_exist := nvl(
                pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                'N'
            );
            l_source := x.source;

     -- added by Jaggi #11629
            if x.salesrep_id is not null then
                pc_sales_team.upsert_sales_team_member(
                    p_entity_type           => 'SALES_REP',
                    p_entity_id             => x.salesrep_id,
                    p_mem_role              => 'PRIMARY',
                    p_entrp_id              => p_entrp_id,
                    p_start_date            => trunc(sysdate),
                    p_end_date              => null,
                    p_status                => 'A',
                    p_user_id               => p_user_id,
                    p_pay_commission        => null,
                    p_note                  => null,
                    p_no_of_days            => null,
                    px_sales_team_member_id => l_sales_team_member_id,
                    x_return_status         => l_return_status,
                    x_error_message         => x_error_message
                );
            end if;

      -- Added by Joshi #12279 
            if
                pc_account.get_broker_id(l_acc_id) = 0
                and nvl(p_source, 'ENROLLMENT') = 'ENROLLMENT'
            then
                for j in (
                    select
                        broker_id
                    from
                        online_users ou,
                        broker       b
                    where
                            user_id = p_user_id
                        and user_type = 'B'
                        and upper(tax_id) = upper(broker_lic)
                ) loop
                    update account
                    set
                        broker_id = j.broker_id
                    where
                        entrp_id = p_entrp_id;

                end loop;
            end if;

        -- Added by Joshi for 10431. delete the existing data
       -- before resubmission.
            if
                l_resubmit_flag = 'Y'
                and nvl(p_source, 'ENROLLMENT') = 'ENROLLMENT'
            then
                delete from enterprise
                where
                    entrp_id in (
                        select
                            entity_id
                        from
                            entrp_relationships
                        where
                                entrp_id = p_entrp_id
                            and entity_type = 'ENTERPRISE'
                            and relationship_type in ( 'AFFILIATED_ER', 'CONTROLLED_GROUP' )
                    )
                    and en_code in ( 10, 11 )
                    and entrp_code is null;

                delete from entrp_relationships
                where
                        entrp_id = p_entrp_id
                    and entity_type = 'ENTERPRISE'
                    and relationship_type in ( 'AFFILIATED_ER', 'CONTROLLED_GROUP' );
             -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
             -- user might update existing  contacts.
                for c in (
                    select
                        contact_id
                    from
                        contact_leads
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and account_type = 'POP'
                        and ref_entity_type = 'ONLINE_ENROLLMENT'
                ) loop
                    delete from contact
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and contact_id = c.contact_id;

                    delete from contact_role
                    where
                        contact_id = c.contact_id;

                end loop;

                update user_bank_acct
                set
                    status = 'I'
                where
                        acc_id = l_acc_id
                    and bank_account_usage = 'INVOICE';

                begin
              /* commented by Joshi for 12289
               SELECT ben_plan_id INTO l_ben_plan_id
                    FROM ben_plan_enrollment_Setup
                 WHERE acc_id = l_acc_id ;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_ben_plan_id := NULL ; */
                -- Added by Joshi for 12289. in case of inactive plan resubmit , there will be more than one ben plan records. 
                    select
                        bp.ben_plan_id
                    into l_ben_plan_id
                    from
                        ben_plan_enrollment_setup bp,
                        online_compliance_staging ocs,
                        compliance_plan_staging   cps
                    where
                            ocs.batch_number = p_batch_number
                        and ocs.entrp_id = p_entrp_id
                        and bp.entrp_id = ocs.entrp_id
                        and ocs.batch_number = cps.batch_number
                        and cps.ben_plan_id = bp.ben_plan_id;

                exception
                    when others then
                        l_ben_plan_id := null;
                end;

                if l_ben_plan_id is not null then
                    delete from ben_plan_enrollment_setup
                    where
                            acc_id = l_acc_id
                        and entrp_id = p_entrp_id
                        and ben_plan_id = l_ben_plan_id;

                end if;

            end if;
    -- code ends here Joshi 10431

            pc_log.log_error('x.AFFLIATED_DIFF_EIN  : ', x.affliated_diff_ein
                                                         || ' x.Affliated_Flag :='
                                                         || x.affliated_flag);

            update enterprise
            set
                state_of_org = x.state_of_org,
                entity_type = x.type_of_entity,
                company_tax = x.company_tax,         -- Added by jaggi ##9604
                no_of_eligible = x.no_of_eligible,
                no_of_ees = x.no_off_ees,
                state_main_office = x.state_main_office,   -- Added for Ticket#11037 by Swamy
                state_govern_law = x.state_govern_law,     -- Added for Ticket#11037 by Swamy
                entity_name_desc = x.entity_name_desc,   -- Added for Ticket#11037 by Swamy
                affliated_diff_ein = x.affliated_diff_ein,    -- Added for Ticket#11037 by Swamy
                affliated_flag = x.affliated_flag        -- Added for Ticket#11037 by Swamy;
            where
                entrp_id = p_entrp_id;

            if p_source = 'RENEWAL' then

        --In POP Renewal send invoice flag does not get updated from UI correctly.
                update contact_leads
                set
                    send_invoice = x.send_invoice
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = 'POP'
                    and ref_entity_type in ( 'BEN_PLAN_RENEWALS', 'ENTERPRISE' );

      -- Added by Joshi for 10430 and 10714.

                update enterprise_census a
                set
                    a.census_numbers = x.no_off_ees
                where
                        a.census_code = 'NO_OF_EMPLOYEES'
                    and a.entity_id = p_entrp_id
                    and a.last_update_date = (
                        select
                            max(last_update_date)
                        from
                            enterprise_census
                        where
                                census_code = 'NO_OF_EMPLOYEES'
                            and entity_id = a.entity_id
                            and entity_type = a.entity_type
                    );

        --In case user did not enter number of Eligible ees during enrollment ,then we add it here
                if sql%rowcount = 0 then
                    insert into enterprise_census values ( p_entrp_id,
                                                           'ENTERPRISE',
                                                           'NO_OF_EMPLOYEES',
                                                           x.no_off_ees,
                                                           sysdate,
                                                           p_user_id,
                                                           sysdate,
                                                           p_user_id,
                                                           null );

                end if;

       -- Start of Addition by Swamy for Ticket#7606
        /* Joshi. should update always latest record.   10714

            UPDATE ENTERPRISE_CENSUS
               SET census_numbers = X.no_of_eligible
             WHERE census_code    = 'NO_OF_ELIGIBLE'
               AND entity_id      = P_ENTRP_ID; */

       -- Added by Joshi for 10430 and 10714.

                update enterprise_census a
                set
                    a.census_numbers = x.no_of_eligible
                where
                        a.census_code = 'NO_OF_ELIGIBLE'
                    and a.entity_id = p_entrp_id
                    and a.last_update_date = (
                        select
                            max(last_update_date)
                        from
                            enterprise_census
                        where
                                census_code = 'NO_OF_ELIGIBLE'
                            and entity_id = a.entity_id
                            and entity_type = a.entity_type
                    );


     --In case user did not enter number of Eligible ees during enrollment ,then we add it here
                if
                    sql%rowcount = 0
                    and nvl(x.no_of_eligible, 0) <> 0
                then
                    insert into enterprise_census (
                        entity_id,
                        entity_type,
                        census_code,
                        census_numbers,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        ben_plan_id
                    ) values ( p_entrp_id,
                               'ENTERPRISE',
                               'NO_OF_ELIGIBLE',
                               x.no_of_eligible,
                               sysdate,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               null );

                end if;
           -- End of Addition by Swamy for Ticket#7606
            else
        --Update Enterprise Census
                insert into enterprise_census values ( p_entrp_id,
                                                       'ENTERPRISE',
                                                       'NO_OF_EMPLOYEES',
                                                       x.no_off_ees,
                                                       sysdate,
                                                       p_user_id,
                                                       sysdate,
                                                       p_user_id,
                                                       null );

         -- Start of Addition by Swamy for Ticket#7606
                if nvl(x.no_of_eligible, 0) <> 0 then
                    insert into enterprise_census (
                        entity_id,
                        entity_type,
                        census_code,
                        census_numbers,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        ben_plan_id
                    ) values ( p_entrp_id,
                               'ENTERPRISE',
                               'NO_OF_ELIGIBLE',
                               x.no_of_eligible,
                               sysdate,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               null );

                end if;
          -- End of Addition by Swamy for Ticket#7606

            end if;

            if p_source = 'RENEWAL' then
                for xx in (
                    select
                        *
                    from
                        enterprise_staging
                    where
                            batch_number = p_batch_number
                        and en_code = 10
                        and entity_type = 'BEN_PLAN_RENEWALS'
                ) loop
          /*Creating Affliated Employer */
                    if xx.name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            created_by,
                            creation_date,
                            entrp_code,         -- Start Added for Ticket#11037 by Swamy
                            entity_type,
                            entity_type_other,
                            address,
                            city,
                            state,
                            zip           -- END  of addition for Ticket#11037 by Swamy
                        ) values ( entrp_seq.nextval,
                                   10,
                                   xx.name,
                                   p_user_id,
                                   sysdate,
                                   xx.affliated_ein,              -- Start Added for Ticket#11037 by Swamy
                                   xx.affliated_entity_type,
                                   xx.affliated_entity_type_other,
                                   xx.affliated_address,
                                   xx.affliated_city,
                                   xx.affliated_state,
                                   xx.affliated_zip             -- END  of addition for Ticket#11037 by Swamy
                                    ) returning entrp_id into l_aff_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                            ,
                            p_entity_id     => l_aff_entrp_id                                          ---Affliated ER
                            ,
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'AFFILIATED_ER',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if; --Affliated Employer loop
                end loop;
        /*Control Group Data */
                for xx in (
                    select
                        *
                    from
                        enterprise_staging
                    where
                            batch_number = p_batch_number
                        and en_code = 11
                        and entity_type = 'BEN_PLAN_RENEWALS'
                ) loop
                    if xx.name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   11,
                                   xx.name,
                                   p_user_id,
                                   sysdate ) returning entrp_id into l_ctrl_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                            ,
                            p_entity_id     => l_ctrl_entrp_id               ---Cntrl Grp ER
                            ,
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'CONTROLLED_GROUP',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if; --Control Group loop
                end loop;

            else
        /*renewal Enrollment Id */
                for xx in (
                    select
                        *
                    from
                        enterprise_staging
                    where
                            batch_number = p_batch_number
                        and en_code = 10
                        and entity_type = 'ONLINE_ENROLLMENT'
                ) loop
          /*Creating Affliated Employer */
                    if xx.name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            created_by,
                            creation_date,
                            entrp_code,         -- Start Added for Ticket#11037 by Swamy
                            entity_type,
                            entity_type_other,
                            address,
                            city,
                            state,
                            zip           -- END  of addition for Ticket#11037 by Swamy
                        ) values ( entrp_seq.nextval,
                                   10,
                                   xx.name,
                                   p_user_id,
                                   sysdate,
                                   xx.affliated_ein,              -- Start Added for Ticket#11037 by Swamy
                                   xx.affliated_entity_type,
                                   xx.affliated_entity_type_other,
                                   xx.affliated_address,
                                   xx.affliated_city,
                                   xx.affliated_state,
                                   xx.affliated_zip             -- END  of addition for Ticket#11037 by Swamy
                                    ) returning entrp_id into l_aff_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id             ---Original ER(GPOP)
                            ,
                            p_entity_id     => l_aff_entrp_id        ---Affliated ER
                            ,
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'AFFILIATED_ER',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if; --Affliated Employer loop
                end loop;
        /*Control Group Data */
                for xx in (
                    select
                        *
                    from
                        enterprise_staging
                    where
                            batch_number = p_batch_number
                        and en_code = 11
                        and entity_type = 'ONLINE_ENROLLMENT'
                ) loop
                    if xx.name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   11,
                                   xx.name,
                                   p_user_id,
                                   sysdate ) returning entrp_id into l_ctrl_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                            ,
                            p_entity_id     => l_ctrl_entrp_id    ---Cntrl Grp ER
                            ,
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'CONTROLLED_GROUP',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if; --Control Group loop
                end loop;

            end if;
      -- Start of Addition by Swamy for Ticket#7799
            pc_log.log_error('update_pop_info,p_source ', p_source
                                                          || ' x.acct_payment_fees :='
                                                          || x.acct_payment_fees);
      -- For POP, the data is not populating into Account_Preference table, due to this the functionality of Ticket#7799 is broken.
            pc_account.upsert_acc_pref(
                p_entrp_id               => p_entrp_id,
                p_acc_id                 => l_acc_id,
                p_claim_pay_method       => null,
                p_auto_pay               => null,
                p_plan_doc_only          => null,
                p_status                 => 'A',
                p_allow_eob              => 'Y',
                p_user_id                => p_user_id,
                p_pin_mailer             => 'N',
                p_teamster_group         => 'N',
                p_allow_exp_enroll       => 'Y',
                p_maint_fee_paid         => null,
                p_allow_online_renewal   => 'Y',
                p_allow_election_changes => 'N',
                p_plan_action_flg        => 'Y',
                p_submit_election_change => 'Y',
                p_edi_flag               => 'N',
                p_vendor_id              => null,
                p_reference_flag         => null,
                p_allow_payroll_edi      => null,
                p_fees_paid_by           => x.acct_payment_fees    -- Added by Swamy for Ticket#11037
            );
       -- End of Addition by Swamy for Ticket#7799
            -- Start Added by swmay for ticket#10747
            if p_source = 'RENEWAL' then
                pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);
            end if;

      /*renewal and enrollment IF */
	-- Added by Swamy for Ticket#12675
            if upper(x.fees_payment_flag) = 'ACH' then    
	  /*Create Bank Info */
                if p_source = 'ENROLLMENT' then
                    lc_source := 'E';
                else
                    lc_source := 'R';
                end if;

                pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..ID calling populate_bank_Accounts', 'In Proc lc_source'
                                                                                                          || lc_source
                                                                                                          || 'l_renewal_resubmit_flag :='
                                                                                                          || l_renewal_resubmit_flag)
                                                                                                          ;
                pc_giact_validations.populate_bank_accounts(
                    p_batch_number  => p_batch_number,
                    p_entrp_id      => p_entrp_id,
                    p_product_type  => 'POP',
                    p_user_id       => p_user_id,
                    p_source        => lc_source,
                    x_bank_acct_id  => l_bank_id,
                    x_bank_status   => l_bank_status,
                    x_return_status => l_return_status,
                    x_error_message => l_error_message
                );

                pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..ID after calling populate_bank_Accounts', 'In Proc l_bank_id'
                                                                                                                || l_bank_id
                                                                                                                || 'l_bank_status :='
                                                                                                                || l_bank_status
                                                                                                                || 'l_return_status :='
                                                                                                                || l_return_status
                                                                                                                || ' l_error_message :='
                                                                                                                || l_error_message);

                if l_return_status <> 'S' then
                    raise erreur;
                end if;
                l_bank_acct_num := pc_user_bank_acct.get_bank_acct_num(l_bank_id);
                pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..ID after calling populate_bank_Accounts **1', 'In Proc l_bank_acct_num'
                                                                                                                    || l_bank_acct_num
                                                                                                                    || ' x.record_id :='
                                                                                                                    || x.record_id);

                update online_compliance_staging
                set
                    bank_acct_id = l_bank_id,
                    bank_acc_num = l_bank_acct_num
                where
                    record_id = x.record_id;

            end if;

    -- Commented below and added above by Swamy for Ticket#12675
     /* IF X.FEES_PAYMENT_FLAG = 'ACH' AND X.BANK_NAME IS NOT NULL THEN

        IF p_source          = 'RENEWAL' THEN
         PC_LOG.LOG_ERROR('update_pop_info,p_source ',p_source||' l_bank_id :='||l_bank_id);
          IF NVL(l_entity_type,'*') <> 'BROKER' THEN   -- Added by swmay for ticket#10747
             l_bank_exist_flag  := pc_user_bank_acct.check_bank_acct
                                          (p_entity_id      => l_acc_id
                                          ,p_entity_type    => 'ACCOUNT'
                                          ,p_bank_acct_type => X.Bank_Acc_Type
                                          ,p_routing_number => X.Routing_Number
                                          ,p_bank_acct_num  => X.Bank_Acc_Num
                                          ,p_bank_name      => X.Bank_Name
                                          ,p_bank_account_usage => 'INVOICE' );
          END IF;   -- Added by swmay for ticket#10747

                pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..l_bank_exist_flag: ' , l_bank_exist_flag  );

            IF l_bank_exist_flag = 'N'  THEN

              --Below for loop Added by Swamy for Ticket#10993(Dev Ticket#10747)
              FOR J IN ( SELECT Bank_Name
                               ,Bank_Acct_Type
                               ,bank_Routing_Num
                               ,Bank_Acct_Num
                          FROM USER_BANK_ACCT_STAGING
                         WHERE batch_number = p_batch_number
                           AND account_type = 'POP'
                           AND last_updated_by = p_user_id
                           AND validity = 'V'
                           AND error_status IS NULL) LOOP
                 l_Bank_Name := j.Bank_Name;
                 l_Bank_Acc_Type := j.Bank_Acct_Type;
                 l_Routing_Number := j.bank_Routing_Num;
                 l_Bank_Acc_Num := j.Bank_Acct_Num;
              END LOOP;

               PC_USER_BANK_ACCT.UPSERT_BANK_ACCT
               (p_acc_num 			 => l_acc_num ,
                p_display_name       => l_Bank_Name,
                P_Bank_Acct_Type 	 => l_Bank_Acc_Type,
                P_Bank_Routing_Num	 => l_Routing_Number,
                P_Bank_Acct_Num		 => l_Bank_Acc_Num,
                p_bank_name 		 => l_Bank_Name,
                p_user_id			 => p_user_id ,
                p_account_type       =>  'POP' ,
                x_bank_acct_id 		 => l_bank_id ,
                x_return_status 	=> l_return_status
               ,x_error_message => l_error_message );
            END IF;

        ELSE

      l_acct_usage :=  'INVOICE' ; 
            l_bank_count := 0 ;   
            IF UPPER(x.acct_payment_fees)= 'EMPLOYER'  THEN
                l_entity_id := l_acc_id;
                l_entity_type := 'ACCOUNT';
            ELSIF UPPER(x.acct_payment_fees) = 'BROKER'  THEN
                l_entity_id := pc_account.get_broker_id(l_acc_id);
                l_entity_type := 'BROKER';
            ELSIF UPPER( x.acct_payment_fees) = 'GA'  THEN
                l_entity_id := pc_account.get_ga_id(l_acc_id);
                l_entity_type := 'GA';
            END IF;

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_id: ',l_entity_id);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_type',l_entity_type);
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_acct_usage l',l_acct_usage);

            SELECT COUNT(*) INTO l_bank_count
               FROM bank_Accounts
             WHERE bank_routing_num = x.routing_number
                  AND bank_acct_num    = x.bank_acc_num
                  AND bank_name        = x.bank_name  
                  AND status           = 'A'
                  AND entity_id        = l_entity_id
                  AND bank_account_usage = l_acct_usage
                  AND entity_type      = l_entity_type ;

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_count l',l_bank_count); 

            IF l_bank_count = 0 THEN 
                -- fee bank details      
                pc_user_bank_acct.insert_bank_account(
                                 p_entity_id          => l_entity_id
                                ,p_entity_type        => l_entity_type
                                ,p_display_name       => x.bank_name  
                                ,p_bank_acct_type     => x.bank_acc_type 
                                ,p_bank_routing_num   => x.routing_number 
                                ,p_bank_acct_num      => x.bank_acc_num
                                ,p_bank_name          => x.bank_name 
                                ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                                ,p_user_id            => p_user_id
                                ,x_bank_acct_id       => l_bank_id
                                ,x_return_status      => l_return_status 
                                ,x_error_message      => l_error_message);    

                pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l', l_bank_id);      
            END IF;
        END IF;  
    END IF;
    */

        /* Create Plan Info */

            for y in (
                select
                    *
                from
                    compliance_plan_staging
                where
                    batch_number = p_batch_number
            ) loop
                if p_source = 'RENEWAL' then
                    if y.plan_type = 'COMP_POP' then
                        l_plan_name := 'Cafeteria Plan';
                        l_plan_type := 'COMP_POP_RENEW';
            /*Ticket#6702 */
                    else
                        l_plan_name := 'Basic Plan';
                        l_plan_type := 'BASIC_POP_RENEW';
            /*Ticket#6702 */
                    end if;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..ID', 'In Proc P_SOURCE'
                                                                               || p_source
                                                                               || 'l_renewal_resubmit_flag :='
                                                                               || l_renewal_resubmit_flag);
                    if
                        nvl(l_renewal_resubmit_flag, 'N') = 'Y'
                        and p_source = 'RENEWAL'
                    then   -- swamy 10431
         -- -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                        pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..ID calling delete ', 'In Proc P_NEW_BEN_PLN_ID '
                                                                                                   || p_new_ben_pln_id
                                                                                                   || 'l_renewal_resubmit_flag :='
                                                                                                   || l_renewal_resubmit_flag);
                        pc_web_compliance.delete_resubmit_data(
                            p_acc_id              => l_acc_id,
                            p_entrp_id            => p_entrp_id,
                            p_batch_number        => p_batch_number,
                            p_renewed_ben_plan_id => p_new_ben_pln_id,
                            p_ben_plan_id         => x_er_ben_plan_id,
                            p_account_type        => 'POP',
                            p_eligibility_id      => l_eligibility_id
                        );

                        l_new_ben_pln_id := p_new_ben_pln_id;
                        pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info..ID calling update ', 'In Proc P_NEW_BEN_PLN_ID '
                                                                                                   || p_new_ben_pln_id
                                                                                                   || 'p_batch_number :='
                                                                                                   || p_batch_number);
                        pc_benefit_plans.update_ben_plan_enrollment_setup(
                            p_ben_plan_id                 => p_new_ben_pln_id,
                            p_plan_start_date             => to_date(y.plan_start_date, 'mm/dd/yyyy'),
                            p_plan_end_date               => to_date(y.plan_end_date, 'mm/dd/yyyy'),
                            p_runout_period_days          => null,--P_RUNOUT_PRD     ,
                            p_runout_period_term          => null,--P_RUNOUT_TRM   ,
                            p_funding_options             => null,--P_FUNDING_OPTIONS   ,
                            p_rollover                    => null,--P_ROLLOVER   ,
                            p_new_hire_contrib            => null,--CASE WHEN P_NEW_HIRE = 'Y' THEN 'PRORATE' ELSE 'N' END   ,
                            p_last_update_date            => sysdate,
                            p_last_updated_by             => p_user_id,
                            p_effective_date              => to_date(x.effective_date, 'mm/dd/yyyy'),
                            p_minimum_election            => null,--P_MIN_ELECTION    ,
                            p_maximum_election            => null,--P_MAX_ELECTION     ,
                            p_grace_period                => null,--CASE WHEN P_GRACE = 'Y' THEN P_GRACE_days ELSE 0 END    ,
                            p_batch_number                => p_batch_number,
                            p_non_discrm_flag             => null,--P_NON_DISCM   ,
                            p_plan_docs_flag              => null,--P_PLAN_DOCS   ,
                            p_renewal_flag                => 'Y',
                            p_renewal_date                => sysdate,
                            p_open_enrollment_start_date  => null,--TO_DATE(P_ENRLMNT_START,'dd-mon-rrrr')     ,
                            p_open_enrollment_end_date    => null,--TO_DATE(P_ENRLMNT_ENDT, 'dd-mon-rrrr')    ,
                            p_eob_required                => null,--P_EOB_REQUIRED,
                            p_deduct_tax                  => null,--NVL(P_POST_TAX,'N'),
                            p_update_limit_match_irs_flag => null,--P_Update_limit_match_IRS_Flag,
                            p_pay_acct_fees               => x.acct_payment_fees,-- upper(P_PAY_ACCT_FEES),
                            p_source                      => p_source,
                            p_account_type                => 'POP',
                            p_fiscal_end_date             => x.fiscal_yr_end,
                            p_plan_name                   => l_plan_name,
                            p_plan_number                 => y.plan_number,
                            p_takeover                    => y.takeover_flag,
                            p_org_eff_date                => x.org_eff_date,
                            p_plan_type                   => l_plan_type,
                            p_short_plan_yr               => y.short_plan_yr_flag,
                            p_plan_doc_ndt_flag           => y.plan_doc_ndt_flag,
                            x_return_status               => l_return_status,
                            x_error_message               => l_error_message
                        );

                        if nvl(l_return_status, 'S') = 'E' then
                            raise erreur;
                        end if;
                        l_er_ben_plan_id := p_new_ben_pln_id;
          --Send Notifications using PC_NOTIFICATIONS
                        pc_notifications.notify_er_ren_decl_plan(
                            p_acc_id       => l_acc_id,
                            p_ename        => pc_entrp.get_entrp_name(p_entrp_id),
                            p_email        => pc_users.get_email_from_user_id(p_user_id),
                            p_user_id      => p_user_id,
                            p_entrp_id     => p_entrp_id,
                            p_ben_plan_id  => null,
                            p_ben_pln_name => 'POP',
                            p_ren_dec_flg  => 'R',
                            p_acc_num      => l_acc_num
                        );

                    else
                        pc_log.log_error(' **1 PC_EMPLOYER_ENROLL.update_POP_info..ID calling update ', 'In Proc X.fiscal_yr_end '
                                                                                                        || x.fiscal_yr_end
                                                                                                        || 'p_batch_number :='
                                                                                                        || p_batch_number);

                        pc_employer_enroll.update_plan_info(
                            p_entrp_id             => p_entrp_id,
                            p_fiscal_end_date      => x.fiscal_yr_end, /*Ticket#7135 */
                            p_plan_type            => l_plan_type      /*Ticket#6702 */,
                            p_eff_date             => x.effective_date,/*Ticket#7135 */
                            p_org_eff_date         => x.org_eff_date,/*Ticket#7135 */
                            p_plan_start_date      => y.plan_start_date,/*Ticket#7135 */
                            p_plan_end_date        => y.plan_end_date,/*Ticket#7135 */
                            p_takeover             => y.takeover_flag,
                            p_user_id              => p_user_id,
                            p_short_plan_yr        => y.short_plan_yr_flag,
                            p_plan_number          => y.plan_number,
                            p_plan_name            => l_plan_name,
                            p_wrap_opt_flg         => null, -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                            p_erissa_erap_doc_type => null,-- Added by Joshi for 7791.
                            x_er_ben_plan_id       => x_er_ben_plan_id,
                            x_error_status         => l_return_status,
                            x_error_message        => l_error_message
                        );

       -- Added by Joshi for 10431
                        l_er_ben_plan_id := x_er_ben_plan_id;
                        update compliance_plan_staging
                        set
                            ben_plan_id = l_er_ben_plan_id
                        where
                            plan_id = y.plan_id;

         		 /*Update renewal date for renewed record.Ticket#7148 */
                        if y.plan_type = 'COMP_POP' then  -- Added By Rprabu 03/06/2019 For Ticket #7872 at renewal time

                            update ben_plan_enrollment_setup
                            set
                                renewal_date = sysdate,
                                non_discrm_flag = decode(y.plan_doc_ndt_flag, 'Y', 'Y', 'N'),-- Added By Rprabu 03/06/2019  For Ticket#7832
                                plan_docs_flag = 'Y', -- Added By Rprabu 03/06/2019 For Ticket#7832
                                renewal_flag = 'Y',
                                short_plan_yr_flag = y.short_plan_yr_flag,  -- Swamy #12057 26022024
                                short_plan_yr_end_date = to_date(y.short_plan_yr_end_date, 'mm/dd/yyyy') -- Added by Joshi for 12135.
                            where
                                ben_plan_id = l_er_ben_plan_id;

                        else
                            update ben_plan_enrollment_setup -- Added By Rprabu 03/06/2019 For Ticket #7872 at renewal time
                            set
                                renewal_date = sysdate,
                                non_discrm_flag = 'N',
                                plan_docs_flag = 'N',
                                renewal_flag = 'Y',
                                short_plan_yr_flag = y.short_plan_yr_flag, -- Swamy #12057 26022024
                                short_plan_yr_end_date = to_date(y.short_plan_yr_end_date, 'mm/dd/yyyy') -- Added by Joshi for 12135.
                            where
                                ben_plan_id = l_er_ben_plan_id;

                        end if;
           --Insert into BEN PLAN RENEWALS
                        insert into ben_plan_renewals (
                            ben_plan_id,
                            acc_id,
                            plan_type,
                            start_date,
                            end_date,
                            pay_acct_fees,--Renewal Phase#2
                            created_by,
                            creation_date,
                            renewal_batch_number,
                            renewed_plan_id,
                            source
                        )--Renewal Phase#2.Populate renewed plan ID
                         values ( y.ben_plan_id,
                                   l_acc_id,
                                   y.plan_type,
                                   to_date(y.plan_start_date, 'mm/dd/yyyy'),/*Ticket#7315 */
                                   to_date(y.plan_end_date, 'mm/dd/yyyy'),
                                   x.acct_payment_fees,
                                   p_user_id,
                                   sysdate,
                                   p_batch_number,
                                   l_er_ben_plan_id,
                                   'ONLINE' );

                        pc_log.log_error('UPDATE_POP_INFO ', 'p_source := '
                                                             || p_source
                                                             || ' l_entity_type :='
                                                             || l_entity_type);
                        if
                            p_source = 'RENEWAL'
                            and l_entity_type = 'BROKER'
                        then -- Added by Swamy for Ticket#10747
              --Send Notifications using PC_NOTIFICATIONS
                            pc_notifications.notify_broker_ren_decl_plan(
                                p_acc_id       => l_acc_id,
                                p_user_id      => p_user_id,
                                p_entrp_id     => p_entrp_id,
                                p_ben_pln_name => 'POP',
                                p_ren_dec_flg  => 'R',
                                p_acc_num      => l_acc_num
                            );
                        end if;
          --Send Notifications using PC_NOTIFICATIONS
                        pc_notifications.notify_er_ren_decl_plan(
                            p_acc_id       => l_acc_id,
                            p_ename        => pc_entrp.get_entrp_name(p_entrp_id),
                            p_email        => pc_users.get_email_from_user_id(p_user_id),
                            p_user_id      => p_user_id,
                            p_entrp_id     => p_entrp_id,
                            p_ben_plan_id  => null,
                            p_ben_pln_name => 'POP',
                            p_ren_dec_flg  => 'R',
                            p_acc_num      => l_acc_num
                        );

                    end if;  --  Added by Swamy for Ticket#10431
                else   -- Enrollment
		        ---    Added for the Ticket #8494 by rprabu on 17/12/2019
                    update account_preference
                    set
                        fees_paid_by = upper(x.acct_payment_fees)
                    where
                        entrp_id = p_entrp_id;

                    pc_log.log_error('Plan Created', 'Before Plan Creation');
                    if y.takeover_flag = 'N' then  --New POP

                        pc_employer_enroll.update_plan_info(
                            p_entrp_id             => p_entrp_id,
                            p_fiscal_end_date      => x.fiscal_yr_end,/*Ticket#7135 */
                            p_plan_type            => y.plan_type,
                            p_eff_date             => x.effective_date,
                            p_org_eff_date         => x.org_eff_date,
                            p_plan_start_date      => y.plan_start_date,
                            p_plan_end_date        => y.plan_end_date,
                            p_takeover             => y.takeover_flag,
                            p_user_id              => p_user_id,
                            p_short_plan_yr        => y.short_plan_yr_flag,
                            p_plan_number          => y.plan_number,
                            p_plan_name            => l_plan_name,        -- added by Jaggi #10430 on 11/15/2021
                            p_wrap_opt_flg         => null,				-- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                            p_erissa_erap_doc_type => null,				-- Added by Joshi for 7791.
                            x_er_ben_plan_id       => l_er_ben_plan_id,
                            x_error_status         => l_return_status,
                            x_error_message        => l_error_message
                        );
                    else                                                                                           --Restatement swap the eff and org dates
                        pc_employer_enroll.update_plan_info(
                            p_entrp_id             => p_entrp_id,
                            p_fiscal_end_date      => x.fiscal_yr_end,/*Ticket#7135 */
                            p_plan_type            => y.plan_type,
                            p_eff_date             => x.eff_date_sterling,
                            p_org_eff_date         => x.org_eff_date,
                            p_plan_start_date      => y.plan_start_date,
                            p_plan_end_date        => y.plan_end_date,
                            p_takeover             => y.takeover_flag,
                            p_user_id              => p_user_id,
                            p_short_plan_yr        => y.short_plan_yr_flag,
                            p_plan_number          => y.plan_number,
                            p_plan_name            => l_plan_name,       	-- added by Jaggi #10430 on 11/15/2021
                            p_wrap_opt_flg         => null, 				-- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                            p_erissa_erap_doc_type => null,				-- Added by Joshi for 7791.
                            x_er_ben_plan_id       => l_er_ben_plan_id,
                            x_error_status         => l_return_status,
                            x_error_message        => l_error_message
                        );
                    end if; --Take Over

			 --Added by Joshi for 10431

                    update compliance_plan_staging
                    set
                        ben_plan_id = l_er_ben_plan_id
                    where
                        plan_id = y.plan_id;

         --- For enrollment time, NDT and plan docs flag value..
          -- Added By Rprabu 30/05/2019 For Ticket#7832
                    if y.plan_type = 'COMP_POP' then 		 -- Added By Rprabu 30/05/2019 For Ticket #7872  Renewal Date Removed Here For  Ticket #7886
                        update ben_plan_enrollment_setup
                        set
                            non_discrm_flag = decode(y.plan_doc_ndt_flag, 'Y', 'Y', 'N'),-- Added By Rprabu 30/05/2019 For Ticket#7832
                            plan_docs_flag = 'Y',
                            short_plan_yr_flag = y.short_plan_yr_flag,  -- Swamy #12057 26022024
                            short_plan_yr_end_date = to_date(y.short_plan_yr_end_date, 'mm/dd/yyyy'), -- Added by Joshi for 12135.
                            original_eff_date = nvl(original_eff_date, to_date(x.effective_date, 'mm/dd/yyyy')) -- Added by Joshi for 12711 (for new enrollment original effectivdate should as effective date)   
                        where
                            ben_plan_id = l_er_ben_plan_id;

                    else
                        update ben_plan_enrollment_setup  -- Added By Rprabu 03/06/2019 For Ticket #7872 at renewal time
                        set
                            non_discrm_flag = 'N',
                            plan_docs_flag = 'N',
                            short_plan_yr_flag = y.short_plan_yr_flag,   -- Swamy #12057 26022024
                            short_plan_yr_end_date = to_date(y.short_plan_yr_end_date, 'mm/dd/yyyy'), -- Added by Joshi for 12135.
                            original_eff_date = nvl(original_eff_date, to_date(x.effective_date, 'mm/dd/yyyy')) -- Added by Joshi for 12711 (for new enrollment original effectivdate should as effective date) 
                        where
                            ben_plan_id = l_er_ben_plan_id;

                    end if;

                end if;
        /* renewal and Emrollemnt loop */
        /* Depending on BASIC or COMPREHENSIVE PLAN we insert fees in AR QUOTE headers table */
                pc_log.log_error('Here', 'Plan Craeted');
                for yy in (
                    select
                        *
                    from
                        ar_quote_headers_staging
                    where
                        batch_number = p_batch_number
                ) loop
                    pc_web_compliance.insrt_ar_quote_headers(
                        p_quote_name        => null,
                        p_quote_number      => null,
                        p_total_quote_price => yy.total_quote_price, ---Total Annual Fees
                        p_quote_date        => to_char(sysdate, 'mm/dd/rrrr'),
                        p_payment_method    => x.fees_payment_flag,
                        p_entrp_id          => p_entrp_id,
                        p_bank_acct_id      => 0,
                        p_ben_plan_id       => l_er_ben_plan_id,
                        p_user_id           => p_user_id,
                        p_quote_source      => 'ONLINE',
                        p_product           => 'POP',
                        x_quote_header_id   => x_quote_header_id,
                        x_return_status     => l_return_status,
                        x_error_message     => l_error_message
                    );
                end loop;

                pc_log.log_error('Plan ID Test', y.plan_id);
        /* Create Eligibility Data */
                insert into custom_eligibility_req
                    (
                        select
                            *
                        from
                            custom_eligibility_staging
                        where
                            entity_id = y.plan_id
                    );
        /*Plan Sponsor/Employer Contacts.Same as in ERISA */

                pc_log.log_error('Here', 'Plan Craeted..2');

      ---  IF p_source = 'RENEWAL' THEN     --- commented by rprabu for 7832 on 20/05/2019
                insert into plan_employer_contacts
                    (
                        select
                            *
                        from
                            plan_employer_contacts_stage
                        where
                                batch_number = p_batch_number
                            and entity_id = p_entrp_id
                    );
    ---    END IF;
                update custom_eligibility_req
                set
                    entity_id = l_er_ben_plan_id
                where
                    entity_id = y.plan_id;

                update plan_employer_contacts
                set
                    entity_id = l_er_ben_plan_id
                where
                    entity_id = p_entrp_id;

                update compliance_plan_staging
                set
                    ben_plan_id = l_er_ben_plan_id
                where
                    plan_id = y.plan_id;
        /* CREATE Benefit Codes data */
                for zz in (
                    select
                        *
                    from
                        benefit_codes_stage
                    where
                            entity_id = y.plan_id
                        and batch_number = p_batch_number
                ) loop
                    insert into benefit_codes (
                        benefit_code_id,
                        benefit_code_name,
                        entity_id,
                        entity_type,
                        description,
                        creation_date,
                        created_by
                    ) values ( zz.benefit_code_id,
                               zz.benefit_code_name,
                               l_er_ben_plan_id,
                               'BEN_PLAN_ENROLLMENT_SETUP',
                               zz.description,
                               sysdate,
                               p_user_id );

                end loop;
        --While ER registration we defaulted POP BAsic
        --Now if we enroll COMP POP , we should update correct plan code

        --Insert Contact
                if p_source = 'RENEWAL' then
                    insert into contact (
                        contact_id,
                        first_name,
                        last_name,
                        entity_id,
                        entity_type,
                        email,
                        status,
                        start_date,
                        last_updated_by,
                        created_by,
                        last_update_date,
                        creation_date,
                        can_contact,
                        contact_type,
                        user_id,
                        phone,
                        fax,
                        title,
                        account_type
                    )
                        select
                            contact_id,
                            substr(first_name,
                                   0,
                                   instr(first_name, ' ', 1, 1) - 1),
                            substr(first_name,
                                   instr(first_name, ' ', 1, 1) + 1,
                                   length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                            entity_id,
                            'ENTERPRISE',
                            email,
                            'A',
                            sysdate,
                            p_user_id,
                            p_user_id,
                            sysdate,
                            sysdate,
                            'Y',
                            contact_type,
                            null,
                            phone_num,
                            contact_fax,
                            job_title,
                            'POP'
                        from
                            contact_leads a
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'POP'
                            and ref_entity_type = 'BEN_PLAN_RENEWALS'
                            and not exists (
                                select
                                    1
                                from
                                    contact b
                                where
                                    a.contact_id = b.contact_id
                            )     -------- 7783 rprabu 31/10/2019
                            and lic_number is null;

                else

	 -- Added by Joshi for 10431. need to delete existing contacts and reinsert as in case of resubmit
     -- user might update existing  contacts.

                    delete from contact
                    where
                        contact_id in (
                            select
                                contact_id
                            from
                                contact_leads
                            where
                                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                                and account_type = 'POP'
                                and ref_entity_type = 'ONLINE_ENROLLMENT'
                        );

                    insert into contact (
                        contact_id,
                        first_name,
                        last_name,
                        entity_id,
                        entity_type,
                        email,
                        status,
                        start_date,
                        last_updated_by,
                        created_by,
                        last_update_date,
                        creation_date,
                        can_contact,
                        contact_type,
                        user_id,
                        phone,
                        fax,
                        title,
                        account_type
                    )
                        select
                            contact_id,
                            substr(first_name,
                                   0,
                                   instr(first_name, ' ', 1, 1) - 1),
                            substr(first_name,
                                   instr(first_name, ' ', 1, 1) + 1,
                                   length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                            entity_id,
                            'ENTERPRISE',
                            email,
                            'A',
                            sysdate,
                            p_user_id,
                            p_user_id,
                            sysdate,
                            sysdate,
                            'Y',
                            contact_type,
                            null,
                            phone_num,
                            contact_fax,
                            job_title,
                            'POP'
                        from
                            contact_leads a
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'POP'
                            and not exists (
                                select
                                    1
                                from
                                    contact b
                                where
                                    a.contact_id = b.contact_id
                            )     -------- 7783 rprabu 31/10/2019
                            and ref_entity_type = 'ONLINE_ENROLLMENT';

                end if;
    /** For all contacts added define contact roles etc */
    --Ticket#6555
                if p_source = 'RENEWAL' then -- If cond. added by Swamy wrt Ticket#6416
                    for xx in (
                        select
                            *
                        from
                            contact_leads a
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'POP'
                            and ref_entity_type = 'BEN_PLAN_RENEWALS'
                            and lic_number is null
                            and not exists (
                                select
                                    1
                                from
                                    contact_role b
                                where
                                    a.contact_id = b.contact_id
                            )     -------- 7783 rprabu 31/10/2019
                    ) -- And Cond. Added by Swamy wrt Ticket#6416
                     loop
                        insert into contact_role e (
                            contact_role_id,
                            contact_id,
                            role_type,
                            account_type,
                            effective_date,
                            created_by,
                            last_updated_by
                        ) values ( contact_role_seq.nextval,
                                   xx.contact_id,
                                   xx.account_type,
                                   xx.account_type,
                                   sysdate,
                                   p_user_id,
                                   p_user_id );
        --Especially for compliance we need to have both account type and role type defined
                        insert into contact_role e (
                            contact_role_id,
                            contact_id,
                            role_type,
                            account_type,
                            effective_date,
                            created_by,
                            last_updated_by
                        ) values ( contact_role_seq.nextval,
                                   xx.contact_id,
                                   xx.contact_type,
                                   xx.account_type,
                                   sysdate,
                                   p_user_id,
                                   p_user_id );
        --For all products we want Fee Invoice option also checked
                        if xx.contact_type = 'PRIMARY'
                        or xx.send_invoice = 1 then
                            insert into contact_role e (
                                contact_role_id,
                                contact_id,
                                role_type,
                                account_type,
                                effective_date,
                                created_by,
                                last_updated_by
                            ) values ( contact_role_seq.nextval,
                                       xx.contact_id,
                                       'FEE_BILLING',
                                       xx.account_type,
                                       sysdate,
                                       p_user_id,
                                       p_user_id );

                        end if;

                    end loop;
                else -- Start Addition by Swamy wrt Ticket#6416
                    for xx in (
                        select
                            *
                        from
                            contact_leads a
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'POP'
                            and ref_entity_type = 'ONLINE_ENROLLMENT'
                            and not exists (
                                select
                                    1
                                from
                                    contact_role b
                                where
                                    a.contact_id = b.contact_id
                            )     -------- 7783 rprabu 31/10/2019
                    ) loop
                        insert into contact_role e (
                            contact_role_id,
                            contact_id,
                            role_type,
                            account_type,
                            effective_date,
                            created_by,
                            last_updated_by
                        ) values ( contact_role_seq.nextval,
                                   xx.contact_id,
                                   xx.account_type,
                                   xx.account_type,
                                   sysdate,
                                   p_user_id,
                                   p_user_id );
        --Especially for compliance we need to have both account type and role type defined
                        insert into contact_role e (
                            contact_role_id,
                            contact_id,
                            role_type,
                            account_type,
                            effective_date,
                            created_by,
                            last_updated_by
                        ) values ( contact_role_seq.nextval,
                                   xx.contact_id,
                                   xx.contact_type,
                                   xx.account_type,
                                   sysdate,
                                   p_user_id,
                                   p_user_id );
        --For all products we want Fee Invoice option also checked
                        if xx.contact_type = 'PRIMARY'
                        or xx.send_invoice = 1 then
                            insert into contact_role e (
                                contact_role_id,
                                contact_id,
                                role_type,
                                account_type,
                                effective_date,
                                created_by,
                                last_updated_by
                            ) values ( contact_role_seq.nextval,
                                       xx.contact_id,
                                       'FEE_BILLING',
                                       xx.account_type,
                                       sysdate,
                                       p_user_id,
                                       p_user_id );

                        end if;

                    end loop;
                end if; -- End of addition for Ticket#6416
    --Insert int oSales team member table for Renewals
                if p_source = 'RENEWAL' then
                    for xx in (
                        select
                            *
                        from
                            contact_leads
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'POP'
                            and ref_entity_type = 'BEN_PLAN_RENEWALS'
                            and lic_number is not null
                    ) loop
                        pc_broker.insert_sales_team_leads(
                            p_first_name      => xx.first_name,
                            p_last_name       => null,
                            p_license         => xx.lic_number,
                            p_agency_name     => xx.first_name,
                            p_tax_id          => xx.entity_id,
                            p_gender          => null,
                            p_address         => null,
                            p_city            => null,
                            p_state           => null,
                            p_zip             => null,
                            p_phone1          => xx.phone_num,
                            p_phone2          => null,
                            p_email           => xx.email,
                            p_entrp_id        => p_entrp_id,
                            p_ref_entity_id   => l_er_ben_plan_id,
                            p_ref_entity_type => 'BEN_PLAN_RENEWALS',
                            p_lead_source     => 'RENEWAL',
                            p_entity_type     => xx.contact_type
                        );
                    end loop;
                end if;

                pc_log.log_error('UPDATE_POP_INFO **12 ', 'l_return_status := '
                                                          || l_return_status
                                                          || ' p_source :='
                                                          || p_source
                                                          || ' l_bank_status :='
                                                          || l_bank_status);

                if
                    l_return_status = 'S'
                    and p_source <> 'RENEWAL'
                then
              -- Added by Joshi for 10431
                    if l_inactive_plan_exist = 'I' then
                        pc_employer_enroll_compliance.update_inactive_account(l_acc_id, p_user_id);
                        update account
                        set
                            plan_code =
                                case
                                    when y.plan_type = 'COMP_POP' then
                                        512
                                    else
                                        plan_code
                                end
                        where
                            entrp_id = p_entrp_id;

                    else
                        update account
                        set
                            complete_flag = 1,
                            account_status = decode(l_bank_status, 'W', 11, 3),   -- Added by Swamy for Ticket#12675 --- 9386 of 9141  rprabu 31/08/2020
                            last_update_date = sysdate,
                            enrolled_date = sysdate,  -- 10431 Joshi
                            plan_code =
                                case
                                    when y.plan_type = 'COMP_POP' then
                                        512
                                    else
                                        plan_code
                                end,
                            submit_by = p_user_id
                        where
                            entrp_id = p_entrp_id;

                    end if;
                elsif
                    l_return_status = 'S'
                    and p_source = 'RENEWAL'
                then --while renewal if plan type changes, we need to update plan code also


                    for u in (
                        select
                            user_type
                        from
                            online_users
                        where
                            user_id = p_user_id
                    ) loop
                        if u.user_type = 'B' then
                            l_renewed_by := 'BROKER';
                        elsif u.user_type = 'G' then
                            l_renewed_by := 'GA';
                        else
                            l_renewed_by := 'EMPLOYER';
                        end if;
                    end loop;

                    update account
                    set
                        last_update_date = sysdate,
                        renewed_date = sysdate,             -- 10431 Joshi
                        renewed_by = l_renewed_by,    -- 10431 Joshi
                        plan_code =
                            case
                                when y.plan_type = 'COMP_POP'  then
                                    512
                                when y.plan_type = 'BASIC_POP' then
                                    511
                                else
                                    plan_code
                            end
                    where
                        entrp_id = p_entrp_id;

                    pc_log.log_error('UPDATE_POP_INFO **12.1 ', 'l_bank_id := '
                                                                || l_bank_id
                                                                || ' x.record_id :='
                                                                || x.record_id
                                                                || ' l_bank_status :='
                                                                || l_bank_status);
           --update ONLINE_COMPLIANCE_STAGING set bank_acct_id = l_bank_id where record_id = x.record_id;  Commented an moved to top by Swamy for Ticket#12675

                end if;

            end loop;
      /* Plan Loop */
        end loop;

         -- added by jaggi #11602
        pc_employer_enroll.upsert_rto_api_plan_doc(
            p_entrp_id      => p_entrp_id,
            p_acc_id        => l_acc_id,
            p_ben_plan_id   => l_er_ben_plan_id,
            p_batch_number  => p_batch_number,
            p_user_id       => p_user_id,
            p_source        => l_source,
            x_error_message => x_error_message,
            x_return_status => x_error_status
        );-- end here

             -- Added by Joshi  for Ticket #11086
        pc_employer_enroll_compliance.update_acct_pref(p_batch_number, p_entrp_id);
           -- For Basic plan shouldn't allow to show  allow_broker_plan_amend
        for x in (
            select
                *
            from
                ben_plan_enrollment_setup
            where
                    ben_plan_id = l_er_ben_plan_id
                and plan_type like '%BASIC%'
        ) loop
            update account_preference
            set
                allow_broker_plan_amend = 'N'
            where
                entrp_id = p_entrp_id;

        end loop;

        select
            nvl(broker_id, 0)
        into l_broker_id
        from
            table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

        if l_broker_id > 0 then
            l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_broker_id);
            pc_broker.create_broker_authorize(
                p_broker_id        => l_broker_id,
                p_acc_id           => l_acc_id,
                p_broker_user_id   => null,
                p_authorize_req_id => l_authorize_req_id,
                p_user_id          => p_user_id,
                x_error_status     => l_return_status,
                x_error_message    => l_error_message
            );

        end if;
      -- code ends for Ticket #11086.

    /* Main Loop */
	---9392 rprabu 07/10/2020
        if l_enrolle_type = 'GA' then
            ---9392 rprabu 07/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'POP',
                p_page_no       => '4',
                p_block_name    => 'AUTH_SIGN',
                p_validity      => 'V',
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            ---9392 rprabu 07/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'POP',
                p_page_no       => '4',
                p_block_name    => 'AGREEMENT',
                p_validity      => 'V',
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        end if;
		---9392 END  rprabu 07/10/2020
           -- Added by Swamy for Ticket#12499 
        update online_compliance_staging
        set
            submit_status = 'COMPLETED'
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

    /* Error Status and Message being sent out */
        x_error_status := l_return_status;
        x_error_message := l_error_message;
        pc_log.log_error('Plan Craeted', x_er_ben_plan_id);
    exception
        when erreur then      -- 9141 rprabu  05/08/2020
            rollback;
            x_error_status := 'E';
            x_error_message := x_error_message
                               || sqlcode
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info Erreur', 'Error '
                                                                          || x_error_message
                                                                          || ' := '
                                                                          || sqlerrm);
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info', sqlerrm);
            pc_log.log_error('PC_EMPLOYER_ENROLL.update_POP_info **1',
                             dbms_utility.format_error_backtrace());
            x_error_status := 'E';
            rollback;
    end update_pop_info;

    function get_salesrep return get_salesrep_row_t
        pipelined
        deterministic
    is
        l_record get_salesrep_row;
    begin
        for x in (
            select
                name,
                salesrep_id
            from
                salesrep a
            where
                    status = 'A'
                and end_date is null
                and role_type = 'SALESREP'
        ) loop
            l_record.salesrep_name := x.name;
            l_record.salesrep_id := x.salesrep_id;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end;

    function get_ga_data return get_ga_row_t
        pipelined
        deterministic
    is
        l_record get_ga_row;
    begin
        for x in (
            select
                agency_name,
                ga_id
            from
                general_agent
            where
                end_date is null
        ) loop
            l_record.ga_name := x.agency_name;
            l_record.ga_id := x.ga_id;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end;

    function get_pop_eligibility return get_pop_eligibility_row_t
        pipelined
        deterministic
    is
        l_record get_pop_eligibility_row;
    begin
        for x in (
            select
                lookup_code,
                description
            from
                lookups
            where
                lookup_name = 'POP_ELIGIBILITY'
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_pop_eligibility;

    function get_contact_type return get_contact_type_row_t
        pipelined
        deterministic
    is
        l_record get_contact_type_row;
    begin
        for x in (
            select
                meaning,
                lookup_code
            from
                lookups a
            where
                    a.lookup_name = 'CONTACT_TYPE'
                and lookup_code in ( 'PRIMARY', 'FEE_BILLING', 'BROKER', 'GA', 'EDI' )
        ) loop
            l_record.contact_type := x.meaning;
            l_record.contact_code := x.lookup_code;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end;

    procedure update_plan_info (
        p_entrp_id             in number,
        p_fiscal_end_date      in varchar2,
        p_plan_type            in varchar2,
        p_eff_date             in varchar2,
        p_org_eff_date         in varchar2,
        p_plan_start_date      in varchar2,
        p_plan_end_date        in varchar2,
        p_takeover             in varchar2,
        p_user_id              in number,
        p_is_5500              in varchar2 default null,
        p_plan_name            in varchar2 default null,
        p_plan_number          in varchar2 default null,
        p_coll_plan            in varchar2 default null,
        p_plan_fund_code       in varchar2 default null,
        p_plan_benefit_code    in varchar2 default null,
        p_grandfathered        in varchar2 default null,
        p_administered         in varchar2 default null,
        p_clm_lang_in_spd      in varchar2 default null,
        p_subsidy_in_spd_apndx in varchar2 default null,
        p_final_filing_flag    in varchar2 default null,
        p_wrap_plan_5500       in varchar2 default null,
        p_short_plan_yr        in varchar2 default null,
        p_wrap_opt_flg         in varchar2 default '1', -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_erissa_erap_doc_type in varchar2 default null, -- Added by Joshi for 7791.
        x_er_ben_plan_id       out number,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    ) is

        l_ben_plan_id     number;
        l_ben_plan_id_ndt number;
        l_acc_id          number;
        l_error_status    varchar2(10);
        l_error_message   varchar2(1000);
        l_plan_end_date   date;
    begin
    /* Create Plan Info */
        pc_log.log_error('PC_EMPLOYER_ENROLL.Update_plan_info', 'In Proc p_fiscal_end_date :=' || p_fiscal_end_date);
        select
            acc_id
        into l_acc_id
        from
            account
        where
                entrp_id = p_entrp_id
            and pers_id is null;

        pc_benefit_plans.insert_er_benefit_plan(
            p_acc_id               => l_acc_id,
            p_entrp_id             => p_entrp_id,
            p_effective_date       => p_eff_date,
            p_plan_type            => p_plan_type,
            p_fiscal_end_date      => p_fiscal_end_date,
            p_eff_date             => p_eff_date,
            p_org_eff_date         => p_org_eff_date,
            p_plan_start_date      => p_plan_start_date,
            p_plan_end_date        => p_plan_end_date,
            p_takeover             => p_takeover,
            p_user_id              => p_user_id,
            p_is_5500              => p_is_5500,
            p_plan_name            => p_plan_name,
            p_plan_number          => p_plan_number,
            p_coll_plan            => p_coll_plan,
            p_plan_fund_code       => p_plan_fund_code,
            p_plan_benefit_code    => p_plan_benefit_code,
            p_grandfathered        => p_grandfathered,
            p_administered         => p_administered,
            p_clm_lang_in_spd      => p_clm_lang_in_spd,
            p_subsidy_in_spd_apndx => p_subsidy_in_spd_apndx,
            p_final_filing_flag    => p_final_filing_flag,
            p_wrap_plan_5500       => p_wrap_plan_5500,
            p_wrap_opt_flg         => p_wrap_opt_flg, -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
            p_erissa_erap_doc_type => p_erissa_erap_doc_type, -- added by Joshi for 7791.
            x_ben_plan_id          => l_ben_plan_id,
            x_return_status        => l_error_status,
            x_error_message        => l_error_message
        );
    /*After introducing Cafetria plan, we are eliminating NDT plan Ticket#5862
    IF p_plan_type = 'COMP_POP' THEN  --Create an additional NDT entry
    --Duration of NDT plan should be one year if short plan yr is No else same as plan start and end dates
    IF p_short_plan_yr = 'N' THEN
    SELECT add_months(to_date(p_plan_start_date,'mm/dd/rrrr'),12)
    INTO l_plan_end_date
    FROM dual;
    ELSE
    SELECT to_date(p_plan_end_date,'mm/dd/rrrr')
    INTO l_plan_end_date
    FROM DUAL;
    END IF;
    PC_BENEFIT_PLANS.insert_ER_benefit_plan
    (p_acc_id           =>  l_acc_id
    ,p_entrp_id         =>  p_entrp_id
    , p_effective_date  =>  p_eff_date
    , p_plan_type       =>  'NDT'
    , p_fiscal_end_date      =>  p_fiscal_end_date
    , p_eff_date        =>  p_eff_date
    , p_org_eff_date    =>  p_org_eff_date
    , p_plan_start_date =>  p_plan_start_date
    , p_plan_end_date   =>  to_char(l_plan_end_date,'mm/dd/rrrr')
    , P_TAKEOVER        =>  P_TAKEOVER
    , p_user_id         =>  p_user_id
    , p_plan_name       =>  p_plan_name
    , p_plan_number     =>  p_plan_number
    , x_ben_plan_id     =>   l_ben_plan_id_ndt
    , x_return_status   =>  l_error_status
    , x_error_message   =>  l_error_message
    );
    UPDATE ben_plan_enrollment_setup
    set NON_DISCRM_FLAG = 'Y'
    where ben_plan_id = l_ben_plan_id_ndt;
    END IF;  --NDT Plan Type
    */
        x_er_ben_plan_id := l_ben_plan_id;
        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.Update_plan_info', sqlerrm);
            x_er_ben_plan_id := null;
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end update_plan_info;

-- Added p_entity_type,x_error_status,x_error_messagex_error_message by swamy wrt Development Of Erisa Enrollment Session To Staging Ticket#6294
    procedure insert_pop_eligib_req (
        p_entity_id       in number,
        p_user_id         in number,
        p_benefit_code_id in varchar2_tbl,
        p_entity_name     in varchar2_tbl,
        p_batch_number    in number
    ) is
    begin
        pc_log.log_error('INSERT_POP_ELIGIB_REQ', p_entity_id);
        delete from benefit_codes_stage
        where
            entity_id = p_entity_id;
    /*Modified for Ticket#5862 */
        for i in 1..p_benefit_code_id.count loop
            if p_benefit_code_id(i) is not null then
                insert into benefit_codes_stage (
                    entity_id,
                    entity_type,
                    benefit_code_id,
                    benefit_code_name,
                    description,
                    batch_number,
                    created_by
                ) values ( p_entity_id,
                           'POP_PLAN_SETUP',
                           benefit_code_seq.nextval,
                           p_benefit_code_id(i),
                           case
                               when p_entity_name(i) is null then
                                   (
                                       select
                                           description
                                       from
                                           lookups
                                       where
                                               lookup_code = p_benefit_code_id(i)
                                           and lookup_name = 'POP_PLAN_BENEFITS'    -- Added for Ticket#11037 by Swamy
                --AND lookup_name   ='POP_ELIGIBILITY'     -- Commented for Ticket#11037 by Swamy
                                   )
                               else
                                   p_entity_name(i)
                           end,
                           p_batch_number,
                           p_user_id );

            end if;
      /* Entity Name */
        end loop;
    /* Code Loop */
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_POP_ELIGIB_REQ', sqlerrm);
    end insert_pop_eligib_req;
/*Modified for Ticket#5862 */
    procedure insert_custom_eligib_req (
        p_min_age_req                                in varchar2,
        p_min_age                                    in varchar2,
        p_min_service_req                            in varchar2,
        p_no_of_hrs_current                          in varchar2,
        p_new_ee_month_servc                         in varchar2,
        p_plan_new_ee_join                           in varchar2,
        p_collective_bargain_flag                    in varchar2,
        p_union_ee_join_flag                         in varchar2,
        p_ee_exclude_plan_flag                       in varchar2,
        p_no_of_hrs_part_time                        in varchar2,
        p_exclude_seasonal_flag                      in varchar2,
        p_fmla_leave                                 in varchar2,
        p_fmla_tax                                   in varchar2,
        p_fmla_under_cobra                           in varchar2,
        p_fmla_return_leave                          in varchar2,
        p_fmla_contribution                          in varchar2,
        p_cease_covg_flag                            in varchar2,
        permit_partcp_eoy                            in varchar2,
        p_ee_rehire_plan                             in varchar2,
        p_ee_reemploy_plan                           in varchar2,
        p_automatic_enroll                           in varchar2,
        p_er_partcp_elect                            in varchar2,
        p_failure_plan_yr                            in varchar2,
        p_plan_admin                                 in varchar2,
        p_admin_contact_type                         in varchar2,
        p_admin_name                                 in varchar2,
        p_hsa_contrib                                in varchar2,
        p_max_contrib_amt                            in varchar2,
        p_matching_contrib                           in varchar2,
        p_non_elect_contrib                          in varchar2,
        p_percent_non_elect_amt                      in varchar2,
        p_other_non_elect_amt                        in varchar2,
        p_max_contrib_hsa                            in varchar2,
        p_other_max_contrib                          in varchar2,
        p_flex_credit_flag                           in varchar2,
        p_flex_credit_cash                           in varchar2,
        p_flex_cash_amt                              in varchar2,
        p_er_contrib_flex                            in varchar2,
        p_flex_contrib_amt                           in varchar2,
        p_other_flex_amt                             in varchar2,
        p_cash_out_amt                               in varchar2,
        p_max_flex_cash_out                          in varchar2,
        p_dollar_amt                                 in varchar2,
        p_other_max_cash_out                         in varchar2,
        p_amt_distrib                                in varchar2,
        p_min_contrib_hsa                            in varchar2,
        p_when_partcp_eoy                            in varchar2,
      /* Ticket#5020 */
        p_source                                     in varchar2,
        p_page_validity                              in varchar2,
        p_batch_number                               in number,
        p_entity_id                                  in number,
        p_user_id                                    in number,
        p_fmla_flag                                  in varchar2,--- Added by rprabu Ticket #7832
        p_flex_credit_5000a_flag                     in varchar2,--- Added by rprabu Ticket #7832
        p_flex_credits_er_contrib                    in varchar2,--- Added by rprabu Ticket #7832
        p_employee_elections                         in varchar2,               -- Start Added for Ticket#11037 by Swamy
        p_include_participant_election               in varchar2,
        p_change_status_below_30                     in varchar2,
        p_change_status_special_annual_enrollment    in varchar2,
        p_include_fmla_lang                          in varchar2,                 -- End of addition for Ticket#11037 by Swamy
        p_change_status_dependent_special_enrollment in varchar2,  -- Added by Swamy for Ticket#12131 14052024
        x_error_status                               out varchar2,
        x_error_message                              out varchar2
    ) is
        l_error_status  varchar2(100);
        l_error_message varchar2(1000);
        l_entity_id     number; --------9392 rprabu 12/10/2020
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_CUSTOM_ELIGIB_REQ', 'In Procedure' || p_entity_id);
	  -- added by Joshi for 9392. 10/12/2020. incase of indvidul section update
    -- GA enroll page, plan_id may be null.
        if p_entity_id is null then
            for x in (
                select
                    plan_id
                from
                    compliance_plan_staging
                where
                    batch_number = p_batch_number
            ) loop
                l_entity_id := x.plan_id;
            end loop;

        end if;
    -- Joshi code end here : 9392 below NVL also added.
        delete from custom_eligibility_staging
        where
            entity_id = nvl(p_entity_id, l_entity_id);
    /* Custom Elibility data */
        insert into custom_eligibility_staging (
            eligibility_id,
            min_age_req,
            min_age,
            min_service_req,
            no_of_hrs_current,
            new_ee_month_servc,
            plan_new_ee_join,
            collective_bargain_flag,
            union_ee_join_flag,
            ee_exclude_plan_flag,
            no_of_hrs_part_time,
            exclude_seasonal_flag,
            fmla_leave,
            fmla_tax,
            fmla_under_cobra,
            fmla_return_leave,
            fmla_contribution,
            cease_covg_flag,
            permit_partcp_eoy,
            ee_rehire_plan,
            ee_reemploy_plan,
            automatic_enroll,
            er_partcp_elect,
            failure_plan_yr,
            plan_admin,
            admin_contact_type,
            admin_name,
            hsa_contrib,
            max_contrib_amt,
            matching_contrib,
            non_elect_contrib,
            percent_non_elect_amt,
            other_non_elect_amt,
            max_contrib_hsa,
            other_max_contrib,
            flex_credit_flag,
            flex_credit_cash,
            flex_cash_amt,
            er_contrib_flex,
            flex_contrib_amt,
            other_flex_amt,
            cash_out_amt,
            max_flex_cash_out,
            dollar_amt,
            other_max_cash_out,
            amt_distrib,
            min_contrib_hsa,
            when_partcp_eoy,
            source,
            entity_id,
            fmla_flag,                          --- Added by rprabu Ticket #7832
            flex_credit_5000a_flag,             --- Added by rprabu Ticket #7832
            flex_credits_er_contrib,             --- Added by rprabu Ticket #7832
            created_by,
            creation_date,
            employee_elections,               -- Start Added for Ticket#11037 by Swamy
            include_participant_election,
            change_status_below_30,
            change_status_special_annual_enrollment,
            include_fmla_lang,                  -- End of addition for Ticket#11037 by Swamy
            change_status_dependent_special_enrollment   -- Added by Swamy for Ticket#12131 14052024       )
        ) values ( eligibility_seq.nextval,
                   p_min_age_req,
                   p_min_age,
                   p_min_service_req,
                   p_no_of_hrs_current,
                   p_new_ee_month_servc,
                   p_plan_new_ee_join,
                   p_collective_bargain_flag,
                   p_union_ee_join_flag,
                   p_ee_exclude_plan_flag,
                   p_no_of_hrs_part_time,
                   p_exclude_seasonal_flag,
                   p_fmla_leave,
                   p_fmla_tax,
                   p_fmla_under_cobra,
                   p_fmla_return_leave,
                   p_fmla_contribution,
                   p_cease_covg_flag,
                   permit_partcp_eoy,
                   p_ee_rehire_plan,
                   p_ee_reemploy_plan,
                   p_automatic_enroll,
                   p_er_partcp_elect,
                   p_failure_plan_yr,
                   p_plan_admin,
                   p_admin_contact_type,
                   p_admin_name,
                   p_hsa_contrib,
                   p_max_contrib_amt,
                   p_matching_contrib,
                   p_non_elect_contrib,
                   p_percent_non_elect_amt,
                   p_other_non_elect_amt,
                   p_max_contrib_hsa,
                   p_other_max_contrib,
                   p_flex_credit_flag,
                   p_flex_credit_cash,
                   p_flex_cash_amt,
                   p_er_contrib_flex,
                   p_flex_contrib_amt,
                   p_other_flex_amt,
                   p_cash_out_amt,
                   p_max_flex_cash_out,
                   p_dollar_amt,
                   p_other_max_cash_out,
                   p_amt_distrib,
                   p_min_contrib_hsa,
                   p_when_partcp_eoy,
                   p_source,
                   nvl(p_entity_id, l_entity_id), --NVL added by Joshi for 9392
                   p_fmla_flag,                 --- Added by rprabu Ticket #7832
                   p_flex_credit_5000a_flag,         --- Added by rprabu Ticket #7832
                   p_flex_credits_er_contrib,   --- Added by rprabu Ticket #7832
                   p_user_id,
                   sysdate,
                   p_employee_elections,               -- Start Added for Ticket#11037 by Swamy
                   p_include_participant_election,
                   p_change_status_below_30,
                   p_change_status_special_annual_enrollment,
                   p_include_fmla_lang,                -- End of addition for Ticket#11037 by Swamy
                   p_change_status_dependent_special_enrollment   -- Added by Swamy for Ticket#12131 14052024
                    );

        update online_compliance_staging
        set
            page2 = p_page_validity
        where
            batch_number = p_batch_number;
    --- 9392 rprabu 08/10/2020  Arrow Functionality
        for i in (
            select
                entrp_id
            from
                online_compliance_staging
            where
                batch_number = p_batch_number
        ) loop
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => i.entrp_id,
                p_account_type  => 'POP',
                p_page_no       => '1',
                p_block_name    => 'ELIGIBILITY_REQUIREMENT',
                p_validity      => p_page_validity,
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );
        end loop;
            	    --- END  9392 rprabu 08/10/2020  Arrow Functionality
        x_error_status := 'S';
        x_error_message := null;
    exception
        when others then
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_CUSTOM_ELIGIB_REQ exception', sqlerrm);
    end insert_custom_eligib_req;

    function get_cobra_srvc (
        p_covg_type in varchar2
    ) return cobra_record_t
        pipelined
        deterministic
    is
        l_record cobra_row_t;
        p_param  varchar2(500);
    begin
        if p_covg_type = 'MAIN_COBRA_SERVICE' then
            p_param := ' Employees';
        elsif p_covg_type = 'OPEN_ENROLLMENT_SUITE' then
            p_param := ' Eligible Employees';
        elsif p_covg_type in ( 'OPTIONAL_COBRA_SERVICE_CN', 'OPTIONAL_COBRA_SERVICE_CP' ) then
            p_param := ' Employees';
        end if;

        for x in (
            select
                a.rate_plan_id,
                rate_plan_detail_id                        as param_id,
                rate_plan_name                             as param,
                minimum_range,   --- 3933 rprabu 02/07/2019
                maximum_range,   --- 3933 rprabu 02/07/2019
                minimum_range
                || '-'
                || maximum_range
                || p_param                                 as range,
                ltrim(to_char(rate_plan_cost, '99999.99')) as fee
            from
                rate_plans       a,
                rate_plan_detail b
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_name = 'COBRA_STANDARD_FEES'
                and account_type = 'COBRA'
                and coverage_type = p_covg_type
            order by
                rate_plan_detail_id asc
        ) loop
            l_record.rate_plan_id := x.rate_plan_id;
            l_record.rate_plan_detail_id := x.param_id;
            l_record.rate_plan_name := x.param;
            l_record.min_range := x.minimum_range;   --- 3933 rprabu 02/07/2019
            l_record.max_range := x.maximum_range;   --- 3933 rprabu 02/07/2019
            l_record.range := x.range;
            l_record.fee := x.fee;
            l_record.error_flag := 'S';
            pipe row ( l_record );
        end loop;

    end get_cobra_srvc;

    function get_pop_pricing (
        p_rate_plan_name in varchar2,
        p_account_type   in varchar2
    ) return number is
        l_cost number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.get_pop_pricing', p_rate_plan_name);
        select
            b.rate_plan_cost
        into l_cost
        from
            rate_plans       a,
            rate_plan_detail b
        where
                a.rate_plan_id = b.rate_plan_id
            and a.account_type = p_account_type
            and upper(b.coverage_type) = upper(p_rate_plan_name);

        return nvl(l_cost, 0);
    exception
        when others then
            return 0;
    end get_pop_pricing;

    function get_cobra_plan_type return get_cobra_plan_type_row_t
        pipelined
        deterministic
    is
        l_record get_cobra_plan_type_row;
    begin
        for x in (
            select
                lookup_code,
                description
            from
                lookups
            where
                    lookup_name = 'COBRA_PLAN_TYPE'
      --and lookup_code <> 'COBRA'
                and lookup_code not in ( 'COBRA', 'COBRA_RENEW' )--Pier Ticket 3512 required this change.sk(02_22_2017)
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_cobra_plan_type;
/*
PROCEDURE create_cobra_plan(p_entrp_id IN NUMBER ,
p_Plan_name IN VARCHAR2,
p_insurance_company_name IN  VARCHAR2,
p_governing_state IN VARCHAR2,
p_plan_start_date IN VARCHAR2,
p_plan_end_date IN VARCHAR2,
p_plan_type IN VARCHAR2,
p_description IN VARCHAR2,
p_self_funded_flag IN vARCHAR2,
p_conversion_flag  IN VARCHAR2,
p_bill_cobra_premium_flag IN VARCHAR2,
p_coverage_terminate IN VARCHAR2,
p_age_rated_flag  IN VARCHAR2,
p_carrier_contact_name IN VARCHAR2,
p_Policy_number IN VARCHAR2,
p_plan_number IN VARCHAR2,
p_carrier_contact_email IN VARCHAR2,
p_carrier_phone_no IN VARCHAR2,
p_carrier_addr  IN VARCHAR2,
p_ee_premium  IN VARCHAR2,
p_ee_spouse_premium  IN VARCHAR2,
p_ee_child_premium  IN VARCHAR2,
p_ee_children_premium IN VARCHAR2,
p_ee_family_premium IN VARCHAR2,
p_spouse_premium    IN VARCHAR2,
p_child_premium  IN VARCHAR2,
p_spouse_child_premium IN VARCHAR2,
p_eff_date IN VARCHAR2,
p_user_id IN NUMBER,
p_salesrep_flag IN VARCHAR2,
p_salesrep_id IN VARCHAR2,
p_rate_plan_id IN VARCHAR2_TBL ,
p_rate_plan_detail_id IN VARCHAR2_TBL ,
p_list_price  IN VARCHAR2_TBL ,
p_tot_price IN NUMBER DEFAULT NULL,
p_payment_method IN VARCHAR2 DEFAULT NULL,
x_er_ben_plan_id OUT NUMBER,
x_error_status OUT VARCHAR2,
x_error_message OUT VARCHAR2)
IS
l_er_ben_plan_id NUMBER;
l_error_status VARCHAR2(100) := 'S';
l_error_message VARCHAR2(1000);
l_acc_id NUMBER;
X_QUOTE_HEADER_ID NUMBER;
l_exist  NUMBER := 0;
l_header_exist NUMBER := 0;
BEGIN
pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan','In Proc');
pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan',p_entrp_id);
SELECT acc_id
INTO l_acc_id
FROM account
where entrp_id = p_entrp_id;
BEGIN
SELECT count(*)
INTO l_exist
FROM BEN_PLAN_ENROLLMENT_SETUP
where acc_id = l_acc_id
and ben_plan_id_main IS NULL;
EXCEPTION
WHEN NO_DATA_FOUND THEN
l_exist := 0;
END ;
--For Multiple medical plans we create one entry in ben_plan setup table
IF l_exist = 0 THEN
PC_EMPLOYER_ENROLL.update_PLAN_INFO(p_entrp_id =>p_entrp_id
,p_fiscal_end_date => NULL
, p_plan_type => 'COBRA'
, p_eff_date =>p_eff_date
, p_org_eff_date => NULL
, p_plan_start_date =>p_plan_start_date
, p_plan_end_date =>p_plan_end_date
, P_TAKEOVER =>NULL
, p_user_id =>p_user_id
, x_er_ben_plan_id =>l_er_ben_plan_id
, x_error_status =>l_error_status
, x_error_message =>l_error_message
);
END IF;
INSERT INTO COBRA_PLAN_SETUP
(
cobra_plan_id  ,
Plan_name    ,
insurance_company_name    ,
governing_state     ,
plan_start_date   ,
plan_end_date      ,
plan_type        ,
description      ,
self_funded_flag  ,
conversion_flag   ,
bill_cobra_premium_flag   ,
coverage_terminate  ,
age_rated_flag  ,
entity_id      ,
carrier_contact_name  ,
Policy_number   ,
plan_number    ,
carrier_contact_email  ,
carrier_phone_no   ,
carrier_addr     ,
ee_premium     ,
ee_spouse_premium  ,
ee_child_premium  ,
ee_children_premium ,
ee_family_premium     ,
spouse_premium ,
chil_premium ,
spouse_child_premium   ,
salesrep_flag,
salesrep_id,
ben_plan_id,
CREATED_BY       ,
CREATION_DATE
)
VALUES
(
COBRA_PLAN_SEQ.NEXTVAL,
p_Plan_name ,
p_insurance_company_name,
p_governing_state ,
to_date(p_plan_start_date,'mm/dd/rrrr') ,
to_date(p_plan_end_date,'mm/dd/rrrr') ,
p_plan_type ,
p_description,
p_self_funded_flag,
p_conversion_flag ,
p_bill_cobra_premium_flag,
p_coverage_terminate ,
p_age_rated_flag ,
p_entrp_id ,
p_carrier_contact_name ,
p_Policy_number ,
p_plan_number  ,
p_carrier_contact_email ,
p_carrier_phone_no,
p_carrier_addr ,
p_ee_premium  ,
p_ee_spouse_premium,
p_ee_child_premium  ,
p_ee_children_premium,
p_ee_family_premium ,
p_spouse_premium   ,
p_child_premium      ,
p_spouse_child_premium,
p_salesrep_flag,
p_salesrep_id,
l_er_ben_plan_id,
p_user_id,
SYSDATE
) RETURNING cobra_plan_id  INTO  x_er_ben_plan_id ;
pc_log.log_error('In Proc','AFter Insert2');
--Inserting Plan Options and optional COBRA services
pc_log.log_error('In Proc','Insertig Fees and Services Price ID'||l_er_ben_plan_id );
--For a particular ER only one entry goes into AR_QUOTE_HEADERS
BEGIN
SELECT count(*)
INTO l_header_exist
FROM AR_QUOTE_HEADERS
where entrp_id = p_entrp_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
l_header_exist := 0;
END ;
IF l_header_exist = 0 THEN
PC_WEB_COMPLIANCE.INSRT_AR_QUOTE_HEADERS (P_QUOTE_NAME => NULL,
P_QUOTE_NUMBER =>  NULL    ,
P_TOTAL_QUOTE_PRICE => p_tot_price, ---Total Annual Fees
P_QUOTE_DATE => to_char(SYSDATE,'mm/dd/rrrr')  ,
P_PAYMENT_METHOD =>  p_payment_method,
P_ENTRP_ID  =>    p_entrp_id ,
P_BANK_ACCT_ID => 0   ,
P_BEN_PLAN_ID =>  l_er_ben_plan_id ,
P_USER_ID    =>   p_user_id   ,
P_QUOTE_SOURCE =>  'ONLINE' ,
P_PRODUCT    =>  'COBRA'   ,
X_QUOTE_HEADER_ID => x_quote_header_id,
X_RETURN_STATUS   => l_error_status ,
X_ERROR_MESSAGE  =>  l_error_message
) ;
pc_log.log_error('In Proc','Insertig Fees and Services detail..'||l_error_message);
FOR i in 1..p_rate_plan_id.COUNT
LOOP
IF p_rate_plan_detail_id(i) IS NOT NULL THEN
PC_WEB_COMPLIANCE.INSRT_AR_QUOTE_LINES (P_QUOTE_HEADER_ID => x_quote_header_id,
P_RATE_PLAN_ID => to_number(p_rate_plan_id(i)),
P_RATE_PLAN_DETAIL_ID =>to_number(p_rate_plan_detail_id(i)),
P_LINE_LIST_PRICE => to_number(p_list_price(i)),
P_NOTES => 'COBRA ONLINE ENROLLMENT',
P_USER_ID => p_user_id,
X_RETURN_STATUS => l_error_status,
X_ERROR_MESSAGE =>l_error_message);
END IF;
END LOOP;
END IF;--AR Quote HEaders
--Once Plan setup complete update teh complete flag as 1
-- IF l_error_status = 'S' THEN
UPDATE ACCOUNT
set complete_flag = 1
WHERE acc_id = l_acc_id ;
-- END IF;
x_error_status := l_error_status;
x_error_message := l_error_message;
x_er_ben_plan_id := l_er_ben_plan_id;
EXCEPTION
WHEN OTHERS THEN
pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan',SQLERRM);
x_error_status := 'E';
x_error_message := SQLERRM;
END create_cobra_plan;
*/
    function get_report_type return get_report_type_row_t
        pipelined
        deterministic
    is
        l_record get_report_type_row;
    begin
        for x in (
            select
                lookup_code,
                description
            from
                lookups
            where
                lookup_name = 'PLAN_NOTICE'
      --and lookup_code IN ('FINAL_REPORT','FIRST_REPORT','DFVC','FORM_5558','SHORT_PLAN_YR_REPORT','SPL_EXTN','AUTO_EXTN','AMENDED_REPORT')
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_report_type;

    function get_plan_fund_code return get_report_type_row_t
        pipelined
        deterministic
    is
        l_record get_report_type_row;
    begin
        for x in (
            select
                meaning description,
                lookup_code
            from
                lookups
            where
                lookup_name = 'PLAN_ARRANGEMENT'
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_plan_fund_code;

    function get_benefit_codes return get_report_type_row_t
        pipelined
        deterministic
    is
        l_record get_report_type_row;
    begin
        for x in (
            select
                meaning description,
                lookup_code
            from
                lookups
            where
                lookup_name = 'BENEFIT_CODES'
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.description;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_benefit_codes;

    procedure create_hsa_plan_old (
        p_entrp_id           in number,
        p_peo_ein            in number,
        p_plan_code          in number,
        p_mon_fees_paid_by   in varchar2, --If yes then 2 else 1
        p_ann_fees_paid_by   in varchar2, --If yes then 3 else 1
        p_debit_card_allowed in varchar2, --allowed is 1 else 0
        p_salesrep_id        in number,
        p_user_id            in number,
        p_subscribe_to_acn   in varchar2,   -- Added by Swamy for Ticket#6794(ACN Migration)
        x_error_status       out varchar2,
        x_error_message      out varchar2
    ) is
        l_acc_id        number;
        l_return_status varchar2(100);
        l_error_message varchar2(1000);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_HSA_PLAN', 'In Procedure');
        select
            acc_id
        into l_acc_id
        from
            account
        where
            entrp_id = p_entrp_id;

        update employer_online_enrollment
        set
            maint_fee_paid_by = p_mon_fees_paid_by,
            plan_code = p_plan_code,
            peo_ein = p_peo_ein,
            debit_card_allowed = p_debit_card_allowed
        where
            entrp_id = p_entrp_id;

        for x in (
            select
                *
            from
                employer_online_enrollment
            where
                entrp_id = p_entrp_id
        ) loop
            if x.peo_ein is not null then
                insert into entrp_relationships (
                    relationship_id,
                    entrp_id,
                    tax_id,
                    entity_id,
                    entity_type,
                    relationship_type,
                    start_date,
                    status,
                    note,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( entrp_relationship_seq.nextval,
                           x.entrp_id,
                           x.ein_number,
                           x.peo_ein,
                           'PEO',
                           'PEO_ER',
                           sysdate,
                           'A',
                           'Online Enrollment',
                           sysdate,
                           1,
                           sysdate,
                           1 );

            end if;

            update enterprise
            set
                card_allowed = p_debit_card_allowed
            where
                entrp_id = x.entrp_id;

            if p_salesrep_id is not null then
                update account
                set
                    salesrep_id = p_salesrep_id
                where
                    entrp_id = x.entrp_id;

                pc_employer_enroll.create_salesrep(
                    p_entrp_id      => x.entrp_id,
                    p_salesrep_id   => p_salesrep_id,
                    p_user_id       => null,
                    x_error_status  => l_return_status,
                    x_error_message => l_error_message
                );

            end if;

            if p_mon_fees_paid_by in ( 2, 1 ) then --Employer/employee will cover
        -- Joshi 5363 setup fee should be 0 for e-HSA plan.
                update account
                set
                    fee_maint = pc_plan.fmonth(p_plan_code),
                    plan_code = p_plan_code,
                    fee_setup =
                        case
                            when p_plan_code = 8 then
                                0
                            else
                                fee_setup
                        end
                where
                    entrp_id = x.entrp_id;
        --Update Account Preference Table
                pc_account.upsert_acc_pref(
                    p_entrp_id               => p_entrp_id,
                    p_acc_id                 => l_acc_id,
                    p_claim_pay_method       => null,
                    p_auto_pay               => null,
                    p_plan_doc_only          => null,
                    p_status                 => 'A',
                    p_allow_eob              => 'Y',
                    p_user_id                => p_user_id,
                    p_pin_mailer             => 'N',
                    p_teamster_group         => 'N',
                    p_allow_exp_enroll       => 'Y',
                    p_maint_fee_paid         => p_mon_fees_paid_by,
                    p_allow_online_renewal   => 'N',
                    p_allow_election_changes => 'N',
                    p_plan_action_flg        => 'Y',
                    p_submit_election_change => 'Y',
                    p_edi_flag               => 'N',
                    p_vendor_id              => null,
                    p_reference_flag         => null,
                    p_allow_payroll_edi      => null,
                    p_fees_paid_by           => null
                );    -- Added by Swamy for Ticket#11037
            end if;

            if p_ann_fees_paid_by in ( 2, 1 ) then --Employer/employee will cover
                update account
                set
                    fee_maint = pc_plan.fannual(p_plan_code),
                    plan_code = p_plan_code
          --Setup fee should not be charged for new plans
                    ,
                    fee_setup =
                        case
                            when p_plan_code in ( 5, 6, 7 ) then
                                0
                            else
                                fee_setup
                        end
                where
                    entrp_id = x.entrp_id;
        --Account Preference Table
                pc_account.upsert_acc_pref(
                    p_entrp_id               => p_entrp_id,
                    p_acc_id                 => l_acc_id,
                    p_claim_pay_method       => null,
                    p_auto_pay               => null,
                    p_plan_doc_only          => null,
                    p_status                 => 'A',
                    p_allow_eob              => 'Y',
                    p_user_id                => p_user_id,
                    p_pin_mailer             => 'N',
                    p_teamster_group         => 'N',
                    p_allow_exp_enroll       => 'Y',
                    p_maint_fee_paid         => p_ann_fees_paid_by,
                    p_allow_online_renewal   => 'N',
                    p_allow_election_changes => 'N',
                    p_plan_action_flg        => 'Y',
                    p_submit_election_change => 'Y',
                    p_edi_flag               => 'N',
                    p_vendor_id              => null,
                    p_reference_flag         => null,
                    p_allow_payroll_edi      => null,
                    p_fees_paid_by           => null
                );    -- Added by Swamy for Ticket#11037 );
            end if;

        end loop;

    -- Added by Swamy for Ticket#6794(ACN Migration)
        update account_preference
        set
            subscribe_to_acn = nvl(p_subscribe_to_acn, 'N')
        where
            acc_id = l_acc_id;

    --Once Plan setup complete update teh complete flag as 1
        update account
        set
            complete_flag = 1,
            last_update_date = sysdate
        where
            acc_id = l_acc_id;

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_HSA_PLAN', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end create_hsa_plan_old;

    procedure update_contact_info (
        p_contact_id      number,
        p_entrp_id        number,
        p_first_name      varchar2,
        p_email           varchar2,
        p_account_type    varchar2,
        p_contact_type    varchar2,
        p_user_id         varchar2,
        p_ref_entity_id   varchar2,
        p_ref_entity_type varchar2,
        p_send_invoice    varchar2,
        p_status          varchar2,
        p_phone_num       varchar2 default null,
        p_fax_no          varchar2 default null,
        p_job_title       varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        cnt              number;
        l_contact_id     number := p_contact_id; -- := P_CONTACT_ID added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        l_contact_exists number := 0;   ---7783 rprabu 31/10/2019
    begin
    -- L_CONTACT_ID := null;  -- Commented By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_CONTACT_INFO', 'P_CONTACT_ID' || p_contact_id);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_CONTACT_INFO', 'P_FIRST_NAME' || p_first_name);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_CONTACT_INFO', 'P_FIRST_NAME' || p_send_invoice);
    --IF  L_CONTACT_ID IS  NULL AND P_EMAIL IS NOT NULL  THEN  -- Commented  By Swamy Ticket#6294

        begin      ---7783 rprabu 31/10/2019
            select
                1
            into l_contact_exists
            from
                contact
            where
                    contact_id = l_contact_id
                and account_type = p_account_type;   -- Added by Swamy for Ticket#11533;
        exception
            when no_data_found then     --- Ticket #8326 rprabu 04/11/2019
                l_contact_exists := 0;
        end;

        if p_email is not null then -- Added By Swamy Ticket#6294
            if l_contact_id is null then
                l_contact_id := contact_seq.nextval;
        -- END IF;    -- Commented  By Swamy Ticket#6294
                pc_log.log_error('UPDATE_CONTACT_INFO', 'L_CONTACT_ID' || l_contact_id);
                insert into contact_leads (
                    contact_id,
                    entity_id,
                    entity_type,
                    first_name,
                    email,
                    account_type,
                    ref_entity_id,
                    ref_entity_type,
                    send_invoice,
                    contact_type,
                    updated,
                    user_id,
                    creation_date
                )
                    select
                        l_contact_id,
                        pc_entrp.get_tax_id(p_entrp_id),
                        'ENTERPRISE',
                        p_first_name,
                        p_email,
                        p_account_type,
                        p_ref_entity_id,
                        p_ref_entity_type,
                        p_send_invoice,
                        p_contact_type,
                        'N',
                        p_user_id,
                        sysdate
                    from
                        dual;

            end if; -- Added By Swamy Ticket#6294
      --Added contact Type and User ID for Online Portal
            if l_contact_exists = 0 then       --- 7783 rprabu 31/10/2019
                insert into contact (
                    contact_id,
                    first_name,
                    last_name,
                    entity_id,
                    entity_type,
                    email,
                    status,
                    start_date,
                    last_updated_by,
                    created_by,
                    last_update_date,
                    creation_date,
                    can_contact,
                    contact_type,
                    user_id,
                    phone,
                    fax,
                    title,
                    account_type
                )
                    select
                        contact_id,
                        substr(first_name,
                               0,
                               instr(first_name, ' ', 1, 1) - 1),
                        substr(first_name,
                               instr(first_name, ' ', 1, 1) + 1,
                               length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                        entity_id,
                        'ENTERPRISE',
                        email,
                        'A',
                        sysdate,
                        p_user_id,
                        p_user_id,
                        sysdate,
                        sysdate,
                        'Y',
                        contact_type,
                        null,
                        p_phone_num,
                        p_fax_no,
                        p_job_title,
                        p_account_type
                    from
                        contact_leads
                    where
                            contact_id = l_contact_id
                        and account_type = p_account_type;   -- Added by Swamy for Ticket#11533 (Sometimes in contact_leads table same contact_id is stored for different account type, so ora error during inserting into contact)
      --Especially for compliance we need to have both account type and role type defined
                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           l_contact_id,
                           p_account_type,
                           p_account_type,
                           sysdate,
                           p_user_id,
                           p_user_id );
      --Especially for compliance we need to have both account type and role type defined
      /*Ticket#6555 */
                insert into contact_role e (
                    contact_role_id,
                    contact_id,
                    role_type,
                    account_type,
                    effective_date,
                    created_by,
                    last_updated_by
                ) values ( contact_role_seq.nextval,
                           l_contact_id,
                           p_contact_type,
                           p_account_type,
                           sysdate,
                           p_user_id,
                           p_user_id );
      --For all products we want Fee Invoice option also checked
      --Ticket#6555
                if p_contact_type = 'PRIMARY'
                or p_send_invoice = 1 then
                    insert into contact_role e (
                        contact_role_id,
                        contact_id,
                        role_type,
                        account_type,
                        effective_date,
                        created_by,
                        last_updated_by
                    ) values ( contact_role_seq.nextval,
                               l_contact_id,
                               'FEE_BILLING',
                               p_account_type,
                               sysdate,
                               p_user_id,
                               p_user_id );

                end if;

            end if;        --- 7783 rprabu 31/10/2019
      /*Ticket#6555 */
        end if;

    -- Added by Swamy for Ticket#6794(ACN Migration)
        update acn_employer_migration
        set
            first_name = substr(first_name,
                                0,
                                instr(first_name, ' ', 1, 1) - 1),
            last_name = substr(first_name,
                               instr(first_name, ' ', 1, 1) + 1,
                               length(first_name) - instr(first_name, ' ', 1, 1) + 1)
        where
                nvl(first_name, '*') = '*'
            and nvl(last_name, '*') = '*'
            and entrp_code = pc_entrp.get_tax_id(p_entrp_id)
            and nvl(process_status, 'N') = 'N';

        x_return_status := 'S';
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_return_status := 'E';
            pc_log.log_error('UPDATE_CONTACT_INFO', 'Error ' || sqlerrm);
    end update_contact_info;

    procedure create_erisa_plan (
        p_entrp_id             in number,
        p_state_of_org         in varchar2,
        p_entity_type          in varchar2,
        p_entity_name          in varchar2,
        p_fiscal_end_date      in varchar2,
        p_aff_name             in varchar2_tbl,
        p_cntrl_grp            in varchar2_tbl,
        p_plan_name            in varchar2,
        p_plan_number          in varchar2,
        p_eff_date             in varchar2,
        p_org_eff_date         in varchar2,
        p_plan_start_date      in varchar2,
        p_plan_end_date        in varchar2,
        p_user_id              in number,
        p_no_of_ee             in number,
        p_no_of_elg_ee         in number,
        p_benefit_code_name    in varchar2_tbl,
        p_description          in varchar2_tbl,
        p_5500_filing          in varchar2,
        p_grandfathered        in varchar2,
        p_administered         in varchar2,
        p_clm_lang_in_spd      in varchar2,
        p_subsidy_in_spd_apndx in varchar2,
        p_takeover             in varchar2,
        p_plan_fund_code       in varchar2,
        p_plan_benefit_code    in varchar2,
        p_tot_price            in number,
        p_rate_plan_id         in varchar2_tbl,
        p_rate_plan_detail_id  in varchar2_tbl,
        p_list_price           in varchar2_tbl,
        p_payment_method       in varchar2,
        p_final_filing_flag    in varchar2,
        p_wrap_plan_5500       in varchar2,
        p_salesrep_id          in number,
        p_wrap_opt_flg         in varchar2, -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_erissa_erap_doc_type in varchar2, -- added By Joshi for 7791,
        x_er_ben_plan_id       out number,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    ) is

        l_aff_entrp_id    number;
        l_ctrl_entrp_id   number;
        l_return_status   varchar2(2) := 'S'; -- 'S' Added By Swamy Ticket#6294
        l_error_message   varchar2(1000);
        x_quote_header_id number := 0;
        l_array           wwv_flow_global.vc_arr2;
        l_er_ben_plan_id  number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_ERISA_PLAN', 'In Proc');
        update enterprise
        set
            state_of_org = p_state_of_org,
            entity_type = p_entity_type,
            no_of_eligible = p_no_of_elg_ee
        where
            entrp_id = p_entrp_id;


    --Update Enterprise Census
    /*INSERT
    INTO ENTERPRISE_CENSUS VALUES
      (
        p_entrp_id,
        'ENTERPRISE',
        'NO_OF_EMPLOYEES',
        p_no_of_ee,
        SYSDATE,
        p_user_id,
        SYSDATE,
        p_user_id,
        NULL
      );
      */  -- Commented above and added below by for Ticket#6493
 -- Added below insert statement by Swamy for Ticket#6493
        if nvl(p_no_of_ee, 0) <> 0 then
            insert into enterprise_census (
                entity_id,
                entity_type,
                census_code,
                census_numbers,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                ben_plan_id
            ) values ( p_entrp_id,
                       'ENTERPRISE',
                       'NO_OF_EMPLOYEES',
                       p_no_of_ee,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       null );

        end if;

        if nvl(p_no_of_elg_ee, 0) <> 0 then
            insert into enterprise_census (
                entity_id,
                entity_type,
                census_code,
                census_numbers,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                ben_plan_id
            ) values ( p_entrp_id,
                       'ENTERPRISE',
                       'NO_OF_ELIGIBLE',
                       p_no_of_elg_ee,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       null );

        end if;

  -- End of Addition by Swamy for Ticket#6493

        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_ERISA_PLAN', 'Census Data updated');
    /*Creating Affliated Employer */
        for i in 1..p_aff_name.count loop
            if p_aff_name(i) is not null then
                insert into enterprise (
                    entrp_id,
                    en_code,
                    name,
                    created_by,
                    creation_date
                ) values ( entrp_seq.nextval,
                           10,
                           p_aff_name(i),
                           p_user_id,
                           sysdate ) returning entrp_id into l_aff_entrp_id;
        --x_aff_entrp_id := l_entrp_id;
                pc_employer_enroll.create_enterprise_relation(
                    p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                    ,
                    p_entity_id     => l_aff_entrp_id                                          ---Affliated ER
                    ,
                    p_entity_type   => 'ENTERPRISE',
                    p_relat_type    => 'AFFILIATED_ER',
                    p_user_id       => p_user_id,
                    x_return_status => l_return_status,
                    x_error_message => l_error_message
                );

            end if; --Affliated Employer loop
        end loop;
    /*Control Group Data */
        for i in 1..p_cntrl_grp.count loop
            if p_cntrl_grp(i) is not null then
                insert into enterprise (
                    entrp_id,
                    en_code,
                    name,
                    created_by,
                    creation_date
                ) values ( entrp_seq.nextval,
                           11,
                           p_cntrl_grp(i),
                           p_user_id,
                           sysdate ) returning entrp_id into l_ctrl_entrp_id;

                pc_employer_enroll.create_enterprise_relation(
                    p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                    ,
                    p_entity_id     => l_ctrl_entrp_id                                         ---Cntrl Grp ER
                    ,
                    p_entity_type   => 'ENTERPRISE',
                    p_relat_type    => 'CONTROLLED_GROUP',
                    p_user_id       => p_user_id,
                    x_return_status => l_return_status,
                    x_error_message => l_error_message
                );

            end if; --Control Group loop
            l_return_status := 'S';
        end loop;

        if l_return_status = 'S' then
            pc_employer_enroll.update_plan_info(
                p_entrp_id             => p_entrp_id,
                p_fiscal_end_date      => p_fiscal_end_date,
                p_plan_type            => 'NEW',
                p_plan_name            => p_plan_name,
                p_eff_date             => p_eff_date,
                p_org_eff_date         => p_org_eff_date,
                p_plan_start_date      => p_plan_start_date,
                p_plan_end_date        => p_plan_end_date,
                p_takeover             => p_takeover,
                p_user_id              => p_user_id,
                p_plan_number          => p_plan_number,
                p_grandfathered        => p_grandfathered,
                p_administered         => p_administered,
                p_clm_lang_in_spd      => p_clm_lang_in_spd,
                p_subsidy_in_spd_apndx => p_subsidy_in_spd_apndx,
                p_is_5500              => p_5500_filing,
                p_plan_fund_code       => null,-- replaced p_plan_fund_code with null by swamy for ticket#6162
                p_plan_benefit_code    => p_plan_benefit_code,
                p_final_filing_flag    => p_final_filing_flag,
                p_wrap_plan_5500       => p_wrap_plan_5500,
                p_wrap_opt_flg         => p_wrap_opt_flg,                                                                                                                                                                                                                                                                                                                                                                                                                                       -- added by swamy ticket#6294
                p_erissa_erap_doc_type => p_erissa_erap_doc_type, -- Added by Joshi for 7791
                x_er_ben_plan_id       => l_er_ben_plan_id,
                x_error_status         => l_return_status,
                x_error_message        => l_error_message
            );
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_ERISA_PLAN', 'Plan Created');
        x_er_ben_plan_id := l_er_ben_plan_id;

    /* Assign Benefit Codes */
        if l_return_status = 'S' then
            pc_employer_enroll.insert_benefit_codes(x_er_ben_plan_id --ER plan ID
            , 'BEN_PLAN_ENROLLMENT_SETUP'                             --Entity Type
            , p_benefit_code_name, p_description, null,
                                                    null, null, p_user_id, l_return_status, x_error_message);
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_ERISA_PLAN', 'Benefit codes updated');
    /* Create Notices */

        l_array := apex_util.string_to_table(p_plan_fund_code, ':');
        if l_array.first is not null then
            for i in l_array.first..l_array.last loop
                pc_compliance.insert_plan_notices(
                    p_ben_plan_id => x_er_ben_plan_id,
                    p_report_type => l_array(i),
                    p_user_id     => p_user_id
                );
            end loop;
        end if;

    /* Create Additional Notices */
        l_array := apex_util.string_to_table(p_plan_benefit_code, ':');
        if l_array.first is not null then
            for i in l_array.first..l_array.last loop
                pc_compliance.insert_plan_notices(
                    p_ben_plan_id => x_er_ben_plan_id,
                    p_report_type => l_array(i),
                    p_user_id     => p_user_id
                );
            end loop;
        end if;

    /* Employee Census Information */
        if l_return_status = 'S' then
            pc_web_compliance.insrt_ar_quote_headers(
                p_quote_name        => null,
                p_quote_number      => null,
                p_total_quote_price => p_tot_price, ---Total Annual Fees
                p_quote_date        => to_char(sysdate, 'mm/dd/rrrr'),
                p_payment_method    => p_payment_method,
                p_entrp_id          => p_entrp_id,
                p_bank_acct_id      => 0,
                p_ben_plan_id       => x_er_ben_plan_id,
                p_user_id           => p_user_id,
                p_quote_source      => 'ONLINE',
                p_product           => 'ERISA',
                x_quote_header_id   => x_quote_header_id,
                x_return_status     => l_return_status,
                x_error_message     => l_error_message
            );

            for i in 1..p_rate_plan_id.count loop
                if p_rate_plan_detail_id(i) is not null then
                    pc_log.log_error('PC_EMPLOYER_ENROLL.AR LINES...', x_quote_header_id);
                    pc_web_compliance.insrt_ar_quote_lines(
                        p_quote_header_id     => x_quote_header_id,
                        p_rate_plan_id        => to_number(p_rate_plan_id(i)),
                        p_rate_plan_detail_id => to_number(p_rate_plan_detail_id(i)),
                        p_line_list_price     => to_number(p_list_price(i)),
                        p_notes               => 'ERISA ONLINE ENROLLMENT',
                        p_user_id             => p_user_id,
                        x_return_status       => l_return_status,
                        x_error_message       => l_error_message
                    );

                end if;
            end loop;

        end if; -- Status check

    /* Create Salesrep data  -- commented by Jaggi #11629 handling in final proc
    IF l_return_status = 'S' AND NVL(p_salesrep_id,0) <> 0 THEN -- and nvl(p_salesrep_id,0) <> 0 added by Swamy for Ticket#6294
      PC_EMPLOYER_ENROLL.create_salesrep( p_entrp_id => p_entrp_id ,p_salesrep_id => p_salesrep_id ,p_user_id => p_user_id , X_error_STATUS => l_return_status ,X_ERROR_MESSAGE =>l_error_message);
    END IF;
    */
        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_ERISA_PLAN STATUS', x_error_status);
        x_error_status := l_return_status;
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_ERISA_PLAN', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end create_erisa_plan;

    procedure insert_benefit_codes (
        p_entity_id     in varchar2 --er_ben_plan_id
        ,
        p_entity_type   in varchar2 --FORM_5500_ONLINE_ENROLLMENT
        ,
        p_code_name     in varchar2_tbl,
        p_description   in varchar2_tbl,
        p_er_contrib    in number default null,
        p_ee_contrib    in number default null,
        p_eligibility   in varchar2 default null,
        p_user_id       in number default null,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_benefit_code_count number := 0;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_BENEFIT_CODES', 'In Procedure');
        x_return_status := 'S';
        if p_code_name.count is not null then
            for i in 1..p_code_name.count loop
                insert into benefit_codes (
                    benefit_code_id,
                    benefit_code_name,
                    description,
                    entity_id,
                    entity_type,
                    eligibility,
                    er_cont_pref,
                    ee_cont_pref,
                    creation_date,
                    created_by,
                    last_updated_by,
                    last_update_date
                ) values ( benefit_code_seq.nextval,
                           p_code_name(i),
                           p_description(i),
                           p_entity_id,
                           p_entity_type,
                           p_eligibility,
                           p_er_contrib,
                           p_ee_contrib,
                           sysdate,
                           p_user_id,
                           p_user_id,
                           sysdate );

            end loop;
        end if;

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.INSERT_BENEFIT_CODES', sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_benefit_codes;

    procedure create_salesrep (
        p_entrp_id      in number,
        p_salesrep_id   in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
    begin
        insert into sales_team_member (
            sales_team_member_id,
            entity_type,
            entity_id,
            mem_role,
            emplr_id,
            start_date,
            end_date,
            status,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( sales_team_seq.nextval,
                   'SALES_REP',
                   p_salesrep_id,
                   'PRIMARY',
                   p_entrp_id,
                   sysdate,
                   null,
                   'A',
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id );

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLYER_ENROLL.Create_salesrep', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end create_salesrep;

    procedure create_aca_eligibility (
        p_ben_plan_id                 in number,
        p_aca_ale_flag                in varchar2,
        p_variable_hour_flag          in varchar2,
        p_intl_msrmnt_period          in number,
        p_intl_msrmnt_start_date      in varchar2,
        p_intl_admn_period            in varchar2, -- Replaced Number with Varchar2 by Swamy Erisa Ticket#6294
        p_stblty_period               in number,
        p_msrmnt_start_date           in varchar2,
        p_msrmnt_period               in number,
        p_msrmnt_end_date             in varchar2,
        p_admn_start_date             in varchar2,
        p_admn_period                 in number,
        p_admn_end_date               in varchar2,
        p_stblt_start_date            in varchar2,
        p_stblt_period                in number,
        p_stblt_end_date              in varchar2,
        p_irs_lbm_flag                in varchar2,
        p_mnthl_msrmnt_flag           in varchar2,
        p_same_prd_bnft_start_date    in varchar2,
        p_new_prd_bnft_start_date     in varchar2,
        p_user_id                     in number,
        p_eligibility                 in varchar2_tbl,
        p_er_contrib                  in varchar2_tbl,
        p_ee_contrib                  in varchar2_tbl,
        p_benefit_code_id             in varchar2_tbl,
        p_entrp_id                    in number,
        p_collective_bargain_flag     in varchar2 default 'N', -- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_intl_msrmnt_period_det      in varchar2 default null,
        p_fte_same_period_resume_date in varchar2 default 'N',
        p_fte_diff_period_resume_date in varchar2 default null,
        p_fte_hrs                     in varchar2 default null,
        p_fte_salary_msmrt_period     in varchar2 default null,
        p_fte_hourly_msmrt_period     in varchar2 default null,
        p_fte_other_msmrt_period      in varchar2 default null,
        p_fte_other_ee_detail         in varchar2 default null,
        p_fte_look_back               in varchar2 default null,
        p_fte_lkp_salary_msmrt_period in varchar2 default null,
        p_fte_lkp_hourly_msmrt_period in varchar2 default null,
        p_fte_lkp_other_msmrt_period  in varchar2 default null,
        p_fte_lkp_other_ee_detail     in varchar2 default null,
        p_fte_same_period_select      in varchar2 default null,
        p_fte_diff_period_select      in varchar2 default null,
        p_define_intl_msrmnt_period   in varchar2 default null, -- End By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is
        l_acc_id number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.ERISA_ACA_Eligibility', 'In Proc P_ACA_ALE_FLAG :='
                                                                     || p_aca_ale_flag
                                                                     || ' P_VARIABLE_HOUR_FLAG :='
                                                                     || p_variable_hour_flag);

    --  Rprabu 06/04/2020 Ticket#7873
        if p_collective_bargain_flag is not null then
            update ben_plan_enrollment_setup
            set
                is_collective_plan = p_collective_bargain_flag
            where
                ben_plan_id = p_ben_plan_id;

        end if;
         --  Rprabu 06/04/2020 Ticket#7873

    --Updated this for ticket#4407
        if
            p_aca_ale_flag = 'Y'
            and p_variable_hour_flag = 'Y'
        then
            pc_log.log_error('PC_EMPLOYER_ENROLL.ERISA_ACA_Eligibility', 'INSERT INTO ERISA_ACA_ELIGIBILITY' || p_ben_plan_id);
            insert into erisa_aca_eligibility (
                eligibility_id,
                ben_plan_id,
                aca_ale_flag,
                variable_hour_flag,
                intl_msrmnt_period,
                intl_msrmnt_start_date,
                intl_admn_period,
                stblty_period,
                msrmnt_start_date,
                msrmnt_period,
                msrmnt_end_date,
                admn_start_date,
                admn_period,
                admn_end_date,
                stblt_start_date,
                stblt_period,
                stblt_end_date,
                irs_lbm_flag,
                mnthl_msrmnt_flag,
                same_prd_bnft_start_date,
                new_prd_bnft_start_date,
                collective_bargain_flag, -- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                intl_msrmnt_period_det,
                fte_same_period_resume_date,
                fte_diff_period_resume_date,
                fte_hrs,
                fte_salary_msmrt_period,
                fte_hourly_msmrt_period,
                fte_other_msmrt_period,
                fte_other_ee_detail,
                fte_look_back,
                fte_lkp_salary_msmrt_period,
                fte_lkp_hourly_msmrt_period,
                fte_lkp_other_msmrt_period,
                fte_lkp_other_ee_detail,
                fte_same_period_select,
                fte_diff_period_select,
                define_intl_msrmnt_period, -- End Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( erisa_aca_seq.nextval,
                       p_ben_plan_id,
                       p_aca_ale_flag,
                       p_variable_hour_flag,
                       p_intl_msrmnt_period,
                       to_date(p_intl_msrmnt_start_date, 'mm/dd/rrrr'),
                       p_intl_admn_period,
                       p_stblty_period,
                       to_date(p_msrmnt_start_date, 'mm/dd/rrrr'),
                       p_msrmnt_period,
                       to_date(p_msrmnt_end_date, 'mm/dd/rrrr'),
                       to_date(p_admn_start_date, 'mm/dd/rrrr'),
                       p_admn_period,
                       to_date(p_admn_end_date, 'mm/dd/rrrr'),
                       to_date(p_stblt_start_date, 'mm/dd/rrrr'),
                       p_stblt_period,
                       to_date(p_stblt_end_date, 'mm/dd/rrrr'),
                       p_irs_lbm_flag,
                       p_mnthl_msrmnt_flag,
                       to_date(p_same_prd_bnft_start_date, 'mm/dd/rrrr'),
                       to_date(p_new_prd_bnft_start_date, 'mm/dd/rrrr'),
                       p_collective_bargain_flag -- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                       ,
                       p_intl_msrmnt_period_det,
                       p_fte_same_period_resume_date -- Date field altered to varchar2 field wrt Ticket#6663 by Swamy on 31/08/2018
                       ,
                       p_fte_diff_period_resume_date -- Date field altered to varchar2 field wrt Ticket#6663 by Swamy on 31/08/2018
                       ,
                       p_fte_hrs,
                       p_fte_salary_msmrt_period,
                       p_fte_hourly_msmrt_period,
                       p_fte_other_msmrt_period,
                       p_fte_other_ee_detail,
                       p_fte_look_back,
                       p_fte_lkp_salary_msmrt_period,
                       p_fte_lkp_hourly_msmrt_period,
                       p_fte_lkp_other_msmrt_period,
                       p_fte_lkp_other_ee_detail,
                       p_fte_same_period_select,
                       p_fte_diff_period_select,
                       p_define_intl_msrmnt_period -- End By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                       ,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

        end if;
    /* Update Eligibility and Contribution for benefit codes */
        if p_benefit_code_id.count is not null then --If user does not select any codes
            for i in 1..p_benefit_code_id.count loop
                pc_compliance.update_eligibility_detail(
                    p_benefit_code_id => p_benefit_code_id(i),
                    p_er_contrib      => p_er_contrib(i),
                    p_ee_contrib      => p_ee_contrib(i),
                    p_eligibility     => p_eligibility(i),
                    p_user_id         => p_user_id,
                    x_return_status   => x_error_status,
                    x_error_message   => x_error_message
                );
            end loop;
        end if;
    /* ERISA pLan and ACA eligibility data created . Now Update teh Account status to complete */
        select
            acc_id
        into l_acc_id
        from
            account
        where
            entrp_id = p_entrp_id;

        if x_error_status = 'S' then
            update account
            set
                complete_flag = 1,
                last_update_date = sysdate
            where
                acc_id = l_acc_id;

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.ERISA_ACA_Eligibility', 'end');
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.ERISA_ACA_Eligibility', 'In Others :=' || x_error_message);
    end create_aca_eligibility;

    procedure decline_enrollment (
        p_acc_id        in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.DECINE_ENROLLMENT', 'In Proc for Acct' || p_acc_id);
    /* When user declines enrollment ,we just update the decline date as SYSDATE. Account status remains 3 only  i.e pending activation */
        update account
        set
            decline_date = sysdate
        where
            acc_id = p_acc_id;

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.DECLINE_ENROLLMENT', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end decline_enrollment;

    procedure cr_existing_user_login (
        p_tax_id        in varchar2,
        p_account_type  in varchar2,
        p_user_id       in number, -----9392 rprabu 21/10/2020
        x_entrp_id      out number,
        x_error_message out varchar2,
        x_error_status  out varchar2
    ) is

        l_entrp_id      number;
        l_return_status varchar2(10);
        l_error_message varchar2(1000);
        l_plan_code     number;
        l_acc_id        number;
        l_enrollment_id number;
        l_batch_number  number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.CR_EXISTING_USER_LOGIN ', 'In Procedure' || p_tax_id);
        for x in (
            select
                *
            from
                enterprise
            where
                    entrp_code = p_tax_id
                and rownum < 2
        ) loop
            pc_entrp.insert_enterprise(
                p_name                => x.name,
                p_ein_number          => x.entrp_code,
                p_address             => x.address,
                p_city                => x.city,
                p_state               => x.state,
                p_zip                 => x.zip,
                p_contact_name        => x.entrp_contact,
                p_phone               => x.entrp_phones,
                p_email               => x.entrp_email,
                p_fee_plan_type       => null,
                p_card_allowed        => x.card_allowed,
                p_industry_type       => x.industry_type,      -----9141 rprabu 03/08/2020
                p_office_phone_number => x.office_phone_number,
                p_fax_id              => x.entrp_fax,
                x_entrp_id            => l_entrp_id,
                x_error_status        => l_return_status,
                x_error_message       => l_error_message
            );
      -- Added by Joshi for 5427. HSA plan types are not updating properly.
       --Ticket#7016
            generate_batch_number(l_entrp_id, p_account_type, null, l_batch_number);
            pc_employer_enroll.create_employer_staging(
                p_name                         => x.name,
                p_ein_number                   => x.entrp_code,
                p_address                      => x.address,
                p_city                         => x.city,
                p_state                        => x.state,
                p_zip                          => x.zip,
                p_contact_name                 => x.entrp_contact,
                p_phone                        => x.entrp_phones,
                p_fax_id                       => x.entrp_fax,
                p_email                        => x.entrp_email,
                p_card_allowed                 => null,
                p_management_account_user_name => null,
                p_management_account_password  => null,
                p_password_question            => null,
                p_password_answer              => null,
                p_account_type                 => p_account_type,
                p_batch_number                 => l_batch_number,
                p_office_phone_no              => x.office_phone_number,
                p_salesrep_flag                => null, /*Ticket#11509*/
                p_salesrep_name                => null,  /*Ticket#11509*/
                x_enrollment_id                => l_enrollment_id,
                x_error_message                => l_error_message,
                x_return_status                => l_return_status
            );

            if
                l_return_status = 'S'
                and l_enrollment_id > 0
            then
                update employer_online_enrollment
                set
                    entrp_id = l_entrp_id
                where
                    enrollment_id = l_enrollment_id;

            end if;

            pc_log.log_error('PC_EMPLOYER_ENROLL.CR_EXISTING_USER_LOGIN ', 'Entrp ID Created' || l_entrp_id);
            if p_account_type = 'ERISA_WRAP' then
                l_plan_code := 516;
            elsif p_account_type = 'FSA' then
                l_plan_code := 513;
            elsif p_account_type = 'HRA' then
                l_plan_code := 507;
            elsif p_account_type = 'COBRA' then
                l_plan_code := 514;
            elsif p_account_type = 'FORM_5500' then
                l_plan_code := 515;
            elsif p_account_type = 'POP' then
                l_plan_code := 511;
            else
                l_plan_code := 1;
            end if;

            if l_return_status = 'S' then
                insert into account (
                    acc_id,
                    entrp_id,
                    acc_num,
                    plan_code,
                    start_date,
                    note,
                    fee_setup,
                    fee_maint,
                    reg_date,
                    pay_code,
                    pay_period,
                    account_status,
                    complete_flag,
                    account_type,
                    enrollment_source,
                    broker_id,
                    enrolle_type,                        -----9392 rprabu 21/10/2020
                    enrolled_by,                       -----9392 rprabu 21/10/2020
                    created_by,                         -----9392 rprabu 21/10/2020
                    last_updated_by                 -----9392 rprabu 21/10/2020
                ) values ( acc_seq.nextval,
                           l_entrp_id,
                           'G'
                           ||
                           case
                               when p_account_type = 'HSA'
                                    and l_plan_code in ( 1, 2, 3 ) then
                                       substr(
                                           pc_account.generate_acc_num(l_plan_code,
                                                                       upper(x.state)),
                                           2
                                       )
                               else
                                   pc_account.generate_acc_num(l_plan_code, null)
                           end,
                           l_plan_code,
                           sysdate,
                           'Online Enrollment',
                           case
                               when p_account_type = 'HSA' then
                                   pc_plan.fsetup_online(0)
                               else
                                   0
                           end,
                           case
                               when p_account_type = 'HSA' then
                                   pc_plan.fmonth(l_plan_code) --- This plan code has to be hard coded
                               else
                                   0
                           end,
                           sysdate,
                           null,--Pay Code
                           null ---x.er_contribution_frequency
                           ,
                           3 --Set it to 'Pending Activation'
                           ,
                           0,--Setup NOT complete
                           p_account_type,
                           'ONLINE',
                           0,
                           'EMPLOYER',        -----9392 rprabu 21/10/2020
                           p_user_id,           -----9392 rprabu 21/10/2020
                           p_user_id,           -----9392 rprabu 21/10/2020
                           p_user_id            -----9392 rprabu 21/10/2020
                            ) returning acc_id into l_acc_id;

                pc_log.log_error('PC_EMPLOYER_ENROLL.CR_EXISTING_USER_LOGIN ', 'Account Created' || l_acc_id);
            end if;

        end loop; --Account and Enterprise Created
        x_entrp_id := l_entrp_id;
        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.CR_EXISTING_USER_LOGIN ', sqlerrm);
    end cr_existing_user_login;

    procedure upsert_er_info (
        p_entrp_id                    in number,
        p_name                        in varchar2,
        p_state_of_org                in varchar2,
        p_fiscal_yr_end               in varchar2,
        p_affiliate_employers_flag    varchar2, --- added by   rprabu on 09/10/2018 for the ticket 7085.
        p_controlled_group_flag       varchar2, --- added by   rprabu on 09/10/2018 for the ticket 7085.
        p_type_entity                 in varchar2,
        p_entity_name                 in varchar2,
        p_represent_name              in varchar2,
        p_affliate_name               in varchar2_tbl,
        p_contrl_grp_name             in varchar2_tbl,
        p_total_ees                   in varchar2,
        p_toal_fsa_ees                in varchar2,
        p_comp_sponsored_medical_plan in varchar2,
        p_include_fsa_ees             in varchar2,
        p_batch_number                in number,
        p_user_id                     in number,
        x_enrollment_id               out number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is
        l_count number;
    begin
        x_error_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL.FSA_HRA_ONLINE_STAGE', 'In Proc' || p_batch_number);
        select
            count(*)
        into l_count
        from
            online_fsa_hra_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        if l_count > 0 then
            update online_fsa_hra_staging
            set
                company_name = p_name,
                state_of_org = p_state_of_org,
                fiscal_yr_end = to_date(p_fiscal_yr_end, 'mm/dd/rrrr'),
                type_of_entity = p_type_entity,
                name_of_entity = p_entity_name,
                name_of_representative = p_represent_name,
                total_number_ees = p_total_ees,
                fsa_eligib_ee = p_toal_fsa_ees,
                comp_sponsored_medical_plan = p_comp_sponsored_medical_plan,
                include_ees = p_include_fsa_ees,
                affiliate_employers_flag = p_affiliate_employers_flag, --- added by   rprabu on 23/10/2018 for the ticket 7085.
                controlled_group_flag = p_controlled_group_flag     --- added by   rprabu on 23/10/2018 for the ticket 7085.
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
            returning enrollment_id into x_enrollment_id;

            pc_log.log_error('PC_EMPLOYER_ENROLL.FSA_HRA_ONLINE_STAGE', 'After Update');
        else
      /* Insert into staging table */
            insert into online_fsa_hra_staging (
                enrollment_id,
                entrp_id,
                company_name,
                state_of_org,
                fiscal_yr_end,
                type_of_entity,
                name_of_entity,
                name_of_representative,
                total_number_ees,
                fsa_eligib_ee,
                comp_sponsored_medical_plan,
                include_ees,
                batch_number,
                affiliate_employers_flag, --- added by   rprabu on 23/10/2018 for the ticket 7085.
                controlled_group_flag,    --- added by   rprabu on 23/10/2018 for the ticket 7085.
                creation_date,
                created_by,
                inactive_plan_flag   -- Added by Joshi for 10430
            ) values ( fsa_online_enroll_seq.nextval,
                       p_entrp_id,
                       p_name,
                       p_state_of_org,
                       to_date(p_fiscal_yr_end, 'mm/dd/rrrr'),
                       p_type_entity,
                       p_entity_name,
                       p_represent_name,
                       p_total_ees,
                       p_toal_fsa_ees,
                       p_comp_sponsored_medical_plan,
                       p_include_fsa_ees,
                       p_batch_number,
                       p_affiliate_employers_flag, --- added by   rprabu on 23/10/2018 for the ticket 7085.
                       p_controlled_group_flag,    --- added by   rprabu on 23/10/2018 for the ticket 7085.
                       sysdate,
                       p_user_id,
                       nvl(
                           pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                           'N'
                       ) ) returning enrollment_id into x_enrollment_id;

        end if; -- End of Insert update loop
    /**Delete old record and insert new onez which takes care of updates also */
        delete from entrp_relationships_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;
    /*Creating Affliated Employer */
        for i in 1..p_affliate_name.count loop
            if p_affliate_name(i) is not null then
                insert into entrp_relationships_staging (
                    relation_id,
                    entrp_id,
                    entity_name,
                    entity_type,
                    relationship_type,
                    status,
                    batch_number,
                    creation_date,
                    created_by
                ) values ( fsa_relationship_seq.nextval,
                           p_entrp_id,
                           p_affliate_name(i),
                           'ENTERPRISE',
                           'AFFLIATED_ER',
                           'A',
                           p_batch_number,
                           sysdate,
                           p_user_id );

            end if;
        end loop;
    /*Creating Control Grp Employer */
        for i in 1..p_contrl_grp_name.count loop
            if p_contrl_grp_name(i) is not null then
                insert into entrp_relationships_staging (
                    relation_id,
                    entrp_id,
                    entity_name,
                    entity_type,
                    relationship_type,
                    status,
                    batch_number,
                    creation_date,
                    created_by
                ) values ( fsa_relationship_seq.nextval,
                           p_entrp_id,
                           p_contrl_grp_name(i),
                           'ENTERPRISE',
                           'CONTROLLED_GRP_ER',
                           'A',
                           p_batch_number,
                           sysdate,
                           p_user_id );

            end if;
        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL.FSA_HRA_ONLINE_STAGE', 'After Insert..' || x_error_status);
    exception
        when no_data_found then
            rollback;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.FSA_HRA_ONLINE_STAGE', x_error_message);
        when others then
            rollback;
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.FSA_HRA_ONLINE_STAGE', x_error_message);
    end upsert_er_info;

---------------   Ticket #6928 The Benefit plans selected by pressing Confirm Plan selection(s) is not displaying in Summary page.
---------------  GET_ER_PLAN_INFO  Added by rprabu on 05/11/2018
    function get_er_plan_info (
        p_entrp_id     in number,
        p_batch_number in number
    ) return get_report_type_row_t
        pipelined
        deterministic
    is

        l_record                  get_report_type_row;
        l_ctr                     number := 0;
        l_dependent_care_fsa_flag varchar2(1);
        l_healthcare_fsa_flag     varchar2(1);
        l_lph_fsa_flag            varchar2(1);
        l_parking_fsa_flag        varchar2(1);
        l_transit_fsa_flag        varchar2(1);
        l_bicycle_fsa_flag        varchar2(1);
    begin
        for i in (
            select
                dependent_care_fsa_flag,
                healthcare_fsa_flag,
                lph_fsa_flag,
                parking_fsa_flag,
                transit_fsa_flag,
                bicycle_fsa_flag
            from
                online_fsa_hra_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_dependent_care_fsa_flag := i.dependent_care_fsa_flag;
            l_healthcare_fsa_flag := i.healthcare_fsa_flag;
            l_lph_fsa_flag := i.lph_fsa_flag;
            l_parking_fsa_flag := i.parking_fsa_flag;
            l_transit_fsa_flag := i.transit_fsa_flag;
            l_bicycle_fsa_flag := i.bicycle_fsa_flag;
        end loop;

        for x in (
            select
                lookup_code,
                meaning
            from
                fsa_hra_plan_type
            where
                lookup_code in ( 'DCA', 'FSA', 'LPF', 'PKG', 'TRN',
                                 'UA1' )
        ) loop
            l_ctr := 0;
            if
                x.lookup_code = 'DCA'
                and l_dependent_care_fsa_flag = 'Y'
            then
                l_record.lookup_code := x.lookup_code;
                l_ctr := 1;
            end if;

            if
                x.lookup_code = 'FSA'
                and l_healthcare_fsa_flag = 'Y'
            then
                l_record.lookup_code := x.lookup_code;
                l_ctr := 1;
            end if;

            if
                x.lookup_code = 'LPF'
                and l_lph_fsa_flag = 'Y'
            then
                l_record.lookup_code := x.lookup_code;
                l_ctr := 1;
            end if;

            if
                x.lookup_code = 'PKG'
                and l_parking_fsa_flag = 'Y'
            then
                l_record.lookup_code := x.lookup_code;
                l_ctr := 1;
            end if;

            if
                x.lookup_code = 'TRN'
                and l_transit_fsa_flag = 'Y'
            then
                l_record.lookup_code := x.lookup_code;
                l_ctr := 1;
            end if;

            if
                x.lookup_code = 'UA1'
                and l_bicycle_fsa_flag = 'Y'
            then
                l_record.lookup_code := x.lookup_code;
                l_ctr := 1;
            end if;

            if l_ctr = 1 then
                l_record.error_status := 'S';
                l_record.error_message := 'Sucess';
                pipe row ( l_record );
            end if;

        end loop;
    --   PIPE ROW (l_record);
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_er_plan_info;


---------------   Ticket #6928 The Benefit plans selected by pressing Confirm Plan selection(s) is not displaying in Summary page.
---------------  UPSERT_ER_PLAN_INFO  Added by rprabu on 05/11/2018
    procedure upsert_er_plan_info (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_plan_types    in varchar2_tbl,
        p_source        in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_entrp_id number := null;   --- 9120 27/05/2020  rprabu
    begin
        x_error_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO begin', x_error_message);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_batch_number ', p_batch_number);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_entrp_id ', p_entrp_id);

--- 9120 27/05/2020  rprabu
        begin
            select
                entrp_id
            into l_entrp_id
            from
                online_fsa_hra_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and nvl(source, '*') = nvl(p_source, '*');

        exception
            when no_data_found then
                l_entrp_id := null;
        end;

        if l_entrp_id is not null then  --- 9120 27/05/2020  rprabu
            update online_fsa_hra_staging
            set
                dependent_care_fsa_flag = p_plan_types(1),
                healthcare_fsa_flag = p_plan_types(2),
                lph_fsa_flag = p_plan_types(3),
                parking_fsa_flag = p_plan_types(4),
                transit_fsa_flag = p_plan_types(5),
                bicycle_fsa_flag = p_plan_types(6)
            where
                    entrp_id = p_entrp_id     ------- Ticket#9127 rprabu
                and batch_number = p_batch_number;

        else   --- 9120 27/05/2020  rprabu
            insert into online_fsa_hra_staging (
                enrollment_id,
                entrp_id,
                batch_number,
                dependent_care_fsa_flag,
                healthcare_fsa_flag,
                lph_fsa_flag,
                parking_fsa_flag,
                transit_fsa_flag,
                bicycle_fsa_flag,
                creation_date,
                created_by,
                inactive_plan_flag,   -- Added by Joshi for 10431
                source -- Added by Joshi for 11263
            ) values ( fsa_online_enroll_seq.nextval,
                       p_entrp_id,
                       p_batch_number,
                       p_plan_types(1),
                       p_plan_types(2),
                       p_plan_types(3),
                       p_plan_types(4),
                       p_plan_types(5),
                       p_plan_types(6),
                       sysdate,
                       '0',
                       nvl(
                           pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                           'N'
                       ),
                       p_source  -- Added by Joshi for 11263
                        );

        end if; --- End  9120 27/05/2020  rprabu

 ---- added by rprabu on 15/11/2018 on ticket# 6930
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_plan_types(1) ',
                         p_plan_types(1));
        if p_plan_types(1) = 'N' then
            delete online_fsa_hra_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and plan_type = 'DCA';

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_plan_types(2) ',
                         p_plan_types(2));
        if p_plan_types(2) = 'N' then
            delete online_fsa_hra_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and plan_type = 'FSA';

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_plan_types(3) ',
                         p_plan_types(3));
        if p_plan_types(3) = 'N' then
            delete online_fsa_hra_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and plan_type = 'LPF';

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_plan_types(4) ',
                         p_plan_types(4));
        if p_plan_types(4) = 'N' then
            delete online_fsa_hra_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and plan_type = 'PKG';

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_plan_types(5) ',
                         p_plan_types(5));
        if p_plan_types(5) = 'N' then
            delete online_fsa_hra_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and plan_type = 'TRN';

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO p_plan_types(6) ',
                         p_plan_types(6));
        if p_plan_types(6) = 'N' then
            delete online_fsa_hra_plan_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and plan_type = 'UA1';

        end if;

    exception
        when others then
            rollback;
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ER_PLAN_INFO', x_error_message);
    end upsert_er_plan_info; --------------- End UPSERT_ER_PLAN_INFO  Added by rprabu on 05/11/2018

    procedure upsert_plan_info (
        p_enrollment_id               in number,
        p_plan_type                   in varchar2,
        p_entrp_id                    in number,
        p_user_id                     in number,
        p_batch_number                in number,
        p_plan_number                 in number default null,
        p_plan_start_date             in varchar2,
        p_plan_end_date               in varchar2,
        p_eff_date                    in varchar2 default null,
        p_org_eff_date                in varchar2 default null,
        p_open_enrollment_flag        in varchar2, ---ticket 7225 added by rprabu on 16/11/2018
        p_grace_period_flag           in varchar2, ---ticket 7225 added by rprabu on 16/11/2018
        p_open_enrollment_date        in varchar2,
        p_open_enrollment_end_date    in varchar2,
        p_min_election                in varchar2,
        p_max_annual_election         in varchar2,
        p_run_out_period              in varchar2,
        p_ee_pay_per_period           in varchar2 default null,
        p_allow_debit_card            in varchar2 default null,
        p_pay_day                     in varchar2 default null,
        p_take_over                   in varchar2 default null,
        p_rollover_flag               in varchar2 default null,
        p_rollover_amount             in number default null,
        p_grace_period                in varchar2 default null,
        p_er_contrib_flag             in varchar2 default null,
        p_er_contrib_method           in varchar2 default null,
        p_er_amount                   in varchar2 default null,
        p_heart_act                   in varchar2 default null,
        p_amt_reservist_disrib        in varchar2 default null,
        p_plan_with_hsa               in varchar2 default null,
        p_plan_with_hra               in varchar2 default null,
        p_highway_flag                in varchar2 default null,
        p_transit_pass_flag           in varchar2 default null,
        p_run_out_term                in varchar2 default null,
        p_short_plan_yr_flag          in varchar2 default null,
        p_post_deductible_plan        in varchar2 default null,
        p_plan_docs_flag              in varchar2 default null,
        p_ndt_testing                 in varchar2 default null,
        p_new_plan_yr                 in varchar2 default null,
        p_org_ben_plan_id             in varchar2 default null,
        p_new_hire                    in varchar2 default null,
        p_eob                         in varchar2 default null,
        p_payroll_frequency           in varchar2_tbl,
        p_no_of_periods               in varchar2_tbl,
        p_pay_date                    in varchar2_tbl,
        p_funding_option              in varchar2 default null,---8313 04/11/2019 rprabu
        p_update_limit_match_irs_flag in varchar2 default null,---8237 12/11/2019 rprabu
        p_page_validity               in varchar2,    --- RPRABU 27/07/2018 6346
        p_renewal_new_plan            in varchar2,    -- Added by Swamy for Ticket#9601 09/11/2021
        x_enrollment_detail_id        out number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is
        l_count      number;
        l_count_freq number := 0;
        l_detail_id  number;
    begin
        x_error_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO p_enrollment_id: ', p_enrollment_id);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', 'In Proc');
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', p_plan_start_date);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', p_plan_end_date);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', p_eff_date);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', p_eff_date);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', p_open_enrollment_date);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', p_open_enrollment_end_date);

    --pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO',p_pay_date);
        if p_plan_type is not null then ----Ticket #6967 added by rprabu 03/10/2018

            select
                count(*)
            into l_count
            from
                online_fsa_hra_plan_staging
            where
                    batch_number = p_batch_number
                and enrollment_id = p_enrollment_id
                and plan_type = p_plan_type;

            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO p_plan_type: ', p_plan_type);
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO l_count: ', l_count);
            if l_count > 0 then --Then Only Update
                update online_fsa_hra_plan_staging
                set
                    plan_type = p_plan_type,
                    plan_number = p_plan_number,
                    plan_start_date = to_date(p_plan_start_date, 'mm/dd/rrrr'),
                    plan_end_date = to_date(p_plan_end_date, 'mm/dd/rrrr'),
                    effective_date = to_date(p_eff_date, 'mm/dd/rrrr'),
                    org_effective_date = to_date(p_org_eff_date, 'mm/dd/rrrr'),
                    open_enrollment_period_flag = p_open_enrollment_flag, ---ticket 7225 added by rprabu on 16/11/2018
                    grace_period_flag = p_grace_period_flag, ---ticket 7225 added by rprabu on 16/11/2018
                    open_enrollment_start_date = to_date(p_open_enrollment_date, 'mm/dd/rrrr'),
                    open_enrollment_end_date = to_date(p_open_enrollment_end_date, 'mm/dd/rrrr'),
                    min_annual_election = p_min_election,
                    max_annual_election = p_max_annual_election,
                    run_out_period = p_run_out_period,
                    ee_pay_per_period = p_ee_pay_per_period,
                    all_debit_card = p_allow_debit_card,
                    pay_day = p_pay_day,
                    rollover_flag = p_rollover_flag,
                    rollover_amount = p_rollover_amount,
                    grace_period = p_grace_period,
                    er_contrib_flag = p_er_contrib_flag,
                    er_contrib_method = p_er_contrib_method,
                    er_lump_amt = p_er_amount,
                    heart_act_flag = p_heart_act,
                    amt_reservist_disrib = p_amt_reservist_disrib,
                    take_over = p_take_over,
                    plan_with_hsa = p_plan_with_hsa,
                    plan_with_hra = p_plan_with_hra,
                    highway_contrib_flag = p_highway_flag,
                    transit_pass_flag = p_transit_pass_flag,
                    run_out_term = p_run_out_term,
                    short_plan_yr_flag = p_short_plan_yr_flag,
                    post_deductible_plan = p_post_deductible_plan,
                    plan_docs_flag = p_plan_docs_flag,
                    non_discm_testing = p_ndt_testing,
                    new_plan_yr = p_new_plan_yr,
                    org_ben_plan_id = p_org_ben_plan_id,
                    new_hire = p_new_hire,
                    eob = p_eob,
                    funding_option = p_funding_option, ---8313 04/11/2019 rprabu
                    update_limit_match_irs_flag = p_update_limit_match_irs_flag,  -- 8237 12/11/2019 rprabu
                    plan_error = p_page_validity, --- rprabu on 30/07/2018 by fsa enrollment 6346
                    renewal_new_plan = p_renewal_new_plan    -- Added by Swamy for Ticket#9601 09/11/2021
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id
                    and plan_type = p_plan_type
                returning enrollment_detail_id into l_detail_id;

                pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', 'In Update');
        --Update Payroll Setup
                for i in 1..p_payroll_frequency.count loop
                    select
                        count(*)
                    into l_count_freq
                    from
                        pay_cycle_stage
                    where
                            frequency = p_payroll_frequency(i)
                        and plan_type = p_plan_type
                        and batch_number = p_batch_number;

                    if l_count_freq > 0 then
                        update pay_cycle_stage
                        set
                            frequency = p_payroll_frequency(i),
                            pay_periods = p_no_of_periods(i),
                            start_date = to_date(p_pay_date(i),
        'mm/dd/rrrr')
                        where
                                batch_number = p_batch_number
                            and plan_type = p_plan_type
                            and frequency = p_payroll_frequency(i);

                    else --New Freq added
                        insert into pay_cycle_stage (
                            pay_cycle_id,
                            enrollment_detail_id,
                            plan_type,
                            frequency,
                            pay_periods,
                            start_date,
                            status,
                            batch_number,
                            creation_date,
                            created_by
                        ) values ( pay_cycle_seq.nextval,
                                   l_detail_id,
                                   p_plan_type,
                                   p_payroll_frequency(i),
                                   p_no_of_periods(i),
                                   to_date(p_pay_date(i),
                                           'mm/dd/rrrr'),
                                   'A',
                                   p_batch_number,
                                   sysdate,
                                   p_user_id );

                    end if;

                end loop;

            else -- INSERT
                pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', 'Inserting plan');
                insert into online_fsa_hra_plan_staging (
                    enrollment_detail_id,
                    enrollment_id,
                    plan_type,
                    entrp_id,
                    plan_start_date,
                    plan_end_date,
                    take_over,
                    plan_number,
                    effective_date,
                    org_effective_date,
                    open_enrollment_period_flag,  ---ticket 7225 added by rprabu on 16/11/2018
                    grace_period_flag,   ---ticket 7225 added by rprabu on 16/11/2018
                    open_enrollment_start_date,
                    open_enrollment_end_date,
                    min_annual_election,
                    max_annual_election,
                    run_out_period,
                    run_out_term,
                    ee_pay_per_period,
                    all_debit_card,
                    pay_day,
                    er_contrib_flag,
                    er_contrib_method,
                    er_lump_amt,
                    heart_act_flag,
                    amt_reservist_disrib,
                    grace_period,
                    post_deductible_plan,
                    short_plan_yr_flag,
                    rollover_amount,
                    rollover_flag,
                    plan_with_hsa,
                    plan_with_hra,
                    highway_contrib_flag,
                    transit_pass_flag,
                    plan_docs_flag,
                    non_discm_testing,
                    new_plan_yr,
                    org_ben_plan_id,
                    eob,
                    new_hire,
                    batch_number,
                    funding_option,   ---8313 04/11/2019 rprabu
                    update_limit_match_irs_flag,  -- 8237 12/11/2019 rprabu
                    plan_error, --- rprabu on 30/07/2018 by fsa enrollment 6346
                    renewal_new_plan    -- Added by Swamy for Ticket#9601 09/11/2021
                ) values ( fsa_online_enroll_seq.nextval,
                           p_enrollment_id,
                           p_plan_type,
                           p_entrp_id,
                           to_date(p_plan_start_date, 'mm/dd/rrrr'),
                           to_date(p_plan_end_date, 'mm/dd/rrrr'),
                           p_take_over,
                           p_plan_number,
                           to_date(p_eff_date, 'mm/dd/rrrr'),
                           to_date(p_org_eff_date, 'mm/dd/rrrr'),
                           p_open_enrollment_flag, ---ticket 7225 added by rprabu on 16/11/2018
                           p_grace_period_flag, ---ticket 7225 added by rprabu on 16/11/2018
                           to_date(p_open_enrollment_date, 'mm/dd/rrrr'),
                           to_date(p_open_enrollment_end_date, 'mm/dd/rrrr'),
                           p_min_election,
                           p_max_annual_election,
                           p_run_out_period,
                           p_run_out_term,
                           p_ee_pay_per_period,
                           p_allow_debit_card,
                           p_pay_day,
                           p_er_contrib_flag,
                           p_er_contrib_method,
                           p_er_amount,
                           p_heart_act,
                           p_amt_reservist_disrib,
                           p_grace_period,
                           p_post_deductible_plan,
                           p_short_plan_yr_flag,
                           p_rollover_amount,
                           p_rollover_flag,
                           p_plan_with_hsa,
                           p_plan_with_hra,
                           p_highway_flag,
                           p_transit_pass_flag,
                           p_plan_docs_flag,
                           p_ndt_testing,
                           p_new_plan_yr,
                           p_org_ben_plan_id,
                           p_eob,
                           p_new_hire,
                           p_batch_number,
                           p_funding_option,   ---8313 04/11/2019 rprabu
                           p_update_limit_match_irs_flag,   -- 8237 12/11/2019 rprabu
                           p_page_validity, --- rprabu on 30/07/2018 by fsa enrollment 6346
                           p_renewal_new_plan    -- Added by Swamy for Ticket#9601 09/11/2021
                            ) returning enrollment_detail_id into x_enrollment_detail_id;

                pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', 'After Inserting plan');
        --Insert Payroll Setup
                for i in 1..p_payroll_frequency.count loop
                    pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO',
                                     p_pay_date(i));
                    insert into pay_cycle_stage (
                        pay_cycle_id,
                        enrollment_detail_id,
                        plan_type,
                        frequency,
                        pay_periods,
                        start_date,
                        status,
                        batch_number,
                        creation_date,
                        created_by
                    ) values ( pay_cycle_seq.nextval,
                               x_enrollment_detail_id,
                               p_plan_type,
                               p_payroll_frequency(i),
                               p_no_of_periods(i),
                               to_date(p_pay_date(i),
                                       'mm/dd/rrrr'),
                               'A',
                               p_batch_number,
                               sysdate,
                               p_user_id );

                end loop;

            end if;

        end if; ----Ticket #6967 added by rprabu 03/10/2018
    exception
        when no_data_found then
            rollback;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', x_error_message);
        when others then
            rollback;
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_PLAN_INFO', x_error_message);
    end upsert_plan_info;

    function get_fsa_plan_type return get_report_type_row_t
        pipelined
        deterministic
    is
        l_record get_report_type_row;
    begin
        for x in (
            select
                lookup_code,
                meaning
            from
                fsa_hra_plan_type
            where
                lookup_code in ( 'DCA', 'FSA', 'LPF', 'PKG', 'TRN',
                                 'UA1' )
        ) loop
            l_record.lookup_code := x.lookup_code;
            l_record.description := x.meaning;
            l_record.error_status := 'S';
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_fsa_plan_type;

    procedure upsert_contact_info (
        p_entrp_id        in number,
        p_contact_id      in number,
        p_first_name      in varchar2,
        p_email           in varchar2,
        p_account_type    in varchar2,
        p_contact_type    in varchar2,
        p_user_id         in varchar2,
        p_ref_entity_id   in varchar2,
        p_ref_entity_type in varchar2,
        p_status          in varchar2,
        p_phone_num       in varchar2,
        p_fax_num         in varchar2,
        p_title           in varchar2,
        p_batch_num       in number,
        p_lic_number      in varchar2 default null, --Ticket#5020
      --Ticket#5469
        p_send_invoice    in number default null,
        p_page_validity   in varchar2 default null,
        p_contact_flg     in varchar2 default 'Y',   -- Added by swamy for Ticket#8684 on 19/05/2020
        p_lic_number_flag in varchar2 default null,   -- Added by swamy for Ticket#9162(Dev ref#8684)
        p_source          in varchar2 default null,    -- Added by Swamy for Ticket#9324 on 16/07/2020
        x_contact_id      out number,--For any new insert conatct id is returned to PHP
        x_error_status    out varchar2,
        x_error_message   out varchar2
    ) is

        l_count         number;
        l_contact_seq   number;
        l_contact_cnt   number;
        l_page_validity varchar2(10) := 'V'; -- 6346 rprabu FSA
        l_page_no       number := 0;     -- 6346 rprabu FSA   Ticket #6909
    begin
        x_error_status := 'S';
        x_contact_id := null;
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_CONTACT_INFO..', 'In Proc ' || p_contact_type);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_CONTACT_INFO..', 'Conatct Info Flag 333 ' || p_send_invoice);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_CONTACT_INFO..', 'p_page_validity :333  ' || p_page_validity);
        if p_contact_id is not null then
            update contact_leads
            set
                first_name = p_first_name,
                email = p_email,
                phone_num = p_phone_num,
                contact_fax = p_fax_num,
                job_title = p_title,
                contact_type = p_contact_type,
                send_invoice = p_send_invoice,
                lic_number = p_lic_number,   --Ticket#5020
                validity = p_page_validity, -- prabu 6346 rprabu
                contact_flg = p_contact_flg,   -- Added by swamy for Ticket#8684 on 19/05/2020
                lic_number_flag = p_lic_number_flag   -- Added by swamy for Ticket#9162(Dev ref#8684)
            where
                contact_id = p_contact_id;

            x_contact_id := p_contact_id;
        else
            select
                contact_seq.nextval
            into l_contact_seq
            from
                dual;
      --DELETE FROM CONTACT_LEADS
      --WHERE ENTITY_ID = PC_ENTRP.GET_TAX_ID(P_ENTRP_ID);
            insert into contact_leads (
                contact_id,
                entity_id,
                entity_type,
                first_name,
                email,
                account_type,
                ref_entity_id,
                ref_entity_type,
                send_invoice,
                contact_type,
                updated,
                user_id,
                creation_date,
                phone_num,
                contact_fax,
                job_title,
                lic_number,
                validity,
                contact_flg,    -- Added by swamy for Ticket#8684 on 19/05/2020
                lic_number_flag,  -- Added by swamy for Ticket#9162(Dev ref#8684)
                prefetched_flg  -- Added by swamy for Ticket#9162(Dev ref#8684)
            ) --- rprabu added for FSA enrollment ticket 6346 and 6377 )
                (
                    select
                        l_contact_seq,
                        pc_entrp.get_tax_id(p_entrp_id),
                        'ENTERPRISE',
                        p_first_name,
                        p_email,
                        p_account_type, --Ticket#5469
                        p_ref_entity_id,
                        p_ref_entity_type,
                        p_send_invoice,
                        p_contact_type,
                        'N',
                        p_user_id,
                        sysdate,
                        p_phone_num,
                        p_fax_num,
                        p_title,
                        p_lic_number,
                        p_page_validity, --- rprabu added for FSA enrollment ticket 6346 and 6377
                        p_contact_flg,    -- Added by swamy for Ticket#8684 on 19/05/2020
                        p_lic_number_flag,  -- Added by swamy for Ticket#9162(Dev ref#8684)
                        'N'  -- Added by swamy for Ticket#9162(Dev ref#8684)
                    from
                        dual
                );

            x_contact_id := l_contact_seq;
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_CONTACT_INFO..', 'OUT ID ' || x_contact_id);
    --Validating Page #3  -- FORM5500 added by rprabu 7015      --- ERISA_WRAP added rprabu for 12/06/2019 7691
        if p_account_type in ( 'FSA', 'HRA', 'HSA', 'FORM_5500', 'ERISA_WRAP' ) then -- IF  added by rprabu on 08/08/2018 for the tickets 6346 and 6377
      -- for loop added by rprabu on 09/08/2018 Ticket 6346                     -- HSA - Added by jaggi for Ticket #9553
            for i in (
                select
                    decode(
                        count(contact_id),
                        0,
                        'V',
                        'I'
                    ) page_validity
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = p_account_type
                    and validity = 'I'
            ) loop
                l_page_validity := i.page_validity;
            end loop;
      --- Added for  the Ticket #6909
            if p_account_type = 'FSA' then
                l_page_no := 3;
            elsif p_account_type = 'HRA' then
                l_page_no := 4;
		--- ERISA_WRAP added rprabu for 12/06/2019 7691
            elsif p_account_type in ( 'ERISA_WRAP', 'HSA', 'FORM_5500' ) then -- added by rprabu 12/12/2018 for ticket 7015
                l_page_no := 2;                                        -- HSA - Added by jaggi for Ticket #9553
            end if;
      --- added by rprabu for contact page issue on 27/07/2018 ticket 6346
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_num,
                p_entrp_id      => p_entrp_id,
                p_account_type  => p_account_type,
                p_page_no       => l_page_no,
                p_block_name    => 'CONTACT_INFORMATION',
                p_validity      => l_page_validity,
                p_user_id       => p_user_id,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_CONTACT_INFO', ' 4.5 l_page_validity : ' || l_page_validity);
        else
            if ( p_account_type <> 'COBRA' )
            or (
                p_account_type = 'COBRA'
                and p_source <> 'RENEWAL'
            ) then   -- Added for Prod Ticket#11612 by Swamy
                update online_compliance_staging
                set
                    page3_contact = p_page_validity,
                    last_update_date = sysdate,  -- added by swamy
                    last_updated_by = p_user_id -- added by swamy
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_num;
--------9392 rprabu 29/09/2020 POP, cobra added .
                if p_account_type = 'POP' then
                    l_page_no := 2;
                elsif p_account_type = 'COBRA' then
                    if p_source = 'RENEWAL' then -- Added by Swamy for Ticket#11364
                        l_page_no := 2;
                    else
                        l_page_no := 3;
                    end if;
                end if;

                pc_employer_enroll.upsert_page_validity(
                    p_batch_number  => p_batch_num,
                    p_entrp_id      => p_entrp_id,
                    p_account_type  => p_account_type,
                    p_page_no       => l_page_no,
                    p_block_name    => 'CONTACT_INFORMATION',
                    p_validity      => p_page_validity,
                    p_user_id       => p_user_id,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );
              --------9392 rprabu 29/09/2020 POP, cobra added .
                pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_CONTACT_INFO', ' 4.5 l_page_validity : ' || l_page_validity);
            end if;
        end if;
    --In case there is no Priary Contact or uf Broker/GA is not setup for send invoice flag as 1. Then we mark record as Inactive
    --Only if everything in UI is valid, we should validate business login
    --- IF p_page_validity = 'V' THEN
    -- validate_contact(x_contact_id,p_entrp_id);
    --- END IF;
    ---If is added by rprabu  on 08/08/2018 for the  tickets 6346 and 6377
    --- P_ACCOUNT_TYPE and p_BATCH_NUM is added by rprabu  tickets 6346 and 6377
	-- FORM_5500 added by 7015 on 05/01/2019
	--- ERISA_WRAP added rprabu for 12/06/2019 7691

        if p_account_type in ( 'FSA', 'HRA', 'HSA', 'FORM_5500', 'ERISA_WRAP' ) then        -- HSA - Added by jaggi for Ticket #9553
            if l_page_validity = 'V' then
                validate_contact(x_contact_id, p_entrp_id, p_batch_num, p_account_type, p_source);  -- p_source Added by Swamy for Ticket#9324 on 16/07/2020

            end if;
        elsif p_page_validity = 'V' then
            validate_contact(x_contact_id, p_entrp_id, p_batch_num, p_account_type, p_source);    -- p_source Added by Swamy for Ticket#9324 on 16/07/2020
        end if;

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_CONTACT_INFO', 'Error ' || sqlerrm);
    end upsert_contact_info;
/*
--- Coommented  by rprabu 21/08/2018  for FSA enrollment 6346 Update_Eligibile_Admin_Option1,
PROCEDURE UPDATE_ELIGIBILE_ADMIN_OPTION(
p_entrp_id                IN NUMBER,
p_ndt_preference          IN VARCHAR2,
p_batch_number            IN NUMBER,
p_er_pretax_flag          IN VARCHAR2,
p_PERMIT_CASH_FLAG        IN VARCHAR2,
p_limit_cash_flag         IN VARCHAR2 ,
p_REVOKE_ELECT_FLAG       IN VARCHAR2,
p_CEASE_COVG_FLAG         IN VARCHAR2,
p_COLLECTIVE_BARGAIN_FLAG IN VARCHAR2,
p_NO_OF_HRS_PART_TIME     IN VARCHAR2 ,
p_NO_OF_HRS_SEASONAL      IN VARCHAR2 ,
p_NO_OF_HRS_CURRENT       IN VARCHAR2,
p_NEW_EE_MONTH_SERVC      IN VARCHAR2,
p_SELECT_ENTRY_DATE_FLAG  IN VARCHAR2,
p_MIN_AGE_REQ             IN VARCHAR2 ,
p_PLAN_NEW_EE_JOIN        IN VARCHAR2 ,
p_AUTOMATIC_ENROLL        IN VARCHAR2,
p_carrier_flag            IN VARCHAR2,
p_PERMIT_PARTCP_EOY       IN VARCHAR2,
P_EE_EXCLUDE_PLAN_FLAG    IN VARCHAR2,
p_limit_cash_paid         IN VARCHAR2,
p_coincident_next_flag    IN VARCHAR2,
p_ndt_testing_flag        IN VARCHAR2,
p_enrollment_option       IN VARCHAR2,
P_user_id                 IN NUMBER,
p_benefit_code            IN VARCHAR2_TBL,
p_benefit_name            IN VARCHAR2_TBL,
x_error_status OUT VARCHAR2,
x_error_message OUT VARCHAR2 )
IS
l_count NUMBER := 0;
BEGIN
pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_ELIGIBILE_ADMIN_OPTION','In Proc ');
UPDATE ONLINE_FSA_HRA_STAGING
SET er_pretax_flag        = p_er_pretax_flag ,
PERMIT_CASH_FLAG        = p_PERMIT_CASH_FLAG ,
limit_cash_flag         = p_limit_cash_flag,
REVOKE_ELECT_FLAG       = p_REVOKE_ELECT_FLAG,
CEASE_COVG_FLAG         = p_CEASE_COVG_FLAG ,
COLLECTIVE_BARGAIN_FLAG = p_COLLECTIVE_BARGAIN_FLAG,
NO_OF_HRS_PART_TIME     = p_NO_OF_HRS_PART_TIME ,
NO_OF_HRS_SEASONAL      = p_NO_OF_HRS_SEASONAL,
NO_OF_HRS_CURRENT       = p_NO_OF_HRS_CURRENT ,
NEW_EE_MONTH_SERVC      = p_NEW_EE_MONTH_SERVC ,
SELECT_ENTRY_DATE_FLAG   = p_SELECT_ENTRY_DATE_FLAG,
MIN_AGE_REQ             = p_MIN_AGE_REQ ,
PLAN_NEW_EE_JOIN        = p_PLAN_NEW_EE_JOIN ,
AUTOMATIC_ENROLL        = p_AUTOMATIC_ENROLL ,
PERMIT_PARTCP_EOY       = p_PERMIT_PARTCP_EOY,
ndt_preference          = p_ndt_preference,
carrier_flag            = p_carrier_flag,
EE_EXCLUDE_PLAN_FLAG    = p_EE_EXCLUDE_PLAN_FLAG,
limit_cash_paid         = p_limit_cash_paid,
coincident_next_flag    = p_coincident_next_flag ,
ndt_testing_flag        = p_ndt_testing_flag,
enrollment_option       = p_enrollment_option
WHERE batch_number        = p_batch_number
AND entrp_id              = p_entrp_id;
---   Update Benefit Code data ****
--- For every update of benefit codes just delete and insert new set of codes
DELETE FROM BENEFIT_CODES_STAGE
WHERE entity_id = p_entrp_id
AND batch_number = p_batch_number ;
pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_ELIGIBILE_ADMIN_OPTION','After Delete');
FOR i in 1..p_benefit_code.COUNT
LOOP
IF p_benefit_code(i) IS NOT NULL THEN
pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_ELIGIBILE_ADMIN_OPTION..loop',p_benefit_code(i));
INSERT INTO BENEFIT_CODES_STAGE(ENTITY_ID,
BENEFIT_CODE_ID,
BENEFIT_CODE_NAME,
DESCRIPTION,
BATCH_NUMBER,
CREATED_BY,
CREATION_DATE)
VALUES (P_ENTRP_ID
,BENEFIT_CODE_SEQ.NEXTVAL
,p_benefit_code(i)
,CASE WHEN p_benefit_name(i) IS NULL THEN
(select description from lookups where lookup_code = p_benefit_code(i) and lookup_name='POP_ELIGIBILITY')
ELSE
p_benefit_name(i)
END
,p_batch_number
,P_USER_ID
,SYSDATE
);
END IF;
END LOOP;
pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_ELIGIBILE_ADMIN_OPTION','After Benefit Code');
EXCEPTION
WHEN OTHERS THEN
X_ERROR_MESSAGE := SQLCODE || ' ' || SQLERRM;
X_ERROR_STATUS := 'E';
pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_ELIGIBILE_ADMIN_OPTION','Error '||SQLERRM);
END UPDATE_ELIGIBILE_ADMIN_OPTION ;
*/
--- Added by rprabu 21/08/2018  for FSA enrollment 6346 Update_Eligibile_Admin_Option1,
---Update_Eligibile_Admin_Option2 , Update_Eligibile_Admin_Option3
    procedure update_eligibile_admin_option1 (
        p_entrp_id          in number,
        p_batch_number      in number,
        p_er_pretax_flag    in varchar2,
        p_permit_cash_flag  in varchar2,
        p_limit_cash_flag   in varchar2,
        p_revoke_elect_flag in varchar2,
        p_cease_covg_flag   in varchar2,
        p_limit_cash_paid   in varchar2,
        p_user_id           in number,
        p_benefit_code      in varchar2_tbl,
        p_benefit_name      in varchar2_tbl,
        x_error_status      out varchar2,
        x_error_message     out varchar2
    ) is
        l_count number := 0;
    begin
        pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option', 'In Proc ');
        update online_fsa_hra_staging
        set
            er_pretax_flag = p_er_pretax_flag,
            permit_cash_flag = p_permit_cash_flag,
            limit_cash_flag = p_limit_cash_flag,
            revoke_elect_flag = p_revoke_elect_flag,
            cease_covg_flag = p_cease_covg_flag,
            limit_cash_paid = p_limit_cash_paid
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;
    /* Update Benefit Code Data *** */
    /* * For Every Update Of Benefit Codes Just Delete And Insert New Set Of Codes */
        delete from benefit_codes_stage
        where
                entity_id = p_entrp_id
            and batch_number = p_batch_number;

        pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option', 'After Delete');
        for i in 1..p_benefit_code.count loop
            if p_benefit_code(i) is not null then
                pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option..Loop',
                                 p_benefit_code(i));
                insert into benefit_codes_stage (
                    entity_id,
                    benefit_code_id,
                    benefit_code_name,
                    description,
                    batch_number,
                    created_by,
                    creation_date
                ) values ( p_entrp_id,
                           benefit_code_seq.nextval,
                           p_benefit_code(i),
                           case
                               when p_benefit_name(i) is null
                                    and p_benefit_code(i) <> '5K'  --- Added by rprabu 7819 13/06/2019
                                     then
                                   (
                                       select
                                           description
                                       from
                                           lookups
                                       where
                                               lookup_code = p_benefit_code(i)
                                           and lookup_name = 'POP_ELIGIBILITY'
                                   )
                               else
                                   p_benefit_name(i)
                           end,
                           p_batch_number,
                           p_user_id,
                           sysdate );

            end if;
        end loop;

        pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option1', 'After Benefit Code');
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option1', 'Error ' || sqlerrm);
    end update_eligibile_admin_option1;

    procedure update_eligibile_admin_option2 (
        p_entrp_id                in number,
        p_batch_number            in number,
        p_collective_bargain_flag in varchar2,
        p_no_of_hrs_part_time     in varchar2,
        p_no_of_hrs_seasonal      in varchar2,
        p_no_of_hrs_current       in varchar2,
        p_new_ee_month_servc      in varchar2,
        p_select_entry_date_flag  in varchar2,
        p_min_age_req             in varchar2,
        p_plan_new_ee_join        in varchar2,
        p_automatic_enroll        in varchar2,
        p_permit_partcp_eoy       in varchar2,
        p_ee_exclude_plan_flag    in varchar2,
        p_coincident_next_flag    in varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is
        l_count number := 0;
    begin
        update online_fsa_hra_staging
        set
            collective_bargain_flag = p_collective_bargain_flag,
            no_of_hrs_part_time = p_no_of_hrs_part_time,
            no_of_hrs_seasonal = p_no_of_hrs_seasonal,
            no_of_hrs_current = p_no_of_hrs_current,
            new_ee_month_servc = p_new_ee_month_servc,
            select_entry_date_flag = p_select_entry_date_flag,
            min_age_req = p_min_age_req,
            plan_new_ee_join = p_plan_new_ee_join,
            automatic_enroll = p_automatic_enroll,
            permit_partcp_eoy = p_permit_partcp_eoy,
            ee_exclude_plan_flag = p_ee_exclude_plan_flag,
            coincident_next_flag = p_coincident_next_flag
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option2', 'After Benefit Code');
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option2', 'Error ' || sqlerrm);
    end update_eligibile_admin_option2;

    procedure update_eligibile_admin_option3 (
        p_entrp_id                in number,
        p_batch_number            in number,
        p_ndt_preference          in varchar2,
        p_carrier_flag            in varchar2,
        p_ndt_testing_flag        in varchar2,
        p_enrollment_option       in varchar2,
        p_additional_service_flag in varchar2, --- added by 7680 added by rprabu 16/05/2019
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is
        l_count number := 0;
    begin
        update online_fsa_hra_staging
        set
            ndt_preference = p_ndt_preference,   ---3
            carrier_flag = p_carrier_flag,     ---3
            ndt_testing_flag = p_ndt_testing_flag, ---3
            enrollment_option = p_enrollment_option, ---3
            additional_service_flag = p_additional_service_flag -- 3 --- added by 7680 added by rprabu 16/05/2019
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option3', 'After Benefit Code');
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('Pc_Employer_Enroll.Update_Eligibile_Admin_Option3', 'Error ' || sqlerrm);
    end update_eligibile_admin_option3;

    procedure delete_plan (
        p_batch_number  in varchar2,
        p_plan_type     in varchar2,
        p_entrp_id      in number,
        p_plan_id       in varchar2 default null,
      /*Ticket#5469*/
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_count         number(10);  				 ------ 7015   added by rprabu
        l_header_id     number(10); 	          ------ 7015   added by rprabu
        l_total_cost    number(10);  				 ------ 7015   added by rprabu
        l_page_valitity varchar2(1);  	 ------ 7015   added by rprabu
        l_plan_id       number := 0;                   ---- Ticket #  9429 01/12/2020 rprabu
    begin
        if p_plan_type = 'COBRA' then
            for i in (
                select
                    *
                from
                    table ( in_list(p_plan_id, ',') )
            ) loop
                delete from compliance_plan_staging
                where
                        plan_id = i.column_value
                    and batch_number = p_batch_number;

            end loop;

   -------- Ticket # 9429 01/12/2020 rprabu
            begin
                select
                    count(plan_id)
                into l_plan_id
                from
                    compliance_plan_staging
                where
                        entity_id = p_entrp_id
                    and batch_number = p_batch_number;

            end;

            if l_plan_id < 1 then
                update online_compliance_staging
                set
                    page1_plan = 'I'
                where
                    batch_number = p_batch_number;

            end if;
    --------  END  Ticket # 9429 01/12/2020 rprabu










        elsif p_plan_type = 'FORM_5500' then -- ElSIF Added by rprabu for 7015
            for i in (
                select
                    *
                from
                    table ( in_list(p_plan_id, ',') )
            ) loop
                delete from online_form_5500_plan_staging
                where
                        enrollment_detail_id = i.column_value
                    and batch_number = p_batch_number
                    and entrp_id = p_entrp_id;

                begin
                    select
                        quote_header_id
                    into l_header_id
                    from
                        ar_quote_headers_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and enrollment_detail_id = i.column_value;

                exception
                    when no_data_found then
                        l_header_id := null;
                end;

                if l_header_id is not null then
                    delete from ar_quote_lines_staging
                    where
                            batch_number = p_batch_number
                        and quote_header_id = l_header_id;

                    delete from ar_quote_headers_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and enrollment_detail_id = i.column_value;

                end if;

            end loop;  --- End by rprabu for 7015
            l_total_cost := 0;
            begin
                select
                    sum(total_quote_price)
                into l_total_cost
                from
                    ar_quote_headers_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number;

                update online_form_5500_staging
                set
                    grand_total_price = l_total_cost
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number;

            exception
                when no_data_found then
                    l_header_id := null;
            end;

            l_count := 0;
            begin
                select
                    count(page_validity)
                into l_count
                from
                    online_form_5500_plan_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
                    and page_validity = 'I';

            end;

            l_page_valitity := 'V';
            if l_count > 0 then
                l_page_valitity := 'I';
            end if;
--- added by rprabu for   page issue
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'FORM_5500',
                p_page_no       => 1,
                p_block_name    => 'PLAN_INFORMATION',
                p_validity      => l_page_valitity,
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        else
            delete from online_fsa_hra_plan_staging
            where
                    batch_number = p_batch_number
                and plan_type = p_plan_type;

        end if;
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.DELETE PLAN', 'Error ' || sqlerrm);
    end delete_plan;


/*Ticket#5469.COBRA Reconstruction */
    procedure generate_batch_number (
        p_entrp_id     in number,
        p_account_type in varchar2,
        p_source       in varchar2 default null,
        x_batch_number out number
    ) is
        l_batch_num             number;
        l_status                varchar2(1) := null;-- L_status added by rprabu for 7992
        l_renewal_resubmit_flag varchar2(1);  -- Joshi 10430
    begin
        if p_account_type in ( 'FSA', 'HRA' ) then
            if p_source is null then--Enrollment
        -- Added by Joshi for 10430
                if nvl(
                    pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                    'N'
                ) = 'I' then
                    select
                        max(batch_number)
                    into l_batch_num
                    from
                        online_fsa_hra_staging
                    where
                            entrp_id = p_entrp_id
                        and nvl(inactive_plan_flag, 'N') = 'I';

                else
                    select
                        max(batch_number)
                    into l_batch_num
                    from
                        online_fsa_hra_staging
                    where
                        entrp_id = p_entrp_id;

                end if;

            else --Renewal
                select
                    batch_number  --  MAX(batch_number) -- Added by jaggi #11368
                into l_batch_num
                from
                    online_fsa_hra_staging
                where
                        entrp_id = p_entrp_id
                    and source = p_source;

            end if;
	    /*Ticket#7015.FORM_5500 reconstruction */
        elsif p_account_type = 'FORM_5500' then
            pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num p_account_type   ', p_account_type);
            if p_source is null then--Enrollment 7792 if added by rprabu 01/08/2019

                if nvl(
                    pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                    'N'
                ) = 'I' then
                    select
                        max(batch_number)    --status added by rprabu for 7992
                    into l_batch_num
                    from
                        online_form_5500_staging
                    where
                            entrp_id = p_entrp_id
                        and status = 'I'
                        and nvl(source, 'ENROLLMENT') = 'ENROLLMENT'
                        and nvl(inactive_plan_flag, 'N') = 'I';

                    if l_batch_num is not null then
                        l_status := 'I';
                    end if;
                else
                    pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num     p_source   ', p_source);
             -- Added by Joshi for 10431. get the complete record
                    if pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id) = 'R' then
                 --  SELECT  batch_number,  status  --status added by rprabu for 7992 commented by Joshi for 12337 as it is fetching mulptiple records
                        select
                            max(batch_number)
                        into l_batch_num
                        from
                            online_form_5500_staging
                        where
                                entrp_id = p_entrp_id
                            and status = 'C'     ------8132
                            and nvl(source, 'ENROLLMENT') = 'ENROLLMENT';

                    else
                        select
                            batch_number,
                            status  --status added by rprabu for 7992
                        into
                            l_batch_num,
                            l_status
                        from
                            online_form_5500_staging
                        where
                                entrp_id = p_entrp_id
                            and status = 'I'     ------8132
                        order by
                            batch_number desc;

                    end if;

                end if;

            else
                pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num   else p_source   ', p_source);
                for j in (
                    select
                        ( batch_number ),
                        status  --status added by rprabu for 7992
                    from
                        online_form_5500_staging
                    where
                            entrp_id = p_entrp_id
                        and source = p_source
                        and status = 'I'     ------8132
                    order by
                        batch_number desc
                ) loop
                    l_batch_num := j.batch_number;     --batch_num added by rprabu for 7992
                    l_status := j.status;        --status added by rprabu for 7992
                    exit;
                end loop;

            end if;

        elsif p_account_type in ( 'HSA', 'LSA' ) then          -- Added by Swamy for Ticket#9912
        /* commeneted by Joshi for 11668. as the batch_number is stored in the Employer_Online_Product_Staging.

        SELECT batch_number
        INTO l_batch_num
        FROM employer_online_enrollment
        WHERE entrp_id = p_entrp_id;
        */
       -- Added by Joshi for 11668.
            for x in (
                select
                    batch_number
                from
                    employer_online_product_staging
                where
                    entrp_id = p_entrp_id
            ) loop
                l_batch_num := x.batch_number;
            end loop;

            if l_batch_num is null then   -- added by Joshi for 11668
                select
                    batch_number
                into l_batch_num
                from
                    employer_online_enrollment
                where
                    entrp_id = p_entrp_id;

            end if;

        elsif p_account_type in ( 'ERISA_WRAP', 'POP' ) then   -- Added POP by Swamy for Ticket#12499  -- Added by Swamy for Ticket#8684 on 19/05/2020
            if p_source is null then--Enrollment  today
    	-- Added by Joshi for 10430
                if nvl(
                    pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                    'N'
                ) = 'I' then
                    for j in (
                        select
                            batch_number,
                            record_id
                        from
                            online_compliance_staging
                        where
                                entrp_id = p_entrp_id
                            and nvl(inactive_plan_flag, 'N') = 'I'
                        order by
                            record_id
                    ) loop
                        l_batch_num := j.batch_number;
                    end loop;

                else
                    for j in (
                        select
                            batch_number,
                            record_id
                        from
                            online_compliance_staging
                        where
                            entrp_id = p_entrp_id
                        order by
                            record_id
                    ) loop
                        l_batch_num := j.batch_number;
                    end loop;
                end if;

            else -- Renewal
        -- Submit_status should be null, only then its a new record which is not yet submitted., else its an record which is already used for renewal in used for final submit.
        -- Check the procedure pc_web_er_renewal.Erisa_Renewal_final_submit for the Submit_status column details
                select
                    renewal_resubmit_flag
                into l_renewal_resubmit_flag
                from
                    account
                where
                    entrp_id = p_entrp_id;

                if l_renewal_resubmit_flag = 'Y' then
                    for j in (
                        select
                            batch_number,
                            record_id
                        from
                            online_compliance_staging
                        where
                                entrp_id = p_entrp_id
                            and source = p_source
                            and nvl(submit_status, '*') = 'COMPLETED'
                        order by
                            record_id
                    ) loop
                        l_batch_num := j.batch_number;
                    end loop;

                else
                    for j in (
                        select
                            batch_number,
                            record_id
                        from
                            online_compliance_staging
                        where
                                entrp_id = p_entrp_id
                            and source = p_source
                            and nvl(submit_status, '*') = '*'
                        order by
                            record_id
                    ) loop
                        l_batch_num := j.batch_number;
                    end loop;
                end if;

            end if;
        elsif p_account_type = 'COBRA' then   -- Added by Swamy for Ticket#11364
            if p_source is null then
    	-- Added by Joshi for 10430
                if nvl(
                    pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                    'N'
                ) = 'I' then
                    for j in (
                        select
                            batch_number,
                            record_id
                        from
                            online_compliance_staging
                        where
                                entrp_id = p_entrp_id
                            and nvl(inactive_plan_flag, 'N') = 'I'
                        order by
                            record_id
                    ) loop
                        l_batch_num := j.batch_number;
                    end loop;

                else
                    for j in (
                        select
                            batch_number,
                            record_id
                        from
                            online_compliance_staging
                        where
                            entrp_id = p_entrp_id
                        order by
                            record_id
                    ) loop
                        l_batch_num := j.batch_number;
                    end loop;
                end if;

            else -- Renewal
        -- Submit_status should be null, only then its a new record which is not yet submitted., else its an record which is already used for renewal in used for final submit.
        -- Check the procedure pc_web_er_renewal.Erisa_Renewal_final_submit for the Submit_status column details
                select
                    renewal_resubmit_flag
                into l_renewal_resubmit_flag
                from
                    account
                where
                    entrp_id = p_entrp_id;

                if l_renewal_resubmit_flag = 'Y' then
                    for j in (
                        select
                            max(batch_number) batch_number --,record_id
                        from
                            online_compliance_staging
                        where
                                entrp_id = p_entrp_id
                            and source = p_source
                            and nvl(submit_status, '*') = 'COMPLETED'
                    )
                          --ORDER BY record_id)
                     loop
                        l_batch_num := j.batch_number;
                    end loop;

                else
                    for j in (
                        select
                            max(batch_number) batch_number --,record_id
                        from
                            online_compliance_staging
                        where
                                entrp_id = p_entrp_id
                            and source = p_source
                            and nvl(submit_status, '*') = '*'
                    )
                            --ORDER BY record_id)
                     loop
                        l_batch_num := j.batch_number;
                    end loop;
                end if;

            end if;
        else
            pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num p_source ', p_source);
            if p_source is null then--Enrollment
            -- Added by Joshi for 10430
                if nvl(
                    pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                    'N'
                ) = 'I' then
                    pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num', 'inside inactive place');
                    select
                        max(batch_number)
                    into l_batch_num
                    from
                        online_compliance_staging
                    where
                            entrp_id = p_entrp_id
                        and nvl(inactive_plan_flag, 'N') = 'I';

                    pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num in side inactive plan ', l_batch_num);
                else
                    select
                        max(a.batch_number)
                    into l_batch_num
                    from
                        online_compliance_staging a
                    where
                        a.entrp_id = p_entrp_id;

                end if;

            else -- Renewal

                select
                    batch_number
                into l_batch_num
                from
                    online_compliance_staging
                where
                        entrp_id = p_entrp_id
                    and source = p_source;

            end if;

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num', l_batch_num);
    -- L_status added by rprabu for 7992
    --  IF l_batch_num IS NULL  OR ( L_status ='C'  THEN commented by Joshi for 10431

    -- Added by Joshi for 10341
        if l_batch_num is null
           or (
            l_status = 'C'
            and pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id) <> 'R'
        ) then      --New Acct
            select
                batch_num_seq.nextval
            into x_batch_number
            from
                dual;

        else
            x_batch_number := l_batch_num; --Already created data
        end if;

    exception
        when no_data_found then
            select
                batch_num_seq.nextval
            into x_batch_number
            from
                dual;

            pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num when NO_DATA_FOUND ', x_batch_number);
        when others then
            select
                batch_num_seq.nextval
            into x_batch_number
            from
                dual;

            pc_log.log_error('PC_EMPLOYER_ENROLL.Generate Batch Num when others ', x_batch_number);
    end generate_batch_number;

    procedure delete_contact (
        p_batch_number  in varchar2,
        p_contact_id    in varchar2,
        p_entrp_id      in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_contact_type      varchar2(20);
        l_enrolle_type      varchar2(20); -- added by jaggi 9734
        l_contact_id        number;       -- added by jaggi 9734
        l_cnt               number;
        l_flag              varchar2(10);
        l_page_no           number := 0;    -- 6346 rprabu FSA   Ticket #6346
        l_account_type      varchar2(100); -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        l_acct_payment_fees varchar2(100); -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        l_acct_type         varchar2(10);   -- Added for Prod Ticket#11612 by Swamy
        l_broker_cnt        number;         -- Added for Prod Ticket#11612 by Swamy
        l_check_flag        varchar2(10);   -- Added for Prod Ticket#11612 by Swamy
        l_source            varchar2(10);   -- Added for Prod Ticket#11612 by Swamy
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.DELETE CONTACT', 'In Proc');
        begin
            select
                nvl(enrolle_type, 'EMPLOYER'),
                account_type
            into
                l_enrolle_type,
                l_acct_type
            from
                account
            where
                entrp_id = p_entrp_id;

        end;
   -- Added for Prod Ticket#11612 by Swamy
        l_check_flag := 'TRUE';
        if l_acct_type = 'COBRA' then
            for l_cob in (
                select
                    source
                from
                    online_compliance_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                l_source := l_cob.source;
            end loop;

            if l_source = 'RENEWAL' then
                l_check_flag := 'FALSE';
            end if;
        end if;

    -- Below code added by swamy for ticket#5469
        for i in (
            select
                *
            from
                table ( in_list(p_contact_id, ',') )
        ) loop
            pc_log.log_error('PC_EMPLOYER_ENROLL.DELETE CONTACT..', p_contact_id);
            select
                contact_type,
                account_type -- account_type Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
            into
                l_contact_type,
                l_account_type
            from
                contact_leads
            where
                contact_id = i.column_value;

            pc_log.log_error('PC_EMPLOYER_ENROLL.DELETE CONTACT..', l_contact_type);
      --In case there is no Primary Contact or if Broker/GA is not setup for send invoice flag as 1. Then we mark record as Inactive
            if l_contact_type in ( 'PRIMARY', 'BROKER' ) then    -- BROKER Added by Swamy for Ticket#11104(11170)
                select
                    count(*)
                into l_cnt
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = l_account_type
                    and contact_type = l_contact_type;  -- Added  by Swamy for Ticket#11104(11170)
        --AND contact_type = 'PRIMARY';     -- Commented  by Swamy for Ticket#11104(11170)
                if l_cnt = 1 then                   -- If only one primary contact then we should update teh page Invalid bcoz noprimary contact.
                    if l_account_type in ( 'FSA', 'HRA' ) then -- Start Added By RPRABU 27/07/2018 ticket 6346 For Development Of FSA Enrollment
            --- Added for  the Ticket #6346
                        if l_account_type = 'FSA' then
                            l_page_no := 3;
                        elsif l_account_type = 'HRA' then
                            l_page_no := 4;
                        end if;

                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => l_account_type,
                            p_page_no       => l_page_no,
                            p_block_name    => 'CONTACT_INFORMATION',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );

			---- FORM_5500 7015 ADDED BY RPRABU 15/12/2018
                    elsif l_account_type in ( 'ERISA_WRAP', 'HSA', 'FORM_5500' ) then -- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => l_account_type,
                            p_page_no       => '2',
                            p_block_name    => 'CONTACT_INFORMATION',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );
                    else -- End By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
  --- 9392 rprabu 08/10/2020  Arrow Functionality   POP and COBRA
                        if l_account_type = 'POP' then
                            l_page_no := 2;
                        elsif l_account_type = 'COBRA' then
                            l_page_no := 3;
                        end if;
               ---9392 rprabu 07/10/2020
                        if l_check_flag = 'TRUE' then  -- Added for Prod Ticket#11612 by Swamy for COBRA RENEWAL we dont need contact information
                            pc_employer_enroll.upsert_page_validity(
                                p_batch_number  => p_batch_number,
                                p_entrp_id      => p_entrp_id,
                                p_account_type  => l_account_type,
                                p_page_no       => l_page_no,
                                p_block_name    => 'CONTACT_INFORMATION',
                                p_validity      => 'I',
                                p_user_id       => null,
                                x_error_status  => x_error_status,
                                x_error_message => x_error_message
                            );

                            update online_compliance_staging
                            set
                                page3_contact = 'I'
                            where
                                batch_number = p_batch_number;

                        end if;

                    end if;

                end if;

            end if; --Primary Conatct loop

      -- Added by Joshi for 9033 --- GA added by rprabu 24/09/2020   Ticket #9468
            if
                l_contact_type in ( 'BROKER', 'GA' )
                and l_account_type = 'COBRA'
            then
                select
                    count(*)
                into l_broker_cnt
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = l_account_type
                    and contact_type in ( 'BROKER', 'GA' );  ---- GA added by rprabu 24/09/2020   Ticket #9468

                if l_broker_cnt = 1 then
                    update online_compliance_staging
                    set
                        page3_contact = 'I'
                    where
                        batch_number = p_batch_number;

                end if;

            end if;
      -- 9033 ends here.
        -- Added By Jaggi 9734
            if
                l_enrolle_type = 'GA'
                and l_contact_type = 'BROKER'
                and l_account_type in ( 'COBRA', 'POP' )
            then
                select
                    count(*),
                    min(contact_id)
                into
                    l_broker_cnt,
                    l_contact_id
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = l_account_type
                    and contact_type in ( 'BROKER' );

                if
                    l_broker_cnt = 1
                    and l_contact_id = i.column_value
                then
                    update online_compliance_staging
                    set
                        page3_contact = 'I'
                    where
                        batch_number = p_batch_number;

                end if;

            end if;
       -- end here --

      --- added by rprabu for 6346  , FORM_5500 added by rprabu on 21/12/2018 for 7015
            if l_account_type in ( 'FSA', 'HRA', 'FORM_5500' ) then
                select
                    count(entity_id) count_rec
                into l_flag
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = l_account_type
                    and send_invoice in ( '1', 'Y' );

                begin
                    if l_account_type = 'FORM_5500' then  --FORM_5500 added by rprabu on 21/12/2018 for 7015
                        select
                            nvl(pay_acct_fees, 'X')
                        into l_acct_payment_fees
                        from
                            online_form_5500_staging
                        where
                                entrp_id = p_entrp_id
                            and batch_number = p_batch_number;

                    else
                        select
                            nvl(pay_acct_fees, 'X')
                        into l_acct_payment_fees
                        from
                            online_fsa_hra_staging
                        where
                                entrp_id = p_entrp_id
                            and batch_number = p_batch_number;

                    end if;

                end;

            else -- pay_acct_fees
                if l_account_type <> 'HSA' then  /*Ticket#7016 */
                    select
                        send_invoice,
                        acct_payment_fees -- acct_payment_fees added by swamy Ticket#6294
                    into
                        l_flag,
                        l_acct_payment_fees
                    from
                        online_compliance_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number;

                end if;
        /*Ticket#5020 */
            end if;

            if l_flag = '1' then
                select
                    count(*)
                into l_cnt
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = l_account_type
                    and contact_type in ( 'BROKER', 'GA' );

                if l_cnt = 1 then                  -- If only broker or GA is not there then we shud invalidate it
                    if l_account_type in ( 'FSA', 'HRA', 'FORM_5500' ) then -- Added By RPRABU on  27/07/2018 ticket 6346 For Development Of FSA Enrollment
            --- Added for  the Ticket #6346
                        if l_account_type = 'FSA' then
                            l_page_no := 3;
                        elsif l_account_type = 'HRA' then
                            l_page_no := 4;
                        elsif l_account_type = 'FORM_5500' then --- 7015 done by rprabu on 15/12/2018
                            l_page_no := 2;
                        end if;

                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => l_account_type,
                            p_page_no       => l_page_no,
                            p_block_name    => 'INVOICING_PAYMENT',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );

                    elsif l_account_type = 'ERISA_WRAP' then -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => l_account_type,
                            p_page_no       => '2',
                            p_block_name    => 'INVOICING_PAYMENT',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );
                    else -- End by swamy Ticket#6294
                        update online_compliance_staging
                        set
                            page3_payment = 'I'
                        where
                            batch_number = p_batch_number;

                    end if;

                end if;

            end if; --Send Invoice Flag
      -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
            if l_acct_payment_fees in ( 'GA', 'BROKER' ) then
        /*Ticket#6617 */
                l_cnt := 0;
                select
                    count(*)
                into l_cnt
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and contact_type = l_acct_payment_fees
                    and account_type = l_account_type;

                if nvl(l_cnt, 0) = 1 then
          --- Added for  the Ticket #6346  BY RPRABU
                    if l_account_type = 'FSA' then
                        l_page_no := 3;
                    elsif l_account_type = 'HRA' then
                        l_page_no := 4;
                    elsif l_account_type = 'FORM_5500' then -- 7015 DONE BY RPRABU 15/12/2018
                        l_page_no := 2;
                    end if;

                    if l_account_type in ( 'FSA', 'HRA', 'FORM_5500' ) then -- Added By RPRABU on  27/07/2018 ticket 6346 For Development Of FSA Enrollment
                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => l_account_type,
                            p_page_no       => l_page_no,
                            p_block_name    => 'INVOICING_PAYMENT',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );

                    elsif l_account_type = 'ERISA_WRAP' then
                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => l_account_type,
                            p_page_no       => '2',
                            p_block_name    => 'INVOICING_PAYMENT',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );
                    elsif l_account_type = 'POP' then
            /*Ticket#6617 */
                        update online_compliance_staging
                        set
                            page3_payment = 'I'
                        where
                            batch_number = p_batch_number;
			 --- 9392 rprabu 08/10/2020  Arrow Functionality
                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => l_account_type,
                            p_page_no       => '2',
                            p_block_name    => 'INVOICING_PAYMENT',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );

                    end if;

                end if;
        /*Cnt loop */
            end if;
      /* Acct Payment fees */
      -- End Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
            delete from contact_leads
            where
                contact_id = i.column_value;

        end loop;

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.DELETE CONTACT', 'Error ' || sqlerrm);
    end delete_contact;

    procedure update_invoice_bank_info (
        p_batch_number               in varchar2,
        p_entrp_id                   in number,
        p_salesrep_flag              in varchar2,    -- Ticket #6882
        p_salesrep_id                in number,
        p_pay_acct_fees              in varchar2,
        p_invoice_flag               in varchar2,
        p_funding_option             in varchar2,
        p_bank_name                  in varchar2,
        p_account_type               in varchar2,
        p_routing_num                in varchar2,
        p_account_num                in varchar2,
        p_acct_usage                 in varchar2,
        p_payment_method             in varchar2,
        p_bank_authorize             in varchar2,    -- Added by Jaggi #9602
        p_pay_monthly_fees_by        in varchar2,    -- Added by Jaggi #11263
        p_monthly_fee_payment_method in varchar2,    -- Added by Jaggi #11263
        p_funding_payment_method     in varchar2,    -- Added by Jaggi #11263
        x_error_status               out varchar2,
        x_error_message              out varchar2
    ) is
        l_salesrep_flag varchar2(1);
        l_salesrep_id   number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_INVOICE_BANK_INFO', 'In Proc');
    --  -- Added by rprabu for the Ticket #6882 on 12/10/2018
        if p_salesrep_flag = 'Y' then
            l_salesrep_id := p_salesrep_id;
        elsif p_salesrep_flag = 'N' then
            l_salesrep_id := null;
        end if;

        update online_fsa_hra_staging
        set
            salesrep_id = l_salesrep_id,
            salesrep_flag = p_salesrep_flag,                        -- Added by rprabu for the Ticket #6882 on 12/10/2018
            pay_acct_fees = p_pay_acct_fees,
            monthly_fees_paid_by = p_pay_monthly_fees_by,              -- Added by Jaggi #11263
            monthly_fee_payment_method = p_monthly_fee_payment_method, -- Added by Jaggi #11263
            funding_payment_method = p_funding_payment_method,     -- Added by Jaggi #11263
            invoice_flag = p_invoice_flag,
            bank_name = p_bank_name,
            routing_number = p_routing_num,
            bank_acc_num = p_account_num,
            bank_acc_type = p_account_type,
            acct_usage = p_acct_usage,
            fund_option = p_funding_option,
            payment_method = p_payment_method,
            bank_authorize = p_bank_authorize
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;
    --- p_invoice_flag is send invoice option 19/09/2018
        update contact_leads
        set
            send_invoice = p_invoice_flag
        where
            entity_id = pc_entrp.get_tax_id(p_entrp_id);

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_INVOICE_BANK_INFO', 'Error ' || sqlerrm);
    end update_invoice_bank_info;

    procedure process_fsa_enrollment_renewal (
        p_batch_number       in number,
        p_entrp_id           in number,
        p_user_id            in number,
      --Added Renewal parameters
        p_broker_name        in varchar2 default null,
        p_broker_license_num in varchar2 default null,
        p_broker_contact     in varchar2_tbl,
        p_broker_contact_id  in varchar2_tbl,
        p_broker_email       in varchar2_tbl,
        p_ga_name            in varchar2 default null,
        p_ga_license_num     in varchar2 default null,
        p_ga_contact         in varchar2_tbl,
        p_ga_contact_id      in varchar2_tbl,
        p_ga_email           in varchar2_tbl,
        p_send_invoice       in varchar2 default null,
        p_bank_acct_id       out number,                  -- Added by Swamy for Ticket#12309
        x_error_status       out varchar2,
        x_error_message      out varchar2
    ) is

        l_aff_entrp_id         number;
        l_return_status        varchar2(10);
        l_error_message        varchar2(100);
        l_ctrl_entrp_id        number;
        l_acc_id               number;
        l_acc_num              varchar2(100);
        l_ben_plan_id          number;
        l_bank_id              number;
        l_acct_usage           varchar2(100);
        l_broker_email         varchar2(100);
        l_ga_email             varchar2(100);
    --Ticket#4429
        l_grace                varchar2(2) := null;
        l_all_debit_card       varchar2(1) := 'N'; --- ticket 7110 on 19/11/2018
        l_prev_ben_plan_id     number := null;   --- 7335 rprabu 21/01/2020
        l_plan_fund_option     online_fsa_hra_plan_staging.funding_option%type;   -- Added by Swamy for Ticket#10562(Dev ticket#9601 ) 16/11/2021
        l_renewed_by           varchar2(30);
        l_resubmit_flag        varchar2(1);
        l_inactive_plan_exist  varchar2(1);
        l_org_ben_plan_id      number;
        l_broker_id            number;
        l_authorize_req_id     number;
        l_pay_acct_fees        varchar2(30);
        l_entity_id            number;
        l_entity_type          varchar2(50);
        l_bank_count           number;
        l_renewal_sign_type    varchar2(30);
        l_active_bank_exists   varchar2(3) := '*';
        l_create_error exception;
        l_sales_team_member_id number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'In Proc');
        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments batch number', p_batch_number
                                                                                    || ' p_entrp_id :='
                                                                                    || p_entrp_id);
        x_error_status := 'S';
        l_inactive_plan_exist := nvl(
            pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
            'N'
        );

	 -- Added resubmit flag 10430 Joshi
        select
            acc_id,
            acc_num,
            nvl(resubmit_flag, 'N'),
            renewal_sign_type
        into
            l_acc_id,
            l_acc_num,
            l_resubmit_flag,
            l_renewal_sign_type
        from
            account
        where
            entrp_id = p_entrp_id;

        for x in (
            select
                *
            from
                online_fsa_hra_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            savepoint enroll_renewal_savepoint;  -- Added by Swamy for Ticket#12309
            l_pay_acct_fees := x.pay_acct_fees; -- Added by Jaggi #11119
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments l_pay_acct_fees', l_pay_acct_fees);
            if x.source is null then --Enrollments IF
      -- Added by Jaggi #11263
                if pc_account.get_broker_id(l_acc_id) = 0 then
                    for j in (
                        select
                            broker_id
                        from
                            online_users ou,
                            broker       b
                        where
                                user_id = p_user_id
                            and user_type = 'B'
                            and upper(tax_id) = upper(broker_lic)
                    ) loop
                        update account
                        set
                            broker_id = j.broker_id
                        where
                            entrp_id = p_entrp_id;

                    end loop;
                end if;
     -- added by Jaggi #11629
                if x.salesrep_id is not null then
                    pc_sales_team.upsert_sales_team_member(
                        p_entity_type           => 'SALES_REP',
                        p_entity_id             => x.salesrep_id,
                        p_mem_role              => 'PRIMARY',
                        p_entrp_id              => p_entrp_id,
                        p_start_date            => trunc(sysdate),
                        p_end_date              => null,
                        p_status                => 'A',
                        p_user_id               => p_user_id,
                        p_pay_commission        => null,
                        p_note                  => null,
                        p_no_of_days            => null,
                        px_sales_team_member_id => l_sales_team_member_id,
                        x_return_status         => l_return_status,
                        x_error_message         => x_error_message
                    );

                end if;
	  --- Added the  for loop for the Ticket #7110 ( Allow debit card information is not displaying in ??mployer Account page??number: 39)
                for z in (
                    select
                        count(all_debit_card) debit_count,
                        max(renewal_new_plan) renewal_new_plan  -- Added by Swamy for 11002 (Dev Ticket#10751)
                    from
                        online_fsa_hra_plan_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                        and all_debit_card = 'Y'
                ) loop
                    l_all_debit_card := 'Y';
       -- Only for New enrollments the below card_allowed should be updated, Not for new enrollments done from Renewal page.
                    if nvl(z.renewal_new_plan, 'N') = 'N' then   -- Added by Swamy for 11002 (Dev Ticket#10751)
                        if z.debit_count > 0 then
                            update enterprise
                            set
                                card_allowed = 0
                            where
                                entrp_id = p_entrp_id;

                        else
                            update enterprise
                            set
                                card_allowed = 1
                            where
                                entrp_id = p_entrp_id;

                        end if;

                    end if;

                end loop;

                if l_all_debit_card = 'N' then
                    update enterprise
                    set
                        card_allowed = 1
                    where
                        entrp_id = p_entrp_id;

                end if;

	   -- End for the Ticket #7110
                update enterprise
                set
                    state_of_org = x.state_of_org,
                    no_of_eligible = x.fsa_eligib_ee,  --Eligible ees
                    entity_type = x.type_of_entity
                where
                    entrp_id = p_entrp_id;

	-- Added by Joshi 10431. need to delete existing affliated ER incase of resubmission
                if
                    l_resubmit_flag = 'Y'
                    and nvl(x.source, 'E') <> 'RENEWAL'
                then
                    delete from enterprise
                    where
                        entrp_id in (
                            select
                                entity_id
                            from
                                entrp_relationships
                            where
                                    entrp_id = p_entrp_id
                                and entity_type = 'ENTERPRISE'
                                and relationship_type = 'AFFILIATED_ER'
                        )
                        and entrp_code is null;

                    delete from entrp_relationships
                    where
                            entrp_id = p_entrp_id
                        and entity_type = 'ENTERPRISE'
                        and relationship_type = 'AFFILIATED_ER';
             -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
             -- user might update existing  contacts.
                    for c in (
                        select
                            contact_id
                        from
                            contact_leads
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'FSA'
                            and ref_entity_type = 'ONLINE_ENROLLMENT'
                    ) loop
                        delete from contact
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and contact_id = c.contact_id;

                        delete from contact_role
                        where
                            contact_id = c.contact_id;

                    end loop;

                    update user_bank_acct
                    set
                        status = 'I'
                    where
                        acc_id = l_acc_id;

           /* commented and added below by Joshi for #12339. Ben plan deletion issue
             FOR B IN (  SELECT ben_plan_id
                         FROM ben_plan_enrollment_setup
                        WHERE acc_id = l_acc_id AND entrp_id = p_entrp_id) */

                    for b in (
                        select
                            bp.ben_plan_id
                        from
                            ben_plan_enrollment_setup   bp,
                            online_fsa_hra_staging      os,
                            online_fsa_hra_plan_staging ops
                        where
                                os.batch_number = p_batch_number
                            and os.entrp_id = p_entrp_id
                            and os.batch_number = ops.batch_number
                            and os.enrollment_id = ops.enrollment_id
                            and os.entrp_id = bp.entrp_id
                            and ops.ben_plan_id = bp.ben_plan_id
                    ) loop
                        delete from ben_plan_coverages
                        where
                                acc_id = l_acc_id
                            and ben_plan_id = b.ben_plan_id;

                        delete from custom_eligibility_req
                        where
                                entity_id = b.ben_plan_id
                            and source = 'FSA';

                -- Delete all the ben_plan_enrollment_data. 10431 Joshi
                        delete from ben_plan_enrollment_setup
                        where
                                acc_id = l_acc_id
                            and entrp_id = p_entrp_id
                            and ben_plan_id = b.ben_plan_id;

                    end loop;

         -- Delete all the ben_plan_enrollment_data. 10431 Joshi
          --  DELETE FROM ben_plan_enrollment_setup
        --    WHERE acc_id = l_acc_id AND entrp_id = p_entrp_id;

           -- For resubmit, system should delete and recreate, if not deleting, then wrong invoice amount is generated as the no of eligile value is comming wrong if there are many inserts with different values on the same day
                    delete from enterprise_census
                    where
                            entity_id = p_entrp_id
                        and entity_type = 'ENTERPRISE'
                        and census_code = 'NO_OF_ELIGIBLE';  -- Added by Swamy for Ticket#11254(Main Ticket=>11119)
                    delete from enterprise_census
                    where
                            entity_id = p_entrp_id
                        and entity_type = 'ENTERPRISE'
                        and census_code = 'NO_OF_EMPLOYEES'; -- Added by Swamy for Ticket#11254(Main Ticket=>11119)

                end if;
         --- Ends here : 10430

        /***Create Affliated ER **/

                for j in (
                    select
                        *
                    from
                        entrp_relationships_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and relationship_type = 'AFFLIATED_ER'
                ) loop
                    if j.entity_name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   10,
                                   j.entity_name,
                                   p_user_id,
                                   sysdate ) returning entrp_id into l_aff_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                            ,
                            p_entity_id     => l_aff_entrp_id                                          ---Affliated ER
                            ,
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'AFFILIATED_ER',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if;
                end loop;

        /**Craete Controlled Grp ER ***/

                for j in (
                    select
                        *
                    from
                        entrp_relationships_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and relationship_type = 'CONTROLLED_GRP_ER'
                ) loop
                    if j.entity_name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   10,
                                   j.entity_name,
                                   p_user_id,
                                   sysdate ) returning entrp_id into l_ctrl_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                            ,
                            p_entity_id     => l_ctrl_entrp_id                                         ---Cntrl Grp ER
                            ,
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'CONTROLLED_GROUP',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if;
                end loop;

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'After creating Affliated and Controlled Grp ');
        /*** Update Account Preference *****/
        --Update Account Preference Table
        /*   ---   Commented by  Ticket #6944 by rprabu on 25/09/2018
        INSERT INTO account_preference
        (ACCOUNT_PREFERENCE_ID
        ,ACC_ID
        ,ENTRP_ID
        ,STATUS
        ,ALLOW_EOB
        ,PIN_MAILER_ALLOWED
        ,teamster_group
        ,ALLOW_EXP_ENROLL
        ,MAINT_FEE_PAID_BY
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,allow_online_renewal
        ,allow_election_changes
        ,NDT_PREFERENCE
        ,fees_paid_by
        )
        VALUES
        (account_preference_seq.NEXTVAL
        ,L_acc_id
        ,p_entrp_id
        ,'A'
        ,'Y'
        ,'N'
        ,'N'
        ,'Y'
        ,NULL
        ,SYSDATE
        ,p_user_id
        ,SYSDATE
        ,p_user_id
        ,'Y'
        ,'N'
        ,upper(X.ndt_preference)
        ,upper(X.pay_acct_fees));*/
        ---    Ticket #6944 by rprabu on 25/09/2018
                pc_account.upsert_acc_pref(
                    p_entrp_id               => p_entrp_id,
                    p_acc_id                 => l_acc_id,
                    p_claim_pay_method       => null,
                    p_auto_pay               => null,
                    p_plan_doc_only          => null,
                    p_status                 => 'A',
                    p_allow_eob              => 'Y',
                    p_user_id                => p_user_id,
                    p_pin_mailer             => 'N',
                    p_teamster_group         => 'N',
                    p_allow_exp_enroll       => 'Y',
                    p_maint_fee_paid         => null,
                    p_allow_online_renewal   => 'Y',
                    p_allow_election_changes => 'N',
                    p_plan_action_flg        => 'Y',
                    p_submit_election_change => 'Y',
                    p_edi_flag               => 'N',
                    p_vendor_id              => null,
                    p_reference_flag         => null,
                    p_allow_payroll_edi      => null,
                    p_fees_paid_by           => null
                );    -- Added by Swamy for Ticket#11037 );
        ---    Added for the Ticket #6944 by rprabu on 25/09/2018
                update account_preference
                set
                    ndt_preference = upper(x.ndt_preference),
                    fees_paid_by = upper(x.pay_acct_fees)
                where
                    entrp_id = p_entrp_id;

        --Update Enterprise Census
                insert into enterprise_census values ( p_entrp_id,
                                                       'ENTERPRISE',
                                                       'NO_OF_EMPLOYEES',
                                                       x.total_number_ees,
                                                       sysdate,
                                                       p_user_id,
                                                       sysdate,
                                                       p_user_id,
                                                       null );

        -- Start Addition by Swamy for Ticket#7606
                if nvl(x.fsa_eligib_ee, 0) <> 0 then
                    insert into enterprise_census (
                        entity_id,
                        entity_type,
                        census_code,
                        census_numbers,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        ben_plan_id
                    ) values ( p_entrp_id,
                               'ENTERPRISE',
                               'NO_OF_ELIGIBLE',
                               x.fsa_eligib_ee,
                               sysdate,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               null );

                end if;
      -- End of Addition by Swamy for Ticket#7606

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'Census Data created successfully ');
        /*****************Update Contact Info ***************/

     -- Added by Joshi for 10431. need to delete existing contacts and reinsert as in case of resubmit
     -- user might update existing  contacts.
                if l_resubmit_flag = 'Y' then
                    delete from contact
                    where
                        contact_id in (
                            select
                                contact_id
                            from
                                contact_leads
                            where
                                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                                and account_type = 'FSA'
                        );

                end if;

                insert into contact (
                    contact_id,
                    first_name,
                    last_name,
                    entity_id,
                    entity_type,
                    email,
                    status,
                    start_date,
                    last_updated_by,
                    created_by,
                    last_update_date,
                    creation_date,
                    can_contact,
                    contact_type,
                    user_id,
                    phone,
                    fax,
                    title,
                    account_type
                )
                    select
                        contact_id,
                        substr(first_name,
                               0,
                               instr(first_name, ' ', 1, 1) - 1),
                        substr(first_name,
                               instr(first_name, ' ', 1, 1) + 1,
                               length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                        entity_id,
                        'ENTERPRISE',
                        email,
                        'A',
                        sysdate,
                        p_user_id,
                        p_user_id,
                        sysdate,
                        sysdate,
                        'Y',
                        contact_type,
                        null,
                        phone_num,
                        contact_fax,
                        job_title,
                        'FSA'
                    from
                        contact_leads a
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and not exists (
                            select
                                1
                            from
                                contact b
                            where
                                a.contact_id = b.contact_id
                        )     -------- 7783 rprabu 31/10/2019
                        and account_type = 'FSA';

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'Contact Data created successfully ');
        /** For all contacts added define contact roles etc */
        --Ticket#6555
                for xx in (
                    select
                        *
                    from
                        contact_leads a
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and not exists (
                            select
                                1
                            from
                                contact_role b
                            where
                                a.contact_id = b.contact_id
                        )     -------- 7783 rprabu 31/10/2019
                ) loop
                    insert into contact_role e (
                        contact_role_id,
                        contact_id,
                        role_type,
                        account_type,
                        effective_date,
                        created_by,
                        last_updated_by
                    ) values ( contact_role_seq.nextval,
                               xx.contact_id,
                               xx.account_type,
                               xx.account_type,
                               sysdate,
                               p_user_id,
                               p_user_id );
          --Especially for compliance we need to have both account type and role type defined
                    insert into contact_role e (
                        contact_role_id,
                        contact_id,
                        role_type,
                        account_type,
                        effective_date,
                        created_by,
                        last_updated_by
                    ) values ( contact_role_seq.nextval,
                               xx.contact_id,
                               xx.contact_type,
                               xx.account_type,
                               sysdate,
                               p_user_id,
                               p_user_id );
          --For all products we want Fee Invoice option also checked
          --Ticket#6555
                    if xx.contact_type = 'PRIMARY'
                    or xx.send_invoice in ( 'Y', '1' ) then
                        insert into contact_role e (
                            contact_role_id,
                            contact_id,
                            role_type,
                            account_type,
                            effective_date,
                            created_by,
                            last_updated_by
                        ) values ( contact_role_seq.nextval,
                                   xx.contact_id,
                                   'FEE_BILLING',
                                   xx.account_type,
                                   sysdate,
                                   p_user_id,
                                   p_user_id );

                    end if;

                end loop;

            else -- Renewals loop
                pc_log.log_error('Process_fsa_enrolllment_renewal', 'Before Renewal Broker Info' || p_broker_name);
                for i in 1..p_broker_contact.count loop
                    pc_web_compliance.update_contact_info(
                        p_contact_id      => p_broker_contact_id(i),
                        p_entrp_id        => p_entrp_id,
                        p_first_name      => p_broker_contact(i),
                        p_email           => p_broker_email(i),
                        p_account_type    => 'FSA',
                        p_contact_type    => 'BROKER',
                        p_user_id         => p_user_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'ENTERPRISE',
                        p_send_invoice    => x.invoice_flag, --p_send_invoice,
                        p_status          => 'A',
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    l_broker_email := p_broker_email(i);
                end loop;

                if p_broker_name is not null then
                    pc_broker.insert_sales_team_leads(
                        p_first_name      => null,
                        p_last_name       => null,
                        p_license         => p_broker_license_num,
                        p_agency_name     => p_broker_name,
                        p_tax_id          => null,
                        p_gender          => null,
                        p_address         => null,
                        p_city            => null,
                        p_state           => null,
                        p_zip             => null,
                        p_phone1          => null,
                        p_phone2          => null,
                        p_email           => l_broker_email --any last email of contact is assigned
                        ,
                        p_entrp_id        => p_entrp_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'BEN_PLAN_RENEWALS',
                        p_lead_source     => 'RENEWAL',
                        p_entity_type     => 'BROKER'
                    );
                end if;

                for i in 1..p_ga_contact.count loop
                    pc_web_compliance.update_contact_info(
                        p_contact_id      => p_ga_contact_id(i),
                        p_entrp_id        => p_entrp_id,
                        p_first_name      => p_ga_contact(i),
                        p_email           => p_ga_email(i),
                        p_account_type    => 'FSA',
                        p_contact_type    => 'GA',
                        p_user_id         => p_user_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'ENTERPRISE',
                        p_send_invoice    => x.invoice_flag,--p_send_invoice,
                        p_status          => 'A',
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    l_ga_email := p_ga_email(i);
                end loop; --Ga entry
                if p_ga_name is not null then
                    pc_broker.insert_sales_team_leads(
                        p_first_name      => null,
                        p_last_name       => null,
                        p_license         => p_ga_license_num,
                        p_agency_name     => p_ga_name,
                        p_tax_id          => null,
                        p_gender          => null,
                        p_address         => null,
                        p_city            => null,
                        p_state           => null,
                        p_zip             => null,
                        p_phone1          => null,
                        p_phone2          => null,
                        p_email           => l_ga_email,
                        p_entrp_id        => p_entrp_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'BEN_PLAN_RENEWALS',
                        p_lead_source     => 'RENEWAL',
                        p_entity_type     => 'GA'
                    );
                end if;

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal', 'Created Broker GA Info.. ');
            end if; --Enrollments IF

      ---    Added for the Ticket #9646 by Jaggi on 22/01/2021 for Renewal
            update account_preference
            set
                ndt_preference = upper(x.ndt_preference)
            where
                entrp_id = p_entrp_id;
     --

      /****Update Bank Info *****/
       /* commented by Joshi 11263 as ther will always be multiples bank accounts entered for SETUP/MONTHLY/CLAIM.
      IF X.bank_name   IS NOT NULL THEN
        IF X.source     = 'RENEWAL' THEN
          l_acct_usage := 'INVOICE' ;
        ELSE
          SELECT
            CASE
              WHEN X.acct_usage= 'ALL'
              THEN 'OFFICE'
              WHEN X.acct_usage = 'FEE'
              THEN 'INVOICE'
              WHEN X.acct_usage = 'FUNDING'
             --  THEN 'INVOICE'
              THEN 'FUNDING'  -- Added by Jaggi #11119
              ELSE 'CLAIMS'
            END
          INTO l_acct_usage
          FROM dual;
        END IF; --Renewal/Enrollments

  IF X.source     = 'RENEWAL' THEN   -- Added Jaggi/Swamy for Ticket#11040 on 05/04/2022
      pc_employer_enroll.insert_user_bank_acct
           (p_acc_num           => l_acc_num ,
            p_display_name      => x.bank_name ,
            p_bank_acct_type    => x.bank_acc_type ,
            p_bank_routing_num  => x.routing_number ,
            p_bank_acct_num     => x.bank_acc_num ,
            p_bank_name         => x.bank_name ,
            p_user_id           => p_user_id ,
            p_acct_usage        => l_acct_usage ,
            x_bank_acct_id      => l_bank_id ,
            x_return_status     => l_return_status ,
            x_error_message     => l_error_message );
    ELSE
            pc_user_bank_acct.insert_bank_account(
                     p_entity_id          => l_acc_id
                    ,p_entity_type        => 'ACCOUNT'
                    ,p_display_name       => x.bank_name
                    ,p_bank_acct_type     => x.bank_acc_type
                    ,p_bank_routing_num   => x.routing_number
                    ,p_bank_acct_num      => x.bank_acc_num
                    ,p_bank_name          => x.bank_name
                    ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                    ,p_user_id            => p_user_id
                    ,x_bank_acct_id       => l_bank_id
                    ,x_return_status      => l_return_status
                    ,x_error_message      => l_error_message);
    END IF;

        ----------new  code Below added by rprabu function to get MULTI BANK FUNCTIONALITY ticket 6346
      ELSE*/

            pc_log.log_error('Process_fsa_enrolllment_renewal', 'Before Renewal Broker Info p_batch_number '
                                                                || p_batch_number
                                                                || ' X.source :='
                                                                || x.source
                                                                || ' p_entrp_id :='
                                                                || p_entrp_id);
    -- Added by Swamy for Ticket#12309
    -- If there is no active bank account then the account status should change to pending bank verification.
            if nvl(x.source, 'E') = 'E' then
                for j in (
                    select
                        'P' cnt
                    from
                        user_bank_acct_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and bank_status in ( 'P', 'W' )
                ) loop
                    l_active_bank_exists := j.cnt;
                end loop;
            else
                l_active_bank_exists := 'A';
            end if;

            if nvl(x.source, 'E') = 'E' then  -- Added by Swamy for Ticket#12309
      -- Added By Joshi for 11263. Store as per the bank account usage.
      -- Enrollment
                for bank_rec in (
                    select
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
                        bank_status,            -- Start Addition by Swamy for Ticket#10978 13062024
                        business_name,
                        giac_response,
                        giac_verify,
                        giac_authenticate,
                        giac_verified_response,
                        bank_acct_verified    -- End of Addition by Swamy for Ticket#10978 13062024
                    from
                        user_bank_acct_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                ) loop
                    select
                        case
                            when bank_rec.acct_usage = 'ALL'     then
                                'OFFICE'
                            when bank_rec.acct_usage in ( 'FEE', 'MONTHLY' ) -- Added by Jaggi #11263
                             then
                                'INVOICE'
                            when bank_rec.acct_usage = 'FUNDING' then
                                'FUNDING'
                            else
                                'CLAIMS'
                        end
                    into l_acct_usage
                    from
                        dual;

                    l_bank_id := null;
                    if bank_rec.acct_usage in ( 'FEE', 'MONTHLY' ) then
                        if bank_rec.acct_usage = 'FEE' then
                            if upper(x.pay_acct_fees) = 'EMPLOYER' then
                                l_entity_id := l_acc_id;
                                l_entity_type := 'ACCOUNT';
                            elsif upper(x.pay_acct_fees) = 'BROKER' then
                                l_entity_id := pc_account.get_broker_id(l_acc_id);
                                l_entity_type := 'BROKER';
                            elsif upper(x.pay_acct_fees) in ( 'GA', 'GENERAL AGENT' ) then
                                l_entity_id := pc_account.get_ga_id(l_acc_id);
                                l_entity_type := 'GA';
                            end if;

                            update online_fsa_hra_staging
                            set
                                payment_method = 'ACH'
                            where
                                    batch_number = p_batch_number
                                and entrp_id = p_entrp_id;

                        else
                            if upper(x.monthly_fees_paid_by) = 'EMPLOYER' then
                                l_entity_id := l_acc_id;
                                l_entity_type := 'ACCOUNT';
                            elsif upper(x.monthly_fees_paid_by) = 'BROKER' then
                                l_entity_id := pc_account.get_broker_id(l_acc_id);
                                l_entity_type := 'BROKER';
                            elsif upper(x.monthly_fees_paid_by) in ( 'GA', 'GENERAL AGENT' ) then
                                l_entity_id := pc_account.get_ga_id(l_acc_id);
                                l_entity_type := 'GA';
                            end if;
                        end if;

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal l_entity_id: ', l_entity_id);
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal l_entity_type', l_entity_type);
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_acct_usage l', l_acct_usage);
                        l_bank_count := 0;

               /* SELECT COUNT(*) INTO l_bank_count
                  FROM bank_Accounts
                WHERE bank_routing_num = bank_rec.Bank_Routing_Num
                    AND bank_acct_num    = bank_rec.Bank_Acct_Num
                    AND bank_name        = bank_rec.bank_name
                    AND status           = 'A'
                    AND entity_id        = l_entity_id
                    AND entity_type     = l_entity_type
                    AND bank_Account_usage =  l_acct_usage;   -- Added by Swamy for Ticket#12432
                   */

                        l_bank_count := pc_user_bank_acct.get_bank_acct_id(
                            p_entity_id          => l_entity_id,
                            p_entity_type        => l_entity_type,
                            p_bank_acct_num      => bank_rec.bank_acct_num,
                            p_bank_name          => bank_rec.bank_name,
                            p_bank_routing_num   => bank_rec.bank_routing_num,
                            p_bank_account_usage => l_acct_usage,
                            p_bank_acct_type     => bank_rec.bank_acct_type
                        );

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_bank_count l', l_bank_count);
                        if nvl(l_bank_count, 0) = 0 then
                        /*pc_user_bank_acct.insert_bank_account(
                         p_entity_id          => l_entity_id
                        ,p_entity_type        => l_entity_type
                        ,p_display_name       => bank_rec.bank_name
                        ,p_bank_acct_type     => bank_rec.bank_acct_type
                        ,p_bank_routing_num   => bank_rec.Bank_Routing_Num
                        ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                        ,p_bank_name          => bank_rec.bank_name
                        ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                        ,p_user_id            => p_user_id
                        ,x_bank_acct_id       => l_bank_id
                        ,x_return_status      => l_return_status
                        ,x_error_message      => l_error_message);*/

                            pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024

                            (
                                p_acc_num          => l_acc_num,
                                p_entity_id        => l_entity_id,
                                p_entity_type      => l_entity_type,
                                p_display_name     => bank_rec.bank_name,
                                p_bank_acct_type   => bank_rec.bank_acct_type,
                                p_bank_routing_num => bank_rec.bank_routing_num,
                                p_bank_acct_num    => bank_rec.bank_acct_num,
                                p_bank_name        => bank_rec.bank_name,
                                p_business_name    => bank_rec.business_name,
                                p_user_id          => p_user_id,
                                p_gverify          => bank_rec.giac_verify,
                                p_gauthenticate    => bank_rec.giac_authenticate,
                                p_gresponse        => bank_rec.giac_response,
                                p_giact_verify     => bank_rec.giac_verified_response,
                                p_bank_status      => bank_rec.bank_status,
                                p_auto_pay         => 'Y'   -- Added by Swamy for Ticket#12309
                                ,
                                p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                                ,
                                p_division_code    => null,
                                p_source           => 'E',
                                x_bank_acct_id     => l_bank_id,
                                x_return_status    => l_return_status,
                                x_error_message    => x_error_message
                            );

                            if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#10978 13062024
                                raise l_create_error;
                            end if;
                        else
                   /* FOR   B IN (   SELECT bank_Acct_id
                                          FROM bank_Accounts
                                        WHERE bank_routing_num = bank_rec.Bank_Routing_Num
                                            AND bank_acct_num    = bank_rec.Bank_Acct_Num
                                            AND bank_name          = bank_rec.bank_name
                                            AND status                = 'A'
                                            AND entity_id             = l_entity_id
                                            AND entity_type         = l_entity_type 
                                             AND bank_Account_usage =  l_acct_usage)   -- Added by Swamy for Ticket#12432
                    LOOP
                            l_bank_id := b.bank_Acct_id ;
                    END LOOP;*/
                            l_bank_id := l_bank_count;
                        end if;

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_bank_id l', l_bank_id);
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_error_message l', l_error_message);

                -- Upload to file_attachments 
                -- Added by Swamy for Ticket#12309
                        pc_file_upload.giact_insert_file_attachments(
                            p_user_bank_stg_id => bank_rec.user_bank_acct_stg_id,
                            p_attachment_id    => null,
                            p_entity_id        => l_bank_id,
                            p_entity_name      => 'GIACT_BANK_INFO',
                            p_document_purpose => 'GIACT_DOC',
                            p_batch_number     => p_batch_number,
                            p_source           => 'E',
                            x_error_status     => x_error_status,
                            x_error_message    => x_error_message
                        );

                --  added by Jaggi 11263
                        if bank_rec.acct_usage = 'MONTHLY' then
                            update online_fsa_hra_staging
                            set
                                monthly_fee_bank_acct_id = l_bank_id,
                                monthly_fee_payment_method = 'ACH'
                            where
                                    batch_number = p_batch_number
                                and entrp_id = p_entrp_id;

                        end if;

                    end if;

                    if bank_rec.acct_usage in ( 'CLAIMS', 'FUNDING' ) then
                 /*pc_user_bank_acct.insert_bank_account(
                         p_entity_id          => l_acc_id
                        ,p_entity_type        => 'ACCOUNT'
                        ,p_display_name       => bank_rec.bank_name
                        ,p_bank_acct_type     => bank_rec.bank_acct_type
                        ,p_bank_routing_num   => bank_rec.Bank_Routing_Num
                        ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                        ,p_bank_name          => bank_rec.bank_name
                        ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                        ,p_user_id            => p_user_id
                        ,x_bank_acct_id       => l_bank_id
                        ,x_return_status      => l_return_status
                        ,x_error_message      => l_error_message);*/

                        pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024

                        (
                            p_acc_num          => l_acc_num,
                            p_entity_id        => l_acc_id,
                            p_entity_type      => 'ACCOUNT',
                            p_display_name     => bank_rec.bank_name,
                            p_bank_acct_type   => bank_rec.bank_acct_type,
                            p_bank_routing_num => bank_rec.bank_routing_num,
                            p_bank_acct_num    => bank_rec.bank_acct_num,
                            p_bank_name        => bank_rec.bank_name,
                            p_business_name    => bank_rec.business_name,
                            p_user_id          => p_user_id,
                            p_gverify          => bank_rec.giac_verify,
                            p_gauthenticate    => bank_rec.giac_authenticate,
                            p_gresponse        => bank_rec.giac_response,
                            p_giact_verify     => bank_rec.giac_verified_response,
                            p_bank_status      => bank_rec.bank_status,
                            p_auto_pay         => 'Y'    -- Added by Swamy for Ticket#12309 13062024
                            ,
                            p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                            ,
                            p_division_code    => null,
                            p_source           => 'E',
                            x_bank_acct_id     => l_bank_id,
                            x_return_status    => l_return_status,
                            x_error_message    => x_error_message
                        );

                        if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#12309 13062024
                            raise l_create_error;
                        end if;
                        update online_fsa_hra_staging
                        set
                            funding_payment_method = 'ACH'
                        where
                                batch_number = p_batch_number
                            and entrp_id = p_entrp_id;

                -- Upload to file_attachments 
                -- Added by Swamy for Ticket#12309
                        pc_file_upload.giact_insert_file_attachments(
                            p_user_bank_stg_id => bank_rec.user_bank_acct_stg_id,
                            p_attachment_id    => null,
                            p_entity_id        => l_bank_id,
                            p_entity_name      => 'GIACT_BANK_INFO',
                            p_document_purpose => 'GIACT_DOC',
                            p_source           => 'E',
                            p_batch_number     => p_batch_number,
                            x_error_status     => x_error_status,
                            x_error_message    => x_error_message
                        );

                    end if;
    -- Added by Swamy for Ticket#12309.
    -- Ticket#12464, if broker has entered pending activation bank account, then the employer will be in pending bank verification status. When the finance team
    -- activates the bank account in manage giact bank account screen, then the particular employer account status should change to pending verification.
    -- to incorporate this the below bank account details is updated in staging table
                    update user_bank_acct_staging
                    set
                        bank_acct_id = l_bank_id
                    where
                            user_bank_acct_stg_id = bank_rec.user_bank_acct_stg_id
                        and batch_number = p_batch_number
                        and entrp_id = p_entrp_id;

                end loop;

                if l_active_bank_exists = 'P' then
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa updating account l_active_bank_exists l', l_active_bank_exists
                    );
                    update account
                    set
                        account_status = '11'  -- Added by Swamy for Ticket#12309
                    where
                        entrp_id = p_entrp_id;

                end if;

            end if; -- Added by Swamy for Ticket#12309

            if x.source = 'RENEWAL' then -- Added by Swamy for Ticket#12309
         -- Renewals  #Added by Jaggi #11263
                for bank_rec in (
                    select
                        bank_name,
                        routing_number,
                        bank_acc_num,
                        bank_acc_type,
                        acct_usage,
                        monthly_fees_paid_by,
                        monthly_bank_name,
                        monthly_routing_number,
                        monthly_bank_acc_num,
                        monthly_bank_acc_type,
                        bank_status,            -- Start Addition by Swamy for Ticket#12309 13062024
                        business_name,
                        giac_response,
                        giac_verify,
                        giac_authenticate,
                        giac_verified_response,
                        giac_verified_response_monthly,
                        bank_acct_verified,    -- End of Addition by Swamy for Ticket#12309 13062024      
                        giac_verify_monthly,
                        giac_authenticate_monthly,
                        giac_response_monthly,
                        bank_status_monthly,
                        bank_file_attachment_id,
                        monthly_bank_file_attachment_id,
                        enrollment_id
                    from
                        online_fsa_hra_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and ( ( nvl(bank_acc_num, '*') <> '*' )
                              or ( nvl(monthly_bank_acc_num, '*') <> '*' ) )
                ) -- Added by Swamy for Ticket#12309 
                 loop
                    l_acct_usage := 'INVOICE';
                    if bank_rec.acct_usage in ( 'INVOICE' ) then
                        if upper(x.pay_acct_fees) = 'EMPLOYER' then
                            l_entity_id := l_acc_id;
                            l_entity_type := 'ACCOUNT';
                        elsif upper(x.pay_acct_fees) = 'BROKER' then
                            l_entity_id := pc_account.get_broker_id(l_acc_id);
                            l_entity_type := 'BROKER';
                        elsif upper(x.pay_acct_fees) in ( 'GA', 'GENERAL AGENT' ) then
                            l_entity_id := pc_account.get_ga_id(l_acc_id);
                            l_entity_type := 'GA';
                        end if;

                    end if;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal l_entity_id: ', l_entity_id);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal l_entity_type', l_entity_type);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_acct_usage l', l_acct_usage);
                    l_bank_count := 0;

            /*SELECT COUNT(*) INTO l_bank_count
              FROM bank_Accounts
            WHERE bank_routing_num = bank_rec.routing_number
                AND bank_acct_num    = bank_rec.bank_acc_num
                AND bank_name        = bank_rec.bank_name
                AND status           = 'A'
                AND entity_id        = l_entity_id
                AND entity_type     = l_entity_type
                AND bank_Account_usage =  l_acct_usage  ;  -- Added by Joshi for 11493
            */
                    l_bank_count := pc_user_bank_acct.get_bank_acct_id(
                        p_entity_id          => l_entity_id,
                        p_entity_type        => l_entity_type,
                        p_bank_acct_num      => bank_rec.bank_acc_num,
                        p_bank_name          => bank_rec.bank_name,
                        p_bank_routing_num   => bank_rec.routing_number,
                        p_bank_account_usage => l_acct_usage,
                        p_bank_acct_type     => bank_rec.bank_acc_type
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_bank_count l', l_bank_count);
                    if
                        nvl(l_bank_count, 0) = 0
                        and nvl(bank_rec.bank_acc_num, '*') <> '*'
                    then   -- And cond. Added by Swamy for Ticket#12309
                  -- fee bank details
                  /*pc_user_bank_acct.insert_bank_account(
                             p_entity_id          => l_entity_id
                            ,p_entity_type        => l_entity_type
                            ,p_display_name       => bank_rec.bank_name
                            ,p_bank_acct_type     => bank_rec.bank_acc_type
                            ,p_bank_routing_num   => bank_rec.routing_number
                            ,p_bank_acct_num      => bank_rec.bank_acc_num
                            ,p_bank_name          => bank_rec.bank_name
                            ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                            ,p_user_id            => p_user_id
                            ,x_bank_acct_id       => l_bank_id
                            ,x_return_status      => l_return_status
                            ,x_error_message      => l_error_message);*/

                        pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024

                        (
                            p_acc_num          => l_acc_num,
                            p_entity_id        => l_entity_id,
                            p_entity_type      => l_entity_type,
                            p_display_name     => bank_rec.bank_name,
                            p_bank_acct_type   => bank_rec.bank_acc_type,
                            p_bank_routing_num => bank_rec.routing_number,
                            p_bank_acct_num    => bank_rec.bank_acc_num,
                            p_bank_name        => bank_rec.bank_name,
                            p_business_name    => bank_rec.business_name,
                            p_user_id          => p_user_id,
                            p_gverify          => bank_rec.giac_verify,
                            p_gauthenticate    => bank_rec.giac_authenticate,
                            p_gresponse        => bank_rec.giac_response,
                            p_giact_verify     => bank_rec.giac_verified_response,
                            p_bank_status      => bank_rec.bank_status,
                            p_auto_pay         => 'Y'    -- Added by Swamy for Ticket#12309 13062024
                            ,
                            p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                            ,
                            p_division_code    => null,
                            p_source           => 'R',
                            x_bank_acct_id     => l_bank_id,
                            x_return_status    => l_return_status,
                            x_error_message    => x_error_message
                        );

                        if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#12309 13062024
                            raise l_create_error;
                        end if;
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa renewal  l_bank_id l', l_bank_id);
                        update online_fsa_hra_staging
                        set
                            bank_acct_id = nvl(l_bank_id, bank_acct_id)
                        where
                                batch_number = p_batch_number
                            and entrp_id = p_entrp_id;

                    end if;

                -- Upload to file_attachments 
                -- Added by Swamy for Ticket#12309
                    pc_file_upload.giact_insert_file_attachments(
                        p_user_bank_stg_id => bank_rec.enrollment_id,
                        p_attachment_id    => bank_rec.bank_file_attachment_id,
                        p_entity_id        => l_bank_id,
                        p_entity_name      => 'GIACT_BANK_INFO',
                        p_document_purpose => 'GIACT_DOC',
                        p_batch_number     => p_batch_number,
                        p_source           => 'R',
                        x_error_status     => x_error_status,
                        x_error_message    => x_error_message
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_bank_id l', l_bank_id
                                                                                                      || 'bank_rec.monthly_bank_name :='
                                                                                                      || bank_rec.monthly_bank_name
                                                                                                      || 'bank_rec.MONTHLY_FEES_PAID_BY :='
                                                                                                      || bank_rec.monthly_fees_paid_by
                                                                                                      );

            -- Monthly bank details
                    if bank_rec.monthly_bank_name is not null then
                        l_bank_count := 0;
                        l_entity_id := null;
                        l_entity_type := null;
                        if bank_rec.monthly_bank_name is not null then
                            if upper(bank_rec.monthly_fees_paid_by) = 'EMPLOYER' then
                                l_entity_id := l_acc_id;
                                l_entity_type := 'ACCOUNT';
                            elsif upper(bank_rec.monthly_fees_paid_by) = 'BROKER' then
                                l_entity_id := pc_account.get_broker_id(l_acc_id);
                                l_entity_type := 'BROKER';
                            elsif upper(bank_rec.monthly_fees_paid_by) in ( 'GA', 'GENERAL AGENT' ) then
                                l_entity_id := pc_account.get_ga_id(l_acc_id);
                                l_entity_type := 'GA';
                            end if;

               -- check if used had entered existing bank account details.
             /*  SELECT COUNT(*) INTO l_bank_count
                 FROM bank_Accounts
                WHERE bank_routing_num = bank_rec.monthly_routing_number
                  AND bank_acct_num    = bank_rec.monthly_bank_acc_num
                  AND bank_name        = bank_rec.monthly_bank_name
                  AND bank_acct_type   = bank_rec.monthly_bank_acc_type
                  AND status           = 'A'
                  AND entity_id        = l_entity_id
                  AND entity_type      = l_entity_type
                  AND bank_Account_usage =  l_acct_usage  ;
             */
                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  monthly l_bank_count  * := ', l_bank_count
                                                                                                                              || ' l_entity_id :='
                                                                                                                              || l_entity_id
                                                                                                                              || ' l_entity_type :='
                                                                                                                              || l_entity_type
                                                                                                                              );

                            l_bank_count := pc_user_bank_acct.get_bank_acct_id(
                                p_entity_id          => l_entity_id,
                                p_entity_type        => l_entity_type,
                                p_bank_acct_num      => bank_rec.monthly_bank_acc_num,
                                p_bank_name          => bank_rec.monthly_bank_name,
                                p_bank_routing_num   => bank_rec.monthly_routing_number,
                                p_bank_account_usage => l_acct_usage,
                                p_bank_acct_type     => bank_rec.monthly_bank_acc_type
                            );

                            if nvl(l_bank_count, 0) = 0 then
                 /*pc_user_bank_acct.insert_bank_account(
                             p_entity_id          => l_entity_id
                            ,p_entity_type        => l_entity_type
                            ,p_display_name       => bank_rec.monthly_bank_name
                            ,p_bank_acct_type     => bank_rec.monthly_bank_acc_type
                            ,p_bank_routing_num   => bank_rec.monthly_routing_number
                            ,p_bank_acct_num      => bank_rec.monthly_Bank_Acc_Num
                            ,p_bank_name          => bank_rec.monthly_bank_name
                            ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                            ,p_user_id            => p_user_id
                            ,x_bank_acct_id       => l_bank_id
                            ,x_return_status      => l_return_status
                            ,x_error_message      => l_error_message);*/

                                pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024

                                (
                                    p_acc_num          => l_acc_num,
                                    p_entity_id        => l_entity_id,
                                    p_entity_type      => l_entity_type,
                                    p_display_name     => bank_rec.monthly_bank_name,
                                    p_bank_acct_type   => bank_rec.monthly_bank_acc_type,
                                    p_bank_routing_num => bank_rec.monthly_routing_number,
                                    p_bank_acct_num    => bank_rec.monthly_bank_acc_num,
                                    p_bank_name        => bank_rec.monthly_bank_name,
                                    p_business_name    => bank_rec.business_name,
                                    p_user_id          => p_user_id,
                                    p_gverify          => bank_rec.giac_verify_monthly,
                                    p_gauthenticate    => bank_rec.giac_authenticate_monthly,
                                    p_gresponse        => bank_rec.giac_response_monthly,
                                    p_giact_verify     => bank_rec.giac_verified_response_monthly,
                                    p_bank_status      => bank_rec.bank_status_monthly,
                                    p_auto_pay         => 'Y'    -- Added by Swamy for Ticket#12309 13062024
                                    ,
                                    p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                                    ,
                                    p_division_code    => null,
                                    p_source           => 'R',
                                    x_bank_acct_id     => l_bank_id,
                                    x_return_status    => l_return_status,
                                    x_error_message    => x_error_message
                                );

                                if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#12309 13062024
                                    raise l_create_error;
                                end if;
                                pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa monthly l_bank_id l', l_bank_id);
                            else

                /*FOR   B IN (    SELECT bank_Acct_id
                                  FROM bank_Accounts
                                 WHERE bank_routing_num = bank_rec.monthly_routing_number
                                   AND bank_acct_num    = bank_rec.monthly_bank_acc_num
                                   AND bank_name        = bank_rec.monthly_bank_name
                                   AND bank_acct_type   = bank_rec.monthly_bank_acc_type
                                   AND status           = 'A'
                                   AND entity_id        = l_entity_id
                                   AND entity_type      = l_entity_type
                                   AND bank_Account_usage =  l_acct_usage)
                LOOP
                            l_bank_id := b.bank_Acct_id ;
               END LOOP;
               */
                                l_bank_id := l_bank_count;
                            end if;

                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_bank_id l', l_bank_id);
                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewa  l_error_message l', l_error_message
                                                                                                                    || 'p_batch_number :='
                                                                                                                    || p_batch_number
                                                                                                                    );
                            update online_fsa_hra_staging
                            set
                                monthly_fee_bank_acct_id = nvl(l_bank_id, monthly_fee_bank_acct_id)
                            where
                                    batch_number = p_batch_number
                                and entrp_id = p_entrp_id;

               -- Upload to file_attachments 
                -- Added by Swamy for Ticket#12309
                            pc_file_upload.giact_insert_file_attachments(
                                p_user_bank_stg_id => bank_rec.enrollment_id,
                                p_attachment_id    => bank_rec.monthly_bank_file_attachment_id,
                                p_entity_id        => l_bank_id,
                                p_entity_name      => 'GIACT_BANK_INFO',
                                p_document_purpose => 'GIACT_DOC',
                                p_batch_number     => p_batch_number,
                                p_source           => 'R',
                                x_error_status     => x_error_status,
                                x_error_message    => x_error_message
                            );

                        end if;

                    end if;

                    p_bank_acct_id := l_bank_id; -- Added by Swamy for Ticket#12309

        /* commented by Joshi fof 11263.
	   IF x.payment_method = 'ACH' Then -- For the   Ticket #7241 added by prabu on 16/11/2018


          IF X.source     = 'RENEWAL' THEN     -- Added Jaggi/Swamy for Ticket#11040 on 05/04/2022
              PC_EMPLOYER_ENROLL.insert_user_bank_acct
                (p_acc_num          => l_acc_num ,
                p_display_name      => bank_rec.Bank_Name ,
                p_bank_acct_type    => bank_rec.Bank_Acct_Type ,
                p_bank_routing_num  => bank_rec.Bank_Routing_Num ,
                p_bank_acct_num     => bank_rec.Bank_Acct_Num ,
                p_bank_name         => bank_rec.bank_name ,
                p_user_id           => p_user_id ,
                p_acct_usage        => l_acct_usage ,
                x_bank_acct_id      => l_bank_id ,
                x_return_status     => l_return_status ,
                x_error_message     => l_error_message );
          ELSE
            pc_user_bank_acct.insert_bank_account(
                     p_entity_id          => l_acc_id
                    ,p_entity_type        => 'ACCOUNT'
                    ,p_display_name       => bank_rec.bank_name
                    ,p_bank_acct_type     => bank_rec.bank_acct_type
                    ,p_bank_routing_num   => bank_rec.Bank_Routing_Num
                    ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                    ,p_bank_name          => bank_rec.bank_name
                    ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                    ,p_user_id            => p_user_id
                    ,x_bank_acct_id       => l_bank_id
                    ,x_return_status      => l_return_status
                    ,x_error_message      => l_error_message);
          END IF;

        End If;

          pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal','Bank Data created successfully ');
          x_error_status := l_return_status;
          */
                end loop;
            end if; -- Added by Swamy for Ticket#12309
        ------------ -- end   code added by rprabu function to get MULTI BANK FUNCTIONALITY ticket 6346
     -- END IF; ---- X.bank_name IS NOT NULL
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal', 'Bank Data created successfully ');
            x_error_status := l_return_status;
            for y in (
                select
                    *
                from
                    online_fsa_hra_plan_staging
                where
                    enrollment_id = x.enrollment_id
            ) loop
                l_ben_plan_id := null; -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal', 'x.source '
                                                                                      || x.source
                                                                                      || 'y.plan_type :='
                                                                                      || y.plan_type
                                                                                      || 'X.enrollment_id :='
                                                                                      || x.enrollment_id
                                                                                      || 'p_entrp_id :='
                                                                                      || p_entrp_id
                                                                                      || 'Y.org_ben_plan_id.. '
                                                                                      || y.org_ben_plan_id);
       -- Added by Swamy for Ticket#10751
       -- For transit/parking/bycycly there should be only one plan, so during renewal of dca/lpf, if the trn/pkg/ua1 status is inactive, then from php user will have option to add trn/pkg/ua1 plan
       -- At that time new trn/pkg/ua1 plan should not be inserted, instead system should renew the existing the plan.
                l_org_ben_plan_id := y.org_ben_plan_id;
                if y.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                    l_org_ben_plan_id := null;
         -- Below loop is for Invalid plans
                    for k in (
                        select
                            ben_plan_id,
                            status
                        from
                            ben_plan_enrollment_setup
                        where
                                entrp_id = p_entrp_id
                            and plan_type = y.plan_type
                    ) loop
                        if nvl(k.ben_plan_id, 0) <> 0 then
              --Y.org_ben_plan_id := k.ben_plan_id;
                            l_org_ben_plan_id := k.ben_plan_id;
                            x.source := 'RENEWAL';
                            y.renewal_new_plan := 'N';
                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal inside loop', '   l_org_ben_plan_id.. ' || l_org_ben_plan_id
                            );
              -- Make the status to valid
                            if nvl(k.status, 0) = 'I' then
                                update ben_plan_enrollment_setup
                                set
                                    status = 'A'
                --WHERE ben_plan_id = Y.org_ben_plan_id
                                where
                                        ben_plan_id = l_org_ben_plan_id
                                    and entrp_id = p_entrp_id
                                    and plan_type = y.plan_type;

                            end if;

                        end if;
                    end loop;
         -- Below loop is for declined plans
                    for n in (
                        select
                            max(d.ben_plan_id) ben_plan_id,
                            max(b.acc_id)      acc_id
                        from
                            ben_plan_denials          d,
                            ben_plan_enrollment_setup b
                        where
                                b.entrp_id = y.entrp_id
                            and d.acc_id = b.acc_id
                            and d.ben_plan_id = b.ben_plan_id
                            and b.plan_type = y.plan_type
                    ) loop
                        if nvl(n.ben_plan_id, 0) <> 0 then
             -- Y.org_ben_plan_id := n.ben_plan_id;
                            l_org_ben_plan_id := n.ben_plan_id;
                            x.source := 'RENEWAL';
                            y.renewal_new_plan := 'N';
                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal second inside loop', '   l_org_ben_plan_id.. ' || l_org_ben_plan_id
                            );
              -- When the plan is declined,the plan_end_date gets updated to system date, so we need to update it back to previous applicable date which would be present in ben_plan_history table
                            for m in (
                                select
                                    plan_end_date
                                from
                                    ben_plan_history
                                where
                                        entrp_id = y.entrp_id
                                    and plan_type = y.plan_type
                                    and ben_plan_id = n.ben_plan_id
                                order by
                                    ben_plan_history_id desc
                                fetch first 1 rows only
                            ) loop
                                if nvl(
                                    trunc(m.plan_end_date),
                                    trunc(sysdate)
                                ) <> trunc(sysdate) then
                                    update ben_plan_enrollment_setup
                                    set
                                        plan_end_date = m.plan_end_date
                                    where
                                            ben_plan_id = n.ben_plan_id
                                        and entrp_id = p_entrp_id
                                        and plan_type = y.plan_type;

                                end if;
                            end loop;

                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal deleting inside loop', '   n.ben_plan_id.. ' || n.ben_plan_id
                            );
            -- Deleting the record from ben_plan_denials so that it does not reappear in Add New Plans section during renewal.
                            delete from ben_plan_denials
                            where
                                    ben_plan_id = n.ben_plan_id
                                and acc_id = n.acc_id;

                        end if;
                    end loop;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal', '   Y.org_ben_plan_id.. '
                                                                                          || y.org_ben_plan_id
                                                                                          || 'X.source :='
                                                                                          || x.source
                                                                                          || 'Y.renewal_new_plan :='
                                                                                          || y.renewal_new_plan);

                end if;
       -- end of Ticket#10751
        -- During renewal of a plan, if any other new plan is enrolled, the renewal_new_plan flag will be passed from php and stored in db as Y.
		-- renewal_new_plan flag = Y, indicates that its a new plan added during renewal.
		-- So during renewal there would be two records, one for renewal which should go inside the below if cond. for renewal,
		-- and the other record(New plan) with enrollment,which should go to else part of the if cond. (renewal_new_plan will be Y.so will go to else cond for enrollment)
                if
                    x.source = 'RENEWAL'
                    and nvl(y.renewal_new_plan, 'N') = 'N'
                then    -- Added AND cond by Swamy for Ticket#9601 09/11/2021
          --Ticket#4429
                    if y.grace_period is not null then
                        l_grace := 'Y';
                    end if;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal', '   Y.funding_option.. '
                                                                                          || y.funding_option
                                                                                          || 'Y.org_ben_plan_id :='
                                                                                          || y.org_ben_plan_id
                                                                                          || 'l_org_ben_plan_id :='
                                                                                          || l_org_ben_plan_id);

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments3 l_pay_acct_fees', l_pay_acct_fees);
          --Ticket#4429
           ---- X.fund_option is replaced by  Y.funding_option for 8313 04/11/2019 rprabu
                    pc_web_er_renewal.insrt_er_ben_plan_enrlmnt(
                        p_ben_plan_id                 => l_org_ben_plan_id /*Y.org_ben_plan_id*/,
                        p_min_election                => y.min_annual_election,
                        p_max_election                => y.max_annual_election,
                        p_new_plan_yr                 => y.new_plan_yr,
                        p_new_end_plan_yr             => null,     -- Added by Swamy for Ticket#9932 on 07/06/2021
                        p_runout_prd                  => y.run_out_period,
                        p_runout_trm                  => y.run_out_term,
                        p_grace                       => l_grace,                                                                                                                      --Ticket#4429
                        p_grace_days                  => y.grace_period,
                        p_rollover                    => y.rollover_flag,
                        p_funding_options             => y.funding_option,
                        p_non_discm                   => y.non_discm_testing,
                        p_new_hire                    => y.new_hire,
                        p_eob_required                => y.eob,
                        p_enrlmnt_start               => y.open_enrollment_start_date,
                        p_enrlmnt_endt                => y.open_enrollment_end_date,
                        p_plan_docs                   => y.plan_docs_flag,
                        p_user_id                     => p_user_id,
                        p_post_tax                    => null,
                        p_pay_acct_fees               => l_pay_acct_fees,--Renewal phase#2  x.pay_acct_fees
                        p_update_limit_match_irs_flag => y.update_limit_match_irs_flag,  --- 8237 18/11/2019  rprabu
                        p_batch_number                => p_batch_number, -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                        p_new_ben_pln_id              => l_ben_plan_id,
                        x_return_status               => l_return_status,
                        x_error_message               => l_error_message
                    );

                    x_error_status := l_return_status;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollment_renewal', 'Created Plan.. ' || l_ben_plan_id);
		  -- Previous benefit code is assgined to previous ben plan.

                    if l_ben_plan_id is not null then  ------7335 start  rprabu 21/01/2020

                        l_prev_ben_plan_id := null;
                        begin
                            select
                                max(ben_plan_id)
                            into l_prev_ben_plan_id
                            from
                                ben_plan_enrollment_setup
                            where
                                    entrp_id = y.entrp_id
                                and plan_type = y.plan_type
                                and ben_plan_id < l_ben_plan_id;

                        exception
                            when others then
                                null;
                        end;
       ---  insert added for 7335 rprabu 21/01/2020
                        if l_prev_ben_plan_id is not null then
                            insert into benefit_codes (
                                benefit_code_id,
                                entity_id,
                                benefit_code_name,
                                entity_type,
                                description,
                                created_by,
                                creation_date
                            )
                                select
                                    benefit_code_seq.nextval,   --- benefit_code_id ,  replaced with seqeunce for the Ticket #8795
                                    l_ben_plan_id,
                                    benefit_code_name,
                                    'BEN_PLAN_ENROLLMENT_SETUP',
                                    description,
                                    created_by,
                                    creation_date
                                from
                                    benefit_codes_stage
                                where
                                        entity_id = p_entrp_id
                                    and batch_number = p_batch_number;

                            if sql%rowcount = 0 then    --- 7335 rprabu 21/01/2020
                                insert into benefit_codes (
                                    benefit_code_id,
                                    entity_id,
                                    benefit_code_name,
                                    entity_type,
                                    description,
                                    created_by,
                                    creation_date
                                )
                                    select
                                        benefit_code_seq.nextval,   --- benefit_code_id ,  replaced with seqeunce for the Ticket #8795    ,
                                        l_ben_plan_id,
                                        benefit_code_name,
                                        'BEN_PLAN_ENROLLMENT_SETUP',
                                        description,
                                        created_by,
                                        creation_date
                                    from
                                        benefit_codes
                                    where
                                        entity_id = l_prev_ben_plan_id;

                                if sql%rowcount = 0 then    --- 7335 rprabu 21/01/2020
                                    insert into benefit_codes (
                                        benefit_code_id,
                                        entity_id,
                                        benefit_code_name,
                                        entity_type,
                                        description,
                                        created_by,
                                        creation_date
                                    )
                                        select
                                            benefit_code_seq.nextval,   --- benefit_code_id ,  replaced with seqeunce for the Ticket #8795   ,
                                            l_ben_plan_id,
                                            benefit_code_name,
                                            'BEN_PLAN_ENROLLMENT_SETUP',
                                            description,
                                            created_by,
                                            creation_date
                                        from
                                            benefit_codes
                                        where
                                            entity_id = p_entrp_id;

                                end if;

                            end if;

                  ----Eligibility data is copied for all the plans */  --- 7949  rprabu 07/02/2020

                            insert into custom_eligibility_req (
                                eligibility_id,
                                acct_for_pretax_flag,
                                permit_cash_flag,
                                limit_cash_flag,
                                revoke_elect_flag,
                                cease_covg_flag,
                                collective_bargain_flag,
                                no_of_hrs_part_time,
                                no_of_hrs_seasonal,
                                no_of_hrs_current,
                                new_ee_month_servc,
                                min_age,            --- 7949  Rprabu 07/02/2020
                                min_age_req,       --- 7949  Rprabu 07/02/2020
                                select_entry_date_flag,
                                plan_new_ee_join,
                                permit_partcp_eoy,
                                automatic_enroll,
                                ee_exclude_plan_flag,
                                coincident_next_flag,
                                salesrep_id,
                                limit_cash_paid,
                                entity_id
                            )
                                select
                                    eligibility_seq.nextval,
                                    x.er_pretax_flag,
                                    x.permit_cash_flag,
                                    x.limit_cash_flag,
                                    x.revoke_elect_flag,
                                    x.cease_covg_flag,
                                    x.collective_bargain_flag,
                                    x.no_of_hrs_part_time,
                                    x.no_of_hrs_seasonal,
                                    x.no_of_hrs_current,
                                    x.new_ee_month_servc,
                                    x.min_age_req,
                                    x.minimum_age_flag,
                                    x.select_entry_date_flag,
                                    x.plan_new_ee_join,
                                    x.permit_partcp_eoy,
                                    x.automatic_enroll,
                                    x.ee_exclude_plan_flag,
                                    x.coincident_next_flag,
                                    x.salesrep_id,
                                    x.limit_cash_paid,
                                    l_ben_plan_id
                                from
                                    dual;

                            if l_prev_ben_plan_id is not null then

									---- Added by rprabu 0n 21/02/2020 for the ticket 7335
                                for i in (
                                    select
                                        *
                                    from
                                        custom_eligibility_req
                                    where
                                        entity_id = l_prev_ben_plan_id
                                ) loop
                                    update custom_eligibility_req
                                    set
                                        no_of_hrs_part_time = nvl(no_of_hrs_part_time, i.no_of_hrs_part_time),
                                        no_of_hrs_seasonal = nvl(no_of_hrs_seasonal, i.no_of_hrs_seasonal),
                                        no_of_hrs_current = nvl(no_of_hrs_current, i.no_of_hrs_current),
                                        new_ee_month_servc = nvl(new_ee_month_servc, i.new_ee_month_servc),
                                        collective_bargain_flag = nvl(collective_bargain_flag, i.collective_bargain_flag),
                                        union_ee_join_flag = nvl(union_ee_join_flag, i.union_ee_join_flag),
                                        plan_new_ee_join = nvl(plan_new_ee_join, i.plan_new_ee_join),
                                        select_entry_date_flag = nvl(select_entry_date_flag, i.select_entry_date_flag),
                                        min_age_req = nvl(min_age_req, i.min_age_req),
                                        automatic_enroll = nvl(automatic_enroll, i.automatic_enroll),
                                        revoke_elect_flag = nvl(revoke_elect_flag, i.revoke_elect_flag),
                                        cease_covg_flag = nvl(cease_covg_flag, i.cease_covg_flag),
                                        contrib_flag = nvl(contrib_flag, i.contrib_flag),
                                        contrib_amt = nvl(contrib_amt, i.contrib_amt),
                                        percent_contrib = nvl(percent_contrib, i.percent_contrib),
                                        permit_cash_flag = nvl(permit_cash_flag, i.permit_cash_flag),
                                        limit_cash_flag = nvl(limit_cash_flag, i.limit_cash_flag),
                                        salesrep_flag = nvl(salesrep_flag, i.salesrep_flag),
                                        ga_flag = nvl(ga_flag, i.ga_flag),
                                        salesrep_id = nvl(salesrep_id, i.salesrep_id),
                                        ga_id = nvl(ga_id, i.ga_id),
                                        source = 'FSA',
                                        last_updated_by = p_user_id,
                                        last_update_date = sysdate,
                                        acct_for_pretax_flag = nvl(acct_for_pretax_flag, i.acct_for_pretax_flag),
                                        permit_partcp_eoy = nvl(permit_partcp_eoy, i.permit_partcp_eoy),
                                        ee_exclude_plan_flag = nvl(ee_exclude_plan_flag, i.ee_exclude_plan_flag),
                                        coincident_next_flag = nvl(coincident_next_flag, i.coincident_next_flag),
                                        limit_cash_paid = nvl(limit_cash_paid, i.limit_cash_paid),
                                        min_service_req = nvl(min_service_req, i.min_service_req),
                                        exclude_seasonal_flag = nvl(exclude_seasonal_flag, i.exclude_seasonal_flag),
                                        fmla_leave = nvl(fmla_leave, i.fmla_leave),
                                        fmla_tax = nvl(fmla_tax, i.fmla_tax),
                                        fmla_under_cobra = nvl(fmla_under_cobra, i.fmla_under_cobra),
                                        fmla_return_leave = nvl(fmla_return_leave, i.fmla_return_leave),
                                        fmla_contribution = nvl(fmla_contribution, i.fmla_contribution),
                                        ee_rehire_plan = nvl(ee_rehire_plan, i.ee_rehire_plan),
                                        ee_reemploy_plan = nvl(ee_reemploy_plan, i.ee_reemploy_plan),
                                        er_partcp_elect = nvl(er_partcp_elect, i.er_partcp_elect),
                                        failure_plan_yr = nvl(failure_plan_yr, i.failure_plan_yr),
                                        plan_admin = nvl(plan_admin, i.plan_admin),
                                        admin_contact_type = nvl(admin_contact_type, i.admin_contact_type),
                                        admin_name = nvl(admin_name, i.admin_name),
                                        hsa_contrib = nvl(hsa_contrib, i.hsa_contrib),
                                        max_contrib_amt = nvl(max_contrib_amt, i.max_contrib_amt),
                                        matching_contrib = nvl(matching_contrib, i.matching_contrib),
                                        non_elect_contrib = nvl(non_elect_contrib, i.non_elect_contrib),
                                        percent_non_elect_amt = nvl(percent_non_elect_amt, i.percent_non_elect_amt),
                                        other_non_elect_amt = nvl(other_non_elect_amt, i.other_non_elect_amt),
                                        max_contrib_hsa = nvl(max_contrib_hsa, i.max_contrib_hsa),
                                        other_max_contrib = nvl(other_max_contrib, i.other_max_contrib),
                                        flex_credit_flag = nvl(flex_credit_flag, i.flex_credit_flag),
                                        flex_credit_cash = nvl(flex_credit_cash, i.flex_credit_cash),
                                        flex_cash_amt = nvl(flex_cash_amt, i.flex_cash_amt),
                                        er_contrib_flex = nvl(er_contrib_flex, i.er_contrib_flex),
                                        flex_contrib_amt = nvl(flex_contrib_amt, i.flex_contrib_amt),
                                        other_flex_amt = nvl(other_flex_amt, i.other_flex_amt),
                                        cash_out_amt = nvl(cash_out_amt, i.cash_out_amt),
                                        max_flex_cash_out = nvl(max_flex_cash_out, i.max_flex_cash_out),
                                        dollar_amt = nvl(dollar_amt, i.dollar_amt),
                                        other_max_cash_out = nvl(other_max_cash_out, i.other_max_cash_out),
                                        amt_distrib = nvl(amt_distrib, i.amt_distrib),
                                        min_age = nvl(min_age, i.min_age),
                                        min_contrib_hsa = nvl(min_contrib_hsa, i.min_contrib_hsa),
                                        when_partcp_eoy = nvl(when_partcp_eoy, i.when_partcp_eoy)
                                    where
                                        entity_id = l_ben_plan_id;

                                end loop;
                            end if;

                        end if;

                    end if;

                else -- Enrollments

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'Creatig Plan Info.. ' || y.plan_type);
                    l_ben_plan_id := null; --- 8795
                    l_plan_fund_option := x.fund_option;   -- Added by Swamy for Ticket#10562(Dev ticket#9601 ) 16/11/2021



                    pc_employer_enroll.update_plan_info(
                        p_entrp_id             => p_entrp_id,
                        p_fiscal_end_date      => to_char(x.fiscal_yr_end, 'mm/dd/rrrr'),
                        p_plan_type            => y.plan_type,
                        p_plan_number          => y.plan_number,
                        p_eff_date             => to_char(y.effective_date, 'mm/dd/rrrr')               --Transation Date
                        ,
                        p_org_eff_date         => to_char(y.org_effective_date, 'mm/dd/rrrr')       --Original Eff date
                        ,
                        p_plan_start_date      => to_char(y.plan_start_date, 'mm/dd/rrrr')              --
                        ,
                        p_plan_end_date        => to_char(y.plan_end_date, 'mm/dd/rrrr'),
                        p_takeover             => y.take_over                                            --restament then Y else N
                        ,
                        p_user_id              => p_user_id,
                        p_plan_name            =>
                                     case
                                         when y.post_deductible_plan = 'Y' then
                                             'PDFSA'
                                         else
                                             substr(
                                                 replace(y.plan_type
                                                         || pc_entrp.get_entrp_name(p_entrp_id),
                                                         ' ',
                                                         ''),
                                                 1,
                                                 18
                                             )
                                     end                                               -- added by Jaggi #10430 on 11/15/2021
                                     ,
                        p_erissa_erap_doc_type => null                                     -- Added by Joshi for 7791.
                        ,
                        x_er_ben_plan_id       => l_ben_plan_id,
                        x_error_status         => l_return_status,
                        x_error_message        => l_error_message
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'Created Plan.. ' || l_ben_plan_id);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'Fund option.. ' || x.fund_option);
                    x_error_status := l_return_status;



		    /***** Insert Eligibility Requirement Data******************************/
                        /**Eligibility data is copied for all the plans */
				     --- 8795 CUSTOM_ELIGIBILITY_REQ should be created after the ben plan enrollment creation only. rprabu 03/03/2020
                    insert into custom_eligibility_req (
                        eligibility_id,
                        acct_for_pretax_flag,
                        permit_cash_flag,
                        limit_cash_flag,
                        revoke_elect_flag,
                        cease_covg_flag,
                        collective_bargain_flag,
                        no_of_hrs_part_time,
                        no_of_hrs_seasonal,
                        no_of_hrs_current,
                        new_ee_month_servc,
                        min_age_req,
                        min_age,
                            /* Ticket#7118 */
                        select_entry_date_flag,
                        plan_new_ee_join,
                        permit_partcp_eoy,
                        automatic_enroll,
                        ee_exclude_plan_flag,
                        contrib_amt,
                        coincident_next_flag,
                        salesrep_id,
                        limit_cash_paid,
                        entity_id
                    )
                        select
                            eligibility_seq.nextval,
                            x.er_pretax_flag,
                            x.permit_cash_flag,
                            x.limit_cash_flag,
                            x.revoke_elect_flag,
                            x.cease_covg_flag,
                            x.collective_bargain_flag,
                            x.no_of_hrs_part_time,
                            x.no_of_hrs_seasonal,
                            x.no_of_hrs_current,
                            x.new_ee_month_servc,
                            x.minimum_age_flag,  --- Tiket Ticket #7212 Rprabu 16/11/2018
                            x.min_age_req,
                         /* Ticket#7118 */
                            x.select_entry_date_flag,
                            x.plan_new_ee_join,
                            x.permit_partcp_eoy,
                            x.automatic_enroll,
                            x.ee_exclude_plan_flag,
                            y.er_lump_amt,
                            x.coincident_next_flag,
                            x.salesrep_id,
                            x.limit_cash_paid,
                            l_ben_plan_id
                        from
                            dual;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'Eligibility Data created successfully ');
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments..BEN PLAN ID Update', l_ben_plan_id);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments..ENROLLMENT DETAIL ID Update', y.enrollment_detail_id
                    );
                    update online_fsa_hra_plan_staging
                    set
                        ben_plan_id = l_ben_plan_id
                    where
                        y.enrollment_detail_id = enrollment_detail_id;

           -- Added by Swamy for Ticket#10562(Dev ticket#9601 ) 16/11/2021
                    if nvl(y.renewal_new_plan, 'N') = 'Y' then
                        l_plan_fund_option := y.funding_option;
                    end if;

                    update ben_plan_enrollment_setup
                    set
                        open_enrollment_start_date = y.open_enrollment_start_date,
                        open_enrollment_end_date = y.open_enrollment_end_date,
                        minimum_election = y.min_annual_election,
                        maximum_election = y.max_annual_election,
                        rollover = y.rollover_flag,
                        grace_period = y.grace_period,
                        runout_period_days = y.run_out_period,
                        er_contrib_flag = y.er_contrib_flag,
                        pay_method = y.er_contrib_method,
                        er_lump_amount = y.er_lump_amt,
                        ee_pay_amount = y.ee_pay_per_period,
                        allow_debit_card = y.all_debit_card,
                        heart_act_flag = y.heart_act_flag,
                        amt_reservist_disrib = y.amt_reservist_disrib,
                        pay_day = y.pay_day,
                        funding_options = l_plan_fund_option, -- Replaced X.fund_option with l_plan_fund_option Swamy Ticket#10562(Dev ticket#9601 ) 16/11/2021
                        non_discrm_flag = x.ndt_testing_flag,
                        runout_period_term = y.run_out_term,
                        claim_reimbursed_by =
                            case
                                when l_plan_fund_option = 'CLAIM_INVOICE'     -- Replaced X.fund_option with l_plan_fund_option Swamy Ticket#10562(Dev ticket#9601 ) 16/11/2021
                                 then
                                    'EMPLOYER'
                                else
                                    'STERLING'
                            end,
            /* For Post deductible plan type is LPF only,plan name goes as PDFSA */
                        ben_plan_name =
                            case
                                when y.post_deductible_plan = 'Y' then
                                    'PDFSA'
                                else
                                    substr(
                                        replace(y.plan_type
                                                || pc_entrp.get_entrp_name(p_entrp_id),
                                                ' ',
                                                ''),
                                        1,
                                        18
                                    )
                            end,
                        plan_type =
                            case
                                when y.plan_type = 'PDFSA' then
                                    'LPF'
                                else
                                    y.plan_type
                            end
                    where
                        ben_plan_id = l_ben_plan_id;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', ' 333 before benefit code :  ' || l_ben_plan_id);

          /*** For LPF and FSA plns create a coverage tier *****/
                    insert into benefit_codes (
                        benefit_code_id,
                        entity_id,
                        benefit_code_name,
                        entity_type,
                        description,
                        created_by,
                        creation_date
                    )
                        select
                            benefit_code_seq.nextval,   --- benefit_code_id ,  replaced with seqeunce for the Ticket #8795
                            l_ben_plan_id,
                            benefit_code_name,
                            'BEN_PLAN_ENROLLMENT_SETUP',
                            description,
                            created_by,
                            creation_date
                        from
                            benefit_codes_stage
                        where
                                entity_id = p_entrp_id
                            and batch_number = p_batch_number;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', ' 555 after  benefit code :  ' || l_ben_plan_id);
                    if y.plan_type in ( 'LPF', 'FSA' ) then
                        pc_benefit_plans.create_fsa_coverage(l_ben_plan_id, 'SINGLE', p_user_id);
                    end if;
          /*************PAYROLL SETUP ************************/
                    insert into pay_cycle (
                        pay_cycle_id,
                        name,
                        entrp_id,
                        start_date,
                        frequency,
                        no_of_periods,
                        ben_plan_id,
                        plan_type,
                        created_by,
                        creation_date
                    )
                        select
                            pay_cycle_seq.nextval,
                            y.plan_type || y.plan_number,
                            p_entrp_id,
                            start_date,
                            frequency,
                            pay_periods,
                            l_ben_plan_id,
                            y.plan_type,
                            p_user_id,
                            sysdate
                        from
                            pay_cycle_stage
                        where
                            enrollment_detail_id = y.enrollment_detail_id;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'Payroll Setup for.. ' || y.plan_type);
                end if; -- Renewal and Enrollments

        -- Added by Joshi for 10431.  update ben_plan_id in the staging table.
                update online_fsa_hra_plan_staging
                set
                    ben_plan_id = l_ben_plan_id
                where
                        enrollment_detail_id = y.enrollment_detail_id
                    and batch_number = p_batch_number;

            end loop; --Plan Level Loop

            if x_error_status = 'S' then
	      /** Update Benefit Codes Info **/
	    --- This old code is commented for the ticket 7335 rprabu 21/01/2020 uncommented for sumitra issue
        -- exception code added for the the ticket 8795
                begin
                    delete from benefit_codes
                    where
                        entity_id = p_entrp_id;

                exception
                    when others then
                        null;
                end;

        /* Update ACClevel staging table **/
                update online_fsa_hra_staging
                set
                    acc_num = l_acc_num,
                    error_message = 'Success'
                where
                    enrollment_id = x.enrollment_id;

                if x.source is null then
          /***In last update complete flag ****/

            -- Added by Joshi for 10431
                    if
                        l_inactive_plan_exist = 'I'
                        and nvl(
                            pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                            'N'
                        ) = 'N'
                    then
                        pc_employer_enroll_compliance.update_inactive_account(l_acc_id, p_user_id);
                    else
                        update account
                        set
                            complete_flag = 1,
                            enrolled_date = sysdate,  -- 10431 Joshi
                            submit_by = p_user_id
                        where
                            acc_num = l_acc_num;

                    end if;
                else
               -- IF broker is renewed, then the renewed by should be broker which is happening in pc_employer_enroll_compliance.Renewal_app_signed_by_staging. the below code should be executed only when employer does renewal.
               -- If broker is renewed and asks employer to sign, then l_renewal_sign_type = 'EMPLOYER, in that case the below should not be executed.
                    if nvl(l_renewal_sign_type, '*') <> 'EMPLOYER' then
               -- Added by Joshi for 10431 -- Renewal
                        for u in (
                            select
                                user_type
                            from
                                online_users
                            where
                                user_id = p_user_id
                        ) loop
                            if u.user_type = 'B' then
                                l_renewed_by := 'BROKER';
                            elsif u.user_type = 'G' then
                                l_renewed_by := 'GA';
                            else
                                l_renewed_by := 'EMPLOYER';
                            end if;
                        end loop;

                        update account
                        set
                            renewed_by = l_renewed_by,
                            renewed_date = sysdate
                        where
                            acc_num = l_acc_num;

                    end if;
                end if;

            end if;

      -- Added by Jaggi for Ticket #11086
            pc_employer_enroll_compliance.update_acct_pref(p_batch_number, p_entrp_id);
            select
                nvl(broker_id, 0)
            into l_broker_id
            from
                table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

            if l_broker_id > 0 then
                l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_acc_id);
                pc_broker.create_broker_authorize(
                    p_broker_id        => l_broker_id,
                    p_acc_id           => l_acc_id,
                    p_broker_user_id   => null,
                    p_authorize_req_id => l_authorize_req_id,
                    p_user_id          => p_user_id,
                    x_error_status     => l_return_status,
                    x_error_message    => l_error_message
                );

            end if;
        -- code ends here by Joshi.

        end loop; ---Acct level Loop
        pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments', 'FSA Enrollments submitted successfully');

          -- added by Jaggi #11368
        update account
        set
            signature_account_status = null
        where
            entrp_id = p_entrp_id;

    exception
        when l_create_error then
            rollback to savepoint enroll_renewal_savepoint;
            x_error_status := 'E';
            update online_fsa_hra_staging
            set
                error_message = x_error_message
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments ERROR l_create_error', x_error_message);
        when others then
            rollback;    ----  For the  Ticket #8795rprabu
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_fsa_enrollments OTHERS ERROR', sqlerrm);
            x_error_status := 'E';
    end process_fsa_enrollment_renewal;

    procedure upsert_expense_info (
        p_entrp_id         in number,
        p_user_id          in number,
        p_batch_number     in number,
        p_plan_code        in number,
        p_plan_type        in varchar2_tbl,
        p_basic_expense_id in varchar2_tbl,
        p_comp_expense_id  in varchar2_tbl,
        p_lph_expense_id   in varchar2_tbl,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    ) is
    begin
    --Depending on Type of plan selected ,update the plan code.
    --If user selecs BASIC then send 509, COMP  510 and if user selects LPF alone
    --then update COMP.
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_EXPENSE_INFO', 'In Proc');
        x_error_status := 'S';
        update online_fsa_hra_staging
        set
            plan_code = p_plan_code,
            ndt_preference =
                case
                    when p_plan_code = 509 then
                        'BASIC'
                    else
                        'COMPREHENSIVE'
                end
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_EXPENSE_INFO', 'After Update');
        delete from eligibile_expenses_staging
        where
                entity_id = p_entrp_id
            and batch_number = p_batch_number;

        for i in 1..p_plan_type.count loop
            if p_plan_type(i) = 'BASIC' then
                pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_EXPENSE_INFO', 'BASIC');
                for j in 1..p_basic_expense_id.count loop
                    insert into eligibile_expenses_staging (
                        expense_id,
                        entity_id,
                        plan_type,
                        expense_code,
                        batch_number,
                        created_by,
                        creation_date
                    ) values ( eligibility_expense_seq.nextval,
                               p_entrp_id,
                               p_plan_type(i),
                               p_basic_expense_id(j),
                               p_batch_number,
                               p_user_id,
                               sysdate );

                end loop; --Basic expense loop
            elsif p_plan_type(i) = 'COMPREHENSIVE' then
                for j in 1..p_comp_expense_id.count loop
                    insert into eligibile_expenses_staging (
                        expense_id,
                        entity_id,
                        plan_type,
                        expense_code,
                        batch_number,
                        created_by,
                        creation_date
                    ) values ( eligibility_expense_seq.nextval,
                               p_entrp_id,
                               p_plan_type(i),
                               p_comp_expense_id(j),
                               p_batch_number,
                               p_user_id,
                               sysdate );

                end loop;
            else
                for j in 1..p_lph_expense_id.count loop
                    insert into eligibile_expenses_staging (
                        expense_id,
                        entity_id,
                        plan_type,
                        expense_code,
                        batch_number,
                        created_by,
                        creation_date
                    ) values ( eligibility_expense_seq.nextval,
                               p_entrp_id,
                               p_plan_type(i),
                               p_lph_expense_id(j),
                               p_batch_number,
                               p_user_id,
                               sysdate );

                end loop;
            end if; --Plan Type IF
        end loop; --Plan type loop
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_ELIGIBLE_EXPENSE', sqlerrm);
            x_error_status := 'E';
    end upsert_expense_info;

    procedure upsert_hra_plan_info (
        p_enrollment_id               in number,
        p_entrp_id                    in number,
        p_user_id                     in number,
        p_batch_number                in number,
        p_plan_number                 in number,
        p_take_over                   in varchar2, --Take over --N else Y
        p_short_plan_year_flag        in varchar2,  -- for the Ticket #7187 added by rprabu on 22/11/2018
        p_plan_start_date             in varchar2,
        p_plan_end_date               in varchar2,
        p_eff_date                    in varchar2,
        p_org_eff_date                in varchar2,
        p_open_enrollment_period_flag varchar2, -- for the Ticket #7187 added by rprabu on 12/11/2018
        p_open_enrollment_date        in varchar2,
        p_open_enrollment_end_date    in varchar2,
        p_rollover_flag               in varchar2,
        p_rollover_method             in varchar2, --  Ticket #7088  added by rprabu 23/10/2018
        p_rollover_amount             in number,
        p_run_out_period              in varchar2,
        p_allow_debit_card            in varchar2,
        p_plan_docs_flag              in varchar2,
        p_plan_with_fsa               in varchar2,
        p_run_out_term                in varchar2,
        p_new_hire_contrib            in varchar2,
        p_er_reimburse_claim          in varchar2,
        p_wish_to_cover               in varchar2,   --- p_enrollment_option replaced with p_wish_to_cover as per jay comment on ticket Ticket #6992
        p_ee_percent_share            in varchar2, ---- rprabu 09/11/2018 ticket 6346
        p_er_percent_share            in varchar2,
        p_individual_plan_flag        in varchar2,
        p_hra_covg_plan_level         in varchar2,
        p_single_ee_contrib_amt       in varchar2,
        p_ee_spouse_ee_amt            in varchar2,
        p_ee_spouse_amt               in varchar2,
        p_ee_children_amt             in varchar2,
        p_ee_childen_depend_amt       in varchar2,
        p_family_ee_amt               in varchar2,
        p_family_spouse_amt           in varchar2,
        p_family_children_amt         in varchar2,
        p_coverage_tier               in varchar2,--Amount Employer will pay first and Amount emplyee...
        p_enrollment_detail_id        in number,
        p_org_ben_plan_id             in varchar2 default null,
        p_new_plan_yr                 in varchar2 default null,
        p_eob                         in varchar2 default null,
        p_source                      in varchar2 default null,
        p_plan_type                   in varchar2 default null,
        p_covg_tier                   in varchar2_tbl,
        p_funding_amount              in varchar2_tbl,
        p_covg_tier2                  in varchar2_tbl,
        p_funding_amount2             in varchar2_tbl,
        p_max_rollover_amount         in varchar2_tbl,
        p_ndt_testing                 in varchar2 default null,   -- Added by Swamy For Ticket#4805
        p_agree_debit_card            in varchar2,   ---- 7889  rprabu
        p_funding_option              in varchar2,  ---- 8313  rprabu 04/11/2019
        x_enrollment_detail_id        out number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is

        l_acc_id       number;
        l_count        number := 0;
        l_min_election number;
        l_max_election number;
        l_cnt_tiers    number := 0;
    begin
        x_error_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO', 'In Proc..ID' || p_enrollment_id);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO', 'In Proc..Plan Type' || p_plan_type);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO', 'In Proc..EOB' || p_eob);
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO', 'In Proc..PLAN YR' || p_new_plan_yr);
        if p_plan_type is not null then ----Ticket #6967 added by rprabu 03/10/2018
            select
                count(*)
            into l_count
            from
                online_fsa_hra_plan_staging
            where
                    batch_number = p_batch_number
                and enrollment_id = p_enrollment_id
                and plan_type = p_plan_type;

            select
                acc_id
            into l_acc_id
            from
                account
            where
                entrp_id = p_entrp_id;

            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO..Cnt', l_count);
            if l_count > 0 then --Then Only Update
                update online_fsa_hra_plan_staging
                set
                    enrollment_id = p_enrollment_id,
                    plan_type = p_plan_type,
                    plan_number = p_plan_number,
                    short_plan_year_flag = p_short_plan_year_flag, ----Ticket #7259 added by rprabu on 22/11/2018
                    plan_start_date = to_date(p_plan_start_date, 'mm/dd/rrrr'),
                    plan_end_date = to_date(p_plan_end_date, 'mm/dd/rrrr'),
                    effective_date = to_date(p_eff_date, 'mm/dd/rrrr'),
                    org_effective_date = to_date(p_org_eff_date, 'mm/dd/rrrr'),
                    open_enrollment_period_flag = p_open_enrollment_period_flag, -- for the Ticket #7187 added by rprabu on 12/11/2018
                    open_enrollment_start_date = to_date(p_open_enrollment_date, 'mm/dd/rrrr'),
                    open_enrollment_end_date = to_date(p_open_enrollment_end_date, 'mm/dd/rrrr'),
                    run_out_period = p_run_out_period,
                    rollover_flag = p_rollover_flag,
                    rollover_method = p_rollover_method, --  Ticket #7088  added by rprabu 23/10/2018
                    rollover_amount = p_rollover_amount,
                    plan_docs_flag = p_plan_docs_flag,
                    take_over = p_take_over,
                    all_debit_card = p_allow_debit_card,
                    plan_with_fsa = p_plan_with_fsa,
                    run_out_term = p_run_out_term,
                    new_hire_contrib = p_new_hire_contrib,
                    er_reimburse_claim = p_er_reimburse_claim,
                    ee_percent_share = p_ee_percent_share, ---- rprabu 09/11/2018 ticket 6346
                    er_percent_share = p_er_percent_share,
                    hra_coverage_option = p_wish_to_cover, --- p_enrollment_option replaced with p_wish_to_cover as per jay comment on ticket Ticket #6992
                    individual_plan_flag = p_individual_plan_flag,
                    hra_covg_plan_level = p_hra_covg_plan_level,
                    eob = p_eob,
                    new_plan_yr = p_new_plan_yr,
                    org_ben_plan_id = p_org_ben_plan_id,
                    non_discm_testing = p_ndt_testing, -- Added by Swamy For Ticket#4805
                    agree_debit_card = p_agree_debit_card, -- 7889
                    funding_option = p_funding_option  ---8313 04/11/2019 rprabu
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id
                returning enrollment_detail_id into x_enrollment_detail_id;
        /**Update Coverage Information **/
                pc_log.log_error('In Coverage Count in Staging table Befor passing', p_covg_tier.count);
                pc_employer_enroll.create_coverage_data(
                    p_covg_tier            => p_covg_tier,
                    p_funding_amount       => p_funding_amount,
                    p_covg_tier2           => p_covg_tier2,
                    p_funding_amount2      => p_funding_amount2,
                    p_batch_number         => p_batch_number,
                    p_user_id              => p_user_id,
                    p_rollover_amount      => p_max_rollover_amount,
                    p_acc_id               => l_acc_id,
                    p_covg_tier_type       => p_coverage_tier,
                    p_enrollment_detail_id => x_enrollment_detail_id,
                    p_source               => p_source,
                    x_error_status         => x_error_status,
                    x_error_message        => x_error_message
                );

            else
        --Insert
                insert into online_fsa_hra_plan_staging (
                    enrollment_detail_id,
                    enrollment_id,
                    plan_type,
                    entrp_id,
                    short_plan_year_flag,    ----Ticket #7259 added by rprabu on 22/11/2018
                    plan_start_date,
                    plan_end_date,
                    take_over,
                    plan_number,
                    effective_date,
                    org_effective_date,
                    open_enrollment_period_flag, -- for the Ticket #7187 added by rprabu on 12/11/2018
                    open_enrollment_start_date,
                    open_enrollment_end_date,
                    run_out_period,
                    run_out_term,
                    rollover_flag,
                    rollover_method, --  Ticket #7088  added by rprabu 23/10/2018
                    rollover_amount,
                    plan_docs_flag,
                    all_debit_card,
                    plan_with_fsa,
                    new_hire_contrib,
                    er_reimburse_claim,
                    er_percent_share,
                    ee_percent_share, ---- rprabu 09/11/2018 ticket 6346
                    hra_coverage_option,
                    individual_plan_flag,
                    hra_covg_plan_level,
                    eob,
                    org_ben_plan_id,
                    new_plan_yr,
                    batch_number,
                    created_by,---- rprabu 09/11/2018 ticket 6346
                    creation_date,---- rprabu 09/11/2018 ticket 6346
                    non_discm_testing,  -- Added by Swamy For Ticket#4805
                    agree_debit_card,       --------Added by prabu  For Ticket#7889
                    funding_option                ---8313 04/11/2019 rprabu
                ) values ( fsa_online_enroll_seq.nextval,
                           p_enrollment_id,
                           p_plan_type,
                           p_entrp_id,
                           p_short_plan_year_flag,    ----Ticket #7259 added by rprabu on 22/11/2018
                           to_date(p_plan_start_date, 'mm/dd/rrrr'),
                           to_date(p_plan_end_date, 'mm/dd/rrrr'),
                           p_take_over,
                           p_plan_number,
                           to_date(p_eff_date, 'mm/dd/rrrr'),
                           to_date(p_org_eff_date, 'mm/dd/rrrr'),
                           p_open_enrollment_period_flag, -- for the Ticket #7187 added by rprabu on 12/11/2018
                           to_date(p_open_enrollment_date, 'mm/dd/rrrr'),
                           to_date(p_open_enrollment_end_date, 'mm/dd/rrrr'),
                           p_run_out_period,
                           p_run_out_term,
                           p_rollover_flag,
                           p_rollover_method, --  Ticket #7088  added by rprabu 23/10/2018
                           p_rollover_amount,
                           p_plan_docs_flag,
                           p_allow_debit_card,
                           p_plan_with_fsa,
                           p_new_hire_contrib,
                           p_er_reimburse_claim,
                           p_er_percent_share,
                           p_ee_percent_share,  ---- rprabu 09/11/2018 ticket 6346
                           p_wish_to_cover, --- p_enrollment_option replaced with p_wish_to_cover as per jay comment on ticket Ticket #6992
                           p_individual_plan_flag,
                           p_hra_covg_plan_level,
                           p_eob,
                           p_org_ben_plan_id,
                           p_new_plan_yr,
                           p_batch_number,
                           p_user_id,			---- rprabu 09/11/2018 ticket 6346
                           sysdate,				---- rprabu 09/11/2018 ticket 6346
                           p_ndt_testing,      -- Added by Swamy For Ticket#4805
                           p_agree_debit_card,   ------------rprabu 7889
                           p_funding_option         ---8313 04/11/2019 rprabu
                            ) returning enrollment_detail_id into x_enrollment_detail_id;

                pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO', 'After Insert Plan Info');

        /** Create Coverage data **/
                pc_employer_enroll.create_coverage_data(
                    p_covg_tier            => p_covg_tier,
                    p_funding_amount       => p_funding_amount,
                    p_covg_tier2           => p_covg_tier2,
                    p_funding_amount2      => p_funding_amount2,
                    p_batch_number         => p_batch_number,
                    p_user_id              => p_user_id,
                    p_rollover_amount      => p_max_rollover_amount,
                    p_acc_id               => l_acc_id,
                    p_covg_tier_type       => p_coverage_tier,
                    p_enrollment_detail_id => x_enrollment_detail_id,
                    p_source               => p_source,
                    x_error_status         => x_error_status,
                    x_error_message        => x_error_message
                );

            end if; -- Insert/Update loop

      /*p_enrollment_option        --- commented for ticket Ticket #6992 rprabu
      UPDATE ONLINE_FSA_HRA_STAGING
      SET enrollment_option = p_enrollment_option
      where entrp_id = p_entrp_id
      and batch_number = p_batch_number; */
      /* Update Min and Max annual election depending on coverage values */
            if p_source = 'RENEWAL' then
        /* For Renewal ,previous yeear annual election should be copied .Ticket#4820*/
                select
                    count(*)
                into l_cnt_tiers
                from
                    ben_plan_coverages_staging
                where
                        acc_id = l_acc_id
                    and batch_number = p_batch_number
                    and ben_plan_id = x_enrollment_detail_id;

                if l_cnt_tiers = 1 then
                    l_min_election := 0;
                    select
                        nvl(
                            max(annual_election),
                            0
                        )
                    into l_max_election
                    from
                        ben_plan_coverages_staging
                    where
                            ben_plan_id = x_enrollment_detail_id
                        and coverage_tier_type is null;

                else
          /* Multiple Tiers */
          /*Ticket#5517 .Max election should be as per max amount defined at coverage level */
                    select
                        nvl(
                            max(annual_election),
                            0
                        ),
                        nvl(
                            min(annual_election),
                            0
                        )
                    into
                        l_max_election,
                        l_min_election
                    from
                        ben_plan_coverages_staging
                    where
                            ben_plan_id = x_enrollment_detail_id
                        and coverage_tier_type is null;
          /*Ticket#5517*/
                end if;

            else
        /* Enrollment */
                select
                    min(annual_election),
                    max(annual_election)
                into
                    l_min_election,
                    l_max_election
                from
                    ben_plan_coverages_staging
                where
                        ben_plan_id = x_enrollment_detail_id
                    and coverage_tier_type = 'Funding_Amount';

            end if;

            update online_fsa_hra_plan_staging
            set
                min_annual_election = l_min_election,
                max_annual_election = l_max_election
            where
                enrollment_detail_id = x_enrollment_detail_id;
      --and max_annual_election < l_max_election;
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO', 'After updating election values');
      /****Insert Deductible Options ****/
            delete from hra_deductible_options
            where
                    entrp_id = p_entrp_id
                and enrollment_detail_id = p_enrollment_detail_id;

            if p_hra_covg_plan_level = 'Y' then
                insert into hra_deductible_options (
                    option_id,
                    enrollment_detail_id,
                    entrp_id,
            -- Individual_plan_flag,
            -- HRA_covg_plan_level ,
                    single_ee_contrib_amt,
                    ee_spouse_ee_amt,
                    ee_spouse_amt,
                    ee_children_amt,
                    ee_childen_depend_amt,
                    family_ee_amt,
                    family_spouse_amt,
                    family_children_amt,
                    coverage_tier,
                    batch_number,
                    created_by,
                    creation_date
                ) values ( deductible_option_seq.nextval,
                           x_enrollment_detail_id,
                           p_entrp_id,
            -- p_Individual_plan_flag,
            -- p_HRA_covg_plan_level ,
                           p_single_ee_contrib_amt,
                           p_ee_spouse_ee_amt,
                           p_ee_spouse_amt,
                           p_ee_children_amt,
                           p_ee_childen_depend_amt,
                           p_family_ee_amt,
                           p_family_spouse_amt,
                           p_family_children_amt,
                           p_coverage_tier,
                           p_batch_number,
                           p_user_id,
                           sysdate );

            end if;

        end if; ----Ticket #6967 added by rprabu 03/10/2018
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPSERT_HRA_PLAN_INFO', sqlerrm);
    end upsert_hra_plan_info;
/*
--- Commented by rprabu 21/08/2018 for HRA enrollment UPDATE_HRA_ADMIN_OPTION spliting into two procs.
PROCEDURE UPDATE_HRA_ADMIN_OPTION(
p_entrp_id                IN NUMBER,
p_ndt_preference          IN VARCHAR2,
p_batch_number            IN NUMBER,
p_COLLECTIVE_BARGAIN_FLAG IN VARCHAR2,
p_NO_OF_HRS_PART_TIME     IN VARCHAR2 ,
p_NO_OF_HRS_SEASONAL      IN VARCHAR2 ,
p_NO_OF_HRS_CURRENT       IN VARCHAR2,
p_NEW_EE_MONTH_SERVC      IN VARCHAR2,
p_MIN_AGE_REQ             IN VARCHAR2 ,
P_EE_EXCLUDE_PLAN_FLAG    IN VARCHAR2,
p_carrier_flag            IN VARCHAR2,
p_union_ee_join_flag      IN VARCHAR2,
p_enrollment_option       IN VARCHAR2,
P_user_id                 IN NUMBER,
x_error_status OUT VARCHAR2,
x_error_message OUT VARCHAR2 )
IS
l_count NUMBER := 0;
BEGIN
pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_ADMIN_OPTION','In Proc ');
x_error_status := 'S';
UPDATE ONLINE_FSA_HRA_STAGING
SET  COLLECTIVE_BARGAIN_FLAG = p_COLLECTIVE_BARGAIN_FLAG,
NO_OF_HRS_PART_TIME     = p_NO_OF_HRS_PART_TIME ,
NO_OF_HRS_SEASONAL      = p_NO_OF_HRS_SEASONAL,
NO_OF_HRS_CURRENT       = p_NO_OF_HRS_CURRENT ,
MIN_AGE_REQ             = p_MIN_AGE_REQ ,
EE_EXCLUDE_PLAN_FLAG    = p_EE_EXCLUDE_PLAN_FLAG,--Y for Custom and N for plan include
NEW_EE_MONTH_SERVC      = p_NEW_EE_MONTH_SERVC    ,
ndt_testing_flag         = p_ndt_preference,
carrier_flag            = p_carrier_flag,
union_ee_join_flag      = p_union_ee_join_flag,
enrollment_option       = p_enrollment_option
WHERE batch_number        = p_batch_number
AND entrp_id              = p_entrp_id;
EXCEPTION
WHEN OTHERS THEN
X_ERROR_MESSAGE := SQLCODE || ' ' || SQLERRM;
X_ERROR_STATUS := 'E';
pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_ADMIN_OPTION','Error '||SQLERRM);
END UPDATE_HRA_ADMIN_OPTION ;
*/
--- Added by rprabu 21/08/2018 for HRA enrollment UPDATE_HRA_ADMIN_OPTION1,
---UPDATE_HRA_ADMIN_OPTION1 , UPDATE_HRA_ADMIN_OPTION2
    procedure update_hra_admin_option1 (
        p_entrp_id                in number,
        p_ndt_preference          in varchar2,
        p_batch_number            in number,
        p_carrier_flag            in varchar2,
        p_additional_service_flag in varchar2,  --- param added by rprabu for the ticket  7678 on 05/15/2018
        p_enrollment_option       in varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is
        l_count number := 0;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_ADMIN_OPTION1', 'In Proc ');
        x_error_status := 'S';
        update online_fsa_hra_staging
        set
            ndt_testing_flag = p_ndt_preference,
            carrier_flag = p_carrier_flag,
            enrollment_option = p_enrollment_option,
            additional_service_flag = p_additional_service_flag  --- param added by rprabu for the ticket  7678 on 05/15/2018
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_ADMIN_OPTION2', 'Error ' || sqlerrm);
    end update_hra_admin_option1;

    procedure update_hra_admin_option2 (
        p_entrp_id                in number,
        p_batch_number            in number,
        p_collective_bargain_flag in varchar2,
        p_no_of_hrs_part_time     in varchar2,
        p_no_of_hrs_seasonal      in varchar2,
        p_no_of_hrs_current       in varchar2,
        p_new_ee_month_servc      in varchar2,
        p_minimum_age             in varchar2, --- param added by rprabu for the ticket  6346 on 09/11/2018
        p_min_age_req             in varchar2,
        p_ee_exclude_plan_flag    in varchar2,
        p_union_ee_join_flag      in varchar2,
        p_user_id                 in number,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is
        l_count number := 0;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_ADMIN_OPTION', 'In Proc ');
        x_error_status := 'S';
        update online_fsa_hra_staging
        set
            collective_bargain_flag = p_collective_bargain_flag,
            no_of_hrs_part_time = p_no_of_hrs_part_time,
            no_of_hrs_seasonal = p_no_of_hrs_seasonal,
            no_of_hrs_current = p_no_of_hrs_current,
            min_age_req = p_min_age_req,
            minimum_age_flag = p_minimum_age,        --- param added by rprabu for the ticket  6346 on 09/11/2018
            ee_exclude_plan_flag = p_ee_exclude_plan_flag,--y for custom and n for plan include
            new_ee_month_servc = p_new_ee_month_servc,
            union_ee_join_flag = p_union_ee_join_flag
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_ADMIN_OPTION', 'Error ' || sqlerrm);
    end update_hra_admin_option2;

    procedure update_hra_invoice_bank_info (
        p_batch_number               in varchar2,
        p_entrp_id                   in number,
        p_salesrep_flag              in varchar2,    -- Ticket #7092 added by rprabu 23/10/2018
        p_salesrep_id                in number,
        p_pay_acct_fees              in varchar2,
        p_invoice_flag               in varchar2,
        p_hra_copy_plan_docs         in varchar2,
        p_funding_option             in varchar2,
        p_bank_name                  in varchar2,
        p_account_type               in varchar2,
        p_routing_num                in varchar2,
        p_account_num                in varchar2,
        p_acct_usage                 in varchar2,
        p_payment_method             in varchar2,
        p_page_validity              in varchar2,    -- Added by prabu for Ticket#7699
        p_bank_authorize             in varchar2,     -- Added by Jaggi ##9602
        p_pay_monthly_fees_by        in varchar2,     -- Added by Jaggi #11263
        p_monthly_fee_payment_method in varchar2,     -- Added by Jaggi #11263
        p_funding_payment_method     in varchar2,     -- Added by Jaggi #11263
        x_error_status               out varchar2,
        x_error_message              out varchar2
    ) is
        l_salesrep_id number := null; -- Added by rprabu for the Ticket #7092 on 12/10/2018
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_INVOICE_BANK_INFO', 'In Proc');
    --  -- Added by rprabu for the Ticket #7092 on 12/10/2018
        if p_salesrep_flag = 'Y' then
            l_salesrep_id := p_salesrep_id;
        elsif p_salesrep_flag = 'N' then
            l_salesrep_id := null;
        end if;

        update online_fsa_hra_staging
        set
            salesrep_id = l_salesrep_id,
            pay_acct_fees = p_pay_acct_fees,
            monthly_fees_paid_by = p_pay_monthly_fees_by,               -- Added by Jaggi #11263
            monthly_fee_payment_method = p_monthly_fee_payment_method,  -- Added by Jaggi #11263
            funding_payment_method = p_funding_payment_method,      -- Added by Jaggi #11263
            invoice_flag = p_invoice_flag,
            hra_copy_plan_docs = p_hra_copy_plan_docs,
            bank_name = p_bank_name,
            routing_number = p_routing_num,
            bank_acc_num = p_account_num,
            bank_acc_type = p_account_type,
            acct_usage = p_acct_usage,
            fund_option = p_funding_option,
            payment_method = p_payment_method,
            salesrep_flag = p_salesrep_flag, --- Ticket #7092 added by rprabu 23/10/2018
            bank_authorize = p_bank_authorize
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;
-- Added by rprabu for Ticket#7699
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'HRA',
            p_page_no       => 4,
            p_block_name    => 'INVOICING_PAYMENT',
            p_validity      => p_page_validity,
            p_user_id       => null,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        update contact_leads
        set
            send_invoice = p_invoice_flag
        where
            entity_id = pc_entrp.get_tax_id(p_entrp_id);

    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HRA_INVOICE_BANK_INFO', 'Error ' || sqlerrm);
    end update_hra_invoice_bank_info;

    procedure process_hra_enrollment_renewal (
        p_batch_number       in number,
        p_entrp_id           in number,
        p_user_id            in number
      --Added Renewal parameters
        ,
        p_broker_name        in varchar2 default null,
        p_broker_license_num in varchar2 default null,
        p_broker_contact     in varchar2_tbl,
        p_broker_contact_id  in varchar2_tbl,
        p_broker_email       in varchar2_tbl,
        p_ga_name            in varchar2 default null,
        p_ga_license_num     in varchar2 default null,
        p_ga_contact         in varchar2_tbl,
        p_ga_contact_id      in varchar2_tbl,
        p_ga_email           in varchar2_tbl,
        p_send_invoice       in varchar2 default null,
        p_bank_acct_id       out number,                  -- Added by Swamy for Ticket#12309
        x_error_status       out varchar2,
        x_error_message      out varchar2
    ) is

        l_aff_entrp_id         number;
        l_return_status        varchar2(10);
        l_error_message        varchar2(800);
        l_ctrl_entrp_id        number;
        l_acc_id               number;
        l_acc_num              varchar2(100);
        l_ben_plan_id          number;
        l_prev_ben_plan_id     number; --- 7335 rprabu 10/02/2020
        l_bank_id              number;
        l_acct_usage           varchar2(100);
        l_eob                  varchar2(2) := 'N';
        l_broker_email         varchar2(100);
        l_ga_email             varchar2(100);
        l_renewed_by           varchar2(30);
        l_resubmit_flag        varchar2(1);
        l_inactive_plan_exist  varchar2(1);
        l_broker_id            number;
        l_authorize_req_id     number;
        l_pay_acct_fees        varchar2(30);
        l_entity_id            number;
        l_entity_type          varchar2(50);
        l_bank_count           number;
        l_renewal_sign_type    varchar2(30);
        l_sales_team_member_id number;
        l_active_bank_exists   varchar2(3) := '*';
        l_create_error exception;  -- Added by Swamy for Ticket#12309
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.process_Hra_enrollment_renewal', 'In Proc');
        x_error_status := 'S';
        select
            acc_id,
            acc_num,
            nvl(resubmit_flag, 'N'),
            renewal_sign_type
        into
            l_acc_id,
            l_acc_num,
            l_resubmit_flag,
            l_renewal_sign_type
        from
            account
        where
            entrp_id = p_entrp_id;

        l_inactive_plan_exist := nvl(
            pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
            'N'
        );
        for x in (
            select
                *
            from
                online_fsa_hra_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            savepoint enroll_renewal_savepoint;   -- Added by Swamy for Ticket#12309
            l_pay_acct_fees := x.pay_acct_fees; -- Added by Jaggi #11119
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_Hra_enrollment_renewal l_pay_acct_fees', l_pay_acct_fees);
            if x.source is null then --Enrollments IF
          -- Added by Jaggi #11263
                if pc_account.get_broker_id(l_acc_id) = 0 then
                    for j in (
                        select
                            broker_id
                        from
                            online_users ou,
                            broker       b
                        where
                                user_id = p_user_id
                            and user_type = 'B'
                            and upper(tax_id) = upper(broker_lic)
                    ) loop
                        update account
                        set
                            broker_id = j.broker_id
                        where
                            entrp_id = p_entrp_id;

                    end loop;
                end if;

     -- added by Jaggi #11629
                if x.salesrep_id is not null then
                    pc_sales_team.upsert_sales_team_member(
                        p_entity_type           => 'SALES_REP',
                        p_entity_id             => x.salesrep_id,
                        p_mem_role              => 'PRIMARY',
                        p_entrp_id              => p_entrp_id,
                        p_start_date            => trunc(sysdate),
                        p_end_date              => null,
                        p_status                => 'A',
                        p_user_id               => p_user_id,
                        p_pay_commission        => null,
                        p_note                  => null,
                        p_no_of_days            => null,
                        px_sales_team_member_id => l_sales_team_member_id,
                        x_return_status         => l_return_status,
                        x_error_message         => x_error_message
                    );

                end if;

                update enterprise
                set
                    state_of_org = x.state_of_org,
                    no_of_eligible = x.fsa_eligib_ee,
                    entity_type = x.type_of_entity
          --  ,entrp_contact = (SELECT first_name from contact_leads
          --                  where entity_id = PC_ENTRP.GET_TAX_ID(p_entrp_id)
          --                  and contact_type = 'PRIMARY'
          --                   and account_type = 'FSA'
          --                   and rownum < 2)
                where
                    entrp_id = p_entrp_id;
        --Update Enterprise Census
                insert into enterprise_census values ( p_entrp_id,
                                                       'ENTERPRISE',
                                                       'NO_OF_EMPLOYEES',
                                                       x.total_number_ees,
                                                       sysdate,
                                                       p_user_id,
                                                       sysdate,
                                                       p_user_id,
                                                       null );

      -- Start of Addition by Swamy for Ticket#7606
                if nvl(x.fsa_eligib_ee, 0) <> 0 then
                    insert into enterprise_census (
                        entity_id,
                        entity_type,
                        census_code,
                        census_numbers,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        ben_plan_id
                    ) values ( p_entrp_id,
                               'ENTERPRISE',
                               'NO_OF_ELIGIBLE',
                               x.fsa_eligib_ee,
                               sysdate,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               null );

                end if;
      -- End of Addition by Swamy for Ticket#7606

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_Hra_enrollment_renewal', 'Census Data created successfully ');
        ----Update Plan CODE
        --If funding option is Advatage then plan code is Advantage Basic and Advantage Comp
                if
                    x.fund_option = '100CR'
                    and x.plan_code = 509
                then
                    update account
                    set
                        plan_code = 507
                    where
                        acc_num = l_acc_num;

                elsif
                    x.fund_option = '100CR'
                    and x.plan_code = 510
                then
                    update account
                    set
                        plan_code = 508
                    where
                        acc_num = l_acc_num;

                else
                    update account
                    set
                        plan_code = x.plan_code
                    where
                        acc_num = l_acc_num;

                end if;

           -- Added by Joshi 10430. need to delete existing affliated ER incase of resubmission
                if
                    l_resubmit_flag = 'Y'
                    and nvl(x.source, 'E') <> 'RENEWAL'
                then
                    delete from enterprise
                    where
                        entrp_id in (
                            select
                                entity_id
                            from
                                entrp_relationships
                            where
                                    entrp_id = p_entrp_id
                                and entity_type = 'ENTERPRISE'
                                and relationship_type = 'AFFILIATED_ER'
                        )
                        and entrp_code is null;

                    delete from entrp_relationships
                    where
                            entrp_id = p_entrp_id
                        and entity_type = 'ENTERPRISE'
                        and relationship_type = 'AFFILIATED_ER';
             -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
             -- user might update existing  contacts.
                    for c in (
                        select
                            contact_id
                        from
                            contact_leads
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and account_type = 'HRA'
                            and ref_entity_type = 'ONLINE_ENROLLMENT'
                    ) loop
                        delete from contact
                        where
                                entity_id = pc_entrp.get_tax_id(p_entrp_id)
                            and contact_id = c.contact_id;

                        delete from contact_role
                        where
                            contact_id = c.contact_id;

                    end loop;

                    update user_bank_acct
                    set
                        status = 'I'
                    where
                        acc_id = l_acc_id;

            /*  commented and added below by Joshi for #12339. Ben plan deletion issue
             FOR B IN (  SELECT ben_plan_id
                         FROM ben_plan_enrollment_setup
                        WHERE acc_id = l_acc_id AND entrp_id = p_entrp_id) */
                    for b in (
                        select
                            bp.ben_plan_id
                        from
                            ben_plan_enrollment_setup   bp,
                            online_fsa_hra_staging      os,
                            online_fsa_hra_plan_staging ops
                        where
                                os.batch_number = p_batch_number
                            and os.entrp_id = p_entrp_id
                            and os.batch_number = ops.batch_number
                            and os.enrollment_id = ops.enrollment_id
                            and os.entrp_id = bp.entrp_id
                            and ops.ben_plan_id = bp.ben_plan_id
                    ) loop
                        delete from ben_plan_coverages
                        where
                                acc_id = l_acc_id
                            and ben_plan_id = b.ben_plan_id;

                        delete from custom_eligibility_req
                        where
                                entity_id = b.ben_plan_id
                            and source = 'FSA';

                -- Delete all the ben_plan_enrollment_data. 10431 Joshi
                        delete from ben_plan_enrollment_setup
                        where
                                acc_id = l_acc_id
                            and entrp_id = p_entrp_id
                            and ben_plan_id = b.ben_plan_id;

                    end loop;

              -- Delete all the ben_plan_enrollment_data. 10430 Joshi
           -- DELETE FROM ben_plan_enrollment_setup
           -- WHERE acc_id = l_acc_id AND entrp_id = p_entrp_id;

                end if;
           -- code ends here  Joshi 10430.

        /***Create Affliated ER **/
                for j in (
                    select
                        *
                    from
                        entrp_relationships_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and relationship_type = 'AFFLIATED_ER'
                ) loop
                    if j.entity_name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            state,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   10,
                                   j.entity_name,
                                   x.state_of_org,
                                   p_user_id,
                                   sysdate ) returning entrp_id into l_aff_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id ---Original ER(GPOP)
                            ,
                            p_entity_id     => l_aff_entrp_id                                          ---Affliated ER
                            ,
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'AFFILIATED_ER',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if;
                end loop;
        /**Craete Controlled Grp ER ***/
                for j in (
                    select
                        *
                    from
                        entrp_relationships_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and relationship_type = 'CONTROLLED_GRP_ER'
                ) loop
                    if j.entity_name is not null then
                        insert into enterprise (
                            entrp_id,
                            en_code,
                            name,
                            state,
                            created_by,
                            creation_date
                        ) values ( entrp_seq.nextval,
                                   10,
                                   j.entity_name,
                                   x.state_of_org,
                                   p_user_id,
                                   sysdate ) returning entrp_id into l_ctrl_entrp_id;

                        pc_employer_enroll.create_enterprise_relation(
                            p_entrp_id      => p_entrp_id,---Original ER(GPOP)
                            p_entity_id     => l_ctrl_entrp_id,                                       ---Cntrl Grp ER
                            p_entity_type   => 'ENTERPRISE',
                            p_relat_type    => 'CONTROLLED_GROUP',
                            p_user_id       => p_user_id,
                            x_return_status => l_return_status,
                            x_error_message => l_error_message
                        );

                    end if;
                end loop;

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_Hra_enrollment_renewal', 'After creating Affliated and Controlled Grp ')
                ;
        /*** Update Account Preference *****/
       ---    Ticket #6944 by rprabu on 25/09/2018
                pc_account.upsert_acc_pref(
                    p_entrp_id               => p_entrp_id,
                    p_acc_id                 => l_acc_id,
                    p_claim_pay_method       => null,
                    p_auto_pay               => null,
                    p_plan_doc_only          => null,
                    p_status                 => 'A',
                    p_allow_eob              => 'Y',
                    p_user_id                => p_user_id,
                    p_pin_mailer             => 'N',
                    p_teamster_group         => 'N',
                    p_allow_exp_enroll       => 'Y',
                    p_maint_fee_paid         => null,
                    p_allow_online_renewal   => 'Y',
                    p_allow_election_changes => 'N',
                    p_plan_action_flg        => 'Y',
                    p_submit_election_change => 'Y',
                    p_edi_flag               => 'N',
                    p_vendor_id              => null,
                    p_reference_flag         => null,
                    p_allow_payroll_edi      => null,
                    p_fees_paid_by           => null    -- Added by Swamy for Ticket#11037
                );

        ---    Added for the Ticket #6944 by rprabu on 25/09/2018
                update account_preference
                set
                    ndt_preference =
                        case
                            when x.ndt_testing_flag = 'Y' then
                                upper(x.ndt_preference)
                            else
                                null
                        end,
                    send_docs_to = x.hra_copy_plan_docs,
                    fees_paid_by = upper(x.pay_acct_fees)
                where
                    entrp_id = p_entrp_id;
        ---Update Eligibilty Expenses
                insert into plan_eligibile_expenses (
                    expense_id,
                    entity_id,
                    plan_type,
                    expense_code,
                    created_by,
                    creation_date
                )
                    select
                        expense_id,
                        entity_id,
                        plan_type,
                        expense_code,
                        created_by,
                        creation_date
                    from
                        eligibile_expenses_staging
                    where
                            entity_id = p_entrp_id
                        and batch_number = p_batch_number;
        /*****************Update Contact Info ***************/

	 -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
     -- user might update existing  contacts.
                if l_resubmit_flag = 'Y' then
                    delete from contact
                    where
                        contact_id in (
                            select
                                contact_id
                            from
                                contact_leads
                            where
                                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                                and account_type = 'HRA'
                        );

                end if;

                insert into contact (
                    contact_id,
                    first_name,
                    last_name,
                    entity_id,
                    entity_type,
                    email,
                    status,
                    start_date,
                    last_updated_by,
                    created_by,
                    last_update_date,
                    creation_date,
                    can_contact,
                    contact_type,
                    user_id,
                    phone,
                    fax,
                    title,
                    account_type
                )
                    select
                        contact_id,
                        substr(first_name,
                               0,
                               instr(first_name, ' ', 1, 1) - 1),
                        substr(first_name,
                               instr(first_name, ' ', 1, 1) + 1,
                               length(first_name) - instr(first_name, ' ', 1, 1) + 1),
                        entity_id,
                        'ENTERPRISE',
                        email,
                        'A',
                        sysdate,
                        p_user_id,
                        p_user_id,
                        sysdate,
                        sysdate,
                        'Y',
                        contact_type,
                        null,
                        phone_num,
                        contact_fax,
                        job_title,
                        account_type
                    from
                        contact_leads a
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and not exists (
                            select
                                1
                            from
                                contact b
                            where
                                a.contact_id = b.contact_id
                        )     -------- 7783 rprabu 31/10/2019
                        and account_type = 'HRA';

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_Hra_enrollment_renewal', 'Contact Data created successfully ');
        /** For all contacts added define contact roles etc */
        --Ticket#6555
                for xx in (
                    select
                        *
                    from
                        contact_leads a
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and not exists (
                            select
                                1
                            from
                                contact_role b
                            where
                                a.contact_id = b.contact_id
                        )     -------- 7783 rprabu 31/10/2019
                ) loop
                    insert into contact_role e (
                        contact_role_id,
                        contact_id,
                        role_type,
                        account_type,
                        effective_date,
                        created_by,
                        last_updated_by
                    ) values ( contact_role_seq.nextval,
                               xx.contact_id,
                               xx.account_type,
                               xx.account_type,
                               sysdate,
                               p_user_id,
                               p_user_id );
          --Especially for compliance we need to have both account type and role type defined
                    insert into contact_role e (
                        contact_role_id,
                        contact_id,
                        role_type,
                        account_type,
                        effective_date,
                        created_by,
                        last_updated_by
                    ) values ( contact_role_seq.nextval,
                               xx.contact_id,
                               xx.contact_type,
                               xx.account_type,
                               sysdate,
                               p_user_id,
                               p_user_id );
          --For all products we want Fee Invoice option also checked
                    if xx.contact_type = 'PRIMARY'
                    or xx.send_invoice in ( 'Y', '1' ) then
                        insert into contact_role e (
                            contact_role_id,
                            contact_id,
                            role_type,
                            account_type,
                            effective_date,
                            created_by,
                            last_updated_by
                        ) values ( contact_role_seq.nextval,
                                   xx.contact_id,
                                   'FEE_BILLING',
                                   xx.account_type,
                                   sysdate,
                                   p_user_id,
                                   p_user_id );

                    end if;--Ticket#6555

                end loop;

            else -- Renewals loop
                pc_log.log_error('PC_EMPLOYER_ENROLL.process_Hra_enrollment_renewal', 'Before Renewal Broker Info' || p_broker_name);
                for i in 1..p_broker_contact.count loop
                    pc_web_compliance.update_contact_info(
                        p_contact_id      => p_broker_contact_id(i),
                        p_entrp_id        => p_entrp_id,
                        p_first_name      => p_broker_contact(i),
                        p_email           => p_broker_email(i),
                        p_account_type    => 'HRA',
                        p_contact_type    => 'BROKER',
                        p_user_id         => p_user_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'ENTERPRISE',
                        p_send_invoice    => p_send_invoice,
                        p_status          => 'A',
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    l_broker_email := p_broker_email(i);
                end loop;

                if p_broker_name is not null then
                    pc_broker.insert_sales_team_leads(
                        p_first_name      => null,
                        p_last_name       => null,
                        p_license         => p_broker_license_num,
                        p_agency_name     => p_broker_name,
                        p_tax_id          => null,
                        p_gender          => null,
                        p_address         => null,
                        p_city            => null,
                        p_state           => null,
                        p_zip             => null,
                        p_phone1          => null,
                        p_phone2          => null,
                        p_email           => l_broker_email,  --any last email of contact is assigned
                        p_entrp_id        => p_entrp_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'BEN_PLAN_RENEWALS',
                        p_lead_source     => 'RENEWAL',
                        p_entity_type     => 'BROKER'
                    );
                end if;

                for i in 1..p_ga_contact.count loop
                    pc_web_compliance.update_contact_info(
                        p_contact_id      => p_ga_contact_id(i),
                        p_entrp_id        => p_entrp_id,
                        p_first_name      => p_ga_contact(i),
                        p_email           => p_ga_email(i),
                        p_account_type    => 'HRA',
                        p_contact_type    => 'GA',
                        p_user_id         => p_user_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'ENTERPRISE',
                        p_send_invoice    => p_send_invoice,
                        p_status          => 'A',
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    l_ga_email := p_ga_email(i);
                end loop; --Ga entry
                if p_ga_name is not null then
                    pc_broker.insert_sales_team_leads(
                        p_first_name      => null,
                        p_last_name       => null,
                        p_license         => p_ga_license_num,
                        p_agency_name     => p_ga_name,
                        p_tax_id          => null,
                        p_gender          => null,
                        p_address         => null,
                        p_city            => null,
                        p_state           => null,
                        p_zip             => null,
                        p_phone1          => null,
                        p_phone2          => null,
                        p_email           => l_ga_email,
                        p_entrp_id        => p_entrp_id,
                        p_ref_entity_id   => null,
                        p_ref_entity_type => 'BEN_PLAN_RENEWALS',
                        p_lead_source     => 'RENEWAL',
                        p_entity_type     => 'GA'
                    );
                end if;

                pc_log.log_error('PC_EMPLOYER_ENROLL.process_Hra_enrollment_renewal', 'Created Broker GA Info.. ');
            end if; --Enrollments IF
      /****Update Bank Info *****/
      /* commented by Joshi 11263 as ther will always be multiples bank accounts entered for SETUP/MONTHLY/CLAIM.
      IF X.bank_name   IS NOT NULL THEN
        IF X.source     = 'RENEWAL' THEN
          l_acct_usage := 'INVOICE' ;
        ELSE
          SELECT
            CASE
              WHEN X.acct_usage= 'ALL'
              THEN 'OFFICE'
              WHEN X.acct_usage = 'FEE'
              THEN 'INVOICE'
              WHEN X.acct_usage = 'FUNDING'
             -- THEN 'INVOICE'
             THEN 'FUNDING'  -- Added by Jaggi #11119
              ELSE 'CLAIMS'
            END
          INTO l_acct_usage
          FROM dual;
        END IF; --Renewal/Enrollments

  IF X.source     = 'RENEWAL' THEN   -- Added Jaggi/Swamy for Ticket#11040 on 05/04/2022
       Pc_Employer_Enroll.Insert_User_Bank_Acct(
						P_Acc_Num           => L_Acc_Num ,
						P_Display_Name      => X.Bank_Name ,
						P_Bank_Acct_Type    => X.Bank_Acc_Type ,
						P_Bank_Routing_Num  => X.Routing_Number ,
						P_Bank_Acct_Num     => X.Bank_Acc_Num ,
						P_Bank_Name         => X.Bank_Name ,
						P_User_Id           => P_User_Id ,
						P_Acct_Usage        =>L_Acct_Usage ,
						X_Bank_Acct_Id      => L_Bank_Id ,
						X_Return_Status     => L_Return_Status ,
  						X_Error_Message     => L_Error_Message );
   ELSE
                pc_user_bank_acct.insert_bank_account(
                         p_entity_id          => l_acc_id
                        ,p_entity_type        => 'ACCOUNT'
                        ,p_display_name       => x.bank_name
                        ,p_bank_acct_type     => x.bank_acc_type
                        ,p_bank_routing_num   => x.routing_number
                        ,p_bank_acct_num      => x.bank_acc_num
                        ,p_bank_name          => x.bank_name
                        ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                        ,p_user_id            => p_user_id
                        ,x_bank_acct_id       => l_bank_id
                        ,x_return_status     => l_return_status
                        ,x_error_message    => l_error_message);
  END IF;

        ----------new  code Below added by rprabu function to get MULTI BANK FUNCTIONALITY ticket 6346

      ELSE
*/
-- Added by Swamy for Ticket#12309
-- If there is no active bank account then the account status should change to pending bank verification.
            if nvl(x.source, 'E') = 'E' then
                for j in (
                    select
                        'P' cnt
                    from
                        user_bank_acct_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and bank_status not in ( 'A' )
                ) loop
                    l_active_bank_exists := j.cnt;
                end loop;
            else
                l_active_bank_exists := 'A';
            end if;

     -- Added By Joshi for 11263. Store as per the bank account usage.
              -- Added By Joshi for 11263. Store as per the bank account usage.
      -- Enrollment
            if nvl(x.source, 'E') = 'E' then
                for bank_rec in (
                    select
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
                        bank_status,            -- Start Addition by Swamy for Ticket#10978 13062024
                        business_name,
                        giac_response,
                        giac_verify,
                        giac_authenticate,
                        giac_verified_response,
                        bank_acct_verified    -- End of Addition by Swamy for Ticket#10978 13062024
                    from
                        user_bank_acct_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                ) loop
                    select
                        case
                            when bank_rec.acct_usage = 'ALL'     then
                                'OFFICE'
                            when bank_rec.acct_usage in ( 'FEE', 'MONTHLY' ) -- Added by Jaggi #11263
                             then
                                'INVOICE'
                            when bank_rec.acct_usage = 'FUNDING' then
                                'FUNDING'
                            else
                                'CLAIMS'
                        end
                    into l_acct_usage
                    from
                        dual;

                    if bank_rec.acct_usage in ( 'FEE', 'MONTHLY' ) then
                        if bank_rec.acct_usage = 'FEE' then
                            if upper(x.pay_acct_fees) = 'EMPLOYER' then
                                l_entity_id := l_acc_id;
                                l_entity_type := 'ACCOUNT';
                            elsif upper(x.pay_acct_fees) = 'BROKER' then
                                l_entity_id := pc_account.get_broker_id(l_acc_id);
                                l_entity_type := 'BROKER';
                            elsif upper(x.pay_acct_fees) in ( 'GA', 'GENERAL AGENT' ) then
                                l_entity_id := pc_account.get_ga_id(l_acc_id);
                                l_entity_type := 'GA';
                            end if;

                            update online_fsa_hra_staging
                            set
                                payment_method = 'ACH'
                            where
                                    batch_number = p_batch_number
                                and entrp_id = p_entrp_id;

                        else
                            if upper(x.monthly_fees_paid_by) = 'EMPLOYER' then
                                l_entity_id := l_acc_id;
                                l_entity_type := 'ACCOUNT';
                            elsif upper(x.monthly_fees_paid_by) = 'BROKER' then
                                l_entity_id := pc_account.get_broker_id(l_acc_id);
                                l_entity_type := 'BROKER';
                            elsif upper(x.monthly_fees_paid_by) in ( 'GA', 'GENERAL AGENT' ) then
                                l_entity_id := pc_account.get_ga_id(l_acc_id);
                                l_entity_type := 'GA';
                            end if;
                        end if;

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal l_entity_id: ', l_entity_id);
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal l_entity_type', l_entity_type);
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_acct_usage l', l_acct_usage);
                        l_bank_count := 0;

              /*  SELECT COUNT(*) INTO l_bank_count
                  FROM bank_Accounts
                WHERE bank_routing_num = bank_rec.Bank_Routing_Num
                    AND bank_acct_num    = bank_rec.Bank_Acct_Num
                    AND bank_name        = bank_rec.bank_name
                    AND status           = 'A'
                    AND entity_id        = l_entity_id
                    AND entity_type     = l_entity_type 
                     AND bank_Account_usage =  l_acct_usage;   -- Added by Swamy for Ticket#12432
             */
                        l_bank_count := pc_user_bank_acct.get_bank_acct_id(
                            p_entity_id          => l_entity_id,
                            p_entity_type        => l_entity_type,
                            p_bank_acct_num      => bank_rec.bank_acct_num,
                            p_bank_name          => bank_rec.bank_name,
                            p_bank_routing_num   => bank_rec.bank_routing_num,
                            p_bank_account_usage => l_acct_usage,
                            p_bank_acct_type     => bank_rec.bank_acct_type
                        );

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_bank_count l', l_bank_count
                                                                                                              || ' p_batch_number :='
                                                                                                              || p_batch_number);
                        if nvl(l_bank_count, 0) = 0 then
                        /*pc_user_bank_acct.insert_bank_account(
                         p_entity_id          => l_entity_id
                        ,p_entity_type        => l_entity_type
                        ,p_display_name       => bank_rec.bank_name
                        ,p_bank_acct_type     => bank_rec.bank_acct_type
                        ,p_bank_routing_num   => bank_rec.Bank_Routing_Num
                        ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                        ,p_bank_name          => bank_rec.bank_name
                        ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                        ,p_user_id            => p_user_id
                        ,x_bank_acct_id       => l_bank_id
                        ,x_return_status      => l_return_status
                        ,x_error_message      => l_error_message);*/
                            pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024
                            (
                                p_acc_num          => l_acc_num,
                                p_entity_id        => l_entity_id,
                                p_entity_type      => l_entity_type,
                                p_display_name     => bank_rec.bank_name,
                                p_bank_acct_type   => bank_rec.bank_acct_type,
                                p_bank_routing_num => bank_rec.bank_routing_num,
                                p_bank_acct_num    => bank_rec.bank_acct_num,
                                p_bank_name        => bank_rec.bank_name,
                                p_business_name    => bank_rec.business_name,
                                p_user_id          => p_user_id,
                                p_gverify          => bank_rec.giac_verify,
                                p_gauthenticate    => bank_rec.giac_authenticate,
                                p_gresponse        => bank_rec.giac_response,
                                p_giact_verify     => bank_rec.giac_verified_response,
                                p_bank_status      => bank_rec.bank_status,
                                p_auto_pay         => 'Y'   -- Added by Swamy for Ticket#12309
                                ,
                                p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                                ,
                                p_division_code    => null,
                                p_source           => 'E',
                                x_bank_acct_id     => l_bank_id,
                                x_return_status    => l_return_status,
                                x_error_message    => l_error_message  --x_error_message
                            );

                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_return_status **1l', l_return_status
                            );
                            if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#10978 13062024
                                raise l_create_error;
                            end if;
                        else
                   /* FOR   B IN (   SELECT bank_Acct_id
                                      FROM bank_Accounts
                                    WHERE bank_routing_num = bank_rec.Bank_Routing_Num
                                        AND bank_acct_num    = bank_rec.Bank_Acct_Num
                                        AND bank_name          = bank_rec.bank_name
                                        AND status                = 'A'
                                        AND entity_id             = l_entity_id
                                        AND entity_type         = l_entity_type 
                                         AND bank_Account_usage =  l_acct_usage)   -- Added by Swamy for Ticket#12432
                    LOOP
                            l_bank_id := b.bank_Acct_id ;
                    END LOOP;*/
                            l_bank_id := l_bank_count;
                        end if;

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_bank_id l', l_bank_id);
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_error_message l', l_error_message);

                    --  added by Jaggi 11263
                        if bank_rec.acct_usage = 'MONTHLY' then
                            update online_fsa_hra_staging
                            set
                                monthly_fee_bank_acct_id = l_bank_id,
                                monthly_fee_payment_method = 'ACH'
                            where
                                    batch_number = p_batch_number
                                and entrp_id = p_entrp_id;

                        end if;

                -- Upload to file_attachments 
                -- Added by Swamy for Ticket#12309
                        pc_file_upload.giact_insert_file_attachments(
                            p_user_bank_stg_id => bank_rec.user_bank_acct_stg_id,
                            p_attachment_id    => null,
                            p_entity_id        => l_bank_id,
                            p_entity_name      => 'GIACT_BANK_INFO',
                            p_document_purpose => 'GIACT_DOC',
                            p_batch_number     => p_batch_number,
                            p_source           => 'E',
                            x_error_status     => x_error_status,
                            x_error_message    => x_error_message
                        );

                    end if;

                    if bank_rec.acct_usage in ( 'CLAIMS', 'FUNDING' ) then
                 /*pc_user_bank_acct.insert_bank_account(
                         p_entity_id          => l_acc_id
                        ,p_entity_type        => 'ACCOUNT'
                        ,p_display_name       => bank_rec.bank_name
                        ,p_bank_acct_type     => bank_rec.bank_acct_type
                        ,p_bank_routing_num   => bank_rec.Bank_Routing_Num
                        ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                        ,p_bank_name          => bank_rec.bank_name
                        ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                        ,p_user_id            => p_user_id
                        ,x_bank_acct_id       => l_bank_id
                        ,x_return_status      => l_return_status
                        ,x_error_message      => l_error_message);*/

                        pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024

                        (
                            p_acc_num          => l_acc_num,
                            p_entity_id        => l_acc_id,
                            p_entity_type      => 'ACCOUNT',
                            p_display_name     => bank_rec.bank_name,
                            p_bank_acct_type   => bank_rec.bank_acct_type,
                            p_bank_routing_num => bank_rec.bank_routing_num,
                            p_bank_acct_num    => bank_rec.bank_acct_num,
                            p_bank_name        => bank_rec.bank_name,
                            p_business_name    => bank_rec.business_name,
                            p_user_id          => p_user_id,
                            p_gverify          => bank_rec.giac_verify,
                            p_gauthenticate    => bank_rec.giac_authenticate,
                            p_gresponse        => bank_rec.giac_response,
                            p_giact_verify     => bank_rec.giac_verified_response,
                            p_bank_status      => bank_rec.bank_status,
                            p_auto_pay         => 'Y'    -- Added by Swamy for Ticket#12309 13062024
                            ,
                            p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                            ,
                            p_division_code    => null,
                            p_source           => 'E',
                            x_bank_acct_id     => l_bank_id,
                            x_return_status    => l_return_status,
                            x_error_message    => l_error_message --x_error_message
                        );

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_return_status **12', l_return_status);
                        if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#12309 13062024
                            raise l_create_error;
                        end if;
                        update online_fsa_hra_staging
                        set
                            funding_payment_method = 'ACH'
                        where
                                batch_number = p_batch_number
                            and entrp_id = p_entrp_id;

                -- Upload to file_attachments 
                -- Added by Swamy for Ticket#12309
                        pc_file_upload.giact_insert_file_attachments(
                            p_user_bank_stg_id => bank_rec.user_bank_acct_stg_id,
                            p_attachment_id    => null,
                            p_entity_id        => l_bank_id,
                            p_entity_name      => 'GIACT_BANK_INFO',
                            p_document_purpose => 'GIACT_DOC',
                            p_batch_number     => p_batch_number,
                            p_source           => 'E',
                            x_error_status     => x_error_status,
                            x_error_message    => x_error_message
                        );

                    end if;

                    update account
                    set
                        account_status = decode(l_active_bank_exists, 'P', '11', account_status)  -- Added by Swamy for Ticket#12309
                    where
                        entrp_id = p_entrp_id;
    -- Added by Swamy for Ticket#12309.
    -- Ticket#12464, if broker has entered pending activation bank account, then the employer will be in pending bank verification status. When the finance team
    -- activates the bank account in manage giact bank account screen, then the particular employer account status should change to pending verification.
    -- to incorporate this the below bank account details is updated in staging table
                    update user_bank_acct_staging
                    set
                        bank_acct_id = l_bank_id
                    where
                            user_bank_acct_stg_id = bank_rec.user_bank_acct_stg_id
                        and batch_number = p_batch_number
                        and entrp_id = p_entrp_id;

                end loop;
            end if;

         -- Renewals  #Added by Jaggi #11263
            if x.source = 'RENEWAL' then -- Added by Swamy for Ticket#12309
                for bank_rec in (
                    select
                        bank_name,
                        routing_number,
                        bank_acc_num,
                        bank_acc_type,
                        acct_usage,
                        monthly_fees_paid_by,
                        monthly_bank_name,
                        monthly_routing_number,
                        monthly_bank_acc_num,
                        monthly_bank_acc_type,
                        bank_status,            -- Start Addition by Swamy for Ticket#12309 13062024
                        business_name,
                        giac_response,
                        giac_verify,
                        giac_authenticate,
                        bank_acct_verified,
                        bank_status_monthly,
                        business_name_monthly,
                        giac_response_monthly,
                        giac_verify_monthly,
                        giac_authenticate_monthly,
                        giac_verified_response,
                        giac_verified_response_monthly,
                        bank_acct_verified_monthly,    -- End of Addition by Swamy for Ticket#12309 13062024   
                        enrollment_id,
                        monthly_bank_file_attachment_id,
                        bank_file_attachment_id
                    from
                        online_fsa_hra_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                        and ( ( nvl(bank_acc_num, '*') <> '*' )
                              or ( nvl(monthly_bank_acc_num, '*') <> '*' ) )
                ) loop
                    l_acct_usage := 'INVOICE';
                    if bank_rec.acct_usage in ( 'INVOICE' ) then
                        if upper(x.pay_acct_fees) = 'EMPLOYER' then
                            l_entity_id := l_acc_id;
                            l_entity_type := 'ACCOUNT';
                        elsif upper(x.pay_acct_fees) = 'BROKER' then
                            l_entity_id := pc_account.get_broker_id(l_acc_id);
                            l_entity_type := 'BROKER';
                        elsif upper(x.pay_acct_fees) in ( 'GA', 'GENERAL AGENT' ) then
                            l_entity_id := pc_account.get_ga_id(l_acc_id);
                            l_entity_type := 'GA';
                        end if;

                    end if;

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal l_entity_id: ', l_entity_id);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal l_entity_type', l_entity_type);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_acct_usage l', l_acct_usage);
                    l_bank_count := 0;

          /*  SELECT COUNT(*) INTO l_bank_count
              FROM bank_Accounts
            WHERE bank_routing_num = bank_rec.routing_number
                AND bank_acct_num    = bank_rec.bank_acc_num
                AND bank_name        = bank_rec.bank_name
                AND status           = 'A'
                AND entity_id        = l_entity_id
                AND entity_type     = l_entity_type
                AND bank_Account_usage =  l_acct_usage  ;  -- Added by Joshi for 11493
          */
                    l_bank_count := pc_user_bank_acct.get_bank_acct_id(
                        p_entity_id          => l_entity_id,
                        p_entity_type        => l_entity_type,
                        p_bank_acct_num      => bank_rec.bank_acc_num,
                        p_bank_name          => bank_rec.bank_name,
                        p_bank_routing_num   => bank_rec.routing_number,
                        p_bank_account_usage => l_acct_usage,
                        p_bank_acct_type     => bank_rec.bank_acc_type
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_bank_count l', l_bank_count);
                    if
                        nvl(l_bank_count, 0) = 0
                        and nvl(bank_rec.bank_acc_num, '*') <> '*'
                    then   -- And Cond. Added by Swamy for Ticket#12309 13062024
                  -- fee bank details
                  /*pc_user_bank_acct.insert_bank_account(
                             p_entity_id          => l_entity_id
                            ,p_entity_type        => l_entity_type
                            ,p_display_name       => bank_rec.bank_name
                            ,p_bank_acct_type     => bank_rec.bank_acc_type
                            ,p_bank_routing_num   => bank_rec.routing_number
                            ,p_bank_acct_num      => bank_rec.bank_acc_num
                            ,p_bank_name          => bank_rec.bank_name
                            ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                            ,p_user_id            => p_user_id
                            ,x_bank_acct_id       => l_bank_id
                            ,x_return_status      => l_return_status
                            ,x_error_message      => l_error_message);*/
                        pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024
                        (
                            p_acc_num          => l_acc_num,
                            p_entity_id        => l_entity_id,
                            p_entity_type      => l_entity_type,
                            p_display_name     => bank_rec.bank_name,
                            p_bank_acct_type   => bank_rec.bank_acc_type,
                            p_bank_routing_num => bank_rec.routing_number,
                            p_bank_acct_num    => bank_rec.bank_acc_num,
                            p_bank_name        => bank_rec.bank_name,
                            p_business_name    => bank_rec.business_name,
                            p_user_id          => p_user_id,
                            p_gverify          => bank_rec.giac_verify,
                            p_gauthenticate    => bank_rec.giac_authenticate,
                            p_gresponse        => bank_rec.giac_response,
                            p_giact_verify     => bank_rec.giac_verified_response,
                            p_bank_status      => bank_rec.bank_status,
                            p_auto_pay         => 'Y'    -- Added by Swamy for Ticket#12309 13062024
                            ,
                            p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                            ,
                            p_division_code    => null,
                            p_source           => 'R',
                            x_bank_acct_id     => l_bank_id,
                            x_return_status    => l_return_status,
                            x_error_message    => l_error_message --x_error_message
                        );

                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_return_status **13', l_return_status);
                        if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#12309 13062024
                            raise l_create_error;
                        end if;
                    end if;
                -- Added by Swamy for Ticket#12309
                    pc_file_upload.giact_insert_file_attachments(
                        p_user_bank_stg_id => bank_rec.enrollment_id,
                        p_attachment_id    => bank_rec.bank_file_attachment_id,
                        p_entity_id        => l_bank_id,
                        p_entity_name      => 'GIACT_BANK_INFO',
                        p_document_purpose => 'GIACT_DOC',
                        p_batch_number     => p_batch_number,
                        p_source           => 'R',
                        x_error_status     => x_error_status,
                        x_error_message    => x_error_message
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal renewal  l_bank_id l', l_bank_id);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_bank_id l', l_bank_id);

            -- Monthly bank details
                    if bank_rec.monthly_bank_name is not null then
                        l_bank_count := 0;
                        l_entity_id := null;
                        l_entity_type := null;
                        if bank_rec.monthly_bank_name is not null then
                            if upper(bank_rec.monthly_fees_paid_by) = 'EMPLOYER' then
                                l_entity_id := l_acc_id;
                                l_entity_type := 'ACCOUNT';
                            elsif upper(bank_rec.monthly_fees_paid_by) = 'BROKER' then
                                l_entity_id := pc_account.get_broker_id(l_acc_id);
                                l_entity_type := 'BROKER';
                            elsif upper(bank_rec.monthly_fees_paid_by) in ( 'GA', 'GENERAL AGENT' ) then
                                l_entity_id := pc_account.get_ga_id(l_acc_id);
                                l_entity_type := 'GA';
                            end if;

               -- check if used had entered existing bank account details.
              /*  SELECT COUNT(*) INTO l_bank_count
                 FROM bank_Accounts
                WHERE bank_routing_num = bank_rec.monthly_routing_number
                  AND bank_acct_num    = bank_rec.monthly_bank_acc_num
                  AND bank_name        = bank_rec.monthly_bank_name
                  AND bank_acct_type   = bank_rec.monthly_bank_acc_type
                  AND status           = 'A'
                  AND entity_id        = l_entity_id
                  AND entity_type      = l_entity_type
                  AND bank_Account_usage =  l_acct_usage  ;
                 */
                            l_bank_count := pc_user_bank_acct.get_bank_acct_id(
                                p_entity_id          => l_entity_id,
                                p_entity_type        => l_entity_type,
                                p_bank_acct_num      => bank_rec.monthly_bank_acc_num,
                                p_bank_name          => bank_rec.monthly_bank_name,
                                p_bank_routing_num   => bank_rec.monthly_routing_number,
                                p_bank_account_usage => l_acct_usage,
                                p_bank_acct_type     => bank_rec.monthly_bank_acc_type
                            );

                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  monthly l_bank_count  l', l_bank_count
                            );
                            if nvl(l_bank_count, 0) = 0 then
                 /*pc_user_bank_acct.insert_bank_account(
                             p_entity_id          => l_entity_id
                            ,p_entity_type        => l_entity_type
                            ,p_display_name       => bank_rec.monthly_bank_name
                            ,p_bank_acct_type     => bank_rec.monthly_bank_acc_type
                            ,p_bank_routing_num   => bank_rec.monthly_routing_number
                            ,p_bank_acct_num      => bank_rec.monthly_Bank_Acc_Num
                            ,p_bank_name          => bank_rec.monthly_bank_name
                            ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                            ,p_user_id            => p_user_id
                            ,x_bank_acct_id       => l_bank_id
                            ,x_return_status      => l_return_status
                            ,x_error_message      => l_error_message);*/
                                pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#12309 13062024
                                (
                                    p_acc_num          => l_acc_num,
                                    p_entity_id        => l_entity_id,
                                    p_entity_type      => l_entity_type,
                                    p_display_name     => bank_rec.monthly_bank_name,
                                    p_bank_acct_type   => bank_rec.monthly_bank_acc_type,
                                    p_bank_routing_num => bank_rec.monthly_routing_number,
                                    p_bank_acct_num    => bank_rec.monthly_bank_acc_num,
                                    p_bank_name        => bank_rec.monthly_bank_name,
                                    p_business_name    => bank_rec.business_name,
                                    p_user_id          => p_user_id,
                                    p_gverify          => bank_rec.giac_verify_monthly,
                                    p_gauthenticate    => bank_rec.giac_authenticate_monthly,
                                    p_gresponse        => bank_rec.giac_response_monthly,
                                    p_giact_verify     => bank_rec.giac_verified_response_monthly,
                                    p_bank_status      => bank_rec.bank_status_monthly,
                                    p_auto_pay         => 'Y'    -- Added by Swamy for Ticket#12309 13062024
                                    ,
                                    p_bank_acct_usage  => nvl(l_acct_usage, 'ONLINE')  -- Added by Swamy for Ticket#12309
                                    ,
                                    p_division_code    => null,
                                    p_source           => 'R',
                                    x_bank_acct_id     => l_bank_id,
                                    x_return_status    => l_return_status,
                                    x_error_message    => l_error_message --x_error_message
                                );

                                pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_return_status **14', l_return_status
                                );
                                if l_return_status not in ( 'S', 'P' ) then   -- Added by Swamy for Ticket#12309 13062024
                                    raise l_create_error;
                                end if;
                                pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal monthly l_bank_id l', l_bank_id);
                            else

                /*FOR   B IN (    SELECT bank_Acct_id
                                  FROM bank_Accounts
                                 WHERE bank_routing_num = bank_rec.monthly_routing_number
                                   AND bank_acct_num    = bank_rec.monthly_bank_acc_num
                                   AND bank_name        = bank_rec.monthly_bank_name
                                   AND bank_acct_type   = bank_rec.monthly_bank_acc_type
                                   AND status           = 'A'
                                   AND entity_id        = l_entity_id
                                   AND entity_type      = l_entity_type
                                   AND bank_Account_usage =  l_acct_usage )
                LOOP
                            l_bank_id := b.bank_Acct_id ;
               END LOOP;*/
                                l_bank_id := l_bank_count;
                            end if;

                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_bank_id l', l_bank_id);
                            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal  l_error_message l', l_error_message)
                            ;
                            update online_fsa_hra_staging
                            set
                                monthly_fee_bank_acct_id = nvl(l_bank_id, monthly_fee_bank_acct_id)
                            where
                                    batch_number = p_batch_number
                                and entrp_id = p_entrp_id;

                -- Added by Swamy for Ticket#12309
                            pc_file_upload.giact_insert_file_attachments(
                                p_user_bank_stg_id => bank_rec.enrollment_id,
                                p_attachment_id    => bank_rec.monthly_bank_file_attachment_id,
                                p_entity_id        => l_bank_id,
                                p_entity_name      => 'GIACT_BANK_INFO',
                                p_document_purpose => 'GIACT_DOC',
                                p_batch_number     => p_batch_number,
                                p_source           => 'R',
                                x_error_status     => x_error_status,
                                x_error_message    => x_error_message
                            );

                        end if;

                    end if;

                    p_bank_acct_id := l_bank_id; -- Added by Swamy for Ticket#12309
                    x_error_status := l_return_status;
        /* commented by Joshi fof 11263.
	   IF x.payment_method = 'ACH' Then -- For the   Ticket #7241 added by prabu on 16/11/2018


          IF X.source     = 'RENEWAL' THEN     -- Added Jaggi/Swamy for Ticket#11040 on 05/04/2022
              PC_EMPLOYER_ENROLL.insert_user_bank_acct
                (p_acc_num          => l_acc_num ,
                p_display_name      => bank_rec.Bank_Name ,
                p_bank_acct_type    => bank_rec.Bank_Acct_Type ,
                p_bank_routing_num  => bank_rec.Bank_Routing_Num ,
                p_bank_acct_num     => bank_rec.Bank_Acct_Num ,
                p_bank_name         => bank_rec.bank_name ,
                p_user_id           => p_user_id ,
                p_acct_usage        => l_acct_usage ,
                x_bank_acct_id      => l_bank_id ,
                x_return_status     => l_return_status ,
                x_error_message     => l_error_message );
          ELSE
            pc_user_bank_acct.insert_bank_account(
                     p_entity_id          => l_acc_id
                    ,p_entity_type        => 'ACCOUNT'
                    ,p_display_name       => bank_rec.bank_name
                    ,p_bank_acct_type     => bank_rec.bank_acct_type
                    ,p_bank_routing_num   => bank_rec.Bank_Routing_Num
                    ,p_bank_acct_num      => bank_rec.Bank_Acct_Num
                    ,p_bank_name          => bank_rec.bank_name
                    ,p_bank_account_usage => NVL(l_acct_usage,'ONLINE')
                    ,p_user_id            => p_user_id
                    ,x_bank_acct_id       => l_bank_id
                    ,x_return_status      => l_return_status
                    ,x_error_message      => l_error_message);
          END IF;

        End If;

          pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal','Bank Data created successfully ');
          x_error_status := l_return_status;
          */
                end loop;
            end if;
        ------------ -- end Below code added by rprabu function to get MULTI BANK FUNCTIONALITY ticket 6346
--      END IF;--Bank Name not null
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', 'Bank Data created successfully ');
            for y in (
                select
                    *
                from
                    online_fsa_hra_plan_staging
                where
                    enrollment_id = x.enrollment_id
            ) loop
                pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', '   Y.funding_option.. ' || y.funding_option);
                pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal l_pay_acct_fees', l_pay_acct_fees);
                l_ben_plan_id := null; -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                if x.source = 'RENEWAL' then
                    pc_web_er_renewal.insrt_er_ben_plan_enrlmnt(
                        p_ben_plan_id     => y.org_ben_plan_id,
                        p_min_election    => y.min_annual_election,
                        p_max_election    => y.max_annual_election,
                        p_new_plan_yr     => y.new_plan_yr,
                        p_new_end_plan_yr => null,     -- Added by Swamy for Ticket#9932 on 07/06/2021
                        p_runout_prd      => y.run_out_period,
                        p_runout_trm      => y.run_out_term,
                        p_grace           => y.grace_period,
                        p_grace_days      => y.grace_period,
                        p_rollover        => y.rollover_flag,
                        p_funding_options => y.funding_option,   ---- X.Fund_Option Is Replaced By  Y.Funding_Option For 8313 04/11/2019 Rprabu
                        p_non_discm       => y.non_discm_testing,
                        p_new_hire        => y.new_hire_contrib,    /* Ticket 4775 .Prorate Update */
                        p_eob_required    => y.eob,
                        p_enrlmnt_start   => y.open_enrollment_start_date,
                        p_enrlmnt_endt    => y.open_enrollment_end_date,
                        p_plan_docs       => y.plan_docs_flag,
                        p_user_id         => p_user_id,
                        p_post_tax        => null,
                        p_pay_acct_fees   => l_pay_acct_fees,--Renewal Phase#2
                        p_batch_number    => p_batch_number, -- Added by Swamy for Ticket#10431(Renewal Resubmit)
                        p_new_ben_pln_id  => l_ben_plan_id,
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    x_error_status := l_return_status;
                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', 'Created Plan.. ' || l_ben_plan_id);
          /* Create Coverage  details */
                    insert into ben_plan_coverages (
                        coverage_id,
                        ben_plan_id,
                        acc_id,
                        start_date,
                        end_date,
                        coverage_type,
                        annual_election,
                        coverage_tier_name,
                        max_rollover_amount,
                        deductible,
                        created_by,
                        creation_date
                    )
                        select
                            coverage_id,
                            l_ben_plan_id,
                            acc_id,
                            y.plan_start_date,
                            y.plan_end_date,
                            coverage_type,
                            annual_election,
                            coverage_tier_name,
                            max_rollover_amount,
                            deductible,
                            created_by,
                            creation_date
                        from
                            ben_plan_coverages_staging
                        where
                                ben_plan_id = y.enrollment_detail_id
                            and batch_number = p_batch_number;

                    update online_fsa_hra_plan_staging
                    set
                        ben_plan_id = l_ben_plan_id
                    where
                        y.enrollment_detail_id = enrollment_detail_id;

                    if l_ben_plan_id is not null then  ------7335 start  rprabu 21/01/2020
                        l_prev_ben_plan_id := null;
                        begin
                            select
                                max(ben_plan_id)
                            into l_prev_ben_plan_id
                            from
                                ben_plan_enrollment_setup
                            where
                                    entrp_id = y.entrp_id
                                and plan_type = y.plan_type
                                and ben_plan_id < l_ben_plan_id;

                        exception
                            when others then
                                null;
                        end;

          /***** Insert Eligibility Requirement Data******************************/
            /**Eligibility data is copied for all the plans renewals 7335 */
                        if l_prev_ben_plan_id is not null then
                            insert into custom_eligibility_req (
                                eligibility_id,
                                acct_for_pretax_flag,
                                permit_cash_flag,
                                limit_cash_flag,
                                revoke_elect_flag,
                                cease_covg_flag,
                                collective_bargain_flag,
                                no_of_hrs_part_time,
                                no_of_hrs_seasonal,
                                no_of_hrs_current,
                                new_ee_month_servc,
                                min_age_req,  --- 7949  Rprabu 07/02/2020
                                min_age,       --- 7949  Rprabu 07/02/2020
                                select_entry_date_flag,
                                plan_new_ee_join,
                                permit_partcp_eoy,
                                automatic_enroll,
                                ee_exclude_plan_flag,
                                coincident_next_flag,
                                salesrep_id,
                                limit_cash_paid,
                                entity_id,
                                contrib_flag,
                                contrib_amt,
                                percent_contrib
                            )
                                select
                                    eligibility_seq.nextval,
                                    x.er_pretax_flag,
                                    x.permit_cash_flag,
                                    x.limit_cash_flag,
                                    x.revoke_elect_flag,
                                    x.cease_covg_flag,
                                    x.collective_bargain_flag,
                                    x.no_of_hrs_part_time,
                                    x.no_of_hrs_seasonal,
                                    x.no_of_hrs_current,
                                    x.new_ee_month_servc,
                                    x.min_age_req,
                                    x.min_age,
                                    x.select_entry_date_flag,
                                    x.plan_new_ee_join,
                                    x.permit_partcp_eoy,
                                    x.automatic_enroll,
                                    x.ee_exclude_plan_flag,
                                    x.coincident_next_flag,
                                    x.salesrep_id,
                                    x.limit_cash_paid,
                                    l_ben_plan_id,
                                    x.contrib_flag,
                                    nvl(y.er_lump_amt, x.contrib_amt),
                                    percent_contrib
                                from
                                    custom_eligibility_req x
                                where
                                    entity_id = l_prev_ben_plan_id;

					  /***Update Salesrep and GA information *****/
                            update custom_eligibility_req
                            set
                                salesrep_id = x.salesrep_id
                            where
                                entity_id = l_ben_plan_id;

                        end if; 	   ----- L_prev_ben_Plan_id IS NOT NULL Then
                        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', 'Eligibility Data created successfully '
                        );
                        update online_fsa_hra_plan_staging
                        set
                            ben_plan_id = l_ben_plan_id
                        where
                            y.enrollment_detail_id = enrollment_detail_id;

                    end if;  -------l_ben_plan_id IS NOT NULL Then

                else -- Enrollments

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', 'Creatig Plan Info.. ' || y.plan_type);
                    pc_employer_enroll.update_plan_info(
                        p_entrp_id        => p_entrp_id,
                        p_fiscal_end_date => to_char(x.fiscal_yr_end, 'mm/dd/rrrr'),
                        p_plan_type       => y.plan_type,
                        p_plan_number     => y.plan_number,
                        p_eff_date        => to_char(y.effective_date, 'mm/dd/rrrr') --Transation Date
                        ,
                        p_org_eff_date    => to_char(y.org_effective_date, 'mm/dd/rrrr')                                                                                                                                                                              --Original Eff date
                        ,
                        p_plan_start_date => to_char(y.plan_start_date, 'mm/dd/rrrr')                                                                                                                                                                              --
                        ,
                        p_plan_end_date   => to_char(y.plan_end_date, 'mm/dd/rrrr'),
                        p_takeover        => y.take_over                                                                                                                                                       --restament then Y else N
                        ,
                        p_user_id         => p_user_id,
                        p_plan_name       =>
                                     case
                                         when x.plan_code = 509 then
                                             substr(
                                                 replace(y.plan_type
                                                         || 'BASIC'
                                                         || pc_entrp.get_entrp_name(p_entrp_id),
                                                         ' ',
                                                         ''),
                                                 1,
                                                 18
                                             )
                                         else
                                             substr(
                                                 replace(y.plan_type
                                                         || 'COMPREHENSIVE'
                                                         || pc_entrp.get_entrp_name(p_entrp_id),
                                                         ' ',
                                                         ''),
                                                 1,
                                                 18
                                             )
                                     end                                      -- added by Jaggi #10430 on 11/15/2021
                                     ,
                        x_er_ben_plan_id  => l_ben_plan_id,
                        x_error_status    => l_return_status,
                        x_error_message   => l_error_message
                    );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', 'Created Plan.. ' || l_ben_plan_id);
                    x_error_status := l_return_status;  -- Added by Swamy for Ticket#12478

                    update ben_plan_enrollment_setup
                    set
                        open_enrollment_start_date = y.open_enrollment_start_date,
                        open_enrollment_end_date = y.open_enrollment_end_date,
                        minimum_election = y.min_annual_election,
                        maximum_election = y.max_annual_election,
                        rollover = y.rollover_flag,
                        grace_period = y.grace_period,
                        runout_period_days = y.run_out_period,
                        allow_debit_card = y.all_debit_card,
                        plan_docs_flag = y.plan_docs_flag,
                        funding_options = x.fund_option,
                        non_discrm_flag = x.ndt_testing_flag,
                        new_hire_contrib = y.new_hire_contrib,
                        reimbursement_type = y.er_reimburse_claim,
                        runout_period_term = y.run_out_term,
                        claim_reimbursed_by =
                            case
                                when x.fund_option = '100CR' then
                                    'EMPLOYER'
                                else
                                    'STERLING'
                            end,
                        ben_plan_name =
                            case
                                when x.plan_code = 509 then
                                    substr(
                                        replace(y.plan_type
                                                || 'BASIC'
                                                || pc_entrp.get_entrp_name(p_entrp_id),
                                                ' ',
                                                ''),
                                        1,
                                        18
                                    )
                                else
                                    substr(
                                        replace(y.plan_type
                                                || 'COMPREHENSIVE'
                                                || pc_entrp.get_entrp_name(p_entrp_id),
                                                ' ',
                                                ''),
                                        1,
                                        18
                                    )
                            end,
                        plan_type = 'HRA'
                    where
                        ben_plan_id = l_ben_plan_id;
          /*** Create Coverage Tier *****/
                    insert into ben_plan_coverages (
                        coverage_id,
                        ben_plan_id,
                        acc_id,
                        start_date,
                        end_date,
                        coverage_type,
                        annual_election,
                        coverage_tier_name,
                        max_rollover_amount,
                        created_by,
                        creation_date
                    )
                        select
                            coverage_id,
                            l_ben_plan_id,
                            acc_id,
                            y.plan_start_date,
                            y.plan_end_date,
                            coverage_type,
                            annual_election,
                            coverage_tier_name,
                            y.rollover_amount,
                            created_by,
                            creation_date
                        from
                            ben_plan_coverages_staging
                        where
                                ben_plan_id = y.enrollment_detail_id
                            and coverage_tier_type = 'Funding_Amount';

		   /**Eligibility data is copied for all the plans enrollment 7335 */
                    insert into custom_eligibility_req (
                        eligibility_id,
                        acct_for_pretax_flag,
                        permit_cash_flag,
                        limit_cash_flag,
                        revoke_elect_flag,
                        cease_covg_flag,
                        collective_bargain_flag,
                        no_of_hrs_part_time,
                        no_of_hrs_seasonal,
                        no_of_hrs_current,
                        new_ee_month_servc,
                        min_age_req,
                        min_age,
                        select_entry_date_flag,
                        plan_new_ee_join,
                        permit_partcp_eoy,
                        automatic_enroll,
                        ee_exclude_plan_flag,
                        contrib_amt,
                        coincident_next_flag,
                        salesrep_id,
                        limit_cash_paid,
                        entity_id
                    )
                        select
                            eligibility_seq.nextval,
                            x.er_pretax_flag,
                            x.permit_cash_flag,
                            x.limit_cash_flag,
                            x.revoke_elect_flag,
                            x.cease_covg_flag,
                            x.collective_bargain_flag,
                            x.no_of_hrs_part_time,
                            x.no_of_hrs_seasonal,
                            x.no_of_hrs_current,
                            x.new_ee_month_servc,
                            x.minimum_age_flag,
                            x.min_age_req,
                            x.select_entry_date_flag,
                            x.plan_new_ee_join,
                            x.permit_partcp_eoy,
                            x.automatic_enroll,
                            x.ee_exclude_plan_flag,
                            y.er_lump_amt,
                            x.coincident_next_flag,
                            x.salesrep_id,
                            x.limit_cash_paid,
                            l_ben_plan_id
                        from
                            dual;

                    update enterprise
                    set
                        card_allowed = (
                            case
                                when y.all_debit_card = 'Y' then
                                    0
                                else
                                    1
                            end
                        )
                    where
                        entrp_id = p_entrp_id;
          /* Update EOB required */
                    begin
                        select
                            'Y'
                        into l_eob
                        from
                            plan_eligibile_expenses
                        where
                                expense_code = '4X'
                            and entity_id = p_entrp_id;

                        update ben_plan_enrollment_setup
                        set
                            eob_required = l_eob
                        where
                            ben_plan_id = l_ben_plan_id;

                    exception
                        when others then
                            update ben_plan_enrollment_setup
                            set
                                eob_required = 'N'
                            where
                                ben_plan_id = l_ben_plan_id;

                    end;

          -- Added by Joshi for 10431.
                    update online_fsa_hra_plan_staging
                    set
                        ben_plan_id = l_ben_plan_id
                    where
                            enrollment_detail_id = y.enrollment_detail_id
                        and batch_number = p_batch_number;

                end if; --Enrollments/Renewals
            end loop; --Plan Level Loop
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', 'l_acc_num '
                                                                                  || l_acc_num
                                                                                  || ' l_inactive_plan_exist :='
                                                                                  || l_inactive_plan_exist
                                                                                  || ' X.source :='
                                                                                  || x.source
                                                                                  || ' l_renewal_sign_type :='
                                                                                  || l_renewal_sign_type
                                                                                  || ' P_USER_ID :='
                                                                                  || p_user_id);
      /* Update ACClevel staging table **/
            update online_fsa_hra_staging
            set
                acc_num = l_acc_num,
                error_message = 'Success'
            where
                enrollment_id = x.enrollment_id;

            if x.source is null then

        /***In last update complete flag ****/
		/* commented by Joshi for 10430
        UPDATE ACCOUNT
        SET complete_flag = 1
        WHERE acc_num     = l_acc_num; */


                if
                    l_inactive_plan_exist = 'I'
                    and nvl(
                        pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                        'N'
                    ) = 'N'
                then
                    pc_employer_enroll_compliance.update_inactive_account(l_acc_id, p_user_id);
                else
                    update account
                    set
                        complete_flag = 1,
                        enrolled_date =
                            case
                                when enrolled_date is null then
                                    sysdate
                                else
                                    enrolled_date
                            end,-- 10431 Joshi
                        submit_by = p_user_id
                    where
                        acc_num = l_acc_num;

                end if;
            else
                if nvl(l_renewal_sign_type, '*') <> 'EMPLOYER' then -- added by Jaggi #11368
          -- Added by Joshi for 10431 -- Renewal
                    for u in (
                        select
                            user_type
                        from
                            online_users
                        where
                            user_id = p_user_id
                    ) loop
                        if u.user_type = 'B' then
                            l_renewed_by := 'BROKER';
                        elsif u.user_type = 'G' then
                            l_renewed_by := 'GA';
                        else
                            l_renewed_by := 'EMPLOYER';
                        end if;
                    end loop;

           -- Added by Joshi for 10431 -- Renewal
                    update account
                    set
                        renewed_by = l_renewed_by,
                        renewed_date = sysdate  -- 10431 Joshi
                    where
                        acc_num = l_acc_num;

                end if;
            end if;

     -- Added by Jaggi for Ticket #11086

            pc_employer_enroll_compliance.update_acct_pref(p_batch_number, p_entrp_id);
            select
                nvl(broker_id, 0)
            into l_broker_id
            from
                table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

            if l_broker_id > 0 then
                l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_acc_id);
                pc_broker.create_broker_authorize(
                    p_broker_id        => l_broker_id,
                    p_acc_id           => l_acc_id,
                    p_broker_user_id   => null,
                    p_authorize_req_id => l_authorize_req_id,
                    p_user_id          => p_user_id,
                    x_error_status     => l_return_status,
                    x_error_message    => l_error_message
                );

                x_error_status := l_return_status;  -- Added by Swamy for Ticket#12478
            end if;
        -- code ends here by Joshi.
        end loop; ---Acct level Loop

          -- added by Jaggi #11368
        update account
        set
            signature_account_status = null
        where
            entrp_id = p_entrp_id;

        x_error_status := nvl(l_return_status, 'S');  -- Added by Swamy for Ticket#12478
        pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', 'HRA Enrollments submitted successfully '
                                                                              || 'x_error_status :=='
                                                                              || x_error_status
                                                                              || 'x_error_message :='
                                                                              || x_error_message);

    exception
        when l_create_error then
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal', ' error in l_create_error x_error_message ' || x_error_message
            );
            rollback to savepoint enroll_renewal_savepoint;
            x_error_status := 'E';
            update online_fsa_hra_staging
            set
                error_message = x_error_message
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.process_hra_enrollment_renewal error in OTHERS',
                             sqlerrm || dbms_utility.format_error_backtrace());
            x_error_status := 'E';
    end process_hra_enrollment_renewal;

    procedure create_coverage_data (
        p_covg_tier            in varchar2_tbl,
        p_funding_amount       in varchar2_tbl,
        p_covg_tier2           in varchar2_tbl,
        p_funding_amount2      in varchar2_tbl,
        p_batch_number         in number,
        p_user_id              in number,
        p_rollover_amount      in varchar2_tbl,
        p_acc_id               in number,
        p_covg_tier_type       in varchar2,
        p_enrollment_detail_id in number,
        p_source               in varchar2 default null,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    ) is
    begin
        x_error_status := 'S';
        pc_log.log_error('In Coverage Count in Staging table', p_covg_tier.count);
        pc_log.log_error('In Coverage Count in Staging table', p_source);
        delete from ben_plan_coverages_staging
        where
                batch_number = p_batch_number
            and ben_plan_id = p_enrollment_detail_id;

        if p_source = 'RENEWAL' then
            for i in 1..p_covg_tier.count loop
                pc_log.log_error('In Coverage Count in Staging table FUnd amount',
                                 p_funding_amount2(i));
                pc_log.log_error('In Coverage Count in Staging table Type',
                                 p_covg_tier(i));
                insert into ben_plan_coverages_staging (
                    coverage_id,
                    ben_plan_id,
                    acc_id,
                    coverage_type,
                    creation_date,
                    created_by,
                    annual_election,
                    coverage_tier_name,
                    max_rollover_amount,
                    coverage_tier_type,
                    deductible,
                    batch_number
                ) values ( coverage_seq.nextval,
                           p_enrollment_detail_id,
                           p_acc_id,
                           p_covg_tier(i),
                           sysdate,
                           p_user_id,
                           p_funding_amount(i),
                           p_covg_tier(i),
                           0 ---p_rollover_amount(i)  --- Ticket 6899 prabu 07/11/2018 p_rollover_amount replaced with 0.
                           ,
                           null,
                           p_funding_amount2(i),
                           p_batch_number );

            end loop;
        else --Enrollments
            pc_log.log_error('In Coverage Date', 'After Delete');
            for i in 1..p_covg_tier.count loop
                insert into ben_plan_coverages_staging (
                    coverage_id,
                    ben_plan_id,
                    acc_id,
                    coverage_type,
                    creation_date,
                    created_by,
                    annual_election,
                    coverage_tier_name,
                    max_rollover_amount,
                    coverage_tier_type,
                    batch_number
                ) values ( coverage_seq.nextval,
                           p_enrollment_detail_id,
                           p_acc_id,
                           p_covg_tier(i),
                           sysdate,
                           p_user_id,
                           p_funding_amount(i),
                           p_covg_tier(i),
                           0 ---p_rollover_amount(i)  --- Ticket 6899 prabu 07/11/2018 p_rollover_amount replaced with 0.
                           ,
                           'Funding_Amount',
                           p_batch_number );

            end loop;--Coverage tier loop
            for i in 1..p_covg_tier2.count loop
                if p_covg_tier2(i) is not null then
                    insert into ben_plan_coverages_staging (
                        coverage_id,
                        ben_plan_id,
                        acc_id,
                        coverage_type,
                        creation_date,
                        created_by,
                        annual_election,
                        coverage_tier_name,
                        max_rollover_amount,
                        coverage_tier_type,
                        batch_number
                    ) values ( coverage_seq.nextval,
                               p_enrollment_detail_id,
                               p_acc_id,
                               p_covg_tier2(i),
                               sysdate,
                               p_user_id,
                               p_funding_amount2(i),
                               p_covg_tier2(i),
                               0----p_rollover_amount(i) --- Ticket 6899 prabu 07/11/2018 p_rollover_amount replaced with 0.
                               ,
                               p_covg_tier_type,
                               p_batch_number );

                end if;
            end loop;--Coverage tier loop
        end if;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_COVERAGE_DATA', sqlerrm);
    end create_coverage_data;

    procedure insert_user_bank_acct (
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        p_acct_usage       in varchar2,
        x_bank_acct_id     out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        setup_error exception;
        l_acc_id                number;
        l_entity_type           varchar2(100);   -- Added by Swamy for Ticket#10747
        l_broker_id             broker.broker_id%type;
        l_count                 number := 0;
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

    -- Start Added by swmay for ticket#10747
        pc_broker.get_broker_id(p_user_id, l_entity_type, l_broker_id);
        if l_entity_type = 'BROKER' then
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
                        p_bank_account_usage => p_acct_usage,
                        p_user_id            => p_user_id,
                        x_bank_acct_id       => x_bank_acct_id,
                        x_return_status      => x_return_status,
                        x_error_message      => x_error_message
                    );

                    if nvl(x_return_status, '*') <> 'S' then
                        raise setup_error;
                    end if;
                end if;
            end loop;
        else
            select
                acc_id,
                account_type
            into
                l_acc_id,
                l_account_type
            from
                account
            where
                acc_num = p_acc_num;
       -- End of addition by swmay for ticket#10747
            for x in (
                select
                    count(*) cnt
                from
                    user_bank_acct_v
                where
                        acc_id = l_acc_id
                    and bank_routing_num = p_bank_routing_num
                    and bank_acct_num = p_bank_acct_num
                    and bank_name = p_bank_name
                    and status = 'A'
            ) loop
                if x.cnt > 1 then
                    x_error_message := 'Your account has bank records with same routing number and account number';
                    raise setup_error;
                end if;
            end loop;

         -- Added by Swamy Ticket#12058 18/03/2024
            if l_account_type = 'COBRA' then
                l_duplicate_bank_exists := pc_user_bank_acct.check_duplicate_bank_account(
                    p_routing_number    => p_bank_routing_num,
                    p_bank_acct_num     => p_bank_acct_num,
                    p_bank_acct_id      => null,
                    p_bank_name         => p_bank_name,
                    p_bank_account_type => p_bank_acct_type,
                    p_acc_id            => l_acc_id,
                    p_ssn               => null,
                    p_user_id           => p_user_id    -- Added by Swamy for Ticket#12309 
                );

                if l_duplicate_bank_exists = 'Y' then
                    x_error_message := 'The Bank details provided already exist in our system , Please enter different Bank details to procced.'
                    ;
                    raise setup_error;
                end if;
            end if;

            insert into user_bank_acct (
                bank_acct_id,
                acc_id,
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
                       l_acc_id,
                       p_display_name,
                       p_bank_acct_type,
                       lpad(p_bank_routing_num, 9, 0),
                       p_bank_acct_num,
                       p_bank_name,
                       p_acct_usage,
                       p_user_id,
                       p_user_id,
                       sysdate,
                       sysdate ) returning bank_acct_id into x_bank_acct_id;

        end if;

    exception
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('insert_user_bank_acct', x_error_message);
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
            pc_log.log_error('insert_user_bank_acct', sqlerrm);
    end insert_user_bank_acct;
 --For Ticket#5020 ,add new flag for Acct payment fees
    procedure set_payment (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_salesrep_flag               in online_compliance_staging.salesrep_flag%type,
        p_salesrep_id                 in online_compliance_staging.salesrep_id%type,
        p_cp_invoice_flag             in varchar2,
        p_fees_payment_flag           in varchar2,
        p_fees_remitance_flag         in varchar2,
        p_acct_payment_fees           in varchar2,
      /*Ticket#5020 */
        p_bank_name                   in online_compliance_staging.bank_name%type,
        p_bank_acc_type               in online_compliance_staging.bank_acc_type%type,
        p_routing_number              in online_compliance_staging.routing_number%type,
        p_bank_acc_num                in online_compliance_staging.bank_acc_num%type,
        p_page_validity               in varchar2,
        p_bank_acct_id                in number,               -- Added by Joshi for 9141
        p_bank_authorize              in varchar2,             -- Added by Jaggi ##9602
        p_user_id                     in number,               -- 10747new
        p_bank_acct_usage             in varchar2,             -- 10747new
      -- Added by Jaggi #11262
        p_optional_bank_name          in online_compliance_staging.optional_bank_name%type,
        p_optional_bank_acc_type      in online_compliance_staging.optional_bank_acc_type%type,
        p_optional_routing_number     in online_compliance_staging.optional_routing_number%type,
        p_optional_bank_acc_num       in online_compliance_staging.optional_bank_acc_num%type,
        p_remit_bank_name             in online_compliance_staging.remit_bank_name%type,
        p_remit_bank_acc_type         in online_compliance_staging.remit_bank_acc_type%type,
        p_remit_routing_number        in online_compliance_staging.remit_routing_number%type,
        p_remit_bank_acc_num          in online_compliance_staging.remit_bank_acc_num%type,
        p_pay_optional_fees_by        in varchar2,
        p_optional_fee_payment_method in varchar2,
        p_optional_fee_bank_acct_id   in varchar2,
        p_optional_bank_authorize     in varchar2,
        p_remit_bank_authorize        in varchar2,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is

        setup_error exception;
        l_count                 number;
        l_acct_type             varchar2(100);
        l_contact_cnt           number;
        l_cnt                   number;
        l_enrolle_type          varchar2(100);   ------  9392 rprabu 09/10/2020
        l_entity_type           varchar2(100);
        l_broker_id             number;
        x_user_bank_acct_stg_id number;
        l_page_validity         varchar2(10);
        l_user_bank_acct_stg_id number;
        l_bank_name             varchar2(50);
        l_optional_bank_name    varchar2(50);
        l_source                varchar2(50);   -- Added by swamy for Ticket#11364
        l_page_no               varchar2(5);    -- Added by swamy for Ticket#11364
        x_bank_status           varchar2(50);
    begin
        x_error_status := 'S';

    -- Moved from here to bottom by swamy for ticket#11364
    /*SELECT COUNT(*)
      INTO l_count
      FROM compliance_plan_staging
     WHERE entity_id      = p_entrp_id
       AND batch_number   = p_batch_number ;
    IF l_count         = 0 THEN
      x_error_message := ' No previous data for Compliance Plan';
      raise setup_error ;
    END IF;
    */
        pc_log.log_error('pc_employer_enroll.set_payment', 'P_user_id ' || p_user_id);
        pc_log.log_error('pc_employer_enroll.set_payment', 'p_optional_bank_name ' || p_optional_bank_name);
    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        pc_broker.get_broker_id(
            p_user_id     => p_user_id,
            p_entity_type => l_entity_type,
            p_broker_id   => l_broker_id
        );

        l_entity_type := nvl(l_entity_type, 'EMPLOYER');
        select
            count(*)
        into l_count
        from
            online_compliance_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        if l_count = 0 then
            x_error_message := ' No previous Bank details data for Compliance Plan';
            raise setup_error;
        end if;

    -- moved from bottom by swamy  Ticket#6294
    --If user does not craete any contact in UI ,then ww will just update PAGE3_CONTACT as "I" Ticket#5462
        select
            account_type,
            nvl(enrolle_type, 'EMPLOYER')    ------   enrolle_type   9392 rprabu 09/10/2020
        into
            l_acct_type,
            l_enrolle_type
        from
            account
        where
            entrp_id = p_entrp_id;

        select
            bank_name,
            optional_bank_name,
            source  -- Added by swamy for Ticket#11364
        into
            l_bank_name,
            l_optional_bank_name,
            l_source
        from
            online_compliance_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        pc_log.log_error('pc_employer_enroll.set_payment', 'p_routing_number '
                                                           || p_routing_number
                                                           || 'p_bank_acc_num :='
                                                           || p_bank_acc_num);
        if l_source not in ( 'RENEWAL' ) then   -- Added by swamy for Ticket#11364
        -- brought from top to here by swamy for ticket#11364
            select
                count(*)
            into l_count
            from
                compliance_plan_staging
            where
                    entity_id = p_entrp_id
                and batch_number = p_batch_number;

            if l_count = 0 then
                x_error_message := ' No previous data for Compliance Plan';
                raise setup_error;
            end if;
        end if;

        update online_compliance_staging
        set
            bank_name = p_bank_name,
            bank_acc_type = p_bank_acc_type,
            routing_number = p_routing_number,
            bank_acc_num = p_bank_acc_num,
            fees_payment_flag = p_fees_payment_flag,
            salesrep_flag = p_salesrep_flag,
            salesrep_id = p_salesrep_id,
            send_invoice = p_cp_invoice_flag,
            remittance_flag = p_fees_remitance_flag,
            acct_payment_fees = p_acct_payment_fees,
       -- Added by Jaggi #11262
            optional_bank_name = p_optional_bank_name,
            optional_bank_acc_type = p_optional_bank_acc_type,
            optional_routing_number = p_optional_routing_number,
            optional_bank_acc_num = p_optional_bank_acc_num,
            optional_fee_paid_by = p_pay_optional_fees_by,
            optional_fee_payment_method = p_optional_fee_payment_method,
            optional_fee_bank_acct_id = p_optional_fee_bank_acct_id,
            optional_bank_authorize = p_optional_bank_authorize,
            remit_bank_name = p_remit_bank_name,
            remit_bank_acc_type = p_remit_bank_acc_type,
            remit_routing_number = p_remit_routing_number,
            remit_bank_acc_num = p_remit_bank_acc_num,
            remit_bank_authorize = p_remit_bank_authorize,
            bank_authorize = p_bank_authorize,
            annual_fee_bank_created_by =
                case
                    when nvl(p_bank_name, '*') <> nvl(l_bank_name, '*') then
                        pc_users.get_user_type(p_user_id)
                    else
                        annual_fee_bank_created_by
                end,
            optional_fee_bank_created_by =
                case
                    when nvl(p_optional_bank_name, '*') <> nvl(l_optional_bank_name, '*') then
                        pc_users.get_user_type(p_user_id)
                    else
                        optional_fee_bank_created_by
                end,
            bank_acct_id = p_bank_acct_id -- Added by Joshi for 9141
      /*Ticket#5020 */
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        update contact_leads
        set
            send_invoice = p_cp_invoice_flag
        where
                entity_id = pc_entrp.get_tax_id(p_entrp_id)
            and account_type = l_acct_type; -- Replaced 'COBRA' with l_acct_type by swamy  Ticket#6294
    --Validating pages
        update online_compliance_staging
        set
            page3_payment = p_page_validity
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        pc_log.log_error('pc_employer_enroll.set_payment', 'l_entity_type '
                                                           || l_entity_type
                                                           || 'l_acct_type :='
                                                           || l_acct_type);
    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        if
            l_entity_type in ( 'BROKER', 'EMPLOYER' )
            and l_acct_type in ( 'ERISA_WRAP', 'POP' )
        then
            for j in (
                select
                    user_bank_acct_stg_id
                from
                    user_bank_acct_staging
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id
                    and nvl(renewed_by, 'EMPLOYER') = l_entity_type
            ) loop --10747new
                l_user_bank_acct_stg_id := j.user_bank_acct_stg_id;
            end loop;

            pc_log.log_error('pc_employer_enroll.set_payment', ' calling pc_employer_enroll.Upsert_Bank_Info ');
            pc_employer_enroll.upsert_bank_info(
                p_user_bank_acct_stg_id => l_user_bank_acct_stg_id,
                p_entrp_id              => p_entrp_id,
                p_batch_number          => p_batch_number,
                p_account_type          => l_acct_type,
                p_acct_usage            => p_bank_acct_usage,
                p_display_name          => p_bank_name,
                p_bank_acct_type        => p_bank_acc_type,
                p_bank_routing_num      => p_routing_number,
                p_bank_acct_num         => p_bank_acc_num,
                p_bank_name             => p_bank_name,
                p_user_id               => p_user_id,
                p_validity              => nvl(p_page_validity, 'V'),
                p_bank_authorize        => p_bank_authorize,
                p_giac_response         => null,   -- Added by Swamy for Ticket#12309 
                p_giac_verify           => null,   -- Added by Swamy for Ticket#12309 
                p_giac_authenticate     => null,   -- Added by Swamy for Ticket#12309 
                p_bank_acct_verified    => null,   -- Added by Swamy for Ticket#12309 
                p_business_name         => null,   -- Added by Swamy for Ticket#12309 
                p_annual_optional_remit => null,   -- Added by Swamy for Ticket#12534 
                p_existing_bank_flag    => 'N',     -- Added by Swamy for Ticket#12534
                p_bank_acct_id          => null,   -- Added by Swamy for Ticket#12534(12624)
                x_user_bank_acct_stg_id => x_user_bank_acct_stg_id,
                x_bank_status           => x_bank_status,    -- Added by Swamy for Ticket#12534 
                x_error_status          => x_error_status,
                x_error_message         => x_error_message
            );

            if nvl(x_error_status, '*') = 'E' then
                l_page_validity := 'I';
            else
                l_page_validity := nvl(p_page_validity, 'V');
            end if;

            pc_log.log_error('pc_employer_enroll.set_payment', ' calling pc_employer_enroll.upsert_page_validity '
                                                               || ' l_page_validity :='
                                                               || l_page_validity);
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => l_acct_type,
                p_page_no       => '3',
                p_block_name    => 'INVOICING_PAYMENT',
                p_validity      => l_page_validity,
                p_user_id       => p_user_id,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        else  -- End of addition for Ticket#10993(Dev Ticket#10747)

              -- Added by swamy for Ticket#11364
            if
                l_acct_type = 'COBRA'
                and l_source = 'RENEWAL'
            then
                l_page_no := '2';
            else
                l_page_no := '3';
            end if;

 --- 9392 rprabu 08/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => l_acct_type,
                p_page_no       => l_page_no,   -- Replaced '3' with l_page_no by swamy for Ticket#11364
                p_block_name    => 'INVOICING_PAYMENT',
                p_validity      => p_page_validity,
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        end if;  -- Added by Swamy for Ticket#10993(Dev Ticket#10747)

--------- If suppose pay by is changed in invoice section.
        if
            l_acct_type in ( 'POP', 'COBRA', 'ERISA_WRAP' )
            and l_enrolle_type = 'GA'
        then   ---19/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => l_acct_type,
                p_page_no       => 4,
                p_block_name    => 'AUTH_SIGN',
                p_validity      => 'I',
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );
        end if;
        --- END  9392 rprabu 08/10/2020
    -- Commented by swamy and moved to top Ticket#6294
    /*--If user does not craete any contact in UI ,then ww will just update PAGE3_CONTACT as "I" Ticket#5462
    SELECT account_type
    INTO l_acct_type
    FROM ACCOUNT
    where entrp_id = p_entrp_id;
    */
    /* Validate if Broker/GA not defined for send invoice flag as 1 ,then error out */
        if p_cp_invoice_flag = 1 then
            select
                count(*)
            into l_cnt
            from
                contact_leads
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and contact_type in ( 'BROKER', 'GA' );

            if l_cnt = 0 then -- If only broker or GA is not there then we shud invalidate it
                update online_compliance_staging
                set
                    page3_payment = 'I'
                where
                    batch_number = p_batch_number;

            elsif p_page_validity <> 'I' then
        /* If UI has sent validity as 'I' we shud not overwrite it */
                update online_compliance_staging
                set
                    page3_payment = 'V'
                where
                    batch_number = p_batch_number;

            end if;

        end if;                                     --Send Invoice Flag
        if l_acct_type in ( 'POP', 'ERISA_WRAP' ) then -- 'ERISA_WRAP' added by Swamy Ticket#6294
            select
                count(*)
            into l_contact_cnt
            from
                contact_leads
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and l_acct_type = l_acct_type; -- Replaced 'POP' with l_acct_type by Swamy Ticket#6294;
            pc_log.log_error('Set Payment cnt ', l_contact_cnt);
            if l_contact_cnt = 0
            or l_contact_cnt is null then
                pc_log.log_error('Set Payment cnt ', 'Loop');
                update online_compliance_staging
                set
                    page3_contact = 'I'
                where
                        batch_number = p_batch_number
                    and entrp_id = p_entrp_id;

            end if;

        end if;

    exception
        when setup_error then
            x_error_status := 'E';
            pc_log.log_error('set_invoicing_payment', x_error_message);
        when others then
            x_error_status := 'U';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('set_invoicing_payment', sqlerrm);
    end set_payment;
-- Below function added by swamy
-- function to get the contact details for cobra plan invoice information (page 3 in the enrolment)
    function get_cobra_contact_info (
        p_entrp_id     in number,
        p_contact_id   in number,
        p_account_type varchar2
    )   --Ticket 7619 added by rprabu 29/01/2019.)
     return ret_er_invoice_info_t
        pipelined
        deterministic
    is
    -- get the contact details
        cursor cur_contact_info is
        select
            b.contact_id,
            b.first_name,
            b.job_title,
            b.phone_num,
            b.email,
            b.contact_fax,
            b.contact_type
        from
            contact_leads b
        where
                b.entity_id = decode(p_entrp_id,
                                     null,
                                     b.entity_id,
                                     pc_entrp.get_tax_id(p_entrp_id))
            and account_type = p_account_type --- Ticket #7619 done by rprabu on 29/01/2019 fetching Contacts from other accounts of same Enterprise
            and b.contact_id = nvl(p_contact_id, b.contact_id);

        l_record er_invoice_info_t;
    begin
        pc_log.log_error('get_cobra_contact_info begin', 'get_cobra_contact_info');
        for x in cur_contact_info loop
            l_record.contact_id := x.contact_id;
            l_record.contact_name := x.first_name;
            l_record.job_title := x.job_title;
            l_record.phone_num := x.phone_num;
            l_record.email := x.email;
            l_record.contact_fax := x.contact_fax;
            l_record.contact_type := x.contact_type;
            pipe row ( l_record );
        end loop;

        pc_log.log_error('get_cobra_contact_info end', 'get_cobra_contact_info');
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm(sqlcode);
            pc_log.log_error('get_cobra_contact_info others',
                             sqlerrm(sqlcode));
            pipe row ( l_record );
    end get_cobra_contact_info;
-- Below function added by RPRABU FOR 6346
-- function to get the FSA details for  fsa plan invoice information (page 3 in the enrolment)
    function get_fsa_plan_info (
        p_batch_number in number,
        p_entrp_id     in number
    ) return ret_fsa_plan_info_t
        pipelined
        deterministic
    is
    -- get the plan type details
        cursor cur_plan_type_info is
        select
            plan_type,
            plan_error
        from
            online_fsa_hra_plan_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        l_record fsa_plan_info_t;
    begin
        pc_log.log_error('get_FSA_plan_info begin', 'get_FSA_plan_info');
        for x in cur_plan_type_info loop
            l_record.plan_type := x.plan_type;
            l_record.plan_status := x.plan_error;
            pipe row ( l_record );
        end loop;

        pc_log.log_error('get_FSA_plan_info end', 'get_FSA_plan_info');
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm(sqlcode);
            pc_log.log_error('get_FSA_plan_info others',
                             sqlerrm(sqlcode));
            pipe row ( l_record );
    end get_fsa_plan_info;
/*Ticket#5469*/

/* Ticket#5518 */
    procedure create_emp_plan_contacts (
        p_admin_type               varchar2,
        p_plan_admin_name          varchar2,
        p_contact_type             varchar2,
        p_contact_name             varchar,
        p_phone_num                varchar2,
        p_email                    varchar2,
        p_address1                 varchar2,
        p_address2                 varchar2,
        p_city                     varchar2,
        p_state                    varchar2,
        p_zip_code                 varchar,
        p_plan_agent               varchar2,
        p_description              varchar2,
        p_agent_name               varchar2,
        p_legal_agent_contact_type varchar2,
        p_legal_agent_contact      varchar2,
        p_legal_agent_phone        varchar2,
        p_legal_agent_email        varchar2,
        p_trust_fund               varchar2,
        p_trustee_name             varchar2,
        p_trustee_contact_type     varchar2,
        p_trustee_contact_name     varchar2,
        p_trustee_contact_phone    varchar2,
        p_trustee_contact_email    varchar2,
        p_user_id                  number,
        p_entrp_id                 number,
        p_batch_number             number,
        x_error_status             out varchar2,
        x_error_message            out varchar2
    ) is
        l_acc_id number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Create Employer Plan Contacts', 'In Proc');
        insert into plan_employer_contacts (
            record_id,
            entity_id,
            admin_type,
            plan_admin_name,
            contact_type,
            contact_name,
            phone_num,
            email,
            address1,
            address2,
            city,
            state,
            zip_code,
            plan_agent,
            description,
            agent_name,
            legal_agent_contact_type,
            legal_agent_contact,
            legal_agent_phone,
            legal_agent_email,
            trust_fund,
            trustee_name,
            trustee_contact_type,
            trustee_contact_name,
            trustee_contact_phone,
            trustee_contact_email,
            batch_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date
        ) values ( plan_emp_contact_seq.nextval,
                   p_entrp_id,
                   p_admin_type,
                   p_plan_admin_name,
                   p_contact_type,
                   p_contact_name,
                   p_phone_num,
                   p_email,
                   p_address1,
                   p_address2,
                   p_city,
                   p_state,
                   p_zip_code,
                   p_plan_agent,
                   p_description,
                   p_agent_name,
                   p_legal_agent_contact_type,
                   p_legal_agent_contact,
                   p_legal_agent_phone,
                   p_legal_agent_email,
                   p_trust_fund,
                   p_trustee_name,
                   p_trustee_contact_type,
                   p_trustee_contact_name,
                   p_trustee_contact_phone,
                   p_trustee_contact_email,
                   p_batch_number,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   sysdate );

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.Create Employer Plan Contacts', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end create_emp_plan_contacts;
--Ticket#5469.COBRA Reconstruction
    function get_invalid_page (
        p_entrp_id     in number,
        p_batch_number in number
    ) return varchar2 is

        l_page_invalid varchar2(10) := 'V';
        l_plan_valid   varchar2(2);
        l_acct_type    varchar2(10);
    begin
        select
            account_type
        into l_acct_type
        from
            account
        where
            entrp_id = p_entrp_id;

        if l_acct_type = 'COBRA' then
            select
                case
                    when page1_company = 'I' then
                        1
                    when page1_plan = 'I'    then
                        2          ------9429 rprabu 02/12/2020 1 replaced by 2
                    when page2 = 'I'         then
                        2
            /* In COBRA seconds page is eligibility section */
                    when page3_contact = 'I' then
                        3
                    when page3_payment = 'I' then
                        3
                end page_invalid
            into l_page_invalid
            from
                online_compliance_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        elsif l_acct_type = 'POP' then
            select
                case
                    when page1_company = 'I'      then
                        1
                    when page1_plan = 'I'         then
                        1
                    when page2 = 'I'              then
                        1
                    when page1_plan_sponsor = 'I'  --- rprabu 26/03/2020  7946
                     then
                        1
            /* In POP first page is eligibility section */
                    when page3_contact = 'I'      then
                        3
                    when page3_payment = 'I'      then
                        3
                end page_invalid
            into l_page_invalid
            from
                online_compliance_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

        return l_page_invalid;
    end get_invalid_page;
--Ticket#5469
    procedure delete_file (
        p_batch_number  in varchar2,
        p_doc_id        in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
    begin
        delete from file_attachments_staging
        where
                batch_number = p_batch_number
            and attachment_id = p_doc_id;

        x_error_status := 'S';
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.DELETE FILE', 'Error ' || sqlerrm);
    end delete_file;

    procedure upsert_pop_staging (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_state_of_org                in varchar2,
        p_yr_end_date                 in varchar2,
        p_entity_type                 in varchar2,
        p_company_tax                 in varchar2,             -- Added by jaggi ##9604
        p_name                        in varchar2,
        p_affl_flag                   in varchar2,
        p_cntrl_grp_flag              in varchar2,
        p_aff_name                    in varchar2_tbl,
        p_cntrl_grp                   in varchar2_tbl,
        p_user_id                     in number,
        p_page_validity               in varchar2,
        p_source                      in varchar2,             -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_state_main_office           in varchar2,              -- Added for Ticket#11037 by Swamy
        p_state_govern_law            in varchar2,              -- Added for Ticket#11037 by Swamy
        p_affliated_diff_ein          in varchar2,              -- Added for Ticket#11037 by Swamy
        p_type_entity_other           in varchar2,              -- Added for Ticket#11037 by Swamy
        p_affliated_ein               in varchar2_tbl,              -- Start Added for Ticket#11037 by Swamy
        p_affliated_entity_type       in varchar2_tbl,
        p_affliated_entity_type_other in varchar2_tbl,
        p_affliated_address           in varchar2_tbl,
        p_affliated_city              in varchar2_tbl,
        p_affliated_state             in varchar2_tbl,
        p_affliated_zip               in varchar2_tbl,             -- END  of addition for Ticket#11037 by Swamy
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is
        l_header_id    number;
        l_count        number;
        l_source       varchar2(100);
        l_account_type varchar2(50);
    begin
        pc_log.log_error('POP Staging', 'Loop' || p_page_validity);
        l_account_type := pc_account.get_account_type_from_entrp_id(p_entrp_id);
        select
            count(*)
        into l_count
        from
            online_compliance_staging
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        begin
            select
                source
            into l_source
            from
                online_compliance_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

        exception
            when others then
                l_source := null;
        end;
    /* Header Record */
        if l_count = 0 then
      /* new rec */
            insert into online_compliance_staging (
                record_id,
                entrp_id,
                state_of_org,
                fiscal_yr_end,
                type_of_entity,
                company_tax                -- Added by jaggi ##9604
                ,
                entity_name_desc,
                affliated_flag,
                cntrl_grp_flag,
                batch_number,
                source -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                ,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                inactive_plan_flag   -- Added by Joshi for 10430
                ,
                state_main_office              -- Added for Ticket#11037 by Swamy
                ,
                state_govern_law                -- Added for Ticket#11037 by Swamy
                ,
                affliated_diff_ein               -- Added for Ticket#11037 by Swamy
                ,
                type_entity_other              -- Added for Ticket#11037 by Swamy
            ) values ( compliance_staging_seq.nextval,
                       p_entrp_id,
                       p_state_of_org,
                       p_yr_end_date /*Ticket#7135 */,
                       p_entity_type,
                       p_company_tax                -- Added by jaggi ##9604
                       ,
                       p_name,
                       p_affl_flag,
                       p_cntrl_grp_flag,
                       p_batch_number,
                       p_source -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                       ,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate,
                       nvl(
                           pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
                           'N'
                       ),
                       p_state_main_office              -- Added for Ticket#11037 by Swamy
                       ,
                       p_state_govern_law                -- Added for Ticket#11037 by Swamy
                       ,
                       p_affliated_diff_ein              -- Added for Ticket#11037 by Swamy
                       ,
                       p_type_entity_other              -- Added for Ticket#11037 by Swamy
                        );

            pc_log.log_error('POP Staging', 'After Insert..');
        else
      /* Update Record */
            pc_log.log_error('POP Staging', 'Update' || p_entrp_id);
            update online_compliance_staging
            set
                state_of_org = p_state_of_org,
                fiscal_yr_end = p_yr_end_date           /*Ticket#7135 */,
                type_of_entity = p_entity_type,
                company_tax = p_company_tax            -- Added by jaggi ##9604
                ,
                entity_name_desc = p_name,
                affliated_flag = p_affl_flag,
                cntrl_grp_flag = p_cntrl_grp_flag,
                last_updated_by = p_user_id                -- added by swamy erisa  Ticket#6294
                ,
                last_update_date = sysdate                  -- added by swamy erisa  Ticket#6294
                ,
                state_main_office = p_state_main_office              -- Added for Ticket#11037 by Swamy
                ,
                state_govern_law = p_state_govern_law                -- Added for Ticket#11037 by Swamy
                ,
                affliated_diff_ein = p_affliated_diff_ein              -- Added for Ticket#11037 by Swamy
                ,
                type_entity_other = p_type_entity_other              -- Added for Ticket#11037 by Swamy
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;
    /* Insert update loop */
    /* Affliated Employers */
        if l_source = 'RENEWAL' then
            delete from enterprise_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and entity_type = 'BEN_PLAN_RENEWALS';

            if l_account_type = 'POP' then
                for i in 1..p_aff_name.count loop
                    if p_aff_name(i) is not null then
                        insert into enterprise_staging (
                            entrp_stg_id,
                            entrp_id,
                            en_code,
                            name,
                            batch_number,
                            entity_type,
                            created_by,
                            creation_date,
                            affliated_ein,              -- Start Added for Ticket#11037 by Swamy
                            affliated_entity_type,
                            affliated_entity_type_other,
                            affliated_address,
                            affliated_city,
                            affliated_state,
                            affliated_zip             -- END  of addition for Ticket#11037 by Swamy
                        ) values ( entrp_staging_seq.nextval,
                                   p_entrp_id,
                                   10,-- Affliated ER
                                   p_aff_name(i),
                                   p_batch_number,
                                   'BEN_PLAN_RENEWALS',
                                   p_user_id,
                                   sysdate,
                                   p_affliated_ein(i),              -- Start Added for Ticket#11037 by Swamy
                                   p_affliated_entity_type(i),
                                   p_affliated_entity_type_other(i),
                                   p_affliated_address(i),
                                   p_affliated_city(i),
                                   p_affliated_state(i),
                                   p_affliated_zip(i)             -- END  of addition for Ticket#11037 by Swamy
                                    );

                    end if;
                end loop;

            else
                for i in 1..p_aff_name.count loop
                    if p_aff_name(i) is not null then
                        insert into enterprise_staging (
                            entrp_stg_id,
                            entrp_id,
                            en_code,
                            name,
                            batch_number,
                            entity_type,
                            created_by,
                            creation_date
                        ) values ( entrp_staging_seq.nextval,
                                   p_entrp_id,
                                   10,-- Affliated ER
                                   p_aff_name(i),
                                   p_batch_number,
                                   'BEN_PLAN_RENEWALS',
                                   p_user_id,
                                   sysdate );

                    end if;
                end loop;
            end if;
      /**Control grp **/
            for i in 1..p_cntrl_grp.count loop
                if p_cntrl_grp(i) is not null then -- Added by Swamy wrt Ticket#6559
                    insert into enterprise_staging (
                        entrp_stg_id,
                        entrp_id,
                        en_code,
                        name,
                        batch_number,
                        entity_type,
                        created_by,
                        creation_date
                    ) values ( entrp_staging_seq.nextval,
                               p_entrp_id,
                               11,-- Controlled Grp
                               p_cntrl_grp(i),
                               p_batch_number,
                               'BEN_PLAN_RENEWALS',
                               p_user_id,
                               sysdate );

                end if; -- Added by Swamy wrt Ticket#6559
            end loop;

        else
      /*Enrollment loop */
            delete from enterprise_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
                and entity_type = 'ONLINE_ENROLLMENT';

            if l_account_type = 'POP' then
                for i in 1..p_aff_name.count loop
        --IF p_aff_name(i) IS NOT NULL THEN
                    if nvl(
                        p_aff_name(i),
                        '*'
                    ) <> '*' then -- Commented above and added by swamy Ticket#6294
                        insert into enterprise_staging (
                            entrp_stg_id,
                            entrp_id,
                            en_code,
                            name,
                            batch_number,
                            entity_type,
                            created_by,
                            creation_date,
                            affliated_ein,              -- Start Added for Ticket#11037 by Swamy
                            affliated_entity_type,
                            affliated_entity_type_other,
                            affliated_address,
                            affliated_city,
                            affliated_state,
                            affliated_zip             -- END  of addition for Ticket#11037 by Swamy
                        ) values ( entrp_staging_seq.nextval,
                                   p_entrp_id,
                                   10,-- Affliated ER
                                   p_aff_name(i),
                                   p_batch_number,
                                   'ONLINE_ENROLLMENT',
                                   p_user_id,
                                   sysdate,
                                   p_affliated_ein(i),              -- Start Added for Ticket#11037 by Swamy
                                   p_affliated_entity_type(i),
                                   p_affliated_entity_type_other(i),
                                   p_affliated_address(i),
                                   p_affliated_city(i),
                                   p_affliated_state(i),
                                   p_affliated_zip(i)             -- END  of addition for Ticket#11037 by Swamy
                                    );

                    end if;
                end loop;

            else
                for i in 1..p_aff_name.count loop
        --IF p_aff_name(i) IS NOT NULL THEN
                    if nvl(
                        p_aff_name(i),
                        '*'
                    ) <> '*' then -- Commented above and added by swamy Ticket#6294
                        insert into enterprise_staging (
                            entrp_stg_id,
                            entrp_id,
                            en_code,
                            name,
                            batch_number,
                            entity_type,
                            created_by,
                            creation_date
                        ) values ( entrp_staging_seq.nextval,
                                   p_entrp_id,
                                   10,-- Affliated ER
                                   p_aff_name(i),
                                   p_batch_number,
                                   'ONLINE_ENROLLMENT',
                                   p_user_id,
                                   sysdate );

                    end if;
                end loop;
            end if;
      /**Control Group **/
            for i in 1..p_cntrl_grp.count loop
                if nvl(
                    p_cntrl_grp(i),
                    '*'
                ) <> '*' then -- added by swamy Ticket#6294
                    insert into enterprise_staging (
                        entrp_stg_id,
                        entrp_id,
                        en_code,
                        name,
                        batch_number,
                        entity_type,
                        created_by,
                        creation_date
                    ) values ( entrp_staging_seq.nextval,
                               p_entrp_id,
                               11,-- Controlled Grp
                               p_cntrl_grp(i),
                               p_batch_number,
                               'ONLINE_ENROLLMENT',
                               p_user_id,
                               sysdate );

                end if;
            end loop;

        end if;
    /*renewal enrollment If */
    --Validating pages
        update online_compliance_staging
        set
            page1_company = p_page_validity
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

 --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'POP',
            p_page_no       => '1',
            p_block_name    => 'COMPANY_INFORMATION',  -- 8014 rprabu 12/08/2019
            p_validity      => p_page_validity,
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_POP_staging', sqlerrm);
    end upsert_pop_staging;
/*Ticket#5862 */
    procedure create_pop_plan_staging (
        p_entrp_id               in number,
        p_plan_name              in varchar2,
        p_plan_number            in varchar2,
        p_plan_type              in varchar2,
        p_take_over_flag         in varchar2,
        p_short_plan_yr_flag     in varchar2,
        p_plan_start_date        in varchar2,
        p_plan_end_date          in varchar2,
        p_org_eff_date           in varchar2,
        p_eff_date               in varchar2,
        p_eff_date_sterling      in varchar2,
        p_tot_no_ees             in number,
        p_tot_eligib_ees         in varchar2,
        p_ga_flag                in varchar2,
        p_ga_id                  in varchar2,
        p_user_id                in number,
        p_page_validity          in varchar2,
        p_batch_number           in number,
        p_tot_cost               in number,
        p_plan_id                in number default null,
        p_flg_plan_name          in varchar2 default 'N', -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_wrap_opt_flg           in varchar2 default 'N', -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_plan_doc_ndt_flag      in varchar2,  --- Added by rprabu Ticket #7832
        p_short_plan_yr_end_date in varchar2, -- Added by Joshi for 12135.
        x_er_ben_plan_id         out number,
        x_error_status           out varchar2,
        x_error_message          out varchar2
    ) is
        l_count   number;
        l_plan_id number; --- Ticket #9121 rprabu 26/05/2020
    begin
        pc_log.log_error('create_POP_plan_staging', 'Loop' || p_plan_id);

           --- Ticket #9121 rprabu 26/05/2020
        begin
            select
                plan_id
            into l_plan_id
            from
                compliance_plan_staging
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id;

        exception
            when others then
                null;
        end;

        if
            p_plan_id is null
            and l_plan_id is null
        then --- l_plan_id added for  Ticket #9121 rprabu 26/05/2020
      /* Insert */
            pc_log.log_error('create_POP_plan_staging..Count', l_count);
            insert into compliance_plan_staging (
                plan_id,
                entity_id,
                plan_name,
                plan_type,
                plan_number,
                plan_start_date,
                plan_end_date,
                ga_flag,
                ga_id,
                takeover_flag,
                short_plan_yr_flag,
                batch_number,
                flg_plan_name, -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                wrap_opt_flg,  -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                plan_doc_ndt_flag,   --- Added by rprabu Ticket #7832
                short_plan_yr_end_date,   -- Added by Joshi for 12135.
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( compliance_plan_seq.nextval,
                       p_entrp_id,
                       p_plan_name,
                       p_plan_type,
                       p_plan_number,
                       p_plan_start_date,/*Ticket#7135 */
          -- p_plan_start_date,
          --  p_plan_end_date,
                       p_plan_end_date,/*Ticket#7135 */
                       p_ga_flag,
                       p_ga_id,
                       p_take_over_flag,
                       p_short_plan_yr_flag,
                       p_batch_number,
                       p_flg_plan_name, -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                       p_wrap_opt_flg,  -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                       p_plan_doc_ndt_flag,   --- Added by rprabu Ticket #7832
                       p_short_plan_yr_end_date,   -- Added by Joshi for 12135.
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate ) returning plan_id into x_er_ben_plan_id;

        else
      /* Update */
            pc_log.log_error('create_POP_plan_staging..Update', p_plan_start_date);
            update compliance_plan_staging
            set
                plan_name = p_plan_name,
                plan_number = p_plan_number,
                plan_type = p_plan_type,
                ga_id = p_ga_id,
                ga_flag = p_ga_flag,
                plan_start_date = p_plan_start_date,/*Ticket#7135 */
                plan_end_date = p_plan_end_date,/*Ticket#7135 */
                takeover_flag = p_take_over_flag,
                short_plan_yr_flag = p_short_plan_yr_flag,
                flg_plan_name = p_flg_plan_name, -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                wrap_opt_flg = p_wrap_opt_flg,  -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                plan_doc_ndt_flag = p_plan_doc_ndt_flag, --- Added by rprabu Ticket #7832
                short_plan_yr_end_date = p_short_plan_yr_end_date, -- Added by Joshi for 12135.
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
                and plan_id = p_plan_id;

            x_er_ben_plan_id := p_plan_id;
            pc_log.log_error('create_POP_plan_staging..After Update', p_plan_start_date);
        end if;
    /* Insert/Update loop */
        pc_log.log_error('create_POP_plan_staging', 'After Insert');
    --Validating page# 2
        update online_compliance_staging
        set
            no_off_ees = p_tot_no_ees,
            no_of_eligible = p_tot_eligib_ees,
            org_eff_date = p_org_eff_date,
            eff_date_sterling = p_eff_date_sterling,
            effective_date = p_eff_date,
            page1_plan = p_page_validity,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;
            --- Added by rprabu for validations based on   page_validity table 9392 ticket implemention 12/10/2020
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'POP',
            p_page_no       => 2,
            p_block_name    => 'PLAN_INFORMATION',
            p_validity      => p_page_validity,
            p_user_id       => p_user_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        delete from ar_quote_headers_staging
        where
            entrp_id = p_entrp_id;

        insert into ar_quote_headers_staging (
            quote_header_id,
            total_quote_price,
            entrp_id,
            batch_number,
            account_type,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date
        ) values ( compliance_quote_seq.nextval,
                   p_tot_cost,
                   p_entrp_id,
                   p_batch_number,
                   p_plan_type,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   sysdate );

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.create_POP_plan_staging', sqlerrm);
    end create_pop_plan_staging;
/* Ticket 5862 */

    procedure validate_contact (
        p_contact_id   in number,
        p_entrp_id     in number,
        p_batch_number in number,
        p_account_type in varchar2 default null,
        p_source       in varchar2 default null    -- Added by Swamy for Ticket#9324 on 16/07/2020
    ) is

        l_cnt           number := 0;
        l_cnt_broker    number := 0;
        l_page_no       number := 0; -- 6346 rprabu FSA   Ticket #6909
        l_contact_type  varchar2(100);
        l_flag          varchar2(2);
        l_enrolle_type  account.enrolle_type%type;  --------------rprabu 9141 19/08/2020
        l_page3_payment varchar2(1);
        l_page3_contact varchar2(1);
        x_error_status  varchar2(100);
        x_error_message varchar2(100);
    begin
                --------------------rprabu 9141 19/08/2020
        begin
            select
                nvl(enrolle_type, 'EMPLOYER')
            into l_enrolle_type
            from
                account
            where
                entrp_id = p_entrp_id;

        exception
            when others then
                null;
        end;

        pc_log.log_error('In Validate', p_contact_id);
        begin
            select
                count(*)
            into l_cnt
            from
                contact_leads
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and account_type = p_account_type    --- Ticket #7572 added by rprabu 21/01/2019
                and contact_type = 'PRIMARY';

        exception
            when no_data_found then
                null;
        end;

            --added by Jaggi #9734
        if
            p_account_type in ( 'COBRA', 'POP', 'ERISA_WRAP' )
            and l_enrolle_type = 'GA'
        then
            begin
                select
                    count(*)
                into l_cnt_broker
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = p_account_type
                    and contact_type = 'BROKER';

            exception
                when no_data_found then
                    null;
            end;
        else
               	--- To find  contacts of broker or GA
            begin
                select
                    count(*)
                into l_cnt_broker
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = p_account_type    --- Ticket #7572 added by rprabu 21/01/2019
                    and contact_type in ( 'BROKER', 'GA' );

            exception
                when no_data_found then
                    null;
            end;
        end if;
            -- END HERE --

        pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT..', l_cnt);

    --- FSA / HRA Coding for 6346 on 30/08/2018 added by rprabu
	--- ERISA_WRAP added rprabu for 12/06/2019 7691
        if p_account_type in ( 'FSA', 'HRA', 'FORM_5500', 'ERISA_WRAP' ) then ---- FSA and HRA plans
      --- Added for  the Ticket #6909
            if p_account_type = 'FSA' then
                l_page_no := 3;
            elsif p_account_type = 'HRA' then
                l_page_no := 4;
	    --- 7015 FORM_5500 DONE BY RPRABU -- ERISA_WRAP 7691   DONE BY RPRABU
            elsif p_account_type in ( 'FORM_5500', 'ERISA_WRAP' ) then
                l_page_no := 2;
            end if;
      --- contacts page checking for primary contact
            if
                l_cnt = 0
                and upper(p_source) = 'ENROLLMENT'
            then     -- And p_source Added by Swamy for Ticket#9324 on 16/07/2020
                l_page3_contact := 'I';
            elsif
                l_cnt_broker = 0
                and l_enrolle_type = 'GA'
                and upper(p_source) = 'ENROLLMENT'
            then   -- Added p_source condition for Ticket#12653 by Swamy --added by Jaggi #9734
                l_page3_contact := 'I';
            else
                l_page3_contact := 'V';
            end if;

            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => p_account_type,
                p_page_no       => l_page_no,
                p_block_name    => 'CONTACT_INFORMATION',
                p_validity      => l_page3_contact,
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            l_page3_payment := 'V'; --   Ticket #7587
            if p_account_type = 'FORM_5500' then   --- Ticket #7595 if  added by rprabu on 30/01/2019
                for x in (
                    select
                        nvl(send_invoice, 0) send_invoice
                    from
                        online_form_5500_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_number
                ) loop
                    pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT..', x.send_invoice);
                    if
                        x.send_invoice in ( '1', 'Y' )
                        and l_cnt_broker = 0
                    then
                        l_page3_payment := 'I';
                        pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT..', x.send_invoice);
                    elsif
                        x.send_invoice in ( '1', 'Y' )
                        and l_cnt_broker > 0
                    then
                        l_page3_payment := 'V';
                    elsif x.send_invoice in ( '0', 'N' ) then
                        l_page3_payment := 'V';
                    end if;

                end loop;
            elsif p_account_type = 'ERISA_WRAP' then   --- Ticket #7914 ElsIf  added by rprabu on 24/06/2019
                for y in (
                    select
                        page3_payment
                    from
                        online_compliance_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                ) loop
                    l_page3_payment := y.page3_payment;
                end loop;
            else               ---- For FSA and HRA plans
                for i in (
                    select
                        count(entity_id) count_rec
                    from
                        contact_leads
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and account_type = p_account_type
                        and send_invoice in ( '1', 'Y' )     --- 'Y' Ticket #7572 added by rprabu 21/01/2019
                ) loop
                    pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT 280119 i.count_rec : ..', i.count_rec);
                    pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT 280119 : i.l_cnt_broker : ..', l_cnt_broker);
                    --- checking for  existance of  BROKER or GA, GA ticket 6346 added by rprabu
                    if i.count_rec = 0 then
                        l_page3_payment := 'V';
                        pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT 280119  1: ..', l_page3_payment);
                    elsif
                        l_cnt_broker = 0
                        and i.count_rec > 0
                    then
                        l_page3_payment := 'I';
                        pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT 280119  2: ..', l_page3_payment);
                    elsif
                        l_cnt_broker > 0
                        and i.count_rec > 0
                    then
                        l_page3_payment := 'V';
                        pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT 280119   3: ..', l_page3_payment);
                    end if;

                end loop;
            end if;    --- Ticket #7595 if  added by rprabu on 30/01/2019
          --- Added for  the Ticket #6909
            if p_account_type = 'FSA' then
                l_page_no := 3;
            elsif p_account_type = 'HRA' then
                l_page_no := 4;
            elsif p_account_type = 'FORM_5500' then
                l_page_no := 2;
            end if;

            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => p_account_type,
                p_page_no       => l_page_no,
                p_block_name    => 'INVOICING_PAYMENT',
                p_validity      => l_page3_payment,
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            pc_log.log_error('PC_EMPLOYER_ENROLL.validate 30/01 l_page3_payment..', l_page3_payment);
            pc_log.log_error('PC_EMPLOYER_ENROLL.validate 30/01 p_account_type..', p_account_type);
        else              ----other then FSA and HRA plans

		--- 9392 rprabu 08/10/2020  Arrow Functionality
            if p_account_type = 'POP' then
                l_page_no := 2;
            elsif p_account_type = 'COBRA' then
                l_page_no := 3;
            end if;

            if l_cnt = 0 then -- If no primary contact then we should update teh page Invalid bcoz noprimary contact.
                if ( p_account_type <> 'COBRA' )
                or (
                    p_account_type = 'COBRA'
                    and upper(p_source) <> 'RENEWAL'
                ) then  -- Added for Prod Ticket#11612 by Swamy
                    pc_log.log_error('PC_EMPLOYER_ENROLL.validate CONTACT..', 'Updating Contact');
                    update online_compliance_staging
                    set
                        page3_contact = 'I'
                    where
                        entrp_id = p_entrp_id;
      --- 9392 rprabu 08/10/2020  Arrow Functionality
                    pc_employer_enroll.upsert_page_validity(
                        p_batch_number  => p_batch_number,
                        p_entrp_id      => p_entrp_id,
                        p_account_type  => p_account_type,
                        p_page_no       => l_page_no,
                        p_block_name    => 'CONTACT_INFORMATION',
                        p_validity      => 'I',
                        p_user_id       => null,
                        x_error_status  => x_error_status,
                        x_error_message => x_error_message
                    );
                    ---END  9392 rprabu 07/10/2020
                end if;

            else
                update online_compliance_staging
                set
                    page3_contact = 'V'
                where
                    entrp_id = p_entrp_id;
  --- 9392 rprabu 08/10/2020  Arrow Functionality

                pc_employer_enroll.upsert_page_validity(
                    p_batch_number  => p_batch_number,
                    p_entrp_id      => p_entrp_id,
                    p_account_type  => p_account_type,
                    p_page_no       => l_page_no,
                    p_block_name    => 'CONTACT_INFORMATION',
                    p_validity      => 'V',
                    p_user_id       => null,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );

            end if;				---Primary Conatct loop
  ------------- pop and cobra added for 06/10/2020 9392 -------------
            if p_account_type in ( 'COBRA', 'POP' ) then
                l_page3_payment := 'V';
                if p_account_type = 'COBRA' then
                    l_page_no := 3;
                elsif p_account_type = 'POP' then
                    l_page_no := 2;
                end if;

                for y in (
                    select
                        page3_payment
                    from
                        online_compliance_staging
                    where
                            batch_number = p_batch_number
                        and entrp_id = p_entrp_id
                ) loop
                    l_page3_payment := nvl(y.page3_payment, 'I');
                end loop;

                pc_employer_enroll.upsert_page_validity(
                    p_batch_number  => p_batch_number,
                    p_entrp_id      => p_entrp_id,
                    p_account_type  => p_account_type,
                    p_page_no       => l_page_no,
                    p_block_name    => 'INVOICING_PAYMENT',
                    p_validity      => l_page3_payment,
                    p_user_id       => null,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );

            end if;
------------END  pop and cobra added for 06/10/2020 9392  --------------------
      -- Added by Joshi for 8471. For COBRA Broker contact is mandatory.
	   ----- l_enrolle_type  added by rprabu 9141 19/08/2020
--      IF P_ACCOUNT_TYPE = 'COBRA' And l_enrolle_type='EMPLOYER'   THEN

         -- Added by Joshi for 9009. checking primary also.
         --      Added by Jaggi for 9734 Mandatory Broker Contact On GA Applications
            if (
                p_account_type = 'COBRA'
                and l_enrolle_type = 'EMPLOYER'
            )
            or (
                p_account_type in ( 'COBRA', 'POP', 'ERISA_WRAP' )
                and l_enrolle_type = 'GA'
            ) then
                if (
                    l_cnt_broker > 0
                    and l_cnt > 0
                ) then
                    update online_compliance_staging
                    set
                        page3_contact = 'V'
                    where
                        entrp_id = p_entrp_id;

                else
                    update online_compliance_staging
                    set
                        page3_contact = 'I'
                    where
                        entrp_id = p_entrp_id;

                end if;
            end if;
      -- Added by Joshi for 8471
            begin
                select
                    send_invoice
                into l_flag
                from
                    online_compliance_staging
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number;  -- Added by Swamy for Ticket#8684 in order to avoid ORA-01422: exact fetch returns more than requested number of rows

            exception
                when no_data_found then  --- Exception added for Ticket No #7315 by rprabu
                    null;
            end;

            pc_log.log_error('PC_EMPLOYER_ENROLL.validate Invoice..', l_flag);
            if l_flag = '1' then
        -- this select moved to above code sharing for fsa also.  done by rprabu 6346
        /* SELECT count(*)
        INTO l_cnt
        FROM CONTACT_LEADS
        WHERE  entity_id = PC_ENTRP.GET_TAX_ID(P_ENTRP_ID)
        AND contact_type in ( 'BROKER','GA'); */
	---9392 rprabu 06/10/2020
                if p_account_type = 'COBRA' then
                    l_page_no := 3;
                elsif p_account_type = 'POP' then
                    l_page_no := 2;
                end if;

                if l_cnt_broker = 0 then -- l_cnt replaced  by l_cnt_broker
		--- 9392 rprabu 08/10/2020  Arrow Functionality
                    if p_account_type in ( 'COBRA', 'POP' ) then
                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => p_account_type,
                            p_page_no       => l_page_no,
                            p_block_name    => 'INVOICING_PAYMENT',
                            p_validity      => 'I',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );
                    end if;							      --- END 9392 rprabu 08/10/2020  Arrow Functionality
                    update online_compliance_staging
                    set
                        page3_payment = 'I'
                    where
                        entrp_id = p_entrp_id;

                else
 --- added by rprabu for validations based on   page_validity table 9392 ticket implemention
                    if p_account_type in ( 'COBRA', 'POP' ) then
                        pc_employer_enroll.upsert_page_validity(
                            p_batch_number  => p_batch_number,
                            p_entrp_id      => p_entrp_id,
                            p_account_type  => p_account_type,
                            p_page_no       => l_page_no,
                            p_block_name    => 'INVOICING_PAYMENT',
                            p_validity      => 'V',
                            p_user_id       => null,
                            x_error_status  => x_error_status,
                            x_error_message => x_error_message
                        );
                    end if;				      --- END 9392 rprabu 08/10/2020  Arrow Functionality
                    update online_compliance_staging
                    set
                        page3_payment = 'V'
                    where
                        entrp_id = p_entrp_id;

                end if;

            end if;

        end if;

    end validate_contact;

/* Ticket#5020 */
    procedure create_emp_plan_contacts_stage (
        p_admin_type               varchar2,
        p_plan_admin_name          varchar2,
        p_contact_type             varchar2,
        p_contact_name             varchar,
        p_phone_num                varchar2,
        p_email                    varchar2,
        p_address1                 varchar2,
        p_address2                 varchar2,
        p_city                     varchar2,
        p_state                    varchar2,
        p_governing_state          varchar2, -- 7832 Rprabu 29/05/2019
        p_zip_code                 varchar,
        p_plan_agent               varchar2,
        p_description              varchar2,
        p_agent_name               varchar2,
        p_legal_agent_contact_type varchar2,
        p_legal_agent_contact      varchar2,
        p_legal_agent_phone        varchar2,
        p_legal_agent_email        varchar2,
        p_trust_fund               varchar2,
        p_trustee_name             varchar2,
        p_trustee_contact_type     varchar2,
        p_trustee_contact_name     varchar2,
        p_trustee_contact_phone    varchar2,
        p_trustee_contact_email    varchar2,
        p_user_id                  number,
        p_entrp_id                 number,
        p_batch_number             number,
        p_page_validity            in varchar2, -- rprabu 7946 26/03/2020
        x_error_status             out varchar2,
        x_error_message            out varchar2
    ) is
        l_acc_id number;
        l_cnt    number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Create Employer Plan Contacts Staging', 'In Proc');
        pc_log.log_error('PC_EMPLOYER_ENROLL.Create Employer Plan Contacts Staging P_page_validity : ', p_page_validity
                                                                                                        || 'p_entrp_id :='
                                                                                                        || p_entrp_id
                                                                                                        || ' p_batch_number :='
                                                                                                        || p_batch_number);
 --- ticket # 7946 26/03/2020
        update online_compliance_staging
        set
            page1_plan_sponsor = p_page_validity
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

    --- 9392 rprabu 08/10/2020  Arrow Functionality
        pc_employer_enroll.upsert_page_validity(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_account_type  => 'POP',
            p_page_no       => '1',
            p_block_name    => 'PLAN_SPONSOR',
            p_validity      => p_page_validity,
            p_user_id       => null,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        select
            count(*)
        into l_cnt
        from
            plan_employer_contacts_stage
        where
                entity_id = p_entrp_id
            and batch_number = p_batch_number;

        if l_cnt = 0 then
            pc_log.log_error('PC_EMPLOYER_ENROLL.Create Employer Plan Contacts Staging insert : ', p_page_validity
                                                                                                   || 'p_entrp_id :='
                                                                                                   || p_entrp_id
                                                                                                   || ' p_batch_number :='
                                                                                                   || p_batch_number);

            insert into plan_employer_contacts_stage (
                record_id,
                entity_id,
                admin_type,
                plan_admin_name,
                contact_type,
                contact_name,
                phone_num,
                email,
                address1,
                address2,
                city,
                state,
                governing_state, --- 7832 rprabu 29/05/2019
                zip_code,
                plan_agent,
                description,
                agent_name,
                legal_agent_contact_type,
                legal_agent_contact,
                legal_agent_phone,
                legal_agent_email,
                trust_fund,
                trustee_name,
                trustee_contact_type,
                trustee_contact_name,
                trustee_contact_phone,
                trustee_contact_email,
                batch_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( plan_emp_contact_seq.nextval,
                       p_entrp_id,
                       p_admin_type,
                       p_plan_admin_name,
                       p_contact_type,
                       p_contact_name,
                       p_phone_num,
                       p_email,
                       p_address1,
                       p_address2,
                       p_city,
                       p_state,
                       p_governing_state,  --- 7832 Rprabu 29/05/2019
                       p_zip_code,
                       p_plan_agent,
                       p_description,
                       p_agent_name,
                       p_legal_agent_contact_type,
                       p_legal_agent_contact,
                       p_legal_agent_phone,
                       p_legal_agent_email,
                       p_trust_fund,
                       p_trustee_name,
                       p_trustee_contact_type,
                       p_trustee_contact_name,
                       p_trustee_contact_phone,
                       p_trustee_contact_email,
                       p_batch_number,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

        else -- Update
            pc_log.log_error('PC_EMPLOYER_ENROLL.Create Employer Plan Contacts Staging update : ', p_page_validity
                                                                                                   || 'p_entrp_id :='
                                                                                                   || p_entrp_id
                                                                                                   || ' p_batch_number :='
                                                                                                   || p_batch_number);

            update plan_employer_contacts_stage
            set
                admin_type = p_admin_type,
                city = p_city,
                state = p_state,
                governing_state = p_governing_state,  --- 7832 Added By RPRABU 29/05/2019
                zip_code = p_zip_code,
                plan_admin_name = p_plan_admin_name,
                contact_type = p_contact_type,
                contact_name = p_contact_name,
                phone_num = p_phone_num,
                email = p_email,
                address1 = p_address1,
                address2 = p_address2,
                plan_agent = p_plan_agent, -- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
                description = p_description,
                agent_name = p_agent_name,
                legal_agent_contact_type = p_legal_agent_contact_type,
                legal_agent_contact = p_legal_agent_contact,
                legal_agent_phone = p_legal_agent_phone,
                legal_agent_email = p_legal_agent_email,
                trust_fund = p_trust_fund,
                trustee_name = p_trustee_name,
                trustee_contact_type = p_trustee_contact_type,
                trustee_contact_name = p_trustee_contact_name,
                trustee_contact_phone = p_trustee_contact_phone,
                trustee_contact_email = p_trustee_contact_email,
                last_updated_by = p_user_id,
                last_update_date = sysdate -- End Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
            where
                    entity_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.Create Employer Plan Contacts Stage', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end create_emp_plan_contacts_stage;
/**********************ERISA Online Enrollment*******************************/
-- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
    function get_plan_details (
        p_entity_id    in number,
        p_batch_number in number,
        p_flg_block    in varchar2
    ) return tbl_ben_codes
        pipelined
    is
        rec rec_ben_codes;
    begin
        pc_log.log_error('Pc_Employer_Enroll.Get_Plan_Details', p_entity_id);
        if
            p_batch_number is not null
            and p_entity_id is not null
        then
      --Lookup_name = 'BEN_PLAN_ENROLLMENT_SETUP' for Welfare Benefit Plan Chart Appendix
      --Lookup_name = 'SUBSIDIARY_CONTRACTS' for Welfare Benefit Plans(options 1 2 and 3)
            for i in (
                select
                    a.benefit_code_id,
                    a.benefit_code_name,
                    b.meaning,
                    a.description,
                    a.eligibility,
                    a.er_cont_pref,
                    a.ee_cont_pref,
                    a.er_ee_contrib_lng,
                    a.refer_to_doc,
                    a.eligibility_refer_to_doc, -- added by Joshi for 7791
                    a.voluntary_life_add_info  -- added by jaggi for 9199
                from
                    benefit_codes_stage a,
                    lookups             b
                where
                        benefit_code_name = lookup_code (+)
                    and entity_id = p_entity_id
                    and b.lookup_name in ( 'CLAIM_LNG_OPTIONS', 'SUBSIDIARY_CONTRACTS' )
                    and a.batch_number = p_batch_number
                    and flg_block = p_flg_block
            ) loop
                rec.benefit_code_id := i.benefit_code_id;
                rec.benefit_code_name := i.benefit_code_name;
                rec.meaning := nvl(i.description, i.meaning);
                rec.eligibility := i.eligibility;
                rec.er_cont_pref := i.er_cont_pref;
                rec.ee_cont_pref := i.ee_cont_pref;
                rec.er_ee_contrib_lng := i.er_ee_contrib_lng;
                rec.refer_to_doc := i.refer_to_doc;
                rec.eligibility_refer_to_doc := i.eligibility_refer_to_doc;
                rec.voluntary_life_add_info := i.voluntary_life_add_info;
                pipe row ( rec );
            end loop;

        end if;

    exception
        when others then
            pc_log.log_error('Pc_Employer_Enroll.Get_Plan_Details', sqlerrm);
    end get_plan_details;

    procedure insert_erisa_eligib_req (
        p_entity_id               in number,
        p_user_id                 in number,
        p_benefit_code_name       in varchar2_tbl,
        p_others_name             in varchar2_tbl,
        p_batch_number            in number,
        p_entity_type             in varchar2,
        p_eligibility             in varchar2_tbl,
        p_er_ee_cont_pref         in varchar2_tbl,
        p_employer_amount         in varchar2_tbl,
        p_employee_amount         in varchar2_tbl,
        p_external_doc            in varchar2_tbl,
        p_eligibility_refer_doc   in varchar2_tbl,  -- added by Josi for 7791.
        p_voluntary_life_add_info in varchar2,   -- added by jaggi for 9199.
        p_flg_block               in varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is

        v_er_cont_pref          lookups.description%type;
        v_ee_cont_pref          lookups.description%type;
        v_er_amount             number;
        v_ee_amount             number;
        v_flg_num               varchar2(1) := 'N';
        v_eligibility           benefit_codes_stage.eligibility%type;
        v_er_ee_cont_lng        benefit_codes_stage.er_ee_contrib_lng%type;
        v_external_doc          benefit_codes_stage.refer_to_doc%type;
        v_desc                  benefit_codes_stage.description%type;
        v_entity_type           varchar2(100) := 'BEN_PLAN_ENROLLMENT_SETUP';
        v_eligibility_refer_doc benefit_codes_stage.refer_to_doc%type;
    begin
        pc_log.log_error('Test', p_entity_id);
        x_error_status := 'S';
        delete from benefit_codes_stage
        where
                entity_id = p_entity_id
            and batch_number = p_batch_number
            and flg_block = p_flg_block;

        if p_flg_block = '2' then
            v_entity_type := 'SUBSIDIARY_CONTRACT';
        end if;
        for i in 1..p_benefit_code_name.count loop
            v_er_cont_pref := null;
            v_ee_cont_pref := null;
            v_er_amount := null;
            v_ee_amount := null;
            v_flg_num := 'N';
            v_eligibility := null;
            v_er_ee_cont_lng := null;
            v_external_doc := null;
            v_eligibility_refer_doc := null;
            if p_benefit_code_name(i) is not null then
                if p_employer_amount.exists(i) then
                    v_flg_num := is_number(p_employer_amount(i));
                    if v_flg_num = 'Y' then
                        v_er_amount := to_number ( p_employer_amount(i) );
                    end if;

                    v_flg_num := 'N';
                end if;

                if p_employee_amount.exists(i) then
                    v_flg_num := is_number(p_employee_amount(i));
                    if v_flg_num = 'Y' then
                        v_ee_amount := to_number ( p_employee_amount(i) );
                    end if;

                    v_flg_num := 'N';
                end if;

                if p_eligibility.exists(i) then
                    v_eligibility := p_eligibility(i);
                end if;

                if p_er_ee_cont_pref.exists(i) then
                    v_er_ee_cont_lng := p_er_ee_cont_pref(i);
                end if;

                if p_external_doc.exists(i) then
                    v_external_doc := p_external_doc(i);
                end if;
         -- Added by Joshi for 7791

                if p_eligibility_refer_doc.exists(i) then
                    v_eligibility_refer_doc := p_eligibility_refer_doc(i);
                end if;
        -- code ends here 7791

                if upper(p_benefit_code_name(i)) = 'OTHER' then
                    if p_others_name.exists(i) then
                        v_desc := p_others_name(i);
                        if nvl(v_desc, '*') = '*' then
                            continue;
                        end if;
                    end if;
                else
                    for n in (
                        select
                            description
                        from
                            lookups
                        where
                                lookup_code = p_benefit_code_name(i)
                            and lookup_name in ( 'SUBSIDIARY_CONTRACTS', 'CLAIM_LNG_OPTIONS' )
                    ) loop
                        v_desc := n.description;
                    end loop;
                end if;

                insert into benefit_codes_stage (
                    entity_id,
                    entity_type,
                    seq_id,
                    benefit_code_name,
                    description,
                    batch_number,
                    eligibility,
                    er_ee_contrib_lng,
                    er_cont_pref,
                    ee_cont_pref,
                    flg_block,
                    refer_to_doc,
                    eligibility_refer_to_doc,
                    voluntary_life_add_info,
                    created_by,
                    creation_date
                ) values ( p_entity_id,
                           v_entity_type -- 'Pop_Plan_Setup'
                           ,
                           benefit_codes_seq.nextval,
                           p_benefit_code_name(i),
                           v_desc,
                           p_batch_number,
                           v_eligibility,
                           v_er_ee_cont_lng,
                           v_er_amount,
                           v_ee_amount,
                           p_flg_block,
                           v_external_doc,
                           v_eligibility_refer_doc,  -- Added by Joshi for 7791
                           decode(
                               p_benefit_code_name(i),
                               'VOLUNTARY_LIFE_ADD',
                               p_voluntary_life_add_info,
                               null
                           ), -- added by Jaggi 9199
                           p_user_id,
                           sysdate );

            end if;
      /* Entity Name */
        end loop;
    /* Code Loop */
    exception
        when others then
            x_error_status := 'E';
            x_error_message := ( 'PC_EMPLOYER_ENROLL.Insert_Erisa_Eligib_Req Others '
                                 || sqlerrm(sqlcode) );
            pc_log.log_error('PC_EMPLOYER_ENROLL.Insert_Erisa_Eligib_Req', sqlerrm);
    end insert_erisa_eligib_req;

    procedure insert_plan_notices_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_notice_type   in varchar2_tbl,
        p_flg_no_notice in varchar2,
        p_flg_addition  in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_count number := 0;
    begin
        x_error_status := 'S';
        delete from plan_notices_stage
        where
                batch_number = p_batch_number
            and nvl(entrp_id, -1) in ( p_entrp_id, - 1 );

        for i in 1..p_notice_type.count loop
            if p_notice_type(i) is not null then
                insert into plan_notices_stage (
                    batch_number,
                    entity_id,
                    entity_type,
                    notice_type,
                    entrp_id,
                    creation_date,
                    created_by
                ) values ( p_batch_number,
                           p_ben_plan_id,
                           'BEN_PLAN_ENROLLMENT_SETUP',
                           p_notice_type(i),
                           p_entrp_id,
                           sysdate,
                           p_user_id );

            end if;
        end loop;

        if p_flg_no_notice = 'N'
        or nvl(p_flg_addition, '*') in ( 'N', 'Y' ) then
            insert into plan_notices_stage (
                batch_number,
                entity_id,
                entity_type,
                notice_type,
                flg_no_notice,
                flg_addition,
                entrp_id,
                creation_date,
                created_by
            ) values ( p_batch_number,
                       p_ben_plan_id,
                       'BEN_PLAN_ENROLLMENT_SETUP',
                       '5500',
                       p_flg_no_notice,
                       p_flg_addition,
                       p_entrp_id,
                       sysdate,
                       p_user_id );

        end if;

    exception
        when others then
            x_error_status := 'E';                                                                        -- swamy erisa
            x_error_message := ( 'PC_EMPLOYER_ENROLL.insert_plan_notices_stage Others '
                                 || sqlerrm(sqlcode) ); -- swamy erisa
            pc_log.log_error('PC_EMPLOYER_ENROLL.insert_plan_notices_stage', sqlerrm);
    end insert_plan_notices_stage;

    function get_plan_notices_stage (
        p_batch_number in number,
        p_entrp_id     in number,
        p_lookup_name  in varchar2
    ) return get_plan_notices_row_t
        pipelined
        deterministic
    is
        l_record get_plan_notices_row;
    begin
        for x in (
            select
                a.notice_type,
                b.description,
                a.flg_no_notice,
                a.flg_addition
            from
                plan_notices_stage a,
                lookups            b
            where
                    b.lookup_name = p_lookup_name
                and a.batch_number = p_batch_number
                and a.notice_type = b.lookup_code
                and a.entrp_id = p_entrp_id
            order by
                a.notice_type -- Ordr By Is Necessary For Php People To Correctly Mapp The Flg_No_Notice And Flg_Addition
        ) loop
      -- 5500 means null value, I am passing 5500 whie inserting into plan_notices_stage if the flag flg_no_notice is "N"
            if x.notice_type = '5500' then
                l_record.notice_type := null;
                l_record.description := null;
            else
                l_record.notice_type := x.notice_type;
                l_record.description := x.description;
            end if;

            l_record.flg_no_notice := x.flg_no_notice;
            l_record.flg_addition := x.flg_addition;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_plan_notices_stage;

    procedure upsert_emp_census_stage (
        p_entrp_id             in number,
        p_batch_number         in number,
        p_tot_emp              in number,
        p_tot_eligible_emp     in number,
        p_flg_5500             in varchar2,
        p_flg_final_filing     in varchar2,
        p_flg_plan_no_use      in varchar2,
        p_wrap_plan_5500       in varchar2,
        p_user_id              in number,
        p_erissa_wrap_doc_type in varchar2 default null,   -- Added by Swamy for Ticket#8684 on 19/05/2020
        x_error_status         out varchar2,
        x_error_message        out varchar2
    ) is
        v_check number;
    begin
        x_error_status := 'S';
        select
            count(*)
        into v_check
        from
            erisa_aca_eligibility_stage
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        if nvl(v_check, 0) = 0 then
            insert into erisa_aca_eligibility_stage (
                batch_number,
                eligibility_id,
                entrp_id,
                flg_5500,
                flg_final_filing,
                flg_plan_no_use,
                wrap_plan_5500
            ) values ( p_batch_number,
                       erisa_aca_stage_seq.nextval,
                       p_entrp_id,
                       p_flg_5500,
                       p_flg_final_filing,
                       p_flg_plan_no_use,
                       p_wrap_plan_5500 );

        else
            update erisa_aca_eligibility_stage
            set
                flg_5500 = p_flg_5500,
                flg_final_filing = p_flg_final_filing,
                flg_plan_no_use = p_flg_plan_no_use,
                wrap_plan_5500 = p_wrap_plan_5500
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

        end if;

        update online_compliance_staging
        set
            no_off_ees = p_tot_emp,
            no_of_eligible = p_tot_eligible_emp,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

    -- Added by Swamy for Ticket#8684
        if nvl(p_erissa_wrap_doc_type, '*') <> '*' then
            update compliance_plan_staging
            set
                erissa_erap_doc_type = p_erissa_wrap_doc_type
            where
                    entity_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

    exception
        when others then
            x_error_status := 'E';                                                                      -- Swamy Erisa
            x_error_message := ( 'Pc_Employer_Enroll.Upsert_Emp_Census_Stage Others '
                                 || sqlerrm(sqlcode) ); -- Swamy Erisa
            pc_log.log_error('Pc_Employer_Enroll.Upsert_Emp_Census_Stage', sqlerrm);
    end upsert_emp_census_stage;

    function get_employee_censes (
        p_batch_number in number,
        p_entrp_id     in number
    ) return get_emp_censes_row_t
        pipelined
    is
        l_record get_emp_censes_row;
    begin
        for x in (
            select
                b.no_off_ees,
                b.no_of_eligible,
                a.flg_5500,
                a.flg_final_filing,
                a.flg_plan_no_use,
                a.wrap_plan_5500,
                a.collective_bargain_flag
            from
                erisa_aca_eligibility_stage a,
                online_compliance_staging   b
            where
                    a.batch_number = p_batch_number
                and a.entrp_id = p_entrp_id
                and a.batch_number = b.batch_number
                and a.entrp_id = b.entrp_id
        ) loop
            l_record.no_off_ees := x.no_off_ees;
            l_record.no_of_eligible := x.no_of_eligible;
            l_record.flg_5500 := x.flg_5500;
            l_record.flg_final_filing := x.flg_final_filing;
            l_record.flg_plan_no_use := x.flg_plan_no_use;
            l_record.wrap_plan_5500 := x.wrap_plan_5500;
            l_record.collective_bargain_flag := x.collective_bargain_flag;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            l_record.error_status := 'E';
            l_record.error_message := sqlerrm;
            pipe row ( l_record );
    end get_employee_censes;

    procedure insert_ar_quote (
        p_batch_number        in number,
        p_entrp_id            in number,
        p_account_type        in varchar2,
        p_rate_plan_id        in varchar2_tbl,
        p_rate_plan_detail_id in varchar2_tbl,
        p_list_price          in varchar2_tbl,
        p_user_id             in varchar2,
        x_error_status        out varchar2,
        x_error_message       out varchar2
    ) is
        v_tot_price ar_quote_lines_staging.line_list_price%type;
        v_header    number;
    begin
        x_error_status := 'S';
        if p_rate_plan_id.count > 0 then
            delete from ar_quote_lines_staging
            where
                batch_number = p_batch_number;

            delete from ar_quote_headers_staging
            where
                batch_number = p_batch_number;

            v_header := compliance_quote_seq.nextval;
            for i in 1..p_rate_plan_id.count loop
                if p_rate_plan_detail_id(i) is not null then
                    insert into ar_quote_lines_staging (
                        quote_line_id,
                        quote_header_id,
                        rate_plan_id,
                        rate_plan_detail_id,
                        line_list_price,
                        batch_number,
                        created_by,
                        creation_date
                    ) values ( compliance_quote_lines_seq.nextval,
                               v_header,
                               p_rate_plan_id(i),
                               p_rate_plan_detail_id(i),
                               p_list_price(i),
                               p_batch_number,
                               p_user_id,
                               sysdate );

                end if;
            end loop;

            for i in (
                select
                    sum(line_list_price) price
                from
                    ar_quote_lines_staging
                where
                        batch_number = p_batch_number
                    and quote_header_id = v_header
            ) loop
                v_tot_price := i.price;
            end loop;

            insert into ar_quote_headers_staging (
                quote_header_id,
                total_quote_price,
                entrp_id,
                batch_number,
                account_type,
                created_by,
                creation_date
            ) values ( v_header,
                       v_tot_price,
                       p_entrp_id,
                       p_batch_number,
                       p_account_type,
                       p_user_id,
                       sysdate );

        end if;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := ' Error In Others Procedure Insert_Ar_Quote ' || sqlerrm(sqlcode);
    end insert_ar_quote;

    procedure erisa_stage_to_main (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_user_id       in varchar2,
        p_source        in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_renewed_by           varchar2(30);
        l_broker_id            number;
        l_authorize_req_id     number;
        l_return_status        varchar2(100);
        l_error_message        varchar2(1000);
        l_acct_usage           varchar2(100);
        l_bank_count           integer;
        l_bank_id              number;
        cursor cur_compliance is
        select
            record_id,
            entrp_id,
            no_off_ees,
            effective_date,
            state_of_org,
            fiscal_yr_end,
            type_of_entity,
            batch_number,
            bank_name,
            routing_number,
            bank_acc_num,
            bank_acc_type,
            error_message,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            remittance_flag,
            fees_payment_flag,
            salesrep_flag,
            salesrep_id,
            send_invoice,
            page2,
            page3_contact,
            page3_payment,
            entity_name_desc,
            org_eff_date,
            eff_date_sterling,
            no_of_eligible,
            affliated_flag,
            cntrl_grp_flag,
            page1_company,
            page1_plan,
            source,
            acct_payment_fees
        from
            online_compliance_staging
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        cursor cur_comp_stage is
        select
            plan_id,
            entity_id,
            plan_name,
            plan_type,
            plan_number,
            policy_number,
            insurance_company_name,
            governing_state,
            plan_start_date,
            plan_end_date,
            self_funded_flag,
            conversion_flag,
            bill_cobra_premium_flag,
            coverage_terminate,
            age_rated_flag,
            carrier_contact_name,
            carrier_contact_email,
            carrier_phone_no,
            carrier_addr,
            ee_premium,
            ee_spouse_premium,
            ee_child_premium,
            ee_children_premium,
            ee_family_premium,
            spouse_premium,
            child_premium,
            spouse_child_premium,
            description,
            batch_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            ben_plan_id,
            error_message,
            fees_payment_flag,
            takeover_flag,
            ga_flag,
            ga_id,
            short_plan_yr_flag,
            flg_plan_name,
            grandfathered,
            self_administered,
            notes,
            subsidy_in_spd_apndx,
            clm_lang_in_spd,
            wrap_opt_flg,
            flg_pre_adop_pln,
            erissa_erap_doc_type -- added by Joshi for 7791
        from
            compliance_plan_staging
        where
                batch_number = p_batch_number
            and entity_id = p_entrp_id;

        cursor cur_aca is
        select
            eligibility_id,
            ben_plan_id,
            aca_ale_flag,
            variable_hour_flag,
            intl_msrmnt_period,
            intl_msrmnt_start_date,
            intl_admn_period,
            stblty_period,
            msrmnt_start_date,
            msrmnt_period,
            msrmnt_end_date,
            admn_start_date,
            admn_period,
            admn_end_date,
            stblt_start_date,
            stblt_period,
            stblt_end_date,
            irs_lbm_flag,
            mnthl_msrmnt_flag,
            same_prd_bnft_start_date,
            new_prd_bnft_start_date,
            fte_hrs,
            fte_look_back,
            fte_salary_msmrt_period,
            fte_hourly_msmrt_period,
            fte_other_msmrt_period,
            fte_same_period_resume_date,
            fte_diff_period_resume_date,
            fte_other_ee_detail,
            fte_lkp_other_ee_detail,
            fte_lkp_salary_msmrt_period,
            fte_lkp_hourly_msmrt_period,
            fte_lkp_other_msmrt_period,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            collective_bargain_flag,
            flg_5500,
            flg_final_filing,
            flg_plan_no_use,
            wrap_plan_5500,
            tot_emp,
            batch_number,
            entrp_id,
            intl_msrmnt_period_det,
            special_inst,
            fte_same_period_select,
            fte_diff_period_select,
            define_intl_msrmnt_period
        from
            erisa_aca_eligibility_stage
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        cursor cur_affiliate_emp (
            vc_en_code in varchar2
        ) is
        select
            name
        from
            enterprise_staging
        where
                en_code = vc_en_code
            and batch_number = p_batch_number
        order by
            entrp_stg_id;

        v_benefit_code         benefit_codes_stage%rowtype;
        v_aca                  cur_aca%rowtype;
        v_comp                 cur_compliance%rowtype;
        v_comp_plan            cur_comp_stage%rowtype;
        v_aff_name             pc_employer_enroll.varchar2_tbl;
        v_cntrl_grp            pc_employer_enroll.varchar2_tbl;
        v_dummy                pc_employer_enroll.varchar2_tbl;
        v_dummy1               pc_employer_enroll.varchar2_tbl;
        v_dummy2               pc_employer_enroll.varchar2_tbl;
        v_dummy3               pc_employer_enroll.varchar2_tbl;
        v_dummy4               pc_employer_enroll.varchar2_tbl;
        v_dummy5               pc_employer_enroll.varchar2_tbl;
        v_rate_plan_id         pc_employer_enroll.varchar2_tbl;
        v_rate_plan_detail_id  pc_employer_enroll.varchar2_tbl;
        v_line_list_price      pc_employer_enroll.varchar2_tbl;
        v_plan                 plan_employer_contacts_stage%rowtype;
        v_plan_fund_code       varchar2(500);
        v_count                number;
        v_tot_price            ar_quote_lines.line_list_price%type := 0;
        x_er_ben_plan_id       ben_plan_enrollment_setup.ben_plan_id%type;
        v_cnt_aff_name         number := 0;
        v_5500_filing          varchar2(1);
        v_wrap_plan_5500       varchar2(1);
        v_erissa_erap_doc_type varchar2(1);
        x_bank_acct_id         number;
        v_display_name         varchar2(500);
        v_acc_num              account.acc_num%type;
        v_acc_id               account.acc_id%type;
        v_found                varchar2(1);
        v_cnt                  number;
        v_eligibility          varchar2(500);
        v_er_ee_contrib_lng    varchar2(500);
        v_code_name            varchar2(500);
        v_entity_type          varchar2(500);
        erreur exception;
        l_acc_id               number;
        l_entity_type          varchar2(50);  ----9141 rprabu 05/08/2020
        l_entity_id            number;   ----9141 rprabu 05/08/2020
        l_enrolle_type         varchar2(50);  ----9141 rprabu 05/08/2020
        l_enrolled_by          number;   ----9141 rprabu 05/08/2020
        l_ga_broker_flg        varchar2(1) := 'N';  -- Added by Swamy for Ticket#9387 on 21/08/2020
        l_resubmit_flag        varchar2(1);
        l_inactive_plan_exist  varchar2(1);
        l_sales_team_member_id number;
        lc_source              varchar2(1);
        l_bank_acct_num        varchar2(20);
        l_bank_status          varchar2(20);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main begin', 'P_Batch_Number := '
                                                                         || p_batch_number
                                                                         || ' P_Entrp_Id :='
                                                                         || p_entrp_id);
        x_error_status := 'S';
        v_aca := null;
        v_comp := null;
        v_comp_plan := null;
        v_plan_fund_code := null;
        open cur_compliance;
        fetch cur_compliance into v_comp;
        close cur_compliance;
        if v_comp.entrp_id is null then
            x_error_message := 'There is no data for Company Information';
            raise erreur;
        end if;
        open cur_comp_stage;
        fetch cur_comp_stage into v_comp_plan;
        close cur_comp_stage;
        if v_comp_plan.plan_id is null then
            x_error_message := 'There is no data for Plan Setup Information/Arrangement Options';
            raise erreur;
        end if;

     -- added by Jaggi #11629
        if v_comp.salesrep_id is not null then
            pc_sales_team.upsert_sales_team_member(
                p_entity_type           => 'SALES_REP',
                p_entity_id             => v_comp.salesrep_id,
                p_mem_role              => 'PRIMARY',
                p_entrp_id              => p_entrp_id,
                p_start_date            => trunc(sysdate),
                p_end_date              => null,
                p_status                => 'A',
                p_user_id               => p_user_id,
                p_pay_commission        => null,
                p_note                  => null,
                p_no_of_days            => null,
                px_sales_team_member_id => l_sales_team_member_id,
                x_return_status         => l_return_status,
                x_error_message         => x_error_message
            );
        end if;

        for x in (
            select
                name
            from
                enterprise_staging
            where
                    en_code = '10'
                and batch_number = p_batch_number
            order by
                entrp_stg_id
        ) loop
            v_cnt_aff_name := v_cnt_aff_name + 1;
            v_aff_name(v_cnt_aff_name) := x.name;
        end loop;

        v_cnt_aff_name := 0;
        for i in (
            select
                name
            from
                enterprise_staging
            where
                    en_code = '11'
                and batch_number = p_batch_number
            order by
                entrp_stg_id
        ) loop
            v_cnt_aff_name := v_cnt_aff_name + 1;
            v_cntrl_grp(v_cnt_aff_name) := i.name;
        end loop;

        v_cnt_aff_name := 0;
        open cur_aca;
        fetch cur_aca into v_aca;
        close cur_aca;
        if v_aca.ben_plan_id is null then
            x_error_message := 'There Is No Data In Aca Eligibility And Measurement Period Information';
            raise erreur;
        end if;
        for i in (
            select
                notice_type,
                flg_no_notice,
                flg_addition
            from
                plan_notices_stage
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and notice_type is not null
        ) loop
      -- In Erisa Notice_Type The Functionality Of 5500 Is Not Used. In Coding It Is Used As 5500 During Insertion In Staging Table To Get The Value Of Flg_No_Notice And Flg_Addition
      -- This Is Used During Retrival, As The Query For Retrival Is A Join From Lookup Table With Lookup_Code As 'Plan_Notice', Hence During Insertion From Staging To Base Tables
      -- We Are Not Inserting The Record With Notice_Type 5500.
            if i.notice_type = '5500' then
                if nvl(i.flg_no_notice, '*') = 'N' then  -- Start Added by swamy for Ticket#6681
                    if nvl(v_plan_fund_code, '*') = '*' then
                        v_plan_fund_code := 'NO_NOTICE';
                    else
                        v_plan_fund_code := v_plan_fund_code
                                            || ':'
                                            || 'NO_NOTICE';
                    end if;
                end if;      -- End Of Addition by swamy for Ticket#6681
                continue;
            end if;

            if nvl(v_plan_fund_code, '*') = '*' then
                v_plan_fund_code := i.notice_type;
            else
                v_plan_fund_code := v_plan_fund_code
                                    || ':'
                                    || i.notice_type;
            end if;

        end loop;

        v_count := 0;
        v_tot_price := 0;
        v_rate_plan_id.delete;
        v_rate_plan_detail_id.delete;
        v_line_list_price.delete;
        for i in (
            select
                rate_plan_id,
                rate_plan_detail_id,
                line_list_price
            from
                ar_quote_lines_staging
            where
                batch_number = p_batch_number
        ) loop
            v_count := nvl(v_count, 0) + 1;
            v_rate_plan_id(v_count) := i.rate_plan_id;
            v_rate_plan_detail_id(v_count) := i.rate_plan_detail_id;
            v_line_list_price(v_count) := i.line_list_price;
            v_tot_price := nvl(v_tot_price, 0) + i.line_list_price;
        end loop;

        v_count := 0;
        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main begin', 'V_Tot_Price := ' || v_tot_price);
        for k in (
            select
                acc_id,
                acc_num,
                enrolled_by          -----9141 rprabu 11/08/2020
                ,
                enrolle_type         ---9141 rprabu   11/08/2020
                ,
                nvl(resubmit_flag, 'N') resubmit_flag
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            v_acc_id := k.acc_id;
            v_acc_num := k.acc_num;
            l_enrolled_by := k.enrolled_by;  ------9141 rprabu 11/08/2020
            l_enrolle_type := k.enrolle_type; ----9141 rprabu   11/08/2020
            l_resubmit_flag := k.resubmit_flag;
        end loop;

        l_inactive_plan_exist := nvl(
            pc_employer_enroll_compliance.get_resubmit_inactive_flag(p_entrp_id),
            'N'
        );

     -- Added by Joshi #12279 
        if pc_account.get_broker_id(v_acc_id) = 0 then
            for j in (
                select
                    broker_id
                from
                    online_users ou,
                    broker       b
                where
                        user_id = p_user_id
                    and user_type = 'B'
                    and upper(tax_id) = upper(broker_lic)
            ) loop
                update account
                set
                    broker_id = j.broker_id
                where
                    entrp_id = p_entrp_id;

            end loop;
        end if;

    -- In PHP, they are sending as Y only for "FORM_STERLING", others they are sending as 'N'
    -- Same this is implemented here.
        if upper(v_aca.flg_5500) = 'FORM_STERLING' then
            v_5500_filing := 'Y';
        else
            v_5500_filing := 'N';
        end if;
    -- In Php, They Are Sending As Y Only For "Form_Sterling", Others They Are Sending As 'N'
    -- Same This Is Implemented Here.
        if upper(v_aca.wrap_plan_5500) = 'FORM_STERLING' then
            v_wrap_plan_5500 := 'Y';
        else
            v_wrap_plan_5500 := 'N';
        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main calling Pc_Employer_Enroll.Create_Erisa_Plan', 'V_Comp.Type_Of_Entity := ' || v_comp.type_of_entity
        );
    /*Ticket#6834.User ID should be passed as per ip parameter value */

	-- Added by Joshi 10430. need to delete existing affliated ER incase of resubmission
        if l_resubmit_flag = 'Y' then
            delete from enterprise
            where
                entrp_id in (
                    select
                        entity_id
                    from
                        entrp_relationships
                    where
                            entrp_id = p_entrp_id
                        and entity_type = 'ENTERPRISE'
                        and relationship_type in ( 'AFFILIATED_ER', 'CONTROLLED_GROUP' )
                )
                and en_code in ( 10, 11 )
                and entrp_code is null;

            delete from entrp_relationships
            where
                    entrp_id = p_entrp_id
                and entity_type = 'ENTERPRISE'
                and relationship_type in ( 'AFFILIATED_ER', 'CONTROLLED_GROUP' );
             -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
             -- user might update existing  contacts.
            for c in (
                select
                    contact_id
                from
                    contact_leads
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and account_type = 'ERISA_WRAP'
                    and ref_entity_type = 'ONLINE_ENROLLMENT'
            ) loop
                delete from contact
                where
                        entity_id = pc_entrp.get_tax_id(p_entrp_id)
                    and contact_id = c.contact_id;

                delete from contact_role
                where
                    contact_id = c.contact_id;

            end loop;

            update user_bank_acct
            set
                status = 'I'
            where
                    acc_id = v_acc_id
                and bank_account_usage = 'INVOICE';

            /* commented and added below by Joshi for #12339. Ben plan deletion issue
           FOR B IN (  SELECT ben_plan_id
                         FROM ben_plan_enrollment_setup
                        WHERE acc_id = v_acc_id
                          AND entrp_id = p_entrp_id) */

            for b in (
                select distinct
                    bp.ben_plan_id
                from
                    ben_plan_enrollment_setup bp,
                    online_compliance_staging os,
                    compliance_plan_staging   ops
                where
                        os.batch_number = p_batch_number
                    and os.entrp_id = p_entrp_id
                    and os.batch_number = ops.batch_number
                    and os.entrp_id = bp.entrp_id
                    and ops.ben_plan_id = bp.ben_plan_id
            ) loop
                delete from custom_eligibility_req
                where
                    entity_id = b.ben_plan_id;

                delete from benefit_codes
                where
                        entity_id = b.ben_plan_id
                    and entity_type = 'BEN_PLAN_ENROLLMENT_SETUP';

                -- Delete all the ben_plan_enrollment_data. 10430 Joshi
                delete from ben_plan_enrollment_setup
                where
                        acc_id = v_acc_id
                    and entrp_id = p_entrp_id
                    and ben_plan_id = b.ben_plan_id;

            end loop;

        end if;
         --- Ends here : 10430


        pc_employer_enroll.create_erisa_plan(
            p_entrp_id             => p_entrp_id,
            p_state_of_org         => v_comp.state_of_org,
            p_entity_type          => v_comp.type_of_entity,
            p_entity_name          => v_comp.entity_name_desc,
            p_fiscal_end_date      => v_comp.fiscal_yr_end,
            p_aff_name             => v_aff_name,
            p_cntrl_grp            => v_cntrl_grp,
            p_plan_name            => v_comp_plan.plan_name,
            p_plan_number          => v_comp_plan.plan_number,
            p_eff_date             => v_comp.effective_date,
            p_org_eff_date         => v_comp.org_eff_date,
            p_plan_start_date      => v_comp_plan.plan_start_date,
            p_plan_end_date        => v_comp_plan.plan_end_date,
            p_user_id              => p_user_id,
            p_no_of_ee             => v_comp.no_off_ees,
            p_no_of_elg_ee         => v_comp.no_of_eligible,
            p_benefit_code_name    => v_dummy4,
            p_description          => v_dummy5,
            p_5500_filing          => v_5500_filing,
            p_grandfathered        => v_comp_plan.grandfathered,
            p_administered         => v_comp_plan.self_administered,
            p_clm_lang_in_spd      => v_comp_plan.clm_lang_in_spd,
            p_subsidy_in_spd_apndx => v_comp_plan.subsidy_in_spd_apndx,
            p_takeover             => v_comp_plan.flg_pre_adop_pln -- Replaced Null with V_Comp_Plan.flg_pre_adop_pln for Ticket#6616
            ,
            p_plan_fund_code       => v_plan_fund_code,
            p_plan_benefit_code    => null,
            p_tot_price            => v_tot_price,
            p_rate_plan_id         => v_rate_plan_id,
            p_rate_plan_detail_id  => v_rate_plan_detail_id,
            p_list_price           => v_line_list_price,
            p_payment_method       => v_comp.fees_payment_flag,
            p_final_filing_flag    => v_aca.flg_final_filing,
            p_wrap_plan_5500       => v_wrap_plan_5500,
            p_salesrep_id          => v_comp.salesrep_id,
            p_wrap_opt_flg         => v_comp_plan.wrap_opt_flg,
            x_er_ben_plan_id       => x_er_ben_plan_id,
            p_erissa_erap_doc_type => v_comp_plan.erissa_erap_doc_type,
            x_error_status         => x_error_status,
            x_error_message        => x_error_message
        );

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main After calling Pc_Employer_Enroll.Create_Erisa_Plan', 'X_Error_Status := '
                                                                                                                      || x_error_status
                                                                                                                      || ' X_Error_Message :='
                                                                                                                      || x_error_message
                                                                                                                      );
        if nvl(x_error_status, 'S') = 'E' then
            raise erreur;
        end if;

				-- Added by Joshi for 10431

        if nvl(x_error_status, 'S') = 'S' then
            update compliance_plan_staging
            set
                ben_plan_id = x_er_ben_plan_id
            where
                    entity_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

        update ar_quote_headers
        set
            pay_acct_fees = v_comp.acct_payment_fees
        where
                entrp_id = p_entrp_id
            and ben_plan_id = x_er_ben_plan_id;   -- Added by Swamy for Ticket#9304

        update enterprise
        set
            entity_name_desc = v_comp.entity_name_desc
        where
            entrp_id = p_entrp_id;     -- Added by Swamy for Ticket#9304

     -- Start of Addition by Swamy for Ticket#7799
     -- For Erisa, the data is not populating into Account_Preference table, due to this the functionality of Ticket#7799 is broken.
        for m in (
            select
                acc_id
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_acc_id := m.acc_id;
        end loop;
	 -- Inserting the data into Account_Preference Table.
        pc_account.upsert_acc_pref(
            p_entrp_id               => p_entrp_id,
            p_acc_id                 => l_acc_id,
            p_claim_pay_method       => null,
            p_auto_pay               => null,
            p_plan_doc_only          => null,
            p_status                 => 'A',
            p_allow_eob              => 'Y',
            p_user_id                => p_user_id,
            p_pin_mailer             => 'N',
            p_teamster_group         => 'N',
            p_allow_exp_enroll       => 'Y',
            p_maint_fee_paid         => null,
            p_allow_online_renewal   => 'Y',
            p_allow_election_changes => 'N',
            p_plan_action_flg        => 'Y',
            p_submit_election_change => 'Y',
            p_edi_flag               => 'N',
            p_vendor_id              => null,
            p_reference_flag         => null,
            p_allow_payroll_edi      => null,
            p_fees_paid_by           => null   -- Added by Swamy for Ticket#11037
        );
    -- End of Addition by Swamy for Ticket#7799

    -- inserting into benefit codes table
        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main Inserting the records into Benefit_Codes Table for Flg_Block 2 ', 'X_Error_Status := ' || x_error_status
        );
        for j in (
            select
                seq_id,
                entity_id,
                benefit_code_id,
                benefit_code_name,
                status,
                batch_number,
                creation_date,
                created_by,
                last_updated_by,
                description,
                entity_type,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc -- added by Joshi for 7791
                ,
                voluntary_life_add_info  -- added by Jaggi for 9199
                ,
                flg_block                -- Added by Swamy for Ticket#9304
            from
                benefit_codes_stage
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
                and flg_block = '2'
        )--cur_benefit_codes
         loop
            v_eligibility := null;
            v_er_ee_contrib_lng := null;
            v_code_name := null;
            if nvl(j.eligibility, '*') <> '*' then
                v_eligibility := nvl(
                    pc_lookups.get_meaning(j.eligibility, 'ELIGIBILITY_OPTIONS'),
                    pc_lookups.get_meaning(j.eligibility, 'ELIGIBILITY_OPTIONS_OTHER')
                );
       -- Added by Joshi 7791
                if v_eligibility is null then
                    v_eligibility := pc_lookups.get_meaning(j.eligibility, 'ELIGIBILITY_OPTIONS_OTHER_REF');
                end if;

            end if;

            if nvl(j.er_ee_contrib_lng, '*') <> '*' then
                v_er_ee_contrib_lng := pc_lookups.get_meaning(j.er_ee_contrib_lng, 'ER_EE_CONTRIB_LNG');
            end if;

            if j.benefit_code_name = 'OTHER' then
                v_code_name := j.benefit_code_name
                               || '('
                               || j.description
                               || ')';
            else
                v_code_name := j.benefit_code_name;
            end if;

            insert into benefit_codes (
                benefit_code_id,
                benefit_code_name,
                entity_id,
                entity_type,
                description,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc -- added by Joshi for 7791
                ,
                voluntary_life_add_info  -- added by Jaggi for 9199
                ,
                eligibility_code         -- Added by Swamy for Ticket#9304
                ,
                er_ee_contrib_lng_code   -- Added by Swamy for Ticket#9304
                ,
                flg_block                -- Added by Swamy for Ticket#9304
                ,
                creation_date,
                created_by
            ) values ( benefit_code_seq.nextval,
                       v_code_name,
                       x_er_ben_plan_id,
                       j.entity_type --'BEN_PLAN_ENROLLMENT_SETUP',
                       ,
                       j.description,
                       j.er_cont_pref,
                       j.ee_cont_pref,
                       v_eligibility,
                       v_er_ee_contrib_lng,
                       j.refer_to_doc,
                       j.eligibility_refer_to_doc -- Added by Joshi 7791.
                       ,
                       j.voluntary_life_add_info  -- added by Jaggi for 9199
                       ,
                       j.eligibility           -- Added by Swamy for Ticket#9304
                       ,
                       j.er_ee_contrib_lng     -- Added by Swamy for Ticket#9304
                       ,
                       j.flg_block             -- Added by Swamy for Ticket#9304
                       ,
                       sysdate,
                       p_user_id );

        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main Inserting the records into Benefit_Codes Table for Flg_Block 1 and flg_block 3'
        , 'X_Error_Status := ' || x_error_status);
        for j in (
            select distinct
                benefit_code_name,
                entity_id,
                benefit_code_id,
                status,
                batch_number,
                creation_date,
                created_by,
                last_updated_by,
                description,
                entity_type,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc,
                voluntary_life_add_info  -- added by Jaggi for 9199
                ,
                flg_block                -- Added by Swamy for Ticket#9304
            from
                benefit_codes_stage
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
                and flg_block in ( '1', '3' )
        )--cur_benefit_codes
         loop
    /*  -- During Enrollment,Some Of The Items Are Repeated In Three Blocks(Subsidiary Contracts(Block 1),Welfare Benefit Plans(Block 2),Claims Language (Block 3)),
      -- All The Duplicate Records Are Stored In Session Table.(Beneft_Codes_Stage). But Insertion Into Base Table(Benefit Codes) Only Unique Record Should Be Inserted.
      -- Hence We Are First Inserting All The Records With Flg_Block = 2, And Then Check For Records Of Flg_Block 1 And 3 With Already Inserted Record Of Flg_Block 1. If Its Already Inserted, Then Continue,Else The Record Is Inserted.
      v_found := 'F';
      FOR M IN
      (SELECT Benefit_Code_Name
         FROM Benefit_Codes_Stage
        WHERE Batch_Number       = P_Batch_Number
          AND Entity_Id          = P_Entrp_Id
          AND Flg_Block          = '2'
          AND Benefit_Code_Name  = J.Benefit_Code_Name
          AND Benefit_Code_Name  <> 'OTHER'
      )
      LOOP
        V_Found := 'T';
        EXIT;
      END LOOP;
      V_Code_Name   := NULL;
      V_Entity_Type := NULL;
      IF V_Found     = 'T' THEN
        CONTINUE;
      END IF;
      */                       -- Commented by Swamy for Ticket#9304

            v_code_name := null;   -- Added by Swamy for Ticket#9304
            v_entity_type := null;   -- Added by Swamy for Ticket#9304

            if j.entity_type = 'BEN_PLAN_ENROLLMENT_SETUP' then
                v_entity_type := 'BEN_PLAN_ENROLL';
            else
                v_entity_type := j.entity_type;
            end if;

            if j.benefit_code_name = 'OTHER' then
                v_code_name := j.benefit_code_name
                               || '('
                               || j.description
                               || ')';
            else
                v_code_name := j.benefit_code_name;
            end if;

            insert into benefit_codes (
                benefit_code_id,
                benefit_code_name,
                entity_id,
                entity_type,
                description,
                er_cont_pref,
                ee_cont_pref,
                eligibility,
                er_ee_contrib_lng,
                refer_to_doc,
                eligibility_refer_to_doc,
                voluntary_life_add_info  -- added by Jaggi for 9199
                ,
                eligibility_code         -- Added by Swamy for Ticket#9304
                ,
                er_ee_contrib_lng_code   -- Added by Swamy for Ticket#9304
                ,
                flg_block                -- Added by Swamy for Ticket#9304
                ,
                creation_date,
                created_by
            ) values ( benefit_code_seq.nextval,
                       v_code_name,
                       x_er_ben_plan_id,
                       v_entity_type --'BEN_PLAN_ENROLLMENT_SETUP',
                       ,
                       j.description,
                       j.er_cont_pref,
                       j.ee_cont_pref,
                       j.eligibility,
                       j.er_ee_contrib_lng,
                       j.refer_to_doc,
                       j.eligibility_refer_to_doc -- added by Joshi for 7791
                       ,
                       j.voluntary_life_add_info  -- added by Jaggi for 9199
                       ,
                       j.eligibility           -- Added by Swamy for Ticket#9304
                       ,
                       j.er_ee_contrib_lng     -- Added by Swamy for Ticket#9304
                       ,
                       j.flg_block             -- Added by Swamy for Ticket#9304
                       ,
                       sysdate,
                       p_user_id );

        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main calling Create_Aca_Eligibility', 'X_Er_Ben_Plan_Id := ' || x_er_ben_plan_id
        );
        pc_employer_enroll.create_aca_eligibility(
            p_ben_plan_id                 => x_er_ben_plan_id,
            p_aca_ale_flag                => v_aca.aca_ale_flag,
            p_variable_hour_flag          => v_aca.variable_hour_flag,
            p_intl_msrmnt_period          => v_aca.intl_msrmnt_period,
            p_intl_msrmnt_start_date      => v_aca.intl_msrmnt_start_date,
            p_intl_admn_period            => v_aca.intl_admn_period,
            p_stblty_period               => v_aca.stblty_period,
            p_msrmnt_start_date           => v_aca.msrmnt_start_date,
            p_msrmnt_period               => v_aca.msrmnt_period,
            p_msrmnt_end_date             => v_aca.msrmnt_end_date,
            p_admn_start_date             => v_aca.admn_start_date,
            p_admn_period                 => v_aca.admn_period,
            p_admn_end_date               => v_aca.admn_end_date,
            p_stblt_start_date            => v_aca.stblt_start_date,
            p_stblt_period                => v_aca.stblt_period,
            p_stblt_end_date              => v_aca.stblt_end_date,
            p_irs_lbm_flag                => v_aca.irs_lbm_flag,
            p_mnthl_msrmnt_flag           => v_aca.mnthl_msrmnt_flag,
            p_same_prd_bnft_start_date    => v_aca.same_prd_bnft_start_date,
            p_new_prd_bnft_start_date     => v_aca.new_prd_bnft_start_date,
            p_user_id                     => p_user_id,
            p_eligibility                 => v_dummy,
            p_er_contrib                  => v_dummy1,
            p_ee_contrib                  => v_dummy2,
            p_benefit_code_id             => v_dummy3,
            p_entrp_id                    => p_entrp_id,
            p_collective_bargain_flag     => v_aca.collective_bargain_flag,
            p_intl_msrmnt_period_det      => v_aca.intl_msrmnt_period_det,
            p_fte_same_period_resume_date => v_aca.fte_same_period_resume_date,
            p_fte_diff_period_resume_date => v_aca.fte_diff_period_resume_date,
            p_fte_hrs                     => v_aca.fte_hrs,
            p_fte_salary_msmrt_period     => v_aca.fte_salary_msmrt_period,
            p_fte_hourly_msmrt_period     => v_aca.fte_hourly_msmrt_period,
            p_fte_other_msmrt_period      => v_aca.fte_other_msmrt_period,
            p_fte_other_ee_detail         => v_aca.fte_other_ee_detail,
            p_fte_look_back               => v_aca.fte_look_back,
            p_fte_lkp_salary_msmrt_period => v_aca.fte_lkp_salary_msmrt_period,
            p_fte_lkp_hourly_msmrt_period => v_aca.fte_lkp_hourly_msmrt_period,
            p_fte_lkp_other_msmrt_period  => v_aca.fte_lkp_other_msmrt_period,
            p_fte_lkp_other_ee_detail     => v_aca.fte_lkp_other_ee_detail,
            p_fte_same_period_select      => v_aca.fte_same_period_select,
            p_fte_diff_period_select      => v_aca.fte_diff_period_select,
            p_define_intl_msrmnt_period   => v_aca.define_intl_msrmnt_period,
            x_error_status                => x_error_status,
            x_error_message               => x_error_message
        );

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main After calling Create_Aca_Eligibility', 'X_Error_Status := '
                                                                                                        || x_error_status
                                                                                                        || ' X_Error_Message :='
                                                                                                        || x_error_message);
        if nvl(x_error_status, 'S') = 'E' then
            raise erreur;
        end if;
        for v_plan in (
            select
                admin_type,
                plan_admin_name,
                contact_type,
                contact_name,
                phone_num,
                email,
                address1,
                address2,
                city,
                state,
                zip_code,
                plan_agent,
                description,
                agent_name,
                legal_agent_contact_type,
                legal_agent_contact,
                legal_agent_phone,
                legal_agent_email,
                trust_fund,
                trustee_name,
                trustee_contact_type,
                trustee_contact_name,
                trustee_contact_phone,
                trustee_contact_email
            from
                plan_employer_contacts_stage
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
        ) --cur_plan_employer
         loop
            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main calling CREATE_EMP_PLAN_CONTACTS', 'V_Plan.Email := '
                                                                                                        || v_plan.email
                                                                                                        || ' V_Plan.Admin_Type :='
                                                                                                        || v_plan.admin_type);

            pc_employer_enroll.create_emp_plan_contacts(
                p_admin_type               => v_plan.admin_type,
                p_plan_admin_name          => v_plan.plan_admin_name,
                p_contact_type             => v_plan.contact_type,
                p_contact_name             => v_plan.contact_name,
                p_phone_num                => v_plan.phone_num,
                p_email                    => v_plan.email,
                p_address1                 => v_plan.address1,
                p_address2                 => v_plan.address2,
                p_city                     => v_plan.city,
                p_state                    => v_plan.state,
                p_zip_code                 => v_plan.zip_code,
                p_plan_agent               => v_plan.plan_agent,
                p_description              => v_plan.description,
                p_agent_name               => v_plan.agent_name,
                p_legal_agent_contact_type => v_plan.legal_agent_contact_type,
                p_legal_agent_contact      => v_plan.legal_agent_contact,
                p_legal_agent_phone        => v_plan.legal_agent_phone,
                p_legal_agent_email        => v_plan.legal_agent_email,
                p_trust_fund               => v_plan.trust_fund,
                p_trustee_name             => v_plan.trustee_name,
                p_trustee_contact_type     => v_plan.trustee_contact_type,
                p_trustee_contact_name     => v_plan.trustee_contact_name,
                p_trustee_contact_phone    => v_plan.trustee_contact_phone,
                p_trustee_contact_email    => v_plan.trustee_contact_email,
                p_user_id                  => p_user_id,
                p_entrp_id                 => x_er_ben_plan_id,
                p_batch_number             => p_batch_number,
                x_error_status             => x_error_status,
                x_error_message            => x_error_message
            );

            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main After calling CREATE_EMP_PLAN_CONTACTS', 'X_Error_Status := '
                                                                                                              || x_error_status
                                                                                                              || ' X_Error_Message :='
                                                                                                              || x_error_message);
            if nvl(x_error_status, 'S') = 'E' then
                raise erreur;
            end if;
        end loop;


     -- Added by Joshi for 10431. need to delete existing contacts and reinsert as in case of resubmit
     -- user might update existing  contacts.
        if l_resubmit_flag = 'Y' then
            delete from contact
            where
                contact_id in (
                    select
                        contact_id
                    from
                        contact_leads
                    where
                            entity_id = pc_entrp.get_tax_id(p_entrp_id)
                        and account_type = p_account_type
                );

        end if;

        for i in (
            select
                contact_id,
                first_name,
                email,
                user_id,
                creation_date,
                updated,
                entity_id,
                account_type,
                contact_type,
                send_invoice,
                entity_type,
                ref_entity_id,
                ref_entity_type,
                phone_num,
                contact_fax,
                job_title,
                lic_number
            from
                contact_leads a
            where
                    account_type = p_account_type
                and not exists (
                    select
                        1
                    from
                        contact b
                    where
                        a.contact_id = b.contact_id
                )     -------- 7783 rprabu 31/10/2019
                and entity_id = pc_entrp.get_tax_id(p_entrp_id)
        ) --Cur_Contacts
         loop
            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main calling Update_Contact_Info', 'I.Contact_Id := '
                                                                                                   || i.contact_id
                                                                                                   || ' P_Entrp_Id :='
                                                                                                   || p_entrp_id);

            pc_employer_enroll.update_contact_info(
                p_contact_id      => i.contact_id,
                p_entrp_id        => p_entrp_id,
                p_first_name      => i.first_name,
                p_email           => i.email,
                p_account_type    => i.account_type,
                p_contact_type    => i.contact_type,
                p_user_id         => p_user_id,
                p_ref_entity_id   => i.ref_entity_id,
                p_ref_entity_type => i.ref_entity_type,
                p_send_invoice    => i.send_invoice,
                p_status          => null,
                p_phone_num       => i.phone_num,
                p_fax_no          => i.contact_fax,
                p_job_title       => i.job_title,
                x_return_status   => x_error_status,
                x_error_message   => x_error_message
            );

            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main After calling Update_Contact_Info', 'X_Error_Status := '
                                                                                                         || x_error_status
                                                                                                         || ' X_Error_Message :='
                                                                                                         || x_error_message);
            if nvl(x_error_status, 'S') = 'E' then
                raise erreur;
            end if;
        end loop;

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main ', 'v_Comp.fees_payment_flag := ' || v_comp.fees_payment_flag);
   -- IF v_Comp.fees_payment_flag = 'ACH' THEN
        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main calling Pc_User_Bank_Acct.Insert_User_Bank_Acct', 'V_Acc_Num := ' || v_acc_num
        );

      /*  Commented by rprabu 11/08/2020 for 9141
      Pc_User_Bank_Acct.Insert_User_Bank_Acct
	                   (P_Acc_Num             => V_Acc_Num
                       ,P_Display_Name        => V_Comp.Bank_Name
                       ,P_Bank_Acct_Type      => V_Comp.Bank_Acc_Type
                       ,P_Bank_Routing_Num    => V_Comp.Routing_Number
                       ,P_Bank_Acct_Num       => V_Comp.Bank_Acc_Num
                       ,P_Bank_Name           => V_Comp.Bank_Name
                       ,P_User_Id             => P_User_Id
                       ,X_Bank_Acct_Id        => X_Bank_Acct_Id
                       ,X_Return_Status       => X_Error_Status ,X_Error_Message => X_Error_Message);
          pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main after calling Pc_User_Bank_Acct.Insert_User_Bank_Acct','X_Error_Status := '||X_Error_Status||' X_Error_Message :='||X_Error_Message);
          IF NVL(X_Error_Status,'S') = 'E' THEN
            Raise Erreur;
          END IF;*/
          ------------9141 rprabu 11/08/2020
		     ------------  rprabu 21/09/2020    Ticket #9507---#9508---ERISA_WRAP
         /* commented by Joshi  for 12279     
         IF l_Enrolle_Type = 'BROKER' THEN   -- If Cond. for Broker Added by Swamy for Ticket#9730
             IF nvl(v_Comp.acct_payment_fees,'EMPLOYER') = 'EMPLOYER'  Then   ------ 9412 rprabu 31/08/2020
                L_Entity_Id    := l_acc_Id;
                L_Entity_Type  :=    'ACCOUNT';
             ELSIF v_Comp.acct_payment_fees = 'BROKER' Then
                L_Entity_Id    := l_Enrolled_By;
                L_Entity_Type  := l_Enrolle_Type;
             End If;

         ELSIF l_Enrolle_Type ='GA' Then   ------rprabu 21/09/2020             Ticket #9507---#9508---
            IF NVL(v_Comp.acct_payment_fees,'EMPLOYER')   IN ('EMPLOYER','BROKER')  THEN
              L_Entity_Id     := l_acc_Id;
              L_Entity_Type   := 'ACCOUNT';
            ELSIF v_Comp.acct_payment_fees   In ('GA')   Then
              L_Entity_Id     :=    l_Enrolled_By;
              L_Entity_Type   :=     l_Enrolle_Type;
            END IF;
         ELSIF  NVL(l_Enrolle_Type, 'EMPLOYER' )  = 'EMPLOYER'  THEN    ------rprabu 21/09/2020             Ticket #9507---#9508---
                   L_Entity_Id        := l_acc_Id;
                   L_Entity_Type      := 'ACCOUNT';
         END IF;
           -------9141 rprabu 11/08/2020

           -- Added by Swamy for Ticket#9387 on 21/08/2020
           l_ga_broker_flg := pc_user_bank_acct.check_bank_acct
                                                (p_entity_id      => L_Entity_Id
                                                ,p_entity_type    => L_Entity_Type
                                                ,p_bank_acct_type => v_Comp.Bank_Acc_Type
                                                ,p_routing_number => v_Comp.Routing_Number
                                                ,p_bank_acct_num  => v_Comp.Bank_Acc_Num
                                                ,p_bank_name      => v_Comp.Bank_Name
                                                 ,p_bank_account_usage =>  'INVOICE'); -- Joshi 10430

           IF l_ga_broker_flg = 'N' THEN  -- End of Addition by Swamy for Ticket#9387
           ------------9141 rprabu 11/08/2020
              Pc_User_Bank_Acct.Insert_Bank_Account(P_Entity_Id        => L_Entity_Id ,
                                                    P_Entity_Type      => L_Entity_Type,
                                                    P_Display_Name     => v_Comp.Bank_Name ,
                                                    P_Bank_Acct_Type   => v_Comp.Bank_Acc_Type ,
                                                    P_Bank_Routing_Num => v_Comp.Routing_Number,
                                                    P_Bank_Acct_Num    => v_Comp.Bank_Acc_Num ,
                                                    P_Bank_Name        => v_Comp.Bank_Name ,
                                                    P_Bank_Account_Usage => 'INVOICE' ,
                                                    P_User_Id          => P_User_Id ,
                                                    X_Bank_Acct_Id     => X_Bank_Acct_Id ,
                                                    X_Return_Status    => X_Error_Status ,
                                                    X_Error_Message    => X_Error_Message );

                    pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main after calling Pc_User_Bank_Acct.Insert_User_Bank_Acct','X_Error_Status := '||X_Error_Status||' X_Error_Message :='||X_Error_Message);
                    IF NVL(X_Error_Status,'S') = 'E' THEN
                       Raise Erreur;
                    END IF;
            ------------End 9141 rprabu 11/08/2020
            END IF;
    END IF;
    Joshi:comment ends here 12279   */

   /*Create Bank Info ends here */
    -- Added by Joshi #12279
    -- Add bank details
   /* IF v_comp.bank_name IS NOT NULL AND  upper(v_comp.fees_payment_flag )= 'ACH' THEN   

        l_acct_usage :=  'INVOICE' ; 
        l_bank_count := 0 ;   
        IF UPPER(v_comp.acct_payment_fees)= 'EMPLOYER'  THEN
            l_entity_id := l_acc_id;
            l_entity_type := 'ACCOUNT';
        ELSIF UPPER(v_comp.acct_payment_fees) = 'BROKER'  THEN
            l_entity_id := pc_account.get_broker_id(l_acc_id);
            l_entity_type := 'BROKER';
        ELSIF UPPER( v_comp.acct_payment_fees) = 'GA'  THEN
            l_entity_id := pc_account.get_ga_id(l_acc_id);
            l_entity_type := 'GA';
        END IF;

        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_id: ',l_entity_id);
        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_entity_type',l_entity_type);
        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_acct_usage l',l_acct_usage);

        SELECT COUNT(*) INTO l_bank_count
           FROM bank_Accounts
         WHERE bank_routing_num = v_comp.routing_number
              AND bank_acct_num    = v_comp.bank_acc_num
              AND bank_name        = v_comp.bank_name  
              AND status           = 'A'
              AND entity_id        = l_entity_id
              AND bank_account_usage = l_acct_usage
              AND entity_type      = l_entity_type ;

        pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_count l',l_bank_count); 

        IF l_bank_count = 0 THEN 
            -- fee bank details      
            pc_user_bank_acct.insert_bank_account(
                             p_entity_id          => l_entity_id
                            ,p_entity_type        => l_entity_type
                            ,p_display_name       => v_comp.bank_name  
                            ,p_bank_acct_type     => v_comp.bank_acc_type 
                            ,p_bank_routing_num   => v_comp.routing_number 
                            ,p_bank_acct_num      => v_comp.bank_acc_num
                            ,p_bank_name          => v_comp.bank_name 
                            ,p_bank_account_usage => NVL(l_acct_usage,'INVOICE')
                            ,p_user_id            => p_user_id
                            ,x_bank_acct_id       => l_bank_id
                            ,x_return_status      => l_return_status 
                            ,x_error_message      => l_error_message);    

            pc_log.log_error('PC_EMPLOYER_ENROLL.create_cobra_plan l_bank_id l',l_bank_id);      
        END IF;
    END IF;
    */
	-- Added by Swamy for Ticket#12698
        if upper(v_comp.fees_payment_flag) = 'ACH' then
            l_bank_acct_num := null;
            l_bank_id := null;         
	  /*Create Bank Info */
            if p_source = 'ENROLLMENT' then
                lc_source := 'E';
            else
                lc_source := 'R';
            end if;

            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main.. calling populate_bank_Accounts', 'In Proc lc_source' || lc_source
            );
            pc_giact_validations.populate_bank_accounts(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_product_type  => 'ERISA_WRAP',
                p_user_id       => p_user_id,
                p_source        => lc_source,
                x_bank_acct_id  => l_bank_id,
                x_bank_status   => l_bank_status,
                x_return_status => l_return_status,
                x_error_message => l_error_message
            );

            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main.. after calling populate_bank_Accounts', 'In Proc l_bank_id'
                                                                                                              || l_bank_id
                                                                                                              || 'l_bank_status :='
                                                                                                              || l_bank_status
                                                                                                              || 'l_return_status :='
                                                                                                              || l_return_status
                                                                                                              || ' l_error_message :='
                                                                                                              || l_error_message);

            if l_return_status <> 'S' then
                raise erreur;
            end if;
            l_bank_acct_num := pc_user_bank_acct.get_bank_acct_num(l_bank_id);
            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main after calling populate_bank_Accounts **1', 'In Proc l_bank_acct_num'
                                                                                                                || l_bank_acct_num
                                                                                                                || ' v_comp.record_id :='
                                                                                                                || v_comp.record_id);

            update online_compliance_staging
            set
                bank_acct_id = l_bank_id,
                bank_acc_num = l_bank_acct_num
            where
                record_id = v_comp.record_id;

        end if;

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main  calling Pc_Utility.Insert_Notes', 'V_Aca.Special_Inst := '
                                                                                                    || v_aca.special_inst
                                                                                                    || ' X_Er_Ben_Plan_Id :='
                                                                                                    || x_er_ben_plan_id);

        pc_utility.insert_notes(
            p_entity_id     => x_er_ben_plan_id,
            p_entity_type   => 'BEN_PLAN_ENROLLMENT_SETUP',
            p_description   => v_aca.special_inst,
            p_user_id       => p_user_id,
            p_creation_date => sysdate,
            p_pers_id       => null,
            p_acc_id        => v_acc_id,
            p_entrp_id      => p_entrp_id,
            p_action        => 'SPECIAL_INSTRUCTIONS'
        );

        pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main after calling Pc_Utility.Insert_Notes', 'X_Error_Status := '
                                                                                                         || x_error_status
                                                                                                         || ' X_Error_Message :='
                                                                                                         || x_error_message);
        if nvl(x_error_status, 'S') = 'E' then
            raise erreur;
        end if;
        if nvl(x_error_status, 'S') = 'S' then
        /* Commented by Joshi for 10430

          UPDATE Account
             SET Complete_Flag    = 1
                ,account_status = 3    -- Added by Swamy for Tiket#9387
                ,Last_Update_Date = Sysdate
           WHERE Acc_Id = V_Acc_Id ; */

          -- Added by Joshi for 10430
            if l_inactive_plan_exist = 'I' then
                pc_employer_enroll_compliance.update_inactive_account(v_acc_id, p_user_id);
            else
                update account
                set
                    complete_flag = 1,
                    last_update_date = sysdate,
                    account_status = decode(l_bank_status, 'W', 11, 3)   -- Added by Swamy for Ticket#12698
                    ,
                    last_updated_by = p_user_id,
                    enrolled_date =
                        case
                            when enrolled_date is null then  -- Added by Joshi for 10431
                                sysdate
                            else
                                enrolled_date
                        end,
                    submit_by = p_user_id
                where
                    acc_id = v_acc_id;

            end if;
        end if;

---9392 rprabu 07/10/2020
        if l_enrolle_type = 'GA' then
            ---9392 rprabu 07/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'ERISA_WRAP',
                p_page_no       => '4',
                p_block_name    => 'AUTH_SIGN',
                p_validity      => 'V',
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            ---9392 rprabu 07/10/2020
            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => 'ERISA_WRAP',
                p_page_no       => '4',
                p_block_name    => 'AGREEMENT',
                p_validity      => 'V',
                p_user_id       => null,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        end if;

      -- Added by Jaggi for Ticket #11086

        pc_employer_enroll_compliance.update_acct_pref(p_batch_number, p_entrp_id);
        select
            nvl(broker_id, 0)
        into l_broker_id
        from
            table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

        if l_broker_id > 0 then
            l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_acc_id);
            pc_broker.create_broker_authorize(
                p_broker_id        => l_broker_id,
                p_acc_id           => l_acc_id,
                p_broker_user_id   => null,
                p_authorize_req_id => l_authorize_req_id,
                p_user_id          => p_user_id,
                x_error_status     => l_return_status,
                x_error_message    => l_error_message
            );

        end if;
        -- code ends here by Joshi.

        x_error_status := 'S';
    exception
        when erreur then
            rollback;
            x_error_status := 'E';
            x_error_message := x_error_message
                               || sqlcode
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main', 'Error '
                                                                       || x_error_message
                                                                       || ' := '
                                                                       || sqlerrm);
        when others then
            rollback;
            x_error_status := 'E';
            x_error_message := ' Error In Others Procedure Erisa_Stage_To_Main ' || sqlerrm(sqlcode);
            pc_log.log_error('PC_EMPLOYER_ENROLL.Erisa_Stage_To_Main',
                             'Others '
                             || dbms_utility.format_error_backtrace
                             || sqlerrm(sqlcode));

    end erisa_stage_to_main;

    procedure upsert_welfare_ben_plans (
        p_batch_number            in number,
        p_entrp_id                in number,
        p_collective_bargain_flag in varchar2,
        p_grandfathered           in varchar2,
        p_self_administered       in varchar2,
        p_subsidy_in_spd_apndx    in varchar2,
        p_clm_lang_in_spd         in varchar2,
        p_wrap_opt_flg            in varchar2,
        p_special_inst            in varchar2,
        p_user_id                 in number,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    ) is
        v_bar_flg  number := 0;
        v_comp_flg number := 0;
    begin
        select
            count(*)
        into v_bar_flg
        from
            erisa_aca_eligibility_stage
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        if nvl(v_bar_flg, 0) > 0 then
            update erisa_aca_eligibility_stage
            set
                collective_bargain_flag = p_collective_bargain_flag,
                special_inst = p_special_inst
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

        else
            insert into erisa_aca_eligibility_stage (
                batch_number,
                entrp_id,
                collective_bargain_flag,
                special_inst
            ) values ( p_batch_number,
                       p_entrp_id,
                       p_collective_bargain_flag,
                       p_special_inst );

        end if;

        update compliance_plan_staging
        set
            grandfathered = p_grandfathered,
            self_administered = p_self_administered,
            subsidy_in_spd_apndx = p_subsidy_in_spd_apndx,
            clm_lang_in_spd = p_clm_lang_in_spd,
            wrap_opt_flg = p_wrap_opt_flg
        where
                batch_number = p_batch_number
            and entity_id = p_entrp_id;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('Pc_Employer_Enroll.Upsert_Welfare_Ben_Plans', sqlerrm);
    end upsert_welfare_ben_plans;

    function get_welfare_ben_plans (
        p_batch_number in number,
        p_entrp_id     in number
    ) return tbl_welfare_ben_plans
        pipelined
    is
        rec rec_welfare_ben_plans;
    begin
        pc_log.log_error('Get_Welfare_Ben_Plans', 'P_Batch_Number'
                                                  || p_batch_number
                                                  || ' P_Entrp_Id :='
                                                  || p_entrp_id);
    -- There are two columns missing below, add later, check the excel mapping sheet
        for i in (
            select
                a.grandfathered,
                a.self_administered,
                a.subsidy_in_spd_apndx,
                a.clm_lang_in_spd,
                a.wrap_opt_flg,
                b.collective_bargain_flag,
                b.special_inst,
                a.erissa_erap_doc_type   -- Added by Swamy for Ticket#8684 on 19/05/2020
            from
                compliance_plan_staging     a,
                erisa_aca_eligibility_stage b
            where
                    a.batch_number = p_batch_number
                and a.entity_id = p_entrp_id
                and a.batch_number = b.batch_number
                and a.entity_id = b.entrp_id
        ) loop
            rec.grandfathered := i.grandfathered;
            rec.self_administered := i.self_administered;
            rec.subsidy_in_spd_apndx := i.subsidy_in_spd_apndx;
            rec.clm_lang_in_spd := i.clm_lang_in_spd;
            rec.wrap_opt_flg := i.wrap_opt_flg;
            rec.collective_bargain_flag := i.collective_bargain_flag;
            rec.special_inst := i.special_inst;
            rec.erisa_wrap_doc_type := i.erissa_erap_doc_type;   -- Added by Swamy for Ticket#8684 on 19/05/2020
            pipe row ( rec );
        end loop;

    end get_welfare_ben_plans;

    procedure plan_arrange_options (
        p_entrp_id             in number,
        p_plan_name            in varchar2,
        p_plan_number          in varchar2,
        p_plan_type            in varchar2,
        p_short_plan_yr_flag   in varchar2,
        p_plan_start_date      in varchar2,
        p_plan_end_date        in varchar2,
        p_org_eff_date         in varchar2,
        p_eff_date             in varchar2,
        p_user_id              in number,
        p_page_validity        in varchar2,
        p_batch_number         in number,
        p_plan_id              in number,
        p_flg_plan_name        in varchar2,
        p_flg_pre_adop_pln     in varchar2,
        p_erissa_wrap_doc_type in varchar2,
        x_er_ben_plan_id       out number,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    ) is
        l_count number;
    begin
        pc_log.log_error('Create_Pop_Plan_Staging', 'Loop' || p_plan_id);
        if p_plan_id is null then
      /* Insert */
            pc_log.log_error('create_POP_plan_staging..Count', l_count);
            pc_log.log_error('create_POP_plan_staging..Update', p_plan_end_date);
            pc_log.log_error('create_POP_plan_staging..length',
                             length(p_plan_end_date));
            insert into compliance_plan_staging (
                plan_id,
                entity_id,
                plan_name,
                plan_type,
                plan_number,
                plan_start_date,
                plan_end_date,
                short_plan_yr_flag,
                batch_number,
                flg_plan_name, -- Swamy Erisa
                flg_pre_adop_pln,
                erissa_erap_doc_type,-- Added by Joshi for 7791
                created_by,
                creation_date,
                last_updated_by,
                last_update_date
            ) values ( compliance_plan_seq.nextval,
                       p_entrp_id,
                       p_plan_name,
                       p_plan_type,
                       p_plan_number,
                       p_plan_start_date,
                       p_plan_end_date,
                       p_short_plan_yr_flag,
                       p_batch_number,
                       p_flg_plan_name, -- Swamy Erisa
                       p_flg_pre_adop_pln,
                       p_erissa_wrap_doc_type,  -- 7791
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate ) returning plan_id into x_er_ben_plan_id;

        else
      /* Update */
            pc_log.log_error('create_POP_plan_staging..Update', p_plan_start_date);
            update compliance_plan_staging
            set
                plan_name = p_plan_name,
                plan_number = p_plan_number,
                plan_type = p_plan_type,
                plan_start_date = p_plan_start_date,
                plan_end_date = p_plan_end_date,
                short_plan_yr_flag = p_short_plan_yr_flag,
                flg_plan_name = p_flg_plan_name, -- Swamy Erisa
                flg_pre_adop_pln = p_flg_pre_adop_pln,
                erissa_erap_doc_type = p_erissa_wrap_doc_type, -- 7791
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
                and plan_id = p_plan_id;

            x_er_ben_plan_id := p_plan_id;
            pc_log.log_error('Create_Pop_Plan_Staging..After Update', p_plan_start_date);
        end if;
    /* Insert/Update loop */
        pc_log.log_error('create_POP_plan_staging', 'After Insert');
    --Validating page# 2
        update online_compliance_staging
        set
            org_eff_date = p_org_eff_date,
            effective_date = p_eff_date,
            page1_plan = p_page_validity,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_number;

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_EMPLOYER_ENROLL.Plan_Arrange_Options', sqlerrm);
    end plan_arrange_options;

    procedure aca_eligibility (
        p_ben_plan_id                 in number,
        p_aca_ale_flag                in varchar2,
        p_variable_hour_flag          in varchar2,
        p_irs_lbm_flag                in varchar2,
        p_intl_msrmnt_period          in varchar2,
        p_intl_msrmnt_start_date      in varchar2,
        p_intl_admn_period            in varchar2,
        p_define_intl_msrmnt_period   in varchar2,
        p_stblty_period               in varchar2,
        p_fte_hrs                     in varchar2,
        p_fte_salary_msmrt_period     in varchar2,
        p_fte_hourly_msmrt_period     in varchar2,
        p_fte_other_msmrt_period      in varchar2,
        p_fte_other_ee_name           in varchar2,
        p_fte_look_back               in varchar2,
        p_fte_lkp_salary_msmrt_period in varchar2,
        p_fte_lkp_hourly_msmrt_period in varchar2,
        p_fte_lkp_other_msmrt_period  in varchar2,
        p_fte_lkp_other_ee_name       in varchar2,
        p_msrmnt_period               in varchar2,
        p_msrmnt_start_date           in varchar2,
        p_msrmnt_end_date             in varchar2,
        p_stblt_start_date            in varchar2,
        p_stblt_period                in varchar2,
        p_stblt_end_date              in varchar2,
        p_fte_same_period_resume_date in varchar2,
        p_fte_diff_period_resume_date in varchar2,
        p_fte_same_period_select      in varchar2,
        p_fte_diff_period_select      in varchar2,
        p_admn_start_date             in varchar2,
        p_admn_period                 in varchar2,
        p_admn_end_date               in varchar2,
        p_mnthl_msrmnt_flag           in varchar2,
        p_same_prd_bnft_start_date    in varchar2,
        p_new_prd_bnft_start_date     in varchar2,
        p_user_id                     in number,
        p_entrp_id                    in number,
        p_batch_number                in number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    ) is
        l_acc_id         number;
        v_count          number;
        v_eligibility_id number;
    begin
        select
            count(*)
        into v_count
        from
            erisa_aca_eligibility_stage
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        if nvl(v_count, 0) = 0 then
      --Delete From Erisa_Aca_Eligibility_Stage Where Batch_Number =  P_Batch_Number And Entrp_Id = P_Entrp_Id;
            select
                erisa_aca_seq.nextval
            into v_eligibility_id
            from
                dual;

            pc_log.log_error('pc_employer_enroll.Aca_Eligibility', 'In Proc');
            insert into erisa_aca_eligibility_stage (
                eligibility_id,
                ben_plan_id,
                batch_number,
                entrp_id,
                aca_ale_flag,
                variable_hour_flag,
                intl_msrmnt_period,
                intl_msrmnt_start_date,
                intl_admn_period,
                define_intl_msrmnt_period,
                stblty_period,
                msrmnt_start_date,
                msrmnt_period,
                msrmnt_end_date,
                admn_start_date,
                admn_period,
                admn_end_date,
                stblt_start_date,
                stblt_period,
                stblt_end_date,
                irs_lbm_flag,
                mnthl_msrmnt_flag,
                same_prd_bnft_start_date,
                new_prd_bnft_start_date,
                fte_hrs,
                fte_look_back,
                fte_salary_msmrt_period,
                fte_hourly_msmrt_period,
                fte_other_msmrt_period,
                fte_same_period_resume_date, -- Check With Gopy Date Field Going As Varchar2
                fte_diff_period_resume_date, -- Check With Gopy Date Field Going As Varchar2
                fte_lkp_salary_msmrt_period,
                fte_lkp_hourly_msmrt_period,
                fte_lkp_other_msmrt_period,
                fte_lkp_other_ee_detail,
                fte_other_ee_detail,
                fte_same_period_select,
                fte_diff_period_select,
                created_by,
                creation_date
            ) values ( v_eligibility_id,
                       p_ben_plan_id,
                       p_batch_number,
                       p_entrp_id,
                       p_aca_ale_flag,
                       p_variable_hour_flag,
                       p_intl_msrmnt_period,
                       p_intl_msrmnt_start_date,
                       p_intl_admn_period,
                       p_define_intl_msrmnt_period,
                       p_stblty_period,
                       p_msrmnt_start_date,
                       p_msrmnt_period,
                       p_msrmnt_end_date,
                       p_admn_start_date,
                       p_admn_period,
                       p_admn_end_date,
                       p_stblt_start_date,
                       p_stblt_period,
                       p_stblt_end_date,
                       p_irs_lbm_flag,
                       p_mnthl_msrmnt_flag,
                       p_same_prd_bnft_start_date,
                       p_new_prd_bnft_start_date,
                       p_fte_hrs,
                       p_fte_look_back,
                       p_fte_salary_msmrt_period,
                       p_fte_hourly_msmrt_period,
                       p_fte_other_msmrt_period,
                       p_fte_same_period_resume_date -- Check With Gopy Date Field Going As Varchar2
                       ,
                       p_fte_diff_period_resume_date -- Check With Gopy Date Field Going As Varchar2
                       ,
                       p_fte_lkp_salary_msmrt_period,
                       p_fte_lkp_hourly_msmrt_period,
                       p_fte_lkp_other_msmrt_period,
                       p_fte_lkp_other_ee_name,
                       p_fte_other_ee_name,
                       p_fte_same_period_select,
                       p_fte_diff_period_select,
                       p_user_id,
                       sysdate );

        else
            update erisa_aca_eligibility_stage
            set
                ben_plan_id = p_ben_plan_id,
                aca_ale_flag = p_aca_ale_flag,
                variable_hour_flag = p_variable_hour_flag,
                intl_msrmnt_period = p_intl_msrmnt_period,
                intl_msrmnt_start_date = p_intl_msrmnt_start_date,
                intl_admn_period = p_intl_admn_period,
                define_intl_msrmnt_period = p_define_intl_msrmnt_period,
                stblty_period = p_stblty_period,
                msrmnt_start_date = p_msrmnt_start_date,
                msrmnt_period = p_msrmnt_period,
                msrmnt_end_date = p_msrmnt_end_date,
                admn_start_date = p_admn_start_date,
                admn_period = p_admn_period,
                admn_end_date = p_admn_end_date,
                stblt_start_date = p_stblt_start_date,
                stblt_period = p_stblt_period,
                stblt_end_date = p_stblt_end_date,
                irs_lbm_flag = p_irs_lbm_flag,
                mnthl_msrmnt_flag = p_mnthl_msrmnt_flag,
                same_prd_bnft_start_date = p_same_prd_bnft_start_date,
                new_prd_bnft_start_date = p_new_prd_bnft_start_date,
                fte_hrs = p_fte_hrs,
                fte_look_back = p_fte_look_back,
                fte_salary_msmrt_period = p_fte_salary_msmrt_period,
                fte_hourly_msmrt_period = p_fte_hourly_msmrt_period,
                fte_other_msmrt_period = p_fte_other_msmrt_period,
                fte_same_period_resume_date = p_fte_same_period_resume_date,  -- Check With Gopy Date Field Going As Varchar2
                fte_diff_period_resume_date = p_fte_diff_period_resume_date, -- Check With Gopy Date Field Going As Varchar2
                fte_lkp_salary_msmrt_period = p_fte_lkp_salary_msmrt_period,
                fte_lkp_hourly_msmrt_period = p_fte_lkp_hourly_msmrt_period,
                fte_lkp_other_msmrt_period = p_fte_lkp_other_msmrt_period,
                fte_lkp_other_ee_detail = p_fte_lkp_other_ee_name,
                fte_other_ee_detail = p_fte_other_ee_name,
                fte_same_period_select = p_fte_same_period_select,
                fte_diff_period_select = p_fte_diff_period_select
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id;

        end if;

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('pc_employer_enroll.Aca_Eligibility', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end aca_eligibility;
--swamy erisa
    function get_aca_eligibility (
        p_batch_number in number,
        p_entrp_id     in number
    ) return tbl_aca_eligibility_stage
        pipelined
    is
        rec erisa_aca_eligibility_stage%rowtype;
    begin
    -- There Are Two Columns Missing Below, Add Later, Check The Excel Mapping Sheet
        for i in (
            select
                *
            from
                erisa_aca_eligibility_stage
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
        ) loop
            rec.eligibility_id := i.eligibility_id;
            rec.ben_plan_id := i.ben_plan_id;
            rec.aca_ale_flag := i.aca_ale_flag;
            rec.variable_hour_flag := i.variable_hour_flag;
            rec.intl_msrmnt_period := i.intl_msrmnt_period;
            rec.intl_msrmnt_start_date := i.intl_msrmnt_start_date;
            rec.intl_admn_period := i.intl_admn_period;
            rec.define_intl_msrmnt_period := i.define_intl_msrmnt_period;
            rec.stblty_period := i.stblty_period;
            rec.msrmnt_start_date := i.msrmnt_start_date;
            rec.msrmnt_period := i.msrmnt_period;
            rec.msrmnt_end_date := i.msrmnt_end_date;
            rec.admn_start_date := i.admn_start_date;
            rec.admn_period := i.admn_period;
            rec.admn_end_date := i.admn_end_date;
            rec.stblt_start_date := i.stblt_start_date;
            rec.stblt_period := i.stblt_period;
            rec.stblt_end_date := i.stblt_end_date;
            rec.irs_lbm_flag := i.irs_lbm_flag;
            rec.mnthl_msrmnt_flag := i.mnthl_msrmnt_flag;
            rec.same_prd_bnft_start_date := i.same_prd_bnft_start_date;
            rec.new_prd_bnft_start_date := i.new_prd_bnft_start_date;
            rec.fte_hrs := i.fte_hrs;
            rec.fte_look_back := i.fte_look_back;
            rec.fte_salary_msmrt_period := i.fte_salary_msmrt_period;
            rec.fte_hourly_msmrt_period := i.fte_hourly_msmrt_period;
            rec.fte_other_msmrt_period := i.fte_other_msmrt_period;
            rec.fte_same_period_resume_date := i.fte_same_period_resume_date;
            rec.fte_diff_period_resume_date := i.fte_diff_period_resume_date;
            rec.fte_lkp_salary_msmrt_period := i.fte_lkp_salary_msmrt_period;
            rec.fte_lkp_hourly_msmrt_period := i.fte_lkp_hourly_msmrt_period;
            rec.fte_lkp_other_msmrt_period := i.fte_lkp_other_msmrt_period;
            rec.fte_lkp_other_ee_detail := i.fte_lkp_other_ee_detail;
            rec.fte_other_ee_detail := i.fte_other_ee_detail;
            rec.fte_same_period_select := i.fte_same_period_select;
            rec.fte_diff_period_select := i.fte_diff_period_select;
            pipe row ( rec );
        end loop;
    end get_aca_eligibility;

    function get_plan_employer_contacts (
        p_batch_number in number,
        p_entrp_id     in number
    ) return tbl_plan_employer_contacts
        pipelined
    is
        rec plan_employer_contacts_stage%rowtype;
    begin
        for i in (
            select
                *
            from
                plan_employer_contacts_stage
            where
                    batch_number = p_batch_number
                and entity_id = p_entrp_id
        ) loop
            rec.plan_admin_name := i.plan_admin_name;
            rec.contact_type := i.contact_type;
            rec.contact_name := i.contact_name;
            rec.phone_num := i.phone_num;
            rec.email := i.email;
            rec.address1 := i.address1;
            rec.address2 := i.address2;
            rec.city := i.city;
            rec.state := i.state;
            rec.governing_state := i.governing_state; -- 7832 rprabu
            rec.zip_code := i.zip_code;
            rec.plan_agent := i.plan_agent;
            rec.description := i.description;
            rec.agent_name := i.agent_name;
            rec.legal_agent_contact := i.legal_agent_contact;
            rec.legal_agent_phone := i.legal_agent_phone;
            rec.legal_agent_email := i.legal_agent_email;
            rec.trust_fund := i.trust_fund;
            rec.record_id := i.record_id;
            rec.entity_id := i.entity_id;
            rec.batch_number := i.batch_number;
            rec.admin_type := i.admin_type;
            rec.trustee_name := i.trustee_name;
            rec.trustee_contact_type := i.trustee_contact_type;
            rec.trustee_contact_name := i.trustee_contact_name;
            rec.trustee_contact_phone := i.trustee_contact_phone;
            rec.trustee_contact_email := i.trustee_contact_email;
            rec.legal_agent_contact_type := i.legal_agent_contact_type;
            pipe row ( rec );
        end loop;
    end get_plan_employer_contacts;

    procedure upsert_page_validity (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_page_no       in varchar2,
        p_block_name    in varchar2,
        p_validity      in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        v_flg_exisits varchar2(1) := 'F';
    begin
        for j in (
            select
                1
            from
                page_validity
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and block_name = p_block_name
                and account_type = p_account_type
        ) loop
            update page_validity
            set
                validity = p_validity,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and block_name = p_block_name
                and account_type = p_account_type;

            v_flg_exisits := 'T';
        end loop;

        if v_flg_exisits = 'F' then
            insert into page_validity (
                batch_number,
                entrp_id,
                page_no,
                block_name,
                validity,
                account_type,
                created_by,
                creation_date
            ) values ( p_batch_number,
                       p_entrp_id,
                       p_page_no,
                       p_block_name,
                       p_validity,
                       p_account_type,
                       p_user_id,
                       sysdate );

        end if;

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('pc_employer_enroll.Upsert_Page_Validity', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end upsert_page_validity;

    function get_page_validity (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2
    ) return varchar2 is
        v_page_no varchar2(1) := 'V';
    begin
        for j in (
            select
                page_no
            from
                page_validity
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and account_type = p_account_type
                and validity = 'I'
            order by
                page_no
        ) loop
            v_page_no := j.page_no;
            exit;
        end loop;

        return v_page_no;
    end get_page_validity;
--- added by rprabu on 22/08/2018 for 6346
    function get_page_validity_details (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2
    ) return page_validity_record_t
        pipelined
        deterministic
    is
        l_count  number;
        l_record page_validity_row_t;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Get_Page_Validity_details EIN', 'P_Entrp_Id# ' || p_entrp_id);
        for j in (
            select
                page_no,
                upper(block_name) block_name,
                validity
            from
                page_validity
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and account_type = p_account_type
                and validity = 'I'
            order by
                page_no
        ) loop
            l_record.page_no := j.page_no;
            l_record.block_name := j.block_name;
            l_record.validity := j.validity;
            pipe row ( l_record );
        end loop;

    end get_page_validity_details;
--- added by rprabu on 06/10/2020  for Ticket#9392
    function get_ga_er_details (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2
    ) return page_validity_record_t
        pipelined
        deterministic
    is

        l_count            number;
        l_summary_validity varchar2(1) := 'V';
        l_record           page_validity_row_t;
        l_last_page        number := 0;
        l_loop_counter     number := 0;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Get_Page_Validity_details EIN', 'P_Entrp_Id# ' || p_entrp_id);
        for j in (
            select
                page_no,
                upper(block_name) block_name,
                validity
            from
                page_validity
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and account_type = p_account_type
            order by
                page_no
        ) loop
            l_record.page_no := j.page_no;
            l_record.block_name := j.block_name;
            l_record.validity := j.validity;
            l_last_page := j.page_no;
            if
                j.validity = 'I'
                and l_record.block_name not in ( 'AUTH_SIGN', 'AGREEMENT' )
            then
                l_summary_validity := 'I';
            elsif
                j.validity = 'V'
                and l_record.block_name not in ( 'AUTH_SIGN', 'AGREEMENT' )
            then
                l_loop_counter := l_loop_counter + 1;
            end if;

            pipe row ( l_record );
        end loop;

        l_record.page_no := l_last_page + 1;
        l_record.block_name := 'SUMMARY';
        if l_summary_validity = 'I' then
            l_record.validity := 'I';
        elsif
            l_loop_counter < 6
            and p_account_type = 'POP'
        then
            l_record.validity := 'I';
        elsif
            l_loop_counter < 9
            and p_account_type = 'ERISA_WRAP'
        then
            l_record.validity := 'I';
        elsif
            l_loop_counter < 5
            and p_account_type = 'COBRA'
        then
            l_record.validity := 'I';
        else
            l_record.validity := 'V';
        end if;

        pipe row ( l_record );
    end get_ga_er_details;  --- END  by rprabu on 06/10/2020  for Ticket#9392
-------------------------------------------------------------------
    function get_tot_eligible_emp (
        p_batch_number in number
    ) return tbl_tot_eligible_emp
        pipelined
    is
        rec rec_tot_eligible_emp;
    begin
        for j in (
            select
                a.rate_plan_detail_id,
                a.line_list_price,
                b.coverage_type
            from
                ar_quote_lines_staging a,
                rate_plan_detail       b
            where
                    a.batch_number = p_batch_number
                and a.rate_plan_id = b.rate_plan_id
                and a.rate_plan_detail_id = b.rate_plan_detail_id
            order by
                coverage_type desc
        ) loop
            rec.rate_plan_detail_id := j.rate_plan_detail_id;
            rec.line_list_price := j.line_list_price;
            rec.coverage_type := j.coverage_type;
            pipe row ( rec );
        end loop;
    end get_tot_eligible_emp;
/***************************************************/
-- End Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
----Get_User_Bank_acct_Staging  added by rprabu on 08/10/2018  Ticket 6346
-- Added p_Account_type by Joshi.
    function get_user_bank_acct_staging (
        p_batch_number          in number,
        p_entrp_id              in number,
        p_user_bank_acct_stg_id in number,
        p_account_type          in varchar2,
        p_annual_optional_remit in varchar2   -- Added by Swamy for Ticket#12534
--      p_user_id               IN NUMBER   --10747new
    ) return tbl_user_bank_acct_staging
        pipelined
    is
        rec           user_bank_acct_staging%rowtype;
        l_entity_type varchar2(100);
        l_broker_id   number;
    begin
-- Commented by by Jaggi ##11360
/*     pc_broker.get_broker_id (p_user_id     => p_user_id ,  --10747new
                                p_entity_type => l_entity_type,
                                p_broker_id   => l_broker_id);

    l_entity_type := NVL(l_entity_type,'EMPLOYER');  --10747new
*/
        for i in (
            select
                *
            from
                user_bank_acct_staging
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and user_bank_acct_stg_id = nvl(p_user_bank_acct_stg_id, user_bank_acct_stg_id)
                and account_type = p_account_type
                and nvl(annual_optional_remit, '*') = nvl(p_annual_optional_remit, '*')   -- Added by Swamy for Ticket#12534
--      AND NVL(RENEWED_BY,'EMPLOYER') = l_entity_type   -- 10747new
            order by
                user_bank_acct_stg_id desc
        ) loop
            rec.user_bank_acct_stg_id := i.user_bank_acct_stg_id;
            rec.entrp_id := i.entrp_id;
            rec.batch_number := i.batch_number;
            rec.account_type := i.account_type;
            rec.acct_usage := i.acct_usage;
            rec.display_name := i.display_name;
            rec.bank_acct_type := i.bank_acct_type;
            rec.bank_routing_num := i.bank_routing_num;
            rec.bank_acct_num := i.bank_acct_num;
            rec.bank_name := i.bank_name;
            rec.validity := i.validity;
            rec.bank_authorize := i.bank_authorize;   -- Added by Jaggi ##9602
            rec.created_by := i.created_by;       -- Added by Jaggi ##11360
            rec.renewed_by := i.renewed_by;       -- Added by Jaggi ##11360
            pipe row ( rec );
        end loop;
    end get_user_bank_acct_staging;
----Delete_bank_info added by rprabu on 08/10/2018  Ticket 6346
    procedure delete_bank_info (
        p_user_bank_acct_stg_id in number,
        p_entrp_id              in number,
        p_batch_number          in number,
        p_account_type          in varchar2,
        p_acct_usage            in varchar2,    -- Added by Jaggi #11263
        x_error_status          out varchar2,
        x_error_message         out varchar2
    ) is
    begin
        delete user_bank_acct_staging
        where
                entrp_id = p_entrp_id
            and user_bank_acct_stg_id = nvl(p_user_bank_acct_stg_id, user_bank_acct_stg_id)
            and batch_number = p_batch_number
            and account_type = p_account_type
            and acct_usage = p_acct_usage;  -- Added by Jaggi #11263;
    exception
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_EMPLOYER_ENROLL.Delete_bank_info', 'Error ' || sqlerrm);
    end delete_bank_info;
----Upsert_Bank_Info added by rprabu on 08/10/2018 Ticket 6346
 ----Upsert_Bank_Info added by rprabu on 08/10/2018 Ticket 6346
    procedure upsert_bank_info (
        p_user_bank_acct_stg_id in number,
        p_entrp_id              in number,
        p_batch_number          in number,
        p_account_type          in varchar2,
        p_acct_usage            in varchar2,
        p_display_name          in varchar2,
        p_bank_acct_type        in varchar2,
        p_bank_routing_num      in varchar2,     --Changed from number to varchar2 by Swamy for Production issue (Bank account no and routing no leading zero is not saving. Date 22/04/2022)
        p_bank_acct_num         in varchar2,     --Changed from number to varchar2 by Swamy for Production issue (Bank account no and routing no leading zero is not saving. Date 22/04/2022)
        p_bank_name             in varchar2,
        p_user_id               in number,
        p_validity              in varchar2,
        p_bank_authorize        in varchar2,              -- Added by Jaggi ##9602
        p_giac_response         in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verify           in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_authenticate     in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_acct_verified    in varchar2,   -- Added by Swamy for Ticket#12309 
        p_business_name         in varchar2,   -- Added by Swamy for Ticket#12309 
        p_annual_optional_remit in varchar2,   -- Added by Swamy for Ticket#12534 
        p_existing_bank_flag    in varchar2,     -- Added by Swamy for Ticket#12534
        p_bank_acct_id          in number,     -- Added by Swamy for Ticket#12534(12624)
        x_user_bank_acct_stg_id out number,
        x_bank_status           out varchar2,    -- Added by Swamy for Ticket#12534 
        x_error_status          out varchar2,
        x_error_message         out varchar2
    ) is

        l_user_bank_acct_stg_id number;
        l_page_validity         varchar2(1);
        l_page_no               number(5) := null;
        l_bank_exist            number; /*Ticket#7017 */
        setup_error exception;/*Ticket#7017 */
        l_bank_acct_usage       varchar2(100);         -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        l_entity_type           varchar2(100);        -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        l_broker_id             number;
        l_giact_verify          varchar2(50);   -- Added by Swamy for Ticket#12309 
        l_bank_status           varchar2(1);    -- Added by Swamy for Ticket#12309 
        l_error_message         varchar2(500);  -- Added by Swamy for Ticket#12534 
        l_error_status          varchar2(500);  -- Added by Swamy for Ticket#12534 
        l_bank_error exception;
    begin
        x_error_status := 'S';
        pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_Bank_Info..', 'In Proc ' || p_user_bank_acct_stg_id);
        pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_Bank_Info..', 'Conatct Info P_Account_Type '
                                                                  || p_account_type
                                                                  || ' P_acct_usage :='
                                                                  || p_acct_usage);
        if
            nvl(p_giac_verify, '*') <> '*'
            and nvl(p_existing_bank_flag, 'N') = 'N'
        then    -- Added by Swamy for Ticket#12534   -- Added by Swamy for Ticket#12309 
            pc_user_bank_acct.validate_giact_response(
                p_gverify       => p_giac_verify,
                p_gauthenticate => p_giac_authenticate,
                x_giact_verify  => l_giact_verify,
                x_bank_status   => l_bank_status,
                x_return_status => l_error_status,
                x_error_message => l_error_message  -- Added by Swamy for Ticket#12534 
            );

            pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_Bank_Info..', 'Conatct Info l_giact_verify '
                                                                      || l_giact_verify
                                                                      || 'l_bank_status :='
                                                                      || l_bank_status
                                                                      || ' X_ERROR_STATUS :='
                                                                      || x_error_status
                                                                      || ' x_error_message :='
                                                                      || x_error_message);  -- Added by Swamy for Ticket#12309

            if l_giact_verify = 'R' then
                x_bank_status := l_bank_status;  -- Added by Swamy for Ticket#12534 
                raise l_bank_error;
            end if;
        elsif nvl(p_existing_bank_flag, 'N') = 'Y' then    -- Added by Swamy for Ticket#12534
            l_bank_status := 'A';
            l_giact_verify := 'V'; -- Added by Swamy for Ticket#12542
            l_error_message := 'Your bank account has been created successfully!';
        end if;

    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        pc_broker.get_broker_id(
            p_user_id     => p_user_id,
            p_entity_type => l_entity_type,
            p_broker_id   => l_broker_id
        );

        pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_Bank_Info..', 'Conatct Info p_user_id '
                                                                  || p_user_id
                                                                  || 'l_entity_type :='
                                                                  || l_entity_type
                                                                  || ' l_broker_id :='
                                                                  || l_broker_id);  -- Added by Swamy for Ticket#12309

        l_entity_type := nvl(l_entity_type, 'EMPLOYER');
        pc_log.log_error('PC_EMPLOYER_ENROLL.Upsert_Bank_Info..', 'Conatct Info l_entity_type  '
                                                                  || l_entity_type
                                                                  || ' P_User_Bank_acct_stg_Id :='
                                                                  || p_user_bank_acct_stg_id
                                                                  || ' P_acct_usage :='
                                                                  || p_acct_usage);

        if p_user_bank_acct_stg_id is not null then
            select
                acct_usage
            into l_bank_acct_usage
            from
                user_bank_acct_staging
            where
                user_bank_acct_stg_id = p_user_bank_acct_stg_id;

            if l_bank_acct_usage = p_acct_usage then
                update user_bank_acct_staging
                set
                    acct_usage = p_acct_usage,
                    display_name = p_display_name,
                    bank_acct_type = p_bank_acct_type,
                    bank_routing_num = p_bank_routing_num,
                    bank_name = p_bank_name,
                    bank_acct_num = p_bank_acct_num,
                    validity = p_validity,
                    bank_authorize = p_bank_authorize,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate,
                    giac_response = p_giac_response,   -- Added by Swamy for Ticket#12309 
                    giac_verify = p_giac_verify,   -- Added by Swamy for Ticket#12309 
                    giac_authenticate = p_giac_authenticate,   -- Added by Swamy for Ticket#12309 
                    bank_acct_verified = p_bank_acct_verified,   -- Added by Swamy for Ticket#12309 
                    business_name = p_business_name,   -- Added by Swamy for Ticket#12309      
                    bank_status = l_bank_status,      -- Added by Swamy for Ticket#12309  
                    giac_verified_response = l_giact_verify,      -- Added by Swamy for Ticket#12309  
                    bank_acct_id = p_bank_acct_id        -- Added by Swamy for Ticket#12534(12624) 
                where
                    user_bank_acct_stg_id = p_user_bank_acct_stg_id;

            else
             -- Commented by Swamy as the below validation is no longer required Ticket#12620
             /* SELECT count(*)
              INTO l_bank_exist
              FROM User_Bank_acct_Staging
              WHERE entrp_id = p_entrp_id
              and Acct_usage = p_acct_usage
              AND batch_number = P_Batch_Number   -- Added by Swamy for Ticket#12543
              and nvl(renewed_by,'EMPLOYER') = l_entity_type;   -- Added by Swamy for Ticket#10993(Dev Ticket#10747)

             --Ticket#7017 
             IF L_BANK_EXIST >  0 THEN
                   X_ERROR_STATUS := 'E';
                   x_error_message := 'One account usage option cannot be selected for multiple bank accounts.';
                   l_page_validity := 'I';
                   RAISE setup_error ;
             ELSE*/
                update user_bank_acct_staging
                set
                    acct_usage = p_acct_usage,
                    display_name = p_display_name,
                    bank_acct_type = p_bank_acct_type,
                    bank_routing_num = p_bank_routing_num,
                    bank_name = p_bank_name,
                    bank_acct_num = p_bank_acct_num,
                    validity = p_validity,
                    bank_authorize = p_bank_authorize,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate,
                    giac_response = p_giac_response,   -- Added by Swamy for Ticket#12309 
                    giac_verify = p_giac_verify,   -- Added by Swamy for Ticket#12309 
                    giac_authenticate = p_giac_authenticate,   -- Added by Swamy for Ticket#12309 
                    bank_acct_verified = p_bank_acct_verified,   -- Added by Swamy for Ticket#12309 
                    business_name = p_business_name,   -- Added by Swamy for Ticket#12309        
                    bank_status = l_bank_status,      -- Added by Swamy for Ticket#12309  
                    giac_verified_response = l_giact_verify,      -- Added by Swamy for Ticket#12309  
                    bank_acct_id = p_bank_acct_id        -- Added by Swamy for Ticket#12534(12624) 
                where
                    user_bank_acct_stg_id = p_user_bank_acct_stg_id;
            --END IF ;
            end if;

        else /*Insert Loop */
            select
                user_bank_acct_stg_seq.nextval
            into l_user_bank_acct_stg_id
            from
                dual;

     -- Commented by Swamy as the below validation is no longer required Ticket#12620
         /*Ticket#7017 */
     /* SELECT count(*)
      INTO l_bank_exist
      FROM User_Bank_acct_Staging
      WHERE entrp_id = p_entrp_id
      and Acct_usage = p_acct_usage
      AND batch_number = P_Batch_Number   -- Added by Swamy for Ticket#12543
      and nvl(renewed_by,'EMPLOYER') = l_entity_type;   -- Added by Swamy for Ticket#10993(Dev Ticket#10747)

    --Ticket#7017 
     IF L_BANK_EXIST >  0 THEN
           X_ERROR_STATUS := 'E';
           x_error_message := 'One account usage option cannot be selected for multiple bank accounts.';
           l_page_validity := 'I';
           RAISE setup_error ;
      END IF ;
      */
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
                renewed_by,     -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
                giac_response,       -- Start Added by Swamy for Ticket#12309
                giac_verify,
                giac_authenticate,
                bank_acct_verified,
                bank_status,
                business_name,
                giac_verified_response,  -- End Added by Swamy for Ticket#12309 
                annual_optional_remit,      -- Added by Swamy for Ticket#12534
                bank_acct_id                 -- Added by Swamy for Ticket#12534(12624) 
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
                       l_entity_type,       -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
                       p_giac_response,       -- Start Added by Swamy for Ticket#12309
                       p_giac_verify,
                       p_giac_authenticate,
                       p_bank_acct_verified,
                       l_bank_status,
                       p_business_name,
                       l_giact_verify,  -- End Added by Swamy for Ticket#12309
                       p_annual_optional_remit,  -- Added by Swamy for Ticket#12534 
                       p_bank_acct_id          -- Added by Swamy for Ticket#12534(12624) 
                        );

        end if;

        x_user_bank_acct_stg_id := l_user_bank_acct_stg_id;
        x_bank_status := l_bank_status;    -- Added by Swamy for Ticket#12534
        x_error_message := nvl(l_error_message, x_error_message);  -- Added by Swamy for Ticket#12534
        x_error_status := nvl(l_error_status, x_error_status);
    -- Moved the below code to procedure FSA_HRA_ENROLL_upsert_page_validity which will be directly called from PHP by Swamy for Ticket#12309
   /* l_page_validity     := NULL;
      IF P_ACCOUNT_TYPE IN ( 'FSA' , 'HRA') THEN -- IF  added by rprabu on 08/08/2018 for the tickets 6346 and 6377
      -- for loop added by rprabu on 09/08/2018 Ticket 6346
      FOR I IN
      (SELECT DECODE( COUNT(User_Bank_acct_stg_Id),0, 'V', 'I') page_validity
         FROM User_Bank_acct_Staging
        WHERE Entrp_Id   = P_ENTRP_ID
          AND Account_Type = P_ACCOUNT_TYPE
          AND validity     = 'I'
      )
      LOOP
        l_page_validity := i.page_validity;
      END LOOP;
      --- added by rprabu for contact page issue on 27/07/2018 ticket 6346
      IF P_Account_Type    = 'FSA' THEN
        l_page_no         :=3;
      Elsif P_Account_Type = 'HRA' THEN
        l_page_no         :=4;
      END IF;
      Pc_Employer_Enroll.upsert_page_validity(
			  p_batch_number => P_Batch_Number, p_entrp_id => p_entrp_id,
			  p_Account_Type => P_ACCOUNT_TYPE, p_page_no => l_page_no,
			  p_block_name   => 'INVOICING_PAYMENT', p_validity => l_page_validity,
			  p_user_id      => P_USER_ID, x_ERROR_STATUS => X_ERROR_STATUS, x_ERROR_MESSAGE => x_ERROR_MESSAGE ) ;
    END IF;
    X_ERROR_STATUS := 'S';
    */
    exception
       /*Ticket#7071 */
        when setup_error then
            x_error_status := 'E';
            pc_log.log_error('Upsert_Bank_Info setup_error Upsert Bank Acct', x_error_message);
        when l_bank_error then
            x_error_status := 'E';    -- Added by Swamy for Ticket#12534 
            x_error_message := l_error_message;   -- Added by Swamy for Ticket#12534 
            pc_log.log_error('Upsert_Bank_Info l_bank_error Upsert Bank Acct', x_error_message);
        when others then
            x_error_message := sqlcode
                               || ' '
                               || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('Upsert_Bank_Info OTHERS PC_EMPLOYER_ENROLL.Upsert_Bank_Info', 'Error ' || sqlerrm);
    end upsert_bank_info;
   /*Created for ticket#7016 on 21/11/2018 */
    procedure update_hsa_staging (
        p_entrp_id      in number,
        p_peo_ein       in number,
        p_peo_flag      in varchar2,
        p_salesrep_flag in varchar2,
        p_salesrep_id   in number,
        p_user_id       in number,
        p_batch_num     in number,
        p_page_validity in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_acc_id        number;
        l_return_status varchar2(100);
        l_error_message varchar2(1000);
        l_exist         number;
        l_acc_num       varchar2(100);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.Update HSA Staging', 'In Procedure');
        pc_log.log_error('PC_EMPLOYER_ENROLL.Update HSA Staging', p_entrp_id);
        pc_log.log_error('PC_EMPLOYER_ENROLL.Update HSA Staging', p_batch_num);
        select
            count(*)
        into l_exist
        from
            employer_online_enrollment
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_num;

        for j in (
            select
                acc_num
            from
                account
            where
                entrp_id = p_entrp_id
        ) loop
            l_acc_num := j.acc_num;
        end loop;

        if l_exist > 0 then
            update employer_online_enrollment
            set
                peo_ein = p_peo_ein,
                salesrep_id = p_salesrep_id,
                peo_flag = p_peo_flag,
                salesrep_flag = p_salesrep_flag,
                last_updated_by = p_user_id /*Ticket#6834 */
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_num;

        else /* For Old accts with NULL BATCH NUMBER */

       -- Added by Swamy for Ticket#11790 30/10/2023
            insert into employer_online_enrollment (
                enrollment_id,
                entrp_id,
                acc_num,
                peo_ein,
                salesrep_id,
                peo_flag,
                salesrep_flag,
                batch_number,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date
            ) values ( mass_enrollments_seq.nextval,
                       p_entrp_id,
                       l_acc_num,
                       p_peo_ein,
                       p_salesrep_id,
                       p_peo_flag,
                       p_salesrep_flag,
                       p_batch_num,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       sysdate );

       --Commented Swamy for Ticket#11790 30/10/2023
	   /*UPDATE EMPLOYER_ONLINE_ENROLLMENT
        SET
            peo_ein             = p_peo_ein ,
            salesrep_id        = p_salesrep_id,
            peo_flag       = p_peo_flag,
            salesrep_flag = p_salesrep_flag,
            batch_number = p_batch_num,
             last_updated_by   = p_user_id --Ticket#6834
        WHERE entrp_id        = p_entrp_id;*/

        end if;

        upsert_page_validity(p_batch_num, p_entrp_id, 'HSA', 1, 'HSA_COMPANY_INFO',
                             p_page_validity, p_user_id, x_error_status, x_error_message);

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HSA_STAGING', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end update_hsa_staging;

  /*Created for ticket#7016 on 21/11/2018 */
    procedure update_hsa_plan_staging (
        p_entrp_id           in number,
        p_plan_code          in number,
        p_mon_fees_paid_by   in varchar2,
        p_ann_fees_paid_by   in varchar2,
        p_debit_card_allowed in varchar2,
        p_user_id            in number,
        p_subscribe_to_acn   in varchar2,
        p_batch_num          in number,
        p_page_validity      in varchar2,
        x_error_status       out varchar2,
        x_error_message      out varchar2
    ) is
        l_acc_id        number;
        l_return_status varchar2(100);
        l_error_message varchar2(1000);
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HSA_PLAN_STAGING', 'In Procedure');
        update employer_online_enrollment
        set
            maint_fee_paid_by = p_mon_fees_paid_by,
            setup_fee_paid_by = p_ann_fees_paid_by,
            plan_code = p_plan_code,
            subscribe_to_acn = p_subscribe_to_acn,
            debit_card_allowed = p_debit_card_allowed,
            last_updated_by = p_user_id /*Ticket#6834 */
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_num;

        upsert_page_validity(p_batch_num, p_entrp_id, 'HSA', 1, 'HSA_PLAN_INFO',
                             p_page_validity, p_user_id, x_error_status, x_error_message);

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HSA_PLAN_STAGING', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end update_hsa_plan_staging;

  /*Created for Ticket#7016 */
    function get_hsa_info (
        p_entrp_id     in number,
        p_batch_number in number
    ) return er_hsa_info_t
        pipelined
        deterministic
    is
        l_record er_hsa_info;
        l_cnt    number := 0;
    begin
        for y in (
            select
                count(*) cnt
            from
                page_validity
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_cnt := y.cnt;
        end loop;

        for x in (
            select
                peo_flag,
                peo_ein,
                salesrep_flag,
                salesrep_id,
                case
                    when l_cnt = 0 then
                        null
                    else
                        plan_code
                end plan_code,
                maint_fee_paid_by,
                setup_fee_paid_by,
                debit_card_allowed,
                subscribe_to_acn,
                no_of_eligible,
                total_no_of_ee	-- Added by Swamy for Ticket#7610
            from
                employer_online_enrollment
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_record.peo := x.peo_flag;
            l_record.peo_tax_id := x.peo_ein;
            l_record.salesrep_id := x.salesrep_id;
            l_record.salesrep_flag := x.salesrep_flag;
            l_record.salesrep_name := pc_account.get_salesrep_name(x.salesrep_id);
            l_record.plan_code := x.plan_code;
            l_record.maint_fee_paid_by := x.maint_fee_paid_by;
            l_record.debit_card_allowed := x.debit_card_allowed;
            l_record.setup_fee_paid_by := x.setup_fee_paid_by;
            l_record.subscribe_to_acn := x.subscribe_to_acn;
            l_record.total_no_of_ee := x.total_no_of_ee;     -- Added by Swamy for Ticket#7610
            l_record.no_of_eligible := x.no_of_eligible;     -- Added by Swamy for Ticket#7610

            pipe row ( l_record );
        end loop;

    end get_hsa_info;
  /*Ticket#7016 */
    procedure create_hsa_plan (
        p_entrp_id      in number,
        p_batch_num     in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_acc_id           number;
        l_return_status    varchar2(100);
        l_error_message    varchar2(1000);
        l_resubmit_flag    varchar2(1);
        l_renewed_by       varchar2(30);
        l_broker_id        number;
        l_authorize_req_id number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_HSA_PLAN', 'In Procedure');
        select
            acc_id,
            nvl(resubmit_flag, 'N') resubmit_flag
        into
            l_acc_id,
            l_resubmit_flag
        from
            account
        where
            entrp_id = p_entrp_id;

        for x in (
            select
                *
            from
                employer_online_enrollment
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_num
        ) loop
            if x.peo_ein is not null then
                insert into entrp_relationships (
                    relationship_id,
                    entrp_id,
                    tax_id,
                    entity_id,
                    entity_type,
                    relationship_type,
                    start_date,
                    status,
                    note,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( entrp_relationship_seq.nextval,
                           x.entrp_id,
                           x.ein_number,
                           x.peo_ein,
                           'PEO',
                           'PEO_ER',
                           sysdate,
                           'A',
                           'Online Enrollment',
                           sysdate,
                           1,
                           sysdate,
                           1 );

            end if;

            update enterprise
            set
                card_allowed = x.debit_card_allowed,
                no_of_eligible = x.no_of_eligible,     -- Added by Swamy for Ticket#7610
                no_of_ees = x.total_no_of_ee      -- Added by Swamy for Ticket#7610
            where
                entrp_id = x.entrp_id;

  -- Added below insert statement by Swamy for Ticket#7610
            if nvl(x.total_no_of_ee, 0) <> 0 then
                insert into enterprise_census (
                    entity_id,
                    entity_type,
                    census_code,
                    census_numbers,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    ben_plan_id
                ) values ( p_entrp_id,
                           'ENTERPRISE',
                           'NO_OF_EMPLOYEES',
                           x.total_no_of_ee,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           null );

            end if;

            if nvl(x.no_of_eligible, 0) <> 0 then
                insert into enterprise_census (
                    entity_id,
                    entity_type,
                    census_code,
                    census_numbers,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    ben_plan_id
                ) values ( p_entrp_id,
                           'ENTERPRISE',
                           'NO_OF_ELIGIBLE',
                           x.no_of_eligible,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           null );

            end if;

  -- End of Addition by Swamy for Ticket#7610

            if x.salesrep_id is not null then
                update account
                set
                    salesrep_id = x.salesrep_id
                where
                    entrp_id = p_entrp_id;

                pc_employer_enroll.create_salesrep(
                    p_entrp_id      => x.entrp_id,
                    p_salesrep_id   => x.salesrep_id,
                    p_user_id       => null,
                    x_error_status  => l_return_status,
                    x_error_message => l_error_message
                );

            end if;

            if x.maint_fee_paid_by in ( 2, 1 ) then --Employer/employee will cover
        -- Joshi 5363 setup fee should be 0 for e-HSA plan.
                update account
                set
                    fee_maint = pc_plan.fmonth(x.plan_code),
                    plan_code = x.plan_code,
                    fee_setup =
                        case
                            when x.plan_code = 8 then
                                0
                            else
                                fee_setup
                        end
                where
                    entrp_id = x.entrp_id;

        --Update Account Preference Table
                pc_account.upsert_acc_pref(
                    p_entrp_id               => p_entrp_id,
                    p_acc_id                 => l_acc_id,
                    p_claim_pay_method       => null,
                    p_auto_pay               => null,
                    p_plan_doc_only          => null,
                    p_status                 => 'A',
                    p_allow_eob              => 'Y',
                    p_user_id                => p_user_id,
                    p_pin_mailer             => 'N',
                    p_teamster_group         => 'N',
                    p_allow_exp_enroll       => 'Y',
                    p_maint_fee_paid         => x.maint_fee_paid_by,
                    p_allow_online_renewal   => 'N',
                    p_allow_election_changes => 'N',
                    p_plan_action_flg        => 'Y',
                    p_submit_election_change => 'Y',
                    p_edi_flag               => 'N',
                    p_vendor_id              => null,
                    p_reference_flag         => null,
                    p_allow_payroll_edi      => null,
                    p_fees_paid_by           => null    -- Added by Swamy for Ticket#11037
                );

            end if;

            if x.setup_fee_paid_by in ( 2, 1 ) then --Employer/employee will cover
                update account
                set
                    fee_maint = pc_plan.fannual(x.plan_code),
                    plan_code = x.plan_code
          --Setup fee should not be charged for new plans
                    ,
                    fee_setup =
                        case
                            when x.plan_code in ( 5, 6, 7 ) then
                                0
                            else
                                fee_setup
                        end
                where
                    entrp_id = x.entrp_id;

        --Account Preference Table
                pc_account.upsert_acc_pref(
                    p_entrp_id               => p_entrp_id,
                    p_acc_id                 => l_acc_id,
                    p_claim_pay_method       => null,
                    p_auto_pay               => null,
                    p_plan_doc_only          => null,
                    p_status                 => 'A',
                    p_allow_eob              => 'Y',
                    p_user_id                => p_user_id,
                    p_pin_mailer             => 'N',
                    p_teamster_group         => 'N',
                    p_allow_exp_enroll       => 'Y',
                    p_maint_fee_paid         => x.setup_fee_paid_by,
                    p_allow_online_renewal   => 'N',
                    p_allow_election_changes => 'N',
                    p_plan_action_flg        => 'Y',
                    p_submit_election_change => 'Y',
                    p_edi_flag               => 'N',
                    p_vendor_id              => null,
                    p_reference_flag         => null,
                    p_allow_payroll_edi      => null,
                    p_fees_paid_by           => null    -- Added by Swamy for Ticket#11037
                );

            end if;

           -- Swamy for sso
            update account_preference
            set
                subscribe_to_acn = nvl(x.subscribe_to_acn, 'N')
            where
                acc_id = l_acc_id;

        end loop;
    /*Update Contact Info */
    -- Added by Joshi for 10430. need to delete existing contacts and reinsert as in case of resubmit
    -- user might update existing  contacts.
        for c in (
            select
                contact_id
            from
                contact_leads
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and account_type = 'HSA'
                and ref_entity_type = 'ONLINE_ENROLLMENT'
        ) loop
            delete from contact
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and contact_id = c.contact_id;

            delete from contact_role
            where
                contact_id = c.contact_id;

        end loop;
      -- code end here --
        for x in (
            select
                *
            from
                contact_leads
            where
                    entity_id = pc_entrp.get_tax_id(p_entrp_id)
                and account_type = 'HSA'
        ) loop
            update_contact_info(
                p_contact_id      => x.contact_id,
                p_entrp_id        => p_entrp_id,
                p_first_name      => x.first_name,
                p_email           => x.email,
                p_account_type    => 'HSA',
                p_contact_type    => x.contact_type,
                p_user_id         => p_user_id,
                p_ref_entity_id   => null,
                p_ref_entity_type => null,
                p_send_invoice    => x.send_invoice,
                p_status          => 'A',
                p_phone_num       => x.phone_num,
                p_fax_no          => x.contact_fax,
                p_job_title       => x.job_title,
                x_return_status   => l_return_status,
                x_error_message   => l_error_message
            );
        end loop;

     -- Added by Jaggi for Ticket #11086

        pc_employer_enroll_compliance.update_acct_pref(p_batch_num, p_entrp_id);
        select
            nvl(broker_id, 0)
        into l_broker_id
        from
            table ( pc_broker.get_broker_info_from_acc_id(l_acc_id) );

        if l_broker_id > 0 then
            l_authorize_req_id := pc_broker.get_broker_authorize_req_id(l_broker_id, l_acc_id);
            pc_broker.create_broker_authorize(
                p_broker_id        => l_broker_id,
                p_acc_id           => l_acc_id,
                p_broker_user_id   => null,
                p_authorize_req_id => l_authorize_req_id,
                p_user_id          => p_user_id,
                x_error_status     => l_return_status,
                x_error_message    => l_error_message
            );

        end if;
        -- code ends here by Joshi.

    --Once Plan setup complete update teh complete flag as 1
        update account
        set
            complete_flag = 1,
            last_update_date = sysdate,
            created_by = p_user_id,  /*Ticket#6834 */
            submit_by = p_user_id
        where
            acc_id = l_acc_id;

        x_error_status := 'S';
    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.CREATE_HSA_PLAN', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end create_hsa_plan;

-- Procedure Added by swamy for Ticket#7610
    procedure update_hsa_employee_census (
        p_entrp_id       in number,
        p_user_id        in number,
        p_batch_num      in number,
        p_page_validity  in varchar2,
        p_no_of_ee       in number,
        p_no_of_eligible in number,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    ) is
        l_acc_id        number;
        l_return_status varchar2(100);
        l_error_message varchar2(1000);
        l_exist         number;
    begin
        pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HSA_Employee_Census', 'In Procedure');
        update employer_online_enrollment
        set
            total_no_of_ee = p_no_of_ee,
            no_of_eligible = p_no_of_eligible
        where
                entrp_id = p_entrp_id
            and batch_number = p_batch_num;

        upsert_page_validity(p_batch_num, p_entrp_id, 'HSA', 1, 'HSA_EMPLOYEE_CENSUS',
                             p_page_validity, p_user_id, x_error_status, x_error_message);

    exception
        when others then
            pc_log.log_error('PC_EMPLOYER_ENROLL.UPDATE_HSA_Employee_Census', sqlerrm);
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end update_hsa_employee_census;

-- New procedure Validate_User_Bank_Acct_Stg is added by ticket#7699
    procedure validate_user_bank_acct_stg (
        p_entrp_id      in number,
        p_batch_num     in number,
        p_acct_type     in varchar2,
        p_page_validity out varchar2
    ) is

        l_fund_option        varchar2(100);
        l_diffent_acct_usage number(4) := 0;
        l_all                number := 0;
    begin
        pc_log.log_error('P_Acct_Type ', p_acct_type);
        pc_log.log_error('P_Batch_Num ', p_batch_num);
        pc_log.log_error('P_Entrp_Id ', p_entrp_id);
        p_page_validity := 'I';
        begin
            select
                fund_option
            into l_fund_option
            from
                online_fsa_hra_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_num;

        exception
            when no_data_found then
                null;
        end;

        pc_log.log_error('L_Fund_Option :  ', l_fund_option);
        begin
            select
                count(distinct acct_usage)
            into l_diffent_acct_usage
            from
                user_bank_acct_staging
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_num
                and account_type = p_acct_type
                and validity = 'V';

        exception
            when no_data_found then
                null;
        end;

        if p_acct_type = 'HRA' then
            if l_fund_option = '100CR' then
                for i in (
                    select
                        acct_usage,
                        count(acct_usage) no_of_records
                    from
                        user_bank_acct_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_num
                        and account_type = p_acct_type
                        and validity = 'V'
                    group by
                        acct_usage
                    order by
                        acct_usage
                ) loop
                    if l_diffent_acct_usage > 1 then
                        p_page_validity := 'V';
                        exit;
                    end if;
                    pc_log.log_error(' I.Acct_Usage  :  ', i.acct_usage);
                    if
                        i.acct_usage in ( 'ALL' )
                        and i.no_of_records > 0
                    then
                        l_all := i.no_of_records;
                        p_page_validity := 'V';
                        pc_log.log_error(' I.P_Page_Validity  :  ', p_page_validity);
                        exit;
                    elsif i.acct_usage in ( 'CLAIMS', 'FEE' ) then
                        if l_all < 1 then
                            p_page_validity := 'I';
                        else
                            p_page_validity := 'V';
                        end if;
                    end if;

                end loop;

            elsif l_fund_option in ( '10%_DEP', '50%_FUND', '100%_FUND' ) then
                for i in (
                    select
                        acct_usage,
                        count(acct_usage) no_of_records
                    from
                        user_bank_acct_staging
                    where
                            entrp_id = p_entrp_id
                        and batch_number = p_batch_num
                        and account_type = p_acct_type
                        and validity = 'V'
                    group by
                        acct_usage
                    order by
                        acct_usage
                ) loop
                    if l_diffent_acct_usage > 1 then
                        p_page_validity := 'V';
                        exit;
                    end if;
                    if
                        i.acct_usage in ( 'ALL' )
                        and i.no_of_records > 0
                    then
                        l_all := i.no_of_records;
                        p_page_validity := 'V';
                        exit;
                    elsif i.acct_usage in ( 'FUNDING', 'FEE' ) then
                        if l_all < 1 then
                            p_page_validity := 'I';
                        else
                            p_page_validity := 'V';
                        end if;
                    end if;

                end loop;
            end if;
        end if;   ---P_acct_type = 'HRA'

    end validate_user_bank_acct_stg;

    function get_enroll_or_renewed_by (
        p_entrp_id in number
    ) return last_enroll_or_renewed_by_t
        pipelined
        deterministic
    is
        l_record last_enroll_or_renewed_by_row;
    begin
        l_record.enoll_or_renewed_by := null;
        l_record.enoll_or_renewed_by_desc := null;
        pipe row ( l_record );
    end;

-- Added by Jaggi #11263
    function get_cobra_bank_details (
        p_entrp_id     in number,
        p_batch_number in number
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'ACC_NUM' value b.acc_num,
                                                          key 'BANK_NAME' value a.bank_name,
                                                          key 'ROUTING_NUMBER' value a.routing_number,
                                                          key 'BANK_ACC_NUM' value a.bank_acc_num,
                                                          key 'BANK_ACC_TYPE' value a.bank_acc_type,
                                                                  key 'REMITTANCE_FLAG' value a.remittance_flag,
                                                          key 'FEES_PAYMENT_FLAG' value a.fees_payment_flag,
                                                          key 'SALESREP_ID' value a.salesrep_id,
                                                          key 'SALESREP_FLAG' value a.salesrep_flag,
                                                          key 'SEND_INVOICE' value a.send_invoice,
                                                                  key 'ACCT_PAYMENT_FEES' value a.acct_payment_fees,
                                                          key 'BANK_ACCT_ID' value a.bank_acct_id,
                                                          key 'OPTIONAL_BANK_NAME' value a.optional_bank_name,
                                                          key 'OPTIONAL_ROUTING_NUMBER' value a.optional_routing_number,
                                                          key 'OPTIONAL_BANK_ACC_NUM' value a.optional_bank_acc_num,
                                                                  key 'OPTIONAL_BANK_ACC_TYPE' value a.optional_bank_acc_type,
                                                          key 'OPTIONAL_FEE_PAID_BY' value a.optional_fee_paid_by,
                                                          key 'OPTIONAL_FEE_BANK_ACCT_ID' value a.optional_fee_bank_acct_id,
                                                          key 'OPTIONAL_FEE_PAYMENT_METHOD' value a.optional_fee_payment_method,
                                                          key 'REMIT_BANK_NAME' value a.remit_bank_name,
                                                                  key 'REMIT_ROUTING_NUMBER' value a.remit_routing_number,
                                                          key 'REMIT_BANK_ACC_NUM' value a.remit_bank_acc_num,
                                                          key 'REMIT_BANK_ACC_TYPE' value a.remit_bank_acc_type,
                                                          key 'REMITTANCE_FLAG' value a.remittance_flag,
                                                          key 'BANK_AUTHORIZE' value a.bank_authorize,
                                                                  key 'OPTIONAL_BANK_AUTHORIZE' value a.optional_bank_authorize,
                                                          key 'REMIT_BANK_AUTHORIZE' value a.bank_authorize,
                                                          key 'ANNUAL_FEE_BANK_CREATED_BY' value a.annual_fee_bank_created_by,
                                                          key 'OPTIONAL_FEE_BANK_CREATED_BY' value a.optional_fee_bank_created_by
                                                      )
                                                  ) cobra_bank_details
                                              from
                                                  online_compliance_staging a,
                                                  account                   b
                           where
                                   a.entrp_id = b.entrp_id
                               and a.entrp_id = p_entrp_id
                               and a.batch_number = p_batch_number;

        return thecursor;
    end;

--Added by Jaggi #11263
    function get_fhra_bank_details (
        p_entrp_id     in number,
        p_batch_number in number,
        p_source       in varchar2
    ) return sys_refcursor is
        thecursor sys_refcursor;
    begin
        open thecursor for select
                                                  (
                                                      json_object(
                                                          key 'ACC_NUM' value b.acc_num,
                                                                  key 'PAYMENT_METHOD' value a.payment_method,
                                                                  key 'PAY_ACCT_FEES' value a.pay_acct_fees,
                                                                  key 'MONTHLY_FEES_PAID_BY' value a.monthly_fees_paid_by,
                                                                  key 'MONTHLY_FEE_PAYMENT_METHOD' value a.monthly_fee_payment_method
                                                                  ,
                                                                  key 'MONTHLY_FEE_BANK_ACCT_ID' value a.monthly_fee_bank_acct_id,
                                                                  key 'MONTHLY_BANK_NAME' value a.monthly_bank_name,
                                                                  key 'MONTHLY_ROUTING_NUMBER' value a.monthly_routing_number,
                                                                  key 'MONTHLY_BANK_ACC_NUM' value a.monthly_bank_acc_num,
                                                                  key 'MONTHLY_BANK_ACC_TYPE' value a.monthly_bank_acc_type,
                                                                  key 'FUNDING_PAYMENT_METHOD' value a.funding_payment_method,
                                                                  key 'BANK_NAME' value a.bank_name,
                                                                  key 'ROUTING_NUMBER' value a.routing_number,
                                                                  key 'BANK_ACC_NUM' value a.bank_acc_num,
                                                                  key 'BANK_ACC_TYPE' value a.bank_acc_type,
                                                                  key 'ACCT_USAGE' value a.acct_usage,
                                                                  key 'FUND_OPTION' value a.fund_option,
                                                                  key 'LOOKUP_CODE' value a.fund_option,
                                                                  key 'DESCRIPTION' value decode(b.account_type,
                                                                                                 'FSA',
                                                                                                 pc_lookups.get_meaning(a.fund_option
                                                                                                 , 'FSA_FUNDING_OPTION'),
                                                                                                 pc_lookups.get_meaning(a.fund_option
                                                                                                 , 'FUNDING_OPTION')),
                                                                  key 'SALESREP_FLAG' value a.salesrep_flag,
                                                                  key 'SALESREP_ID' value a.salesrep_id,
                                                                  key 'INVOICE_FLAG' value a.invoice_flag,
                                                                  key 'HRA_COPY_PLAN_DOCS' value a.hra_copy_plan_docs,
                                                                  key 'NDT_PREFERENCE' value a.ndt_preference,
                                                                  key 'CARRIER_FLAG' value a.carrier_flag
                                                      )
                                                  ) fhra_bank_details
                                              from
                                                  online_fsa_hra_staging a,
                                                  account                b
                           where
                                   a.entrp_id = b.entrp_id
                               and a.entrp_id = p_entrp_id
                               and a.batch_number = p_batch_number
                               and nvl(a.source, '*') = nvl(p_source, '*');

        return thecursor;
    end;

-- Added by Jaggi #11602
    procedure upsert_rto_api_plan_doc (
        p_entrp_id      in number,
        p_acc_id        in number,
        p_ben_plan_id   in number,
        p_batch_number  in number,
        p_user_id       in number,
        p_source        in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        v_api_posted_data clob;
        l_record_exists   varchar2(1) := 'N';
    begin
        x_return_status := 'S';
        for i in (
            select
                1
            from
                rto_api_plan_doc_request
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_record_exists := 'Y';
        end loop;

        if nvl(l_record_exists, 'N') = 'N' then
            insert into rto_api_plan_doc_request (
                api_request_id,
                acc_id,
                entrp_id,
                ben_plan_id,
                verified_renewal_date,
                batch_number,
                source,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                process_status,
                return_status,
                return_error_message
            ) values ( api_request_seq.nextval,
                       p_acc_id,
                       p_entrp_id,
                       p_ben_plan_id,
                       null,
                       p_batch_number,
                       nvl(p_source, 'ENROLLMENT'),
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       'N',
                       'S',
                       null );

        else
       -- Added by Swamy for Ticket#12249 on 01072024
       -- When the application is resubmitted, the ben_plan_id should get overwritten with the newly generated ben_plan_id, bcos the old ben plan id gets deleted during resubmission.
            update rto_api_plan_doc_request
            set
                ben_plan_id = p_ben_plan_id
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end upsert_rto_api_plan_doc;

-- Added by Swamy #11602
    function get_rto_api_plan_doc_request (
        p_batch_number in number default null
    ) return ret_rto_api_plan_doc_request
        pipelined
        deterministic
    is

        l_entrp_id             number;
        l_batch_number         number;
        l_acc_id               number;
        l_affliated_flag       varchar2(10);
        l_plan_start_date      varchar2(100);
        l_plan_end_date        varchar2(100);
        l_takeover_flag        varchar2(10);
        l_short_plan_yr_flag   varchar2(10);
        l_employee_elections   varchar2(100);
        l_external_id          number;
        l_first_name           varchar2(100);
        l_last_name            varchar2(100);
        l_email                varchar2(500);
        l_phone                varchar2(100);
        l_user_id              varchar2(100) := '0';
        v_error_message        varchar2(500);
        l_type_of_entity       varchar2(100);
        l_record               rto_api_plan_doc_request_t;
        l_ben_code_exists      varchar2(100);
        l_ben_plan_id          number;
        l_api_request_id       number;
        l_return_error_message varchar2(500);
        pragma autonomous_transaction;
    begin
        for x in (
            select
                rto.acc_id,
                a.entrp_id,
                rto.batch_number,
                rto.api_request_id,
                rto.ben_plan_id,
                rto.source
            from
                rto_api_plan_doc_request rto,
                account                  a
            where
                    a.acc_id = rto.acc_id
                and nvl(rto.return_status, 'S') = 'S'
                and nvl(rto.process_status, 'N') = 'N'
                and a.account_status = '1'
                and rto.batch_number = nvl(p_batch_number, rto.batch_number)
                and a.account_type = 'POP'
        ) loop
            l_entrp_id := x.entrp_id;
            l_batch_number := x.batch_number;
            l_ben_code_exists := 'N';
            l_api_request_id := x.api_request_id;
            l_return_error_message := null;
            for cur_json in (
                select
                    json_arrayagg(
                        json_object(
                            key 'ACC_ID' value a.acc_id,
                                    key 'ACC_NUM' value a.acc_num,
                                    key 'ACCOUNT_STATUS' value a.account_status,
                                    key 'CREATION_DATE' value a.creation_date,
                                    key 'RENEWED_DATE' value a.renewed_date,
                                    key 'BATCH_NUMBER' value x.batch_number,
                                    key 'SOURCE' value nvl(
                                initcap(x.source),
                                'Enrollment'
                            ),
                                    key 'AFFLIATED_FLAG' value nvl(en.affliated_flag, 'N'),
                                    key 'AFFLIATED_DIFF_EIN' value en.affliated_diff_ein,
                                    key 'EXTERNAL_ID' value a.entrp_id,
                                    key 'TYPE_OF_ENTITY' value(
                                select
                                    pc_lookups.get_meaning(
                                        p_lookup_code => en.entity_type,
                                        p_lookup_name => 'ENTITY_TYPE'
                                    ) type_of_entity
                                from
                                    dual
                            ),
                                    key 'STATE_OF_ORG' value en.state_of_org,
                                    key 'CITY' value en.city,
                                    key 'ZIP' value en.zip,
                                    key 'ADDRESS' value en.address,
                                    key 'EMAIL' value en.entrp_email,
               -- KEY 'PHONE'                         VALUE en.entrp_phones,   -- commented by Joshi for 12711
                                    key 'STATE_MAIN_OFFICE' value en.state_main_office,
                                    key 'STATE_GOVERN_LAW' value en.state_govern_law,
                                    key 'TYPE_ENTITY_OTHER' value en.entity_name_desc,
                                    key 'EIN' value pc_entrp.get_tax_id(a.entrp_id),
                                    key 'NAME' value en.name,
                                    key 'PLAN_BENEFITS' value(
                                select
                                    json_arrayagg(
                                        json_object( --Plan details--
                                            key bcs.description value bcs.value
                                        returning clob)
                                    returning clob)
                                from
                                    (
                                        select
                                            bc.description,
                                            1 value
                                        from
                                            benefit_lookup_code_v bc
                                        where
                                            bc.lookup_code in(
                                                select
                                                    b.benefit_code_name
                                                from
                                                    benefit_codes b
                                                where
                                                    b.entity_id = x.ben_plan_id
                                            )
                                        union
                                        select
                                            bc.description,
                                            0 value
                                        from
                                            benefit_lookup_code_v bc
                                        where
                                            bc.lookup_code not in(
                                                select
                                                    b.benefit_code_name
                                                from
                                                    benefit_codes b
                                                where
                                                    b.entity_id = x.ben_plan_id
                                            )
                                    ) bcs
                            ),
                                    key 'AFFLIATED_DETAILS' value(
                                select
                                    json_arrayagg(
                                        json_object( --AFFLIATED details--
                                            key 'AFFLIATED_EIN' value ent.entrp_code,
                                            key 'AFFLIATED_ENTITY_TYPE' value ent.entity_type,
                                            key 'AFFLIATED_ADDRESS' value ent.address,
                                            key 'AFFLIATED_CITY' value ent.city,
                                            key 'AFFLIATED_ZIP' value ent.zip,
                                                    key 'AFFLIATED_STATE' value ent.state
                                        returning clob)
                                    returning clob)
                                from
                                    enterprise          ent,
                                    entrp_relationships erl
                                where
                                        ent.entrp_id = erl.entity_id
                                    and erl.entrp_id = x.entrp_id
                                    and erl.entity_type = 'ENTERPRISE'
                                    and erl.relationship_type = 'AFFILIATED_ER'
                            ),
                                    key 'PLAN_DETAILS' value(
                                select
                                    json_arrayagg(
                                        json_object( --PLAN details--
                                            key 'PLAN_NAME' value decode(bp.plan_type, 'COMP_POP', 'Cafeteria Plan', 'COMP_POP_RENEW'
                                            , 'Cafeteria Plan',
                                                                         'Premium Only Plan'),
                                                    key 'TAKEOVER_FLAG' value decode(
                                                nvl(x.source, 'ENROLLMENT'),
                                                'ENROLLMENT',
                                                decode(
                                                                                             nvl(bp.takeover, 'N'),
                                                                                             'Y',
                                                                                             'Y',
                                                                                             nvl(bp.renewal_flag, 'N')
                                                                                         ),
                                                nvl(bp.renewal_flag, 'N')
                                            ),  -- Commented and added by Swamy for Ticket#12513
                                                                    --KEY  'TAKEOVER_FLAG'                VALUE NVL(bp.takeover,'N'), -- Enrollment means New, and Renewal means reinstatement -- NVL(bp.takeover,'N'),
                                                    key 'PLAN_START_DATE' value bp.plan_start_date,
                                                    key 'PLAN_END_DATE' value bp.plan_end_date,
                                                    key 'EFFECTIVE_DATE' value decode(
                                                nvl(x.source, 'ENROLLMENT'),
                                                'ENROLLMENT',
                                                decode(
                                                                                             nvl(bp.takeover, 'N'),
                                                                                             'Y',
                                                                                             bp.original_eff_date,
                                                                                             bp.effective_date
                                                                                         ),
                                                bp.plan_start_date
                                            ),
                                                    key 'SHORT_PLAN_YR_FLAG' value nvl(bp.short_plan_yr_flag, 'N'),
                                                    key 'REINSTATEMENT_DATE' value decode(
                                                nvl(x.source, 'ENROLLMENT'),
                                                'ENROLLMENT',
                                                decode(
                                                                                             nvl(bp.takeover, 'N'),
                                                                                             'Y',
                                                                                             nvl(bp.effective_date, a.start_date),
                                                                                             nvl(bp.effective_date, a.start_date)
                                                                                         ),
                                                bp.plan_start_date
                                            ),  -- Added bp.plan_start_date instead of a.start_date for Ticket#12513
                                                    key 'RENEWAL_YEAR_START' value bp.plan_start_date,
                                                    key 'RENEWAL_YEAR_END' value bp.plan_end_date,
                                                    key 'BEN_PLAN_ID' value bp.ben_plan_id
                                        returning clob)
                                    returning clob)
                                from
                                    ben_plan_enrollment_setup bp
                                where
                                    bp.ben_plan_id = x.ben_plan_id
                            ),
                                    key 'CUSTOM_ELIGIBILITY_REQ' value(
                                select
                                    json_arrayagg(
                                        json_object( --CUSTOM_ELIGIBILITY_REQ details--
                                            key 'INCLUDE_PARTICIPANT_ELECTION' value nvl(cer.include_participant_election, 'N'),
                                                    key 'CHANGE_STATUS_BELOW_30' value nvl(cer.change_status_below_30, 'N'),
                                                    key 'CHANGE_STATUS_SPECIAL_ANNUAL_ENROLLMENT' value nvl(cer.change_status_special_annual_enrollment
                                                    , 'N'),
                                                    key 'INCLUDE_FMLA_LANG' value nvl(cer.include_fmla_lang, 'N'),
                                                    key 'EMPLOYEE_ELECTIONS' value(
                                                select
                                                    pc_lookups.get_meaning(
                                                        p_lookup_code => cer.employee_elections,
                                                        p_lookup_name => 'POP_ELECTIONS_PLAN_OPTIONS'
                                                    ) employee_elections
                                                from
                                                    dual
                                            ),
                                                    key 'CHANGE_STATUS_DEPENDENT_SPECIAL_ENROLLMENT' value decode(
                                                nvl(cer.change_status_special_annual_enrollment, 'N'),
                                                'N',
                                                'N',
                                                nvl(cer.change_status_dependent_special_enrollment, 'N')
                                            )  -- Added for Ticket#12905
                                                                    --KEY  'CHANGE_STATUS_DEPENDENT_SPECIAL_ENROLLMENT'            VALUE NVL(cer.CHANGE_STATUS_DEPENDENT_SPECIAL_ENROLLMENT,'N')   -- Added by Swamy for Ticket#12131 22052024
                                        returning clob)
                                    returning clob)
                                from
                                    custom_eligibility_req cer
                                where
                                    cer.entity_id = x.ben_plan_id
                            ),
                 /* commented and added below by jsohi for 12711
                 KEY  'CONTACT_DETAILS'                    VALUE (SELECT JSON_ARRAYAGG(
                                                                     JSON_OBJECT( --CONTACT details--
                                                                    KEY  'FIRST_NAME'                VALUE con.first_name,
                                                                    KEY  'LAST_NAME'                 VALUE con.last_name ,
                                                                    KEY  'EMAIL'                     VALUE con.email
                                                                  RETURNING CLOB )RETURNING CLOB)
                                                                  FROM pc_contact.GET_CONTACT_INFO (P_EIN => PC_ENTRP.GET_TAX_ID(l_entrp_id), P_CONTACT_TYPE => 'PRIMARY') con   -- Added by Swamy for Ticket# INC14358
																/* FROM CONTACT con
																WHERE con.entity_id    = PC_ENTRP.GET_TAX_ID(l_entrp_id)
                                                                  AND con.contact_type   = 'PRIMARY'
															  	  AND NVL(con.can_contact,'N')    = 'Y'
                                                                  AND con.status = 'A'
                                                                  AND con.first_name IS NOT NULL
                                                                  AND con.last_name IS NOT NULL
                                                                  AND con.email IS NOT NULL
                                                                  ) */

                                    key 'CONTACT_DETAILS' value(
                                select
                                    json_arrayagg(
                                        json_object( --CONTACT details--
                                            key 'FIRST_NAME' value a.first_name,
                                            key 'LAST_NAME' value a.last_name,
                                            key 'PHONE' value a.phone,
                                            key 'EMAIL' value a.email
                                        returning clob)
                                    returning clob)
                                from
                                    (
                                        select
                                            first_name,
                                            last_name,
                                            phone,
                                            email
                                        from
                                            pc_contact.get_contact_info(
                                                p_ein          => pc_entrp.get_tax_id(l_entrp_id),
                                                p_contact_type => 'PRIMARY'
                                            ) con
                                        where
                                                account_type = 'POP'
                                            and con.first_name is not null
                                            and con.last_name is not null
                                            and con.email is not null
                                        union all
                                        select
                                            first_name,
                                            last_name,
                                            phone,
                                            email
                                        from
                                            table(pc_contact.get_contact_info(
                                                p_ein          => pc_entrp.get_tax_id(l_entrp_id),
                                                p_contact_type => 'PRIMARY'
                                            )) con
                                        where
                                                rownum = 1
                                            and con.first_name is not null
                                            and con.last_name is not null
                                            and con.email is not null
                                            and not exists(
                                                select
                                                    *
                                                from
                                                    table(pc_contact.get_contact_info(
                                                        p_ein          => pc_entrp.get_tax_id(l_entrp_id),
                                                        p_contact_type => 'PRIMARY'
                                                    )) con1
                                                where
                                                        con1.account_type = 'POP'
                                                    and con1.first_name is not null
                                                    and con1.last_name is not null
                                                    and con1.email is not null
                                            )
                                    ) a
                            )
                        returning clob)
                    returning clob) files
                from
                    account    a,
                    enterprise en
                where
                        en.entrp_id = a.entrp_id
                    and a.entrp_id = x.entrp_id
            ) loop
                begin
                    l_record.col1 := cur_json.files;
			-- do not put this log message as there is an ora error SAM.WEBSITE_LOGS.MESSAGE (actual: 6803, maximum: 4000)
            --pc_log.log_error('Get_Rto_Api_Plan_Doc_Request','l_record.col1 '||l_record.col1);
                    v_error_message := null;
                    l_acc_id := null;
                    l_type_of_entity := null;
                    l_plan_start_date := null;
                    l_plan_end_date := null;
                    l_affliated_flag := null;
                    l_takeover_flag := null;
                    l_short_plan_yr_flag := null;
                    l_employee_elections := null;
                    l_first_name := null;
                    l_last_name := null;
                    l_email := null;
                    l_phone := null;
                    l_external_id := null;
                    l_ben_plan_id := null;
                    l_acc_id := json_value(l_record.col1, '$.ACC_ID');
                    l_type_of_entity := json_value(l_record.col1, '$.TYPE_OF_ENTITY');
                    l_plan_start_date := json_value(l_record.col1, '$.PLAN_DETAILS.PLAN_START_DATE');
                    l_plan_end_date := json_value(l_record.col1, '$.PLAN_DETAILS.PLAN_END_DATE');
                    l_affliated_flag := json_value(l_record.col1, '$.AFFLIATED_FLAG');
                    l_takeover_flag := json_value(l_record.col1, '$.PLAN_DETAILS.TAKEOVER_FLAG');
                    l_short_plan_yr_flag := json_value(l_record.col1, '$.PLAN_DETAILS.SHORT_PLAN_YR_FLAG');
                    l_employee_elections := json_value(l_record.col1, '$.CUSTOM_ELIGIBILITY_REQ.EMPLOYEE_ELECTIONS');
                    l_first_name := json_value(l_record.col1, '$.CONTACT_DETAILS[0].FIRST_NAME');
                    l_last_name := json_value(l_record.col1, '$.CONTACT_DETAILS[0].LAST_NAME');
                    l_email := json_value(l_record.col1, '$.CONTACT_DETAILS[0].EMAIL');
                    l_phone := json_value(l_record.col1, '$.CONTACT_DETAILS[0].PHONE');  -- added by Joshi for 12711
                    l_external_id := json_value(l_record.col1, '$.EXTERNAL_ID');
                    l_ben_plan_id := json_value(l_record.col1, '$.PLAN_DETAILS.BEN_PLAN_ID');
                    pc_log.log_error('Get_Rto_Api_Plan_Doc_Request', 'l_ben_plan_id ' || l_ben_plan_id);
                    for k in (
                        select
                            benefit_code_name
                        from
                            benefit_codes b
                        where
                            b.entity_id = l_ben_plan_id
                    ) loop
                        l_ben_code_exists := k.benefit_code_name;
                    end loop;

                    if nvl(l_ben_code_exists, 'N') = 'N' then
                        v_error_message := v_error_message || ' No Benefit Codes Selected';
                    end if;

                    if l_acc_id is null then
                        v_error_message := v_error_message || ' Account Number is Null';
                    end if;
                    if l_type_of_entity is null then
                        v_error_message := v_error_message || ' Company Type is Null';
                    end if;
                    if l_affliated_flag is null then
                        v_error_message := v_error_message || ' AFFLIATED FLAG is Null';
                    end if;
                    if l_takeover_flag is null then
                        v_error_message := v_error_message || ' Takeover FLAG is Null';
                    end if;
                    if l_short_plan_yr_flag is null then
                        v_error_message := v_error_message || ' Short Plan year FLAG is Null';
                    end if;
                    if l_employee_elections is null then
                        v_error_message := v_error_message || ' Employee Elections is Null';
                    end if;
                    if l_first_name is null then
                        v_error_message := v_error_message || ' First Name is Null';
                    end if;
                    if l_last_name is null then
                        v_error_message := v_error_message || ' Last Name is Null';
                    end if;
                    if l_email is null then
                        v_error_message := v_error_message || ' Email is Null';
                    end if;
                    if l_phone is null then
                        v_error_message := v_error_message || ' Phone No is Null';
                    end if;
                    if l_plan_start_date is null then
                        v_error_message := v_error_message || ' Plan Start Date is Null';
                    end if;
                    if l_plan_end_date is null then
                        v_error_message := v_error_message || ' Plan End Date is Null';
                    end if;
                    if nvl(v_error_message, '*') = '*' then
                        pc_log.log_error('Get_Rto_Api_Plan_Doc_Request', 'l_acc_id '
                                                                         || l_acc_id
                                                                         || ' l_TAKEOVER_FLAG :='
                                                                         || l_takeover_flag
                                                                         || ' l_Employee_Elections :='
                                                                         || l_employee_elections);

                        pipe row ( l_record );
                        update rto_api_plan_doc_request ra
                  --SET ra.api_posted_data = To_char(cur_json.files)   -- If we use to_char then ORA-22835: Buffer too small for CLOB to CHAR is raised.
                        set
                            ra.api_posted_data = cur_json.files,
                            ra.last_update_date = sysdate,
                            ra.last_updated_by = l_user_id
                        where
                            ra.api_request_id = x.api_request_id;

                        commit;
                    else
                        begin
                            update rto_api_plan_doc_request
                            set
                                return_status = 'E',
                                return_error_message = v_error_message,
                                last_update_date = sysdate,
                                last_updated_by = l_user_id
                            where
                                api_request_id = x.api_request_id;

                            commit;
                        end;
                    end if;

                exception
                    when no_data_needed then
                        null;
                    when others then
                        l_return_error_message := sqlerrm;
                        update rto_api_plan_doc_request
                        set
                            return_status = 'E',
                            return_error_message = 'Error in Others exception ' || l_return_error_message,
                            last_update_date = sysdate,
                            last_updated_by = l_user_id
                        where
                            api_request_id = l_api_request_id;

                        commit;
                end;
            end loop;

        end loop;
    end get_rto_api_plan_doc_request;

-- Added by Swamy for Ticket#12309
-- Just moved the code from upsert_bank_info which will be directly called from php, instead of upsert_bank_info.
    procedure fsa_hra_enroll_upsert_page_validity (
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_batch_number  in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_page_no       number;
        l_page_validity varchar2(100);
    begin
        l_page_validity := null;
        if p_account_type in ( 'FSA', 'HRA' ) then -- IF  added by rprabu on 08/08/2018 for the tickets 6346 and 6377
      -- for loop added by rprabu on 09/08/2018 Ticket 6346
            for i in (
                select
                    decode(
                        count(user_bank_acct_stg_id),
                        0,
                        'V',
                        'I'
                    ) page_validity
                from
                    user_bank_acct_staging
                where
                        entrp_id = p_entrp_id
                    and account_type = p_account_type
                    and validity = 'I'
            ) loop
                l_page_validity := i.page_validity;
            end loop;
      --- added by rprabu for contact page issue on 27/07/2018 ticket 6346
            if p_account_type = 'FSA' then
                l_page_no := 3;
            elsif p_account_type = 'HRA' then
                l_page_no := 4;
            end if;

            pc_employer_enroll.upsert_page_validity(
                p_batch_number  => p_batch_number,
                p_entrp_id      => p_entrp_id,
                p_account_type  => p_account_type,
                p_page_no       => l_page_no,
                p_block_name    => 'INVOICING_PAYMENT',
                p_validity      => l_page_validity,
                p_user_id       => p_user_id,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

        end if;

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
    end fsa_hra_enroll_upsert_page_validity;

end pc_employer_enroll;
/


-- sqlcl_snapshot {"hash":"60a96491d44d0aca0a3d884dd990674141cc6197","type":"PACKAGE_BODY","name":"PC_EMPLOYER_ENROLL","schemaName":"SAMQA","sxml":""}