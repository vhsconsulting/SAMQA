-- liquibase formatted sql
-- changeset SAMQA:1754374073080 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_online_enrollment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_online_enrollment.sql:null:c9e8902c9a26690feed8bac2cb730aaf0d065fc7:create

create or replace package body samqa.pc_online_enrollment is

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

    function check_user_registered (
        p_ssn in varchar2
    ) return varchar2 is
        l_exists varchar2(1) := 'N';
    begin
        l_exists := pc_users.check_user_registered(p_ssn, 'S');
        return l_exists;
    end check_user_registered;

    procedure pc_insert_enrollment_plb (
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
        p_entrp_acc_num              in varchar2,
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
        x_enrollment_id              out number,
        x_error_message              out varchar2,
        x_return_status              out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_setup_error exception;
        l_fraud_account  varchar2(30) := 'N';
        l_return_status  varchar2(30);
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_account_type   varchar2(30);
        l_deductible     number;
        l_effective_date date;
        l_count          number := 0;
        l_entrp_id       number;
    begin
        x_return_status := 'S';
        pc_log.log_error('START OF PROCEDURE', 'Inside Online Enrollment ');
        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'bank information : account_type '
                                                 || p_account_type
                                                 || 'routing_number '
                                                 || p_routing_number
                                                 || 'account number '
                                                 || p_bank_account_number
                                                 || 'bank name '
                                                 || p_bank_name);

        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'er contribution ' || p_er_contribution);
        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'First Name  '
                                                 || p_first_name
                                                 || 'Last Name  '
                                                 || p_last_name
                                                 || 'SSN '
                                                 || p_ssn
                                                 || 'Health plan effective date '
                                                 || p_health_plan_eff_date);

        if p_account_type in ( 'CK', 'C' ) then
            l_account_type := 'C';
        else
            l_account_type := 'S';
        end if;

        if p_ssn is null then
            x_error_message := 'Enter valid social security number';
            raise l_create_error;
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
        if isalphanumeric(p_last_name) is not null then
            x_error_message := ' Special Characters '
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
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_middle_name)
                               || ' are not allowed for middle name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_user_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_user_name)
                               || ' are not allowed for user name ';
            raise l_setup_error;
        end if;

        if p_user_name is null then
            x_error_message := 'Enter valid user name';
            raise l_setup_error;
        end if;
        if p_password_reminder_question is null then
            x_error_message := 'Enter valid password reminder question';
            raise l_setup_error;
        end if;
        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'dependant checking');
        if p_password_reminder_answer is null then
            x_error_message := 'Enter valid password reminder answer';
            raise l_setup_error;
        end if;
        for x in (
            select
                entrp_id
            from
                account
            where
                acc_num = p_entrp_acc_num
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

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
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( mass_enrollments_seq.nextval,
                   initcap(p_first_name),
                   initcap(p_last_name),
                   substr(p_middle_name, 1, 1),
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
                   p_plan_type,
                   nvl(p_health_plan_eff_date, sysdate),
                   p_deductible,
                   p_plan_code,
                   p_broker_lic,
                   l_entrp_id,
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
                   sysdate,
                   421,
                   sysdate,
                   421 ) returning enrollment_id into x_enrollment_id;

        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Inserted into enrollment table  ' || x_enrollment_id);
        l_acc_num := pc_account.generate_acc_num(p_plan_code,
                                                 upper(p_state));
        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Generated acc num  ' || l_acc_num);
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
                upper(state)                               state,
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
                pc_account.get_salesrep_id(null, entrp_id) salesrep_id
            from
                online_enrollment
            where
                enrollment_id = x_enrollment_id
        ) loop
            begin
                l_fraud_account := 'N';
                l_return_status := 'S';
                pc_online.check_fraud(
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
            /*** Creating Person ****/
                l_action := 'Creating Person';
                savepoint enroll_savepoint;
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
                    raise l_create_error;
                end if;

                if
                    l_deductible is null
                    and x.deductible is null
                then
                    x_error_message := 'Enter valid deductible';
                    raise l_create_error;
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
                    enrollment_source,
                    salesrep_id
                ) values ( acc_seq.nextval,
                           l_pers_id,
                           l_acc_num,
                           x.plan_code,
                           greatest(
                               nvl(l_effective_date, x.health_plan_eff_date),
                               sysdate
                           ),
                           nvl(x.er_contribution, 0) + nvl(x.ee_contribution, 0) + nvl(x.ee_fee_contribution, 0) + nvl(x.er_fee_contribution
                           , 0),
                           nvl((case
                               when
                                   x.broker_lic is null
                                   and x.entrp_id is not null
                               then
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
                               else(
                                   select
                                       broker_id
                                   from
                                       broker
                                   where
                                       broker_lic = x.broker_lic
                               )
                           end), 0),
                           'Online Enrollment',
                           pc_plan.fsetup(x.plan_code),
                           pc_plan.fmonth(x.plan_code),
                           sysdate,
                           3,
                           1,
                           'Y',
                           greatest(
                               nvl(l_effective_date, x.health_plan_eff_date),
                               sysdate
                           ),
                           'ONLINE',
                           x.salesrep_id ) returning acc_id into l_acc_id;

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
                           nvl(l_effective_date, x.health_plan_eff_date),
                           nvl(l_deductible, x.deductible),
                           'Online Enrollment',
                           x.plan_type );

                dbms_output.put_line('creating card ');

           /*** Creating Debit Card Information ***/

                if x.debit_card_flag = 'Y' then
                    l_action := 'Creating Debit Card';
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
                               1248,
                               case
                                   when pc_plan.can_create_card_on_pend(x.plan_code) = 'Y' then
                                       1
                                   else
                                       9
                               end,
                               'Automatic Online Enrollment',
                               0,
                               sysdate );
                 -- PC_FIN.CARD_OPEN_FEE(l_pers_id);
                end if;

           /*** Creating Bank Account Information ***/
                if x.bank_name is not null then
                    l_action := 'Creating Bank Account';
                    pc_user_bank_acct.insert_user_bank_acct(
                        p_acc_num          => l_acc_num,
                        p_display_name     => x.bank_name,
                        p_bank_acct_type   => x.account_type,
                        p_bank_routing_num => x.routing_number,
                        p_bank_acct_num    => x.bank_account_number,
                        p_bank_name        => x.bank_name,
                        p_user_id          => 421,
                        x_bank_acct_id     => l_bank_acct_id,
                        x_return_status    => l_return_status,
                        x_error_message    => x_error_message
                    );

                    if l_return_status <> 'S' then
                        raise l_create_error;
                    end if;

           /*** Scheduling for ACH transfer ***/
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

                        if l_return_status <> 'S' then
                            raise l_create_error;
                        end if;
                    end if;

                end if;
          -- SELECT acc_num INTO l_acc_num FROM account WHERE acc_id = l_acc_id;

                l_action := 'Creating User';
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
                update online_enrollment
                set
                    acc_id = l_acc_id,
                    pers_id = l_pers_id,
                    acc_num = l_acc_num,
                    enrollment_status = 'Success',
                    error_message = null
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
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                    dbms_output.put_line('error message ' || sqlerrm);
            end;
        end loop;

    exception
        when l_setup_error then
            rollback;
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Exception in enrollment  ' || x_error_message);
        when others then
            x_return_status := 'E';
            x_error_message := x_error_message;
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Exception in enrollment  '
                                                     || x_error_message
                                                     || ' '
                                                     || sqlerrm);
    end pc_insert_enrollment_plb;

    procedure pc_insert_enrollment (
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
        p_lang_perf                  in varchar2,
        p_id_verification_status     in varchar2,
        p_transaction_id             in varchar2,
        p_verification_date          in varchar2,
        p_business_name              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gverify                    in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gauthenticate              in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_gresponse                  in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_giact_verify               in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_bank_status                in varchar2     -- Added by Swamy for Ticket#10978 13062024
        ,
        p_bank_acct_id               out number      -- Added by Swamy for Ticket#10978 13062024
        ,
        x_enrollment_id              out number,
        x_error_message              out varchar2,
        x_return_status              out varchar2
    ) is

        l_sqlerrm                varchar2(3200);
        l_pers_id                number;
        l_acc_id                 number;
        l_bank_acct_id           number;
        l_transaction_id         number;
        l_action                 varchar2(255);
        l_create_error exception;
        l_setup_error exception;
        l_fraud_account          varchar2(30) := 'N';
        l_return_status          varchar2(30);
        l_error_message          varchar2(3200);
        l_acc_num                varchar2(30);
        l_user_id                number;
        l_account_type           varchar2(30);
        l_deductible             number;
        l_effective_date         date;
        l_count                  number := 0;
        l_user_count             number := 0;
        l_id_verification_status varchar2(1);
        l_giac_return_status     varchar2(255);
        l_giac_error_message     varchar2(500);
        l_bank_status            varchar2(50) := p_bank_status;
    begin
        x_return_status := 'S';
        pc_log.log_error('START OF PROCEDURE', 'Inside Online Enrollment ');
        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'bank information : account_type '
                                                 || p_account_type
                                                 || 'routing_number '
                                                 || p_routing_number
                                                 || 'account number '
                                                 || p_bank_account_number
                                                 || 'bank name '
                                                 || p_bank_name);

        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'er contribution ' || p_er_contribution);
        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'First Name  '
                                                 || p_first_name
                                                 || 'Last Name  '
                                                 || p_last_name
                                                 || 'SSN '
                                                 || p_ssn
                                                 || 'Health plan effective date '
                                                 || p_health_plan_eff_date);

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

        if p_ssn is null then
            x_error_message := 'Enter valid social security number';
            raise l_setup_error;   --l_create_error;  -- Added by Swamy for Ticket#10978 13062024

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
        if isalphanumeric(p_last_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_last_name)
                               || ' are not allowed for last name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_first_name) is not null then
            x_error_message := x_error_message
                               || ' Special Characters '
                               || isalphanumeric(p_first_name)
                               || ' are not allowed for first name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_middle_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_middle_name)
                               || ' are not allowed for middle name ';
            raise l_setup_error;
        end if;

        if nvl(
            pc_users.check_user_registered(p_ssn, 'S'),
            'N'
        ) = 'N' then
            if isalphanumeric(p_user_name) is not null then
                x_error_message := ' Special Characters '
                                   || isalphanumeric(p_user_name)
                                   || ' are not allowed for user name ';
                raise l_setup_error;
            end if;

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
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'dependant checking');
            if p_password_reminder_answer is null then
                x_error_message := 'Enter valid password reminder answer';
                raise l_setup_error;
            end if;
        end if;

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
                   substr(p_middle_name, 1, 1),
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

        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Inserted into enrollment table  ' || x_enrollment_id);
        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Generated acc num  ' || l_acc_num);
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
                upper(state)                               state,
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
            savepoint enroll_savepoint;
            begin
                l_fraud_account := 'N';
                l_return_status := 'S';
                pc_online.check_fraud(
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

                pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Fraud check complete ' || l_fraud_account);
                if l_fraud_account = 'Y'
                or l_return_status = 'E' then
                    x_error_message := 'Cannot enroll account. Please contact customer service at 800-617-4729 between 8AM-6PM Pacific Time.'
                    ;
                    raise l_create_error;
                end if;
            /*** Creating Person ****/
                l_action := 'Creating Person';
                l_deductible := null;
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
                elsif l_effective_date > sysdate + 90
                      or x.health_plan_eff_date > sysdate + 90 then
                    x_error_message := 'Your account cannot be enrolled as the plan effective date is in future ';
                    raise l_create_error;
                end if;

                if
                    l_deductible is null
                    and x.deductible is null
                then
                    x_error_message := 'Enter valid deductible';
                    raise l_create_error;
                end if;

                if pc_account.check_duplicate(x.ssn, null, null, 'HSA', x.entrp_id) = 'Y' then
                    x_error_message := 'Cannot enroll, this ssn already has an account ';       -- SSN removed by Jaggi #9957
                    raise l_create_error;
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
                               nvl(l_effective_date, x.health_plan_eff_date),
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
                               nvl(l_effective_date, x.health_plan_eff_date),
                               sysdate
                           ),
                           'HSA',
                           'ONLINE',
                           x.salesrep_id,
                           x.lang_perf,
                           decode(
                               nvl(l_id_verification_status, -1),
                               0,
                               'N',
                               'Y'
                           ) -- added for id verification with veratad
                           ,
                           decode(
                               nvl(p_id_verification_status, -1),
                               0,
                               'Y',
                               'N'
                           ) ) -- added for id verification with veratad
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
                           nvl(l_effective_date, x.health_plan_eff_date),
                           nvl(l_deductible, x.deductible),
                           'Online Enrollment',
                           x.plan_type );

                dbms_output.put_line('creating card ');

           /*** Creating Debit Card Information ***/

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
                    l_action := 'Creating Debit Card';
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
                               1248,
                               9,
                               'Automatic Online Enrollment',
                               0,
                               sysdate );
                 -- PC_FIN.CARD_OPEN_FEE(l_pers_id);
                end if;

           /*** Creating Bank Account Information ***/
                if x.bank_name is not null then
                    l_action := 'Creating Bank Account';
             -- Commented by Swamy for Ticket#10978 13062024
            /* pc_user_bank_acct.insert_user_bank_acct
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
                RAISE l_create_error;
             END IF;
             */

                    pc_user_bank_acct.giac_insert_user_bank_acct            -- Added by Swamy for Ticket#10978 13062024

                    (
                        p_acc_num          => l_acc_num,
                        p_entity_id        => l_acc_id     -- Added by Swamy for Ticket#12309 
                        ,
                        p_entity_type      => 'ACCOUNT',
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
                        p_auto_pay         => 'N'        -- Added by Swamy for Ticket#12309 
                        ,
                        p_bank_acct_usage  => 'ONLINE'   -- Added by Swamy for Ticket#12309
                        ,
                        p_division_code    => null,
                        p_source           => null,
                        x_bank_acct_id     => l_bank_acct_id,
                        x_return_status    => l_return_status,
                        x_error_message    => x_error_message
                    );

                    p_bank_acct_id := l_bank_acct_id;
                    if l_return_status = 'P' then
                        l_giac_return_status := l_return_status;
                        l_giac_error_message := x_error_message;
                    end if;
                    if l_return_status not in ( 'S', 'P', 'R' ) then   -- Added by Swamy for Ticket#10978 13062024
                        raise l_create_error;
                    end if;
                    pc_log.log_error('PC_ONLINE_ENROLLMENT', 'pc_ach_transfer.ins_ach_transfer l_bank_status ' || l_bank_status);
                    if nvl(l_bank_status, '*') = 'A' then  -- If cond.Added by Swamy for Ticket#10978 13062024
           /*** Scheduling for ACH transfer ***/
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

                            if l_return_status <> 'S' then
                                raise l_create_error;
                            end if;
                        end if;
                    end if;

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
                if nvl(
                    pc_users.check_user_registered(x.ssn, 'S'),
                    'N'
                ) = 'N' then
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
                    l_user_count := 0;
                    l_user_count := pc_users.get_user_count(x.ssn, 'S');
                    pc_log.log_error('PC_ONLINE_ENROLLMENT', 'User is  registered for '
                                                             || x.ssn
                                                             || ' count : '
                                                             || l_user_count);

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
                    if nvl(l_id_verification_status, -1) <> 0 then
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
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                    dbms_output.put_line('error message ' || sqlerrm);
            end;

        end loop;

    exception
        when l_setup_error then
            rollback;
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Exception in enrollment  ' || x_error_message);
        when others then
            x_return_status := 'E';
            x_error_message := x_error_message;
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Exception in enrollment  '
                                                     || x_error_message
                                                     || ' '
                                                     || sqlerrm);
    end pc_insert_enrollment;

    procedure pc_update_enrollment (
        p_enrollment_id          in number,
        p_first_name             in varchar2,
        p_last_name              in varchar2,
        p_middle_name            in varchar2,
        p_title                  in varchar2,
        p_gender                 in varchar2,
        p_birth_date             in date,
        p_ssn                    in varchar2,
        p_id_type                in varchar2,
        p_id_number              in varchar2,
        p_address                in varchar2,
        p_city                   in varchar2,
        p_state                  in varchar2,
        p_zip                    in varchar2,
        p_phone                  in varchar2,
        p_email                  in varchar2,
        p_carrier_id             in number,
        p_plan_type              in varchar2,
        p_health_plan_eff_date   in date,
        p_deductible             in varchar2,
        p_plan_code              in number,
        p_broker_lic             in varchar2,
        p_entrp_id               in number,
        p_debit_card_flag        in varchar2,
        p_ip_address             in varchar2,
        p_id_verification_status in varchar2,
        p_transaction_id         in varchar2,
        p_verification_date      in varchar2,
        p_dep_first_name         in varchar2_tbl,
        p_dep_middle_name        in varchar2_tbl,
        p_dep_last_name          in varchar2_tbl,
        p_dep_gender             in varchar2_tbl,
        p_dep_birth_date         in varchar2_tbl,
        p_dep_ssn                in varchar2_tbl,
        p_dep_relative           in varchar2_tbl,
        p_dep_flag               in varchar2_tbl,
        p_beneficiary_name       in varchar2_tbl,
        p_beneficiary_type       in varchar2_tbl,
        p_beneficiary_relation   in varchar2_tbl,
        p_ben_distiribution      in varchar2_tbl,
        p_dep_debit_card_flag    in varchar2_tbl,
        x_error_message          out varchar2,
        x_return_status          out varchar2
    ) is

        l_insur_count          number := 0;
        l_card_count           number := 0;
        l_dup_count            number := 0;
        l_account_type         varchar2(30);
        l_deductible           number;
        l_primary_dist         number;
        l_contingent_dist      number;
        l_effective_date       date;
        l_dep_sp_count         number := 0;
        l_fraud_account        varchar2(1) := 'N';
        l_dep_pers_id          number;
        l_create_error exception;
        l_setup_error exception;
        l_error_message        varchar2(3200);
        l_count                number := 0;
        l_dep_first_name       varchar2_tbl;
        l_dep_middle_name      varchar2_tbl;
        l_dep_last_name        varchar2_tbl;
        l_dep_gender           varchar2_tbl;
        l_dep_birth_date       varchar2_tbl;
        l_dep_ssn              varchar2_tbl;
        l_dep_relative         varchar2_tbl;
        l_dep_flag             varchar2_tbl;
        l_beneficiary_type     varchar2_tbl;
        l_beneficiary_relation varchar2_tbl;
        l_ben_distiribution    varchar2_tbl;
        l_dep_debit_card_flag  varchar2_tbl;
        l_beneficiary_name     varchar2_tbl;
    begin
        x_return_status := 'S';
        pc_log.log_error('update_enrollment, enrollment id', p_enrollment_id);
        pc_log.log_error('update_enrollment, health plan eff date', p_health_plan_eff_date);
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
        if
            p_deductible is not null
            and is_number(p_deductible) = 'N'
        then
            x_error_message := 'Enter numeric value for Deductible Amount,  space or non-numeric characters are not allowed  ';
            raise l_setup_error;
        end if;

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

        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'dependant relative checking');
        if isalphanumeric(p_last_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_last_name)
                               || ' are not allowed for last name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_first_name) is not null then
            x_error_message := x_error_message
                               || ' Special Characters '
                               || isalphanumeric(p_first_name)
                               || ' are not allowed for first name ';
            raise l_setup_error;
        end if;

        if isalphanumeric(p_middle_name) is not null then
            x_error_message := ' Special Characters '
                               || isalphanumeric(p_middle_name)
                               || ' are not allowed for middle name ';
            raise l_setup_error;
        end if;

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

        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'dependant debit card checking');
        for i in 1..l_dep_debit_card_flag.count loop
            if
                l_dep_flag(i) = 'DEPENDANT'
                and nvl(p_debit_card_flag, 'N') = 'N'
                and l_dep_debit_card_flag(i) = '1'
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
                and l_dep_debit_card_flag(i) = '1'
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

        pc_log.log_error('PC_ONLINE_ENROLLMENT', 'dependant ssn checking');
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

        for i in 1..l_beneficiary_type.count loop
            if l_beneficiary_type(i) = 1 then
                l_primary_dist := nvl(l_primary_dist, 0) + l_ben_distiribution(i);
                if l_primary_dist > 100 then
                    x_error_message := 'Distribution cannot exceed 100% for primary beneficiary type';
                    raise l_setup_error;
                end if;
            else
                l_contingent_dist := nvl(l_contingent_dist, 0) + l_ben_distiribution(i);
                if l_contingent_dist > 100 then
                    x_error_message := 'Distribution cannot exceed 100% for contingent beneficiary type';
                    raise l_setup_error;
                end if;
            end if;
        end loop;

        update online_enrollment
        set
            first_name = initcap(p_first_name),
            last_name = p_last_name,
            middle_name = initcap(p_middle_name),
            title = p_title,
            gender = p_gender,
            birth_date = p_birth_date
   --    ,SSN                         = P_SSN  /* vanitha commented on 1/24/2021 to avoid ssn overwrite errors */
            ,
            id_type = p_id_type,
            id_number = p_id_number,
            address = p_address,
            city = initcap(p_city),
            state = upper(p_state),
            zip = p_zip,
            phone = p_phone,
            email = p_email,
            carrier_id = p_carrier_id,
            plan_type = decode(p_plan_type, 0, 0, 1) -- Added by jaggi#10456 -- coverage tiers  EE+SPOUSE  EE+CHILDREN  should come as FAMILY
            ,
            health_plan_eff_date = nvl(health_plan_eff_date,
                                       nvl(p_health_plan_eff_date, sysdate)),
            deductible = p_deductible,
            plan_code = p_plan_code,
            debit_card_flag = p_debit_card_flag,
            ip_address = p_ip_address,
            last_update_date = sysdate,
            last_updated_by = 421
        where
            enrollment_id = p_enrollment_id;

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
                entrp_id,
                debit_card_flag,
                pers_id,
                acc_id,
                pc_account.get_salesrep_id(null, entrp_id) salesrep_id,
                acc_num
            from
                online_enrollment
            where
                enrollment_id = p_enrollment_id
        ) loop
            begin
                pc_log.log_error('update_enrollment, enrollment id', p_enrollment_id);
                l_fraud_account := 'N';
                x_return_status := 'S';
         /*    pc_online.check_fraud
            (p_first_name => x.first_name
            ,p_last_name  => x.last_name
            ,p_ssn        => x.ssn
            ,p_address    => x.address
            ,p_city       => x.city
            ,p_state      => x.state
            ,p_zip        => x.zip
            ,p_drivlic    => x.drivers_lic
            ,p_phone      => x.phone
            ,p_email      => x.email
            ,x_fraud_accunt => l_fraud_account
            ,x_return_status => x_return_status
            ,x_error_message => l_error_message);*/

                if l_fraud_account = 'Y'
                or x_return_status = 'E' then
                    x_error_message := 'Cannot enroll account. Please contact customer service at 800-617-4729 between 8AM-6PM Pacific Time.'
                    ;
                    pc_log.log_error('update_enrollment, x_error_message ', x_error_message);
                    raise l_setup_error;
                end if;

                select
                    count(*)
                into l_dup_count
                from
                    person  a,
                    account b
                where
                        replace(a.ssn, '-') = replace(x.ssn, '-')
                    and a.pers_id = b.pers_id
                    and b.account_type = 'HSA'
                    and a.pers_id <> x.pers_id
                    and b.acc_id <> x.acc_id
                    and b.account_status <> 4
                    and a.entrp_id = x.entrp_id;

                if l_dup_count > 0 then
                    x_error_message := x.ssn || ' cannot enroll, this ssn already has an account ';
                    raise l_setup_error;
                end if;

                update person
                set
                    first_name = (
                        case
                            when nvl(first_name, '-1') <> nvl(x.first_name, '-1') then
                                x.first_name
                            else
                                first_name
                        end
                    ),
                    middle_name = (
                        case
                            when nvl(middle_name, '-1') <> nvl(x.middle_name, '-1') then
                                x.middle_name
                            else
                                middle_name
                        end
                    ),
                    last_name = (
                        case
                            when nvl(last_name, '-1') <> nvl(x.last_name, '-1') then
                                x.last_name
                            else
                                last_name
                        end
                    ),
                    title = (
                        case
                            when nvl(title, '-1') <> nvl(x.title, '-1') then
                                x.title
                            else
                                title
                        end
                    )
 --         ,ssn         = (case when nvl(ssn,'-1') <> nvl(x.ssn,'-1') then x.ssn else ssn end) /* vanitha commented on 1/24/2021 to avoid ssn overwrite errors */
                    ,
                    drivlic = (
                        case
                            when nvl(drivlic, '-1') <> nvl(x.drivers_lic, '-1') then
                                x.drivers_lic
                            else
                                drivlic
                        end
                    ),
                    passport = (
                        case
                            when nvl(passport, '-1') <> nvl(x.passport, '-1') then
                                x.passport
                            else
                                passport
                        end
                    ),
                    address = (
                        case
                            when nvl(address, '-1') <> nvl(x.address, '-1') then
                                x.address
                            else
                                address
                        end
                    ),
                    city = (
                        case
                            when nvl(city, '-1') <> nvl(x.city, '-1') then
                                x.city
                            else
                                city
                        end
                    ),
                    state = (
                        case
                            when nvl(state, '-1') <> nvl(x.state, '-1') then
                                x.state
                            else
                                state
                        end
                    ),
                    zip = (
                        case
                            when nvl(zip, '-1') <> nvl(x.zip, '-1') then
                                x.zip
                            else
                                zip
                        end
                    ),
                    phone_day = (
                        case
                            when nvl(phone_day, '-1') <> nvl(x.phone, '-1') then
                                x.phone
                            else
                                phone_day
                        end
                    ),
                    email = (
                        case
                            when nvl(email, '-1') <> nvl(x.email, '-1') then
                                x.email
                            else
                                email
                        end
                    ),
                    gender = x.gender /*Ticket#7471. Modified on 12/27/2018 */,
                    note = 'Updated from online by the employee ',
                    last_update_date = sysdate,
                    last_updated_by = 421
                where
                    pers_id = x.pers_id;

                pc_log.log_error('update_enrollment', 'updating person');
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
                elsif l_effective_date > sysdate + 90
                      or x.health_plan_eff_date > sysdate + 90 then
                    x_error_message := 'Your account cannot be enrolled as the plan effective date is in future ';
                    raise l_setup_error;
                end if;

                update account
                set
                    plan_code = x.plan_code,
                    fee_maint = pc_plan.fmonth(x.plan_code),
                    note = 'Updated by account holder',
                    blocked_flag = decode(p_id_verification_status, 0, 'N', 'Y') -- added for id verification with veratad
                    ,
                    id_verified = decode(p_id_verification_status, 0, 'Y', 'N')
                           --   ,  start_date = GREATEST(NVL(l_effective_date,x.health_plan_eff_date),SYSDATE)
                where
                        plan_code <> x.plan_code
                    and pers_id = x.pers_id;

                select
                    count(*)
                into l_insur_count
                from
                    insure
                where
                    pers_id = x.pers_id;

                if l_insur_count = 0 then
                    insert into insure (
                        pers_id,
                        insur_id,
                        start_date,
                        deductible,
                        note,
                        plan_type
                    ) values ( x.pers_id,
                               x.carrier_id,
                               greatest(
                                   nvl(l_effective_date, x.health_plan_eff_date),
                                   sysdate
                               ),
                               nvl(x.deductible, l_deductible),
                               'Employee Online Enrollment',
                               x.plan_type );

                else
                    update insure
                    set
                        insur_id = x.carrier_id,
                        deductible = x.deductible,
                        start_date = greatest(
                            nvl(l_effective_date, x.health_plan_eff_date),
                            sysdate
                        ),
                        plan_type = x.plan_type,
                        note = 'Updated by employee online'
                    where
                        pers_id = x.pers_id;

                end if;

                pc_log.log_error('update_enrollment', 'updating insurance');
                if
                    x.debit_card_flag = 'Y'
                    and pc_person.card_allowed(x.pers_id) = 0
                then
                    select
                        count(*)
                    into l_card_count
                    from
                        card_debit
                    where
                        card_id = x.pers_id;

                    if l_card_count = 0 then
                        insert into card_debit (
                            card_id,
                            start_date,
                            emitent,
                            status,
                            note,
                            max_card_value,
                            last_update_date
                        ) values ( x.pers_id,
                                   greatest(x.health_plan_eff_date, sysdate),
                                   6763,
                                   case
                                       when pc_plan.can_create_card_on_pend(x.plan_code) = 'Y' then
                                           1
                                       else
                                           9
                                   end,
                                   'Automatic Online Enrollment',
                                   0,
                                   sysdate );
           --   PC_FIN.CARD_OPEN_FEE(x.pers_id);
                    end if;

                end if;

                pc_log.log_error('update_enrollment', 'creating card ');

           /*** Creating Debit Card Information ***/

                if pc_account.validate_enrollment(x.acc_id) is null then
                    update account
                    set
                        complete_flag = 1,
                        account_status = 3,
                        signature_on_file = 'Y'
                    where
                        pers_id = x.pers_id;

                else
                    update account
                    set
                        signature_on_file = 'Y',
                        note = pc_account.validate_enrollment(account.acc_id)
                    where
                        pers_id = x.pers_id;

                end if;

                pc_log.log_error('update_enrollment', 'doing id verfication ');
                if p_id_verification_status <> 0 then
                    pc_webservice_batch.process_online_verification(
                        p_acc_num           => x.acc_num,
                        p_transaction_id    => p_transaction_id,
                        p_verification_date => p_verification_date,
                        x_return_status     => x_return_status,
                        x_error_message     => l_error_message
                    );
     -- Vanitha:12/10/2018: this is moved inside process online verification
        --    UPDATE online_users
        --    SET    blocked = 'Y'
        --    WHERE  find_key = x.acc_num;
                end if;

                update online_enrollment
                set
                    enrollment_status = 'S',
                    error_message = null,
                    last_update_date = sysdate
                where
                    enrollment_id = p_enrollment_id;

            exception
                when others then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := sqlerrm;
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
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
                                                || 'dep_flag '
                                                || p_dep_flag.count
                                                || 'ben type '
                                                || p_beneficiary_type.count
                                                || 'ben relation count '
                                                || p_beneficiary_relation.count
                                                || ' dist '
                                                || p_ben_distiribution.count
                                                || 'debit card flag '
                                                || p_dep_debit_card_flag.count);

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
                format_to_date(a.birth_date) birth_date,
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
                )                            card_status,
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
                    card_issue_flag
                ) values ( pers_seq.nextval,
                           x.first_name,
                           x.middle_name,
                           x.last_name,
                           x.birth_date,
                           x.gender,
                           x.ssn,
                           to_number(x.relative),
                           'Online Enrollments',
                           x.pers_id,
                           'DEPENDANT',
                           x.mass_enrollment_id,
                           x.debit_card_flag ) returning pers_id into l_dep_pers_id;

                if x.debit_card_flag = 'Y' then
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
                           x.distiribution,
                           'Online Automatic Enrollments',
                           x.mass_enrollment_id );

            end if;

        end loop;

    exception
        when l_setup_error then
            rollback;
            x_return_status := 'E';
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Exception in enrollment  ' || x_error_message);
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := x_error_message
                               || ' '
                               || sqlerrm;
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'Exception in enrollment  ' || x_error_message);
    end pc_update_enrollment;

    procedure pc_delete_enrollment (
        p_enrollment_id in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        x_return_status := 'S';
        delete from online_enrollment
        where
            enrollment_id = p_enrollment_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end pc_delete_enrollment;

    procedure pc_insert_dependant (
        p_subscriber_ssn       in varchar2,
        p_first_name           in varchar2,
        p_middle_name          in varchar2,
        p_last_name            in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_relative             in varchar2,
        p_dep_flag             in varchar2,
        p_account_type         in varchar2   -- changed on 04/23/2011
        ,
        p_beneficiary_type     in varchar2 default null,
        p_beneficiary_relation in varchar2 default null,
        p_effective_date       in date default null,
        p_distiribution        in varchar2 default null,
        p_debit_card_flag      in varchar2 default 'N',
        x_enrollment_id        out varchar2,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
        l_pers_id       number;
        l_enrollment_id number;
        l_error_message varchar2(3200);
        l_card_count    number;
        setup_exception exception;
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_INSERT_DEPENDANT', 'Inserting into dependant');
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
            last_updated_by,
            account_type
        ) values ( mass_enrollments_seq.nextval,
                   p_subscriber_ssn,
                   p_first_name,
                   p_middle_name,
                   p_last_name,
                   upper(p_gender),
                   p_birth_date,
                   p_ssn,
                   p_relative,
                   nvl(p_dep_flag, 'N'),
                   nvl(p_beneficiary_type, 'PRIMARY'),
                   initcap(p_beneficiary_relation),
                   p_effective_date,
                   p_distiribution,
                   p_debit_card_flag,
                   sysdate,
                   421,
                   sysdate,
                   421,
                   p_account_type ) returning mass_enrollment_id into x_enrollment_id;

        for x in (
            select
                count(*) dep_count
            from
                person                per,
                account               acc,
                mass_enroll_dependant md,
                person                sub
            where
                    md.mass_enrollment_id = x_enrollment_id
                and sub.pers_id = acc.pers_id
                and per.ssn = md.ssn
                and sub.ssn = md.subscriber_ssn
                and per.pers_end_date is null
                and acc.account_type = nvl(md.account_type, 'HSA')
        ) loop
            if x.dep_count > 1 then
                x_error_message := 'Cannot add dependent, Your account already has dependent with same social security number ';
                raise setup_exception;
            end if;
        end loop;

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
                (
                    select
                        c.start_date
                    from
                        insure c
                    where
                        c.pers_id = b.pers_id
                ) start_date,
                (
                    select
                        status
                    from
                        card_debit
                    where
                        card_id = b.pers_id
                ) card_status,
                a.created_by
            from
                mass_enroll_dependant a,
                person                b,
                account               d
            where
                    format_ssn(a.subscriber_ssn) = b.ssn
                and d.pers_id = b.pers_id
                and d.account_type = nvl(a.account_type, 'HSA')
                and a.mass_enrollment_id = x_enrollment_id
        ) loop
            if upper(x.dep_flag) = 'DEPENDANT' then

           /*   IF x.ssn_count > 0 THEN
                UPDATE person
                SET    pers_end_date = NULL
                   ,   card_issue_flag = x.debit_card_flag
                   ,   last_updated_by = x.created_by
                   ,   last_update_date = SYSDATE
                WHERE  ssn = x.ssn RETURNING pers_id INTO l_pers_id;
                IF x.debit_card_flag = 'Y' THEN
                    UPDATE card_debit
                    SET    status = 1
                       ,   terminated = 'N'
                       ,   last_update_date = SYSDATE
                       ,   note ='Upated from Online'||note
                    WHERE  card_id IN (SELECT pers_id FROM person WHERE ssn =  x.ssn)
                    AND    status = 3;
                   IF  SQL%ROWCOUNT = 0 THEN
                       INSERT INTO CARD_DEBIT
                          (card_id,start_date,emitent,
                          status,note,max_card_value,
                          last_update_date)
                          VALUES( l_pers_id
                          ,GREATEST(x.start_date,SYSDATE)
                          ,6763
                          ,decode(x.card_status,9,9,1)
                          ,'Automatic Online Enrollment'
                          ,0
                          ,SYSDATE);
                  END IF;
                END IF;
              ELSE*/
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
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    card_issue_flag
                ) values ( pers_seq.nextval,
                           x.first_name,
                           x.middle_name,
                           x.last_name,
                           to_date(x.birth_date, 'DD-MON-YYYY'),
                           x.gender,
                           x.ssn,
                           to_number(x.relative),
                           'Online Enrollments',
                           x.pers_id,
                           'DEPENDANT',
                           x_enrollment_id,
                           x.created_by,
                           sysdate,
                           x.created_by,
                           sysdate,
                           x.debit_card_flag ) returning pers_id into l_pers_id;

                if x.debit_card_flag = 'Y' then
                    insert into card_debit (
                        card_id,
                        start_date,
                        emitent,
                        status,
                        note,
                        max_card_value,
                        last_update_date
                    ) values ( l_pers_id,
                               greatest(x.start_date, sysdate),
                               6763,
                               decode(x.card_status, 9, 9, 1),
                               'Automatic Online Enrollment',
                               0,
                               sysdate );

                        --  PC_FIN.CARD_OPEN_FEE(x.pers_id);
                end if;
           --  END IF;
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
                           x.first_name
                           || ' '
                           || x.last_name,
                           x.beneficiary_type,
                           x.beneficiary_relation,
                           nvl(to_date(x.effective_date, 'DD-MON-YYYY'), sysdate),
                           x.pers_id,
                           sysdate,
                           421,
                           x.distiribution,
                           'Online Automatic Enrollments',
                           x_enrollment_id );

            end if;

        end loop;

    exception
        when setup_exception then
            x_return_status := 'E';
        when others then
            x_return_status := 'E';
            l_error_message := sqlerrm;
            pc_log.log_error('PC_INSERT_DEPENDANT', 'Exception in dependent creation ' || l_error_message);
            x_error_message := sqlerrm;
    end pc_insert_dependant;

    procedure pc_insert_dependant_plb (
        p_subscriber_ssn       in varchar2,
        p_first_name           in varchar2,
        p_middle_name          in varchar2,
        p_last_name            in varchar2,
        p_gender               in varchar2,
        p_birth_date           in varchar2,
        p_ssn                  in varchar2,
        p_relative             in varchar2,
        p_dep_flag             in varchar2,
        p_beneficiary_type     in varchar2 default null,
        p_beneficiary_relation in varchar2 default null,
        p_effective_date       in date default null,
        p_distiribution        in varchar2 default null,
        p_debit_card_flag      in varchar2 default 'N',
        x_enrollment_id        out varchar2,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
        l_pers_id       number;
        l_enrollment_id number;
        l_error_message varchar2(3200);
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_INSERT_DEPENDANT', 'Inserting into dependant');
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
        ) values ( mass_enrollments_seq.nextval,
                   p_subscriber_ssn,
                   p_first_name,
                   p_middle_name,
                   p_last_name,
                   upper(p_gender),
                   p_birth_date,
                   p_ssn,
                   p_relative,
                   nvl(p_dep_flag, 'N'),
                   nvl(p_beneficiary_type, 'PRIMARY'),
                   initcap(p_beneficiary_relation),
                   p_effective_date,
                   p_distiribution,
                   p_debit_card_flag,
                   sysdate,
                   421,
                   sysdate,
                   421 ) returning mass_enrollment_id into x_enrollment_id;

        commit;
        pc_log.log_error('PC_INSERT_DEPENDANT_PLB', 'Inserting into mass_enroll_dependant' || x_enrollment_id);
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
                c.start_date
            from
                mass_enroll_dependant a,
                person                b,
                insure                c
            where
                    a.subscriber_ssn = b.ssn
                and b.pers_id = c.pers_id
                and a.mass_enrollment_id = x_enrollment_id
        ) loop
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
                           to_date(x.birth_date, 'YYYY-MM-DD'),
                           x.gender,
                           x.ssn,
                           to_number(x.relative),
                           'Online Enrollments',
                           x.pers_id,
                           'DEPENDANT',
                           x_enrollment_id,
                           'N',
                           sysdate ) returning pers_id into l_pers_id;

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
                           x.first_name
                           || ' '
                           || x.last_name,
                           x.beneficiary_type,
                           x.beneficiary_relation,
                           to_date(x.effective_date, 'YYYY-MM-DD'),
                           x.pers_id,
                           sysdate,
                           421,
                           x.distiribution,
                           'Online Automatic Enrollments',
                           x_enrollment_id );

            end if;

        end loop;

    exception
        when others then
            x_return_status := 'E';
            l_error_message := sqlerrm;
            pc_log.log_error('PC_INSERT_DEPENDANT_PLB', 'Exception in dependant creation ' || l_error_message);
            x_error_message := sqlerrm;
    end pc_insert_dependant_plb;

    procedure update_address (
        p_pers_id       in number,
        p_address       in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zip           in varchar2,
        p_phone         in varchar2,
        p_email         in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_address_changed varchar(1) := 'N';
        l_phone_changed   varchar(1) := 'N';
        l_ssn             varchar2(30);
        l_phone_1         varchar2(100);   -- Added by Swamy for Ticket#9048 on 06-May-2020
        l_phone_2         varchar2(100);   -- Added by Swamy for Ticket#9048 on 06-May-2020

    begin
        x_return_status := 'S';
        for x in (
            select
                address,
                phone_day
            from
                person
            where
                pers_id = p_pers_id
        ) loop
            if p_address <> x.address then
                l_address_changed := 'Y';
            end if;

		  /*
          IF p_phone <> x.phone_day THEN
             l_phone_changed := 'Y';
          END if;
          */

		  -- Commented above and Added below by Swamy for Ticket#9048 on 06-May-2020
            l_phone_1 := regexp_replace(p_phone, '[^[:digit:]]', '');
            l_phone_2 := regexp_replace(x.phone_day, '[^[:digit:]]', '');
            if nvl(l_phone_1, '@') <> nvl(l_phone_2, '@') then
                l_phone_changed := 'Y';
            end if;

        end loop;

        update person
        set
            address = nvl(p_address, address),
            city = nvl(p_city, city),
            state = nvl(p_state, state),
            zip = nvl(p_zip, zip)
       --   , phone_day   = NVL(p_phone,phone_day)     -- Commented phone and email for Ticket# 9774 as the update to person table is happening in pc_user_security_pkg.update_otp_phone which is called from online after update_address.
         -- , email   = NVL(p_email,email)
            ,
            last_updated_by = p_user_id     -- Added by Joshi For Ticket#9776
            ,
            last_update_date = sysdate       -- Added by Joshi For Ticket#9776
        where
            pers_id = p_pers_id
        returning replace(ssn, '-') into l_ssn;

    -- START Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21
        if l_address_changed = 'Y' then
        -- Insert the details into Event_Notification Table based on Alert_Preferences settings.
            pc_notification2.insert_events(
                p_acc_id      => null,
                p_pers_id     => p_pers_id,
                p_event_name  => 'ADDRESS',
                p_entity_type => 'PERSON',
                p_entity_id   => p_pers_id,
                p_ssn         => l_ssn
            );
        end if;

     -- Commented below update by swamy for Ticket# 9774 as the update to online_users table for email is happening in pc_user_security_pkg.update_otp_phone which is called from online after update_address.
    /*UPDATE online_users
     SET    email = NVL(p_email,email)
     WHERE  tax_id = l_ssn;
     */

-- Commented by Swamy for Ticket#9774
-- Only changes of verified phone related to online_user_security table should be sent notification and stored in online_user_security_history table
-- Below is the changes related to person table and person table phone is not in sync with online_user_security table so commenting the code
/*    -- START Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21
    IF l_phone_changed = 'Y'  THEN
        -- Insert the details into Event_Notification Table based on Alert_Preferences settings.
        pc_notification2.INSERT_EVENTS(p_acc_id     =>  NULL ,
                                       p_pers_id    => p_pers_id,
                                       p_event_name => 'PHONE',
                                       p_ENTITY_TYPE => 'ONLINE_USERS',
                                       P_ENTITY_ID  =>p_pers_id,
                                       p_ssn        => l_ssn);

         -- Added below by Swamy for Ticket#9048 on 06-May-2020
		 pc_notification2.insert_audit_security_info(
                                  p_pers_id     => p_pers_id,
                                  p_email       => NULL,
                                  p_phone_no    => l_phone_2,
                                  p_user_id     => p_user_id);

    END IF;
*/

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_address;

    procedure update_user (
        p_user_id       in number,
        p_user_name     in varchar2,
        p_password      in varchar2,
        p_pwd_question  in varchar2,
        p_pwd_answer    in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        update online_users
        set
            user_name = nvl(p_user_name, p_user_name),
            password = p_password,
            pw_question = p_pwd_question,
            pw_answer = p_pwd_answer
        where
            user_id = p_user_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_user;

    procedure delete_dependant (
        p_pers_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        delete from person
        where
            pers_id = p_pers_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end delete_dependant;

    procedure delete_beneficiary (
        p_beneficiary_id in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
    begin
        x_return_status := 'S';
        delete from beneficiary
        where
            beneficiary_id = p_beneficiary_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end delete_beneficiary;

    procedure pc_emp_batch_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_return_status  varchar2(30);
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_file_upload_id number;
    begin
        pc_log.log_error('PC_EMP_BATCH_ENROLLMENT', 'in emp batch enrollment ');
        x_return_status := 'S';
        pc_log.log_error('PC_EMP_BATCH_ENROLLMENT', 'in emp batch enrollment ');
        if p_file_name is not null then

	   --------  added by rprabu 7781 30/05/2019
            update online_enrollment
            set
                created_by = p_user_id,
                last_updated_by = p_user_id
            where
                batch_number = p_batch_number;

            insert into file_upload_history (
                file_upload_id,
                entrp_id,
                file_name,
                batch_number,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( file_upload_history_seq.nextval,
                       p_entrp_id,
                       p_file_name,
                       p_batch_number,
                       sysdate,
                       p_user_id --- 7781 rprabu 30/05/2019. 421 replaced with p_user_id
                       ,
                       sysdate,
                       p_user_id --- 7781 rprabu 30/05/2019 421 replaced with p_user_id
                        ) returning file_upload_id into l_file_upload_id;

        end if;

        pc_log.log_error('PC_EMP_BATCH_ENROLLMENT', 'calling online enrollment ' || p_batch_number);
        for x in (
            select
                initcap(a.first_name)                                      first_name,
                a.middle_name,
                initcap(a.last_name)                                       last_name,
                a.title,
                upper(a.gender)                                            gender,
                lpad(a.ssn, 11, '0')                                       ssn,
                a.enrollment_id,
                a.entrp_id,
                a.phone,
                a.email,
                b.plan_code,
                a.health_plan_eff_date,
                a.start_date,
                b.broker_id,
                a.deductible,
                decode(id_type, 'D', id_number)                            drivers_lic,
                decode(id_type, 'P', id_number)                            passport,
                a.address,
                initcap(a.city)                                            city,
                upper(a.state)                                             state,
                a.zip,
                a.birth_date,
                a.plan_type,
                nvl(a.carrier_id,
                    (
                    select
                        entrp_id
                    from
                        enterprise
                    where
                        regexp_like(upper(name),
                                    '\'
                                    || upper(carrier_name)
                                    || '\')
                        and rownum = 1
                ))                                                         carrier_id,
                a.lang_perf,
                pc_account.get_salesrep_id(null, b.entrp_id)               salesrep_id,
                pc_sales_team.get_salesrep_detail(b.entrp_id, 'SECONDARY') am_id /* Ticket#5461 */,
                a.division_code
            from
                online_enrollment a,
                account           b
            where
                    batch_number = p_batch_number
                and enrollment_status is null
                and a.entrp_id = b.entrp_id
        ) loop
            pc_log.log_error('PC_EMP_BATCH_ENROLLMENT', 'processing for  ' || x.ssn);
            savepoint enroll_savepoint;
            begin
                pc_log.log_error('PC_EMP_BATCH_ENROLLMENT', 'processing for  ' || x.ssn);
                if x.birth_date > sysdate then
                    l_error_message := x.ssn || ' cannot enroll, Date of birth is in future ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.last_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.last_name)
                                       || ' are not allowed for last name ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.first_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.first_name)
                                       || ' are not allowed for first name ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.middle_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.middle_name)
                                       || ' are not allowed for middle name ';
                    raise l_create_error;
                end if;

                if regexp_like(
                    replace(x.ssn, '-'),
                    '^[[:digit:]]{9}$'
                ) then
                    null;
                else
                    l_error_message := x.ssn || ' cannot enroll, SSN must be in the format of 999-99-9999';
                    raise l_create_error;
                end if;

                if pc_account.check_duplicate(x.ssn, null, null, 'HSA', x.entrp_id) = 'Y' then
                    l_error_message := x.ssn || ' cannot enroll, this ssn already has an account ';
                    raise l_create_error;
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
                    last_updated_by,
                    division_code
                ) values ( pers_seq.nextval,
                           x.first_name,
                           substr(x.middle_name, 1, 1),
                           x.last_name,
                           x.birth_date,
                           initcap(x.title),
                           x.gender,
                           x.ssn,
                           x.drivers_lic,
                           x.passport,
                           x.address,
                           x.city,
                           x.state,
                           x.zip,
                           x.phone,
                           x.email,
                           1,
                           'Online Enrollment',
                           x.entrp_id,
                           'SUBSCRIBER',
                           x.enrollment_id,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           x.division_code ) returning pers_id into l_pers_id;

                pc_log.log_error('PC_ONLINE_ENROLLMENT', 'inserted  ' || l_pers_id);
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
                    broker_id,
                    note,
                    fee_setup,
                    fee_maint,
                    reg_date,
                    account_status,
                    complete_flag,
                    signature_on_file,
                    account_type,
                    enrollment_source,
                    lang_perf,
                    created_by,
                    last_updated_by,
                    salesrep_id,
                    am_id
                )/*Ticket#5461 */ values ( acc_seq.nextval,
                           l_pers_id,
                           l_acc_num,
                           x.plan_code,
                           greatest(
                               nvl(x.health_plan_eff_date, x.start_date),
                               sysdate
                           ),
                           x.broker_id,
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
                           0,
                           'N',
                           'HSA',
                           'ONLINE',
                           x.lang_perf,
                           p_user_id,
                           p_user_id,
                           x.salesrep_id,
                           x.am_id )/*Ticket#5461 */ returning acc_id into l_acc_id;

                dbms_output.put_line('creating insure ');

           /*** Creating Insurance Information ***/

                if l_return_status <> 'S' then
                    raise l_create_error;
                end if;
                update online_enrollment
                set
                    acc_id = l_acc_id,
                    pers_id = l_pers_id,
                    acc_num = l_acc_num,
                    enrollment_status = 'S'
                where
                    enrollment_id = x.enrollment_id;

		 -- Added by Joshi for 6794 : ACN Migration. migrate new standard accounts
                if
                    x.plan_code = 1
                    and pc_acn_migration.is_employer_migrated(x.entrp_id) = 'Y'
                then
                    insert into acn_employee_migration (
                        mig_seq_no,
                        acc_id,
                        pers_id,
                        account_type,
                        emp_acc_id,
                        action_type,
                        subscriber_type,
                        creation_date,
                        created_by
                    ) values ( mig_seq.nextval,
                               l_acc_id,
                               l_pers_id,
                               'HSA',
                               pc_entrp.get_acc_id(x.entrp_id),
                               'I',
                               'E',
                               sysdate,
                               0 );

                end if;
        -- code ends here Joshi.

            exception
                when l_create_error then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || l_error_message;
           --   x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                when others then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                    dbms_output.put_line('error message ' || sqlerrm);
            end;

        end loop;

        if p_file_name is not null then
            for x in (
                select
                    sum(
                        case
                            when enrollment_status = 'S' then
                                1
                            else
                                0
                        end
                    ) success_cnt,
                    sum(
                        case
                            when nvl(enrollment_status, 'E') <> 'S' then
                                1
                            else
                                0
                        end
                    ) failure_cnt
                from
                    online_enrollment
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = l_file_upload_id;

                else
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' employees, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' employees failed to load '
                        )
                    where
                        file_upload_id = l_file_upload_id;

                end if;
            end loop;
        end if;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_message
                               || ' '
                               || sqlerrm;
    end pc_emp_batch_enrollment;

    procedure pc_enroll_batch (
        p_first_name_tbl     in varchar2_tbl,
        p_last_name_tbl      in varchar2_tbl,
        p_email_tbl          in varchar2_tbl,
        p_ssn_tbl            in varchar2_tbl,
        p_birth_date_tbl     in varchar2_tbl,
        p_state_tbl          in varchar2_tbl,
        p_effective_date_tbl in varchar2_tbl,
        p_entrp_id           in number,
        p_ip_address         in varchar2,
        p_lang_perf          in varchar2,
        p_batch_number       in varchar2,
        p_user_id            in number,
        p_enroll_source      in varchar2   -- Added By Jaggi ##9699
        ,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        l_status             varchar2(30);
        l_error_message      varchar2(3200);
        l_first_name_tbl     varchar2_tbl;
        l_last_name_tbl      varchar2_tbl;
        l_email_tbl          varchar2_tbl;
        l_ssn_tbl            varchar2_tbl;
        l_birth_date_tbl     varchar2_tbl;
        l_state_tbl          varchar2_tbl;
        l_effective_date_tbl varchar2_tbl;
        l_birth_date         date;
        j                    number := 0;
    begin
        pc_log.log_error('PC_BATCH_ENROLL',
                         'Processing Enrollment on ' || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss'));
        x_return_status := 'S';
        pc_log.log_error('PC_BATCH_ENROLL', 'No of employees to process ' || p_first_name_tbl.count);
        for i in 1..p_first_name_tbl.count loop
            if
                p_first_name_tbl(i) is null
                and p_last_name_tbl(i) is null
                and p_email_tbl(i) is null
                and p_ssn_tbl(i) is null
                and p_birth_date_tbl(i) is null
                and p_effective_date_tbl(i) is null
            then
                null;
            else
                j := j + 1;
                l_first_name_tbl(j) := p_first_name_tbl(i);
                l_last_name_tbl(j) := p_last_name_tbl(i);
                l_email_tbl(j) := p_email_tbl(i);
                l_ssn_tbl(j) := p_ssn_tbl(i);
                l_birth_date_tbl(j) := p_birth_date_tbl(i);
                l_state_tbl(j) := p_state_tbl(i);
                l_effective_date_tbl(j) := p_effective_date_tbl(i);
            end if;
        end loop;

        pc_log.log_error('PC_BATCH_ENROLL', 'No of employees to process ' || l_first_name_tbl.count);
        for i in 1..l_first_name_tbl.count loop
            l_status := 'S';
            l_error_message := '';
            l_birth_date := null;
            if l_last_name_tbl(i) is null then
                l_status := 'E';
                l_error_message := l_error_message || ' Last name cannot be null';
            end if;

            if isalphanumeric(l_last_name_tbl(i)) is not null then
                l_status := 'E';
                l_error_message := l_error_message
                                   || ' Special Characters '
                                   || isalphanumeric(l_last_name_tbl(i))
                                   || ' are not allowed for last name ';

            end if;

            if isalphanumeric(l_first_name_tbl(i)) is not null then
                l_status := 'E';
                l_error_message := l_error_message
                                   || ' Special Characters '
                                   || isalphanumeric(l_first_name_tbl(i))
                                   || ' are not allowed for first name ';

            end if;

            if l_ssn_tbl(i) is null then
                l_status := 'E';
                l_error_message := l_error_message || ' SSN cannot be null';
            else
                if regexp_like(
                    replace(
                        l_ssn_tbl(i),
                        '-'
                    ),
                    '^[[:digit:]]{9}$'
                ) then
                    null;
                else
                    l_status := 'E';
                    l_error_message := l_error_message || ' SSN must be in the format of 999-99-9999';
                end if;

                if l_ssn_tbl(i) <> format_ssn(replace(
                    l_ssn_tbl(i),
                    '-',
                    ''
                )) then    -- Added by Jaggi #11560 on 04/12/2023
                    l_status := 'E';
                    l_error_message := l_error_message || ' SSN must be in the format of 999-99-9999';
                end if;

            end if;

            if l_birth_date_tbl(i) is null then
                l_status := 'E';
                l_error_message := l_error_message || ' Birth Date cannot be null';
            else
                if is_date(
                    l_birth_date_tbl(i),
                    'MM/DD/RRRR'
                ) = 'N' then
                    l_status := 'E';
                    l_error_message := l_error_message || ' Enter valid Date of Birth in mm/dd/yyyy format';
                end if;

                if instr(
                    l_birth_date_tbl(i),
                    '/',
                    1,
                    2
                ) = 0 then
                    l_status := 'E';
                    l_error_message := l_error_message || ' Enter valid Date of Birth in mm/dd/yyyy format';
                end if;

                pc_log.log_error('ENROLL_BATCH',
                                 to_char(to_date(l_birth_date_tbl(i),
                                         'MM/DD/RRRR'),
                                         'MM/DD/RRRR'));

                if to_date ( l_birth_date_tbl(i), 'MM/DD/RRRR' ) > sysdate then
                    l_status := 'E';
                    pc_log.log_error('ENROLL_BATCH', 'Future dob validation');
                    l_error_message := l_error_message || ' Date of Birth Cannot be in future';
                end if;

                if l_status <> 'E' then
                    l_birth_date := to_date ( l_birth_date_tbl(i), 'MM/DD/RRRR' );
                end if;

            end if;

            if l_state_tbl(i) is null then
                l_status := 'E';
                l_error_message := l_error_message || ' State cannot be null';
            end if;

            if l_email_tbl(i) is null then
                l_status := 'E';
                l_error_message := l_error_message || ' Email Address cannot be null';
      /* ELSE
          IF  EMAILVALIDATE_V1(l_EMAIL_TBL(i))  = 0 THEN
              l_status := 'E';
              l_error_message := l_error_message||' Invalid Email Address';
	       END IF;*/
            end if;

            pc_log.log_error('PC_BATCH_ENROLL',
                             'Finished validation for SSN '
                             || p_ssn_tbl(i)
                             || 'Status '
                             || l_status
                             || 'error '
                             || l_error_message);

            pc_log.log_error('PC_BATCH_ENROLL', 'error ' || l_error_message);
            insert into online_enrollment (
                enrollment_id,
                batch_number,
                first_name,
                last_name,
                ssn,
                email,
                birth_date,
                state,
                health_plan_eff_date,
                entrp_id,
                ip_address,
                error_message,
                enrollment_status,
                enrollment_source               -- Added by Jaggi ##9699
                ,
                lang_perf,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( mass_enrollments_seq.nextval,
                       p_batch_number,
                       initcap(l_first_name_tbl(i)),
                       initcap(l_last_name_tbl(i)),
                       l_ssn_tbl(i),
                       l_email_tbl(i),
                       l_birth_date,
                       upper(l_state_tbl(i)),
                       to_date(l_effective_date_tbl(i),
                               'MM/DD/RRRR'),
                       p_entrp_id,
                       p_ip_address,
                       l_error_message,
                       decode(l_status, 'E', 'E', null),
                       p_enroll_source               -- Added by Jaggi ##9699
                       ,
                       p_lang_perf,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id );

            pc_log.log_error('PC_BATCH_ENROLL', 'Finished inserting for SSN ' || sql%rowcount);
        end loop;
 -- IF l_status <> 'E' THEN

        pc_log.log_error('PC_BATCH_ENROLL', 'Calling batch enrollment ');
        pc_emp_batch_enrollment(
            p_batch_number  => p_batch_number,
            p_entrp_id      => p_entrp_id,
            p_file_name     => null,
            p_lang_perf     => p_lang_perf,
            p_user_id       => p_user_id,
            x_error_message => x_error_message,
            x_return_status => x_return_status
        );

        pc_log.log_error('PC_BATCH_ENROLL', 'After Calling batch enrollment ' || x_error_message);
        if x_return_status <> 'S' then
            x_return_status := 'E';
        end if;
 -- END IF;
    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end pc_enroll_batch;

    procedure validate_online_fsa_enroll (
        p_batch_number in number,
        p_user_id      in number
    ) is
    begin
        update online_enrollment
        set
            error_message = is_date(birth_date)
                            || ' ,Correct Birth Date'
        where
                account_type = 'FSA'
            and is_date(birth_date) <> 'Y'
            and batch_number = p_batch_number;

        update online_enrollment
        set
            error_message = 'Gender Cannot have more than one character'
        where
                account_type = 'FSA'
            and length(gender) > 1
            and batch_number = p_batch_number;

        update online_enrollment
        set
            error_message = 'Middle Name Cannot have more than one character'
        where
                account_type = 'FSA'
            and length(middle_name) > 1
            and batch_number = p_batch_number;

        update online_enrollment
        set
            error_message = 'State Cannot have more than two character'
        where
                trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and length(state) > 2
            and error_message is null;

 /*
       UPDATE ONLINE_ENROLLMENT
       SET    ERROR_MESSAGE = IS_DATE(HFSA_EFFECTIVE_DATE)||' ,Correct Health FSA Effective Date'
            , ERROR_COLUMN  = 'HFSA_EFFECTIVE_DATE'
       WHERE   ACCOUNT_TYPE  = 'FSA'
       AND    IS_DATE(HFSA_EFFECTIVE_DATE) <> 'Y'
       AND BATCH_NUMBER = P_BATCH_NUMBER;

        UPDATE ONLINE_ENROLLMENT
       SET    ERROR_MESSAGE = IS_DATE(DFSA_EFFECTIVE_DATE)||' ,Correct Dependant FSA Effective Date'
            , ERROR_COLUMN  = 'DFSA_EFFECTIVE_DATE'
       WHERE   BATCH_NUMBER = P_BATCH_NUMBER
       AND    ACCOUNT_TYPE  = 'FSA'
       AND    IS_DATE(DFSA_EFFECTIVE_DATE) <> 'Y' ;

        UPDATE ONLINE_ENROLLMENT
       SET    ERROR_MESSAGE = IS_DATE(TRANSIT_EFFECTIVE_DATE)||' ,Correct Transit Effective Date'
            , ERROR_COLUMN  = 'TRANSIT_EFFECTIVE_DATE'
       WHERE   BATCH_NUMBER = P_BATCH_NUMBER
       AND    ACCOUNT_TYPE  = 'FSA'
       AND    IS_DATE(TRANSIT_EFFECTIVE_DATE) <> 'Y' ;

        UPDATE ONLINE_ENROLLMENT
       SET    ERROR_MESSAGE = IS_DATE(PARKING_EFFECTIVE_DATE)||' ,Correct Parking Effective Date'
            , ERROR_COLUMN  = 'PARKING_EFFECTIVE_DATE'
       WHERE  BATCH_NUMBER = P_BATCH_NUMBER
       AND    ACCOUNT_TYPE  = 'FSA'
       AND    IS_DATE(PARKING_EFFECTIVE_DATE) <> 'Y';

        UPDATE ONLINE_ENROLLMENT
       SET    ERROR_MESSAGE = IS_DATE(BICYCLE_EFFECTIVE_DATE)||' ,Correct Bicycle Effective Date'
            , ERROR_COLUMN  = 'BICYCLE_EFFECTIVE_DATE'
       WHERE   BATCH_NUMBER = P_BATCH_NUMBER
       AND   IS_DATE(BICYCLE_EFFECTIVE_DATE) <> 'Y'
       AND    ACCOUNT_TYPE  = 'FSA';

        UPDATE ONLINE_ENROLLMENT
       SET    ERROR_MESSAGE = IS_DATE(POST_DED_EFFECTIVE_DATE)||' ,Correct Effective Date'
            , ERROR_COLUMN  = 'POST_DED_EFFECTIVE_DATE'
       WHERE  BATCH_NUMBER = P_BATCH_NUMBER
       AND   IS_DATE(POST_DED_EFFECTIVE_DATE) <> 'Y'
       AND    ACCOUNT_TYPE  = 'FSA';
 */

--     Validations
        update online_enrollment
        set
            error_message = 'Last Name Cannot be Null'
        where
            last_name is null
            and batch_number = p_batch_number
            and account_type = 'FSA';

        update online_enrollment
        set
            error_message = 'First Name Cannot be Null'
        where
            first_name is null
            and account_type = 'FSA'
            and batch_number = p_batch_number;

        update online_enrollment
        set
            error_message = 'Address Cannot be Null'
        where
            address is null
            and batch_number = p_batch_number
            and account_type = 'FSA';

        update online_enrollment
        set
            error_message = 'City Cannot be Null'
        where
            city is null
            and account_type = 'FSA'
            and batch_number = p_batch_number;

        update online_enrollment
        set
            error_message = 'State Cannot be Null'
        where
            state is null
            and account_type = 'FSA'
            and batch_number = p_batch_number;

        update online_enrollment
        set
            error_message = 'Zip Cannot be Null'
        where
            zip is null
            and batch_number = p_batch_number
            and account_type = 'FSA';

        update online_enrollment
        set
            error_message = 'Social Security Number Cannot be Null'
        where
            ssn is null
            and batch_number = p_batch_number
            and account_type = 'FSA';

        update online_enrollment
        set
            error_message = 'ZIP code must be in the form 99999'
        where
            ( length(zip) > 5
              or not regexp_like ( zip,
                                   '^[[:digit:]]+$' ) )
            and batch_number = p_batch_number
            and account_type = 'FSA';


     --  COMMIT;
    exception
        when others then
            raise_application_error('-20002', 'Error in Validation ' || sqlerrm);
    end validate_online_fsa_enroll;

    procedure pc_hra_emp_batch_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_return_status  varchar2(30);
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_file_upload_id number;
        l_ben_plan_id    number;
        l_er_ben_plan_id number;
        l_scheduler_id   number;
        l_sdetail_id     number;
    begin
        x_return_status := 'S';
        pc_log.log_error('pc_hra_emp_batch_enrollment', 'in emp hra batch enrollment ');
        if p_file_name is not null then
            insert into file_upload_history (
                file_upload_id,
                entrp_id,
                file_name,
                batch_number,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( file_upload_history_seq.nextval,
                       p_entrp_id,
                       p_file_name,
                       p_batch_number,
                       sysdate,
                       421,
                       sysdate,
                       421 ) returning file_upload_id into l_file_upload_id;

        end if;

        pc_log.log_error('pc_hra_emp_batch_enrollment', 'calling online enrollment ' || p_batch_number);
        for x in (
            select
                initcap(a.first_name)                        first_name,
                a.middle_name,
                initcap(a.last_name)                         last_name,
                upper(a.gender)                              gender,
                lpad(a.ssn, 11, '0')                         ssn,
                a.enrollment_id,
                a.entrp_id,
                a.phone,
                a.email,
                a.start_date,
                a.address,
                initcap(a.city)                              city,
                upper(a.state)                               state,
                a.zip,
                a.birth_date,
                upper(a.debit_card_flag)                     debit_card_flag,
                a.annual_election,
                b.plan_code,
                b.broker_id,
                a.plan_type,
                pc_plan.fsetup_hra(b.entrp_id)               fee_setup,
                pc_plan.fmonth_hra(b.entrp_id)               fee_month,
                pc_account.get_salesrep_id(null, b.entrp_id) salesrep_id,
                b.bps_hra_plan,
                b.acc_num,
                a.created_by,
                b.acc_id,
                a.deductible,
                nvl(a.lang_perf, 'ENGLISH')                  lang_perf,
                upper(a.division_code)                       division_code
            from
                online_enrollment a,
                account           b
            where
                    batch_number = p_batch_number
                and enrollment_status is null
                and a.entrp_id = b.entrp_id
        ) loop
            savepoint enroll_savepoint;
            begin
                pc_log.log_error('pc_hra_emp_batch_enrollment', 'processing for  ' || x.ssn);
                for xx in (
                    select
                        count(*) cnt
                    from
                        person
                    where
                            ssn = x.ssn
                        and entrp_id = x.entrp_id
                        and pc_account.check_duplicate(x.ssn, x.acc_num, null, 'HRA', x.entrp_id) = 'Y'
                ) loop
                    if xx.cnt > 0 then
                        l_error_message := x.ssn || ' cannot enroll, this ssn already has an account ';
                        raise l_create_error;
                    end if;
                end loop;

                if x.birth_date > sysdate then
                    l_error_message := x.ssn || ' cannot enroll, Date of birth is in future ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.last_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.last_name)
                                       || ' are not allowed for last name ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.first_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.first_name)
                                       || ' are not allowed for first name ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.middle_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.middle_name)
                                       || ' are not allowed for middle name ';
                    raise l_create_error;
                end if;

                if regexp_like(
                    replace(x.ssn, '-'),
                    '^[[:digit:]]{9}$'
                ) then
                    null;
                else
                    l_error_message := x.ssn || ' cannot enroll, SSN must be in the format of 999-99-9999';
                    raise l_create_error;
                end if;

                if
                    x.division_code is not null
                    and pc_employer_divisions.get_division_count(x.entrp_id,
                                                                 upper(x.division_code)) = 0
                then
                    l_error_message := x.ssn
                                       || ' cannot enroll, Cannot find Division code '
                                       || x.division_code;
                    raise l_create_error;
                end if;

                insert into person (
                    pers_id,
                    first_name,
                    middle_name,
                    last_name,
                    birth_date,
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
                    entrp_id,
                    person_type,
                    mass_enrollment_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    division_code
                ) values ( pers_seq.nextval,
                           ltrim(rtrim(x.first_name)),
                           substr(x.middle_name, 1, 1),
                           ltrim(rtrim(x.last_name)),
                           x.birth_date,
                           x.gender,
                           x.ssn,
                           ltrim(rtrim(x.address)),
                           ltrim(rtrim(x.city)),
                           ltrim(rtrim(x.state)),
                           x.zip,
                           x.phone,
                           ltrim(rtrim(x.email)),
                           1,
                           'Online Enrollment',
                           x.entrp_id,
                           'SUBSCRIBER',
                           x.enrollment_id,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           upper(x.division_code) ) returning pers_id into l_pers_id;

                l_acc_num := pc_account.generate_acc_num(x.plan_code,
                                                         upper(x.state));

                select
                    acc_seq.nextval
                into l_acc_id
                from
                    dual;

            /*** Insert Account, Insurance, Income and Debit Card ****/
         -- Insertinto Account
                insert into account (
                    acc_id,
                    pers_id,
                    entrp_id,
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
                    account_type,
                    annual_election,
                    bps_hra_plan,
                    salesrep_id,
                    lang_perf,
                    created_by,
                    last_updated_by
                ) values ( l_acc_id,
                           l_pers_id,
                           null,
                           l_acc_num,
                           x.plan_code,
                           x.start_date,
                           0,
                           nvl(x.broker_id, 0),
                           'Online Enrollment',
                           x.fee_setup,
                           x.fee_month,
                           sysdate,
                           1,
                           1,
                           'Y',
                           'HRA',
                           x.annual_election,
                           x.bps_hra_plan,
                           x.salesrep_id,
                           x.lang_perf,
                           p_user_id,
                           p_user_id );

                update person a
                set
                    acc_numc = reverse(l_acc_num)
                where
                    acc_numc is null;

                if x.debit_card_flag in ( 'Y', 'YES' ) then
                    insert into card_debit (
                        card_id,
                        start_date,
                        emitent,
                        note,
                        status,
                        card_number,
                        created_by,
                        last_updated_by,
                        last_update_date
                    )
                        select
                            l_pers_id,
                            nvl(x.start_date, sysdate),
                            6763 -- Metavante
                            ,
                            'Online Enrollment',
                            1,
                            null,
                            p_user_id,
                            p_user_id,
                            sysdate
                        from
                            dual
                        where
                            exists (
                                select
                                    *
                                from
                                    enterprise
                                where
                                        entrp_id = x.entrp_id
                                    and nvl(card_allowed, 1) = 0
                            );

                end if;

                l_er_ben_plan_id := pc_benefit_plans.get_er_ben_plan(p_entrp_id, 'HRA', x.start_date);
                if l_er_ben_plan_id is not null then
                    pc_benefit_plans.insert_benefit_plan(
                        p_er_ben_plan_id  => l_er_ben_plan_id,
                        p_acc_id          => l_acc_id,
                        p_effective_date  => to_char(x.start_date, 'RRRRMMDD'),
                        p_annual_election => x.annual_election,
                        p_eob_required    => null,
                        p_coverage_level  => x.plan_type,
                        p_batch_number    => p_batch_number,
                        x_return_status   => l_return_status,
                        x_error_message   => x_error_message
                    );

                    if l_return_status <> 'S' then
                        pc_log.log_error('PC_HRA_ONLINE_ENROLLMENT', 'Error in creating benefit plan , acc_id '
                                                                     || l_acc_id
                                                                     || ' for plan type '
                                                                     || x.plan_type);

                    end if;

                else
                    pc_log.log_error('PC_HRA_ONLINE_ENROLLMENT', 'Plan is not defined for , acc_id '
                                                                 || l_acc_id
                                                                 || ' for plan type '
                                                                 || x.plan_type);
                end if;

                update online_enrollment
                set
                    acc_id = l_acc_id,
                    pers_id = l_pers_id,
                    acc_num = l_acc_num,
                    enrollment_status = 'S'
                where
                    enrollment_id = x.enrollment_id;

            exception
                when l_create_error then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || l_error_message;
           --   x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                when others then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                    dbms_output.put_line('error message ' || sqlerrm);
            end;

        end loop;

        pc_benefit_plans.create_annual_election(
            p_batch_number  => p_batch_number,
            p_user_id       => p_user_id,
            x_return_status => x_return_status,
            x_error_message => l_error_message
        );

        pc_fin.create_prefunded_receipt(
            p_batch_number => p_batch_number,
            p_user_id      => 421,
            p_acc_num      => null
        );

        for x in (
            select
                b.acc_id ee_acc_id,
                a.acc_id,
                a.entrp_id,
                a.plan_type,
                a.plan_start_date,
                a.plan_end_date
            from
                ben_plan_enrollment_setup a,
                online_enrollment         b
            where
                    a.entrp_id = b.entrp_id
                and a.batch_number = b.batch_number
                and a.batch_number = p_batch_number
                and a.ben_plan_id = l_er_ben_plan_id
        ) loop
            l_scheduler_id := pc_schedule.get_scheduler_id(
                p_entrp_id        => x.entrp_id,
                p_acc_id          => x.acc_id,
                p_plan_type       => x.plan_type,
                p_plan_start_date => x.plan_start_date,
                p_plan_end_date   => x.plan_end_date
            );

     -- get scheduler id , if there is any add this employee to that schedule
            pc_schedule.ins_scheduler_details(
                p_scheduler_id        => l_scheduler_id,
                p_acc_id              => x.ee_acc_id,
                p_er_amount           => 0,
                p_ee_amount           => 0,
                p_er_fee_amount       => 0,
                p_ee_fee_amount       => 0,
                p_user_id             => p_user_id,
                x_scheduler_detail_id => l_sdetail_id,
                x_return_status       => l_return_status,
                x_error_message       => x_error_message
            );

        end loop;

        if p_file_name is not null then
            for x in (
                select
                    sum(
                        case
                            when enrollment_status = 'S' then
                                1
                            else
                                0
                        end
                    ) success_cnt,
                    sum(
                        case
                            when nvl(enrollment_status, 'E') <> 'S' then
                                1
                            else
                                0
                        end
                    ) failure_cnt
                from
                    online_enrollment
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = l_file_upload_id;

                else
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' employees, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' employees failed to load '
                        )
                    where
                        file_upload_id = l_file_upload_id;

                end if;
            end loop;
        end if;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_message
                               || ' '
                               || sqlerrm;
    end pc_hra_emp_batch_enrollment;

    procedure pc_fsa_emp_batch_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_return_status  varchar2(30) := 'S';
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_file_upload_id number;
        l_ben_plan_id    number;
        l_er_ben_plan_id number;
        l_account_status number := 1;
        l_complete_flag  number := 1;
        l_scheduler_id   number;
        l_sdetail_id     number;
    begin
        x_return_status := 'S';
        pc_log.log_error('pc_fsa_emp_batch_enrollment', 'in emp fsa batch enrollment ');
        if p_file_name is not null then
            insert into file_upload_history (
                file_upload_id,
                entrp_id,
                file_name,
                batch_number,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( file_upload_history_seq.nextval,
                       p_entrp_id,
                       p_file_name,
                       p_batch_number,
                       sysdate,
                       421,
                       sysdate,
                       421 ) returning file_upload_id into l_file_upload_id;

        end if;

        pc_log.log_error('pc_fsa_emp_batch_enrollment', 'calling online enrollment ' || p_batch_number);
        for x in (
            select
                initcap(a.first_name)                        first_name,
                a.middle_name,
                initcap(a.last_name)                         last_name,
                upper(a.gender)                              gender,
                lpad(a.ssn, 11, '0')                         ssn,
                a.enrollment_id,
                a.entrp_id,
                a.phone,
                a.email,
                a.start_date,
                a.address,
                initcap(a.city)                              city,
                upper(a.state)                               state,
                a.zip,
                a.birth_date,
                a.plan_type,
                upper(a.debit_card_flag)                     debit_card_flag,
                a.annual_election,
                b.plan_code,
                b.broker_id,
                pc_plan.fsetup_hra(b.entrp_id)               fee_setup,
                pc_plan.fmonth_hra(b.entrp_id)               fee_month,
                pc_account.get_salesrep_id(null, b.entrp_id) salesrep_id,
                b.bps_hra_plan,
                b.acc_num,
                a.created_by,
                b.acc_id,
                a.deductible,
                upper(a.division_code)                       division_code,
                a.lang_perf
            from
                online_enrollment a,
                account           b
            where
                    batch_number = p_batch_number
                and enrollment_status is null
                and a.entrp_id = b.entrp_id
        ) loop
            savepoint enroll_savepoint;
            begin
                pc_log.log_error('pc_hra_emp_batch_enrollment', 'processing for  ' || x.ssn);
                for xx in (
                    select
                        count(*) cnt
                    from
                        person
                    where
                            ssn = x.ssn
                        and entrp_id = x.entrp_id
                        and pc_account.check_duplicate(x.ssn, x.acc_num, null, 'FSA', x.entrp_id) = 'Y'
                ) loop
                    if xx.cnt > 0 then
                        l_error_message := x.ssn || ' cannot enroll, this ssn already has an account ';
                        raise l_create_error;
                    end if;
                end loop;

                if x.birth_date > sysdate then
                    l_error_message := x.ssn || ' cannot enroll, Date of birth is in future ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.last_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.last_name)
                                       || ' are not allowed for last name ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.first_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.first_name)
                                       || ' are not allowed for first name ';
                    raise l_create_error;
                end if;

                if isalphanumeric(x.middle_name) is not null then
                    l_error_message := ' Special Characters '
                                       || isalphanumeric(x.middle_name)
                                       || ' are not allowed for middle name ';
                    raise l_create_error;
                end if;

                if regexp_like(
                    replace(x.ssn, '-'),
                    '^[[:digit:]]{9}$'
                ) then
                    null;
                else
                    l_error_message := x.ssn || ' cannot enroll, SSN must be in the format of 999-99-9999';
                    raise l_create_error;
                end if;

                if
                    x.division_code is not null
                    and pc_employer_divisions.get_division_count(x.entrp_id,
                                                                 upper(x.division_code)) = 0
                then
                    l_error_message := x.ssn
                                       || ' cannot enroll, Cannot find Division code '
                                       || x.division_code;
                    raise l_create_error;
                end if;

                insert into person (
                    pers_id,
                    first_name,
                    middle_name,
                    last_name,
                    birth_date,
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
                    entrp_id,
                    person_type,
                    mass_enrollment_id,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    division_code
                ) values ( pers_seq.nextval,
                           ltrim(rtrim(x.first_name)),
                           substr(x.middle_name, 1, 1),
                           ltrim(rtrim(x.last_name)),
                           x.birth_date,
                           x.gender,
                           x.ssn,
                           ltrim(rtrim(x.address)),
                           ltrim(rtrim(x.city)),
                           ltrim(rtrim(x.state)),
                           x.zip,
                           x.phone,
                           ltrim(rtrim(x.email)),
                           1,
                           'Online Enrollment',
                           x.entrp_id,
                           'SUBSCRIBER',
                           x.enrollment_id,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           upper(x.division_code) ) returning pers_id into l_pers_id;

                l_account_status := 1;
                l_complete_flag := 1;
                pc_log.log_error('PC_FSA_ONLINE_ENROLLMENT', 'pers_id:  ' || l_pers_id);
                l_acc_num := pc_account.generate_acc_num(x.plan_code,
                                                         upper(x.state));

                select
                    acc_seq.nextval
                into l_acc_id
                from
                    dual;

            /*** Insert Account, Insurance, Income and Debit Card ****/
         -- Insertinto Account
                insert into account (
                    acc_id,
                    pers_id,
                    entrp_id,
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
                    account_type,
                    bps_hra_plan,
                    salesrep_id,
                    lang_perf,
                    created_by,
                    last_updated_by
                ) values ( l_acc_id,
                           l_pers_id,
                           null,
                           l_acc_num,
                           x.plan_code,
                           nvl(x.start_date, sysdate),
                           0,
                           nvl(x.broker_id, 0),
                           'Online Enrollment',
                           x.fee_setup,
                           x.fee_month,
                           sysdate,
                           1,
                           1,
                           'Y',
                           'FSA',
                           x.bps_hra_plan,
                           x.salesrep_id,
                           x.lang_perf,
                           p_user_id,
                           p_user_id );

                update person a
                set
                    acc_numc = reverse(l_acc_num)
                where
                    acc_numc is null;

                pc_log.log_error('PC_FSA_ONLINE_ENROLLMENT', 'Debit card inserting');
                if upper(x.debit_card_flag) in ( 'YES', 'Y' ) then
                    insert into card_debit (
                        card_id,
                        start_date,
                        emitent,
                        note,
                        status,
                        card_number,
                        created_by,
                        last_updated_by,
                        last_update_date
                    )
                        select
                            l_pers_id,
                            nvl(x.start_date, sysdate),
                            6763 -- Metavante
                            ,
                            'Online Enrollment',
                            1,
                            null,
                            p_user_id,
                            p_user_id,
                            sysdate
                        from
                            dual
                        where
                            exists (
                                select
                                    *
                                from
                                    enterprise
                                where
                                        entrp_id = x.entrp_id
                                    and nvl(card_allowed, 1) = 0
                            );

                end if;

                update online_enrollment
                set
                    acc_id = l_acc_id,
                    pers_id = l_pers_id,
                    acc_num = l_acc_num,
                    enrollment_status = 'S'
                where
                    enrollment_id = x.enrollment_id;

            exception
                when l_create_error then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || l_error_message;
                    pc_log.log_error('FSA EXCEPTION', 'error message ' || l_error_message);
           --   x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                when others then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    pc_log.log_error('FSA EXCEPTION', 'error message ' || l_error_message);
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                    dbms_output.put_line('error message ' || sqlerrm);
            end;

        end loop;

     -- create annual election
        pc_benefit_plans.create_annual_election(
            p_batch_number  => p_batch_number,
            p_user_id       => 421,
            x_return_status => x_return_status,
            x_error_message => l_error_message
        );
     -- create receipt for HRA plans
        pc_fin.create_prefunded_receipt(
            p_batch_number => p_batch_number,
            p_user_id      => 421,
            p_acc_num      => null
        );

        for x in (
            select
                b.acc_id ee_acc_id,
                a.acc_id,
                a.entrp_id,
                a.plan_type,
                a.plan_start_date,
                a.plan_end_date
            from
                ben_plan_enrollment_setup a,
                online_enrollment         b
            where
                    a.entrp_id = b.entrp_id
                and a.batch_number = b.batch_number
                and a.batch_number = p_batch_number
                and a.ben_plan_id = l_er_ben_plan_id
        ) loop
            l_scheduler_id := pc_schedule.get_scheduler_id(
                p_entrp_id        => x.entrp_id,
                p_acc_id          => x.acc_id,
                p_plan_type       => x.plan_type,
                p_plan_start_date => x.plan_start_date,
                p_plan_end_date   => x.plan_end_date
            );

     -- get scheduler id , if there is any add this employee to that schedule
            pc_schedule.ins_scheduler_details(
                p_scheduler_id        => l_scheduler_id,
                p_acc_id              => x.ee_acc_id,
                p_er_amount           => 0,
                p_ee_amount           => 0,
                p_er_fee_amount       => 0,
                p_ee_fee_amount       => 0,
                p_user_id             => p_user_id,
                x_scheduler_detail_id => l_sdetail_id,
                x_return_status       => l_return_status,
                x_error_message       => x_error_message
            );

        end loop;

        if p_file_name is not null then
            for x in (
                select
                    sum(
                        case
                            when enrollment_status = 'S' then
                                1
                            else
                                0
                        end
                    ) success_cnt,
                    sum(
                        case
                            when nvl(enrollment_status, 'E') <> 'S' then
                                1
                            else
                                0
                        end
                    ) failure_cnt
                from
                    online_enrollment
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = l_file_upload_id;

                else
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' employees, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' employees failed to load '
                        )
                    where
                        file_upload_id = l_file_upload_id;

                end if;
            end loop;
        end if;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_message
                               || ' '
                               || sqlerrm;
    end pc_fsa_emp_batch_enrollment;

    procedure pc_hrafsa_emp_batch_enrollment (
        p_batch_number   in varchar2,
        p_entrp_id       in varchar2,
        p_file_name      in varchar2,
        p_lang_perf      in varchar2,
        p_user_id        in number,
        p_enroll_source  in varchar2 default 'EXCEL',
        p_process_type   in varchar2 default null           --- Added by rprabu on 30/07/2019 for 7919
        ,
        p_file_upload_id out number                     --- Added by rprabu on 30/07/2019 for 7919
        ,
        x_error_message  out varchar2,
        x_return_status  out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_return_status  varchar2(30) := 'S';
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_file_upload_id number;
        l_ben_plan_id    number;
        l_er_ben_plan_id number;
        l_account_status number := 1;
        l_complete_flag  number := 1;
        l_scheduler_id   number;
        l_sdetail_id     number;
    begin
        x_return_status := 'S';
        pc_log.log_error('pc_fsa_emp_batch_enrollment', 'in emp fsa batch enrollment ' || p_file_name);
        if p_file_name is not null then
            insert into file_upload_history (
                file_upload_id,
                entrp_id,
                file_name,
                batch_number,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( file_upload_history_seq.nextval,
                       p_entrp_id,
                       p_file_name,
                       p_batch_number,
                       sysdate,
                       p_user_id --- 7781   rprabu 30/05/2019    421 replaced  with p_user_id
                       ,
                       sysdate,
                       p_user_id --- 7781  rprabu 30/05/2019    421 replaced  with p_user_id
                        ) returning file_upload_id into l_file_upload_id;

        end if;

        p_file_upload_id := l_file_upload_id;  ----          Added by rprabu on 30/07/2019 for 7919

        load_hrafsa_enrollment(p_batch_number,
                               p_entrp_id,
                               p_user_id, --- 7781 P_user_id added by rprabu 30/05/2019
                               nvl(p_enroll_source, 'EXCEL'),
                               x_error_message,
                               x_return_status);

       --- 7919 rprabu 21/08/2019
        update online_enrollment
        set
            process_type = p_process_type
        where
                batch_number = p_batch_number
            and entrp_id = p_entrp_id;

        pc_log.log_error('pc_fsa_emp_batch_enrollment', 'load_hrafsa_enrollment:return status ' || x_return_status);
        if x_return_status = 'S' then
            initialize_hrafsa_enrollment(p_batch_number, p_entrp_id, x_error_message, x_return_status);
            pc_log.log_error('pc_fsa_emp_batch_enrollment', 'initialize_hrafsa_enrollment:return status ' || x_return_status);
        end if;

        if x_return_status = 'S' then
            validate_hrafsa_enrollment(p_batch_number, p_entrp_id);
            pc_log.log_error('pc_fsa_emp_batch_enrollment', 'validate_hrafsa_enrollment:return status ' || x_return_status);
        end if;

        if x_return_status = 'S' then
            process_changes_enrollment(p_batch_number, p_entrp_id, x_error_message, x_return_status);
            pc_log.log_error('pc_fsa_emp_batch_enrollment', 'process_changes_enrollment:return status ' || x_return_status);
        end if;

        if x_return_status = 'S' then
            process_hrafsa_enrollment(p_batch_number, p_entrp_id, x_error_message, x_return_status);
            pc_log.log_error('pc_fsa_emp_batch_enrollment', 'process_hrafsa_enrollment:return status ' || x_return_status);
            pc_log.log_error('pc_fsa_emp_batch_enrollment', 'process_hrafsa_enrollment:error message ' || x_error_message);
        end if;

        if x_return_status = 'S' then
            pc_log.log_error('pc_fsa_emp_batch_enrollment', 'process_terminations:calling');
 /** PAYROLL CALENDAR SETTINGS **/

            for x in (
                select
                    me.acc_id,
                    me.entrp_id,
                    format_to_date(mep.termination_date) termination_date,
                    mep.plan_type,
                    bp.ben_plan_id,
                    mep.enroll_plan_id
                from
                    online_enrollment         me,
                    online_enroll_plans       mep,
                    ben_plan_enrollment_setup bp
                where
                        me.enrollment_id = mep.enrollment_id
                    and mep.plan_type = bp.plan_type
                    and me.acc_id = bp.acc_id
                    and bp.status <> 'R'
                --    and    MEP.STATUS IS NULL
                --    AND    (ME.ENROLLMENT_STATUS IS NULL OR ME.ENROLLMENT_STATUS = 'W')
                    and bp.ben_plan_id_main = mep.er_ben_plan_id
                    and me.batch_number = p_batch_number
            ) loop
                update online_enroll_plans
                set
                    ben_plan_id = x.ben_plan_id
                where
                    enroll_plan_id = x.enroll_plan_id;

            end loop;

            for xx in (
                select
                    me.acc_id,
                    mp.ben_plan_id,
                    mp.first_payroll_date,
                    mp.pay_contrb,
                    mp.no_of_periods,
                    mp.pay_cycle,
                    bp.effective_date,
                    me.created_by,
                    mp.er_ben_plan_id,
                    mp.plan_type,
                    me.entrp_id,
                    bp.product_type,
                    bp.annual_election,
                    bp.plan_end_date
                from
                    online_enrollment         me,
                    online_enroll_plans       mp,
                    ben_plan_enrollment_setup bp
                where
                        me.enrollment_id = mp.enrollment_id
                    and mp.ben_plan_id = bp.ben_plan_id
                    and me.batch_number = mp.batch_number
                    and mp.ben_plan_id is not null
                    and ( mp.first_payroll_date is not null
                          and mp.pay_contrb is not null
                          and mp.pay_cycle is not null )
                    and mp.batch_number = p_batch_number
                    and mp.action in ( 'N', 'R' )
            ) loop
                insert into pay_details (
                    pay_detail_id,
                    acc_id,
                    ben_plan_id,
                    first_payroll_date,
                    pay_contrb,
                    no_of_periods,
                    pay_cycle,
                    effective_date,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    ben_plan_id_main
                )
                    select
                        pay_details_seq.nextval,
                        xx.acc_id,
                        xx.ben_plan_id,
                        xx.first_payroll_date,
                        nvl(xx.pay_contrb,
                            pc_benefit_plans.calculate_pay_period(
                            p_plan_type     => xx.plan_type,
                            p_entrp_id      => xx.entrp_id,
                            p_ann_election  => xx.annual_election,
                            p_pay_cycle     => xx.pay_cycle,
                            p_eff_date      => to_char(xx.effective_date, 'MM/DD/YYYY'),
                            p_plan_end_date => to_char(xx.plan_end_date, 'MM/DD/YYYY')
                        )),
                        xx.no_of_periods,
                        xx.pay_cycle,
                        xx.effective_date,
                        sysdate,
                        xx.created_by,
                        sysdate,
                        xx.created_by,
                        xx.er_ben_plan_id
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                pay_details
                            where
                                    ben_plan_id = xx.ben_plan_id
                                and acc_id = xx.acc_id
                        );

            end loop;
         -- AND (ME.ENROLLMENT_STATUS IS NULL OR ME.ENROLLMENT_STATUS IN ('S','W'));
		  -- commented below IF clause by Joshi for Ticket #4827. annual election was not creating
        -- for Webform/enroll express enrollments.
        -- IF p_enroll_source = 'EXCEL' THEN
            pc_benefit_plans.create_annual_election(
                p_batch_number  => p_batch_number,
                p_user_id       => p_user_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );

            if x_return_status = 'S' then
                pc_fin.create_prefunded_receipt(
                    p_batch_number => p_batch_number,
                    p_user_id      => p_user_id
                );
            end if;
        -- END IF;
         -- AND (ME.ENROLLMENT_STATUS IS NULL OR ME.ENROLLMENT_STATUS IN ('S','W'));

            process_terminations(p_entrp_id, p_batch_number);
            update online_enroll_plans
            set
                status = 'Successfully Processed'
            where
                status is null
                and batch_number = p_batch_number;

            for xx in (
                select
                    sum(
                        case
                            when a.status = 'Successfully Processed' then
                                1
                            else
                                0
                        end
                    )        plan_count,
                    count(*) all_plan_count,
                    b.enrollment_id
                from
                    online_enroll_plans a,
                    online_enrollment   b
                where
                        a.enrollment_id = b.enrollment_id
                    and b.batch_number = p_batch_number
                    and b.account_type in ( 'HRA', 'FSA' )
                group by
                    b.enrollment_id
            ) loop
                pc_log.log_error('PC_HRAFSA_ONLINE_ENROLLMENT:xx.plan_count ', xx.plan_count);
                pc_log.log_error('PC_HRAFSA_ONLINE_ENROLLMENT:xx.all_plan_count ', xx.all_plan_count);
                if xx.plan_count = xx.all_plan_count then
                    update online_enrollment
                    set
                        enrollment_status = 'S'
                    where
                        enrollment_id = xx.enrollment_id;

                elsif
                    xx.plan_count < xx.all_plan_count
                    and xx.plan_count > 0
                then
                    update online_enrollment
                    set
                        enrollment_status = 'W'
                    where
                        enrollment_id = xx.enrollment_id;

                elsif
                    xx.plan_count < xx.all_plan_count
                    and xx.plan_count = 0
                then
                    update online_enrollment a
                    set
                        enrollment_status = 'E',
                        error_message = (
                            select
                                status
                            from
                                online_enroll_plans b
                            where
                                    status <> 'Successfully Processed'
                                and a.enrollment_id = b.enrollment_id
                                and rownum = 1
                        )
                    where
                        enrollment_id = xx.enrollment_id;

                    x_return_status := 'S';      --- Added by rprabu on 30/07/2019 for 7919
                end if;

            end loop;

        end if;

        if p_file_name is not null then
            for x in (
                select
                    sum(
                        case
                            when enrollment_status in('W', 'S') then
                                1
                            else
                                0
                        end
                    ) success_cnt,
                    sum(
                        case
                            when nvl(enrollment_status, 'E') not in('W', 'S') then
                                1
                            else
                                0
                        end
                    ) failure_cnt
                from
                    online_enrollment
                where
                        entrp_id = p_entrp_id
                    and batch_number = p_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = l_file_upload_id;

                    x_return_status := 'E';      --- Added by rprabu on 30/07/2019 for 7919

                else
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' employees, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' employees failed to load '
                        )
                    where
                        file_upload_id = l_file_upload_id;
			     --- if   Added by rprabu on 30/07/2019 for 7919
                    if nvl(x.failure_cnt, 0) = 0 then
                        x_return_status := 'S';     --- Added by rprabu on 30/07/2019 for 7919
                    else
                        x_return_status := 'E';     --- Added by rprabu on 30/07/2019 for 7919
                    end if;

                end if;
            end loop;
        end if;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_message
                               || ' '
                               || sqlerrm;
    end pc_hrafsa_emp_batch_enrollment;

    procedure load_hrafsa_enrollment (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_user_id       in number --- 7781 rprabu 30/05/2019
        ,
        p_enroll_source in varchar2 default 'EXCEL',
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_ONLINE_ENROLLMENT:load_hrafsa_enrollment ', 'Batch Number :'
                                                                         || p_batch_number
                                                                         || 'p_entrp_id '
                                                                         || p_entrp_id);
        pc_log.log_error('PC_ONLINE_ENROLLMENT:load_hrafsa_enrollment ..Source', p_enroll_source);

--IF P_ENROLL_SOURCE IS NULL OR P_ENROLL_SOURCE <> 'WEBFORM_ENROLL' THEN
        pc_log.log_error('PC_ONLINE_ENROLLMENT:load_hrafsa_enrollment ..Source', 'Loop');
        insert into online_enrollment (
            enrollment_id,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            phone,
            email,
            birth_date,
            ssn,
            debit_card_flag,
            plan_code,
            start_date,
            created_by, 			  --- 7781 rprabu 30/05/2019
            creation_date,
            last_updated_by, 	  --- 7781 rprabu 30/05/2019
            last_update_date,
            entrp_id,
            account_type,
            division_code,
            batch_number,
            acc_num,
            enrollment_source
        )
            select
                mass_enrollments_seq.nextval,
         -- strip_bad(INITCAP(a.FIRST_NAME)) ,
                initcap(a.first_name),              -- added by Jaggi #9959
                a.middle_name,
       -- strip_bad(INITCAP(a.LAST_NAME)),
                initcap(a.last_name),               -- added by Jaggi #9959
                a.gender,
                initcap(a.address),
                initcap(a.city),
                upper(a.state),
                a.zip,
                a.day_phone,
                a.email_address,
                a.birth_date,
                strip_bad(rtrim(ltrim(a.ssn))),
                nvl(a.debit_card, 'N') debit_card,
                a.plan_code,
                sysdate,
                p_user_id, --- 7781 rprabu 30/05/2019
                sysdate                creation_date,
                p_user_id, --- 7781 rprabu 30/05/2019
                sysdate                last_update_date,
                a.entrp_id,
                a.account_type,
                a.division_code,
                a.batch_number,
                a.acc_num,
                p_enroll_source
            from
                (
                    select distinct
                        a.first_name,
                        a.middle_name,
                        a.last_name,
                        initcap(a.gender)                       gender,
                        initcap(a.address)                      address,
                        initcap(a.city)                         city,
                        a.state,
                        case
                            when length(a.zip) < 5 then
                                lpad(a.zip, 5, '0')
                            else
                                zip
                        end                                     zip,
                        a.day_phone,
                        a.email_address,
         -- format_date(a.BIRTH_DATE) BIRTH_DATE ,
          -- TO_DATE(format_date(a.BIRTH_DATE),'MM/DD/YYYY') BIRTH_DATE,
                        decode(p_enroll_source,
                               'EXCEL',
                               to_date(format_date(a.birth_date),
                               'MM/DD/YYYY'),
                               format_date(a.birth_date))       birth_date,
                        format_ssn(a.ssn)                       ssn,
                        a.action,
                        upper(
                            case
                                when a.debit_card = 'YES' then
                                    'Y'
                                when a.debit_card = 'NO' then
                                    'N'
                                else a.debit_card
                            end
                        )                                       debit_card,
                        b.plan_code                             plan_code,
                        'Active'                                account_status,
                        'Yes'                                   setup_status,
                        initcap(nvl(a.conditional_issue, 'No')) conditional_issue,
                        null                                    error_message,
                        a.note,
                        a.entrp_id,
                        b.acc_num                               group_number,
                        b.account_type,
                        upper(a.division_code)                  division_code,
                        a.acc_num,
                        b.broker_id,
                        a.batch_number
                    from
                        online_hfsa_enroll_stage a,
                        account                  b
                    where
                            a.entrp_id = b.entrp_id
                        and a.batch_number = p_batch_number
                        and a.entrp_id = p_entrp_id
                ) a
            where
                not exists (
                    select
                        *
                    from
                        online_enrollment
                    where
                            ssn = format_ssn(a.ssn)
                        and batch_number = a.batch_number
                );
--END IF;
        pc_log.log_error('PC_ONLINE_ENROLLMENT:load_hrafsa_enrollment ..Source', 'Loop Out');
        pc_log.log_error('PC_ONLINE_ENROLLMENT ', 'Number of rows insert into Online enrollemnts' || sql%rowcount);
    --Insert into Mass Enroll Plans
        update online_enrollment
        set
            enrollment_status = 'E',
            error_message = 'Enter Valid Group Number'
        where
            entrp_id is null
            and batch_number = p_batch_number;

        update online_enrollment
        set
            enrollment_status = 'E',
            error_message = 'Enter Valid Account Number or Social Security Number'
        where
            acc_num is null
            and ssn is null
            and batch_number = p_batch_number;

        for x in (
            select
                ssn,
                count(*) cnt
            from
                online_enrollment
            where
                    batch_number = p_batch_number
                and account_type in ( 'HRA', 'FSA' )
            group by
                ssn
            having
                count(*) > 1
        ) loop
            if x.ssn is not null then
                update online_enrollment
                set
                    enrollment_status = 'E',
                    error_message = 'You are attempting to enroll in more than one plan , but values does not match between the rows,
                               Please enter same values across rows if a member is enrolling in more than one plan'
                where
                        ssn = x.ssn
                    and account_type in ( 'HRA', 'FSA' );

            end if;
        end loop;

    --Ticket#4363.Validate for combination of ACC Num and SSN .Modified on /08/14/2017
        for x in (
            select
                a.enrollment_id,
                c.pers_id,
                d.acc_num org_acc_num,--Ticket#4363
                d.acc_id,
                a.acc_num new_acc_num, --Ticket#4363
                a.ssn
            from
                online_enrollment a,
                person            c,
                account           d
            where
                    a.batch_number = p_batch_number
                and ( a.enrollment_status is null
                      or a.enrollment_status = 'W' )
                and a.entrp_id = c.entrp_id
                and ( a.ssn is not null
                      and replace(c.ssn, '-') = replace(
                    format_ssn(a.ssn),
                    '-'
                ) )
                and c.pers_id = d.pers_id
                and a.acc_num is not null
                and d.account_type in ( 'HRA', 'FSA' )
        ) loop
            if trim(x.org_acc_num) <> trim(x.new_acc_num) then --Ticket#4363

                update online_enrollment
                set
                    enrollment_status = 'E',
                    error_message = 'Account Number and SSN do not match '
                where
                        batch_number = p_batch_number
                    and enrollment_id = x.enrollment_id;

                update online_hfsa_enroll_stage
                set
                    process_status = 'ERROR'
                where
                        batch_number = p_batch_number
                    and ssn = x.ssn;

            end if;  --Ticket#4363 Modified on /08/14/2017
        end loop;

 /* Ticket#5180.Validating duplicate Acc and plans being renewed/emrolled */

        for x in (
            select
                acc_num,
                plan_type,
                effective_date,
                count(*) cnt
            from
                online_hfsa_enroll_stage
            where
                batch_number = p_batch_number
            group by
                acc_num,
                plan_type,
                effective_date
            having
                count(*) > 1
        ) loop
            update online_enrollment
            set
                enrollment_status = 'E',
                error_message = 'You are attempting to enroll in same plan multiple times'
            where
                    batch_number = p_batch_number
                and acc_num = x.acc_num;

     ---  AND   entrp_id = p_entrp_id;
        end loop;
  /* Ticket#5180 */
        pc_log.log_error('PC_ONLINE_ENROLLMENT:load_hrafsa_enrollment ..Source', 'Loop Plan');

      -- added decode below for coverage tier name  by Joshi for not removing any char while webform/enroll express enrolments #4884
        insert into online_enroll_plans (
            enroll_plan_id,
            plan_type,
            deductible,
            effective_date,
            annual_election,
            first_payroll_date,
            pay_contrb,
            no_of_periods,
            pay_cycle,
            action,
            covg_tier_name,
            conditional_issue,
            note,
            batch_number,
            enrollment_id,
            created_by,
            creation_date,
            last_update_date,
            last_updated_by,
            termination_date,
            life_event_code,
            er_ben_plan_id
        )
            select
                online_enroll_plans_seq.nextval,
                upper(a.plan_type),
                a.deductible,
                decode(p_enroll_source,
                       'EXCEL',
                       to_date(format_date(a.effective_date),
                       'MM/DD/YYYY'),
                       a.effective_date) effective_date,
        --a.EFFECTIVE_DATE,
                replace(a.annual_election, '$', ''),/* Ticket 4363 */
                a.first_payroll_date,
                replace(a.pay_contrb, '$', ''),/* Ticket 4363 */
                a.no_of_periods,
                upper(a.pay_cycle),
                upper(a.action),
                decode(b.enrollment_source,
                       'EXCEL',
                       ltrim(rtrim(strip_coverage_tier_char(a.covg_tier_name))),
                       ltrim(rtrim(a.covg_tier_name))),--ltrim/rtrim does not remove junk charaters.With Ticket#4363
                initcap(a.conditional_issue),
                a.note,
                a.batch_number,
                b.enrollment_id,
                b.created_by,
                sysdate,
                sysdate,
                b.last_updated_by,
                a.termination_date,
                nvl(a.qual_event_code, 'NEW_HIRE'),
                a.er_ben_plan_id
            from
                online_hfsa_enroll_stage a,
                online_enrollment        b
            where
                ( ( format_ssn(a.ssn) = b.ssn )
                  or ( a.acc_num = b.acc_num ) )
                and b.batch_number = a.batch_number
                and a.batch_number = p_batch_number
                and b.account_type in ( 'HRA', 'FSA' )
                and b.enrollment_status is null
                and a.process_status is null  /* Ticket4363 */
                and a.plan_type is not null;

        pc_log.log_error('PC_ONLINE_ENROLLMENT:load_hrafsa_enrollment ..Source', 'After Loop Plan');
        update online_enrollment y
        set
            enrollment_status = 'E',
            error_message = 'Enter Valid Plan Type, Plan Type Cannot be Null'
        where
                batch_number = p_batch_number
            and enrollment_status is null
            and account_type in ( 'HRA', 'FSA' )
            and not exists (
                select
                    *
                from
                    online_enroll_plans x
                where
                    y.enrollment_id = x.enrollment_id
            );

        update online_hfsa_enroll_stage
        set
            process_status = 'LOADED'
        where
                batch_number = p_batch_number
            and process_status is null; /* Ticket4363 */
        pc_log.log_error('PC_ONLINE_ENROLLMENT ', 'Number of rows insert into Online Enroll Plan ' || sql%rowcount);
    exception
        when others then
        -- l_sqlerrm := 'Error in inserting into ONLINE_ENROLLMENT '||SQLERRM;
            pc_log.log_error('PC_ONLINE_ENROLLMENT', 'SQLERRM ' || sqlerrm);
            x_error_message := sqlerrm;
            x_return_status := 'E';
    end load_hrafsa_enrollment;

    procedure initialize_hrafsa_enrollment (
        p_batch_number  in number,
        p_entrp_id      in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('process_upload.initialize_fsa_renewal', 'Initialize Renewal ');
  -- Deletermine Account Type
        for x in (
            select
                a.account_type,
                a.plan_code,
                b.entrp_id,
                a.acc_id
            from
                account           a,
                online_enrollment b
            where
                    a.entrp_id = b.entrp_id
                and b.batch_number = p_batch_number
            group by
                a.account_type,
                a.plan_code,
                b.entrp_id,
                a.acc_id
        ) loop
            update online_enrollment
            set
                account_type = x.account_type,
                plan_code = x.plan_code
            where
                    entrp_id = x.entrp_id
                and batch_number = p_batch_number;

        end loop;

        for x in (
            select
                a.enrollment_id,
                c.pers_id,
                d.acc_num,
                d.acc_id
            from
                online_enrollment a,
                person            c,
                account           d
            where
                    a.batch_number = p_batch_number
                and ( a.enrollment_status is null
                      or a.enrollment_status = 'W' )
                and a.entrp_id = c.entrp_id
                and ( a.ssn is not null
                      and replace(c.ssn, '-') = replace(
                    format_ssn(a.ssn),
                    '-'
                ) )
                and c.pers_id = d.pers_id
                and d.account_type in ( 'HRA', 'FSA' )
        ) loop
            update online_enrollment
            set
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                enrollment_id = x.enrollment_id;

        end loop;
  -- Changes for renewal release , Vanitha : 03/31/2017
        for x in (
            select
                a.enrollment_id,
                c.pers_id,
                d.acc_num,
                d.acc_id
            from
                online_enrollment a,
                person            c,
                account           d
            where
                    a.batch_number = p_batch_number
                and ( a.enrollment_status is null
                      or a.enrollment_status = 'W' )
                and a.entrp_id = c.entrp_id
                and a.acc_num is not null
                and a.acc_num = d.acc_num
                and c.pers_id = d.pers_id
                and d.account_type in ( 'HRA', 'FSA' )
        ) loop
            update online_enrollment
            set
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                enrollment_id = x.enrollment_id;

        end loop;
  --
        for x in (
            select
                ssn,
                count(*) cnt
            from
                online_enrollment
            where
                    batch_number = p_batch_number
                and account_type in ( 'HRA', 'FSA' )
            group by
                ssn
            having
                count(*) > 1
        ) loop
            if x.ssn is not null then
                update online_enrollment
                set
                    enrollment_status = 'E',
                    error_message = 'You are attempting to enroll in more than one plan , but values does not match between the rows,
                             Please enter same values across rows if a member is enrolling in more than one plan'
                where
                        ssn = x.ssn
                    and account_type in ( 'HRA', 'FSA' );

            end if;
        end loop;

        for x in (
            select
                b.effective_date,
                a.entrp_id,
                a.account_type,
                a.enrollment_id,
                b.plan_type,
                b.enroll_plan_id,
                b.termination_date,
                a.action
            from
                online_enrollment   a,
                online_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and a.enrollment_status is null
                and b.status is null
                and account_type in ( 'HRA', 'FSA' )
                and a.enrollment_id = b.enrollment_id
                and a.batch_number = b.batch_number
        ) loop
            if ( (
                x.effective_date is null
                and x.termination_date is null
            )
            or (
                x.effective_date is not null
                and format_to_date(x.effective_date) is null
            ) ) then
                update online_enroll_plans
                set
                    status = 'Enter valid value for Effective Date'
                where
                        batch_number = p_batch_number
                    and enroll_plan_id = x.enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null
                    and termination_date is null;

            end if;

            if
                x.termination_date is not null
                and format_to_date(x.termination_date) is null
            then
                update online_enroll_plans
                set
                    status = 'Enter valid value for Termination Date',
                    action = 'T'
                where
                        batch_number = p_batch_number
                    and enroll_plan_id = x.enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

            if ( x.entrp_id is null )
            or ( x.account_type is null ) then
                update online_enrollment
                set
                    error_message = 'Group Number is Invalid for plan type ' || x.plan_type,
                    enrollment_status = 'E'
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and error_message is null
                    and enrollment_status is null
                    and account_type in ( 'HRA', 'FSA' )
                    and enrollment_id = x.enrollment_id;

                update online_enroll_plans
                set
                    status = 'Enter valid value for Group Number'
                where
                        batch_number = p_batch_number
                    and enroll_plan_id = x.enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

        end loop;

        update online_enroll_plans
        set
            status = 'Cannot Terminate or Change Plan as Employee does not have plan ' || plan_type
        where
            enroll_plan_id in (
                select
                    enroll_plan_id
                from
                    online_enroll_plans b, online_enrollment   a
                where
                    b.termination_date is not null
                    and a.batch_number = p_batch_number
                    and a.batch_number = b.batch_number
                    and a.enrollment_id = b.enrollment_id
                    and account_type in ( 'HRA', 'FSA' )
                    and not exists (
                        select
                            *
                        from
                            ben_plan_enrollment_setup bp
                        where
                                a.acc_id = bp.acc_id
                            and bp.status in ( 'P', 'A', 'I' )
                            and bp.plan_type = b.plan_type
                    )
            )
            and status is null;
  -- Determine Action
        for x in (
            select
                pc_benefit_plans.get_er_ben_plan(me.entrp_id,
                                                 mp.plan_type,
                                                 nvl(
                                    format_to_date(mp.effective_date),
                                    sysdate
                                )) er_ben_plan_id,
                me.acc_id,
                me.enrollment_id,
                mp.enroll_plan_id,
                mp.plan_type
            from
                online_enrollment   me,
                online_enroll_plans mp
            where
                    me.batch_number = p_batch_number
                and me.batch_number = mp.batch_number
                and me.enrollment_id = mp.enrollment_id
                and me.acc_id is not null
                and account_type in ( 'HRA', 'FSA' )
                and mp.action is null
                and me.enrollment_status is null
                and mp.status is null
        ) -- Ask this we need to add otherwise file value gets overwritten
         loop
            if pc_benefit_plans.get_ben_plan(x.er_ben_plan_id, x.acc_id) is not null then
                update online_enroll_plans
                set
                    action = 'C',
                    er_ben_plan_id = x.er_ben_plan_id
                where
                    enroll_plan_id = x.enroll_plan_id;

            else
                for zz in (
                    select
                        count(*) cnt
                    from
                        ben_plan_enrollment_setup
                    where
                            plan_type = x.plan_type
                        and status in ( 'A', 'I', 'P' )
                        and acc_id = x.acc_id
                ) loop
                    if zz.cnt > 0 then
                        update online_enroll_plans
                        set
                            action = 'R',
                            er_ben_plan_id = x.er_ben_plan_id
                        where
                            enroll_plan_id = x.enroll_plan_id;

                    else
                        update online_enroll_plans
                        set
                            action = 'N',
                            er_ben_plan_id = x.er_ben_plan_id
                        where
                            enroll_plan_id = x.enroll_plan_id;

                    end if;
                end loop;
            end if;
        end loop;

        update online_enroll_plans
        set
            action = 'T'
        where
                batch_number = p_batch_number
            and termination_date is not null
            and status is null;
  -- determine mass enrollment action
        for x in (
            select
                me.enrollment_id,
                sum(
                    case
                        when mp.action in('T', 'C') then
                            1
                        else
                            0
                    end
                ) change_count,
                sum(
                    case
                        when mp.action = 'R' then
                            1
                        when mp.action = 'N'
                             and me.pers_id is not null then
                            1
                        else
                            0
                    end
                ) renewal_count
            from
                online_enroll_plans mp,
                online_enrollment   me
            where
                    mp.enrollment_id = me.enrollment_id
                and me.batch_number = mp.batch_number
                and me.batch_number = p_batch_number
                and mp.termination_date is null
                and me.enrollment_status is null
                and account_type in ( 'HRA', 'FSA' )
                and mp.status is null
            group by
                me.enrollment_id
        ) loop
            if x.renewal_count > 0 then
                update online_enrollment
                set
                    action = 'R'
                where
                    enrollment_id = x.enrollment_id;

            end if;

            if
                x.renewal_count = 0
                and x.change_count > 0
            then
                update online_enrollment
                set
                    action = 'C'
                where
                    enrollment_id = x.enrollment_id;

            end if;

        end loop;

        update online_enroll_plans
        set
            action = 'N'
        where
            action is null
            and batch_number = p_batch_number
            and status is null;

  -- If no ssn exists then it is new
        update online_enrollment
        set
            action = 'N'
        where
            action is null
            and batch_number = p_batch_number
            and acc_num is null
            and account_type in ( 'HRA', 'FSA' )
            and enrollment_status is null;

        update online_enrollment
        set
            action = 'C'
        where
            action is null
            and batch_number = p_batch_number
            and acc_num is not null
            and account_type in ( 'HRA', 'FSA' )
            and enrollment_status is null;

        pc_log.log_error('NN', 'In Initialize End');
    end initialize_hrafsa_enrollment;

    procedure validate_hrafsa_enrollment (
        p_batch_number in number,
        p_entrp_id     in number
    ) is

        l_valid_plan        number;
        l_grp_entrp_id      varchar2(100);
        l_ee_entrp_id       varchar2(100);
        l_exist             number;
        plan_validation_error exception;
        l_error_message     varchar2(2400);
        l_error_column      varchar2(255);
        l_dup_count         number;
        l_ben_covg          varchar2(10);
        l_plan_type         varchar2(10);
        l_enrollment_status varchar2(10);
    begin
        pc_log.log_error('PP', 'In Start');
   --   x_return_status := 'S';

  --If any of the Mandatory fields are NULL ,we would just reject the entire set of record

        for x in (
            select
                ssn,
                count(*) cnt
            from
                online_enrollment
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and account_type in ( 'HRA', 'FSA' )
                and ( enrollment_status is null
                      or enrollment_status = 'W' )
            group by
                ssn
            having
                count(*) > 1
        ) loop
            if x.ssn is not null then
                update online_enrollment
                set
                    enrollment_status = 'E',
                    error_message = 'You are attempting to enroll in more than one plan , but values does not match between the rows,
                             Please enter same values across rows if a member is enrolling in more than one plan'
                where
                        ssn = x.ssn
                    and batch_number = p_batch_number
                    and account_type in ( 'HRA', 'FSA' )
                    and entrp_id = p_entrp_id;

            end if;
        end loop;

        for x in (
            select
                b.effective_date,
                a.entrp_id,
                a.account_type,
                a.enrollment_id,
                b.plan_type,
                b.enroll_plan_id,
                b.termination_date,
                a.action
            from
                online_enrollment   a,
                online_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and ( enrollment_status is null
                      or enrollment_status = 'W' )
                and b.status is null
                and a.enrollment_id = b.enrollment_id
                and account_type in ( 'HRA', 'FSA' )
                and a.batch_number = b.batch_number
                and a.entrp_id = p_entrp_id
        ) loop
            pc_log.log_error('validate_hrafsa_enrollment', 'EFFECTIVE_DATE' || x.effective_date);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'termination_date' || x.termination_date);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'entrp_id' || x.entrp_id);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'enrollment_id' || x.enrollment_id);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'plan_type' || x.plan_type);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'termination_date' || x.termination_date);
            if
                ( x.effective_date is null )
                and x.action in ( 'R', 'N' )
                and x.termination_date is null
            then
                update online_enrollment
                set
                    error_message = 'Enter valid value of effective Date for plan type ' || x.plan_type,
                    enrollment_status = 'W'
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and account_type in ( 'FSA', 'HRA' )
                    and error_message is null
                    and enrollment_status is null
                    and enrollment_id = x.enrollment_id
                    and entrp_id = p_entrp_id;

                update online_enroll_plans
                set
                    status = 'Enter valid value for Effective Date'
                where
                        batch_number = p_batch_number
                    and enroll_plan_id = x.enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

            if ( x.entrp_id is null )
            or ( x.account_type is null ) then
                update online_enrollment
                set
                    error_message = 'Group Number is Invalid for plan type ' || x.plan_type,
                    enrollment_status = 'E'
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and error_message is null
                    and account_type in ( 'HRA', 'FSA' )
                    and enrollment_status is null
                    and enrollment_id = x.enrollment_id
                    and entrp_id = p_entrp_id;

                update online_enroll_plans
                set
                    status = 'Enter valid value for Group Number'
                where
                        batch_number = p_batch_number
                    and enroll_plan_id = x.enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

        end loop;

  -- Plan Validations
        for x in (
            select
                b.plan_type,
                a.birth_date,
                upper(nvl(a.debit_card_flag, 'N'))        debit_card_flag,
                a.first_name,
                a.middle_name,
                a.last_name,
                a.gender,
                a.city,
                a.state,
                a.zip,
                a.address,
                a.ssn,
                a.entrp_id,
                a.account_type,
                a.division_code,
  --  A.DEBIT_CARD,
                pc_lookups.get_fsa_plan_type(b.plan_type) plan_type_m,
                b.effective_date,
                a.enrollment_id,
                pc_benefit_plans.get_er_ben_plan(a.entrp_id,
                                                 b.plan_type,
                                                 nvl(
                                    format_to_date(b.effective_date),
                                    sysdate
                                ))                                        er_ben_plan,
                b.annual_election,
                b.first_payroll_date,
                b.pay_contrb,
                b.no_of_periods,
                b.pay_cycle,
                b.covg_tier_name,
                nvl(a.acc_id,
                    pc_account.get_acc_id_from_ssn(
                    replace(a.ssn, '-'),
                    a.entrp_id
                ))                                        acc_id,
                a.action,
                b.enroll_plan_id,
                b.termination_date,
                a.acc_num,
                b.life_event_code,
                a.enrollment_source
            from
                online_enrollment   a,
                online_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and a.enrollment_id = b.enrollment_id
                and a.entrp_id = p_entrp_id
                and a.batch_number = b.batch_number
                and a.error_message is null
                and account_type in ( 'HRA', 'FSA' )
                and ( enrollment_status is null
                      or enrollment_status = 'W' )
        ) loop
            begin
                l_error_message := null;
                l_error_column := null;
                if ( x.entrp_id is null ) then
                    l_error_message := 'Verify Group Number of Employer, Cannot find match for plan type ' || x.plan_type;
                    l_enrollment_status := 'E';
                    raise plan_validation_error;
                end if;

                if
                    (
                        x.ssn is null
                        and x.acc_num is null
                    )
                    and x.account_type in ( 'FSA', 'HRA' )
                then
                    l_error_message := 'Social Security Number Cannot be Null for plan type ' || x.plan_type;
                    l_enrollment_status := 'E';
                    raise plan_validation_error;
                end if;

                if
                    x.ssn like '%xx%'
                    and length(x.ssn) > 11
                    and x.account_type in ( 'FSA', 'HRA' )
                then
                    l_error_message := 'Enter valid Social Security Number for ' || x.plan_type;
                    l_enrollment_status := 'E';
                    raise plan_validation_error;
                end if;

                if
                    x.ssn like '%-%'
                    and length(x.ssn) > 11
                    and x.account_type in ( 'FSA', 'HRA' )
                then
                    l_error_message := 'Social Security Number Cannot have more than 11 characters for plan type ' || x.plan_type;
                    l_enrollment_status := 'E';
                    raise plan_validation_error;
                end if;

                if
                    x.ssn not like '%-%'
                    and length(x.ssn) > 9
                    and x.account_type in ( 'FSA', 'HRA' )
                then
                    l_error_message := 'Social Security Number Cannot have more than 9 characters for plan type ' || x.plan_type;
                    l_enrollment_status := 'E';
                    raise plan_validation_error;
                end if;
    --  IF pc_account.check_duplicate(X.ssn,X.group_number,NULL,X.account_type,X.entrp_id) = 'Y' THEN
    --     L_ERROR_MESSAGE := 'Member has been enrolled already with this SSN for plan type '||X.plan_type;
	--       L_ERROR_COLUMN  := 'SSN';
    --     L_ENROLLMENT_STATUS := 'E';
    --     RAISE plan_validation_error;
    --  END IF;
                if x.termination_date is not null then
                    if pc_benefit_plans.get_ben_plan(x.er_ben_plan, x.acc_id) is null then
                        l_error_message := 'Cannot terminate benefit plan '
                                           || x.plan_type
                                           || ', as the member is not enrolled in this plan
                            or this plan is already terminated';
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;
                else
      ---- ##9536  Remove the mandatory field prefix by jaggi
 /*         IF X.GENDER IS NULL AND X.ACCOUNT_TYPE IN ('FSA','HRA')
          AND X.ACTION = 'N'
          THEN
             L_ERROR_MESSAGE := 'Gender cannot be NULL for plan type '||X.plan_type;
             L_ENROLLMENT_STATUS := 'E';
             RAISE plan_validation_error;
          END IF;

          IF LENGTH(X.GENDER) > 1 AND X.ACCOUNT_TYPE IN ('FSA','HRA')
      --    AND X.ACTION = 'N'
          THEN
             L_ERROR_MESSAGE := 'Gender Cannot have more than one character for plan type '||X.plan_type;
             L_ENROLLMENT_STATUS := 'E';
             RAISE plan_validation_error;
          END IF;

          IF (X.GENDER) NOT IN ('Male','Female','M','F') AND X.ACCOUNT_TYPE IN ('FSA','HRA')
      --    AND X.ACTION = 'N'
          THEN
             L_ERROR_MESSAGE := 'Enter valid value for Gender, Valid values are M,F for '||X.plan_type;
             L_ENROLLMENT_STATUS := 'E';
             RAISE plan_validation_error;
          END IF;
*/
                    if
                        x.first_name is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'First Name cannot be null for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.last_name is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Last Name cannot be null for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        length(x.middle_name) > 1
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Middle Name Cannot have more than one character for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.address is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Address Cannot be NULL for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.city is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'City Cannot be NULL for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.state is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'State Cannot be NULL for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        process_upload.get_valid_state(upper(x.state)) is null
                        and x.action = 'N'
                    then
                        l_error_message := 'State is not valid for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.zip is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'ZIP Cannot be NULL for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        ( length(x.zip) > 5
                        or not regexp_like(x.zip, '^[[:digit:]]+$') )
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'ZIP code must be in the form 99999 for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        length(x.state) > 2
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'State Cannot have more than two character for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.birth_date is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Birth Date Cannot be NULL for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;
 /*
          IF FORMAT_TO_DATE(X.BIRTH_DATE) IS NULL AND X.ACCOUNT_TYPE IN ('FSA','HRA')
          THEN
            L_ERROR_MESSAGE := 'Enter correct format for Birth Date for plan type '||X.plan_type;
            L_ENROLLMENT_STATUS := 'E';
            RAISE plan_validation_error;
          END IF;
 */

                    if
                        x.division_code is not null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and pc_employer_divisions.get_division_count(x.entrp_id,
                                                                     upper(x.division_code)) = 0
                    then
                        l_error_message := 'Division Code is not Setup for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.debit_card_flag is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Debit Card Information must be entered for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        upper(x.debit_card_flag) not in ( 'Y', 'N', 'YES', 'NO' )
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Enter valid value for Debit Card information for plan type ' || x.plan_type;
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

	--Ticket#3687.For Transit ,Parking and UA1 , this validation is not applicable
                    if
                        pc_benefit_plans.get_ben_plan(x.er_ben_plan, x.acc_id) is not null
                        and x.action in ( 'R', 'N' )
                        and x.plan_type not in ( 'TRN', 'PKG', 'UA1' )
                    then
                        l_error_message := 'Member has already enrolled in the benefit plan' || x.plan_type;
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;

                    if
                        x.plan_type is null
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Enter Valid Value for Plan Type';
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.plan_type is null
                        and x.termination_date is not null
                    then
                        l_error_message := 'Enter Valid Value for Plan Type';
                        l_enrollment_status := 'E';
                        raise plan_validation_error;
                    end if;

                    if
                        x.plan_type_m is null
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Invalid Plan Type';
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;

                    if
                        x.acc_id is null
                        and x.action <> 'N'
                    then
                        l_error_message := 'Employee does not belong to this employer for plan type ' || x.plan_type;
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;

                    if x.er_ben_plan is null then
                        l_error_message := 'Cannot find any matching employer plans for the information entered';
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;

                    if
                        x.annual_election is null
                        and pc_lookups.get_meaning(x.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA'
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Enter Valid Value for Annual Election for plan type ' || x.plan_type;
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;

       --For Ticket#3687.If Annual election is NULL we will not validate.It shud just accept
                    if
                        process_upload.validate_annual_election(x.er_ben_plan, x.annual_election) <> 'Y'
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Annual election should be within the defined range for plan type ' || x.plan_type;
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;

                    if is_number(x.annual_election) = 'N' then
                        l_error_message := 'Enter Numeric Value for Annual Election for plan type ' || x.plan_type;
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;
     --Added by jaggi #10748
                    if
                        to_number ( x.annual_election ) = 0
                        and x.plan_type not in ( 'TRN', 'PKG', 'UA1' )
                        and x.action in ( 'R', 'N' )
                        and x.enrollment_source = 'EXCEL'
                    then
                        l_error_message := 'Cannot enroll with $0 Annual Election ' || x.plan_type;
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;
       --Pay Per period amount should be numeric#4363
                    if is_number(x.pay_contrb) = 'N' then
                        l_error_message := 'Enter Numeric Value for Period Contribution for plan type ' || x.plan_type;
                        l_enrollment_status := 'W';
                        raise plan_validation_error;
                    end if;

      /*
      IF (X.FIRST_PAYROLL_DATE IS NULL
      AND X.ACTION IN ( 'R','N')
      AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO')) OR FORMAT_TO_DATE(X.FIRST_PAYROLL_DATE) = 'N' THEN
        L_ERROR_MESSAGE       := 'Enter valid value for First Payroll Date for plan type '||X.plan_type;
        L_ENROLLMENT_STATUS := 'W';
        RAISE plan_validation_error;
      END IF;
      IF (X.PAY_CONTRB   IS NULL
      AND X.ACTION IN ( 'R','N')
      AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO') ) OR IS_NUMBER(X.PAY_CONTRB) = 'N'  THEN
        L_ERROR_MESSAGE := 'Enter valid value for Pay Period Contribution for plan type '||X.plan_type;
        L_ENROLLMENT_STATUS := 'W';
        RAISE plan_validation_error;
      END IF;
      IF (X.NO_OF_PERIODS IS NULL
      AND X.ACTION IN ( 'R','N')
      AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO') )OR IS_NUMBER(X.NO_OF_PERIODS) = 'N' THEN
        L_ERROR_MESSAGE  := 'Enter valid value for Number of Pay Period for plan type '||X.plan_type;
        L_ENROLLMENT_STATUS := 'W';
        RAISE plan_validation_error;
      END IF;
      IF X.PAY_CYCLE    IS NULL AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO')
      AND X.ACTION IN ( 'R','N')
      THEN
        L_ERROR_MESSAGE := 'Enter valid value for Payroll Cycle for plan type '||X.plan_type;
        L_ENROLLMENT_STATUS := 'W';
        RAISE plan_validation_error;
      END IF;
      */
    --  IF X.COVG_TIER_NAME IS NULL AND X.PLAN_TYPE IN ('HRA','HRP','HR5','HR4','ACO') THEN
    --    L_ERROR_MESSAGE   := 'Enter valid value for Coverage Tier Name';
    --    L_ERROR_COLUMN    := 'COVG_TIER_NAME';
    --    L_ENROLLMENT_STATUS := 'W';
    --    RAISE plan_validation_error;
    --  END IF;
                end if;

                if x.action not in ( 'T', 'R', 'N', 'C' ) then
                    l_error_message := 'Invalid Action Code for plan type ' || x.plan_type;
                    l_enrollment_status := 'W';
                    raise plan_validation_error;
                end if;

            exception
                when plan_validation_error then
                    pc_log.log_error('PROCESS_UPLOAD.validate_fsa_renewal', 'In plan_validation_error' || l_error_message);
                    update online_enrollment
                    set
                        enrollment_status = l_enrollment_status
                    where
                            batch_number = p_batch_number
                        and error_message is null
                        and account_type in ( 'HRA', 'FSA' )
                        and enrollment_status is null
                        and enrollment_id = x.enrollment_id;

                    update online_enroll_plans
                    set
                        status = l_error_message
                    where
                            batch_number = p_batch_number
                        and enroll_plan_id = x.enroll_plan_id
                        and nvl(plan_type, 0) = nvl(x.plan_type, 0)
                        and status is null;  --Added NVL to handle NULL value of plan_type

            end;
        end loop;

 --Benefit Plan Setup Incomplete
        for x in (
            select distinct
                a.plan_type,
                a.ben_plan_name,
                c.enrollment_id,
                d.enroll_plan_id
            from
                ben_plan_enrollment_setup a,
                account                   b,
                online_enrollment         c,
                online_enroll_plans       d
            where
                    c.batch_number = p_batch_number
                and a.acc_id = b.acc_id
                and b.account_type in ( 'FSA', 'HRA' )
                and c.account_type in ( 'FSA', 'HRA' )
                and c.error_message is null
                and ( c.enrollment_status is null
                      or c.enrollment_status = 'W' )
                and c.entrp_id = b.entrp_id
                and d.plan_type = a.plan_type
                and c.enrollment_id = d.enrollment_id
                and c.entrp_id = p_entrp_id
                and c.action in ( 'R', 'N', 'T' )
                and a.status = 'A'
                and trunc(format_to_date(d.effective_date)) between a.plan_start_date and a.plan_end_date
        ) loop
            if x.plan_type is null
               or x.ben_plan_name is null then
                update online_enroll_plans
                set
                    status = 'Benefit Plan Setup is Incomplete, Please Contact Customer Service',
                    last_update_date = sysdate
                where
                    enroll_plan_id = x.enroll_plan_id;

            end if;
        end loop;

 --Check for Duplicate SSN's in the File
        for x in (
            select
                ssn,
                enrollment_id
            from
                online_enrollment
            where
                    batch_number = p_batch_number
                and action = 'N'
                and error_message is null
                and entrp_id = p_entrp_id
                and ( enrollment_status is null
                      or enrollment_status = 'W' )
                and account_type in ( 'HRA', 'FSA' )
            group by
                ssn,
                enrollment_id
        )
             -- Having count(*) > 1)
         loop
            pc_log.log_error('PROCESS_UPLOAD.validate_fsa_renewals', 'Check for Duplicate SSN in the File ' || x.ssn);
            l_dup_count := 0;
            begin
                for zz in (
                    select
                        b.plan_type,
                        b.effective_date,
                        count(*) cnt
                    from
                        online_enrollment   a,
                        online_enroll_plans b
                    where
                            a.enrollment_id = b.enrollment_id
                        and format_ssn(a.ssn) = x.ssn
                        and b.batch_number = p_batch_number
                        and account_type in ( 'HRA', 'FSA' )
                        and b.status is null
                    group by
                        b.plan_type,
                        b.effective_date
                    having
                        count(*) > 1
                ) loop
                    if zz.cnt > 0 then
                        update online_enroll_plans
                        set
                            status = 'Duplicate Record found for plan type '
                                     || zz.plan_type
                                     || ' please correct the file to have one row
                          per plan type '
                        where
                                batch_number = p_batch_number
                            and enrollment_id = x.enrollment_id
                            and status is null;

                        l_dup_count := l_dup_count + 1;
                    end if;
                end loop;
            exception
                when others then
                    l_dup_count := 0;
            end;

     /*      pc_log.log_error('PROCESS_UPLOAD.validate_fsa_renewals','Np of Duplicate SSN in the File for '||X.SSN ||': '||l_dup_count);

       IF l_dup_count > 1 THEN
         UPDATE ONLINE_ENROLLMENT
         SET ERROR_MESSAGE        = 'Duplicate SSN in the File'
            ,ENROLLMENT_STATUS        = 'E'
         WHERE BATCH_NUMBER       = p_batch_number
         AND TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
         AND ERROR_MESSAGE IS NULL
         AND ACTION = 'N'
         AND ENROLLMENT_STATUS      IS NULL
         AND SSN = X.SSN;

        END IF;*/
        end loop;

         -- Update ben_plan_id in ONLINE_ENROLL_PLANS table
        for x in (
            select
                a.entrp_id,
                b.plan_type,
                b.effective_date,
                a.enrollment_id,
                b.enroll_plan_id,
                pc_benefit_plans.get_er_ben_plan(a.entrp_id,
                                                 b.plan_type,
                                                 nvl(b.effective_date, sysdate)) er_ben_plan_id
            from
                online_enrollment   a,
                online_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and account_type in ( 'HRA', 'FSA' )
                and a.enrollment_id = b.enrollment_id
                and a.batch_number = b.batch_number
                and a.error_message is null
                and a.enrollment_status is null
                and b.er_ben_plan_id is null
        ) loop
            update online_enroll_plans
            set
                er_ben_plan_id = x.er_ben_plan_id
            where
                    enroll_plan_id = x.enroll_plan_id
                and batch_number = p_batch_number
                and plan_type = x.plan_type;

        end loop;

        --Validate for Coverage Tier Name
        for x in (
            select
                mrp.er_ben_plan_id,
                me.enrollment_id,
                mrp.covg_tier_name,
                mrp.plan_type,
                mrp.enroll_plan_id
            from
                online_enrollment   me,
                online_enroll_plans mrp
            where
                    me.batch_number = p_batch_number
                and me.batch_number = mrp.batch_number
                and me.enrollment_id = mrp.enrollment_id
                and mrp.covg_tier_name is not null
                and pc_lookups.get_meaning(mrp.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'HRA'
                and me.error_message is null
                and account_type in ( 'HRA', 'FSA' )
                and me.enrollment_status is null
                and me.enrollment_source = 'EXCEL'
        ) -- added By Joshi for 4884 bypasisng coverage tier validation for webform/enroll express
         loop
            begin
                select
                    'Y'
                into l_ben_covg
                from
                    ben_plan_coverages
                where
                        ben_plan_id = x.er_ben_plan_id
                    and upper(x.covg_tier_name) = upper(coverage_tier_name);

            exception
                when others then
                    l_ben_covg := 'N';
            end;

            if l_ben_covg <> 'Y' then
                update online_enroll_plans
                set
                    status = 'Coverage Tier Name is not valid for plan type '
                where
                        batch_number = p_batch_number
                    and enroll_plan_id = x.enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

        end loop;
      -- When all rows have warning then we have to error out
        for x in (
            select
                a.enrollment_id,
                sum(
                    case
                        when b.status is null then
                            0
                        else
                            1
                    end
                )        error_count,
                sum(
                    case
                        when b.enrollment_id is null then
                            0
                        else
                            1
                    end
                )        no_of_lines,
                count(*) no_of_records
            from
                online_enrollment   a,
                online_enroll_plans b
            where
                    a.enrollment_id = b.enrollment_id (+)
                and a.batch_number = b.batch_number (+)
                and account_type in ( 'HRA', 'FSA' )
                and a.batch_number = p_batch_number
            group by
                a.enrollment_id
        ) loop
            if
                x.error_count > 0
                and x.error_count = x.no_of_lines
            then
                update online_enrollment
                set
                    error_message = 'Plan Information is Incomplete or Invalid, Enter Valid Plan Information',
                    enrollment_status = 'E'
                where
                        enrollment_id = x.enrollment_id
                    and account_type in ( 'HRA', 'FSA' )
                    and ( enrollment_status is null
                          or enrollment_status = 'W' );

            end if;
 /* IF X.NO_OF_LINES = 0 THEN
      UPDATE ONLINE_ENROLLMENT
       SET   ERROR_MESSAGE = 'Plan Information is Missing, Enter Valid Plan Information'
         ,   ENROLLMENT_STATUS = 'E'
      WHERE  enrollment_id =  X.enrollment_id
      AND    (ENROLLMENT_STATUS IS NULL or ENROLLMENT_STATUS  = 'W');
  END IF;*/

        end loop;

    exception
        when others then
            pc_log.log_error('PROCESS_UPLOAD', 'In validate_fsa_renewals exception ' || sqlerrm);
            raise_application_error('-20002', 'Error in Validation ' || sqlerrm);
    end validate_hrafsa_enrollment;

    procedure process_changes_enrollment (
        p_batch_number  in number,
        p_entrp_id      in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_user_id       number;
        l_return_status varchar2(30);
        l_error_message varchar2(3200);
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_ONLINE_ENROLLMENT:process_changes_enrollment', 'In process_changes_enrollment');
        for x in (
            select
                a.enrollment_id,
                rtrim(ltrim(a.first_name))  first_name,
                rtrim(ltrim(a.middle_name)) middle_name,
                rtrim(ltrim(a.last_name))   last_name,
                a.birth_date                birth_date,
                rtrim(ltrim(a.address))     address,
                rtrim(ltrim(a.city))        city,
                upper(a.state)              state,
                substr(a.zip, 1, 5)         zip,
                phone,
                a.acc_num,
                a.pers_id,
                a.gender,
                upper(a.debit_card_flag)    debit_card,
                sysdate                     effective_date,
                a.action,
                nvl((
                    select
                        card_allowed
                    from
                        enterprise
                    where
                        enterprise.entrp_id = a.entrp_id
                ), 1)                       card_allowed,
                a.last_updated_by
            from
                online_enrollment a
            where
                    a.batch_number = p_batch_number
                and ( a.enrollment_status is null
                      or a.enrollment_status = 'W' )
                and a.pers_id is not null
                and a.acc_id is not null
                and account_type in ( 'HRA', 'FSA' )
                and a.action in ( 'R', 'C' )
        ) loop
            if x.action in ( 'R', 'C' ) then
                update person
                set
                    first_name = nvl(x.first_name, first_name),
                    last_name = nvl(x.last_name, last_name),
                    middle_name = nvl(x.middle_name, middle_name),
                    address = nvl(x.address, address),
                    city = nvl(x.city, city),
                    state = nvl(x.state, state),
                    zip = nvl(x.zip, zip),
                    phone_day = nvl(x.phone, phone_day),
                    gender = nvl(x.gender, gender),
                    birth_date = nvl(x.birth_date, birth_date),
                    last_update_date = sysdate,
                    last_updated_by = x.last_updated_by
                where
                    pers_id = x.pers_id;

            end if;

            if
                x.debit_card in ( 'YES', 'Y' )
                and x.card_allowed = 0
            then
                insert into card_debit (
                    card_id,
                    start_date,
                    emitent,
                    note,
                    status,
                    created_by,
                    last_updated_by,
                    last_update_date
                )
                    select
                        x.pers_id,
                        nvl(x.effective_date, sysdate),
                        6763, -- Metavante
                        'Mass Enrollment',
                        1,
                        x.last_updated_by,
                        x.last_updated_by,
                        sysdate
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                card_debit
                            where
                                card_debit.card_id = x.pers_id
                        );

            end if;

            update online_enrollment a
            set
                error_message = 'Successfully Processed ',
                enrollment_status = nvl(enrollment_status, 'S')
            where
                ( enrollment_status is null
                  or enrollment_status = 'W' )
                and enrollment_id = x.enrollment_id;

            pc_log.log_error('PC_ONLINE_ENROLLMENT:process_changes_enrollment', 'After Update of mass_enrollments ' || sql%rowcount);
        end loop;

        process_renewals(p_batch_number, p_entrp_id, x_return_status, x_error_message);
        pc_log.log_error('PC_ONLINE_ENROLLMENT:process_changes_enrollment', 'In Existing HFSA End '
                                                                            || x_return_status
                                                                            || 'Error '
                                                                            || x_error_message);
        process_annual_election_change(p_batch_number);
        pc_log.log_error('PC_ONLINE_ENROLLMENT:process_changes_enrollment', 'annual election '
                                                                            || x_return_status
                                                                            || 'Error '
                                                                            || x_error_message);
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_ONLINE_ENROLLMENT:process_changes_enrollment', 'Exception: ' || sqlerrm);
    end process_changes_enrollment;

    procedure process_renewals (
        p_batch_number  in number,
        p_entrp_id      in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        lv_create_error exception;
    begin
        pc_log.log_error('PC_ONLINE_ENROLLMENT:process_renewals', ' P_BATCH_NUMBER' || p_batch_number);
        x_return_status := 'S';
        for x in (
            select
                er_ben_plan_id,
                acc_id,
                annual_election,
                covg_tier_name,
                pers_id,
                effective_date,
    --decode(enrollment_source,'EXCEL','A','P') status,
                decode(enrollment_source, 'EXCEL', 'A', 'WEBFORM_ENROLL', 'A',
                       'P') status, -- Joshi webform ticket 4487
                life_event_code
            from
                (
                    select
                        x.er_ben_plan_id,
                        me.acc_id,
                        x.annual_election,
                        upper(x.covg_tier_name) covg_tier_name,
                        pers_id,
                        x.effective_date        effective_date,
                        case
                            when x.action = 'R'
                                 and x.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                                'OPEN_ENROLLMENT'
                            when x.action = 'N'
                                 and x.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                                'NEW_HIRE'
                            else
                                x.life_event_code
                        end                     life_event_code,
                        me.enrollment_source
                    from
                        online_enroll_plans x,
                        online_enrollment   me
                    where
                            me.batch_number = p_batch_number
                        and me.enrollment_id = x.enrollment_id
                        and me.batch_number = x.batch_number
                        and x.action in ( 'R', 'N' )
                        and account_type in ( 'HRA', 'FSA' )
                        and me.action = 'R'
                        and x.status is null
                        and ( me.enrollment_status in ( 'S', 'W' ) )
                ) xx
            where
                not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup bp
                    where
                            xx.acc_id = bp.acc_id
                        and bp.ben_plan_id_main = xx.er_ben_plan_id
                        and status <> 'R'
                )
        ) loop
            pc_log.log_error('PC_ONLINE_ENROLLMENT:PROCESS_RENEWAL : er_ben_plan_id ', x.er_ben_plan_id
                                                                                       || ' P_BATCH_NUMBER :='
                                                                                       || p_batch_number);
            pc_log.log_error('PC_ONLINE_ENROLLMENT:PROCESS_RENEWAL : effective_date ', x.effective_date
                                                                                       || ' X.ANNUAL_ELECTION :='
                                                                                       || x.annual_election);

            pc_log.log_error('PC_ONLINE_ENROLLMENT:PROCESS_RENEWAL : P_BATCH_NUMBER ', p_batch_number);
            pc_log.log_error('PC_ONLINE_ENROLLMENT:PROCESS_RENEWAL : ANNUAL_ELECTION ', x.annual_election);
            begin
                pc_benefit_plans.add_renew_employees(
                    p_acc_id          => x.acc_id,
                    p_annual_election => x.annual_election,
                    p_er_ben_plan_id  => x.er_ben_plan_id,
                    p_cov_tier_name   => x.covg_tier_name,
                    p_effective_date  => x.effective_date,
                    p_batch_number    => p_batch_number,
                    p_user_id         => get_user_id(v('APP_USER')),
                    x_return_status   => x_return_status,
                    x_error_message   => x_error_message,
                    p_status          => x.status,
                    p_life_event_code => nvl(x.life_event_code, 'OPEN_ENROLLMENT')
                );

                if x_return_status <> 'S' then
                    raise lv_create_error;
                end if;
                pc_benefit_plans.create_benefit_coverage(
                    p_er_ben_plan_id => x.er_ben_plan_id,
                    p_cov_tier_name  => x.covg_tier_name,
                    p_acc_id         => x.acc_id,
                    p_user_id        => get_user_id(v('APP_USER')),
                    x_return_status  => x_return_status,
                    x_error_message  => x_error_message
                );

                if x_return_status <> 'S' then
                    raise lv_create_error;
                end if;
            exception
                when lv_create_error then
                    update online_enrollment
                    set
                        enrollment_status = 'E',
                        error_message = x_error_message
                    where
                            pers_id = x.pers_id
                        and ( enrollment_status is null
                              or enrollment_status = 'W' );

            end;

        end loop;

--Ticket #3687 ,For TRN,PKG and UA1 ,it will not go in above loop.We just update
  --renewal dates for TRN,PKG and UA1 renewals

        for x in (
            select
                er_ben_plan_id,
                acc_id,
                annual_election,
                covg_tier_name,
                pers_id,
                effective_date,
                decode(enrollment_source, 'EXCEL', 'A', 'P') status,
                life_event_code,
                plan_type
            from
                (
                    select
                        x.er_ben_plan_id,
                        me.acc_id,
                        x.annual_election,
                        upper(x.covg_tier_name) covg_tier_name,
                        pers_id,
                        x.effective_date        effective_date,
                        case
                            when x.action = 'R'
                                 and x.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                                'OPEN_ENROLLMENT'
                            when x.action = 'N'
                                 and x.plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                                'NEW_HIRE'
                            else
                                x.life_event_code
                        end                     life_event_code,
                        me.enrollment_source,
                        x.plan_type
                    from
                        online_enroll_plans x,
                        online_enrollment   me
                    where
                            me.batch_number = p_batch_number
                        and me.enrollment_id = x.enrollment_id
                        and me.batch_number = x.batch_number
                        and x.action in ( 'R', 'N' )
                        and x.plan_type in ( 'TRN', 'PKG', 'UA1' )
                        and me.action = 'R'
                        and x.status is null
                        and ( me.enrollment_status in ( 'S', 'W' ) )
                ) xx
        ) loop
            pc_log.log_error('PC_ONLINE_ENROLLMENT:PROCESS_RENEWAL ', 'For TRN and PKG ..ACC ID' || x.acc_id);
            pc_log.log_error('PC_ONLINE_ENROLLMENT:PROCESS_RENEWAL ', 'For TRN and PKG ..ACC ID' || x.er_ben_plan_id);
            update ben_plan_enrollment_setup
            set
                renewal_date = sysdate
            where
                    ben_plan_id_main = x.er_ben_plan_id
                and acc_id = x.acc_id
                and plan_type = x.plan_type;

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_ONLINE_ENROLLMENT:PROCESS_RENEWAL ', 'EXCEPTION ' || sqlerrm);
    end process_renewals;

    procedure process_hrafsa_enrollment (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_sqlerrm        varchar2(3200);
        l_pers_id        number;
        l_acc_id         number;
        l_bank_acct_id   number;
        l_transaction_id number;
        l_action         varchar2(255);
        l_create_error exception;
        l_duplicate_error exception;
        l_return_status  varchar2(30) := 'S';
        l_error_message  varchar2(3200);
        l_acc_num        varchar2(30);
        l_user_id        number;
        l_file_upload_id number;
        l_ben_plan_id    number;
        l_er_ben_plan_id number;
        l_account_status number := 1;
        l_complete_flag  number := 1;
        l_scheduler_id   number;
        l_sdetail_id     number;
    begin
        x_return_status := 'S';
        pc_log.log_error('process_hrafsa_enrollment', 'calling online enrollment ' || p_batch_number);
        for x in (
            select
                initcap(a.first_name)                                      first_name,
                a.middle_name,
                initcap(a.last_name)                                       last_name,
                a.title                                  -- Added by Jaggi #9579
                ,
                upper(a.gender)                                            gender,
                lpad(a.ssn, 11, '0')                                       ssn,
                a.enrollment_id,
                a.entrp_id,
                a.phone,
                a.email,
                a.start_date,
                a.address,
                initcap(a.city)                                            city,
                upper(a.state)                                             state,
                a.zip,
                a.birth_date,
                a.plan_type,
                upper(
                    case
                        when a.debit_card_flag = 'YES' then
                            'Y'
                        when a.debit_card_flag = 'NO' then
                            'N'
                        else a.debit_card_flag
                    end
                )                                                          debit_card_flag,
                a.annual_election,
                b.plan_code,
                b.broker_id,
                pc_plan.fsetup_hra(b.entrp_id)                             fee_setup,
                pc_plan.fmonth_hra(b.entrp_id)                             fee_month,
                pc_account.get_salesrep_id(null, b.entrp_id)               salesrep_id,
                pc_sales_team.get_salesrep_detail(b.entrp_id, 'SECONDARY') am_id -- 5022: secondary salesrep should be populated.
                ,
                b.bps_hra_plan,
                b.acc_num,
                a.created_by,
                b.acc_id,
                a.deductible,
                upper(a.division_code)                                     division_code,
                a.lang_perf,
                a.account_type,
                a.carrier_id,
                nvl(
                    pc_enroll_utility_pkg.is_stacked_account(
                        replace(c.entrp_code, '-'),
                        null
                    ),
                    'N'
                )                                                          stacked,
                a.enrollment_source
	                   -- , decode(a.enrollment_source,'EXCEL','A','P') plan_status
                ,
                decode(a.enrollment_source, 'EXCEL', 'A', 'WEBFORM_ENROLL', 'A',
                       'P')                                                plan_status -- Joshi webform ticket 4487
            from
                online_enrollment a,
                account           b,
                enterprise        c
            where
                    batch_number = p_batch_number
                and nvl(enrollment_status, 'S') in ( 'S', 'W' )
                and a.account_type in ( 'HRA', 'FSA' )
                and a.action = 'N'
                and a.entrp_id = b.entrp_id
                and c.entrp_id = b.entrp_id
                and b.entrp_id = p_entrp_id
        ) loop
            savepoint enroll_savepoint;
            begin
                pc_log.log_error('process_hrafsa_enrollment', 'processing for  ' || x.ssn);
                pc_log.log_error('process_hrafsa_enrollment', 'processing for x.acc_num ' || x.acc_num);
                pc_log.log_error('process_hrafsa_enrollment', 'processing for x.account_type ' || x.account_type);
                pc_log.log_error('process_hrafsa_enrollment', 'processing for x.entrp_id ' || x.entrp_id);
                begin
                    for xx in (
                        select
                            count(*) cnt
                        from
                            person
                        where
                                ssn = x.ssn
                            and entrp_id = x.entrp_id
                            and pc_account.check_duplicate(x.ssn, x.acc_num, null, x.account_type, x.entrp_id) = 'Y'
                    ) loop
                        if xx.cnt > 0 then
                            if x.stacked = 'N' then
                                l_error_message := x.ssn || ' cannot enroll, this ssn already has an account ';
                                raise l_create_error;
                            else
                                raise l_duplicate_error;
                            end if;

                        end if;
                    end loop;

                    if x.birth_date > sysdate then
                        l_error_message := x.ssn || ' cannot enroll, Date of birth is in future ';
                        raise l_create_error;
                    end if;

                    if isalphanumeric(x.last_name) is not null then
                        l_error_message := ' Special Characters '
                                           || isalphanumeric(x.last_name)
                                           || ' are not allowed for last name ';
                        raise l_create_error;
                    end if;

                    if isalphanumeric(x.first_name) is not null then
                        l_error_message := ' Special Characters '
                                           || isalphanumeric(x.first_name)
                                           || ' are not allowed for first name ';
                        raise l_create_error;
                    end if;

                    if isalphanumeric(x.middle_name) is not null then
                        l_error_message := ' Special Characters '
                                           || isalphanumeric(x.middle_name)
                                           || ' are not allowed for middle name ';
                        raise l_create_error;
                    end if;

                    if regexp_like(
                        replace(x.ssn, '-'),
                        '^[[:digit:]]{9}$'
                    ) then
                        null;
                    else
                        l_error_message := x.ssn || ' cannot enroll, SSN must be in the format of 999-99-9999';
                        raise l_create_error;
                    end if;

                    if
                        x.division_code is not null
                        and pc_employer_divisions.get_division_count(x.entrp_id,
                                                                     upper(x.division_code)) = 0
                    then
                        l_error_message := x.ssn
                                           || ' cannot enroll, Cannot find Division code '
                                           || x.division_code;
                        raise l_create_error;
                    end if;

                    insert into person (
                        pers_id,
                        first_name,
                        middle_name,
                        last_name,
                        title   -- Aded by Jaggi #9579
                        ,
                        birth_date,
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
                        entrp_id,
                        person_type,
                        mass_enrollment_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        division_code
                    ) values ( pers_seq.nextval,
                               ltrim(rtrim(x.first_name)),
                               substr(x.middle_name, 1, 1),
                               ltrim(rtrim(x.last_name)),
                               x.title   -- Added by Jaggi #9579
                               ,
                               x.birth_date,
                               x.gender,
                               x.ssn,
                               ltrim(rtrim(x.address)),
                               ltrim(rtrim(x.city)),
                               ltrim(rtrim(x.state)),
                               x.zip,
                               x.phone,
                               ltrim(rtrim(x.email)),
                               1,
                               'Online Enrollment',
                               x.entrp_id,
                               'SUBSCRIBER',
                               x.enrollment_id,
                               sysdate,
                               x.created_by,
                               sysdate,
                               x.created_by,
                               upper(x.division_code) ) returning pers_id into l_pers_id;

                    l_account_status := 1;
                    l_complete_flag := 1;
                    pc_log.log_error('process_hrafsa_enrollment', 'pers_id:  ' || l_pers_id);

            /*** Insert Account, Insurance, Income and Debit Card ****/
         -- Insertinto Account
			-- populating enrollment_source from online_enrollment table for webform : Joshi
                    insert into account (
                        acc_id,
                        pers_id,
                        entrp_id,
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
                        account_type,
                        bps_hra_plan,
                        salesrep_id,
                        am_id,
                        lang_perf,
                        created_by,
                        last_updated_by,
                        enrollment_source
                    ) values ( acc_seq.nextval,
                               l_pers_id,
                               null,
                               pc_account.generate_acc_num(x.plan_code,
                                                           upper(x.state)),
                               x.plan_code,
                               nvl(x.start_date, sysdate),
                               0,
                               nvl(x.broker_id, 0),
                               'Online Enrollment',
                               x.fee_setup,
                               x.fee_month,
                               sysdate,
                               1,
                               1,
                               'Y',
                               x.account_type,
                               x.bps_hra_plan,
                               x.salesrep_id,
                               x.am_id  -- 5022: secondary salesrep should be populated.
                               ,
                               x.lang_perf,
                               x.created_by,
                               x.created_by,
                               x.enrollment_source );

                    for zz in (
                        select
                            acc_id,
                            acc_num
                        from
                            account a
                        where
                            pers_id = l_pers_id
                    ) loop
                        l_acc_id := zz.acc_id;
                        l_acc_num := zz.acc_num;
                    end loop;

                    update person a
                    set
                        acc_numc = reverse(l_acc_num)
                    where
                        acc_numc is null;

                    pc_log.log_error('process_hrafsa_enrollment', 'ACC_ID' || l_acc_id);
                    pc_log.log_error('process_hrafsa_enrollment', 'l_acc_num' || l_acc_num);
                    if x.carrier_id is not null then
                        insert into insure (
                            pers_id,
                            insur_id,
                            start_date,
                            deductible,
                            note,
                            plan_type
                        ) values ( l_pers_id,
                                   x.carrier_id,
                                   sysdate,
                                   1200,
                                   'Employee Online Enrollment',
                                   0 );

                    end if;

                    if upper(x.debit_card_flag) in ( 'YES', 'Y' ) then
                        insert into card_debit (
                            card_id,
                            start_date,
                            emitent,
                            note,
                            status,
                            card_number,
                            created_by,
                            last_updated_by,
                            last_update_date
                        )
                            select
                                l_pers_id,
                                nvl(x.start_date, sysdate),
                                6763 -- Metavante
                                ,
                                'Online Enrollment'
           --, CASE WHEN x.enrollment_source = 'EXCEL' THEN 1 ELSE 9 END
                                ,
                                decode(x.enrollment_source, 'EXCEL', 1, 'WEBFORM_ENROLL', 1,
                                       9) -- Joshi for Webform.
                                       ,
                                null,
                                x.created_by,
                                x.created_by,
                                sysdate
                            from
                                dual
                            where
                                exists (
                                    select
                                        *
                                    from
                                        enterprise
                                    where
                                            entrp_id = x.entrp_id
                                        and nvl(card_allowed, 1) = 0
                                );

                    end if;

                    update online_enrollment
                    set
                        acc_id = l_acc_id,
                        pers_id = l_pers_id,
                        acc_num = l_acc_num
                    where
                        enrollment_id = x.enrollment_id;

                exception
                    when l_duplicate_error then
                        null;
                end;

                for xx in (
                    select
                        plan_type,
                        effective_date,
                        annual_election,
                        er_ben_plan_id,
                        case
                            when plan_type in ( 'FSA', 'LPF' ) then
                                nvl(covg_tier_name, 'SINGLE')
                            else
                                covg_tier_name
                        end covg_tier_name,
                        case
                            when action = 'R'
                                 and plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                                'OPEN_ENROLLMENT'
                            when action = 'N'
                                 and plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                                'NEW_HIRE'
                            else
                                life_event_code
                        end life_event_code
                    from
                        online_enroll_plans
                    where
                            enrollment_id = x.enrollment_id
                        and status is null
                ) loop
                    pc_log.log_error('PC_HRAFSA_ONLINE_ENROLLMENT', 'Getting ben plan id' || xx.plan_type);
                    pc_log.log_error('PC_HRAFSA_ONLINE_ENROLLMENT', 'Getting ben plan id' || xx.effective_date);
                    pc_log.log_error('PC_FSA_ONLINE_ENROLLMENT', 'l_er_ben_plan_id ' || xx.er_ben_plan_id);
                    pc_log.log_error('PC_FSA_ONLINE_ENROLLMENT', 'xx.annual_election ' || xx.annual_election);
                    pc_log.log_error('PC_FSA_ONLINE_ENROLLMENT',
                                     'length of xx.annual_election ' || length(xx.annual_election));
                    if xx.er_ben_plan_id is not null then
                        pc_benefit_plans.add_renew_employees(
                            p_acc_id          => l_acc_id,
                            p_annual_election => xx.annual_election,
                            p_er_ben_plan_id  => xx.er_ben_plan_id,
                            p_user_id         => x.created_by,
                            p_cov_tier_name   => xx.covg_tier_name,
                            p_effective_date  => xx.effective_date,
                            p_batch_number    => p_batch_number,
                            x_return_status   => x_return_status,
                            x_error_message   => x_error_message,
                            p_status          => x.plan_status,
                            p_life_event_code => nvl(xx.life_event_code, 'NEW_HIRE')
                        );
                    else
                        pc_log.log_error('PC_HRAFSA_ONLINE_ENROLLMENT', 'Plan is not defined for , acc_id '
                                                                        || l_acc_id
                                                                        || ' for plan type '
                                                                        || xx.plan_type
                                                                        || ' error '
                                                                        || x_return_status
                                                                        || ':message '
                                                                        || x_error_message);
                    end if;

                end loop;

            exception
                when l_create_error then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || l_error_message;
                    pc_log.log_error('FSA EXCEPTION', 'error message ' || l_error_message);
           --   x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                when others then
                    rollback to savepoint enroll_savepoint;
                    l_error_message := l_action
                                       || ' '
                                       || sqlerrm;
                    pc_log.log_error('FSA EXCEPTION', 'error message ' || l_error_message);
                    x_return_status := 'E';
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = 'E'
                    where
                        enrollment_id = x.enrollment_id;

                    raise;
                    dbms_output.put_line('error message ' || sqlerrm);
            end;

        end loop;

        for x in (
            select
                b.acc_id ee_acc_id,
                a.acc_id,
                a.entrp_id,
                a.plan_type,
                a.plan_start_date,
                a.plan_end_date,
                b.created_by
            from
                ben_plan_enrollment_setup a,
                online_enrollment         b
            where
                    a.entrp_id = b.entrp_id
                and a.batch_number = b.batch_number
                and a.batch_number = p_batch_number
                and a.ben_plan_id = l_er_ben_plan_id
        ) loop
            l_scheduler_id := pc_schedule.get_scheduler_id(
                p_entrp_id        => x.entrp_id,
                p_acc_id          => x.acc_id,
                p_plan_type       => x.plan_type,
                p_plan_start_date => x.plan_start_date,
                p_plan_end_date   => x.plan_end_date
            );

     -- get scheduler id , if there is any add this employee to that schedule
            pc_schedule.ins_scheduler_details(
                p_scheduler_id        => l_scheduler_id,
                p_acc_id              => x.ee_acc_id,
                p_er_amount           => 0,
                p_ee_amount           => 0,
                p_er_fee_amount       => 0,
                p_ee_fee_amount       => 0,
                p_user_id             => x.created_by,
                x_scheduler_detail_id => l_sdetail_id,
                x_return_status       => l_return_status,
                x_error_message       => x_error_message
            );

        end loop;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := l_error_message
                               || ' '
                               || sqlerrm;
    end process_hrafsa_enrollment;

    procedure process_terminations (
        p_entrp_id     in number,
        p_batch_number in number
    ) is
        l_exists  varchar2(1) := 'N';
        p_user_id number;
    begin
    --  x_return_status := 'S';
        pc_log.log_error('process_terminations', 'Beginning of terminations');
        for x in (
            select
                me.acc_id,
                me.entrp_id,
                mep.termination_date termination_date,
                mep.plan_type,
                bp.ben_plan_id,
                mep.enroll_plan_id,
                me.last_updated_by
            from
                online_enrollment         me,
                online_enroll_plans       mep,
                ben_plan_enrollment_setup bp
            where
                    me.enrollment_id = mep.enrollment_id
                and mep.plan_type = bp.plan_type
                and account_type in ( 'HRA', 'FSA' )
                and me.acc_id = bp.acc_id
                and mep.status is null
                and nvl(me.enrollment_status, 'S') in ( 'S', 'W' )
                and bp.ben_plan_id_main = mep.er_ben_plan_id
                and me.batch_number = p_batch_number
                and me.entrp_id = p_entrp_id
                and mep.termination_date is not null
        ) loop
            l_exists := 'Y';
            pc_termination.insert_termination_interface(
                p_acc_id          => x.acc_id,
                p_entrp_id        => x.entrp_id,
                p_life_event_code => 'TERM_ONE_PLAN',
                p_effective_date  => x.termination_date,
                p_user_id         => x.last_updated_by,
                p_plan_type       => x.plan_type,
                p_ben_plan_id     => x.ben_plan_id,
                p_batch_number    => p_batch_number
            );

            p_user_id := x.last_updated_by;
        end loop;

        if l_exists = 'Y' then
            pc_termination.terminate_plans(
                p_batch_number => p_batch_number,
                p_user_id      => p_user_id
            );
            for x in (
                select
                    me.acc_id,
                    me.entrp_id,
                    mep.termination_date termination_date,
                    mep.plan_type,
                    bp.ben_plan_id,
                    me.enrollment_id,
                    mep.enroll_plan_id
                from
                    online_enrollment         me,
                    online_enroll_plans       mep,
                    ben_plan_enrollment_setup bp
                where
                        me.enrollment_id = mep.enrollment_id
                    and mep.plan_type = bp.plan_type
                    and me.acc_id = bp.acc_id
                    and bp.status = 'I'
                    and account_type in ( 'HRA', 'FSA' )
                    and bp.ben_plan_id = mep.ben_plan_id
                    and mep.termination_date is not null
                    and me.batch_number = p_batch_number
            ) loop
                if x.termination_date is not null then
                    update online_enrollment
                    set
                        enrollment_status = 'S',
                        error_message = 'Terminated Successfully'
                    where
                            enrollment_id = x.enrollment_id
                        and account_type in ( 'HRA', 'FSA' )
                        and enrollment_status is null;

                    update online_enroll_plans
                    set
                        status = 'Terminated Successfully'
                    where
                            enroll_plan_id = x.enroll_plan_id
                        and termination_date is not null;

                end if;
            end loop;

        end if;

    exception
        when others then
            raise_application_error('-20001', 'Error in Process termination ' || sqlerrm);
    end process_terminations;

    procedure process_annual_election_change (
        p_batch_number in number
    ) is

        l_return_status     varchar2(3200);
        l_error_message     varchar2(3200);
        l_rn                number;
        l_batch_number      number;
        l_list_bill         number;
        l_prefund_list_bill number;
        l_entrp_id          number;
        l_amount            number := 0;
        plan_validation_error exception;
        l_user_id           number;
    begin
        pc_log.log_error('process_annual_election_change', 'Beginning of change');
        for x in (
            select
                me.acc_id,
                me.entrp_id,
                x.plan_type,
                bp.plan_end_date-- Select plan end date  13121
                ,
                bp.ben_plan_id,
                x.enroll_plan_id,
                x.er_ben_plan_id,
                x.annual_election,
                x.annual_election - bp.annual_election amount--pier 2683
                ,
                bp.annual_election                     ee_annual_election,
                me.created_by,
                me.enrollment_id,
                x.action
            from
                online_enrollment         me,
                online_enroll_plans       x,
                ben_plan_enrollment_setup bp
            where
                    me.enrollment_id = x.enrollment_id
                and me.batch_number = x.batch_number
                and x.plan_type = bp.plan_type
                and me.acc_id = bp.acc_id
               -- and    X.STATUS IS NULL
                and x.action in ( 'A', 'C' )
                and me.action in ( 'A', 'C' )
                and bp.status = 'A'
              --  AND    (ME.ENROLLMENT_STATUS IS NULL OR ME.ENROLLMENT_STATUS = 'W')
                and bp.ben_plan_id_main = x.er_ben_plan_id
                and x.annual_election != bp.annual_election
                and me.batch_number = p_batch_number
        ) loop
            begin
                if
                    process_upload.validate_annual_election(x.er_ben_plan_id, x.annual_election) <> 'Y'
                    and x.action in ( 'A', 'C' )
                then
                    l_error_message := 'Annual election should be within the defined range for plan type ' || x.plan_type;
                    l_return_status := 'E';
                    raise plan_validation_error;
                end if;

                pc_log.log_error('process_annual_election_change', 'after process_upload.VALIDATE_ANNUAL_ELECTION');
                if is_number(x.annual_election) = 'N' then
                    l_error_message := 'Enter Numeric Value for Annual Election for plan type ' || x.plan_type;
                    l_return_status := 'E';
                    raise plan_validation_error;
                end if;

                update online_enroll_plans
                set
                    ben_plan_id = x.ben_plan_id
                where
                    enroll_plan_id = x.enroll_plan_id;

                if x.action in ( 'A', 'C' ) then
                    l_return_status := 'S';
                    pc_ben_life_events.insert_ee_ben_life_events(
                        p_acc_id          => x.acc_id,
                        p_ben_plan_id     => x.ben_plan_id,
                        p_plan_type       => x.plan_type,
                        p_life_event_code => 'ANNUAL_ELEC_UPDATE',
                        p_description     => 'Annual Election Change',
                        p_annual_election => x.annual_election,
                        p_payroll_contrib => 0,
                        p_effective_date  => to_char(sysdate, 'mm/dd/yyyy'),
                        p_cov_tier_name   => 'null',
                        p_user_id         => x.created_by,
                        p_batch_number    => p_batch_number,
                        x_return_status   => l_return_status,
                        x_error_message   => l_error_message
                    );

                    pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', 'X_RETURN_STATUS' || l_return_status);
                    pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', 'L_ERROR_MESSAGE' || l_error_message);
                    if l_return_status <> 'S' then
                        l_return_status := 'E';
                        raise plan_validation_error;
                    end if;
                    pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', 'ee_annual_election' || x.ee_annual_election);
                    update ben_life_event_history
                    set
                        original_annual_election = nvl(x.ee_annual_election, 0)
                    where
                            batch_number = p_batch_number
                        and ben_plan_id = x.ben_plan_id;

                    pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', ' x.ben_plan_id' || x.ben_plan_id);
                end if;

                l_user_id := x.created_by;
            exception
                when plan_validation_error then
                    update online_enrollment
                    set
                        error_message = l_error_message,
                        enrollment_status = l_return_status
                    where
                            batch_number = p_batch_number
                        and account_type in ( 'FSA', 'HRA' )
                        and error_message is null
                        and enrollment_status is null
                        and enrollment_id = x.enrollment_id;

                    update online_enroll_plans
                    set
                        status = l_error_message
                    where
                            batch_number = p_batch_number
                        and enroll_plan_id = x.enroll_plan_id
                        and nvl(plan_type, 0) = nvl(x.plan_type, 0)
                        and status is null;

            end;
        end loop;

        pc_log.log_error('INSERT_EE_BEN_LIFE_EVENTS', ' CHANGE_ANNUAL_ELECTION');
        pc_benefit_plans.change_annual_election(p_batch_number, l_user_id, 'ONLINE', l_return_status, l_error_message);
    end process_annual_election_change;

  --Ticket#5422(Enroll Dependants)
    procedure process_dependants (
        p_batch_number  in varchar2,
        p_entrp_id      in varchar2,
        p_file_name     in varchar2,
        p_lang_perf     in varchar2,
        p_user_id       in number,
        p_enroll_source in varchar2 default 'EXCEL',
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_batch_number   number;
        lv_dest_file     varchar2(100);
        l_file_upload_id number;
        l_blob           blob;
        l_file           utl_file.file_type;
        l_blob_len       integer;
        l_pos            integer := 1;
        l_amount         binary_integer := 32767;
        l_buffer         raw(32767);
        l_error_status   varchar2(100);
    begin
        pc_log.log_error('pc_online_enrollment', 'in process_dependants ' || p_file_name);
        x_return_status := null;
        if p_file_name is not null then
            insert into file_upload_history (
                file_upload_id,
                entrp_id,
                file_name,
                batch_number,
                action,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( file_upload_history_seq.nextval,
                       p_entrp_id,
                       p_file_name,
                       p_batch_number,
                       'ENROLL_DEPENDANT',
                       sysdate,
                       p_user_id --- 7781 rprabu 30/05/2019    421 replaced with 7781
                       ,
                       sysdate,
                       p_user_id --- 7781 rprabu 30/05/2019    421 replaced with 7781
                        ) returning file_upload_id into l_file_upload_id;

        end if;

        validate_dependants(p_entrp_id, p_user_id, 'ONLINE', p_batch_number, l_error_status);
        if l_error_status = 'S' then
            process_upload.process_dependants(p_entrp_id, p_batch_number);
        end if;
        if p_file_name is not null then
            pc_log.log_error('pc_online_enrollment', 'in loop ' || p_file_name);
            for x in (
                select
                    sum(
                        case
                            when error_message = 'Successfully Loaded' then
                                1
                            else
                                0
                        end
                    ) success_cnt,
                    sum(
                        case
                            when error_message <> 'Successfully Loaded' then
                                1
                            else
                                0
                        end
                    ) failure_cnt
                from
                    mass_enroll_dependant
                where
                    batch_number = p_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    pc_log.log_error('pc_online_enrollment', 'in loop ..Error' || p_file_name);
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = l_file_upload_id;

                    x_return_status := 'E';
                else
                    pc_log.log_error('pc_online_enrollment', 'in loop success' || p_file_name);
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' dependants, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' dependants failed to load '
                        )
                    where
                        file_upload_id = l_file_upload_id;

                    x_return_status := 'S';
                end if;
            end loop;

        end if;

    exception
        when others then
            pc_log.log_error('pc_online_enrollment..Exception', sqlerrm);
    end process_dependants;

  /* Ticket#5422 */
    procedure validate_dependants (
        pv_entrp_id    in number,
        p_user_id      in number,
        p_source       in varchar2 default null,
        p_batch_number in number,
        x_error_status out varchar2
    ) is
        l_batch_number number;
    begin
        pc_log.log_error('pc_online_enrollment', 'Validate Dependants');
        update mass_enroll_dependant
        set
            error_message = 'Gender Cannot have more than one character',
            error_column = 'GENDER'
        where
                entrp_acc_id = pv_entrp_id
            and length(gender) > 1
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Middle Name Cannot have more than one character',
            error_column = 'MIDDLE_NAME'
        where
                entrp_acc_id = pv_entrp_id
            and length(middle_name) > 1
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Correct Birth Date',
            error_column = 'BIRTH_DATE'
        where
                entrp_acc_id = pv_entrp_id
            and format_to_date(birth_date) is null
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Correct Effective Date',
            error_column = 'EFFECTIVE_DATE'
        where
                entrp_acc_id = pv_entrp_id
            and format_to_date(effective_date) is null
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Subscriber SSN Cannot be Null',
            error_column = 'SUBSCRIBER_SSN'
        where
            subscriber_ssn is null
            and entrp_acc_id = pv_entrp_id
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enroll_dependant a
        set
            error_message = 'Cannot find employee account with SSN# '
                            || a.subscriber_ssn
                            || ' .Please verify your entry',
            error_column = 'SUBSCRIBER_SSN'
      -- WHERE  NOT EXISTS ( SELECT * FROM PERSON WHERE SSN =A.SUBSCRIBER_SSN)
        where
            not exists (
                select
                    *
                from
                    employees_v b
                where
                        b.ssn = a.subscriber_ssn
                    and b.entrp_id = pv_entrp_id
            )
                and entrp_acc_id = pv_entrp_id
                and batch_number = p_batch_number
                and error_message is null;

 --     Validations
        update mass_enroll_dependant
        set
            error_message = 'Last Name Cannot be Null',
            error_column = 'LAST_NAME'
        where
            last_name is null
            and entrp_acc_id = pv_entrp_id
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'First Name Cannot be Null',
            error_column = 'FIRST_NAME'
        where
            first_name is null
            and entrp_acc_id = pv_entrp_id
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant a
        set
            error_message = 'This dependent already exists for this Employee SSN '
                            || a.ssn
                            || '.Cannot create duplicate dependents',
            error_column = 'DUPLICATE'
        where
                (
                    select
                        count(*)
                    from
                        person  c,
                        person  b,
                        account acc
                    where
                            c.ssn = a.ssn
                        and acc.pers_id = c.pers_main
                        and acc.account_type = nvl(a.account_type, acc.account_type)
                        and c.pers_main = b.pers_id
                        and b.ssn = a.subscriber_ssn
                    group by
                        a.account_type
                ) > 0
            and error_message is null
            and batch_number = p_batch_number
            and upper(dep_flag) <> upper('Beneficiary');

        update mass_enroll_dependant
        set
            error_message = 'The Birth Date must be between 01011900 and Current Date',
            error_column = 'BIRTH_DATE'
        where
            format_to_date(birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate
            and birth_date is not null
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'SSN must be in the format of 999999999',
            error_column = 'SSN'
        where
            not regexp_like ( replace(ssn, '-'),
                              '^[[:digit:]]{9}$' )
                and ssn is not null
                and error_message is null
                and batch_number = p_batch_number
                and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'The Effective Date of Beneficiary must be between 01011900 and '
                            || to_char(sysdate + 120, 'MM/DD/YYYY'),
            error_column = 'EFFECTIVE_DATE'
        where
            format_to_date(effective_date) not between to_date('01011900', 'MMDDRRRR') and sysdate + 120
            and effective_date is not null
            and error_message is null
            and batch_number = p_batch_number
            and dep_flag = 'Beneficiary';

        pc_log.log_error('In Pc Online Enrollment', 'End Vaidate Dependants');
        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            raise_application_error('-20001', 'Error in validating dependents ' || sqlerrm);

 --       COMMIT;
    end validate_dependants;

-- Added by swamy for Ticket#12367
    procedure upsert_beneficiary (
        p_pers_id              in number,
        p_beneficiary_id       in number,
        p_first_name           in varchar2,
        p_beneficiary_type     in varchar2,
        p_beneficiary_relation in varchar2,
        p_user_id              in number,
        p_distiribution        in number,
        p_note                 in varchar2,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    ) is
    begin
        pc_log.log_error('In Pc Online Enrollment.upsert_BENEFICIARY p_pers_id', 'p_pers_id'
                                                                                 || p_pers_id
                                                                                 || 'p_user_id :='
                                                                                 || p_user_id
                                                                                 || 'p_beneficiary_id :='
                                                                                 || p_beneficiary_id
                                                                                 || 'p_first_name :='
                                                                                 || p_first_name
                                                                                 || 'p_beneficiary_type :='
                                                                                 || p_beneficiary_type
                                                                                 || ' p_distiribution :='
                                                                                 || p_distiribution
                                                                                 || ' p_beneficiary_relation :='
                                                                                 || p_beneficiary_relation);

        if nvl(p_beneficiary_id, 0) = 0 then
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
                note
            ) values ( beneficiary_seq.nextval,
                       p_first_name,
                       decode(
                           upper(p_beneficiary_type),
                           'PRIMARY',
                           1,
                           'CONTINGENT',
                           2,
                           null
                       ),
                       p_beneficiary_relation,
                       sysdate,
                       p_pers_id,
                       sysdate,
                       p_user_id,
                       p_distiribution,
                       'Online Manage Beneficiaries' );

        else
            update beneficiary
            set
                beneficiary_name = p_first_name,
                beneficiary_type = decode(p_beneficiary_type, 'PRIMARY', 1, 'CONTINGENT', 2,
                                          p_beneficiary_type),
                relat_code = p_beneficiary_relation
           --     ,effective_date = SYSDATE
                ,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                distribution = p_distiribution,
                note = p_note
            where
                    beneficiary_id = p_beneficiary_id
                and pers_id = p_pers_id;

        end if;

        x_return_status := 'S';
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('In Pc Online Enrollment.upsert_BENEFICIARY others ', 'error'
                                                                                   || sqlerrm
                                                                                   || dbms_utility.format_error_backtrace);
            raise_application_error('-20001', 'Error in pc_online_enrollment.upsert_BENEFICIARY ' || sqlerrm);
    end upsert_beneficiary;

-- Added by Joshi for Ticket#12367
    function get_beneficiary (
        p_pers_id in number
    ) return beneficiary_t
        pipelined
        deterministic
    is
        l_record beneficiary_rec;
    begin
        for x in (
            select
                beneficiary_id,
                beneficiary_name,
                beneficiary_type,
                pc_lookups.get_meaning(beneficiary_type, 'BENEFICIARY_TYPE') beneficiary_type_desc,
                relat_code,
                effective_date,
                distribution
            from
                beneficiary
            where
                pers_id = p_pers_id
        ) loop
            l_record.beneficiary_id := x.beneficiary_id;
            l_record.beneficiary_name := x.beneficiary_name;
            l_record.beneficiary_type := x.beneficiary_type;
            l_record.beneficiary_type_desc := x.beneficiary_type_desc;
            l_record.relat_code := x.relat_code;
            l_record.effective_date := x.effective_date;
            l_record.distribution := x.distribution;
            pipe row ( l_record );
        end loop;
    end get_beneficiary;

end pc_online_enrollment;
/

