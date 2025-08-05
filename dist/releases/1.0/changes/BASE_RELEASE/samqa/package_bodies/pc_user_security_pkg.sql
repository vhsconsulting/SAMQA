-- liquibase formatted sql
-- changeset SAMQA:1754374095434 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_user_security_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_user_security_pkg.sql:null:f1ca75ca4ea576d22dbd0fc04f7d10b1d7661d87:create

create or replace package body samqa.pc_user_security_pkg is

    procedure validate_user_security_info (
        p_user_id       in number,
        p_site_key      in varchar2,
        p_pw_question1  in number,
        p_pw_answer1    in varchar2,
        p_pw_question2  in number,
        p_pw_answer2    in varchar2,
        p_pw_question3  in number,
        p_pw_answer3    in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        e_required_val exception;
        l_return_val varchar2(10) := 'X';
    begin
        x_return_status := 'S';
        pc_log.log_error('validate_user_security_info', 'p_user_id ' || p_user_id);
        pc_log.log_error('validate_user_security_info', 'p_pw_answer1 ' || p_pw_answer1);
        pc_log.log_error('validate_user_security_info', 'p_pw_answer2 ' || p_pw_answer2);
        pc_log.log_error('validate_user_security_info', 'p_pw_answer3 ' || p_pw_answer3);
    --IF security_setting_exist(p_user_id) = 'N' THEN

        if
            p_pw_answer1 is null
            and p_pw_answer2 is null
            and p_pw_answer3 is null
        then
            x_error_message := 'Security Answers are required, Enter Value for Security Answer 1, Security Answer 2 and Security Answer3 '
            ;
            raise e_required_val;
        end if;

        if
            p_pw_answer1 is not null
            and p_pw_answer2 is null
            and p_pw_answer3 is null
        then
            x_error_message := 'Security Answers are required, Enter Value for Security Answer 2 and Security Answer3 ';
            raise e_required_val;
        end if;

        if
            p_pw_answer1 is null
            and p_pw_answer2 is not null
            and p_pw_answer3 is null
        then
            x_error_message := 'Security Answers are required, Enter Value for Security Answer 1 and Security Answer3 ';
            raise e_required_val;
        end if;

        if
            p_pw_answer1 is null
            and p_pw_answer2 is null
            and p_pw_answer3 is not null
        then
            x_error_message := 'Security Answers are required, Enter Value for Security Answer 1 and Security Answer2 ';
            raise e_required_val;
        end if;

        if p_pw_question1 is null then
            x_error_message := 'Select Security Question 1 ';
            raise e_required_val;
        end if;
        if p_pw_answer1 is null then
            x_error_message := 'Enter Security Answer 1 ';
            raise e_required_val;
        end if;
        if p_pw_question2 is null then
            x_error_message := 'Select Security Question 2 ';
            raise e_required_val;
        end if;
        if p_pw_answer2 is null then
            x_error_message := 'Enter Security Answer 2 ';
            raise e_required_val;
        end if;
        if p_pw_question3 is null then
            x_error_message := 'Select Security Question 3 ';
            raise e_required_val;
        end if;
        if p_pw_answer3 is null then
            x_error_message := 'Enter Security Answer 3 ';
            raise e_required_val;
        end if;
        if length(p_pw_answer1) > 100 then
            x_error_message := 'Security Answer1 Exceeds the maximum length ';
            raise e_required_val;
        end if;

        if length(p_pw_answer2) > 100 then
            x_error_message := 'Security Answer2 Exceeds the maximum length ';
            raise e_required_val;
        end if;

        if length(p_pw_answer3) > 100 then
            x_error_message := 'Security Answer3 Exceeds the maximum length ';
            raise e_required_val;
        end if;

        pc_log.log_error('validate_user_security_info',
                         'transaclating '
                         || translate(p_pw_answer3, '~!@#$%^&*()_+?><":/', '###########'));

        if instr(
            translate(p_pw_answer1, '~!@#$%^&*()_+?><":/', '###########'),
            '#'
        ) > 0 then
            x_error_message := 'Enter Security Answer 1 in alphanumeric characters only ';
            raise e_required_val;
        end if;

        if instr(
            translate(p_pw_answer2, '~!@#$%^&*()_+?><":/', '###########'),
            '#'
        ) > 0 then
            x_error_message := 'Enter Security Answer 2 in alphanumeric characters only ';
            raise e_required_val;
        end if;

        if instr(
            translate(p_pw_answer3, '~!@#$%^&*()_+?><":/', '###########'),
            '#'
        ) > 0 then
            x_error_message := 'Enter Security Answer 3 in alphanumeric characters only';
            raise e_required_val;
        end if;

        if ( p_pw_question1 = p_pw_question2 )
        or ( p_pw_question1 = p_pw_question3 )
        or ( p_pw_question3 = p_pw_question2 ) then
            x_error_message := 'Select different Security question for each question, Cannot select same Security questions more than once '
            ;
            raise e_required_val;
        end if;
 --   END IF;

    exception
        when e_required_val then
            x_return_status := 'E';
            pc_log.log_error('validate_user_security_info', 'x_error_message ' || x_error_message);
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end validate_user_security_info;

    procedure insert_user_security_info (
        p_user_id       in number,
        p_site_key      in varchar2,
        p_pw_question1  in number,
        p_pw_answer1    in varchar2,
        p_pw_question2  in number,
        p_pw_answer2    in varchar2,
        p_pw_question3  in number,
        p_pw_answer3    in varchar2,
        p_remember_pc   in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        validate_user_security_info(
            p_user_id       => p_user_id,
            p_site_key      => p_site_key,
            p_pw_question1  => p_pw_question1,
            p_pw_answer1    => p_pw_answer1,
            p_pw_question2  => p_pw_question2,
            p_pw_answer2    => p_pw_answer2,
            p_pw_question3  => p_pw_question3,
            p_pw_answer3    => p_pw_answer3,
            x_return_status => x_return_status,
            x_error_message => x_error_message
        );

        if x_return_status = 'S' then
            insert into user_security_info (
                user_id,
                site_key,
                pw_question1,
                pw_answer1,
                pw_question2,
                pw_answer2,
                pw_question3,
                pw_answer3,
                remember_pc,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( p_user_id,
                       p_site_key,
                       p_pw_question1,
                       p_pw_answer1,
                       p_pw_question2,
                       p_pw_answer2,
                       p_pw_question3,
                       p_pw_answer3,
                       p_remember_pc,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id );

        end if;

   /* Call this from the PHP program after insert to insert the photo
     $sql = "UPDATE
           mylobs
        SET
            mylob = EMPTY_BLOB()
        WHERE
           id = 2403
        RETURNING
            mylob INTO :mylob";

	$stmt = OCIParse($conn, $sql);

	$mylob = OCINewDescriptor($conn,OCI_D_LOB);

	OCIBindByName($stmt,':mylob',$mylob, -1, OCI_B_CLOB);

	-- Execute the statement using OCI_DEFAULT (begin a transaction)
	OCIExecute($stmt, OCI_DEFAULT)
	    or die ("Unable to execute query\n");

	if ( !$mylob->save( 'UPDATE: '.date('H:i:s',time()) ) ) {

	    OCIRollback($conn);
	    die("Unable to update lob\n");

	}

	OCICommit($conn);
	$mylob->free();
	OCIFreeStatement($stmt);
   */

    end insert_user_security_info;

    procedure insert_user_security_info (
        p_user_id               in number,
        p_otp_verified          in varchar2,
        p_verified_phone_type   in varchar2,
        p_verified_phone_number in varchar2
    ) is
    begin
        insert into user_security_info (
            user_id,
            otp_verified,
            verified_phone_type,
            verified_phone_number
   --    , phone_update_date
            ,
            remember_pc,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( p_user_id,
                   p_otp_verified,
                   p_verified_phone_type,
                   p_verified_phone_number
    --   , case when p_verified_phone_type is null then null else SYSDATE END
                   ,
                   'N',
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id );

    end insert_user_security_info;

    function security_setting_exist (
        p_user_id in number
    ) return varchar2 is
        l_remember_pc varchar2(1) := 'N';
    begin
        for x in (
            select
                remember_pc
            from
                user_security_info
            where
                user_id = p_user_id
        ) loop
            l_remember_pc := x.remember_pc;
        end loop;

        return l_remember_pc;
    end security_setting_exist;

    procedure change_site_image (
        p_user_id       in number,
        p_site_image    in number,
        p_site_key      in varchar2,
        p_remember_pc   in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        e_required_val exception;
    begin
        x_return_status := 'S';
        if
            p_site_key is null
            and p_site_image is null
        then
            x_error_message := 'Enter Valid Site Key and Select a Site Image ';
            raise e_required_val;
        end if;

        if
            p_site_key is null
            and p_site_image is not null
        then
            x_error_message := 'Enter Valid Site Key  ';
            raise e_required_val;
        end if;

        if p_site_image is null then
            x_error_message := 'Select Site Image ';
            raise e_required_val;
        end if;
        if length(p_site_key) > 200 then
            x_error_message := 'Site Key exceeds the maximum width defined ';
            raise e_required_val;
        end if;

        if isalphanumeric(p_site_key) is not null then
            x_error_message := 'Enter site key in alphanumeric characters';
            raise e_required_val;
        end if;

        update user_security_info
        set
            site_key = p_site_key,
            site_image = p_site_image,
            remember_pc = p_remember_pc,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            user_id = p_user_id;

    exception
        when e_required_val then
            x_return_status := 'E';
    end change_site_image;

    function security_setting_complete (
        p_user_id in number
    ) return varchar2 is
        l_complete_code varchar2(255);
        e_setup exception;
    begin
        for x in (
            select
                *
            from
                user_security_info
            where
                user_id = p_user_id
        ) loop
            if
                x.pw_question1 is null
                and x.pw_answer1 is null
            then
                l_complete_code := 'SEC_QUES_NOT_SETUP';
                raise e_setup;
            end if;

            if
                x.pw_question2 is null
                and x.pw_answer2 is null
            then
                l_complete_code := 'SEC_QUES_NOT_SETUP';
                raise e_setup;
            end if;

            if
                x.pw_question3 is null
                and x.pw_answer3 is null
            then
                l_complete_code := 'SEC_QUES_NOT_SETUP';
                raise e_setup;
            end if;

            if
                x.pw_question3 is null
                and x.pw_answer3 is null
            then
                l_complete_code := 'SEC_QUES_NOT_SETUP';
                raise e_setup;
            end if;

            if x.site_image is null then
                l_complete_code := 'SITE_IMAGE_NOT_SETUP';
                raise e_setup;
            end if;
            if x.site_key is null then
                l_complete_code := 'SITE_KEY_NOT_SETUP';
                raise e_setup;
            end if;
        end loop;

        return null;
    exception
        when e_setup then
            return l_complete_code;
    end security_setting_complete;

    procedure change_security_question (
        p_user_id       in number,
        p_q1            in number,
        p_ans1          in varchar2,
        p_q2            in number,
        p_ans2          in varchar2,
        p_q3            in number,
        p_ans3          in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_setup_error exception;
    begin
        x_return_status := 'S';
        validate_user_security_info(
            p_user_id       => p_user_id,
            p_site_key      => null,
            p_pw_question1  => p_q1,
            p_pw_answer1    => p_ans1,
            p_pw_question2  => p_q2,
            p_pw_answer2    => p_ans2,
            p_pw_question3  => p_q3,
            p_pw_answer3    => p_ans3,
            x_return_status => x_return_status,
            x_error_message => x_error_message
        );

        pc_log.log_error('change_security_question', 'p_ans3 ' || p_ans3);
        pc_log.log_error('change_security_question', 'x_error_message ' || x_error_message);
        pc_log.log_error('change_security_question', 'x_return_status ' || x_return_status);
        if x_return_status = 'E' then
            raise l_setup_error;
        end if;
        update user_security_info
        set
            pw_question1 = nvl(p_q1, pw_question1),
            pw_answer1 = nvl(p_ans1, pw_answer1),
            pw_question2 = nvl(p_q2, pw_question1),
            pw_answer2 = nvl(p_ans2, pw_answer2),
            pw_question3 = nvl(p_q3, pw_question1),
            pw_answer3 = nvl(p_ans3, pw_answer3),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            user_id = p_user_id;

    exception
        when l_setup_error then
            null;
    end change_security_question;

    function get_security_question (
        p_question_id in number
    ) return varchar2 is
        l_count number := 0;
    begin
        for x in (
            select
                description
            from
                security_questions
            where
                security_question_id = p_question_id
        ) loop
            l_count := 1;
            return x.description;
        end loop;

        if l_count = 0 then
            return null;
        end if;
    end get_security_question;

    function get_image (
        p_user_id in number
    ) return blob is
        l_count number := 0;
    begin
        for x in (
            select
                s.security_image
            from
                user_security_info u,
                security_images    s
            where
                    u.user_id = p_user_id
                and u.site_image = s.security_image_id
        ) loop
            l_count := 1;
            return x.security_image;
        end loop;

        if l_count = 0 then
            return empty_blob();
        end if;
    end get_image;

    function get_security_info (
        p_user_id in number
    ) return user_sec_info_t
        pipelined
        deterministic
    is
        l_record_t    user_sec_info_row_t;
        l_user_id     number;
        l_no_accounts number := 0;
    begin
        for x in (
            select
                *
            from
                user_security_info
            where
                user_id = p_user_id
        ) loop
            l_record_t.site_key := x.site_key;
            l_record_t.site_image := x.site_image;
            l_record_t.pw_question1 := x.pw_question1;
            l_record_t.pw_question1_desc := get_security_question(x.pw_question1);
            l_record_t.pw_answer1 := x.pw_answer1;
            l_record_t.pw_question2 := x.pw_question2;
            l_record_t.pw_question2_desc := get_security_question(x.pw_question2);
            l_record_t.pw_answer2 := x.pw_answer2;
            l_record_t.pw_question3 := x.pw_question3;
            l_record_t.pw_question3_desc := get_security_question(x.pw_question3);
            l_record_t.pw_answer3 := x.pw_answer3;
            l_record_t.security_setting_exist := nvl(
                pc_user_security_pkg.security_setting_exist(x.user_id),
                'N'
            );

            pipe row ( l_record_t );
        end loop;
    end get_security_info;

    function get_rand_sec_info (
        p_user_id in number
    ) return user_rand_sec_info_t
        pipelined
        deterministic
    is
        l_record_t    user_rand_sec_info_row_t;
        l_user_id     number;
        l_no_accounts number := 0;
    begin
        for x in (
            select
                pw_question,
                pw_answer
            from
                (
                    select
                        pw_question1 pw_question,
                        pw_answer1   pw_answer
                    from
                        user_security_info
                    where
                        user_id = p_user_id
                    union
                    select
                        pw_question2,
                        pw_answer2
                    from
                        user_security_info
                    where
                        user_id = p_user_id
                    union
                    select
                        pw_question3,
                        pw_answer3
                    from
                        user_security_info
                    where
                        user_id = p_user_id
                )
            order by
                dbms_random.value
        ) loop
            l_record_t.pw_question := x.pw_question;
            l_record_t.pw_question_desc := get_security_question(x.pw_question);
            l_record_t.pw_answer := x.pw_answer;
            pipe row ( l_record_t );
        end loop;
    end get_rand_sec_info;

    procedure update_otp_verified (
        p_user_id  in number,
        p_verified in varchar2 default 'N'
    ) is
    begin
        update user_security_info
        set
            otp_verified = p_verified,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            user_id = p_user_id;

    end update_otp_verified;

    procedure update_otp_phone (
        p_user_id      in number,
        p_device_type  in varchar2,
        p_phone_number in varchar2,
        p_verified     in varchar2 default 'N'
    ) is
-- START Added by Swamy for Ticket#7920
        l_flg_no_update         varchar2(1) := 'N';
        l_verified_phone_number user_security_info.verified_phone_number%type;
        l_user_type             online_users.user_type%type;
        l_acc_num               account.acc_num%type;
        l_acc_id                account.acc_id%type;
        l_pers_id               account.pers_id%type;
        l_ssn                   online_users.tax_id%type;
        l_account_status        account.account_status%type;
-- End of Addition by Swamy for Ticket#7920

    begin
        pc_log.log_error('update_otp_phone', 'p_user_id ' || p_user_id);
        pc_log.log_error('update_otp_phone', 'p_user_id ' || p_verified);

 -- Start Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
        for j in (
            select
                s.verified_phone_number,
                a.acc_num,
                a.acc_id,
                a.pers_id,
                a.account_status,
                replace(u.tax_id, '-') ssn
            from
                user_security_info s,
                online_users       u,
                account            a
            where
                    s.user_id = u.user_id
                and u.find_key = a.acc_num
                and u.user_id = p_user_id
        ) loop
            l_verified_phone_number := j.verified_phone_number;
            l_acc_num := j.acc_num;
            l_acc_id := j.acc_id;
            l_pers_id := j.pers_id;
            l_account_status := j.account_status;
            l_ssn := j.ssn;
        end loop;
-- End of Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21

        update user_security_info
        set
            verified_phone_type = p_device_type,
            verified_phone_number = p_phone_number,
            last_updated_by = p_user_id,
            last_update_date = sysdate,
            otp_verified = p_verified
 --       ,  skip_date = case when p_verified = 'Y' THEN null else skip_date END
 --       , phone_update_date =  case when p_device_type is null then null else SYSDATE END
        where
            user_id = p_user_id;

        if sql%rowcount = 0 then
            insert_user_security_info(
                p_user_id               => p_user_id,
                p_otp_verified          => 'N',
                p_verified_phone_type   => p_device_type,
                p_verified_phone_number => p_phone_number
            );

            l_flg_no_update := 'Y';     -- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
        end if;

    -- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
        if
            l_flg_no_update = 'N'
            and nvl(p_phone_number, '0') <> '0'
        then
            if
                nvl(l_verified_phone_number, '0') <> nvl(p_phone_number, '0')
                and nvl(l_user_type, '0') = 'S'
            then
                pc_notification2.insert_events(
                    p_acc_id      => l_acc_id,
                    p_pers_id     => l_pers_id,
                    p_event_name  => 'PHONE',
                    p_entity_type => 'USER_SECURITY_INFO',
                    p_entity_id   => l_pers_id,   -- Replaced l_Acc_id with l_pers_id by Swamy for Ticket#8609
                    p_ssn         => l_ssn
                );      -- Replaced Null with l_ssn by Swamy for Ticket#8609

         -- Added below by Swamy for Ticket#9048 on 06-May-2020
                pc_notification2.insert_audit_security_info(
                    p_pers_id            => l_pers_id,
                    p_email              => null,
                    p_phone_no           => l_verified_phone_number,
                    p_user_id            => p_user_id,
                    p_new_email_phone_no => p_phone_number     -- Added by Swamy for Ticket#9774
                );

            end if;
        end if;

        pc_log.log_error('After update_otp_phone', 'p_user_id ' || p_user_id);
    end update_otp_phone;

    function get_otp_verified (
        p_user_id in number
    ) return varchar2 is
        l_otp_verified varchar2(1) := 'N';
    begin
        for x in (
            select
                otp_verified
            from
                user_security_info
            where
                user_id = p_user_id
        ) loop
            l_otp_verified := x.otp_verified;
        end loop;

        return l_otp_verified;
    end get_otp_verified;

    function show_phone_update_modal (
        p_user_id in number
    ) return varchar2 is
        l_show_phone_update varchar2(1) := 'Y';
    begin
        for x in (
            select
                skip_date,
                phone_update_date,
                verified_phone_number,
                verified_phone_type
            from
                user_security_info
            where
                user_id = p_user_id
        ) loop
            l_show_phone_update :=
                case
                    when
                        x.skip_date is not null
                        and trunc(sysdate) - trunc(x.skip_date) >= 60
                        and x.phone_update_date is null
                    then
                        'Y'
                    when
                        x.phone_update_date is null
                        and x.skip_date is null
                    then
                        'Y'
                    else 'N'
                end;
        end loop;

        return nvl(l_show_phone_update, 'Y');
    end show_phone_update_modal;

    procedure update_otp_phone (
        p_user_id      in number,
        p_device_type  in varchar2,
        p_phone_number in varchar2,
        p_verified     in varchar2 default 'N',
        p_skip_modal   in varchar2,
        p_email        in varchar2
    ) is

        l_user_type             varchar2(1);
        l_emp_reg_type          varchar2(1);
   -- Start Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21
        l_ssn                   online_users.tax_id%type;
        l_flg_no_update         varchar2(1) := 'N';
        l_verified_phone_number user_security_info.verified_phone_number%type;
        l_acc_num               account.acc_num%type;
        l_acc_id                account.acc_id%type;
        l_pers_id               account.pers_id%type;
        l_account_status        account.account_status%type;
   -- End of Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21
        l_user_id               number;
    begin
        pc_log.log_error('update_otp_phone', 'p_user_id ' || p_user_id);
        pc_log.log_error('update_otp_phone', 'p_verified ' || p_verified);

-- Added by Joshi for Ticket#9776
        l_user_id := get_user_id(v('APP_USER'));

 -- Start Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21
        for j in (
            select
                s.verified_phone_number,
                a.acc_num,
                a.acc_id,
                a.pers_id,
                a.account_status,
                replace(u.tax_id, '-') ssn
            from
                user_security_info s,
                online_users       u,
                account            a
            where
                    s.user_id = u.user_id
                and u.find_key = a.acc_num
                and u.user_id = p_user_id
        ) loop
            l_verified_phone_number := j.verified_phone_number;
            l_acc_num := j.acc_num;
            l_acc_id := j.acc_id;
            l_pers_id := j.pers_id;
            l_account_status := j.account_status;
            l_ssn := j.ssn;
        end loop;
 -- End of Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21

        update online_users
        set
            email =
                case
                    when p_email is null then
                        email
                    else
                        p_email
                end,
            last_updated_by = nvl(l_user_id, p_user_id) -- Added by Joshi for Ticket#9776
            ,
            last_update_date = sysdate
        where
            user_id = p_user_id
        returning user_type,
                  emp_reg_type into l_user_type, l_emp_reg_type;

   -- Below IF cond. added by Swamy for Ticket#9774
        if l_user_type = 'S' then
            update person
            set
                email =
                    case
                        when p_email is null then
                            email
                        else
                            p_email
                    end,
                last_updated_by = nvl(l_user_id, p_user_id),
                last_update_date = sysdate
            where
                ssn in (
                    select
                        format_ssn(tax_id)
                    from
                        online_users
                    where
                        user_id = p_user_id
                );

        end if;

        if p_phone_number is not null then
            pc_log.log_error('update_otp_phone', 'Phone# ' || p_phone_number);
            update user_security_info
            set
                verified_phone_type = p_device_type,
                verified_phone_number = p_phone_number
           -- , last_updated_by  = p_user_id -- Added by Joshi for Ticket#9776
                ,
                last_updated_by = nvl(l_user_id, p_user_id),
                last_update_date = sysdate,
                otp_verified = p_verified,
                skip_date =
                    case
                        when p_skip_modal = 'Y' then
                            sysdate
                        when p_verified = 'Y'   then
                            null
                        else
                            skip_date
                    end,
                phone_update_date =
                    case
                        when p_skip_modal = 'Y' then
                            null
                        when verified_phone_type is not null then
                            sysdate
                        else
                            sysdate
                    end
            where
                user_id = p_user_id;

            if sql%rowcount = 0 then
                insert_user_security_info(
                    p_user_id               => p_user_id,
                    p_otp_verified          => 'N',
                    p_verified_phone_type   => p_device_type,
                    p_verified_phone_number => p_phone_number
                );

                update user_security_info
                set
                    skip_date =
                        case
                            when p_skip_modal = 'Y' then
                                sysdate
                            when p_verified = 'Y'   then
                                null
                            else
                                skip_date
                        end,
                    phone_update_date =
                        case
                            when p_skip_modal = 'Y' then
                                null
                            when verified_phone_type is not null then
                                sysdate
                            else
                                sysdate
                        end
                where
                    user_id = p_user_id;

                l_flg_no_update := 'Y';   -- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
            end if;

            if l_user_type = 'S' then
                update person
                set
                    phone_day = p_phone_number,
                    last_updated_by = nvl(l_user_id, p_user_id) -- Added by Joshi for Ticket#9776
                    ,
                    last_update_date = sysdate
                where
                    ssn in (
                        select
                            format_ssn(tax_id)
                        from
                            online_users
                        where
                            user_id = p_user_id
                    );

            end if;

        -- Commented by Swamy for Ticket#Production issue on 29/10/21
		-- When user updates phone no for a user in sam it should not update the enterprise phone no.
		/*IF l_user_type = 'E'  AND l_emp_reg_type = 2 THEN
               pc_log.log_error('update_otp_phone','Employer# '||p_phone_number);

          UPDATE enterprise SET entrp_phones = p_phone_number
          where entrp_code in ( select tax_id from online_users where user_id = p_user_id);

                         pc_log.log_error('update_otp_phone','After Update# '||p_phone_number);

        END IF;
		*/
            if l_user_type = 'B' then
                update contact
                set
                    phone = p_phone_number,
                    email = p_email
                where
                    user_id = p_user_id;

                if pc_users.is_main_online_broker(p_user_id) = 'Y' then   ----------9132 rprabu 01/06/2020 rprabu added
                    update person
                    set
                        phone_day = p_phone_number
                    where
                        pers_id in (
                            select
                                b.broker_id
                            from
                                online_users ou, broker       b
                            where
                                    user_id = p_user_id
                                and ou.find_key = b.broker_lic
                        );

                end if;

            elsif l_user_type = 'G' then            -----------8890 rprabu 11/06/2020

                update contact
                set
                    phone = p_phone_number,
                    email = p_email
                where
                    user_id = p_user_id;

            end if;

        else
            update user_security_info
            set
                skip_date =
                    case
                        when phone_update_date is null
                             and p_skip_modal = 'Y' then
                            sysdate
                        else
                            null
                    end
            where
                user_id = p_user_id;

        end if;

        pc_log.log_error('update_otp_phone', 'Exit# ' || p_phone_number);

    -- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
        if
            l_flg_no_update = 'N'
            and nvl(p_phone_number, '0') <> '0'
        then
            if
                nvl(l_verified_phone_number, '0') <> nvl(p_phone_number, '0')
                and nvl(l_user_type, '0') = 'S'
            then
                pc_notification2.insert_events(
                    p_acc_id      => l_acc_id,
                    p_pers_id     => l_pers_id,
                    p_event_name  => 'PHONE',
                    p_entity_type => 'USER_SECURITY_INFO',
                    p_entity_id   => l_pers_id,  -- Replaced l_Acc_id with l_pers_id by Swamy for Ticket#8609
                    p_ssn         => l_ssn
                );      -- Replaced Null with l_ssn by Swamy for Ticket#8609

    -- Added below by Swamy for Ticket#9048 on 06-May-2020
                pc_notification2.insert_audit_security_info(
                    p_pers_id            => l_pers_id,
                    p_email              => null,
                    p_phone_no           => l_verified_phone_number,
                    p_user_id            => p_user_id,
                    p_new_email_phone_no => p_phone_number  -- Added by Swamy for Ticket#9774
                );

            end if;
        end if;

    end update_otp_phone;

end pc_user_security_pkg;
/

