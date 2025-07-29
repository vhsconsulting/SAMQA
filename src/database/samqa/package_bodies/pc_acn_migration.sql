create or replace package body samqa.pc_acn_migration as

    procedure insert_acn_employer_migration (
        p_acc_id      in number,
        p_entrp_id    in number,
        p_action_type in varchar2
    ) is

        v_flg_mig          varchar2(1) := 'N';
        v_first_name       varchar2(255);
        v_last_name        varchar2(255);
        v_gender           varchar2(1);
        v_process_status   varchar2(1);
        v_error_message    varchar2(255);
        v_account_type     varchar2(255);
        v_plan_code        number;
        v_tax_id           varchar2(30);
        v_er_name          enterprise.name%type;
        v_entrp_contact    enterprise.entrp_contact%type;
        v_acc_num          account.acc_num%type;
        v_subscribe_to_acn account_preference.subscribe_to_acn%type;
    begin
   --Check to see if the Employer is already Migrated to ACN
   -- Do not Migrate if the account is already Migrated
   -- V_Flg_Mig :=  Pc_Account.Is_Migrated(P_Acc_Id);

     -- Get Account_Type
        v_account_type := null;
        v_plan_code := null;
        v_acc_num := null;
        v_subscribe_to_acn := null;
        v_er_name := null;
        v_account_type := pc_account.get_account_type(p_acc_id);
        v_plan_code := pc_account.get_plan_code(p_acc_id);
        v_acc_num := pc_account.get_acc_num_from_acc_id(p_acc_id);

      -- Insert the record into the staging table only if the employer is already migrated to ACN and demographic information is changed/updated.
        if
            nvl(v_plan_code, 0) = 1
            and v_account_type = 'HSA'
        then
            v_first_name := null;
            v_last_name := null;
            v_gender := null;
            for i in (
                select
                    entrp_code,
                    entrp_contact,
                    name er_name
                from
                    enterprise
                where
                    entrp_id = p_entrp_id
            ) loop
                v_tax_id := to_char(i.entrp_code);
                v_entrp_contact := i.entrp_contact;
                v_er_name := substr(i.er_name, 1, 29);
            end loop;
     -- Get The Contact Details
            pc_contact.get_names(
                p_entrp_code     => v_tax_id,
                p_entrp_contact  => v_entrp_contact,
                p_first_name     => v_first_name,
                p_last_name      => v_last_name,
                p_gender         => v_gender,
                x_process_status => v_process_status,
                x_error_message  => v_error_message
            );

            if
                nvl(v_first_name, '*') = '*'
                and nvl(v_last_name, '*') = '*'
            then
                v_first_name := nvl(v_first_name, v_er_name);
            end if;

            insert into acn_employer_migration (
                acc_id,
                acc_num,
                entrp_id,
                account_type,
                company_name,
                address,
                city,
                state,
                zip,
                first_name,
                last_name,
                gender,
                entrp_phones,
                entrp_email,
                entrp_fax,
                entrp_code,
                action_type,
                process_status,
                creation_date,
                created_by
            )
                select
                    p_acc_id,
                    v_acc_num,
                    p_entrp_id,
                    v_account_type,
                    name,
                    address,
                    city,
                    state,
                    zip,
                    v_first_name,
                    v_last_name,
                    v_gender,
                    entrp_phones,
                    entrp_email,
                    entrp_fax,
                    v_tax_id,
                    p_action_type,           -- 'I' = Insert,'U'= Update , 'C' = Change(When The Plan Is Changed From Hsa To Any Other Plan
                    'N',
                    sysdate,
                    0
                from
                    enterprise
                where
                    entrp_id = p_entrp_id;

        end if;

    end insert_acn_employer_migration;
-- End of Additon by Swamy for Ticket#6794

    procedure update_migrated_employer (
        p_batch_number        in number,
        p_ref_employer_acc_id in varchar2_tbl,
        p_enrollment_status   in varchar2_tbl,
        p_error_message       in varchar2_tbl
    ) is
        v_entrp_id account.entrp_id%type;
    begin
        for i in 1..p_ref_employer_acc_id.count loop
            update acn_employer_migration
            set
                process_status = p_enrollment_status(i),
                error_message = p_error_message(i),
                batch_number = p_batch_number,
                last_update_date = sysdate,
                last_updated_by = 0
            where
                nvl(process_status, 'N') in ( 'N', 'E', 'C' )
                and acc_id = p_ref_employer_acc_id(i);

        end loop;

        update account
        set
            migrated_flag = 'Y'
        where
            acc_id in (
                select
                    acc_id
                from
                    acn_employer_migration
                where
                        batch_number = p_batch_number
                    and process_status = 'S'
                    and action_type = 'I'
            );

        pc_log.log_error('Pc_Acn_Migration.UPDATE_MIGRATED_EMPLOYER calling email_Migration_status', null);
        pc_acn_migration.email_migration_status(
            p_batch_number => p_batch_number,
            p_flg_employer => 'Y'
        );
        pc_log.log_error('Pc_Acn_Migration.UPDATE_MIGRATED_EMPLOYER END ', null);
    end update_migrated_employer;

    procedure email_migration_status (
        p_batch_number in number,
        p_flg_employer in varchar2
    ) as

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        v_attachment   varchar2(100);
        v_subject      varchar2(100);
    begin
        if p_flg_employer = 'Y' then
            l_html_message := '<html>
      <head>
          <title> Employer Migration Status for Account Type(HSA) to ACN   </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Employer Migration Status for Account Type(HSA) to ACN </p>
       </table>
        </body>
        </html>';
            l_sql := 'select acc_num "Account Number",account_type "Account Type",decode(error_message,null,''Null'',error_message) "Error Message",Process_status "Process Status"
              from Acn_Employer_Migration where batch_number = ' || p_batch_number;
            v_subject := 'Employer Migration Status for Account Type(HSA) to ACN Dated := ' || to_char(sysdate, 'MM/DD/YYYY');
            v_attachment := 'Employer_hsa_Migration_status'
                            || to_char(sysdate, 'MMDDYYYY')
                            || '.xls';
        elsif p_flg_employer = 'N' then
            l_html_message := '<html>
      <head>
          <title> Employee Migration Status for Account Type(HSA) to ACN   </title>
      </head>
      <body bgcolor="#FFFFFF" link="#000080">
       <table cellspacing="0" cellpadding="0" width="100%">
       <p> Employee Migration Status for Account Type(HSA) to ACN </p>
       </table>
        </body>
        </html>';
            l_sql := 'select acc_ID "Account Number",account_type "Account Type",error_message "Error Message",Enrollment_status "Process Status",Action_Type "Action"
              from Acn_Employee_Migration where batch_number = ' || p_batch_number;
            v_subject := 'Employee Migration Status for Account Type(HSA) to ACN, Dated := ' || to_char(sysdate, 'MM/DD/YYYY');
            v_attachment := 'Employee_hsa_Migration_status'
                            || to_char(sysdate, 'MMDDYYYY')
                            || '.xls';
        end if;

        mail_utility.report_emails('oracle@sterlinghsa.com', g_hsa_email
                                                             || ','
                                                             || g_cc_email, v_attachment, l_sql, l_html_message,
                                   v_subject);

    exception
        when others then
    -- Close the file if something goes wrong.
            dbms_output.put_line('error message ' || sqlerrm);
    end email_migration_status;

    function is_enable_sso (
        p_acc_id in number
    ) return varchar2 is
        v_flg_sso  varchar2(1) := 'N';
        l_entrp_id number;
    begin
        for x in (
            select
                *
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            if x.entrp_id is not null then
                v_flg_sso := is_employer_migrated(x.entrp_id);
            elsif x.pers_id is not null then
                l_entrp_id := pc_person.get_entrp_from_pers_id(x.pers_id);
        -- individual
                if l_entrp_id is null then
                    if
                        nvl(x.migrated_flag, 'N') = 'Y'
                        and x.plan_code = 1
                        and x.account_status in ( 1, 3 )
                    then
                        v_flg_sso := 'Y';
                    else
                        v_flg_sso := 'N';
                    end if;

                else
            -- employee.
                    if
                        is_employer_migrated(l_entrp_id) = 'Y'
                        and nvl(x.migrated_flag, 'N') = 'Y'
                        and x.plan_code = 1
                    then
                        v_flg_sso := 'Y';
                    else
                        v_flg_sso := 'N';
                    end if;
                end if;

            end if;
        end loop;

        return v_flg_sso;
    end is_enable_sso;

    function is_employer_migrated (
        p_entrp_id in number
    ) return varchar2 is
        v_flg_sso varchar2(1) := 'N';
    begin
        for i in (
            select
                ap.subscribe_to_acn
            from
                account            a,
                account_preference ap
            where
                    a.entrp_id = p_entrp_id
                and a.acc_id = ap.acc_id
                and a.account_type = 'HSA'
                --AND AP.subscribe_to_acn = 'Y'
                and a.plan_code = 1
                and a.account_status in ( 1, 3 )
        ) loop
            v_flg_sso := nvl(i.subscribe_to_acn, 'N');
        end loop;

        return v_flg_sso;
    end is_employer_migrated;

    procedure populate_acn_migrate_data is

        cursor c1 is
        select
            a.acc_id,
            p.first_name,
            p.middle_name,
            p.last_name,
            p.gender,
            replace(p.ssn, '-') ssn,
            to_char(p.birth_date, 'mm/dd/yyyy'),
            p.address,
            p.city,
            p.state,
            p.zip,
            p.phone_day,
            p.phone_even,
            p.email,
            u.user_name,
            u.pw_question,
            u.pw_answer
        from
            account                a,
            person                 p,
            acn_employee_migration acn,
            online_users           u
        where
                a.acc_id = acn.acc_id
            and a.pers_id = p.pers_id
            and a.acc_num = u.find_key (+)
--AND u.user_type= 'S'
            and action_type = 'I'
            and process_status is null;

        type l_record_tbl is
            table of employee_record index by pls_integer;
        l_record l_record_tbl;
    begin
    -- handle change of plans accounts.
    -- get employer acc_id.
        update acn_employee_migration
        set
            emp_acc_id = pc_account.get_emp_accid_from_pers_id(pers_id)
        where
                action_type = 'I'
            and subscriber_type is null;

    -- delete the employees whose employer is not migrated.
        delete from acn_employee_migration
        where
                action_type = 'I'
            and subscriber_type is null
            and emp_acc_id is not null
            and pc_account.is_migrated(emp_acc_id) = 'N';

        update acn_employee_migration
        set
            subscriber_type =
                case
                    when emp_acc_id is null then
                        'I'
                    else
                        'E'
                end
        where
                action_type = 'I'
            and subscriber_type is null;

    -- update the exception records to process again.
        update acn_employee_migration
        set
            process_status = null,
            action_type = 'I'
        where
                action_type = 'N'
            and process_status = 'E';

        open c1;
        loop
            fetch c1
            bulk collect into l_record limit 1000;
            exit when l_record.count() = 0;

        --dbms_output.put_line( 'Entering into loop');
            forall i in l_record.first..l_record.last

      --  dbms_output.put_line( 'l_record(i).first_name: ' ||l_record(i).first_name);
       -- dbms_output.put_line( 'l_record(i).acc_id: ' ||l_record(i).acc_id);

                update acn_employee_migration
                set
                    first_name = l_record(i).first_name,
                    middle_name = l_record(i).middle_name,
                    last_name = l_record(i).last_name,
                    gender = l_record(i).gender,
                    ssn = l_record(i).ssn,
                    birth_date = l_record(i).birth_date,
                    address1 = l_record(i).address1,
                    city = l_record(i).city,
                    state = l_record(i).state,
                    zip = l_record(i).zip,
                    phone_day = l_record(i).phone_day,
                    phone_even = l_record(i).phone_even,
                    email_address = l_record(i).email_address,
                    user_name = l_record(i).user_name,
                    pw_question = l_record(i).pw_question,
                    pw_answer = l_record(i).pw_answer
                where
                        acc_id = l_record(i).acc_id
                    and action_type = 'I'
                    and process_status is null;

        end loop;

        close c1;

    -- update the action type if first name and user_name is updated
        update acn_employee_migration
        set
            action_type = 'N'
        where
                action_type = 'I'
            and first_name is not null
            and process_status is null;

    -- update action type for UPDATE Record.
        update acn_employee_migration
        set
            action_type = 'M'
        where
                action_type = 'U'
            and process_status is null;

    end populate_acn_migrate_data;

    procedure updt_acn_employee_migrate_sts (
        p_mig_seq        in varchar2_tbl,
        p_acc_id         varchar2_tbl,
        p_process_status varchar2_tbl,
        p_error_message  varchar2_tbl
    ) is
    begin
        pc_log.log_error('Pc_Acn_Migration.UPDT_ACN_EMPLOYEE_MIGRATE_STS calling email_Migration_status count :', p_acc_id.count);

   -- bulk update. update migration status for each account.
        forall i in 1..p_acc_id.count save exceptions
            update acn_employee_migration
            set
                process_status = p_process_status(i),
                error_message = p_error_message(i)
            where
                    mig_seq_no = p_mig_seq(i)
                and acc_id = p_acc_id(i);

    -- update migrated_flag in account for each successful migration.
        forall i in 1..p_acc_id.count save exceptions
            update account
            set
                migrated_flag = 'Y'
            where
                    acc_id = p_acc_id(i)
                and p_process_status(i) = 'S';

    end updt_acn_employee_migrate_sts;

end pc_acn_migration;
/


-- sqlcl_snapshot {"hash":"3a47b3e392d61ed3868ec4800f35e2c5a5ec4eb7","type":"PACKAGE_BODY","name":"PC_ACN_MIGRATION","schemaName":"SAMQA","sxml":""}