create or replace package body samqa.process_upload is

    function get_lookup_code (
        p_lookup_name in varchar2,
        p_description in varchar2
    ) return varchar2 is
        l_lookup_code varchar2(30);
    begin
        select
            lookup_code
        into l_lookup_code
        from
            lookups
        where
                lookup_name = p_lookup_name
            and upper(description) like upper(p_description)
                                        || '%';

        return l_lookup_code;
    end get_lookup_code;

    function get_carrier_id (
        p_carrier in varchar2
    ) return number is
        l_entrp_id number;
    begin
        if p_carrier is null then
            l_entrp_id := 1452;
        else
            select
                entrp_id
            into l_entrp_id
            from
                enterprise
            where
                    en_code = 3
                and upper(trim(name)) = upper(trim(p_carrier))
                and rownum = 1;

            if l_entrp_id is null then
                select
                    entrp_id
                into l_entrp_id
                from
                    enterprise
                where
                        en_code = 3
                    and regexp_like ( upper(name),
                                      '\'
                                      || upper(p_carrier)
                                      || '\' )
                    and rownum = 1;

            end if;

        end if;

        return l_entrp_id;
    exception
        when others then
            return 1452;
    end get_carrier_id;

    function get_entrp_id (
        p_acc_id in number
    ) return number is
        l_entrp_id number;
    begin
        select
            entrp_id
        into l_entrp_id
        from
            account
        where
            acc_id = p_acc_id;

        return l_entrp_id;
    end get_entrp_id;

    procedure export_enrollment_file (
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
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
    begin
        pc_log.log_error('Test', 'Div Code');
        pc_log.log_error('process_mass_enrollments', 'In export_enrollment_file');
        l_create_ddl := 'ALTER TABLE MASS_ENROLLMENTS_EXTERNAL ACCESS PARAMETERS ('
                        || '  records delimited by newline skip 1'
                        || '  badfile '''
                        || pv_file_name
                        || '.bad'
                        || ''' '
                        || '  logfile '''
                        || pv_file_name
                        || '.log'
                        || ''' '
                        || '  fields terminated by '','' '
                        || '  optionally enclosed by ''"'' '
                        || '  LRTRIM '
                        || '  MISSING FIELD VALUES ARE NULL)  '
                        || '  LOCATION (ENROLL_DIR:'''
                        || pv_file_name
                        || ''')';

    /*** -1 means it is benetrac user ****/

        if p_user_id = 441 then
            null;
        else
           /* Get the contents of BLOB from wwv_flow_files */
            begin
                select
                    blob_content
                into l_blob
                from
                    wwv_flow_files
                where
                    name = pv_file_name;

                l_file := utl_file.fopen('ENROLL_DIR', pv_file_name, 'w', 32767);
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
                    name = pv_file_name;

            exception
                when others then
                    null;
            end;
        end if;
  /*    BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE MASS_ENROLLMENTS_EXTERNAL ';
      EXCEPTION
         WHEN OTHERS THEN
	    null ;
      END;*/
        execute immediate l_create_ddl;
        x_batch_number := batch_num_seq.nextval;
        pc_log.log_error('Test', 'Div Code2');
        insert into mass_enrollments (
            mass_enrollment_id,
            title,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            driver_license,
            passport,
            carrier,
            plan_type,
            deductible,
            effective_date,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            check_number,
            check_amount,
            employer_amount,
            employee_amount,
            entrp_acc_id,
            employer_name,
            broker_id,
            error_message,
            sign_on_file,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            batch_number,
            division_code
        )
            select
                mass_enrollments_seq.nextval,
                title,
                first_name,
                substr(middle_name, 1, 1),
                last_name,
                initcap(gender),
                initcap(address),
                initcap(city),
                state,
                zip,
                null,
                day_phone,
                null,
                email_address,
                format_date(birth_date)     birth_date,
                case
                    when length(ssn) < 9 then
                        lpad(ssn, 9, '0')
                    else
                        ssn
                end                         ssn,
                driver_license,
                passport
	  -- , REPLACE(REPLACE(CARRIER,';','&'),'/',' ')
                ,
                replace(carrier, ';', '&'),
                initcap(plan_type),
                case
                    when p_user_id = 441
                         and nvl(deductible, 0) = 0
                         and initcap(plan_type) = 'Single' then
                        '1200'
                    when p_user_id = 441
                         and nvl(deductible, 0) = 0
                         and initcap(plan_type) = 'Family' then
                        '2400'
                    else
                        nvl(deductible, '1200')
                end                         deductible,
                format_date(effective_date) effective_date,
                debit_card
	   --, NVL(INITCAP(PLAN_CODE),'Standard')
                ,
                initcap(decode(
                    upper(nvl(plan_code, 'Premium')),
                    'STANDARD',
                    'Premium',
                    'SIMPLE HSA',
                    'Sterling HSA',
                    plan_code
                )) --commented by Joshi for 6794. plan name changed to Premium
                ,
                format_date(start_date)     start_date,
                null,
                nvl(account_status, 'Active'),
                nvl(setup_status, 'Yes'),
                check_number,
                check_amount,
                employer_amount,
                employee_amount,
                0,
                employer_name,
                broker_number,
                null,
                nvl2(sign_on_file, 'Y', 'N'),
                note,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                null,
                case
                    when a.group_number is not null then
                        pc_entrp.get_entrp_id(a.group_number)
                    when a.employer_name is not null then
                        get_entrp_id(null, employer_name, 'HSA')
                    else
                        null
                end                         entrp_id,
                a.group_number,
                x_batch_number,
                division_code
            from
                mass_enrollments_external a
            where
                ( first_name is not null
                  or ssn is not null )
    --   AND   NOT EXISTS ( SELECT * FROM MASS_ENROLLMENTS WHERE SSN = A.SSN)
                and pc_account.check_duplicate(
                    replace(ssn, '-'),
                    a.group_number,
                    replace(a.employer_name, ','),
                    'HSA',
                    null
                ) = 'N';

        commit;
        pc_log.log_error('Test', 'Div Code99');
    exception
        when others then
            rollback;
            pc_log.log_error('export_enrollment_file', 'others' || sqlerrm);
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
            pc_file.extract_error_from_log(pv_file_name || '.log', 'ENROLL_DIR', l_log_file_name);
            l_files.delete;
            l_files.extend(3);
            l_files(1) := '/u01/app/oracle/oradata/enroll/' || pv_file_name;
            l_files(2) := '/u01/app/oracle/oradata/enroll/'
                          || pv_file_name
                          || '.bad';
            l_files(3) := '/u01/app/oracle/oradata/enroll/' || l_log_file_name;
            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
                to_names     => 'techsupport@sterlingadministration.com',
                subject      => 'Error in Enrollment file Upload ' || pv_file_name,
                html_message => sqlerrm,
                attach       => l_files
            );
    --mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_enrollment_file;

    procedure export_ftp_enrollment_file (
        pv_file_name   in varchar2,
        x_batch_number out number
    ) as

        l_file          utl_file.file_type;
        l_buffer        raw(32767);
        l_amount        binary_integer := 32767;
        l_pos           integer := 1;
        l_blob          blob;
        l_blob_len      integer;
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        lv_create exception;
        l_row_count     number := -1;
        l_sqlerrm       varchar2(32000);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
        l_group_number  varchar(100);
        l_entrp_id      number;
        l_file_id       number;
        l_batch_number  number;
    begin
        x_batch_number := batch_num_seq.nextval;
        l_batch_number := x_batch_number;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('export_enrollment_file', 'Destination file ' || lv_dest_file);

      /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        pc_log.log_error('export_enrollment_file', 'l_create_ddl  ' || l_create_ddl);
        l_create_ddl := 'ALTER TABLE MASS_FTP_ENROLLMENTS_EXTERNAL ACCESS PARAMETERS ('
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
                        || '  LOCATION (ENROLL_DIR:'''
                        || lv_dest_file
                        || ''')';

        pc_log.log_error('export_enrollment_file', 'l_create_ddl  ' || l_create_ddl);
        begin
            execute immediate l_create_ddl;
        exception
            when others then
                rollback;
                l_sqlerrm := sqlerrm;
                 --   mail_utility.send_email('oracle@sterlingadministration.com','techsupport@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
                 --   mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);

                pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
                l_files.delete;
                l_files.extend(3);
                l_files(1) := '/u01/app/oracle/oradata/12QA/enroll/' || lv_dest_file;
                l_files(2) := '/u01/app/oracle/oradata/12QA/enroll/'
                              || lv_dest_file
                              || '.bad';
                l_files(3) := '/u01/app/oracle/oradata/12QA/enroll/' || l_log_file_name;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
                    to_names     => 'Jagadeesh.Reddy@sterlingadministration.com, piyush.kumar@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,shivani.jaiswal@sterlingadministration.com,srinivasulu.gudur@sterlingadministration.com, vhsqateam@sterlingadministration.com'
                    ,
                    subject      => 'Error in Enrollment file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );
--                                   attach       => samfiles('/u01/app/oracle/oradata/12QA/enroll/'||lv_dest_file));

                raise lv_create;

       /** send email alert as soon as it fails **/

        end;

        pc_log.log_error('In Porc', 'Before Insert');

        -- Insert into File History table ( added by Joshi for 9072).
        -- moved the code from process_ftp_enrollment to here (Joshi : 9670);
        for x in (
            select distinct
                group_number
            from
                mass_ftp_enrollments_external
        ) loop
            l_group_number := x.group_number;
        end loop;

        for y in (
            select
                entrp_id
            from
                account
            where
                acc_num = l_group_number
        ) loop
            l_entrp_id := y.entrp_id;
        end loop;

        pc_file_upload.insert_file_upload_history(
            p_batch_num         => l_batch_number,
            p_user_id           => 427,
            pv_file_name        => pv_file_name,
            p_entrp_id          => l_entrp_id,
            p_action            => 'ENROLLMENT',
            p_account_type      => 'HSA',
            p_enrollment_source => 'EDI',
            p_file_type         => 'employee_eligibility',
            x_file_upload_id    => l_file_id
        );
        -- code ends here 9072.

        insert into mass_enrollments (
            mass_enrollment_id,
            title,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            driver_license,
            passport,
            carrier,
            plan_type,
            deductible,
            effective_date,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            check_number,
            check_amount,
            employer_amount,
            employee_amount,
            entrp_acc_id,
            employer_name,
            broker_name,
            broker_id,
            error_message,
            sign_on_file,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            tpa_id,
            batch_number,
            division_code -- Division Code Change
            ,
            enrollment_source  --Ticket#2488 .Modified on 08/03/2016
            ,
            termination_date -- #8634 Joshi on 04/12/2020
        )
            select
                mass_enrollments_seq.nextval,
                title,
                first_name,
                substr(middle_name, 1, 1),
                last_name,
                decode(
                    upper(gender),
                    'M',
                    'M',
                    'F',
                    'F',
                    'FEMALE',
                    'F',
                    'MALE',
                    'M',
                    null
                )                             gender  -- added by jaggi #10836 Gender should allow only M,F,MALE,FEMALE apart from this shold enter null.
                ,
                initcap(address),
                initcap(city),
                state,
                zip,
                null,
                day_phone,
                null,
                email_address,
                format_date(birth_date)       birth_date,
                case
                    when length(ssn) < 9 then
                        lpad(ssn, 9, '0')
                    else
                        ssn
                end                           ssn,
                driver_license,
                passport
	--   , REPLACE(REPLACE(CARRIER,';','&'),'/',' ')
                ,
                replace(carrier, ';', '&'),
                initcap(plan_type),
                case
                    when nvl(deductible, 0) = 0
                         and initcap(plan_type) = 'Single' then
                        '1200'
                    when nvl(deductible, 0) = 0
                         and initcap(plan_type) = 'Family' then
                        '2400'
                    else
                        nvl(deductible, '1200')
                end                           deductible,
                format_date(effective_date)   effective_date,
                debit_card
           -- , NVL(INITCAP(PLAN_CODE),'Standard')
          -- , NVL(INITCAP(Decode(PLAN_CODE, 'Standard','Premium',PLAN_CODE )),'Premium') -- Added by Joshi for 7542. (Accept standard/premioum both)
		  -- 9506 Accept Simple HSA as Sterling HSA  - joshi
                ,
                initcap(decode(
                    upper(nvl(plan_code, 'Premium')),
                    'STANDARD',
                    'Premium',
                    'SIMPLE HSA',
                    'Sterling HSA',
                    plan_code
                )) -- Added by Joshi for 7542. (Accept standard/premioum both)
                ,
                format_date(start_date)       start_date,
                null,
                nvl(account_status, 'Active'),
                nvl(setup_status, 'Yes'),
                check_number,
                check_amount,
                employer_amount,
                employee_amount,
                pc_account.get_acc_id(a.group_number),
                employer_name,
                decode(
                    is_number(broker_number),
                    'Y',
                    null,
                    broker_number
                ),
                decode(
                    is_number(broker_number),
                    'Y',
                    broker_number,
                    null
                ),
                null,
                sign_on_file,
                note,
                sysdate,
                0,
                sysdate,
                0,
                null,
                pc_entrp.get_entrp_id(a.group_number),
                a.group_number,
                tpa_id,
                x_batch_number,
                division_code --Division Code change
                ,
                'EDI' --Ticket#2488 .Modified on 08/03/2016
                ,
                format_date(termination_date) termination_date  -- #8634 Joshi on 04/12/2020

            from
                mass_ftp_enrollments_external a
            where
                ( first_name is not null
                  or ssn is not null );
       /* commented and added below clause by Joshi for 8634.
          to allow termination record to be enetered to Staging table.
       AND (  PC_ACCOUNT.CHECK_DUPLICATE
            ( REPLACE(SSN,'-')
            ,A.GROUP_NUMBER
            ,REPLACE(A.EMPLOYER_NAME,',')
            ,'HSA'
            ,NULL) = 'N'
        AND (  PC_ACCOUNT.CHECK_DUPLICATE
            ( REPLACE(SSN,'-')
            ,A.GROUP_NUMBER
            ,REPLACE(A.EMPLOYER_NAME,',')
            ,'HSA'
            ,NULL) = 'N'
          OR ( PC_ACCOUNT.CHECK_DUPLICATE
            ( REPLACE(SSN,'-')
            ,A.GROUP_NUMBER
            ,REPLACE(A.EMPLOYER_NAME,',')
            ,'HSA'
            ,NULL) = 'Y' AND TERMINATION_DATE IS NOT NULL))  ;
            */
 -- Added By Jaggi #9781
        for x in (
            select
                count(*) cnt
            from
                mass_enrollments
            where
                batch_number = x_batch_number
        ) loop
            if x.cnt = 0 then
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => 427,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => 'HSA',
                    p_enrollment_source => 'EDI',
                    p_error             => 'Please check the file, template might be incorrect or file must be empty',
                    p_file_type         => 'employee_eligibility',
                    x_file_upload_id    => l_file_id
                );

            end if;
        end loop;
 -- end here --
        update mass_enrollments
        set
            action =
                case
                    when pc_account.check_duplicate(
                        replace(ssn, '-'),
                        group_number,
                        replace(employer_name, ','),
                        'HSA',
                        null
                    ) = 'N' then
                        'N'
                    else
                        'C'
                end
        where
            batch_number = x_batch_number;

        commit;
        pc_log.log_error('In Proc after insert', sql%rowcount);
    exception
        when lv_create then
         -- Added by Joshi for 9670. capture the error
            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => 427,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => 'HSA',
                p_enrollment_source => 'EDI',
                p_file_type         => 'employee_eligibility',
                p_error             => sqlerrm,
                x_file_upload_id    => l_file_id
            );
          -- code ends here Joshi: 9670
            rollback;
            raise_application_error('-20001', 'Enrollment file seems to be corrupted, Use correct template' || l_sqlerrm);
        when others then
      -- Added by Joshi for 9670. capture the error
            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => 427,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => 'HSA',
                p_enrollment_source => 'EDI',
                p_file_type         => 'employee_eligibility',
                p_error             => sqlerrm,
                x_file_upload_id    => l_file_id
            );
      -- code ends here Joshi: 9670
            rollback;

    -- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

    -- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;
    --    mail_utility.send_email('oracle@sterlingadministration.com','techsupport@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
    --    mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
            pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
            l_files.delete;
            l_files.extend(3);
            l_files(1) := '/u01/app/oracle/oradata/enroll/' || lv_dest_file;
            l_files(2) := '/u01/app/oracle/oradata/enroll/'
                          || lv_dest_file
                          || '.bad';
            l_files(3) := '/u01/app/oracle/oradata/enroll/' || l_log_file_name;
            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
                to_names     => 'Jagadeesh.Reddy@sterlingadministration.com,piyush.kumar@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,shivani.jaiswal@sterlingadministration.com,srinivasulu.gudur@sterlingadministration.com, vhsqateam@sterlingadministration.com'
                , --'techsupport@sterlingadministration.com',
                subject      => 'Error in Enrollment file Upload ' || lv_dest_file,
                html_message => sqlerrm,
                attach       => l_files
            );
--                         attach       => samfiles('/u01/app/oracle/oradata/12QA/enroll/'||lv_dest_file));

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_ftp_enrollment_file;

    procedure export_enrollment_file (
        pv_file_name   in varchar2,
        pv_entrp_id    in number,
        p_user_id      in number,
        p_group_number in varchar2 default null,
        x_batch_number out number
    ) as

        l_file          utl_file.file_type;
        l_buffer        raw(32767);
        l_amount        binary_integer := 32767;
        l_pos           integer := 1;
        l_blob          blob;
        l_blob_len      integer;
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        lv_create exception;
        l_row_count     number := -1;
        l_sqlerrm       varchar2(32000);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
    begin
        x_batch_number := batch_num_seq.nextval;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('export_enrollment_file', 'Destination file ' || lv_dest_file);



      /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
          -- Open / Creates the destination file.
            pc_log.log_error('export_enrollment_file', 'lv_dest_file  ' || lv_dest_file);

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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        pc_log.log_error('export_enrollment_file', 'l_create_ddl  ' || l_create_ddl);
        pc_log.log_error('export_enrollment_file', 'l_create_ddl  ' || l_create_ddl);
        l_create_ddl := 'ALTER TABLE MASS_ENROLLMENTS_EXTERNAL ACCESS PARAMETERS ('
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
                        || '  LOCATION (ENROLL_DIR:'''
                        || lv_dest_file
                        || ''')';

        begin
            pc_log.log_error('export_enrollment_file', 'l_create_ddl **1 ' || l_create_ddl);
            execute immediate l_create_ddl;
            pc_log.log_error('export_enrollment_file', 'after execute l_create_ddl  ' || l_create_ddl);
        exception
            when others then
                rollback;
                l_sqlerrm := sqlerrm;
                pc_log.log_error('export_enrollment_file', 'after execute SQLERRM  ' || sqlerrm);
                 --   mail_utility.send_email('oracle@sterlingadministration.com','techsupport@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
                 --   mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
                pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
                l_files.delete;
                l_files.extend(3);
                l_files(1) := '/u01/app/oracle/oradata/enroll/' || lv_dest_file;
                l_files(2) := '/u01/app/oracle/oradata/enroll/'
                              || lv_dest_file
                              || '.bad';
                l_files(3) := '/u01/app/oracle/oradata/enroll/' || l_log_file_name;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
                    to_names     => 'techsupport@sterlingadministration.com',
                    subject      => 'Error in Enrollment file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );

                raise lv_create;

       /** send email alert as soon as it fails **/

        end;

        insert into mass_enrollments (
            mass_enrollment_id,
            title,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            driver_license,
            passport,
            carrier,
            plan_type,
            deductible,
            effective_date,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            check_number,
            check_amount,
            employer_amount,
            employee_amount,
            entrp_acc_id,
            employer_name,
            broker_name,
            broker_id,
            error_message,
            sign_on_file,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            batch_number,
            division_code   -- Division_code change
            ,
            enrollment_source
        ) -- Ticket#2488 .Modified on 08/03/2016
            select
                mass_enrollments_seq.nextval,
                title,
                first_name,
                substr(middle_name, 1, 1),
                last_name,
                initcap(gender),
                initcap(address),
                initcap(city),
                state,
                zip,
                null,
                day_phone,
                null,
                email_address,
                format_date(birth_date)     birth_date,
                case
                    when length(ssn) < 9 then
                        lpad(ssn, 9, '0')
                    else
                        ssn
                end                         ssn,
                driver_license,
                passport
	--   , REPLACE(REPLACE(CARRIER,';','&'),'/',' ')
                ,
                replace(carrier, ';', '&'),
                initcap(plan_type),
                case
                    when nvl(deductible, 0) = 0
                         and initcap(plan_type) = 'Single' then
                        '1200'
                    when nvl(deductible, 0) = 0
                         and initcap(plan_type) = 'Family' then
                        '2400'
                    else
                        nvl(deductible, '1200')
                end                         deductible,
                format_date(effective_date) effective_date,
                debit_card
	   --, NVL(INITCAP(PLAN_CODE),'Standard')
                ,
                nvl(
                    initcap(decode(plan_code, 'Standard', 'Premium', plan_code)),
                    'Premium'
                ) -- Added by Joshi for 7542. (Accept standard/premioum both)
                ,
                format_date(start_date)     start_date,
                null,
                nvl(account_status, 'Active'),
                nvl(setup_status, 'Yes'),
                check_number,
                check_amount,
                employer_amount,
                employee_amount,
                pc_entrp.get_acc_id(pc_entrp.get_entrp_id(nvl(a.group_number, p_group_number)))   -- Replaced pv_entrp_id with get_acc_id by Swamy for Ticket#9912
                ,
                employer_name,
                decode(
                    is_number(broker_number),
                    'Y',
                    null,
                    broker_number
                ),
                decode(
                    is_number(broker_number),
                    'Y',
                    broker_number,
                    null
                ),
                null,
                sign_on_file,
                note,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                null,
                pc_entrp.get_entrp_id(nvl(a.group_number, p_group_number)),
                nvl(a.group_number, p_group_number),
                x_batch_number,
                division_code  -- Division_code change
                ,
                'PAPER' --Ticket#2488.Modified on 08/03/2016
            from
                mass_enrollments_external a
            where
                ( first_name is not null
                  or ssn is not null );
  --     AND   NOT EXISTS ( SELECT * FROM MASS_ENROLLMENTS WHERE SSN = A.SSN)
       /* commented by Joshi for 8634. allow update to existing accounts
       AND   PC_ACCOUNT.CHECK_DUPLICATE
            ( REPLACE(SSN,'-')
            ,NVL(A.GROUP_NUMBER,P_GROUP_NUMBER)
            ,REPLACE(A.EMPLOYER_NAME,',')
            ,'HSA'
            ,NULL) = 'N';
        */

        update mass_enrollments
        set
            action =
                case
                    when pc_account.check_duplicate(
                        replace(ssn, '-'),
                        group_number,
                        replace(employer_name, ','),
                        pc_account.get_account_type(pc_entrp.get_acc_id(entrp_id))  -- Replaced HSA with pc_account by swamy for Ticket#9912 on 10/08/2021
                        ,
                        null
                    ) = 'N' then
                        'N'
                    else
                        'C'
                end,
            account_type = pc_account.get_account_type(pc_entrp.get_acc_id(entrp_id))  -- Added by swamy for Ticket#9912 on 10/08/2021
        where
            batch_number = x_batch_number;

        pc_log.log_error('export_enrollment_file', 'end  x_batch_number ' || x_batch_number);
        commit;
    exception
        when lv_create then
            pc_log.log_error('export_enrollment_file', 'error  lv_create ');
            rollback;
            raise_application_error('-20001', 'Enrollment file seems to be corrupted, Use correct template');
        when others then
            rollback;
            pc_log.log_error('export_enrollment_file', 'others   ' || sqlerrm);
-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

-- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;
--    mail_utility.send_email('oracle@sterlingadministration.com','techsupport@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
--    mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
                to_names     => 'techsupport@sterlingadministration.com',
                subject      => 'Error in Enrollment file Upload ' || lv_dest_file,
                html_message => sqlerrm,
                attach       => samfiles('/u01/app/oracle/oradata/enroll/' || lv_dest_file)
            );

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_enrollment_file;

    procedure export_hra_enrollment (
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
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_sqlerrm       varchar2(32000);
        l_create_error exception;
        l_batch_number  number;
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
    begin
        x_batch_number := batch_num_seq.nextval;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

           /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', pv_file_name, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            l_create_ddl := 'ALTER TABLE HRA_ENROLLMENTS_EXTERNAL ACCESS PARAMETERS ('
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
                            || '  LOCATION (ENROLL_DIR:'''
                            || lv_dest_file
                            || ''')';

            execute immediate l_create_ddl;
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of hra enrollments file' || sqlerrm;
                pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
                l_files.delete;
                l_files.extend(3);
                l_files(1) := '/u01/app/oracle/oradata/enroll/' || lv_dest_file;
                l_files(2) := '/u01/app/oracle/oradata/enroll/'
                              || lv_dest_file
                              || '.bad';
                l_files(3) := '/u01/app/oracle/oradata/enroll/' || l_log_file_name;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
                    to_names     => 'techsupport@sterlingadministration.com',
                    subject      => 'Error in HRA Enrollment file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );

                raise l_create_error;
        end;

        delete from mass_enrollments
        where
            ssn in (
                select
                    case
                        when length(ssn) < 9 then
                            lpad(ssn, 9, '0')
                        else
                            ssn
                    end
                from
                    hra_enrollments_external a
            );

        delete from mass_enrollments
        where
            acc_num in (
                select
                    acc_num
                from
                    hra_enrollments_external a
            );

        insert into mass_enrollments (
            mass_enrollment_id,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            carrier,
            plan_type,
            deductible,
            effective_date,
            bps_hra_plan,
            annual_election,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            issue_conditional,
            broker_id,
            error_message,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            batch_number,
            account_type,
            division_code,
            coverage_tier_name,
            acc_num,
            hra_fsa_flag
        )
            select
                mass_enrollments_seq.nextval,
                first_name,
                substr(middle_name, 1, 1),
                last_name,
                initcap(gender),
                initcap(address),
                initcap(city),
                state,
                case
                    when length(zip) < 5 then
                        lpad(zip, 5, '0')
                    else
                        zip
                end,
                null,
                day_phone,
                null,
                email_address,
                format_date(birth_date)               birth_date,
                case
                    when length(ssn) < 9 then
                        lpad(ssn, 9, '0')
                    else
                        ssn
                end                                   ssn,
                replace(carrier, ';', '&'),
                upper(plan_type),
                nvl(a.deductible, 1200)               deductible,
                format_date(effective_date)           effective_date,
                bps_hra_plan,
                annual_election,
                debit_card,
                nvl(plan_code, 'Value-Basic(HRA)'),
                format_date(start_date)               start_date,
                null,
                initcap(nvl(account_status, 'Active')),
                initcap(nvl(setup_status, 'Yes')),
                'No',
                broker_number,
                null,
                note,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                null,
                pc_entrp.get_entrp_id(a.group_number) entrp_id,
                a.group_number,
                x_batch_number,
                'HRA',
                upper(a.division_code)                division_code,
                coverage_tier_name,
                acc_num,
                'YES'
            from
                hra_enrollments_external a
            where
                ( first_name is not null
                  or ssn is not null
                  or acc_num is not null )
    /*   AND   NOT EXISTS ( SELECT * FROM MASS_ENROLLMENTS WHERE SSN = A.SSN)
       AND   PC_ACCOUNT.CHECK_DUPLICATE
            ( REPLACE(SSN,'-')
            ,A.GROUP_NUMBER
            ,NULL
            ,'HRA'
            ,NULL) = 'N'*/;

        for x in (
            select
                a.mass_enrollment_id,
                c.pers_id,
                d.acc_num,
                d.acc_id
            from
                mass_enrollments a,
                account          b,
                person           c,
                account          d
            where
                    a.batch_number = x_batch_number
                and a.error_message is null
                and rtrim(
                    ltrim(a.group_number, ' '),
                    ' '
                ) = b.acc_num
                and b.account_type in ( 'HRA', 'FSA' )
                and ( a.ssn is not null
                      and replace(c.ssn, '-') = replace(a.ssn, '-')
                      or a.acc_num = d.acc_num )
                and c.pers_id = d.pers_id
                and b.entrp_id = c.entrp_id
                and b.account_type in ( 'HRA', 'FSA' )
        ) loop
            update mass_enrollments
            set
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                mass_enrollment_id = x.mass_enrollment_id;

        end loop;

        commit;
    exception
        when l_create_error then
            raise_application_error('-20001', 'Error in Exporting File ' || l_sqlerrm);
        when others then
            rollback;

-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

-- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_hra_enrollment;

    procedure validate_hra_enrollments (
        p_user_id      in number,
        p_batch_number in number
    ) is
    begin
        update mass_enrollments
        set
            error_message = 'Enter Valid Birth Date',
            error_column = 'BIRTH_DATE'
        where
                trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and format_to_date(birth_date) is null
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Birth Date Required , Enter Birth Date',
            error_column = 'BIRTH_DATE'
        where
                batch_number = p_batch_number
            and birth_date is null
            and account_type = 'HRA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Gender Cannot be Null',
            error_column = 'GENDER'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'HRA'
            and gender is null
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Gender Cannot have more than one character',
            error_column = 'GENDER'
        where
                trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and length(gender) > 1
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Annual Election must be numeric value ',
            error_column = 'ANNUAL_ELECTION'
        where
                is_number(annual_election) = 'N'
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Middle Name Cannot have more than one character',
            error_column = 'MIDDLE_NAME'
        where
                trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and length(middle_name) > 1
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'State Cannot have more than two character',
            error_column = 'STATE'
        where
                trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and length(state) > 2
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Effective Date',
            error_column = 'EFFECTIVE_DATE'
        where
                trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and format_to_date(effective_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Open Date',
            error_column = 'START_DATE'
        where
                trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and format_to_date(start_date) is null
            and error_message is null;

--     Validations
        update mass_enrollments
        set
            error_message = 'Last Name Cannot be Null',
            error_column = 'LAST_NAME'
        where
            last_name is null
            and batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'First Name Cannot be Null',
            error_column = 'FIRST_NAME'
        where
            first_name is null
            and batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and error_message is null
            and pers_id is null;

     /*  UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Similar Subscriber Seems to Exist for this Employer'
       WHERE  EXISTS ( SELECT *
                       FROM    PERSON, ENTERPRISE, ACCOUNT
		       WHERE   PERSON.entrp_id = ENTERPRISE.ENTRP_ID
		       AND     ACCOUNT.ENTRP_ID = ENTERPRISE.ENTRP_ID
		       AND     ACCOUNT.ACC_ID = MASS_ENROLLMENTS.ENTRP_ACC_ID
		       AND     PERSON.FIRST_NAME = MASS_ENROLLMENTS.FIRST_NAME
		       AND     PERSON.LAST_NAME = MASS_ENROLLMENTS.LAST_NAME
		       AND     PERSON_TYPE = 'SUBSCRIBER')
       AND     TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
       AND    BATCH_NUMBER = p_batch_number
       AND   ERROR_MESSAGE IS NULL;*/

        update mass_enrollments
        set
            error_message = 'Address Cannot be Null',
            error_column = 'ADDRESS'
        where
            address is null
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'City Cannot be Null',
            error_column = 'CITY'
        where
            city is null
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Effective Date Cannot be Null',
            error_column = 'EFFECTIVE_DATE'
        where
            effective_date is null
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'State Cannot be Null',
            error_column = 'STATE'
        where
            state is null
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Zip Cannot be Null',
            error_column = 'ZIP'
        where
            zip is null
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Social Security Number Cannot be Null',
            error_column = 'SSN'
        where
            ssn is null
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

   /*    UPDATE MASS_ENROLLMENTS a
       SET    ERROR_MESSAGE = 'Duplicate SSN, Other Subscribers exist with Same SSN, Search on the Subscriber to find the details'
           ,  ERROR_COLUMN  = 'DUPLICATE'
       WHERE      PC_ACCOUNT.CHECK_DUPLICATE
            ( REPLACE(SSN,'-')
            ,A.GROUP_NUMBER
            ,REPLACE(A.EMPLOYER_NAME,',')
            ,'HRA'
            ,NULL) = 'Y'
       AND     TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
       AND    BATCH_NUMBER = p_batch_number
       AND    ERROR_MESSAGE IS NULL;
 */
        update mass_enrollments
        set
            error_message = 'ZIP code must be in the form 99999',
            error_column = 'ZIP'
        where
            ( length(zip) > 5
              or not regexp_like ( zip,
                                   '^[[:digit:]]+$' ) )
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'The Birth Date must be between 01011900 and Current Date',
            error_column = 'BIRTH_DATE'
        where
            format_to_date(birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate
            and trunc(creation_date) = trunc(sysdate)
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Broker Number must be entered',
            error_column = 'BROKER_NUMBER'
        where
                is_number(broker_id) = 'N'
            and batch_number = p_batch_number
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Division code is not setup',
            error_column = 'DIVISION_CODE'
        where
                pc_employer_divisions.get_division_count(entrp_id,
                                                         upper(division_code)) = 0
            and batch_number = p_batch_number
            and error_message is null
            and division_code is not null
            and pers_id is null;

     --  COMMIT;
    exception
        when others then
            raise_application_error('-20002', 'Error in Validation ' || sqlerrm);
    end validate_hra_enrollments;

    procedure process_hra_enrollments (
        pv_user_id     in number,
        p_batch_number in number
    ) is

        l_entrp_id       number;
        l_broker_id      number;
        l_fee_setup      number;
        l_er_ben_plan_id number;
        l_return_status  varchar2(30);
        l_error_message  varchar2(3200);
    begin
        insert into person (
            pers_id,
            first_name,
            middle_name,
            last_name,
            birth_date,
            title,
            gender,
            ssn,
            address,
            city,
            state,
            zip,
            mailmet,
            phone_day,
            phone_even,
            email,
            relat_code,
            note,
            entrp_id,
            person_type,
            mass_enrollment_id,
            creation_date,
            created_by,
            division_code
        )
            select
                pers_seq.nextval,
                ltrim(rtrim(first_name)),
                ltrim(rtrim(middle_name)),
                ltrim(rtrim(last_name)),
                format_to_date(birth_date),
                title,
                decode(
                    initcap(gender),
                    'Male',
                    'M',
                    'Female',
                    'F',
                    upper(gender)
                ),
                decode(
                    instr(ssn, '-', 1),
                    0,
                    substr(ssn, 1, 3)
                    || '-'
                    || substr(ssn, 4, 2)
                    || '-'
                    || substr(ssn, 6, 9),
                    ssn
                ),
                ltrim(rtrim(address)),
                ltrim(rtrim(city)),
                upper(state),
                substr(zip, 1, 5),
                (
                    select
                        lookup_code
                    from
                        lookups
                    where
                            lookup_name = 'MAIL_TYPE'
                        and upper(description) like upper(contact_method)
                                                    || '%'
                        and contact_method is not null
                ),
                decode(
                    instr(day_phone, '-', 1),
                    0,
                    substr(day_phone, 1, 3)
                    || '-'
                    || substr(day_phone, 4, 3)
                    || '-'
                    || substr(day_phone, 7, 10),
                    day_phone
                ) day_phone,
                evening_phone,
                ltrim(rtrim(email_address)),
                1,
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                b.entrp_id,
                'SUBSCRIBER',
                mass_enrollment_id,
                sysdate,
                a.created_by,
                upper(a.division_code)
            from
                mass_enrollments a,
                account          b
            where
                error_message is null
                and a.batch_number = p_batch_number
                and rtrim(
                    ltrim(a.group_number, ' '),
                    ' '
                ) = b.acc_num
                and b.account_type in ( 'FSA', 'HRA' )
                and not exists (
                    select
                        *
                    from
                        person  c,
                        account b
                    where
                            replace(c.ssn, '-') = replace(a.ssn, '-')
                        and c.pers_id = b.pers_id
                        and b.account_type = 'HRA'
                );

        update mass_enrollments a
        set
            error_message = 'Error in Person Setup'
        where
            error_message is null
            and a.batch_number = p_batch_number
            and not exists (
                select
                    null
                from
                    person
                where
                    replace(person.ssn, '-') = replace(a.ssn, '-')
            );

        for x in (
            select
                c.pers_id,
                a.mass_enrollment_id
            from
                hra_enrollments_external hra,
                person                   c,
                mass_enrollments         a
            where
                error_message is null
                and replace(a.ssn, '-') = replace(
                    lpad(hra.ssn, 9, '0'),
                    '-'
                )
                and a.mass_enrollment_id = c.mass_enrollment_id
        ) loop
            update mass_enrollments a
            set
                pers_id = x.pers_id
            where
                    mass_enrollment_id = x.mass_enrollment_id
                and a.batch_number = p_batch_number;

        end loop;

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
            hsa_effective_date,
            account_type,
            annual_election,
            bps_hra_plan,
            salesrep_id
        )
            select
                acc_seq.nextval,
                b.pers_id,
                null,
                'HRA' || online_enroll_seq.nextval,
                d.plan_code,
                nvl(
                    format_to_date(a.start_date),
                    d.start_date
                ),
                0,
                nvl(a.broker_id, 0),
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                0,
                e.fee_amount,
                sysdate,
                1,
                1,
                'Y',
                null,
                a.account_type,
                a.annual_election,
                a.bps_hra_plan,
                nvl((
                    select
                        salesrep_id
                    from
                        account
                    where
                        entrp_id = a.entrp_id
                ),
                    pc_broker.get_salesrep_id(a.broker_id))
            from
                mass_enrollments a,
                person           b,
                account          d,
                plan_fee         e
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and error_message is null
                and a.batch_number = p_batch_number
                and b.entrp_id = d.entrp_id
                and d.account_type in ( 'HRA', 'FSA' )
                and d.plan_code = e.plan_code
                and e.fee_code = 2
                and not exists (
                    select
                        *
                    from
                        account
                    where
                        pers_id = b.pers_id
                );

        update person a
        set
            acc_numc = (
                select
                    reverse(acc_num)
                from
                    account
                where
                    a.pers_id = account.pers_id
            )
        where
            acc_numc is null;

        update mass_enrollments a
        set
            error_message = 'Error in Account Setup'
        where
            error_message is null
            and a.batch_number = p_batch_number
            and not exists (
                select
                    null
                from
                    person  b,
                    account c
                where
                        replace(b.ssn, '-') = replace(a.ssn, '-')
                    and c.pers_id = b.pers_id
                    and person_type = 'SUBSCRIBER'
                    and c.account_type = 'HRA'
            );

        -- Inserting into Insure

        insert into insure (
            pers_id,
            insur_id,
            plan_type,
            start_date,
            deductible,
            note
        )
            select
                b.pers_id,
                1452,
                nvl(
                    pc_lookups.get_plan_type_code(a.plan_type),
                    0
                )                                       plan_type,
                case
                    when format_to_date(a.effective_date) >= sysdate then
                        format_to_date(a.effective_date)
                    when format_to_date(a.effective_date) <= sysdate then
                        format_to_date(a.effective_date)
                end                                     effective_date,
                nvl(c.deductible, 1200),
                decode(a.setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')) note
            from
                mass_enrollments         a,
                person                   b,
                hra_enrollments_external c
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and a.batch_number = p_batch_number
                and a.error_message like 'Successfully%'
                and a.ssn = case
                                when length(c.ssn) < 9 then
                                    lpad(c.ssn, 9, '0')
                                else
                                    c.ssn
                            end
 --- AND   A.CARRIER IS NOT NULL
                and a.account_type = 'HRA'
                and not exists (
                    select
                        *
                    from
                        insure
                    where
                        insure.pers_id = b.pers_id
                );

        insert into card_debit (
            card_id,
            start_date,
            emitent,
            note,
            status,
            card_number,
            created_by,
            last_updated_by,
            last_update_date,
            issue_conditional
        )
            select
                b.pers_id,
                nvl(
                    greatest(
                        format_to_date(a.start_date),
                        format_to_date(a.effective_date)
                    ),
                    sysdate
                ),
                6763 -- Metavante
                ,
                'Mass Enrollment',
                1,
                null,
                a.created_by,
                a.created_by,
                sysdate,
                'No'
            from
                mass_enrollments a,
                person           b
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and error_message is null
                and a.batch_number = p_batch_number
                and upper(a.debit_card) = 'YES'
                and a.account_type = 'HRA'
                and exists (
                    select
                        *
                    from
                        enterprise
                    where
                            entrp_id = b.entrp_id
                        and nvl(card_allowed, 1) = 0
                )
                and not exists (
                    select
                        *
                    from
                        card_debit
                    where
                        card_id = b.pers_id
                );

        pc_log.log_error('process_hra_enrollments', 'insert BEN_PLAN_ENROLLMENT_SETUP');
        l_er_ben_plan_id := null;
        for x in (
            select
                b.entrp_id,
                b.acc_id,
                d.acc_id                     ee_acc_id,
                nvl(
                    decode(
                        upper(replace(a.plan_type, ' ', '')),
                        'EEANDCHILDREN',
                        'EE_CHILD',
                        'SINGLE',
                        'SINGLE',
                        'EEANDSPOUSE',
                        'EE_SPOUSE',
                        'EEANDFAMILY',
                        'EE_FAMILY'
                    ),
                    'SINGLE'
                )                            plan_type,
                to_char(
                    format_to_date(a.start_date),
                    'RRRRMMDD'
                )                            start_date,
                format_to_date(a.start_date) effective_date,
                a.annual_election,
                a.coverage_tier_name
            from
                hra_enrollments_external a,
                account                  b,
                person                   c,
                account                  d
            where
                    b.acc_num = a.group_number
                and b.entrp_id = c.entrp_id
                and c.ssn = format_ssn(a.ssn)
                and c.pers_id = d.pers_id
        ) loop
            l_er_ben_plan_id := pc_benefit_plans.get_er_ben_plan(x.entrp_id, 'HRA', x.effective_date);
            if l_er_ben_plan_id is not null then
                pc_benefit_plans.insert_benefit_plan(  /*p_er_ben_plan_id  =>*/l_er_ben_plan_id, /*p_acc_id          =>*/ x.ee_acc_id
                , /*p_effective_date  =>*/ x.start_date, /*p_annual_election =>*/ x.annual_election, /*p_coverage_level  =>*/ x.plan_type
                , /*p_batch_number    =>*/
                                                     p_batch_number, /*p_cov_tier_name   =>*/ x.coverage_tier_name, /*x_return_status   =>*/
                                                     l_return_status, /*x_error_message   =>*/ l_error_message);

                if l_return_status <> 'S' then
                    pc_log.log_error('PC_HRA_ENROLLMENT', 'Error in creating benefit plan , acc_id '
                                                          || x.acc_id
                                                          || ' for plan type '
                                                          || x.plan_type);

                end if;

            else
                pc_log.log_error('PC_HRA_ENROLLMENT', 'Plan is not defined for , acc_id '
                                                      || x.acc_id
                                                      || ' for plan type '
                                                      || x.plan_type);
            end if;

        end loop;

        for x in (
            select
                c.mass_enrollment_id,
                a.acc_id,
                a.acc_num
            from
                hra_enrollments_external hra,
                person                   c,
                account                  a
            where
                    c.ssn = format_ssn(hra.ssn)
                and a.pers_id = c.pers_id
        ) loop
            update mass_enrollments a
            set
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                    mass_enrollment_id = x.mass_enrollment_id
                and a.batch_number = p_batch_number;

        end loop;

        pc_benefit_plans.create_annual_election(
            p_batch_number  => p_batch_number,
            p_user_id       => pv_user_id,
            x_return_status => l_return_status,
            x_error_message => l_error_message
        );

        pc_fin.create_prefunded_receipt(
            p_batch_number => p_batch_number,
            p_user_id      => pv_user_id,
            p_acc_num      => null
        );

        update mass_enrollments a
        set
            error_message = 'Successfully Loaded',
            setup_status = 'Yes'
        where
            error_message is null
            and a.batch_number = p_batch_number
            and exists (
                select
                    *
                from
                    person
                where
                    mass_enrollment_id = a.mass_enrollment_id
            );

        commit;
    exception
        when others then
            raise_application_error('-20001', 'Error in Processing Enrollments' || sqlerrm);
    end process_hra_enrollments;

    procedure validate_enrollments (
        pv_entrp_id    in number,
        p_user_id      in number,
        p_batch_number in number
    ) is
    begin
      -- Below update added by Swamy for Ticket#9840 on 18/05/2021.
      -- In EASE file client_id is manditory, based on client ID we fetch entrp_id and other enterprise details, if client id is null or if wrong client id is uploaded below error message is thrown.
        update mass_enrollments
        set
            error_message = 'Client ID OR Entrp_ID cannot be Null',
            error_column = 'CLIENT_ID',
            error_value = 'CLIENT_ID:' || entrp_id
        where
                batch_number = p_batch_number
            and nvl(entrp_id, -1) = - 1
            and nvl(tpa_id, '*') = 'EASE'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Birth Date cannot be blank for plan type',
            error_column = 'BIRTH_DATE',
            error_value = 'BIRTH_DATE:' || nvl(birth_date, 'NULL')
        where
                batch_number = p_batch_number
            and format_to_date(birth_date) is null
            and error_message is null;
/*
       UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Gender Cannot have more than one character',
              ERROR_COLUMN  = 'GENDER',
              ERROR_VALUE   = 'GENDER:' || NVL(GENDER,'NULL')
       WHERE  batch_number = p_batch_number
       AND    LENGTH(GENDER) > 1
       AND    ERROR_MESSAGE IS NULL;
*/
        update mass_enrollments
        set
            error_message = 'Middle Name Cannot have more than one character',
            error_column = 'MIDDLE_NAME',
            error_value = 'MIDDLE_NAME:' || nvl(middle_name, 'NULL')
        where
                batch_number = p_batch_number
            and length(middle_name) > 1
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Birth Date cannot be blank for plan type',
            error_column = 'BIRTH_DATE',
            error_value = 'BIRTH_DATE:' || nvl(birth_date, 'NULL')
        where
                batch_number = p_batch_number
            and birth_date is null
            and error_message is null;
/*
         UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Gender cannot be blank for plan type',
              ERROR_COLUMN  = 'GENDER',
              ERROR_VALUE   = 'GENDER:' || NVL(GENDER,'NULL')
       WHERE  BATCH_NUMBER = p_batch_number
       AND    GENDER IS  NULL
       AND    ERROR_MESSAGE IS NULL;
*/
        update mass_enrollments
        set
            error_message = 'State Cannot have more than two characters',
            error_column = 'STATE',
            error_value = 'STATE:' || nvl(state, 'NULL')
        where
                batch_number = p_batch_number
            and length(state) > 2
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Effective Date is not in correct format ,Correct Effective Date',
            error_column = 'EFFECTIVE_DATE',
            error_value = 'EFFECTIVE_DATE:' || nvl(effective_date, 'NULL')
        where
                batch_number = p_batch_number
            and format_to_date(effective_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Open date is not in correct format ,Correct Open Date',
            error_column = 'START_DATE',
            error_value = 'START_DATE:' || nvl(start_date, 'NULL')
        where
                batch_number = p_batch_number
            and format_to_date(start_date) is null
            and error_message is null;

--     Validations
        update mass_enrollments
        set
            error_message = 'Last Name cannot be blank',
            error_column = 'LAST_NAME',
            error_value = 'LAST_NAME:' || nvl(last_name, 'NULL')
        where
            last_name is null
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'First Name cannot be blank',
            error_column = 'FIRST_NAME',
            error_value = 'FIRST_NAME:' || nvl(first_name, 'NULL')
        where
            first_name is null
            and batch_number = p_batch_number
            and error_message is null;
       --- 9072 JAGADEESH
        update mass_enrollments m
        set
            error_message = 'Enter valid value for plan type',
            error_column = 'PLAN_CODE',
            error_value = 'PLAN_CODE:'
                          || nvl(m.plan_code, 'NULL')
        where
                batch_number = p_batch_number
            and not exists (
                select
                    plan_name
                from
                    plans
                where
                        plan_sign = 'SHA'
                    and upper(plan_name) = upper(m.plan_code)
            )
            and error_message is null;
        ---
        update mass_enrollments
        set
            error_message = 'Similar Subscriber Seems to Exist for this Employer',
            error_value = 'SSN:'
                          || nvl(mass_enrollments.ssn, 'NULL')
        where
            exists (
                select
                    *
                from
                    person,
                    enterprise,
                    account
                where
                        person.entrp_id = enterprise.entrp_id
                    and account.entrp_id = enterprise.entrp_id
                    and account.acc_id = mass_enrollments.entrp_acc_id
                    and person.first_name = mass_enrollments.first_name
                    and person.last_name = mass_enrollments.last_name
                    and account.account_type = mass_enrollments.account_type         -- Added by Swamy for Ticket#10312
                    and replace(person.ssn, '-') = replace(mass_enrollments.ssn, '-')   -- Added by Swamy for Ticket#10312
                    and person_type = 'SUBSCRIBER'
            )
            and batch_number = p_batch_number
            and error_message is null
            and nvl(action, 'N') in ( 'N' ); -- Added by Joshi for 8634

        -- Check for Individual duplicates without employer
        update mass_enrollments                   -- Added by Swamy for Ticket#9912
        set
            error_message = 'Similar Subscriber Seems to Exist'
        where
            exists (
                select
                    *
                from
                    person,
                    account
                where
                    person.entrp_id is null
                    and account.pers_id = person.pers_id
                    and person.first_name = mass_enrollments.first_name
                    and person.last_name = mass_enrollments.last_name
                    and account.account_type = 'LSA'
                    and replace(person.ssn, '-') = replace(mass_enrollments.ssn, '-')
                    and person_type = 'SUBSCRIBER'
            )
            and batch_number = p_batch_number
            and error_message is null
            and account_type = 'LSA'
            and nvl(action, 'N') in ( 'N' ); -- Added by Joshi for 8634

        update mass_enrollments
        set
            error_message = 'Address cannot be blank',
            error_column = 'ADDRESS',
            error_value = 'ADDRESS:' || nvl(address, 'NULL')
        where
                nvl(
                    ltrim(rtrim(address)),
                    '-1'
                ) = '-1'
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'City cannot be blank',
            error_column = 'CITY',
            error_value = 'CITY:' || nvl(city, 'NULL')
        where
            city is null
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Effective Date Cannot be Null',
            error_column = 'EFFECTIVE_DATE',
            error_value = 'EFFECTIVE_DATE:' || nvl(effective_date, 'NULL')
        where
            effective_date is null
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'State cannot be blank',
            error_column = 'STATE',
            error_value = 'STATE:' || nvl(state, 'NULL')
        where
            state is null
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'ZIP cannot be blank',
            error_column = 'ZIP',
            error_value = 'ZIP:' || nvl(zip, 'NULL')
        where
            zip is null
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Social Security Number Cannot be Null',
            error_column = 'SSN',
            error_value = 'SSN:' || nvl(ssn, 'NULL')
        where
            ssn is null
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments a
        set
            error_message = 'Duplicate SSN, Other Subscribers exist with Same SSN, Search on the Subscriber to find the details',
            error_column = 'DUPLICATE',
            error_value = 'SSN:' || nvl(ssn, 'NULL')
        where
                pc_account.check_duplicate(
                    replace(ssn, '-'),
                    a.group_number,
                    replace(a.employer_name, ','),
                    pc_account.get_account_type_from_entrp_id(entrp_id)   -- HSA Replaced by pc_account by Swamy for Ticket#9912 on 10/08/2021
                    ,
                    null
                ) = 'Y'
            and batch_number = p_batch_number
            and error_message is null
            and action = 'N'; -- Added by Joshi for 8634

        update mass_enrollments
        set
            error_message = 'ZIP code must be in the form 99999',
            error_column = 'ZIP',
            error_value = 'ZIP:' || nvl(zip, 'NULL')
        where
            ( length(zip) > 5
              or not regexp_like ( zip,
                                   '^[[:digit:]]+$' ) )
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter correct format for Birth Date MMDDYYYY for plan type',
            error_column = 'BIRTH_DATE',
            error_value = 'BIRTH_DATE:' || nvl(birth_date, 'NULL')
        where
            format_to_date(birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate
            and batch_number = p_batch_number
            and error_message is null;

	    /* commented by Joshi for 12909 . we should allow - to be used for SSN for HSA upload. 		
       UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'SSN Cannot be More than 9 digits',
              ERROR_COLUMN  = 'SSN',
              ERROR_VALUE   = 'SSN:' || NVL(SSN,'NULL')
       WHERE  LENGTH(SSN) > 9
       AND    batch_number = p_batch_number
       AND    ERROR_MESSAGE IS NULL;

       UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'SSN must be in the format of 999999999',
              ERROR_COLUMN  = 'SSN',
              ERROR_VALUE   = 'SSN:' || NVL(SSN,'NULL')
       WHERE  NOT REGEXP_LIKE(REPLACE(SSN,'-'), '^[[:digit:]]{9}$')
       AND    batch_number = p_batch_number
       AND    ERROR_MESSAGE IS NULL;
		 */

	   -- Added by Joshi for 12909 . we should allow - to be used for SSN for HSA upload.   
        update mass_enrollments
        set
            error_message = 'Social Security Number cannot have more than 11 characters if - is used',
            error_column = 'SSN',
            error_value = 'SSN:' || nvl(ssn, 'NULL')
        where
                length(ssn) > 9
            and batch_number = p_batch_number
            and ssn like '%-%'
            and length(ssn) > 11
            and error_message is null;

        -- Added by Joshi for 12909 . we should allow - to be used for SSN for HSA upload.   
        update mass_enrollments
        set
            error_message = 'SSN Cannot be More than 9 digits',
            error_column = 'SSN',
            error_value = 'SSN:' || nvl(ssn, 'NULL')
        where
                length(ssn) > 9
            and batch_number = p_batch_number
            and ssn not like '%-%'
            and length(ssn) > 9
            and error_message is null;

     -- IF more than 1 record with same ssn in a file is uploaded, the system should reject both the records,
     -- Added by Swamy for Ticket#10318 on 09/09/2021
        update mass_enrollments
        set
            error_message = 'Duplicate SSN in the file uploaded',
            error_column = 'SSN',
            error_value = 'SSN:' || nvl(ssn, 'NULL')
        where
                batch_number = p_batch_number
            and error_message is null
            and replace(ssn, '-') in (
                select
                    ssn
                from
                    (
                        select
                            ssn, batch_number, count(replace(ssn, '-'))
                        from
                            mass_enrollments
                        group by
                            ssn, batch_number
                        having count(replace(ssn, '-')) > 1
                               and batch_number = p_batch_number
                    )
            );

      /* UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Deductible Cannot be Null'
           ,  ERROR_COLUMN  = 'DEDUCTIBLE'
       WHERE  DEDUCTIBLE IS NULL
       AND    ENTRP_ACC_ID = pv_entrp_id
       AND    ERROR_MESSAGE IS NULL;*/

        update mass_enrollments
        set
            error_message = 'The Start Date of Plan must be between 01011900 and '
                            || to_char(sysdate + 120, 'MM/DD/YYYY'),
            error_column = 'START_DATE',
            error_value = 'START_DATE:' || nvl(start_date, 'NULL')
        where
                format_to_date(start_date) > sysdate + 120
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Maximum allowed contribution is '
                            || to_number(pc_param.get_value('MAX_CONTRIBUTION')),
            error_column = 'DEDUCTIBLE',
            error_value = 'DEDUCTIBLE:' || nvl(deductible, 'NULL')
        where
                deductible > to_number(pc_param.get_value('MAX_CONTRIBUTION'))
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'veritas plan code mis-match',
            error_column = 'PLAN_CODE',
            error_value = 'PLAN_CODE:' || nvl(plan_code, 'NULL')
        where
            group_number like 'GVRT%'
            and plan_code != (
                select
                    plan_name
                from
                    plans
                where
                    plan_code = 4
            )
            and batch_number = p_batch_number
            and error_message is null;

        update mass_enrollments
        set
            error_message = '1.Group Number is invalid for plan type. 2.Verify Group Number of employer, cannot find match for plan type'
            ,
            error_column = 'GROUP_NUMBER',
            error_value = 'GROUP_NUMBER:' || nvl(group_number, 'NULL')
        where
            group_number not like 'GVRT%'
            and plan_code = (
                select
                    plan_name
                from
                    plans
                where
                    plan_code = 4
            )
            and batch_number = p_batch_number
            and error_message is null;

   --Add Division Code Change
        for x in (
            select
                mass_enrollment_id,
                entrp_id,
                division_code
            from
                mass_enrollments
            where
                    batch_number = p_batch_number
                and error_message is null
        ) loop
            if
                x.entrp_id is not null
                and x.division_code is not null
            then
                update mass_enrollments
                set
                    error_message = 'Division Code is not Setup',
                    error_column = 'DIVISION_CODE',
                    error_value = 'DIVISION_CODE:' || nvl(division_code, 'NULL')
                where
                        mass_enrollment_id = x.mass_enrollment_id
                    and pc_employer_divisions.get_division_count(x.entrp_id,
                                                                 upper(x.division_code)) = 0;

            end if;
        end loop;

       /*

       UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Start date  Cannot be more than 60 days from the Current Date'
           ,  ERROR_COLUMN  = 'START_DATE'
       WHERE  ABS(SYSDATE-TO_DATE(START_DATE,'MMDDRRRR')) > 60
       AND    ENTRP_ACC_ID = pv_entrp_id
       AND    ERROR_MESSAGE IS NULL;*/

  /*     UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Carrier Name Cannot be Null'
           ,  ERROR_COLUMN  = 'CARRIER'
       WHERE  CARRIER IS NULL
       AND    ENTRP_ACC_ID = pv_entrp_id
       AND    ERROR_MESSAGE IS NULL;

       UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Check the Carrier Name, Verify if the Insurance Company exists'
           ,  ERROR_COLUMN  = 'CARRIER'
       WHERE  NOT EXISTS (SELECT ENTRP_ID FROM ENTERPRISE WHERE EN_CODE = 3
                         AND UPPER(NAME) LIKE UPPER(CARRIER)||'%'
                         AND ROWNUM = 1 AND CARRIER IS NOT NULL)
       AND    ENTRP_ACC_ID = pv_entrp_id
       AND    ERROR_MESSAGE IS NULL;

          INSERT INTO ENTERPRISE
       (ENTRP_ID
       ,EN_CODE
       ,NAME)
       SELECT ENTRP_SEQ.NEXTVAL
             ,3
             ,CARRIER
       FROM  MASS_ENROLLMENTS_EXTERNAL
       WHERE  CARRIER IS NOT NULL AND NOT EXISTS (SELECT ENTRP_ID FROM ENTERPRISE WHERE EN_CODE = 3
                         AND UPPER(NAME) LIKE UPPER(CARRIER)||'%'
                         AND ROWNUM = 1 );

*/
	 -- Added by Joshi for 8634 on 04/12//2020
        update mass_enrollments
        set
            error_message = 'Termination Date is not in correct format ,Correct Termination Date',
            error_column = 'TERMINATION_DATE',
            error_value = 'TERMINATION_DATE:' || nvl(termination_date, 'NULL')
        where
                batch_number = p_batch_number
            and format_to_date(termination_date) is null
            and termination_date is not null
            and error_message is null;
    -- code ends here. Joshi for 8634 on 04/12//2020

        update mass_enrollments
        set
            error_message = 'Enter valid value for Debit Card information for plan type: Valid values are YES/NO.',
            error_column = 'DEBIT_CARD',
            error_value = 'DEBIT_CARD:' || debit_card
        where
                batch_number = p_batch_number
            and upper(nvl(debit_card, 'NO')) not in ( 'YES', 'NO' )
            and error_message is null;

        update mass_enrollments
        set
            setup_status = 'No',
            account_status = 'Pending'
        where
            note is not null
            and batch_number = p_batch_number;

     --  COMMIT;
    exception
        when others then
            raise_application_error('-20002', 'Error in Validation ' || sqlerrm);
    end validate_enrollments;

    procedure process_enrollments (
        pv_entrp_id    in number,
        p_batch_number in number
    ) is
        l_entrp_id    number;
        l_broker_id   number;
        l_fee_setup   number;
        l_pers_id_tbl number_table := number_table();
    begin
        pc_log.log_error('PROCESS_ENROLLMENTS', 'Inserting Person');
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
            mailmet,
            phone_day,
            phone_even,
            email,
            relat_code,
            note,
            entrp_id,
            person_type,
            mass_enrollment_id,
            creation_date,
            created_by,
            division_code
        )--Add division code
            select
                pers_seq.nextval,
                first_name,
                middle_name,
                last_name,
                format_to_date(birth_date),
                title,
                decode(
                    initcap(gender),
                    'Male',
                    'M',
                    'Female',
                    'F',
                    upper(gender)
                ),
                decode(
                    instr(ssn, '-', 1),
                    0,
                    substr(ssn, 1, 3)
                    || '-'
                    || substr(ssn, 4, 2)
                    || '-'
                    || substr(ssn, 6, 9),
                    ssn
                ),
                driver_license,
                passport,
                address,
                city,
                upper(state),
                substr(zip, 1, 5),
                (
                    select
                        lookup_code
                    from
                        lookups
                    where
                            lookup_name = 'MAIL_TYPE'
                        and upper(description) like upper(contact_method)
                                                    || '%'
                        and contact_method is not null
                ),
                decode(
                    instr(day_phone, '-', 1),
                    0,
                    substr(day_phone, 1, 3)
                    || '-'
                    || substr(day_phone, 4, 3)
                    || '-'
                    || substr(day_phone, 7, 10),
                    day_phone
                ) day_phone,
                evening_phone,
                email_address,
                1,
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                nvl(entrp_id,
                    get_entrp_id(entrp_acc_id, employer_name, 'HSA')),
                'SUBSCRIBER',
                mass_enrollment_id,
                sysdate,
                a.created_by,
                division_code
            from
                mass_enrollments a
            where
                error_message is null
                and a.termination_date is null  -- Added by Joshi for 8634
                and a.action = 'N' -- Added by Joshi for 8634
                and batch_number = p_batch_number
                and not exists (
                    select
                        *
                    from
                        person  c,
                        account b
                    where
                            replace(c.ssn, '-') = replace(a.ssn, '-')
                        and b.account_status <> 4
                        and c.pers_id = b.pers_id
                        and b.account_type = nvl(a.account_type, 'HSA')
                );    -- 'HSA' Replaced by NVL(a.account_type,'HSA') by Swamy for Ticket#9912 on 10/08/2021

        commit;
        update mass_enrollments a
        set
            error_message = 'Error in Person Setup'
        where
            error_message is null
            and a.termination_date is null -- Added by Joshi for 8634
            and a.action = 'N' -- Added by Joshi for 8634
            and batch_number = p_batch_number
  --	and    not exists ( select null from PERSON where replace(SSN,'-') = a.SSN );commented and added below by Joshi for 12909(
     --  '-' should be allowed for SSN in the uploads.
            and not exists (
                select
                    null
                from
                    person
                where
                    replace(ssn, '-') = replace(a.ssn, '-')
            );

        pc_log.log_error('PROCESS_ENROLLMENTS', 'Inserting Insure' || p_batch_number);

     -- Added by Joshi for 9670( update pers_id in table)
        for x in (
            select
                c.pers_id,
                a.mass_enrollment_id
            from
                person           c,
                mass_enrollments a
            where
                ( process_status is null
                  or process_status = 'W' )
                and a.batch_number = p_batch_number
                and a.mass_enrollment_id = c.mass_enrollment_id
        ) loop
            update mass_enrollments a
            set
                pers_id = x.pers_id
            where
                mass_enrollment_id = x.mass_enrollment_id;

            l_pers_id_tbl.extend;
            l_pers_id_tbl(l_pers_id_tbl.count) := x.pers_id;
        end loop;
      -- code ends here.

        pc_log.log_error('PROCESS_ENROLLMENTS:  l_pers_id_tbl', l_pers_id_tbl.count);

        -- Inserting into Insure
        insert into insure (
            pers_id,
            insur_id,
            plan_type,
            start_date,
            deductible,
            note
        )
            select
                b.pers_id,
                get_carrier_id(carrier) carrier_id,
                nvl(
                    pc_lookups.get_plan_type_code(a.plan_type),
                    0
                )                       plan_type,
                format_to_date(a.effective_date),
                nvl(deductible, 1200)   deductible,
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments'))
            from
                mass_enrollments a,
                person           b
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and error_message is null
                and a.termination_date is null -- Added by Joshi for 8634
                and a.action = 'N' -- Added by Joshi for 8634
                and batch_number = p_batch_number
                and not exists (
                    select
                        *
                    from
                        insure
                    where
                        pers_id = b.pers_id
                );

        pc_log.log_error('PROCESS_ENROLLMENTS', 'after Insure');
        update mass_enrollments a
        set
            error_message = 'Error in Health Plan Setup'
        where
            error_message is null
            and a.termination_date is null -- Added by Joshi for 8634
            and a.action = 'N' -- Added by Joshi for 8634
            and batch_number = p_batch_number
            and not exists (
                select
                    null
                from
                    person b,
                    insure c
                where
                        replace(b.ssn, '-') = replace(a.ssn, '-')
                    and b.pers_id = c.pers_id
            );

        pc_log.log_error('PROCESS_ENROLLMENTS', 'getting broker');
        if pv_entrp_id <> 0 then
            select
                entrp_id,
                broker_id,
                fee_setup
            into
                l_entrp_id,
                l_broker_id,
                l_fee_setup
            from
                account
            where
                acc_id = pv_entrp_id;

        end if;

        pc_log.log_error('PROCESS_ENROLLMENTS', 'Inserting account');

	-- Insertinto Account
        insert into account (
            acc_id,
            pers_id,
            entrp_id,
            acc_num,
            plan_code,
            start_date,
            end_date,
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
            salesrep_id,
            am_id,
            verified_by,
            account_type   -- Account_type Added by Swamy for Ticket#9912 on 10/08/2021
            ,
            id_verified
        )   -- id_verified Added by Swamy for Ticket#9912
            select
                acc_seq.nextval,
                b.pers_id,
                null,
                pc_account.generate_acc_num(d.plan_code, b.state),
                d.plan_code,
                nvl(
                    greatest(
                        format_to_date(a.start_date),
                        format_to_date(a.effective_date)
                    ),
                    sysdate
                ),
                null,
                nvl(a.employer_amount, 0) + nvl(a.employee_amount, 0),
                nvl(
                    nvl(l_broker_id,
                        nvl((
                        select
                            broker_id
                        from
                            account
                        where
                            entrp_id = b.entrp_id
                    ), a.broker_id)),
                    0
                ),
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments'))
      -- , NVL(decode(b.entrp_id ,null,null,( SELECT FEE_SETUP
      --         FROM ACCOUNT WHERE entrp_id = B.ENTRP_ID
      --        )), PC_PLAN.fsetup_paper(D.PLAN_CODE,B.ENTRP_ID))
              --Ticket#2488.For EDI File feed manual charges should be $15
                       ,
                case
                    when a.enrollment_source = 'EDI' then
                        pc_plan.fsetup_edi(d.plan_code, b.entrp_id)
                    when a.enrollment_source <> 'EDI'
                         and b.entrp_id is not null then
                        (
                            select
                                fee_setup
                            from
                                account
                            where
                                entrp_id = b.entrp_id
                        )
                    else
                        pc_plan.fsetup_paper(d.plan_code, b.entrp_id)
                end
           -- Added by Joshi for 5363. to get the monthy fee for e-HSA plan(paper)
                ,
                case
                    when a.enrollment_source = 'PAPER'
                         and d.plan_code = 8 then
                        pc_plan.fmonth_ehsa_paper(d.plan_code)
                    else
                        d.fmonth
                end,
                sysdate
	  /*   , CASE WHEN A.ACCOUNT_STATUS='Active' AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	               1
	       ELSE 3 END ACCOUNT_STATUS*/,
                decode(account_type, 'LSA', '1', 3)    -- decode Added by Swamy for Ticket#9912 before it was hardcoded to 3
                ,
                decode(account_type, 'LSA', '1', 0)    -- decode Added by Swamy for Ticket#9912 before it was hardcoded to 0
                ,
                decode(a.sign_on_file, null, 'N', 'Y'),
                format_to_date(a.start_date) end,
                nvl((
                    select
                        salesrep_id
                    from
                        account
                    where
                        entrp_id = a.entrp_id
                ),
                    pc_broker.get_salesrep_id(a.broker_id)),
                pc_sales_team.get_salesrep_detail(a.entrp_id, 'SECONDARY') -- added by joshi 5461 : populate Account manager
                ,
                decode(account_type,
                       'LSA',
                       a.created_by,
                       decode(a.created_by, 441, a.created_by, null))   -- decode Added by Swamy for Ticket#9912
                       ,
                account_type      -- Account_type Added by Swamy for Ticket#9912 on 10/08/2021
                ,
                decode(account_type, 'LSA', 'Y', 'N')   -- ID Verification not required fro LSA, so directly making it as Y, Added by Swamy for Ticket#9912 on 10/08/2021
            from
                mass_enrollments a,
                person           b,
                plan_fee_v       d
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and error_message is null
                and a.termination_date is null -- Added by Joshi for 8634
                and a.action = 'N' -- Added by Joshi for 8634
	--AND   UPPER(D.PLAN_NAME) = UPPER(nvl(A.PLAN_CODE,'Standard'))
                and upper(d.plan_name) = upper(nvl(a.plan_code, 'Premium')) -- Added by Joshi for 6794. Standard plan changed to Premium.
                and batch_number = p_batch_number
                and not exists (
                    select
                        *
                    from
                        account
                    where
                        pers_id = b.pers_id
                );

        update person a
        set
            acc_numc = (
                select
                    reverse(acc_num)
                from
                    account
                where
                    a.pers_id = account.pers_id
            )
        where
            mass_enrollment_id in (
                select
                    mass_enrollment_id
                from
                    mass_enrollments
                where
                        entrp_acc_id = pv_entrp_id
                    and batch_number = p_batch_number
            );

        update mass_enrollments a
        set
            error_message = 'Error in Account Setup'
        where
            error_message is null
            and a.termination_date is null -- Added by Joshi for 8634
            and a.action = 'N' -- Added by Joshi for 8634
            and batch_number = p_batch_number
            and not exists (
                select
                    *
                from
                    person  c,
                    account b
                where
                        replace(c.ssn, '-') = replace(a.ssn, '-')
                    and c.pers_id = b.pers_id
                    and b.account_type = nvl(a.account_type, 'HSA')   -- 'HSA' Replaced by NVL(a.account_type,'HSA') by Swamy for Ticket#9912 on 10/08/2021
            );

        pc_log.log_error('PROCESS_ENROLLMENTS', 'Inserting card');

    -- Added by Joshi for 9670(update acc_num)

        for x in (
            select
                pers_id,
                acc_id,
                acc_num
            from
                account
            where
                account.pers_id in (
                    select
                        *
                    from
                        table ( cast(l_pers_id_tbl as number_table) )
                )
        ) loop
            update mass_enrollments a
            set
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                pers_id = x.pers_id;

        end loop;

-- code ends here 9670.

        if pv_entrp_id <> 0 then
            insert into card_debit (
                card_id,
                start_date,
                emitent,
                note,
                status,
                max_card_value,
                created_by,
                last_updated_by,
                last_update_date
            )
                select
                    b.pers_id,
                    nvl(
                        greatest(
                            format_to_date(a.start_date),
                            format_to_date(a.effective_date)
                        ),
                        sysdate
                    ),
                    6763 -- Evolution Benefits
                    ,
                    'Mass Enrollment',
                    case
                        when pc_plan.can_create_card_on_pend(p.plan_code) = 'Y' then
                            1
                        else
                            9
                    end,
                    0
	  /*   , CASE WHEN A.ACCOUNT_STATUS='Active'
	        AND A.SETUP_STATUS = 'Yes' AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	             1
               ELSE
	             9
               END
      , CASE WHEN A.ACCOUNT_STATUS='Active'
	        AND A.SETUP_STATUS = 'Yes' AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	             NVL(A.EMPLOYER_AMOUNT,0)+ NVL(A.EMPLOYEE_AMOUNT,0)
               ELSE
	             0
               END*/,
                    a.created_by,
                    a.created_by,
                    sysdate
                from
                    mass_enrollments a,
                    person           b,
                    plans            p
                where
                        a.mass_enrollment_id = b.mass_enrollment_id
                    and error_message is null
                    and a.termination_date is null -- Added by Joshi for 8634
                    and a.action = 'N' -- Added by Joshi for 8634
                    and a.debit_card = 'Yes'
                    and upper(a.plan_code) = upper(p.plan_name)
                    and batch_number = p_batch_number
                    and exists (
                        select
                            *
                        from
                            enterprise
                        where
                                entrp_id = b.entrp_id
                            and nvl(card_allowed, 1) = 0
                    )
                    and not exists (
                        select
                            *
                        from
                            card_debit
                        where
                            card_id = b.pers_id
                    );

        else
            insert into card_debit (
                card_id,
                start_date,
                emitent,
                note,
                status,
                max_card_value,
                created_by,
                last_updated_by
            )
                select
                    b.pers_id,
                    nvl(
                        greatest(
                            format_to_date(a.start_date),
                            format_to_date(a.effective_date)
                        ),
                        sysdate
                    ),
                    6763 -- Evolution Benefits
                    ,
                    'Mass Enrollment',
                    case
                        when pc_plan.can_create_card_on_pend(p.plan_code) = 'Y' then
                            1
                        else
                            9
                    end,
                    0
	/*     , CASE WHEN A.ACCOUNT_STATUS='Active' AND A.SETUP_STATUS = 'Yes'
	       AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	             1
               ELSE
	             9
               END
             , CASE WHEN A.ACCOUNT_STATUS='Active'
	        AND A.SETUP_STATUS = 'Yes' AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	             NVL(A.EMPLOYER_AMOUNT,0)+ NVL(A.EMPLOYEE_AMOUNT,0)
               ELSE
	            0
               END*/,
                    a.created_by,
                    a.created_by
                from
                    mass_enrollments a,
                    person           b,
                    plans            p
                where
                        a.mass_enrollment_id = b.mass_enrollment_id
                    and error_message is null
                    and a.termination_date is null -- Added by Joshi for 8634
                    and a.action = 'N' -- Added by Joshi for 8634
                    and a.debit_card = 'Yes'
                    and upper(a.plan_code) = upper(p.plan_name)
                    and batch_number = p_batch_number
                    and not exists (
                        select
                            *
                        from
                            card_debit
                        where
                            card_id = b.pers_id
                    );

        end if;

	-- Added by Joshi for 6794 : ACN Migration. migrate new standard accounts
    -- individual migration
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
        )
            select
                mig_seq.nextval,
                a.acc_id,
                a.pers_id,
                a.account_type,
                null,
                'I',
                'I',
                sysdate,
                0
            from
                mass_enrollments m,
                account          a,
                person           p
            where
                    m.batch_number = p_batch_number
                and m.mass_enrollment_id = p.mass_enrollment_id
                and a.account_type = 'HSA'
                and a.plan_code = 1
                and a.pers_id = p.pers_id
                and p.entrp_id is null
                and m.error_message is null
                and m.termination_date is null -- Added by Joshi for 8634 ;
                and m.action = 'N';  -- Added by Joshi for 8634

      -- Insert employees
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
        )
            select
                mig_seq.nextval,
                a.acc_id,
                a.pers_id,
                a.account_type,
                pc_entrp.get_acc_id(p.entrp_id),
                'I',
                'E',
                sysdate,
                0
            from
                mass_enrollments m,
                account          a,
                person           p
            where
                    m.batch_number = p_batch_number
                and m.mass_enrollment_id = p.mass_enrollment_id
                and a.pers_id = p.pers_id
                and a.account_type = 'HSA'
                and a.plan_code = 1
                and p.entrp_id is not null
                and m.error_message is null
                and m.termination_date is null -- Added by Joshi for 8634
                and m.action = 'N'          -- Added by Joshi for 8634 ;
                and pc_acn_migration.is_employer_migrated(p.entrp_id) = 'Y';

    -- code ends here (6794).

    /*    FOR X IN (SELECT B.PERS_ID
	          FROM  MASS_ENROLLMENTS A
		      , PERSON B
		      , CARD_DEBIT C
       	          WHERE A.MASS_ENROLLMENT_ID = B.MASS_ENROLLMENT_ID
       	          AND   ERROR_MESSAGE IS NULL
	          AND   A.DEBIT_CARD = 'Yes'
		  AND   ENTRP_ACC_ID = pv_entrp_id
		  AND   B.PERS_ID = C.CARD_ID
		  AND   C.STATUS = 1)
        LOOP
             PC_FIN.CARD_OPEN_FEE(X.PERS_ID);
        END LOOP;
*/
        pc_log.log_error('PROCESS_ENROLLMENTS', 'Inserting income');

   /*     INSERT INTO INCOME (change_num
	                  , acc_id
			  , fee_date
			  , fee_code
			  , pay_code
			  , cc_number
			  , contributor_amount
			  , amount
			  , amount_add
			  , contributor
			  , note)
            SELECT CHANGE_SEQ.NEXTVAL
	         , C.ACC_ID
           , NVL(GREATEST(
               FORMAT_TO_DATE(a.start_date),FORMAT_TO_DATE(a.effective_date )),SYSDATE)
 		 , 3 -- Initial Contribution
		 , 1 -- Check
		 , A.CHECK_NUMBER
		 , NVL(A.CHECK_AMOUNT,(NVL(A.EMPLOYER_AMOUNT,0)+ NVL(A.EMPLOYEE_AMOUNT,0)))
		 , NVL(A.EMPLOYER_AMOUNT,0)
		 , NVL(A.EMPLOYEE_AMOUNT,0)
		 , B.ENTRP_ID
	      ,DECODE(SETUP_STATUS,'No','Note **** '||A.ERROR_MESSAGE|| '  '|| a.note ||' in Mass Enrollments ',NVL(a.NOTE,'Mass Enrollments'))
           FROM  MASS_ENROLLMENTS A
	       , PERSON B
	       , ACCOUNT C
           WHERE A.MASS_ENROLLMENT_ID = B.MASS_ENROLLMENT_ID
	   AND   ERROR_MESSAGE IS NULL
	   AND   B.PERS_ID = C.PERS_ID
  AND   batch_number = p_batch_number
	   AND NVL(A.EMPLOYER_AMOUNT,0)+ NVL(A.EMPLOYEE_AMOUNT,0) > 0;*/

        update mass_enrollments
        set
            error_message = 'Successfully Loaded',
            setup_status = 'Yes'
	--	, action = 'Y'    -- Added by Swamy for Ticket#9912 on 10/08/2021
        where
            error_message is null
            and batch_number = p_batch_number;

        pc_log.log_error('In Proc after insert ', sql%rowcount);
        pc_log.log_error('In Proc after insert p_batch_number', p_batch_number);
        commit;
    exception
        when others then
            raise_application_error('-20001', 'Error in Processing Enrollments' || sqlerrm);
    end process_enrollments;

    procedure process_mass_enrollments (
        pv_file_name in varchar2,
        pv_entrp_id  in number,
        p_user_id    in number
    ) is
        l_batch_number number;
    begin
        pc_log.log_error('process_mass_enrollments', 'In process_mass_enrollments');
        export_enrollment_file(pv_file_name, pv_entrp_id, p_user_id, null, l_batch_number);
        validate_lsa_enrollments(pv_entrp_id, p_user_id, l_batch_number, 'HSA');    -- Added by Swamy for Ticket#9912(10295)
        validate_enrollments(pv_entrp_id, p_user_id, l_batch_number);
        process_enrollments(pv_entrp_id, l_batch_number);
        commit;
    end process_mass_enrollments;

    procedure process_mass_dependants (
        pv_file_name in varchar2,
        pv_entrp_id  in number,
        p_user_id    in number
    ) is
        l_batch_number number;
    begin
        export_dependant_file(pv_file_name, pv_entrp_id);
        validate_dependants(pv_entrp_id, p_user_id, l_batch_number);
        process_dependants(pv_entrp_id, l_batch_number);
        commit;
    end process_mass_dependants;

    procedure export_dependant_file (
        pv_file_name in varchar2,
        pv_entrp_id  in number
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
        l_count      integer;
        l_file_id    integer;
        l_incorrect_template exception;
    begin
        if pv_entrp_id <> 441 then
            lv_dest_file := substr(pv_file_name,
                                   instr(pv_file_name, '/', 1) + 1,
                                   length(pv_file_name) - instr(pv_file_name, '/', 1));
        else
            lv_dest_file := pv_file_name;
        end if;


     /*
      l_create_ddl := 'CREATE TABLE  MASS_ENROLL_DEPENDANT_EXTERNAL '||
                      ' (SUBSCRIBER_SSN    VARCHAR2(30),'||
		      '  FIRST_NAME        VARCHAR2(255),'||
                      '	 MIDDLE_NAME       VARCHAR2(255),'||
              	      '  LAST_NAME         VARCHAR2(255),'||
		      '  GENDER            VARCHAR2(30),'||
		      '	 BIRTH_DATE        VARCHAR2(30),'||
                      '  SSN               VARCHAR2(30),'||
                      '  RELATIVE          VARCHAR2(30),'||
                      '  DEP_FLAG          VARCHAR2(30),'||
                      '  BENEFICIARY_TYPE  VARCHAR2(30),'||
                      '  BENEFICIARY_RELATION VARCHAR2(30),'||
                      '  EFFECTIVE_DATE      VARCHAR2(12),'||
                      '  DISTIRIBUTION        VARCHAR2(30),'||
                      '  ACCOUNT_TYPE        VARCHAR2(30), '||
                      '  ACC_NUM             VARCHAR2(30))'||
		      '  ORGANIZATION EXTERNAL '||
		      '  ( TYPE ORACLE_LOADER DEFAULT DIRECTORY ENROLL_DIR '||
		      '  ACCESS PARAMETERS ('||
		      '  records delimited by newline skip 1'||
		      '  badfile ''enroll.bad'' '||
		      '  logfile ''enroll.log'' '||
		      '  fields terminated by '','' '||
		      '  optionally enclosed by ''"'' '||
		      '  LRTRIM '||
		      '  MISSING FIELD VALUES ARE NULL ) '||
		      '  LOCATION ('''|| lv_dest_file ||''')'||
		      '  ) REJECT LIMIT UNLIMITED ';
       */

        if pv_entrp_id <> 441 then

      /* Get the contents of BLOB from wwv_flow_files */
            begin
                select
                    blob_content
                into l_blob
                from
                    wwv_flow_files
                where
                    name = pv_file_name;

                l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
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
                    name = pv_file_name;

            exception
                when others then
                    null;
            end;

        end if;

        if file_length(lv_dest_file, 'ENROLL_DIR') > 0 then
            begin
                dbms_output.put_line('In Loop');
                execute immediate '
                           ALTER TABLE MASS_ENROLL_DEPENDANT_EXTERNAL
                            location (ENROLL_DIR:'''
                                  || lv_dest_file
                                  || ''')';
                dbms_output.put_line('After alter');
                if sql%rowcount <= 0 then
        -- Added by Joshi for 9670. capture the error and #9781
                    select
                        count(*)
                    into l_count
                    from
                        mass_enroll_dependant_external;

                    if l_count = 0 then
                        select
                            max(file_upload_id)
                        into l_file_id
                        from
                            file_upload_history
                        where
                            file_name = lv_dest_file;

                        pc_file_upload.insert_file_upload_history(
                            p_batch_num         => null,
                            p_user_id           => 427,
                            pv_file_name        => lv_dest_file,
                            p_entrp_id          => null ---l_entrp_id
                            ,
                            p_action            => 'ENROLLMENT',
                            p_account_type      => 'HSA',
                            p_enrollment_source => 'EDI',
                            p_file_type         => 'Dependent_eligibility',
                            p_error             => 'Please check the file, template might be incorrect or file must be empty',
                            x_file_upload_id    => l_file_id
                        );

             /* mail_utility.email_files(
              from_name    => 'enrollments@sterlingadministration.com',
              --to_names     => 'techsupport@sterlingadministration.com',
              to_names     => 'Jagadeesh.Reddy@sterlingadministration.com; piyush.kumar@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,shivani.jaiswal@sterlingadministration.com,srinivasulu.gudur@sterlingadministration.com, vhsqateam@sterlingadministration.com',  -- InternalPurpouse
              subject      => 'Error in Dependent Enrollment file Upload '||lv_dest_file,
              html_message => 'Please check the file, template might be incorrect or file must be empty',
              --attach       => l_files);
              attach => samfiles('/u01/app/oracle/oradata/12QA/enroll/'||lv_dest_file));
           -- code ends here Joshi: 9670
		   */   -- Commented by Swamy for Ticket#10080 on 28/07/2021
                        raise l_incorrect_template;
                    end if;

                end if;

            end;
        end if;

        commit;
    exception
        when l_incorrect_template then
        -- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

        -- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'The Template is Not Correct, Please check the template ' || sqlerrm);
        when others then
            rollback;

-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

-- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'Error in Exporting dependant File ' || sqlerrm);
    end export_dependant_file;

    procedure validate_dependants (
        pv_entrp_id    in number,
        p_user_id      in number,
        x_batch_number out number
    ) is
        l_batch_number number;
    begin
    /*  DELETE FROM MASS_ENROLL_DEPENDANT A WHERE  ENTRP_ACC_ID = pv_entrp_id
      AND (CREATION_DATE > SYSDATE-30
      OR EXISTS ( SELECT * FROM PERSON B
                  WHERE B.SSN = A.SSN)
      OR EXISTS (SELECT * FROM MASS_ENROLL_DEPENDANT B
                  WHERE REPLACE(B.SSN,'-') = REPLACE(A.SSN,'-')));
 */
 /* Ticket#5422 */
        x_batch_number := batch_num_seq.nextval;
        pc_log.log_error('In test', 'In Vaidate');
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
            entrp_acc_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            account_type,
            acc_num,
            debit_card_flag,
            batch_number
        )
            select
                mass_enrollments_seq.nextval,
                format_ssn(subscriber_ssn),
                first_name
                || decode(
                    length(middle_name),
                    1,
                    '',
                    ' ' || middle_name
                )                           first_name,
                decode(
                    length(middle_name),
                    1,
                    '',
                    ' ' || middle_name
                )                           middle_name,
                last_name,
                upper(gender),
                format_date(birth_date)     birth_date,
                format_ssn(ssn),
                relative,
                nvl(dep_flag, 'Dependant'),
                nvl(beneficiary_type, 'PRIMARY'),
                initcap(beneficiary_relation),
                format_date(effective_date) effective_date,
                distiribution,
                pv_entrp_id,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                account_type,
                acc_num,
                debit_card_flag,
                x_batch_number
            from
                mass_enroll_dependant_external a
            where
                subscriber_ssn is not null;
   /*    AND   NOT EXISTS ( SELECT * FROM PERSON B, ACCOUNT C
                          WHERE FORMAT_SSN(b.SSN) = FORMAT_SSN(A.SSN)
                          AND   B.PERS_MAIN = C.PERS_ID
                          AND   A.ACC_NUM = C.ACC_NUM
                          AND   C.ACCOUNT_TYPE  = NVL(A.ACCOUNT_TYPE,'HSA'));
 */
        pc_log.log_error('In test', 'After Insert');
        update mass_enroll_dependant
        set
            error_message = 'Gender Cannot have more than one character',
            error_column = 'GENDER',
            error_value = 'GENDER:' || nvl(gender, 'NULL')
        where
                entrp_acc_id = pv_entrp_id
            and length(gender) > 1
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Middle Name Cannot have more than one character',
            error_column = 'MIDDLE_NAME',
            error_value = 'MIDDLE_NAME:' || nvl(middle_name, 'NULL')
        where
                entrp_acc_id = pv_entrp_id
            and length(middle_name) > 1
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Correct Birth Date',
            error_column = 'BIRTH_DATE',
            error_value = 'BIRTH_DATE:' || nvl(birth_date, 'NULL')
        where
                entrp_acc_id = pv_entrp_id
            and format_to_date(birth_date) is null
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Correct Effective Date',
            error_column = 'EFFECTIVE_DATE',
            error_value = 'EFFECTIVE_DATE:' || nvl(effective_date, 'NULL')
        where
                entrp_acc_id = pv_entrp_id
            and format_to_date(effective_date) is null
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Subscriber SSN Cannot be blank',
            error_column = 'SUBSCRIBER_SSN',
            error_value = 'SUBSCRIBER_SSN:' || nvl(subscriber_ssn, 'NULL')
        where
            subscriber_ssn is null
            and entrp_acc_id = pv_entrp_id
            and batch_number = x_batch_number
            and error_message is null;

        update mass_enroll_dependant a
        set
            error_message = 'Cannot find Subscriber for this subscriber SSN ' || subscriber_ssn,
            error_column = 'SUBSCRIBER_SSN',
            error_value = 'SUBSCRIBER_SSN:' || nvl(subscriber_ssn, 'NULL')
        where
            not exists (
                select
                    *
                from
                    person
                where
                    ssn = a.subscriber_ssn
            )
                and entrp_acc_id = pv_entrp_id
                and batch_number = x_batch_number
                and error_message is null;

--     Validations
        update mass_enroll_dependant
        set
            error_message = 'Last Name Cannot be blank',
            error_column = 'LAST_NAME',
            error_value = 'LAST_NAME:' || nvl(last_name, 'NULL')
        where
            ltrim(rtrim(last_name)) is null
            and entrp_acc_id = pv_entrp_id
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'First Name Cannot be blank',
            error_column = 'FIRST_NAME',
            error_value = 'FIRST_NAME:' || nvl(first_name, 'NULL')
        where
            ltrim(rtrim(first_name)) is null
            and entrp_acc_id = pv_entrp_id
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag <> 'Beneficiary';

   /*    UPDATE MASS_ENROLL_DEPENDANT a
       SET    ERROR_MESSAGE = 'Similar Dependant Seems to Exist for Subsriber with SSN '|| SUBSCRIBER_SSN||' under this Employer'
       WHERE  EXISTS ( SELECT *
                       FROM    PERSON,  PERSON B
		       WHERE   PERSON.PERS_ID = B.PERS_MAIN
		       AND     a.FIRST_NAME = b.FIRST_NAME
		       AND     a.LAST_NAME = b.LAST_NAME)
	AND   ENTRP_ACC_ID = pv_entrp_id
        AND    ERROR_MESSAGE IS NULL
       AND    DEP_FLAG <> 'Beneficiary';*/

        update mass_enroll_dependant a
        set
            error_message = 'Duplicate SSN, Other dependents exist with Same SSN, Search on the Subscriber to find the details',
            error_column = 'DUPLICATE',
            error_value = 'SUBSCRIBER_SSN:' || nvl(subscriber_ssn, 'NULL')
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
                        account_type
                ) > 0
            and error_message is null
            and batch_number = x_batch_number
            and upper(dep_flag) <> upper('Beneficiary');

      /* UPDATE MASS_ENROLL_DEPENDANT a
       SET    ERROR_MESSAGE = 'Duplicate SSN, Other Dependents exist with Same SSN, Search on the Subscriber to find the details'
            , ERROR_COLUMN = 'DUPLICATE'
       WHERE   ( SELECT COUNT(*)
                  FROM    MASS_ENROLL_DEPENDANT b
		              WHERE    a.SSN= b.SSN
                  AND      a.account_type  = b.account_type
                  AND      a.acc_num = b.acc_num) > 1
       AND    ERROR_MESSAGE IS NULL
       AND    BATCH_NUMBER = x_batch_number
       AND    UPPER(DEP_FLAG) <> UPPER('Beneficiary');
       */

   /*    UPDATE MASS_ENROLL_DEPENDANT a
       SET    ERROR_MESSAGE = 'Similar Beneficiary Seems to Exist for Subsriber with SSN '|| SUBSCRIBER_SSN||' under this Employer'
       WHERE  EXISTS ( SELECT *
                       FROM    PERSON, BENEFICIARY B
		       WHERE   PERSON.SSN = a.SUBSCRIBER_SSN
		       AND     PERSON.PERS_ID = B.PERS_ID
		       AND     a.first_name ||' '||a.LAST_NAME LIKE '%'||B.BENEFICIARY_NAME||'%')
	AND   ENTRP_ACC_ID = pv_entrp_id
      AND    ERROR_MESSAGE IS NULL
       AND    DEP_FLAG = 'Beneficiary';

 */
        update mass_enroll_dependant
        set
            error_message = 'The Birth Date must be between 01011900 and Current Date',
            error_column = 'BIRTH_DATE',
            error_value = 'BIRTH_DATE:' || nvl(birth_date, 'NULL')
        where
            format_to_date(birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate
            and birth_date is not null
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'SSN must be in the format of 999999999',
            error_column = 'SSN',
            error_value = 'SSN:' || nvl(ssn, 'NULL')
        where
            not regexp_like ( replace(ssn, '-'),
                              '^[[:digit:]]{9}$' )
                and ssn is not null
                and error_message is null
                and batch_number = x_batch_number
                and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'The Effective Date of Beneficiary must be between 01011900 and '
                            || to_char(sysdate + 120, 'MM/DD/YYYY'),
            error_column = 'EFFECTIVE_DATE',
            error_value = 'EFFECTIVE_DATE:' || nvl(effective_date, 'NULL')
        where
            format_to_date(effective_date) not between to_date('01011900', 'MMDDRRRR') and sysdate + 120
            and effective_date is not null
            and error_message is null
            and batch_number = x_batch_number
            and dep_flag = 'Beneficiary';

        pc_log.log_error('In test', 'End Vaidate');
    exception
        when others then
            raise_application_error('-20001', 'Error in validating dependents ' || sqlerrm);

--       COMMIT;
    end validate_dependants;

    procedure process_dependants (
        pv_entrp_id    in number,
        p_batch_number in number
    ) is
        l_entrp_id  number;
        l_broker_id number;
        l_fee_setup number;
    begin
        pc_log.log_error('Mass Dependants..', p_batch_number);
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
        )
            select
                pers_seq.nextval,
                a.first_name,
                substr(a.middle_name, 1, 1),
                a.last_name,
                format_to_date(a.birth_date),
                decode(a.gender, 'Male', 'M', 'Female', 'F',
                       a.gender),
                decode(
                    instr(a.ssn, '-', 1),
                    0,
                    substr(a.ssn, 1, 3)
                    || '-'
                    || substr(a.ssn, 4, 2)
                    || '-'
                    || substr(a.ssn, 6, 9),
                    a.ssn
                ),
                decode(a.relative, 'Spouse', 2, 'Child', 3,
                       4),
                'Mass Enrollments ',
                b.pers_id,
                'DEPENDANT',
                a.mass_enrollment_id,
                case
                    when upper(a.debit_card_flag) in ( 'Y', 'YES' ) then
                        'Y'
                    else
                        'N'
                end
            from
                mass_enroll_dependant a,
                person                b,
                account               c
            where
                error_message is null
--	AND   ENTRP_ACC_ID = pv_entrp_id
                and b.pers_id = c.pers_id
                and a.subscriber_ssn = b.ssn
                and batch_number = p_batch_number
                and ( a.account_type is null
                      or a.account_type = c.account_type )
                and ( a.acc_num is null
                      or a.acc_num = c.acc_num )
                and nvl(dep_flag, 'Dependant') in ( 'Dependant', 'Dependent' );
--	AND   NOT EXISTS ( SELECT * FROM PERSON C WHERE REPLACE(C.SSN,'-') = A.SSN);
        pc_log.log_error('Mass Dependants..', 'After Isert..Cnt' || sql%rowcount);
        update mass_enroll_dependant a
        set
            error_message = 'Error in Person Setup'
        where
            error_message is null
            and batch_number = p_batch_number
--	AND    ENTRP_ACC_ID = pv_entrp_id
            and dep_flag in ( 'Dependant', 'Dependent' )
            and not exists (
                select
                    null
                from
                    person
                where
                    ssn = a.ssn
            );

        pc_log.log_error('Mass Dependants..', 'After Update..Cnt' || sql%rowcount);
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
        )
            select
                beneficiary_seq.nextval,
                a.first_name
                || ' '
                || a.last_name,
                (
                    select
                        lookup_code
                    from
                        lookups
                    where
                            lookup_name = 'BENEFICIARY_TYPE'
                        and upper(description) like upper(beneficiary_type)
                                                    || '%'
                ),
                nvl(beneficiary_relation, a.relative),
                format_to_date(effective_date),
                b.pers_id,
                sysdate,
                a.created_by,
                distiribution,
                'Mass Enrollments',
                a.mass_enrollment_id
            from
                mass_enroll_dependant a,
                person                b
            where
                error_message is null
                and batch_number = p_batch_number
                and is_number(distiribution) = 'Y'
	--AND   ENTRP_ACC_ID = pv_entrp_id
                and a.subscriber_ssn = b.ssn
                and ( dep_flag = 'Beneficiary'
                      or ( dep_flag in ( 'Dependant', 'Dependent' )
                           and beneficiary_type is not null
                           and distiribution is not null ) );

        pc_log.log_error('Mass Dependants..', 'After Benef' || sql%rowcount);
        update mass_enroll_dependant a
        set
            error_message = 'Error in beneficiary Setup'
        where
            error_message is null
--	AND    ENTRP_ACC_ID = pv_entrp_id
            and a.batch_number = p_batch_number
            and is_number(distiribution) = 'Y'
            and not exists (
                select
                    null
                from
                    beneficiary
                where
                    mass_enrollment_id = a.mass_enrollment_id
            )
            and ( dep_flag = 'Beneficiary'
                  or ( dep_flag in ( 'Dependant', 'Dependent' )
                       and beneficiary_type is not null
                       and distiribution is not null ) );

        pc_log.log_error('Mass Dependants..', 'Before Card Debit');
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
                dep.pers_id,
                sysdate,
                6763 -- Metavante
                ,
                'Mass Enrollment',
                1,
                null,
                a.created_by,
                a.created_by,
                sysdate
            from
                mass_enroll_dependant a,
                person                b,
                person                dep
            where
                    a.ssn = dep.ssn
                and a.subscriber_ssn = b.ssn
                and a.mass_enrollment_id = dep.mass_enrollment_id
                and a.error_message is null
                and dep.pers_main = b.pers_id
                and a.batch_number = p_batch_number
                and upper(a.debit_card_flag) in ( 'Y', 'YES' )
                and exists (
                    select
                        *
                    from
                        enterprise
                    where
                            entrp_id = b.entrp_id
                        and nvl(card_allowed, 1) = 0
                )
                and not exists (
                    select
                        *
                    from
                        card_debit
                    where
                        card_id = dep.pers_id
                )
                and exists (
                    select
                        *
                    from
                        card_debit
                    where
                        card_id = b.pers_id
                ); -- added on 12/25/2016 to make sure that the card request
  -- gets added only if there is a card for subscriber

        pc_log.log_error('Mass Dependants..', 'After Debit Card insert');
        update mass_enroll_dependant a
        set
            error_message = 'Successfully Loaded'
        where
            error_message is null
--	AND    ENTRP_ACC_ID = pv_entrp_id
            and a.batch_number = p_batch_number
            and exists (
                select
                    null
                from
                    person
                where
                    mass_enrollment_id = a.mass_enrollment_id
            )
            and dep_flag in ( 'Dependant', 'Dependent' );

        update mass_enroll_dependant a
        set
            error_message = 'Successfully Loaded'
        where
            error_message is null
	--AND    ENTRP_ACC_ID = pv_entrp_id
            and a.batch_number = p_batch_number
            and exists (
                select
                    null
                from
                    beneficiary
                where
                    mass_enrollment_id = a.mass_enrollment_id
            )
            and ( dep_flag = 'Beneficiary'
                  or ( dep_flag in ( 'Dependant', 'Dependent' )
                       and beneficiary_type is not null
                       and distiribution is not null ) );

    exception
        when others then
            raise_application_error('-20001', 'Error in Processing Dependants ' || sqlerrm);
    end process_dependants;

    procedure process_error (
        pv_mass_enrollment_id in number
    ) is
    begin
        validate_error_enrollments(pv_mass_enrollment_id);
        process_error_enrollments(pv_mass_enrollment_id);
        commit;
    end process_error;

    procedure validate_error_enrollments (
        pv_mass_enrollment_id in number
    ) is
    begin
        update mass_enrollments
        set
            error_message = null,
            error_column = null
        where
            mass_enrollment_id = pv_mass_enrollment_id;

        update mass_enrollments
        set
            error_message = 'Enter Valid Birth Date',
            error_column = 'BIRTH_DATE'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and format_to_date(birth_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Gender Cannot have more than one character',
            error_column = 'GENDER'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and length(gender) > 1
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Middle Name Cannot have more than one character',
            error_column = 'MIDDLE_NAME'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and length(middle_name) > 1
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'State Cannot have more than two character',
            error_column = 'STATE'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and length(state) > 2
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Effective Date',
            error_column = 'EFFECTIVE_DATE'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and format_to_date(effective_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Open Date',
            error_column = 'START_DATE'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and format_to_date(start_date) is null
            and error_message is null;

--     Validations
        update mass_enrollments
        set
            error_message = 'Last Name Cannot be Null',
            error_column = 'LAST_NAME'
        where
            last_name is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'First Name Cannot be Null',
            error_column = 'FIRST_NAME'
        where
            first_name is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Similar Subscriber Seems to Exist for this Employer',
            error_value = 'SSN:'
                          || nvl(mass_enrollments.ssn, 'NULL')
        where
            exists (
                select
                    *
                from
                    person,
                    enterprise,
                    account
                where
                        person.entrp_id = enterprise.entrp_id
                    and account.entrp_id = enterprise.entrp_id
                    and account.acc_id = mass_enrollments.entrp_acc_id
                    and person.first_name = mass_enrollments.first_name
                    and person.last_name = mass_enrollments.last_name
            )
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Address Cannot be Null',
            error_column = 'ADDRESS'
        where
            address is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'City Cannot be Null',
            error_column = 'CITY'
        where
            city is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'State Cannot be Null',
            error_column = 'STATE'
        where
            state is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Zip Cannot be Null',
            error_column = 'ZIP'
        where
            zip is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Social Security Number Cannot be Null',
            error_column = 'SSN'
        where
            ssn is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments a
        set
            error_message = 'Duplicate SSN, Other Subscribers exist with Same SSN, Search on the Subscriber to find the details',
            error_column = 'DUPLICATE'
        where
                pc_account.check_duplicate(
                    replace(ssn, '-'),
                    a.group_number,
                    replace(a.employer_name, ','),
                    'HSA',
                    null
                ) = 'Y'
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Effective Date Cannot be Null',
            error_column = 'EFFECTIVE_DATE'
        where
            effective_date is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'ZIP code must be in the form 99999',
            error_column = 'ZIP'
        where
            ( length(zip) > 5
              or not regexp_like ( zip,
                                   '^[[:digit:]]+$' ) )
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'The Birth Date must be between 01011900 and Current Date',
            error_column = 'BIRTH_DATE'
        where
            format_to_date(birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'SSN Cannot be More than 9 digits',
            error_column = 'SSN'
        where
                length(ssn) > 9
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'SSN must be in the format of 999999999',
            error_column = 'SSN'
        where
            not regexp_like ( replace(ssn, '-'),
                              '^[[:digit:]]{9}$' )
                and mass_enrollment_id = pv_mass_enrollment_id
                and error_message is null;

    /*   UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Deductible Cannot be Null'
           ,  ERROR_COLUMN  = 'DEDUCTIBLE'
       WHERE  DEDUCTIBLE IS NULL
       AND    MASS_ENROLLMENT_ID = pv_mass_enrollment_id
       AND    ERROR_MESSAGE IS NULL;*/

        update mass_enrollments
        set
            error_message = 'The Effective Date of Plan must be between 01011900 and '
                            || to_char(sysdate + 120, 'MM/DD/YYYY'),
            error_column = 'REGISTRATION_DATE'
        where
            format_to_date(effective_date) not between to_date('01011900', 'MMDDRRRR') and sysdate + 120
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Maximum allowed contribution is '
                            || to_number(pc_param.get_value('MAX_CONTRIBUTION')),
            error_column = 'DEDUCTIBLE'
        where
                deductible > to_number(pc_param.get_value('MAX_CONTRIBUTION'))
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

     /*  UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Plan Code must have some value'
           ,  ERROR_COLUMN  = 'PLAN_CODE'
       WHERE  PLAN_CODE IS NULL
       AND    MASS_ENROLLMENT_ID = pv_mass_enrollment_id
       AND    ERROR_MESSAGE IS NULL;

       UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Start date  Cannot be more than 60 days from the Current Date'
           ,  ERROR_COLUMN  = 'START_DATE'
       WHERE  ABS(SYSDATE-TO_DATE(START_DATE,'MMDDRRRR')) > 60
       AND    MASS_ENROLLMENT_ID = pv_mass_enrollment_id
       AND    ERROR_MESSAGE IS NULL;*/

        update mass_enrollments
        set
            error_message = 'Carrier Name Cannot be Null',
            error_column = 'CARRIER'
        where
            carrier is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

       /** Creating Carrier who does not exist in out system***/
  /*     INSERT INTO ENTERPRISE
       (ENTRP_ID
       ,EN_CODE
       ,NAME)
       SELECT ENTRP_SEQ.NEXTVAL
             ,3
             ,CARRIER
       FROM  MASS_ENROLLMENTS
       WHERE  NOT EXISTS (SELECT ENTRP_ID FROM ENTERPRISE WHERE EN_CODE = 3
                         AND UPPER(NAME) LIKE UPPER(CARRIER)||'%'
                         AND ROWNUM = 1 AND CARRIER IS NOT NULL)
       AND    MASS_ENROLLMENT_ID = pv_mass_enrollment_id
       AND    ERROR_MESSAGE IS NULL;

*/
        update mass_enrollments
        set
            setup_status = 'No',
            account_status = 'Pending'
        where
            note is not null;


     --  COMMIT;
    exception
        when others then
            raise_application_error('-20002', 'Error in Validation ' || sqlerrm);
    end validate_error_enrollments;

    procedure process_error_enrollments (
        pv_mass_enrollment_id in number
    ) is
        l_entrp_id  number;
        l_broker_id number;
        l_fee_setup number;
    begin
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
            mailmet,
            phone_day,
            phone_even,
            email,
            relat_code,
            note,
            entrp_id,
            person_type,
            mass_enrollment_id
        )
            select
                pers_seq.nextval,
                first_name,
                middle_name,
                last_name,
                format_to_date(birth_date),
                title,
                decode(
                    initcap(gender),
                    'Male',
                    'M',
                    'Female',
                    'F',
                    upper(gender)
                ),
                decode(
                    instr(ssn, '-', 1),
                    0,
                    substr(ssn, 1, 3)
                    || '-'
                    || substr(ssn, 4, 2)
                    || '-'
                    || substr(ssn, 6, 9),
                    ssn
                ),
                driver_license,
                passport,
                address,
                city,
                upper(state),
                substr(zip, 1, 5),
                (
                    select
                        lookup_code
                    from
                        lookups
                    where
                            lookup_name = 'MAIL_TYPE'
                        and upper(description) like upper(contact_method)
                                                    || '%'
                        and contact_method is not null
                ),
                decode(
                    instr(day_phone, '-', 1),
                    0,
                    substr(day_phone, 1, 3)
                    || '-'
                    || substr(day_phone, 4, 3)
                    || '-'
                    || substr(day_phone, 7, 10),
                    day_phone
                ) day_phone,
                evening_phone,
                email_address,
                1,
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                nvl(entrp_id,
                    get_entrp_id(entrp_acc_id, employer_name, 'HSA')),
                'SUBSCRIBER',
                mass_enrollment_id
            from
                mass_enrollments a
            where
                error_message is null
                and a.mass_enrollment_id = pv_mass_enrollment_id
                and not exists (
                    select
                        *
                    from
                        person  c,
                        account b
                    where
                            c.ssn = format_ssn(a.ssn)
                        and c.pers_id = b.pers_id
                        and b.account_type = 'HSA'
                );

        for x in (
            select
                c.pers_id,
                b.acc_num,
                a.error_message
            from
                person           c,
                account          b,
                mass_enrollments a
            where
                    a.mass_enrollment_id = c.mass_enrollment_id
                and a.mass_enrollment_id = pv_mass_enrollment_id
                and c.pers_id = b.pers_id
                and b.account_type = 'HSA'
        ) loop
            pc_log.log_error('ERROR_ENROLLMENT', 'pers_id '
                                                 || x.pers_id
                                                 || ' error_message '
                                                 || x.error_message);

            pc_log.log_error('ERROR_ENROLLMENT', 'acc_num '
                                                 || x.acc_num
                                                 || ' pv_mass_enrollment_id '
                                                 || pv_mass_enrollment_id);

        end loop;

        update mass_enrollments a
        set
            error_message = 'Error in Person Setup'
        where
            error_message is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and not exists (
                select
                    null
                from
                    person
                where
                    replace(ssn, '-') = a.ssn
            );

        -- Inserting into Insure
        insert into insure (
            pers_id,
            insur_id,
            plan_type,
            start_date,
            deductible,
            note
        )
            select
                b.pers_id,
                get_carrier_id(carrier)          carrier_id,
                nvl(
                    pc_lookups.get_plan_type_code(a.plan_type),
                    0
                )                                plan_type,
                format_to_date(a.effective_date) effective_date,
                nvl(deductible, 1200),
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments'))
            from
                mass_enrollments a,
                person           b
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and error_message is null
                and a.mass_enrollment_id = pv_mass_enrollment_id
                and not exists (
                    select
                        *
                    from
                        insure
                    where
                            pers_id = b.pers_id
                        and person_type = 'SUBSCRIBER'
                );

        update mass_enrollments a
        set
            error_message = 'Error in Health Plan Setup'
        where
            error_message is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and not exists (
                select
                    null
                from
                    person b,
                    insure c
                where
                    ( b.mass_enrollment_id = a.mass_enrollment_id
                      or b.ssn = format_ssn(a.ssn) )
                    and b.pers_id = c.pers_id
            );

        begin
            select
                a.entrp_id,
                a.broker_id,
                fee_setup
            into
                l_entrp_id,
                l_broker_id,
                l_fee_setup
            from
                account          a,
                mass_enrollments b
            where
                    a.acc_id = b.entrp_acc_id
                and mass_enrollment_id = pv_mass_enrollment_id;

        exception
            when others then
                null;
        end;
	-- Insertinto Account
        insert into account (
            acc_id,
            pers_id,
            entrp_id,
            acc_num,
            plan_code,
            start_date,
            end_date,
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
            salesrep_id,
            verified_by
        )
            select
                acc_seq.nextval,
                b.pers_id,
                null,
                pc_account.generate_acc_num(d.plan_code, b.state),
                d.plan_code,
                nvl(
                    greatest(
                        format_to_date(a.start_date),
                        format_to_date(a.effective_date)
                    ),
                    sysdate
                ),
                null,
                nvl(a.employer_amount, 0) + nvl(a.employee_amount, 0),
                nvl(
                    nvl(l_broker_id,
                        nvl((
                        select
                            broker_id
                        from
                            account
                        where
                            entrp_id = b.entrp_id
                    ), a.broker_id)),
                    0
                ),
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                nvl(
                    decode(b.entrp_id, null, null,(
                        select
                            fee_setup
                        from
                            account
                        where
                            entrp_id = b.entrp_id
                    )),
                    pc_plan.fsetup_paper(d.plan_code, b.entrp_id)
                ),
                d.fmonth,
                sysdate
	   /*  , CASE WHEN A.ACCOUNT_STATUS='Active' AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	               1
	       ELSE 3 END ACCOUNT_STATUS*/,
                3,
                decode(a.setup_status, 'Yes', 1, 'No', 0),
                decode(a.sign_on_file, null, 'N', 'Y'),
                format_to_date(a.start_date),
                nvl((
                    select
                        salesrep_id
                    from
                        account
                    where
                        entrp_id = a.entrp_id
                ),
                    pc_broker.get_salesrep_id(a.broker_id)),
                decode(a.created_by, 441, a.created_by, null)
            from
                mass_enrollments a,
                person           b,
                plan_fee_v       d
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and error_message is null
                and upper(d.plan_name) = upper(nvl(a.plan_code, 'Standard'))
                and a.mass_enrollment_id = pv_mass_enrollment_id
                and not exists (
                    select
                        *
                    from
                        person  c,
                        account b
                    where
                            replace(c.ssn, '-') = replace(a.ssn, '-')
                        and c.pers_id = b.pers_id
                        and b.account_type = 'HSA'
                );

        update person a
        set
            acc_numc = (
                select
                    reverse(acc_num)
                from
                    account
                where
                    a.pers_id = account.pers_id
            )
        where
            mass_enrollment_id in (
                select
                    mass_enrollment_id
                from
                    mass_enrollments
                where
                    mass_enrollment_id = pv_mass_enrollment_id
            );

        update mass_enrollments a
        set
            error_message = 'Error in Account Setup'
        where
            error_message is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and not exists (
                select
                    *
                from
                    person  c,
                    account b
                where
                        replace(c.ssn, '-') = replace(a.ssn, '-')
                    and c.pers_id = b.pers_id
                    and b.account_type = 'HSA'
            );

        insert into card_debit (
            card_id,
            start_date,
            emitent,
            note,
            status,
            max_card_value
        )
            select
                b.pers_id,
                nvl(
                    greatest(
                        format_to_date(a.start_date),
                        format_to_date(a.effective_date)
                    ),
                    sysdate
                ),
                6763 -- Evolution Benefits
                ,
                'Mass Enrollment',
                case
                    when pc_plan.can_create_card_on_pend(a.plan_code) = 'Y' then
                        1
                    else
                        9
                end,
                0
	 /*    , CASE WHEN A.ACCOUNT_STATUS='Active' AND A.SETUP_STATUS = 'Yes'
	       AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	             1
               ELSE
	             9
               END
             ,  CASE WHEN A.ACCOUNT_STATUS='Active' AND A.SETUP_STATUS = 'Yes'
	       AND NVL(to_date(A.EFFECTIVE_DATE,'MMDDRRRR'),SYSDATE) <= TRUNC(SYSDATE) THEN
	             NVL(A.EMPLOYER_AMOUNT,0)+NVL(A.EMPLOYEE_AMOUNT,0)
               ELSE
	            0
               END*/
            from
                mass_enrollments a,
                person           b
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and error_message is null
                and a.debit_card = 'Yes'
                and a.mass_enrollment_id = pv_mass_enrollment_id
                and exists (
                    select
                        *
                    from
                        enterprise
                    where
                            entrp_id = b.entrp_id
                        and nvl(card_allowed, 1) = 0
                )
                and not exists (
                    select
                        *
                    from
                        card_debit
                    where
                        card_id = b.pers_id
                );

        if sql%rowcount = 0 then
            insert into card_debit (
                card_id,
                start_date,
                emitent,
                note,
                status,
                max_card_value
            )
                select
                    b.pers_id,
                    nvl(
                        greatest(
                            format_to_date(a.start_date),
                            format_to_date(a.effective_date)
                        ),
                        sysdate
                    ),
                    6763 -- Evolution Benefits
                    ,
                    'Mass Enrollment',
                    case
                        when a.account_status = 'Active'
                             and a.setup_status = 'Yes'
                             and nvl(
                            format_to_date(a.effective_date),
                            sysdate
                        ) <= trunc(sysdate) then
                            1
                        else
                            case
                                when pc_plan.can_create_card_on_pend(a.plan_code) = 'Y' then
                                        1
                                else
                                    9
                            end
                    end,
                    case
                        when a.account_status = 'Active'
                             and a.setup_status = 'Yes'
                             and nvl(
                            format_to_date(a.effective_date),
                            sysdate
                        ) <= trunc(sysdate) then
                            nvl(a.employer_amount, 0) + nvl(a.employee_amount, 0)
                        else
                            0
                    end
                from
                    mass_enrollments a,
                    person           b
                where
                        a.mass_enrollment_id = b.mass_enrollment_id
                    and error_message is null
                    and a.debit_card = 'Yes'
                    and a.mass_enrollment_id = pv_mass_enrollment_id
                    and not exists (
                        select
                            *
                        from
                            card_debit
                        where
                            card_id = b.pers_id
                    );

        end if;

   /*     FOR X IN (SELECT B.PERS_ID
	          FROM  MASS_ENROLLMENTS A
		      , PERSON B
		      , CARD_DEBIT C
       	          WHERE A.MASS_ENROLLMENT_ID = B.MASS_ENROLLMENT_ID
       	          AND   ERROR_MESSAGE IS NULL
	          AND   A.DEBIT_CARD = 'Yes'
		  AND   A.MASS_ENROLLMENT_ID = pv_mass_enrollment_id
		  AND   B.PERS_ID = C.CARD_ID
		  AND   C.STATUS = 1)
        LOOP
             PC_FIN.CARD_OPEN_FEE(X.PERS_ID);
        END LOOP; */

       /* INSERT INTO INCOME (change_num
	                  , acc_id
			  , fee_date
			  , fee_code
			  , pay_code
			  , cc_number
			  , contributor_amount
			  , amount
			  , amount_add
			  , contributor
			  , note)
            SELECT CHANGE_SEQ.NEXTVAL
	         , C.ACC_ID
		 , NVL(GREATEST(TO_DATE(A.START_DATE,'MMDDRRRR'),to_date(A.EFFECTIVE_DATE,'MMDDRRRR')),SYSDATE)
		 , 3 -- Initial Contribution
		 , 1 -- Check
		 , A.CHECK_NUMBER
		 , NVL(A.CHECK_AMOUNT,(NVL(A.EMPLOYER_AMOUNT,0)+ NVL(A.EMPLOYEE_AMOUNT,0)))
		 , NVL(A.EMPLOYER_AMOUNT,0)
		 , NVL(A.EMPLOYEE_AMOUNT,0)
		 , B.ENTRP_ID
	      ,DECODE(SETUP_STATUS,'No','Note **** '||A.ERROR_MESSAGE|| '  '|| a.note ||' in Mass Enrollments ',NVL(a.NOTE,'Mass Enrollments'))
           FROM  MASS_ENROLLMENTS A
	       , PERSON B
	       , ACCOUNT C
           WHERE A.MASS_ENROLLMENT_ID = B.MASS_ENROLLMENT_ID
	   AND   ERROR_MESSAGE IS NULL
	   AND   B.PERS_ID = C.PERS_ID
	   AND   A.MASS_ENROLLMENT_ID = pv_mass_enrollment_id
	   AND NVL(A.EMPLOYER_AMOUNT,0)+ NVL(A.EMPLOYEE_AMOUNT,0) > 0;*/
        update mass_enrollments
        set
            error_message = 'Successfully Loaded',
            setup_status = 'Yes'
        where
            error_message is null
            and mass_enrollment_id = pv_mass_enrollment_id;

    exception
        when others then
            raise_application_error('-20001', 'Error in Processing Enrollments' || sqlerrm);
    end process_error_enrollments;

    procedure validate_error_dependants (
        pv_mass_enrollment_id in number
    ) is
    begin
        update mass_enroll_dependant
        set
            error_message = 'Gender Cannot have more than one character',
            error_column = 'GENDER'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and length(gender) > 1
            and error_message is null
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Middle Name Cannot have more than one character',
            error_column = 'MIDDLE_NAME'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and length(middle_name) > 1
            and error_message is null
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Enter Valid Birth Date',
            error_column = 'BIRTH_DATE'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and format_to_date(birth_date) is null
            and error_message is null
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Enter Valid Effective Date',
            error_column = 'EFFECTIVE_DATE'
        where
                mass_enrollment_id = pv_mass_enrollment_id
            and format_to_date(effective_date) is null
            and error_message is null
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'Subscriber SSN Cannot be Null',
            error_column = 'SUBSCRIBER_SSN'
        where
            subscriber_ssn is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null;

        update mass_enroll_dependant a
        set
            error_message = 'Cannot find Subscriber for this subscriber SSN ' || subscriber_ssn,
            error_column = 'SUBSCRIBER_SSN'
        where
            not exists (
                select
                    *
                from
                    person
                where
                    ssn = a.subscriber_ssn
            )
                and mass_enrollment_id = pv_mass_enrollment_id
                and error_message is null;

--     Validations
        update mass_enroll_dependant
        set
            error_message = 'Last Name Cannot be Null',
            error_column = 'LAST_NAME'
        where
            last_name is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'First Name Cannot be Null',
            error_column = 'LAST_NAME'
        where
            first_name is null
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null
            and dep_flag <> 'Beneficiary';

      /*
       UPDATE MASS_ENROLL_DEPENDANT a
       SET    ERROR_MESSAGE = 'Similar Dependant Seems to Exist for Subsriber with SSN '|| SUBSCRIBER_SSN||' under this Employer'
       WHERE  EXISTS ( SELECT *
                       FROM    PERSON,  PERSON B
		       WHERE   PERSON.PERS_ID = B.PERS_MAIN
		       AND     a.FIRST_NAME = b.FIRST_NAME
		       AND     a.LAST_NAME = b.LAST_NAME)
	      AND   MASS_ENROLLMENT_ID = pv_mass_enrollment_id
        AND   ERROR_MESSAGE IS NULL
       AND    DEP_FLAG <> 'Beneficiary';*/

        update mass_enroll_dependant a
        set
            error_message = 'Duplicate SSN, Other persons exist with Same SSN, Search on the Subscriber to find the details',
            error_column = 'DUPLICATE'
        where
            exists (
                select
                    *
                from
                    person
                where
                    person.ssn = a.ssn
            )
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant a
        set
            error_message = 'Similar Beneficiary Seems to Exist for Subsriber with SSN '
                            || subscriber_ssn
                            || ' under this Employer'
        where
            exists (
                select
                    *
                from
                    person,
                    beneficiary b
                where
                        person.ssn = a.subscriber_ssn
                    and person.pers_id = b.pers_id
                    and a.first_name
                        || ' '
                        || a.last_name like '%'
                                            || b.beneficiary_name
                                            || '%'
            )
            and mass_enrollment_id = pv_mass_enrollment_id
            and error_message is null
            and dep_flag = 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'The Birth Date must be between 01011900 and Current Date',
            error_column = 'BIRTH_DATE'
        where
            format_to_date(birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate
            and mass_enrollment_id = pv_mass_enrollment_id
            and birth_date is not null
            and error_message is null
            and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'SSN must be in the format of 999999999',
            error_column = 'SSN'
        where
            not regexp_like ( replace(ssn, '-'),
                              '^[[:digit:]]{9}$' )
                and mass_enrollment_id = pv_mass_enrollment_id
                and ssn is not null
                and error_message is null
                and dep_flag <> 'Beneficiary';

        update mass_enroll_dependant
        set
            error_message = 'The Effective Date of Beneficiary must be between 01011900 and '
                            || to_char(sysdate + 120, 'MM/DD/YYYY'),
            error_column = 'EFFECTIVE_DATE'
        where
            format_to_date(effective_date) not between to_date('01011900', 'MMDDYYYY') and sysdate + 120
            and mass_enrollment_id = pv_mass_enrollment_id
            and effective_date is not null
            and error_message is null
            and dep_flag = 'Beneficiary';

        commit;
    end validate_error_dependants;

    procedure process_error_dependants (
        pv_mass_enrollment_id in number
    ) is
        l_entrp_id  number;
        l_broker_id number;
        l_fee_setup number;
    begin
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
            mass_enrollment_id
        )
            select
                pers_seq.nextval,
                a.first_name,
                a.middle_name,
                a.last_name,
                format_to_date(a.birth_date),
                decode(a.gender, 'Male', 'M', 'Female', 'F',
                       a.gender),
                decode(
                    instr(a.ssn, '-', 1),
                    0,
                    substr(a.ssn, 1, 3)
                    || '-'
                    || substr(a.ssn, 4, 2)
                    || '-'
                    || substr(a.ssn, 6, 9),
                    a.ssn
                ),
                decode(a.relative, 'Spouse', 2, 'Child', 3,
                       4),
                'Mass Enrollments ',
                b.pers_id,
                'DEPENDANT',
                a.mass_enrollment_id
            from
                mass_enroll_dependant a,
                person                b
            where
                error_message is null
                and a.mass_enrollment_id = pv_mass_enrollment_id
                and a.subscriber_ssn = b.ssn
                and dep_flag in ( 'Dependant', 'Dependent' );

	/*UPDATE MASS_ENROLL_DEPENDANT A
	SET    ERROR_MESSAGE = 'Error in Person Setup'
	WHERE  ERROR_MESSAGE IS NULL
	AND    A.MASS_ENROLLMENT_ID = pv_mass_enrollment_id
	AND    NOT EXISTS ( SELECT NULL FROM PERSON WHERE MASS_ENROLLMENT_ID = A.MASS_ENROLLMENT_ID)
	AND    DEP_FLAG = 'Dependant';*/

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
        )
            select
                beneficiary_seq.nextval,
                a.first_name
                || ' '
                || a.last_name,
                (
                    select
                        lookup_code
                    from
                        lookups
                    where
                            lookup_name = 'BENEFICIARY_TYPE'
                        and upper(description) like upper(beneficiary_type)
                                                    || '%'
                ),
                nvl(beneficiary_relation, a.relative),
                format_to_date(a.effective_date),
                b.pers_id,
                sysdate,
                a.created_by,
                distiribution,
                'Mass Enrollments',
                a.mass_enrollment_id
            from
                mass_enroll_dependant a,
                person                b
            where
                error_message is null
                and a.mass_enrollment_id = pv_mass_enrollment_id
                and a.subscriber_ssn = b.ssn
                and ( dep_flag = 'Beneficiary'
                      or ( dep_flag in ( 'Dependant', 'Dependent' )
                           and beneficiary_type is not null
                           and distiribution is not null ) );

        update mass_enroll_dependant a
        set
            error_message = 'Error in beneficiary Setup'
        where
            error_message is null
            and a.mass_enrollment_id = pv_mass_enrollment_id
            and not exists (
                select
                    null
                from
                    beneficiary
                where
                    mass_enrollment_id = a.mass_enrollment_id
            )
            and ( dep_flag = 'Beneficiary'
                  or ( dep_flag in ( 'Dependant', 'Dependent' )
                       and beneficiary_type is not null
                       and distiribution is not null ) );

        update mass_enroll_dependant a
        set
            error_message = 'Successfully Loaded'
        where
            error_message is null
            and a.mass_enrollment_id = pv_mass_enrollment_id
            and exists (
                select
                    null
                from
                    person
                where
                    mass_enrollment_id = a.mass_enrollment_id
            )
            and dep_flag in ( 'Dependant', 'Dependent' );

        update mass_enroll_dependant a
        set
            error_message = 'Successfully Loaded'
        where
            error_message is null
            and a.mass_enrollment_id = pv_mass_enrollment_id
            and exists (
                select
                    null
                from
                    beneficiary
                where
                    mass_enrollment_id = a.mass_enrollment_id
            )
            and ( dep_flag = 'Beneficiary'
                  or ( dep_flag in ( 'Dependant', 'Dependent' )
                       and beneficiary_type is not null
                       and distiribution is not null ) );

        commit;
    exception
        when others then
            raise_application_error('-20001', 'Error in Processing Dependants ' || sqlerrm);
    end process_error_dependants;

    procedure process_existing_accounts (
        p_user_id      in number default 0,
        p_batch_number in number
    ) is
        l_user_id         number;
        l_per_id_char_tbl pc_online.varchar2_tbl;
        l_return_status   varchar2(1);
        l_return_msg      varchar2(4000);
    begin
        l_user_id := p_user_id;
        for x in (
            select
                b.first_name
                || decode(
                    length(b.middle_name),
                    1,
                    '',
                    ' ' || b.middle_name
                )                       first_name,
                b.last_name,
                decode(
                    length(b.middle_name),
                    1,
                    b.middle_name,
                    ''
                )                       middle_name,
                replace(a.ssn, '-')     ssn -- added by Jaggi
                ,
                b.address,
                b.city,
                upper(b.state)          state,
                substr(b.zip, 1, 5)     zip,
                decode(
                    instr(b.day_phone, '-', 1),
                    0,
                    substr(b.day_phone, 1, 3)
                    || '-'
                    || substr(b.day_phone, 4, 3)
                    || '-'
                    || substr(b.day_phone, 7, 10),
                    b.day_phone
                )                       day_phone,
                b.driver_license,
                b.passport,
                nvl(
                    format_to_date(b.start_date),
                    sysdate
                )                       start_date,
                (
                    select
                        plan_code
                    from
                        plan_fee_v
                    where
                        upper(plan_name) = upper(nvl(b.plan_code, 'Standard'))
                )                       plan_code,
                c.plan_code             acc_plan_code,
                b.debit_card,
                nvl((
                    select
                        entrp_id
                    from
                        enterprise
                    where
                            en_code = 3
                        and regexp_like(upper(name),
                                        '\'
                                        || upper(carrier)
                                        || '\')
                        and rownum = 1
                        and b.carrier is not null
                ),
                    4595)               carrier_id,
                nvl(
                    pc_lookups.get_plan_type_code(b.plan_type),
                    0
                )                       plan_type,
                nvl(
                    format_to_date(b.effective_date),
                    sysdate
                )                       effective_date,
                nvl(b.deductible, 1500) deductible,
                a.pers_id,
                reverse(a.acc_numc)     acc_num,
                c.account_status,
                c.acc_id,
                d.insur_id
            from
                person           a,
                mass_enrollments b,
                account          c,
                insure           d
            where
                    b.ssn = replace(a.ssn, '-')
                and b.batch_number = p_batch_number
                and a.person_type = 'SUBSCRIBER'
                and c.pers_id = a.pers_id
                and d.pers_id = a.pers_id
                and d.end_date is null
                and b.termination_date is null  -- added by Joshi for 8634
                and b.action = 'C'
        )            -- added by Joshi for 8634
         loop
            if x.account_status <> 4 then
                update person
                set   -- FIRST_NAME  = NVL(X.FIRST_NAME,FIRST_NAME) (commented as per shavee request 8364)
                    last_name = nvl(x.last_name, last_name),
                    middle_name = nvl(x.middle_name, middle_name),
                    address = nvl(x.address, address),
                    city = nvl(x.city, city),
                    state = nvl(x.state, state),
                    zip = nvl(x.zip, zip),
                    phone_day = nvl(x.day_phone, phone_day),
                    drivlic = nvl(x.driver_license, drivlic),
                    passport = nvl(x.passport, passport),
                    last_update_date = sysdate,
                    last_updated_by = l_user_id
                where
                    pers_id = x.pers_id;

        -- 9670 and 9894 added by jaggi
                update mass_enrollments
                set
                    pers_id = x.pers_id,
                    acc_num = x.acc_num,
                    acc_id = x.acc_id
                where
                        batch_number = p_batch_number
                    and ssn = replace(x.ssn, '-');
        -- code end here --
/*
       IF X.ACC_PLAN_CODE <> X.PLAN_CODE THEN
          PC_ACCOUNT.CHANGE_PLAN(X.ACC_ID,SYSDATE,X.PLAN_CODE,'Changed via Benetrac');
       END IF;
*/
                if x.insur_id <> x.carrier_id then
                    update insure
                    set
                        end_date = sysdate,
                        note = 'End dating current carrier '
                    where
                            pers_id = x.pers_id
                        and insur_id = x.insur_id;

                    update insure
                    set
                        insur_id = x.carrier_id,
                        deductible = decode(x.deductible,
                                            0,
                                            deductible,
                                            nvl(x.deductible, deductible)),
                        plan_type = nvl(x.plan_type, plan_type),
                        start_date = nvl(x.effective_date, start_date),
                        note = 'End dating current carrier '
                    where
                            pers_id = x.pers_id
                        and insur_id = x.insur_id;

                end if;

                insert into card_debit (
                    card_id,
                    start_date,
                    emitent,
                    note,
                    status,
                    max_card_value
                )
                    select
                        pers_id,
                        case
                            when x.effective_date > trunc(sysdate) then
                                x.effective_date
                            when x.start_date > trunc(sysdate)     then
                                x.start_date
                            else
                                sysdate
                        end,
                        6763 -- Evolution Benefits
                        ,
                        'Benetrac Enrollment',
                        case
                            when pc_plan.can_create_card_on_pend(x.plan_code) = 'Y' then
                                1
                            else
                                9
                        end,
                        0
                    from
                        person b
                    where
                            b.pers_id = x.pers_id
                        and x.debit_card = 'Yes'
                        and exists (
                            select
                                *
                            from
                                enterprise
                            where
                                    entrp_id = b.entrp_id
                                and nvl(card_allowed, 1) = 0
                        )
                        and not exists (
                            select
                                *
                            from
                                card_debit
                            where
                                card_id = b.pers_id
                        );

            end if;
        end loop;

-- Added by Joshi for 8634 on 04/12/2020
-- Swamy Ticket#11508 During Termination, only HSA accounts should get disassociated with the employer
        select
            to_char(a.pers_id)
        bulk collect
        into l_per_id_char_tbl
        from
            person           a,
            mass_enrollments b,
            account          c
        where
                b.ssn = replace(a.ssn, '-')
            and b.batch_number = p_batch_number
            and a.person_type = 'SUBSCRIBER'
            and c.pers_id = a.pers_id
            and c.account_type = 'HSA'   -- Added By swamy for Production Issue Ticket#11508 23/03/23
            and b.termination_date is not null;

        pc_log.log_error('l_per_id_char_tbl.count: ', l_per_id_char_tbl.count);
        if l_per_id_char_tbl.count > 0 then
      --l_per_id_char_tbl := PC_ONLINE_ENROLLMENT.array_fill(l_per_tbl, l_per_tbl.COUNT);
            pc_online.terminate_employee(l_per_id_char_tbl, p_user_id, l_return_status, l_return_msg);
        end if;

-- end 8634.
    exception
        when others then
    -- RAISE_APPLICATION_ERROR('-20001','Error in Processing Dependants '||SQLERRM);
            pc_log.log_error('process_existing_accounts SQLERRM ', sqlerrm);
    end process_existing_accounts;

    procedure process_existing_dependant (
        p_user_id      in number default 0,
        p_batch_number in number
    ) is
        l_user_id number;
    begin
        l_user_id := p_user_id;
        for x in (
            select
                b.first_name
                || decode(
                    length(b.middle_name),
                    1,
                    '',
                    b.middle_name
                )                            first_name,
                b.last_name,
                decode(
                    length(b.middle_name),
                    1,
                    b.middle_name,
                    ''
                )                            middle_name,
                format_to_date(b.birth_date) birth_date,
                decode(b.relative, 'Spouse', 2, 'Child', 3,
                       4)                    relative,
                a.pers_id
            from
                person                a,
                mass_enroll_dependant b,
                person                c
            where
                    a.ssn = format_ssn(b.ssn)
                and b.batch_number = p_batch_number
                and a.pers_main = c.pers_id
                and c.ssn = format_ssn(b.subscriber_ssn)
                and dep_flag in ( 'Dependant', 'Dependent' )
        ) loop
            update person
            set
                first_name = x.first_name,
                last_name = x.last_name,
                middle_name = x.middle_name,
                birth_date = x.birth_date,
                relat_code = x.relative,
                last_update_date = sysdate,
                last_updated_by = l_user_id
            where
                pers_id = x.pers_id;

        end loop;

    end process_existing_dependant;

    procedure process_hra_enrollment (
        pv_file_name in varchar2,
        p_user_id    in number
    ) is
        l_batch_number number;
    begin
        export_hra_enrollment(pv_file_name, p_user_id, l_batch_number);
        validate_hra_enrollments(p_user_id, l_batch_number);
        process_existing_hfsa(p_user_id, l_batch_number);
        process_hra_enrollments(p_user_id, l_batch_number);
        commit;
    end process_hra_enrollment;

-- FSA Enrollment Begin

    procedure process_fsa_enrollment (
        pv_file_name in varchar2,
        p_user_id    in number
    ) is
        l_batch_number number;
        lv_dest_file   varchar2(255);
    begin
        export_fsa_enrollment(pv_file_name, p_user_id, l_batch_number);
        validate_fsa_enrollments(p_user_id, l_batch_number);
        process_existing_hfsa(p_user_id, l_batch_number);
        process_fsa_enrollments(p_user_id, l_batch_number);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        for x in (
            select distinct
                group_number
            from
                mass_enrollments
            where
                batch_number = l_batch_number
        ) loop
            pc_file_upload.export_csv_file(lv_dest_file, x.group_number, 'MANUAL_UPLOAD');
        end loop;

        write_hrafsa_audit_file(l_batch_number, pv_file_name);
        commit;
    end process_fsa_enrollment;

    procedure export_fsa_enrollment (
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
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_sqlerrm       varchar2(32000);
        l_create_error exception;
        l_batch_number  number;
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
    begin
        x_batch_number := batch_num_seq.nextval;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

           /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', pv_file_name, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            l_create_ddl := 'ALTER TABLE FSA_ENROLLMENTS_EXTERNAL ACCESS PARAMETERS ('
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
                            || '  LOCATION (ENROLL_DIR:'''
                            || lv_dest_file
                            || ''')';

            execute immediate l_create_ddl;
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of fsa enrollments file' || sqlerrm;
                pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
                l_files.delete;
                l_files.extend(3);
                l_files(1) := '/u01/app/oracle/oradata/enroll/' || lv_dest_file;
                l_files(2) := '/u01/app/oracle/oradata/enroll/'
                              || lv_dest_file
                              || '.bad';
                l_files(3) := '/u01/app/oracle/oradata/enroll/' || l_log_file_name;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
                    to_names     => 'techsupport@sterlingadministration.com',
                    subject      => 'Error in FSA Enrollment file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );

                raise l_create_error;
        end;

        delete from mass_enrollments
        where
            ssn in (
                select
                    case
                        when length(ssn) < 9 then
                            lpad(ssn, 9, '0')
                        else
                            ssn
                    end ssn
                from
                    fsa_enrollments_external a
            )
            and account_type = 'FSA';

        insert into mass_enrollments (
            mass_enrollment_id,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            issue_conditional,
            broker_id,
            error_message,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            account_type,
            health_fsa_flag,
            hfsa_effective_date,
            hfsa_annual_election,
            dep_fsa_flag,
            dfsa_effective_date,
            dfsa_annual_election,
            transit_fsa_flag,
            transit_effective_date,
            transit_annual_election,
            parking_fsa_flag,
            parking_effective_date,
            parking_annual_election,
            bicycle_effective_date,
            bicycle_fsa_flag,
            bicycle_annual_election,
            post_ded_fsa_flag,
            post_ded_effective_date,
            post_ded_annual_election,
            annual_election,
            effective_date,
            hra_fsa_flag,
            batch_number,
            division_code,
            coverage_tier_name,
            acc_num
        )
            select
                mass_enrollments_seq.nextval,
                first_name,
                substr(middle_name, 1, 1),
                last_name,
                initcap(gender),
                initcap(address),
                initcap(city),
                state,
                case
                    when length(zip) < 5 then
                        lpad(zip, 5, '0')
                    else
                        zip
                end,
                null,
                day_phone,
                null,
                email_address,
                format_date(birth_date)               birth_date,
                case
                    when length(ssn) < 9 then
                        lpad(ssn, 9, '0')
                    else
                        ssn
                end                                   ssn,
                debit_card,
                'FSA',
                to_char(sysdate, 'MMDDRRRR')          start_date --format_date(START_DATE) START_DATE
                ,
                null,
                'Active',
                'Yes',
                initcap(nvl(conditional_issue, 'Yes')),
                broker_number,
                null,
                note,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                null,
                pc_entrp.get_entrp_id(a.group_number) entrp_id,
                a.group_number,
                'FSA',
                upper(health_fsa_flag),
                format_date(hfsa_effective_date)      hfsa_effective_date,
                hfsa_annual_election,
                upper(dep_fsa_flag),
                format_date(dfsa_effective_date)      dfsa_effective_date,
                dfsa_annual_election,
                upper(transit_fsa_flag),
                format_date(transit_effective_date)   transit_effective_date,
                transit_annual_election,
                upper(parking_fsa_flag),
                format_date(parking_effective_date)   parking_effective_date,
                parking_annual_election,
                format_date(bicycle_effective_date)   bicycle_effective_date,
                upper(bicycle_fsa_flag),
                bicycle_annual_election,
                upper(post_ded_fsa_flag),
                format_date(post_ded_effective_date)  post_ded_effective_date,
                post_ded_annual_election,
                hra_annual_election,
                format_date(hra_effective_date)       hra_effective_date,
                upper(hra_fsa_flag),
                x_batch_number,
                upper(division_code)                  division_code,
                coverage_tier_name,
                acc_num
            from
                fsa_enrollments_external a
            where
                ( first_name is not null
                  or ssn is not null )/*
       AND   NOT EXISTS ( SELECT * FROM MASS_ENROLLMENTS WHERE SSN = A.SSN
                         AND ACCOUNT_TYPE= 'FSA')
       AND      not exists (  SELECT  *
                            FROM   PERSON c, ACCOUNT B
                           WHERE   REPLACE(c.SSN,'-') =REPLACE(a.SSN,'-')
                           AND     c.PERS_ID = B.PERS_ID
                           AND     B.ACCOUNT_TYPE = 'FSA')*/;

        for x in (
            select
                a.mass_enrollment_id,
                c.pers_id,
                d.acc_num,
                d.acc_id
            from
                mass_enrollments a,
                account          b,
                person           c,
                account          d
            where
                    a.batch_number = x_batch_number
                and a.error_message is null
                and rtrim(
                    ltrim(a.group_number, ' '),
                    ' '
                ) = b.acc_num
                and b.account_type in ( 'HRA', 'FSA' )
                and ( a.ssn is not null
                      and replace(c.ssn, '-') = replace(a.ssn, '-')
                      or a.acc_num = d.acc_num )
                and c.pers_id = d.pers_id
                and b.entrp_id = c.entrp_id
                and b.account_type in ( 'HRA', 'FSA' )
        ) loop
            update mass_enrollments
            set
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                mass_enrollment_id = x.mass_enrollment_id;

        end loop;

        commit;
    exception
        when l_create_error then
            raise_application_error('-20001', 'Error in Exporting File ' || l_sqlerrm);
        when others then
            rollback;

-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

-- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_fsa_enrollment;

    procedure validate_fsa_enrollments (
        p_user_id      in number,
        p_batch_number in number
    ) is
    begin
        pc_log.log_error('validate_fsa_enrollments', 'In validate');
        update mass_enrollments
        set
            error_message = 'Enter Valid Birth Date',
            error_column = 'BIRTH_DATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and format_to_date(birth_date) is null
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Birth Date Required , Enter Birth Date',
            error_column = 'BIRTH_DATE'
        where
                batch_number = p_batch_number
            and birth_date is null
            and account_type = 'FSA'
            and format_to_date(birth_date) is null
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = ' Enter Group Number of Employer',
            error_column = 'GROUP_NUMBER'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and group_number is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = ' Verify Group Number of Employer, Cannot find match in SAM',
            error_column = 'GROUP_NUMBER'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and entrp_id is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Cannot Enroll, BPS Plan information is not setup',
            error_column = 'GROUP_NUMBER'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and entrp_id is not null
            and not exists (
                select
                    *
                from
                    ben_plan_enrollment_setup a,
                    account                   b
                where
                        a.acc_id = b.acc_id
                    and b.account_type = 'FSA'
                    and mass_enrollments.entrp_id = b.entrp_id
                    and ( a.status = 'A'
                          or ( a.plan_start_date <= trunc(sysdate)
                               and a.plan_end_date >= trunc(sysdate) ) )
            )
            and error_message is null;

        for x in (
            select
                a.*,
                c.mass_enrollment_id
            from
                ben_plan_enrollment_setup a,
                account                   b,
                mass_enrollments          c
            where
                    c.batch_number = p_batch_number
                and a.acc_id = b.acc_id
                and b.account_type = 'FSA'
                and c.account_type = 'FSA'
                and c.error_message is null
                and c.entrp_id = b.entrp_id
                and ( a.status = 'A'
                      or ( a.plan_start_date <= trunc(sysdate)
                           and a.plan_end_date >= trunc(sysdate) ) )
        ) loop
            if x.plan_type is null
               or x.ben_plan_name is null then
                update mass_enrollments
                set
                    error_message = 'Benefit Plan Type is Incomplete, Set it up for Employer',
                    error_column = 'GROUP_NUMBER'
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and account_type = 'FSA'
                    and mass_enrollment_id = x.mass_enrollment_id
                    and error_message is null;

            end if;
        end loop;

        for x in (
            select
                a.*,
                c.mass_enrollment_id
            from
                ben_plan_enrollment_setup a,
                account                   b,
                mass_enrollments          c
            where
                    c.batch_number = p_batch_number
                and a.acc_id = b.acc_id
                and b.account_type = 'FSA'
                and c.account_type = 'FSA'
                and c.error_message is null
                and c.entrp_id = b.entrp_id
                and ( a.status = 'A'
                      or ( a.plan_start_date <= trunc(sysdate)
                           and a.plan_end_date >= trunc(sysdate) ) )
        ) loop
            if x.plan_type is null
               or x.ben_plan_name is null then
                update mass_enrollments
                set
                    error_message = 'Benefit Plan Type is Incomplete, Set it up for Employer',
                    error_column = 'GROUP_NUMBER'
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and account_type = 'FSA'
                    and mass_enrollment_id = x.mass_enrollment_id
                    and error_message is null;

            end if;
        end loop;

        for x in (
            select
                ssn,
                entrp_id,
                plan_type
            from
                fsa_uploaded_plan_types_v
        ) loop
            for xx in (
                select
                    count(*) cnt
                from
                    ben_plan_enrollment_setup a,
                    account                   b
                where
                        a.acc_id = b.acc_id
                    and b.account_type = 'FSA'
                    and a.plan_type = x.plan_type
                    and b.entrp_id = x.entrp_id
                    and ( a.status = 'A'
                          or ( a.status <> 'R'
                               and a.plan_start_date <= trunc(sysdate)
                               and a.plan_end_date >= trunc(sysdate) ) )
            ) loop
                pc_log.log_error('PROCESS_UPLOAD:FSA', 'Plan Type Found or not '
                                                       || x.plan_type
                                                       || ' '
                                                       || 'entrp_id '
                                                       || x.entrp_id
                                                       || ' '
                                                       || xx.cnt);

                if xx.cnt = 0 then
                    update mass_enrollments
                    set
                        error_message = 'Benefit Plan Type is not setup for plan type '
                                        || x.plan_type
                                        || ', Set it up for Employer',
                        error_column = 'GROUP_NUMBER'
                    where
                            batch_number = p_batch_number
                        and trunc(creation_date) = trunc(sysdate)
                        and account_type = 'FSA'
                        and ssn = x.ssn
                        and entrp_id = x.entrp_id
                        and error_message is null;

                end if;

            end loop;
        end loop;

        update mass_enrollments
        set
            error_message = 'Birth Date Required , Enter Birth Date',
            error_column = 'BIRTH_DATE'
        where
                batch_number = p_batch_number
            and birth_date is null
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Gender Cannot be Null',
            error_column = 'GENDER'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and gender is null
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Gender Cannot have more than one character',
            error_column = 'GENDER'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and length(gender) > 1
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Health FSA Annual Election must be numeric value ',
            error_column = 'HFSA_ANNUAL_ELECTION'
        where
                batch_number = p_batch_number
            and hfsa_annual_election is not null
            and account_type = 'FSA'
            and is_number(hfsa_annual_election) = 'N'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Dependent FSA Annual Election must be numeric value ',
            error_column = 'DFSA_ANNUAL_ELECTION'
        where
                batch_number = p_batch_number
            and dfsa_annual_election is not null
            and account_type = 'FSA'
            and is_number(dfsa_annual_election) = 'N'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Transit FSA Annual Election must be numeric value ',
            error_column = 'TRANSIT_ANNUAL_ELECTION'
        where
                batch_number = p_batch_number
            and transit_annual_election is not null
            and account_type = 'FSA'
            and is_number(transit_annual_election) = 'N'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Parking FSA Annual Election must be numeric value ',
            error_column = 'PARKING_ANNUAL_ELECTION'
        where
                batch_number = p_batch_number
            and parking_annual_election is not null
            and account_type = 'FSA'
            and is_number(parking_annual_election) = 'N'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Bicycke FSA Annual Election must be numeric value ',
            error_column = 'BICYCLE_ANNUAL_ELECTION'
        where
                batch_number = p_batch_number
            and bicycle_annual_election is not null
            and is_number(bicycle_annual_election) = 'N'
            and account_type = 'FSA'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Post Deductible FSA Annual Election must be numeric value ',
            error_column = 'POST_DED_ANNUAL_ELECTION'
        where
                batch_number = p_batch_number
            and post_ded_annual_election is not null
            and is_number(post_ded_annual_election) = 'N'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Middle Name Cannot have more than one character',
            error_column = 'MIDDLE_NAME'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and length(middle_name) > 1
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'State Cannot have more than two character',
            error_column = 'STATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and length(state) > 2
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Health FSA Effective Date',
            error_column = 'HFSA_EFFECTIVE_DATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and format_to_date(hfsa_effective_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Dependent FSA Effective Date',
            error_column = 'DFSA_EFFECTIVE_DATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and format_to_date(dfsa_effective_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Transit Effective Date',
            error_column = 'TRANSIT_EFFECTIVE_DATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and format_to_date(transit_effective_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Parking Effective Date',
            error_column = 'PARKING_EFFECTIVE_DATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and format_to_date(parking_effective_date) is null
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Bicycle Effective Date',
            error_column = 'BICYCLE_EFFECTIVE_DATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and format_to_date(bicycle_effective_date) is null
            and account_type = 'FSA'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Enter Valid Post Deductible Effective Date',
            error_column = 'POST_DED_EFFECTIVE_DATE'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and format_to_date(post_ded_effective_date) is null
            and account_type = 'FSA'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'You have elected Dependent FSA Plan, Enter value for Dependent FSA Annual Election/Effective Date',
            error_column = 'DEP_FSA_FLAG'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and dep_fsa_flag = 'YES'
            and ( dfsa_annual_election is null
                  or dfsa_annual_election is null )
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'You have elected Healthcare FSA Plan, Enter value for Annual Election/Effective Date',
            error_column = 'HEALTH_FSA_FLAG'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and health_fsa_flag = 'YES'
            and ( hfsa_annual_election is null
                  or hfsa_effective_date is null )
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'You have elected Transit FSA Plan, Enter value for Annual Election/Effective Date',
            error_column = 'TRANSIT_FSA_FLAG'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and ( transit_effective_date is null
                  or transit_annual_election is null )
            and transit_fsa_flag = 'YES'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'You have elected Parking FSA Plan, Enter value for  Annual Election/Effective Date',
            error_column = 'PARKING_FSA_FLAG'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and parking_fsa_flag = 'YES'
            and ( parking_effective_date is null
                  or parking_annual_election is null )
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'You have elected Bicycle FSA Plan, Enter value for  Annual Election/Effective Date',
            error_column = 'BICYCLE_FSA_FLAG'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and ( bicycle_effective_date is null
                  or bicycle_annual_election is null )
            and bicycle_fsa_flag = 'YES'
            and account_type = 'FSA'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'You have elected Post Deductible FSA Plan, Enter value for Bicycle Annual Election/Effective Date',
            error_column = 'POST_DED_FSA_FLAG'
        where
                batch_number = p_batch_number
            and trunc(creation_date) = trunc(sysdate)
            and ( post_ded_annual_election is null
                  or post_ded_effective_date is null )
            and post_ded_fsa_flag = 'YES'
            and account_type = 'FSA'
            and error_message is null;

     /*  UPDATE MASS_ENROLLMENTS
       SET   ERROR_MESSAGE = 'In order to elect Post Deductible FSA Plan, You need to be have Health Savings Account '
            , ERROR_COLUMN  = 'POST_DED_FSA_FLAG'
       WHERE   TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
       AND    POST_DED_FSA_FLAG ='YES'
       AND    NOT EXISTS ( SELECT * FROM PERSON A, ACCOUNT B
                          WHERE A.PERS_ID = B.PERS_ID
                          AND   MASS_ENROLLMENTS.SSN  = REPLACE(A.SSN,'-')
                          AND   B.ACCOUNT_TYPE= 'HSA')
       AND    ACCOUNT_TYPE  = 'FSA'
       AND    ERROR_MESSAGE IS NULL;

        UPDATE MASS_ENROLLMENTS
       SET   ERROR_MESSAGE = 'You cannot have Health care FSA and Post Deductible FSA '
            , ERROR_COLUMN  = 'POST_DED_FSA_FLAG'
       WHERE  TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
       AND    POST_DED_FSA_FLAG ='YES'
       AND    HEALTH_FSA_FLAG = 'YES'
       AND    ACCOUNT_TYPE  = 'FSA'
       AND    ERROR_MESSAGE IS NULL; */
--     Validations
        update mass_enrollments
        set
            error_message = 'Last Name Cannot be Null',
            error_column = 'LAST_NAME'
        where
                batch_number = p_batch_number
            and last_name is null
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'First Name Cannot be Null',
            error_column = 'FIRST_NAME'
        where
                batch_number = p_batch_number
            and first_name is null
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

    /*   UPDATE MASS_ENROLLMENTS
       SET    ERROR_MESSAGE = 'Similar Subscriber Seems to Exist for this Employer'
       WHERE  EXISTS ( SELECT *
                       FROM    PERSON, ENTERPRISE, ACCOUNT
                       WHERE   PERSON.entrp_id = ENTERPRISE.ENTRP_ID
                       AND     ACCOUNT.ENTRP_ID = ENTERPRISE.ENTRP_ID
                       AND     ACCOUNT.ACC_ID = MASS_ENROLLMENTS.ENTRP_ACC_ID
                       AND     PERSON.ENTRP_ID = MASS_ENROLLMENTS.ENTRP_ID
                       AND     PERSON.FIRST_NAME = MASS_ENROLLMENTS.FIRST_NAME
                       AND     PERSON.LAST_NAME = MASS_ENROLLMENTS.LAST_NAME
                       AND     PERSON_TYPE = 'SUBSCRIBER'
                       AND     ACCOUNT_TYPE = 'FSA')
       AND     BATCH_NUMBER = p_batch_number
       AND    TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
       AND    ACCOUNT_TYPE  = 'FSA'
       AND   ERROR_MESSAGE IS NULL;*/

        update mass_enrollments
        set
            error_message = 'Address Cannot be Null',
            error_column = 'ADDRESS'
        where
                batch_number = p_batch_number
            and address is null
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'City Cannot be Null',
            error_column = 'CITY'
        where
                batch_number = p_batch_number
            and city is null
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'State Cannot be Null',
            error_column = 'STATE'
        where
                batch_number = p_batch_number
            and state is null
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Zip Cannot be Null',
            error_column = 'ZIP'
        where
                batch_number = p_batch_number
            and zip is null
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Social Security Number Cannot be Null',
            error_column = 'SSN'
        where
                batch_number = p_batch_number
            and ssn is null
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

     /*  UPDATE MASS_ENROLLMENTS a
       SET    ERROR_MESSAGE = 'Duplicate SSN, Other Subscribers exist with Same SSN, Search on the Subscriber to find the details'
           ,  ERROR_COLUMN  = 'DUPLICATE'
       WHERE   BATCH_NUMBER = p_batch_number
       AND   PC_ACCOUNT.CHECK_DUPLICATE(A.SSN, A.GROUP_NUMBER,NULL,'FSA',A.ENTRP_ID) = 'Y'
       AND     TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
       AND    ACCOUNT_TYPE  = 'FSA'
        AND    ERROR_MESSAGE IS NULL;*/

        update mass_enrollments
        set
            error_message = 'ZIP code must be in the form 99999',
            error_column = 'ZIP'
        where
                batch_number = p_batch_number
            and ( length(zip) > 5
                  or not regexp_like ( zip,
                                       '^[[:digit:]]+$' ) )
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'The Birth Date must be between 01011900 and Current Date',
            error_column = 'BIRTH_DATE'
        where
                batch_number = p_batch_number
            and format_to_date(birth_date) not between to_date('01011900', 'MMDDRRRR') and sysdate
            and trunc(creation_date) = trunc(sysdate)
            and account_type = 'FSA'
            and error_message is null
            and pers_id is null;

        update mass_enrollments
        set
            error_message = 'Broker Number must be entered',
            error_column = 'BROKER_NUMBER'
        where
                batch_number = p_batch_number
            and is_number(broker_id) = 'N'
            and account_type = 'FSA'
            and error_message is null;

        update mass_enrollments
        set
            error_message = 'Division code is not setup',
            error_column = 'DIVISION_CODE'
        where
                pc_employer_divisions.get_division_count(entrp_id,
                                                         upper(division_code)) = 0
            and batch_number = p_batch_number
            and error_message is null
            and division_code is not null;

     --  COMMIT;
    exception
        when others then
            raise_application_error('-20002', 'Error in Validation ' || sqlerrm);
    end validate_fsa_enrollments;

    procedure process_fsa_enrollments (
        pv_user_id     in number,
        p_batch_number in number
    ) is

        l_entrp_id      number;
        l_broker_id     number;
        l_fee_setup     number;
        l_count         number;
        l_pers_id_tbl   number_table := number_table();
        l_return_status varchar2(30);
        l_error_message varchar2(3200);
    begin
        insert into person (
            pers_id,
            first_name,
            middle_name,
            last_name,
            birth_date,
            title,
            gender,
            ssn,
            address,
            city,
            state,
            zip,
            mailmet,
            phone_day,
            phone_even,
            email,
            relat_code,
            note,
            entrp_id,
            person_type,
            mass_enrollment_id,
            creation_date,
            created_by,
            division_code
        )
            select
                pers_seq.nextval,
                rtrim(ltrim(first_name)),
                rtrim(ltrim(middle_name)),
                rtrim(ltrim(last_name)),
                format_to_date(birth_date),
                title,
                decode(
                    initcap(gender),
                    'Male',
                    'M',
                    'Female',
                    'F',
                    upper(gender)
                ),
                decode(
                    instr(ssn, '-', 1),
                    0,
                    substr(ssn, 1, 3)
                    || '-'
                    || substr(ssn, 4, 2)
                    || '-'
                    || substr(ssn, 6, 9),
                    ssn
                ),
                rtrim(ltrim(address)),
                rtrim(ltrim(city)),
                upper(state),
                substr(zip, 1, 5),
                (
                    select
                        lookup_code
                    from
                        lookups
                    where
                            lookup_name = 'MAIL_TYPE'
                        and upper(description) like upper(contact_method)
                                                    || '%'
                        and contact_method is not null
                ),
                decode(
                    instr(day_phone, '-', 1),
                    0,
                    substr(day_phone, 1, 3)
                    || '-'
                    || substr(day_phone, 4, 3)
                    || '-'
                    || substr(day_phone, 7, 10),
                    day_phone
                ) day_phone,
                evening_phone,
                rtrim(ltrim(email_address)),
                1,
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                b.entrp_id,
                'SUBSCRIBER',
                mass_enrollment_id,
                sysdate,
                a.created_by,
                upper(a.division_code)
            from
                mass_enrollments a,
                account          b
            where
                error_message is null
                and a.batch_number = p_batch_number
                and rtrim(
                    ltrim(a.group_number, ' '),
                    ' '
                ) = b.acc_num
                and b.account_type = 'FSA'
                and not exists (
                    select
                        *
                    from
                        person  c,
                        account b
                    where
                            replace(c.ssn, '-') = replace(a.ssn, '-')
                        and c.pers_id = b.pers_id
                        and a.entrp_id = c.entrp_id
                        and b.account_type = 'FSA'
                );

        for x in (
            select
                c.pers_id,
                a.mass_enrollment_id
            from
                fsa_enrollments_external fsa,
                person                   c,
                mass_enrollments         a
            where
                error_message is null
                and a.batch_number = p_batch_number
                and replace(a.ssn, '-') = replace(
                    lpad(fsa.ssn, 9, '0'),
                    '-'
                )
                and a.mass_enrollment_id = c.mass_enrollment_id
        ) loop
            update mass_enrollments a
            set
                pers_id = x.pers_id
            where
                mass_enrollment_id = x.mass_enrollment_id;

            l_pers_id_tbl.extend;
            l_pers_id_tbl(l_pers_id_tbl.count) := x.pers_id;
        end loop;

        update mass_enrollments a
        set
            error_message = 'Error in Person Setup'
        where
            error_message is null
            and a.batch_number = p_batch_number
            and a.account_type = 'FSA'
            and not exists (
                select
                    *
                from
                    person c
                where
                    replace(c.ssn, '-') = replace(a.ssn, '-')
            );

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
            hsa_effective_date,
            account_type,
            annual_election,
            bps_hra_plan,
            salesrep_id,
            enrollment_source
        )
            select
                acc_seq.nextval,
                b.pers_id,
                null,
                'FSA' || online_enroll_seq.nextval,
                d.plan_code,
                nvl(
                    format_to_date(a.start_date),
                    d.start_date
                ),
                0,
                nvl(a.broker_id, 0),
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                d.fee_setup,
                d.fee_maint,
                sysdate,
                1,
                1,
                'Y',
                null,
                a.account_type,
                a.annual_election,
                a.bps_hra_plan,
                nvl((
                    select
                        salesrep_id
                    from
                        account
                    where
                        entrp_id = a.entrp_id
                ),
                    pc_broker.get_salesrep_id(a.broker_id)),
                decode(pv_user_id, 2, 'EDI', 'PAPER')
            from
                mass_enrollments a,
                person           b,
                account          d
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and a.batch_number = p_batch_number
                and error_message is null
                and b.entrp_id = d.entrp_id
                and d.account_type = 'FSA'
                and not exists (
                    select
                        *
                    from
                        account
                    where
                        pers_id = b.pers_id
                );

        update person a
        set
            acc_numc = (
                select
                    reverse(acc_num)
                from
                    account
                where
                    a.pers_id = account.pers_id
            )
        where
            acc_numc is null;

        for x in (
            select
                pers_id,
                acc_id,
                acc_num
            from
                account
            where
                account.pers_id in (
                    select
                        *
                    from
                        table ( cast(l_pers_id_tbl as number_table) )
                )
        ) loop
            update mass_enrollments a
            set
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                pers_id = x.pers_id;

        end loop;

        update mass_enrollments a
        set
            error_message = 'Error in Account Setup'
        where
            error_message is null
            and not exists (
                select
                    *
                from
                    person  c,
                    account b
                where
                        replace(c.ssn, '-') = replace(a.ssn, '-')
                    and c.pers_id = b.pers_id
                    and b.account_type = 'FSA'
            )
            and a.batch_number = p_batch_number;


        -- Inserting into Insure
        insert into card_debit (
            card_id,
            start_date,
            emitent,
            note,
            status,
            card_number,
            created_by,
            last_updated_by,
            last_update_date,
            issue_conditional
        )
            select
                b.pers_id,
                nvl(
                    greatest(
                        format_to_date(a.start_date),
                        format_to_date(a.effective_date)
                    ),
                    sysdate
                ),
                6763 -- Metavante
                ,
                'Mass Enrollment',
                1,
                null,
                a.created_by,
                a.created_by,
                sysdate,
                'No'
            from
                mass_enrollments a,
                person           b
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and a.batch_number = p_batch_number
                and error_message is null
                and upper(a.debit_card) in ( 'Y', 'YES' )
                and a.account_type = 'FSA'
                and exists (
                    select
                        *
                    from
                        enterprise
                    where
                            entrp_id = b.entrp_id
                        and nvl(card_allowed, 1) = 0
                )
                and not exists (
                    select
                        *
                    from
                        card_debit
                    where
                        card_id = b.pers_id
                );

        update mass_enrollments a
        set
            error_message = 'Error in card Setup'
        where
            error_message is null
            and a.batch_number = p_batch_number
            and upper(a.debit_card) in ( 'Y', 'YES' )
            and account_type = 'FSA'
            and not exists (
                select
                    *
                from
                    card_debit c
                where
                    a.pers_id = c.card_id
            )
            and exists (
                select
                    *
                from
                    enterprise
                where
                        entrp_id = a.entrp_id
                    and nvl(card_allowed, 1) = 0
            );

        insert into ben_plan_enrollment_setup (
            ben_plan_id,
            ben_plan_name,
            ben_plan_number,
            plan_start_date,
            plan_end_date,
            status,
            runout_period_days,
            runout_period_term,
            funding_options,
            reimbursement_type,
            reimbursement_ded,
            rollover,
            term_eligibility,
            funding_type,
            acc_id,
            new_hire_contrib,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            plan_type,
            annual_election,
            effective_date,
            ben_plan_id_main,
            batch_number,
            product_type
        )
            select
                ben_plan_seq.nextval,
                emp_plan.ben_plan_name,
                emp_plan.ben_plan_number,
                emp_plan.plan_start_date,
                emp_plan.plan_end_date,
                'A',
                emp_plan.runout_period_days,
                emp_plan.runout_period_term,
                emp_plan.funding_options,
                emp_plan.reimbursement_type,
                emp_plan.reimbursement_ded,
                emp_plan.rollover,
                emp_plan.term_eligibility,
                emp_plan.funding_type,
                acc.acc_id,
                emp_plan.new_hire_contrib,
                sysdate,
                fsa.created_by,
                sysdate,
                fsa.created_by,
                'Mass Enrollment Setup',
                fsa.plan_type,
                fsa.annual_election,
                format_to_date(fsa.effective_date),
                emp_plan.ben_plan_id,
                p_batch_number,
                case
                    when fsa.plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) then
                        'HRA'
                    else
                        'FSA'
                end
            from
                fsa_plans_enroll_v        fsa,
                account                   acc,
                person                    per,
                account                   emp,
                ben_plan_enrollment_setup emp_plan
            where
                    fsa.pers_id = per.pers_id
                and per.pers_id = acc.pers_id
                and acc.account_type = 'FSA'
                and per.entrp_id = emp.entrp_id
                and emp.account_type = 'FSA'
                and emp.acc_id = emp_plan.acc_id
                and fsa.plan_type = emp_plan.plan_type
                and emp_plan.status = 'A'
                and emp_plan.plan_start_date <= format_to_date(fsa.effective_date)
                and emp_plan.plan_end_date >= format_to_date(fsa.effective_date);

        pc_benefit_plans.create_annual_election(
            p_batch_number  => p_batch_number,
            p_user_id       => pv_user_id,
            x_return_status => l_return_status,
            x_error_message => l_error_message
        );

        pc_fin.create_prefunded_receipt(
            p_batch_number => p_batch_number,
            p_user_id      => pv_user_id
        );
        insert into ben_plan_coverages (
            coverage_id,
            ben_plan_id,
            acc_id,
            coverage_type,
            deductible,
            start_date,
            end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            fixed_funding_amount,
            annual_election,
            fixed_funding_flag,
            deductible_rule_id,
            coverage_tier_name
        )
            select
                coverage_seq.nextval,
                b.ben_plan_id,
                b.acc_id,
                c.coverage_type,
                c.deductible,
                c.start_date,
                c.end_date,
                sysdate,
                0,
                sysdate,
                0,
                c.fixed_funding_amount,
                b.annual_election,
                c.fixed_funding_flag,
                c.deductible_rule_id,
                c.coverage_tier_name
            from
                fsa_plans_enroll_v        fsa,
                ben_plan_enrollment_setup a,
                ben_plan_enrollment_setup b,
                ben_plan_coverages        c
            where
                    b.batch_number = p_batch_number
                and a.ben_plan_id = b.ben_plan_id_main
                and fsa.entrp_id = a.entrp_id
                and fsa.plan_type = a.plan_type
                and a.entrp_id is not null
                and a.plan_type is not null
                and b.status in ( 'A', 'P' )
                and b.ben_plan_id = c.ben_plan_id
                and ( b.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                      or ( b.plan_type in ( 'FSA', 'LPF' )
                           and nvl(b.grace_period, 0) = 0 ) ) -- ADDED FOR FSA ROLLOVER SUPPORT
                and c.coverage_tier_name = fsa.coverage_tier_name
                and fsa.coverage_tier_name is not null;

        update mass_enrollments a
        set
            error_message = 'Error in benefit plan Setup'
        where
            error_message is null
            and account_type = 'FSA'
            and not exists (
                select
                    *
                from
                    ben_plan_enrollment_setup c
                where
                    a.acc_id = c.acc_id
            );

        update mass_enrollments a
        set
            error_message = 'Successfully Loaded',
            setup_status = 'Yes'
        where
            error_message is null
            and exists (
                select
                    *
                from
                    person
                where
                    mass_enrollment_id = a.mass_enrollment_id
            );

        commit;
    exception
        when others then
            raise_application_error('-20001', 'Error in Processing Enrollments' || sqlerrm);
    end process_fsa_enrollments;

-- FSA ENROLLMENT END
    procedure process_benetrac_enrollments (
        pv_file_name in varchar2
    ) is
        l_batch_number number;
    begin
        export_enrollment_file(pv_file_name, 441, l_batch_number);
        validate_enrollments(0, 441, l_batch_number);
        process_existing_accounts(0, l_batch_number);
        process_enrollments(0, l_batch_number);
        commit;
    end process_benetrac_enrollments;

    procedure process_benetrac_dependants (
        pv_file_name in varchar2
    ) is
        l_batch_number number;
    begin
        export_dependant_file(pv_file_name, 441);
        validate_dependants(0, 441, l_batch_number);
        process_existing_dependant(0, l_batch_number);
        process_dependants(0, l_batch_number);
    end process_benetrac_dependants;

    procedure process_ftp_hsa_enrollments (
        pv_file_name   in varchar2,
        p_user_name    in varchar2,
        p_group_number in varchar2
    ) is

        l_user_id      number := 0;
        l_entrp_acc_id number;
        l_batch_number number;
        lv_dest_file   varchar2(255);
        l_create_ddl   varchar2(32000);
        lv_create exception;
        l_row_count    number := -1;
        l_sqlerrm      varchar2(32000);
        l_tpa_exist    varchar2(1) := 'N';
        l_file_id      number;
        l_entrp_id     number;
        l_ease_exist   varchar2(1) := 'N';   -- Added by Swamy for Ticket#9840 on 18/05/2021
    begin
        pc_log.log_error('In Proc', 'Here');
        for x in (
            select
                user_id
            from
                sam_users
            where
                user_name = p_user_name
        ) loop
            l_user_id := x.user_id;
        end loop;

        for x in (
            select
                acc_id,
                entrp_id
            from
                account
            where
                acc_num = p_group_number
        ) loop
            l_entrp_acc_id := x.acc_id;
            l_entrp_id := x.entrp_id;
        end loop;

        pc_log.log_error('In Proc', 'Before Fail');
        l_create_ddl := 'ALTER TABLE TEMPLATE_EXTERNAL LOCATION (ENROLL_DIR:'''
                        || pv_file_name
                        || ''')';
        pc_log.log_error('In Proc', 'l_create_ddl := ' || l_create_ddl);
        begin
            pc_log.log_error('In Proc', 'before execute');
            execute immediate l_create_ddl;
            pc_log.log_error('In Proc', 'after execute ');
        exception
            when others then
                rollback;
                l_sqlerrm := sqlerrm;
                pc_log.log_error('In Proc3', 'Fail others' || l_sqlerrm);
        -- Added by Joshi for 9670. capture the error
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => 427,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => 'HSA',
                    p_enrollment_source => 'EDI',
                    p_file_type         => 'employee_eligibility',
                    p_error             => l_sqlerrm,
                    x_file_upload_id    => l_file_id
                );
        -- code ends here Joshi: 9670
        --   mail_utility.send_email('oracle@sterlingadministration.com','techsupport@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
        --   mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
            -- to_names     => 'techsupport@sterlingadministration.com',
                    to_names     => 'vhsqateam@sterlingadministration.com',  -- InternalPurpouse
                    subject      => 'Error in Enrollment file Upload' || pv_file_name,
                    html_message => sqlerrm,
--            attach       => l_files);
                    attach       => samfiles('/u01/app/oracle/oradata/enroll/' || pv_file_name)
                );

                pc_log.log_error('In Proc2 **2 ', l_tpa_exist);
                raise lv_create;
       /** send email alert as soon as it fails **/
                pc_log.log_error('In Proc3', 'Fail');
        end;

        pc_log.log_error('In Proc2 **1 ', l_tpa_exist);
        for x in (
            select
                *
            from
                template_external
            where
                upper(line) like '%TPA%'
        ) loop
            l_tpa_exist := 'Y';
        end loop;

   -- Below for loop added by Swamy for Ticket#9840 on 18/05/2021 for EASE HSA enrollment file upload
        for x in (
            select
                1
            from
                template_external
            where
                upper(line) like '%CLIENT%'
        ) loop
            l_ease_exist := 'Y';
        end loop;

        pc_log.log_error('In Proc2', l_tpa_exist);
        if l_tpa_exist = 'Y'
        or l_ease_exist = 'Y' then    -- OR cond. added by Swamy for Ticket#9840 on 18/05/2021

         --export_FTP_enrollment_file(pv_file_name,l_batch_number);
		 -- Commented above and added below by added by Swamy for Ticket#9840 on 18/05/2021
            if l_tpa_exist = 'Y' then
                export_ftp_enrollment_file(pv_file_name, l_batch_number);
            elsif l_ease_exist = 'Y' then
                process_upload.export_ease_enrollment_file(pv_file_name, l_batch_number);
            end if;

            pc_log.log_error('In Proc l_batch_number: ', l_batch_number);
            pc_log.log_error('In Proc l_entrp_id: ', l_entrp_id);

          -- Added by Jaggi
            if l_entrp_id is null then
                for x in (
                    select
                        entrp_acc_id,
                        entrp_id
                    from
                        mass_enrollments
                    where
                        batch_number = l_batch_number
                ) loop
                    l_entrp_acc_id := x.entrp_acc_id;
                    l_entrp_id := x.entrp_id;
                end loop;
            end if;

        else
            pc_log.log_error('In Proc', 'Here2');
            export_enrollment_file(pv_file_name, l_entrp_acc_id, l_user_id, p_group_number, l_batch_number);
        end if;

        pc_log.log_error('In Proc l_entrp_id: ', l_entrp_id);
        pc_log.log_error('In Proc l_entrp_acc_id ', l_entrp_acc_id);
        validate_enrollments(l_entrp_acc_id, l_user_id, l_batch_number);
        process_existing_accounts(l_user_id, l_batch_number);
        pc_notifications.closed_account_reactivation;
        process_enrollments(l_entrp_acc_id, l_batch_number);
        pc_log.log_error('In Proc', 'After Process');
        for x in (
            select
                acc_num
            from
                mass_enrollments
            where
                batch_number = l_batch_number
        ) loop
            update account
            set
                enrollment_source = 'EDI'
            where
                    acc_num = x.acc_num
                and trunc(creation_date) = trunc(sysdate);

        end loop;

        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        for x in (
            select distinct
                group_number
            from
                mass_enrollments
            where
                batch_number = l_batch_number
        ) loop
            pc_file_upload.export_csv_file(lv_dest_file, x.group_number, 'ELECTRONIC_UPLOAD');
      --##9537 EDI Notify Jaggi
            pc_notifications.notify_edi_file_received(l_entrp_id, pv_file_name);
        end loop;

        write_hsa_audit_file(l_batch_number, pv_file_name);

   -- update the success/failure count(9072)
        if l_tpa_exist = 'Y'
        or l_ease_exist = 'Y' then    -- OR cond. added by Swamy for Ticket#9840 on 18/05/2021

    -- Get the file ID.(added by Joshi for 9670)
            for f in (
                select
                    file_upload_id
                from
                    file_upload_history
                where
                        batch_number = l_batch_number
                    and file_name = pv_file_name
                    and entrp_id = l_entrp_id
            ) loop
                l_file_id := f.file_upload_id;
            end loop;

            pc_log.log_error('In Proc l_file_id ', l_file_id);
            for x in (
                select
                    sum(
                        case
                            when error_message like '%Successfully Loaded%' then
                                1
                            else
                                0
                        end
                    ) success_cnt,
                    sum(
                        case
                            when error_message not like '%Successfully Loaded%' then
                                1
                            else
                                0
                        end
                    ) failure_cnt
                from
                    mass_enrollments
                where
                    batch_number = l_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = l_file_id;

                else
                    if
                        x.success_cnt > 0
                        and x.failure_cnt = 0
                    then
                        update file_upload_history
                        set
                            file_upload_result = 'Successfully Loaded '
                                                 || nvl(x.success_cnt, 0)
                                                 || ' records '
                        where
                            file_upload_id = l_file_id;

                    else
                        update file_upload_history
                        set
                            file_upload_result = 'Successfully Loaded '
                                                 || nvl(x.success_cnt, 0)
                                                 || ' records, '
                                                 || decode(
                                nvl(x.failure_cnt, 0),
                                0,
                                '',
                                nvl(x.failure_cnt, 0)
                                || ' records failed to load '
                            )
                        where
                            file_upload_id = l_file_id;

                    end if;
                end if;

                if x.failure_cnt > 0 then
                      -- send mail to employer on the EDI results
                    pc_notifications.notify_edi_discrepancy_report(l_entrp_id, pv_file_name);
                end if;

            end loop;

        end if;
   -- code ends here
        commit;
        pc_log.log_error('In Proc', 'End');
    end process_ftp_hsa_enrollments;

    procedure process_ftp_hsa_dependants (
        pv_file_name   in varchar2,
        p_user_name    in varchar2,
        p_group_number in varchar2
    ) is
        l_batch_number number;
        l_user_id      number := 0;
        l_entrp_acc_id number;
        l_entrp_id     number;
        l_file_id      number;
    begin
        for x in (
            select
                user_id
            from
                sam_users
            where
                user_name = p_user_name
        ) loop
            l_user_id := x.user_id;
        end loop;

        for x in (
            select
                acc_id,
                entrp_id
            from
                account
            where
                acc_num = p_group_number
        ) loop
            l_entrp_acc_id := x.acc_id;
            l_entrp_id := x.entrp_id;
        end loop;
    -- Insert into File History table ( added by Joshi for 9072).
        pc_file_upload.insert_file_upload_history(
            p_batch_num         => l_batch_number,
            p_user_id           => 427,
            pv_file_name        => pv_file_name,
            p_entrp_id          => l_entrp_id,
            p_action            => 'ENROLLMENT',
            p_account_type      => 'HSA',
            p_enrollment_source => 'EDI',
            p_file_type         => 'dependent eligibility',
            x_file_upload_id    => l_file_id
        );
   -- code ends here 9072.

        export_dependant_file(pv_file_name, l_entrp_acc_id);
        validate_dependants(l_entrp_acc_id, l_user_id, l_batch_number);
        process_existing_dependant(l_user_id, l_batch_number);
        process_dependants(l_entrp_acc_id, l_batch_number);

   -- update the success/failure count(9072)
        for x in (
            select
                sum(
                    case
                        when error_message like '%Successfully Loaded%' then
                            1
                        else
                            0
                    end
                ) success_cnt,
                sum(
                    case
                        when error_message not like '%Successfully Loaded%' then
                            1
                        else
                            0
                    end
                ) failure_cnt
            from
                mass_enroll_dependant
            where
                batch_number = l_batch_number
        ) loop
            if
                x.success_cnt = 0
                and x.failure_cnt = 0
            then
                update file_upload_history
                set
                    file_upload_result = 'Error processing your file, Contact Customer Service',
                    batch_number = l_batch_number
                where
                    file_upload_id = l_file_id;

            else
                if
                    x.success_cnt > 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' records ',
                        batch_number = l_batch_number
                    where
                        file_upload_id = l_file_id;

                else
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' records, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' records failed to load '
                        ),
                        batch_number = l_batch_number
                    where
                        file_upload_id = l_file_id;

                end if;
            end if;

            if x.failure_cnt > 0 then
                    -- send mail to employer on the EDI results
                pc_notifications.notify_edi_discrepancy_report(l_entrp_id, pv_file_name);
                     -- code ends here.
            end if;

        end loop;

        write_dependent_audit_file(l_batch_number, pv_file_name);
    end process_ftp_hsa_dependants;

    procedure process_existing_hfsa (
        p_user_id      in number default 0,
        p_batch_number in number
    ) is
        l_user_id       number;
        l_return_status varchar2(30);
        l_error_message varchar2(3200);
    begin
        l_user_id := p_user_id;
        for x in (
            select
                a.mass_enrollment_id,
                rtrim(ltrim(a.first_name))   first_name,
                rtrim(ltrim(a.middle_name))  middle_name,
                rtrim(ltrim(a.last_name))    last_name,
                format_to_date(a.birth_date) birth_date,
                rtrim(ltrim(a.address))      address,
                rtrim(ltrim(a.city))         city,
                upper(a.state)               state,
                substr(a.zip, 1, 5)          zip,
                decode(
                    instr(a.day_phone, '-', 1),
                    0,
                    substr(a.day_phone, 1, 3)
                    || '-'
                    || substr(a.day_phone, 4, 3)
                    || '-'
                    || substr(a.day_phone, 7, 10),
                    day_phone
                )                            day_phone,
                a.acc_num,
                a.pers_id
            from
                mass_enrollments a
            where
                    a.batch_number = p_batch_number
                and a.error_message is null
                and a.pers_id is not null
                and a.acc_id is not null
        ) loop
            update person
            set
                first_name = nvl(x.first_name, first_name),
                last_name = nvl(x.last_name, last_name),
                middle_name = nvl(x.middle_name, middle_name),
                address = nvl(x.address, address),
                city = nvl(x.city, city),
                state = nvl(x.state, state),
                zip = nvl(x.zip, zip),
                phone_day = nvl(x.day_phone, phone_day),
                last_update_date = sysdate,
                last_updated_by = l_user_id
            where
                pers_id = x.pers_id;

            update mass_enrollments a
            set
                error_message = 'Successfully Processed',
                setup_status = 'Yes'
            where
                error_message is null
                and mass_enrollment_id = x.mass_enrollment_id;

        end loop;

        mass_renew_employees(p_batch_number);
    end process_existing_hfsa;

    procedure mass_renew_employees (
        p_batch_number in number
    ) is
        lv_create_error exception;
        x_return_status varchar2(30);
        x_error_message varchar2(3200);
    begin
        for x in (
            select
                er_ben_plan_id,
                acc_id,
                annual_election,
                coverage_tier_name,
                pers_id,
                effective_date
            from
                (
                    select
                        pc_benefit_plans.get_er_ben_plan(x.entrp_id,
                                                         x.plan_type,
                                                         format_to_date(x.effective_date)) er_ben_plan_id,
                        acc_id,
                        annual_election,
                        coverage_tier_name,
                        pers_id,
                        format_to_date(x.effective_date)                   effective_date
                    from
                        fsa_uploaded_plans_v x
                    where
                        batch_number = p_batch_number
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
                )
        ) loop
            begin
                pc_benefit_plans.add_renew_employees(
                    p_acc_id          => x.acc_id,
                    p_annual_election => x.annual_election,
                    p_er_ben_plan_id  => x.er_ben_plan_id,
                    p_cov_tier_name   => x.coverage_tier_name,
                    p_effective_date  => x.effective_date,
                    p_batch_number    => p_batch_number,
                    p_user_id         => get_user_id(v('APP_USER')),
                    x_return_status   => x_return_status,
                    x_error_message   => x_error_message
                );

                if x_return_status <> 'S' then
                    raise lv_create_error;
                end if;
                pc_benefit_plans.create_benefit_coverage(
                    p_er_ben_plan_id => x.er_ben_plan_id,
                    p_cov_tier_name  => x.coverage_tier_name,
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
                    update mass_enrollments
                    set
                        error_message = x_error_message
                    where
                            pers_id = x.pers_id
                        and error_message is null;

            end;
        end loop;

        pc_benefit_plans.create_annual_election(
            p_batch_number  => p_batch_number,
            p_user_id       => get_user_id(v('APP_USER')),
            x_return_status => x_return_status,
            x_error_message => x_error_message
        );

        if x_return_status <> 'S' then
            raise lv_create_error;
        end if;
        pc_fin.create_prefunded_receipt(
            p_batch_number => p_batch_number,
            p_user_id      => get_user_id(v('APP_USER'))
        );

    end mass_renew_employees;

    procedure process_fsa_renewal (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) is

        l_batch_number number;
        lv_dest_file   varchar2(255);
        l_file_id      number;
        l_entrp_id     number;
        l_account_type varchar2(30);
        l_tpa_exist    varchar2(1) := 'N';   -- Added by Jaggi for Ticket #101025
        l_ease_exist   varchar2(1) := 'N';   -- Added by Jaggi for Ticket #101025
        l_create_ddl   varchar2(500);        -- Added by Jaggi for Ticket #101025

        l_file         utl_file.file_type;
        l_buffer       raw(32767);
        l_amount       binary_integer := 32767;
        l_pos          integer := 1;
        l_blob         blob;
        l_blob_len     integer;
        exc_no_file exception;
    begin
  -- Start code Added by Jaggi for Ticket#101025(10394)
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('In Proc', 'lv_dest_file := ' || lv_dest_file);
        pc_log.log_error('In Proc', 'pv_file_name := ' || pv_file_name);
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', pv_file_name, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        l_create_ddl := 'ALTER TABLE TEMPLATE_EXTERNAL LOCATION (ENROLL_DIR:'''
                        || lv_dest_file
                        || ''')';
        pc_log.log_error('In Proc', 'l_create_ddl := ' || l_create_ddl);
        begin
            pc_log.log_error('In Proc', 'before execute');
            execute immediate l_create_ddl;
            pc_log.log_error('In Proc', 'after execute ');
        exception
            when others then
                rollback;
        end;

   --- added by jaggi 10125
        for x in (
            select
                *
            from
                template_external
            where
                upper(line) like '%TPA%'
        ) loop
            l_tpa_exist := 'Y';
        end loop;

   -- Below for loop added by Jaggi for Ticket#10125 on 10/09/2021 for EASE FSA enrollment file upload
        for x in (
            select
                1
            from
                template_external
            where
                upper(line) like '%CLIENT%'
        ) loop
            l_ease_exist := 'Y';
        end loop;

        if l_tpa_exist = 'Y'
        or l_ease_exist = 'Y' then
		 -- Commented above and added below by added by jaggi for Ticket#10125 on 10/09/2021
            if l_tpa_exist = 'Y' then
                export_fsa_renewal(pv_file_name, p_user_id, l_batch_number);
            elsif l_ease_exist = 'Y' then
                process_upload.export_ease_fsa_enrollment_file(pv_file_name, p_user_id, l_batch_number);
            end if;
        end if;
   -- End of code by Jaggi 10125

        x_batch_number := l_batch_number;
        validate_fsa_renewals(p_user_id, l_batch_number);

  -- Added by Joshi for 9670.
        for j in (
            select distinct
                a.account_type,
                a.entrp_id
            from
                account          a,
                mass_enrollments m
            where
                    a.acc_num = m.group_number
                and m.batch_number = l_batch_number
        ) loop
            l_account_type := j.account_type;
            l_entrp_id := j.entrp_id;
        end loop;
  -- Existing renewal, address changes etc
        for x in (
            select
                count(*) cnt
            from
                mass_enrollments
            where
                action in ( 'C', 'R' )
                and batch_number = l_batch_number
        ) loop
            if x.cnt > 0 then
                process_existing_hfsa_renew(p_user_id, l_batch_number);
     --Re-instate the terminated plans
                reinstate_terminated_plans(p_user_id, l_batch_number);
            end if;
        end loop;
  -- new plan additions , new enrollments etc

        for x in (
            select
                count(*) cnt
            from
                mass_enroll_plans
            where
                    action = 'N'
                and batch_number = l_batch_number
        ) loop
            if x.cnt > 0 then
                process_fsa_enrollments_renew(p_user_id, l_batch_number);
            end if;
        end loop;
   /** PAYROLL CALENDAR SETTINGS **/
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
                me.acc_id,
                mp.ben_plan_id,
                mp.first_payroll_date,
                mp.pay_contrb,
                mp.no_of_periods,
                mp.pay_cycle,
                format_to_date(mp.effective_date),
                sysdate,
                me.created_by,
                sysdate,
                me.created_by,
                mp.er_ben_plan_id
            from
                mass_enrollments  me,
                mass_enroll_plans mp
            where
                    me.mass_enrollment_id = mp.mass_enrollment_id
                and me.batch_number = mp.batch_number
                and mp.ben_plan_id is not null
                and mp.batch_number = l_batch_number
                and mp.action in ( 'N', 'R' )
                and mp.pay_cycle is not null
                and ( me.process_status is null
                      or me.process_status = 'W' );
    -- terminations

        for x in (
            select
                count(*) cnt
            from
                mass_enroll_plans
            where
                termination_date is not null
                and batch_number = l_batch_number
        ) loop
            if x.cnt > 0 then
                process_terminations(p_user_id, l_batch_number);
            end if;
        end loop;
  -- annual election changes
        for x in (
            select
                count(*) cnt
            from
                mass_enroll_plans
            where
                action in ( 'A', 'C' )-- pier 2683
                and batch_number = l_batch_number
        ) loop
            if x.cnt > 0 then
                process_annual_election_change(p_user_id, l_batch_number);
            end if;
        end loop;

        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        for x in (
            select distinct
                group_number
            from
                mass_enrollments
            where
                batch_number = l_batch_number
        ) loop
            pc_file_upload.export_csv_file(lv_dest_file, x.group_number, 'MANUAL_UPLOAD');
      --##9537 EDI Notify Jaggi
            pc_notifications.notify_edi_file_received(l_entrp_id, pv_file_name);
        end loop;

	 -- update the success/failure count(9072)
   -- p_user_id = 2 implies EDI upload.
        if p_user_id = 2 then
    -- Get the file ID.(Added by Joshi for 9670)
            for f in (
                select
                    file_upload_id
                from
                    file_upload_history
                where
                        batch_number = l_batch_number
                    and file_name = pv_file_name
                    and entrp_id = l_entrp_id
            ) loop
                l_file_id := f.file_upload_id;
            end loop;

            for x in (
                select
                    sum(
                        case
                            when error_column is not null then
                                1
                            else
                                0
                        end
                    ) failure_cnt,
                    sum(
                        case
                            when error_column is null then
                                1
                            else
                                0
                        end
                    ) success_cnt
                from
                    mass_enrollments
                where
                    batch_number = l_batch_number
            ) loop
                if
                    x.success_cnt = 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Error processing your file, Contact Customer Service'
                    where
                        file_upload_id = l_file_id;

                else
                    if
                        x.success_cnt > 0
                        and x.failure_cnt = 0
                    then
                        update file_upload_history
                        set
                            file_upload_result = 'Successfully Loaded '
                                                 || nvl(x.success_cnt, 0)
                                                 || ' records'
                        where
                            file_upload_id = l_file_id;

                    else
                        update file_upload_history
                        set
                            file_upload_result = 'Successfully Loaded '
                                                 || nvl(x.success_cnt, 0)
                                                 || ' records, '
                                                 || decode(
                                nvl(x.failure_cnt, 0),
                                0,
                                '',
                                nvl(x.failure_cnt, 0)
                                || ' records failed to load '
                            )
                        where
                            file_upload_id = l_file_id;

                    end if;
                end if;

                if x.failure_cnt > 0 then
          -- send mail to employer on the EDI results
                    pc_notifications.notify_edi_discrepancy_report(l_entrp_id, pv_file_name);
                end if;

            end loop;

        end if;
   -- code ends here.
        write_hrafsa_audit_file(l_batch_number, pv_file_name);
        commit;
        x_batch_number := l_batch_number;
    end process_fsa_renewal;

    procedure validate_fsa_renewals (
        p_user_id      in number,
        p_batch_number in number
    ) is

        l_valid_plan        number;
        l_grp_entrp_id      varchar2(100);
        l_ee_entrp_id       varchar2(100);
        l_exist             number;
        plan_validation_error exception;
        l_error_message     varchar2(2400);
        l_error_column      varchar2(255);
        l_error_value       varchar2(255); -- 9072 Jagadeesh
        l_dup_count         number;
        l_ben_covg          varchar2(10);
        l_plan_type         varchar2(10);
        l_process_status    varchar2(10);
        l_return_status     varchar2(10);
        l_ben_error_message varchar2(2400);
    begin
        pc_log.log_error('PP', 'In Start');

  --If any of the Mandatory fields are NULL ,we would just reject the entire set of record
        for x in (
            select
                ssn,
                count(*) cnt
            from
                mass_enrollments
            where
                    batch_number = p_batch_number
                and ( process_status is null
                      or process_status = 'W' )
            group by
                ssn
            having
                count(*) > 1
        ) loop
            if x.ssn is not null then
                update mass_enrollments
                set
                    process_status = 'E',
                    error_message = 'You are attempting to enroll in more than one plan , but values does not match between the rows,
                             Please enter same values across rows if a member is enrolling in more than one plan',
                    error_value = 'SSN:'
                                  || nvl(x.ssn, 'NULL'),
                    error_column = 'SSN:'
                                   || nvl(x.ssn, 'NULL')
                where
                        ssn = x.ssn
                    and batch_number = p_batch_number;

            end if;
        end loop;

        for x in (
            select
                group_number,
                count(distinct group_number) cnt
            from
                mass_enrollments
            where
                batch_number = p_batch_number
            group by
                group_number
            having
                count(distinct group_number) > 1
        ) loop
            if x.group_number is not null then
                update mass_enrollments
                set
                    process_status = 'E',
                    error_message = 'You are attempting to perform Enrollment, Termination, Renewal/ Annual election change for more than one employer
                             in one file',
                    error_value = 'Group_number:'
                                  || nvl(x.group_number, 'NULL')
                where
                    group_number = x.group_number;

            end if;
        end loop;

        for x in (
            select
                acc_num,
                count(*) cnt
            from
                mass_enrollments
            where
                    batch_number = p_batch_number
                and ( process_status is null
                      or process_status = 'W' )
            group by
                acc_num
            having
                count(*) > 1
        ) loop
            if x.acc_num is not null then
                update mass_enrollments
                set
                    process_status = 'E',
                    error_message = 'You are attempting to enroll in more than one plan , but values does not match between the rows,
                             Please enter same values across rows if a member is enrolling in more than one plan',
                    error_value = 'acc_num:'
                                  || nvl(x.acc_num, 'NULL'),
                    error_column = 'acc_num:'
                                   || nvl(x.acc_num, 'NULL')
                where
                        acc_num = x.acc_num
                    and batch_number = p_batch_number;

            end if;
        end loop;

        for x in (
            select
                mass_enrollment_id,
                plan_type,
                effective_date,
                count(*) cnt
            from
                mass_enroll_plans
            where
                batch_number = p_batch_number
            group by
                mass_enrollment_id,
                plan_type,
                effective_date
            having
                count(*) > 1
        ) loop
            update mass_enrollments
            set
                process_status = 'E',
                error_message = 'You are attempting to enroll in same plan more than once, Found duplicate rows with same plan type and effective date '
                ,
                error_value = 'plan_type:'
                              || nvl(x.plan_type, 'NULL')
            where
                    mass_enrollment_id = x.mass_enrollment_id
                and batch_number = p_batch_number;

            update mass_enroll_plans
            set
                status = 'You are attempting to enroll in same plan more than once, Found duplicate rows with same plan type and effective date '
            where
                    mass_enrollment_id = x.mass_enrollment_id
                and batch_number = p_batch_number
                and plan_type = x.plan_type
                and effective_date = x.effective_date;

        end loop;

        for x in (
            select
                b.effective_date,
                a.group_number,
                a.entrp_id,
                a.account_type,
                a.mass_enrollment_id,
                b.plan_type,
                b.mass_enroll_plan_id,
                b.termination_date,
                a.action,
                a.tpa_id
            from
                mass_enrollments  a,
                mass_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and ( process_status is null
                      or process_status = 'W' )
                and b.status is null
                and a.mass_enrollment_id = b.mass_enrollment_id (+)
                and a.batch_number = b.batch_number (+)
        ) loop
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'EFFECTIVE_DATE' || x.effective_date);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'termination_date' || x.termination_date);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'group_number' || x.group_number);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'mass_enrollment_id' || x.mass_enrollment_id);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'plan_type' || x.plan_type);
            pc_log.log_error('PROCESS_UPLOAD:validate_fsa_renewals', 'termination_date' || x.termination_date);
            if
                ( x.effective_date is null
                  or format_to_date(x.effective_date) is null )
                and x.action in ( 'R', 'N' )
                and x.termination_date is null
            then
                update mass_enrollments
                set
                    error_message = 'Enter valid value for Effective Date MMDDYYYY for plan type ' || x.plan_type,
                    error_column = 'EFFECTIVE_DATE',
                    process_status = 'W',
                    error_value = 'EFFECTIVE_DATE:'
                                  || nvl(x.effective_date, 'NULL')
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and account_type in ( 'FSA', 'HRA' )
                    and error_message is null
                    and process_status is null
                    and mass_enrollment_id = x.mass_enrollment_id;

                update mass_enroll_plans
                set
                    status = 'Enter valid value for Effective Date'
                where
                        batch_number = p_batch_number
                    and mass_enroll_plan_id = x.mass_enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

            if
                x.termination_date is not null
                and format_to_date(x.termination_date) is null
            then
                update mass_enrollments
                set
                    error_message = 'Enter valid value for Termination Date MMDDYYYY for plan type ' || x.plan_type,
                    error_column = 'TERMINATION_DATE',
                    process_status = 'W',
                    error_value = 'termination_date:'
                                  || nvl(x.termination_date, 'NULL')
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and account_type in ( 'FSA', 'HRA' )
                    and error_message is null
                    and process_status is null
                    and mass_enrollment_id = x.mass_enrollment_id;

                update mass_enroll_plans
                set
                    status = 'Enter valid value for Termination Date'
                where
                        batch_number = p_batch_number
                    and mass_enroll_plan_id = x.mass_enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

            if ( x.group_number is null )
            or ( x.entrp_id is null )
            or ( x.account_type is null ) then
                if nvl(x.tpa_id, '*') = 'EASE' then
      -- Below update added by jaggi for Ticket#10125.
      -- In EASE file client_id is manditory, based on client ID we fetch entrp_id and other enterprise details, if client id is null or if wrong client id is uploaded below error message is thrown.
                    update mass_enrollments
                    set
                        error_message = 'Client ID OR Entrp_ID cannot be Null',
                        error_column = 'CLIENT_ID',
                        error_value = 'CLIENT_ID:' || entrp_id
                    where
                            batch_number = p_batch_number
                        and nvl(entrp_id, -1) = - 1
                        and nvl(tpa_id, '*') = 'EASE'
                        and error_message is null;

                else
                    update mass_enrollments
                    set
                        error_message = 'Group Number is Invalid for plan type ' || x.plan_type,
                        error_column = 'GROUP_NUMBER',
                        process_status = 'E',
                        error_value = 'GROUP_NUMBER:'
                                      || nvl(x.group_number, 'NULL')
                    where
                            batch_number = p_batch_number
                        and trunc(creation_date) = trunc(sysdate)
                        and error_message is null
                        and process_status is null
                        and mass_enrollment_id = x.mass_enrollment_id;

                    update mass_enroll_plans
                    set
                        status = 'Enter valid value for Group Number'
                    where
                            batch_number = p_batch_number
                        and mass_enroll_plan_id = x.mass_enroll_plan_id
                        and plan_type = x.plan_type
                        and status is null;

                end if;
            end if;

        end loop;
  -- Plan Validations
        for x in (
            select
                b.plan_type,
                a.birth_date,
                a.debit_card,
                a.first_name,
                a.middle_name,
                a.last_name,
                a.gender,
                a.city,
                a.state,
                a.zip,
                a.address,
                a.ssn,
                a.group_number,
                a.entrp_id,
                a.account_type,
                a.broker_id,
                a.division_code,
  --  A.DEBIT_CARD,
                pc_lookups.get_fsa_plan_type(b.plan_type) plan_type_m,
                b.effective_date,
                a.mass_enrollment_id,
                b.er_ben_plan_id                          er_ben_plan,
                b.ben_plan_id,
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
                b.mass_enroll_plan_id,
                b.termination_date,
                a.acc_num
            from
                mass_enrollments  a,
                mass_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and a.mass_enrollment_id = b.mass_enrollment_id (+)
                and a.batch_number = b.batch_number (+)
                and a.error_message is null
                and ( process_status is null
                      or process_status = 'W' )
        ) loop
            begin
                l_error_message := null;
                l_error_column := null;
                l_error_value := null;
                if ( x.entrp_id is null ) then
                    l_error_message := 'Verify Group Number of employer, cannot find match for plan type ' || x.plan_type;
                    l_error_column := 'GROUP_NUMBER';
                    l_process_status := 'E';
                    l_error_value := 'ENTRP_ID:'
                                     || nvl(x.entrp_id, 'NULL');
                    raise plan_validation_error;
                end if;

--      IF (X.SSN IS NULL AND X.ACC_NUM IS NULL)  AND X.ACCOUNT_TYPE IN ('FSA','HRA') THEN
                if
                    (
                        replace(x.ssn, '-') is null
                        and x.acc_num is null
                    )
                    and x.account_type in ( 'FSA', 'HRA' )
                then -- Added by Jaggi #9788
                    l_error_message := 'Social Security Number Cannot be Null for plan type ' || x.plan_type;
                    l_error_column := 'SSN';
                    l_process_status := 'E';
                    l_error_value := 'SSN:'
                                     || nvl(x.ssn, 'NULL');
                    raise plan_validation_error;
                end if;

                if
                    x.ssn like '%xx%'
                    and length(x.ssn) > 11
                    and x.account_type in ( 'FSA', 'HRA' )
                then
                    l_error_message := 'Enter valid Social Security Number for plan type ' || x.plan_type;
                    l_error_column := 'SSN';
                    l_process_status := 'E';
                    l_error_value := 'SSN:'
                                     || nvl(x.ssn, 'NULL');
                    raise plan_validation_error;
                end if;

                if
                    x.ssn like '%-%'
                    and length(x.ssn) > 11
                    and x.account_type in ( 'FSA', 'HRA' )
                then
                    l_error_message := 'Social Security Number cannot have more than 11 characters for plan type ' || x.plan_type;
                    l_error_column := 'SSN';
                    l_process_status := 'E';
                    l_error_value := 'SSN:'
                                     || nvl(x.ssn, 'NULL');
                    raise plan_validation_error;
                end if;

                if
                    x.ssn not like '%-%'
                    and length(x.ssn) > 9
                    and x.account_type in ( 'FSA', 'HRA' )
                then
                    l_error_message := 'Social Security Number cannot have more than 9 characters for plan type ' || x.plan_type;
                    l_error_column := 'SSN';
                    l_process_status := 'E';
                    l_error_value := 'SSN:'
                                     || nvl(x.ssn, 'NULL');
                    raise plan_validation_error;
                end if;
    --  IF pc_account.check_duplicate(X.ssn,X.group_number,NULL,X.account_type,X.entrp_id) = 'Y' THEN
    --     L_ERROR_MESSAGE := 'Member has been enrolled already with this SSN for plan type '||X.plan_type;
	--       L_ERROR_COLUMN  := 'SSN';
    --     L_PROCESS_STATUS := 'E';
    --    L_ERROR_VALUE     := 'SSN:' || NVL(X.SSN,'NULL');
    --     RAISE plan_validation_error;
    --  END IF;
                if x.termination_date is not null then
                    if x.ben_plan_id is null then
                        l_error_message := 'Cannot terminate benefit plan '
                                           || x.plan_type
                                           || ', as the member is not enrolled in this plan
                            or this plan is already terminated';
                        l_error_column := 'ACTION';
                        l_process_status := 'W';
                        l_error_value := 'TERMINATION_DATE:'
                                         || nvl(x.termination_date, 'NULL');
                        raise plan_validation_error;
                    end if;
                else
/*          IF X.GENDER IS NULL AND X.ACCOUNT_TYPE IN ('FSA','HRA')
          AND X.ACTION = 'N'
          THEN
             L_ERROR_MESSAGE   := 'Gender cannot be blank for plan type '||X.plan_type;
             L_ERROR_COLUMN    := 'GENDER';
             L_PROCESS_STATUS  := 'E';
             L_ERROR_VALUE     := 'GENDER:' || NVL(X.GENDER,'NULL');
             RAISE plan_validation_error;
          END IF;

          IF LENGTH(X.GENDER) > 1 AND X.ACCOUNT_TYPE IN ('FSA','HRA')
          AND X.ACTION = 'N'
          THEN
             L_ERROR_MESSAGE  := 'Gender cannot have more than one character '||X.plan_type;
             L_ERROR_COLUMN   := 'GENDER';
             L_PROCESS_STATUS := 'E';
             L_ERROR_VALUE    := 'GENDER:' || NVL(X.GENDER,'NULL');
             RAISE plan_validation_error;
          END IF;

         -- added by Jaggi #10836
          IF UPPER(X.GENDER) NOT IN ('M','F') AND X.ACCOUNT_TYPE IN ('FSA','HRA')
          AND X.ACTION = 'N'
          THEN
             L_ERROR_MESSAGE  := 'Enter valid value for Gender '||X.plan_type;
             L_ERROR_COLUMN   := 'GENDER';
             L_PROCESS_STATUS := 'E';
             L_ERROR_VALUE    := 'GENDER:' || NVL(X.GENDER,'NULL');
             RAISE plan_validation_error;
          END IF;
*/
                    if
                        x.first_name is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'First Name cannot be blank ' || x.plan_type;
                        l_error_column := 'FIRST_NAME';
                        l_process_status := 'E';
                        l_error_value := 'FIRST_NAME:'
                                         || nvl(x.first_name, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.last_name is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Last Name cannot be blank ' || x.plan_type;
                        l_error_column := 'LAST_NAME';
                        l_process_status := 'E';
                        l_error_value := 'LAST_NAME:'
                                         || nvl(x.last_name, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        length(x.middle_name) > 1
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action in ( 'C', 'R', 'N' )
                    then
                        l_error_message := 'Middle Name cannot have more than one character ' || x.plan_type;
                        l_error_column := 'MIDDLE_NAME';
                        l_process_status := 'E';
                        l_error_value := 'MIDDLE_NAME:'
                                         || nvl(x.middle_name, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        nvl(
                            ltrim(rtrim(x.address)),
                            '-1'
                        ) = '-1'
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Address cannot be blank ' || x.plan_type;
                        l_error_column := 'ADDRESS';
                        l_process_status := 'E';
                        l_error_value := 'ADDRESS:'
                                         || nvl(x.address, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.city is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'City cannot be blank ' || x.plan_type;
                        l_error_column := 'CITY';
                        l_process_status := 'E';
                        l_error_value := 'CITY:'
                                         || nvl(x.city, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.state is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'State cannot be blank ' || x.plan_type;
                        l_error_column := 'STATE';
                        l_process_status := 'E';
                        l_error_value := 'STATE:'
                                         || nvl(x.state, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        get_valid_state(upper(x.state)) is null
                        and x.action = 'N'
                    then
                        l_error_message := 'State is not valid ' || x.plan_type;
                        l_error_column := 'STATE';
                        l_process_status := 'E';
                        l_error_value := 'STATE:'
                                         || nvl(x.state, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.zip is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'ZIP cannot be blank ' || x.plan_type;
                        l_error_column := 'ZIP';
                        l_process_status := 'E';
                        l_error_value := 'ZIP:'
                                         || nvl(x.zip, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        ( length(x.zip) > 5
                        or not regexp_like(x.zip, '^[[:digit:]]+$') )
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'ZIP must be in the form 99999 ' || x.plan_type;
                        l_error_column := 'ZIP';
                        l_process_status := 'E';
                        l_error_value := 'ZIP:'
                                         || nvl(x.zip, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        length(x.state) > 2
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'State cannot have more than two characters ' || x.plan_type;
                        l_error_column := 'State';
                        l_process_status := 'E';
                        l_error_value := 'STATE:'
                                         || nvl(x.state, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.birth_date is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Birth Date cannot be blank for plan type ' || x.plan_type;
                        l_error_column := 'BIRTH_DATE';
                        l_process_status := 'E';
                        l_error_value := 'BIRTH_DATE:'
                                         || nvl(x.birth_date, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        format_to_date(x.birth_date) is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action = 'N'
                    then
                        l_error_message := 'Enter correct format for Birth Date MMDDYYYY for plan type ' || x.plan_type;
                        l_error_column := 'BIRTH_DATE';
                        l_process_status := 'E';
                        l_error_value := 'BIRTH_DATE:'
                                         || nvl(x.birth_date, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        is_number(x.broker_id) = 'N'
                        and x.account_type in ( 'FSA', 'HRA' )
                    then
                        l_error_message := 'Broker ID must be entered for plan type ' || x.plan_type;
                        l_error_column := 'BROKER_ID';
                        l_process_status := 'E';
                        l_error_value := 'BROKER_ID:'
                                         || nvl(x.broker_id, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.division_code is not null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and pc_employer_divisions.get_division_count(x.entrp_id,
                                                                     upper(x.division_code)) = 0
                    then
                        l_error_message := 'Division Code is not set up for plan type ' || x.plan_type;
                        l_error_column := 'DIVISION_CODE';
                        l_process_status := 'E';
                        l_error_value := 'DIVISION_CODE:'
                                         || nvl(x.division_code, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.debit_card is null
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Debit Card information must be entered for plan type ' || x.plan_type;
                        l_error_column := 'DEBIT_CARD';
                        l_process_status := 'E';
                        l_error_value := 'DEBIT_CARD:'
                                         || nvl(x.debit_card, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        upper(x.debit_card) not in ( 'Y', 'N', 'YES', 'NO' )
                        and x.account_type in ( 'FSA', 'HRA' )
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Enter valid value for Debit Card information for plan type ' || x.plan_type;
                        l_error_column := 'DEBIT_CARD';
                        l_process_status := 'E';
                        l_error_value := 'DEBIT_CARD:'
                                         || nvl(x.debit_card, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.ben_plan_id is not null
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Member has already enrolled in the benefit plan' || x.plan_type;
                        l_error_column := 'ACTION';
                        l_process_status := 'W';
                        l_error_value := 'plan_type:'
                                         || nvl(x.plan_type, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.ben_plan_id is null
                        and x.action = 'A'
                    then
                        l_error_message := ' Cannot make annual election Change,Member is not enrolled in the benefit plan ' || x.plan_type
                        ;
                        l_error_column := 'ACTION';
                        l_process_status := 'W';
                        l_error_value := 'plan_type:'
                                         || nvl(x.plan_type, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.plan_type is null
                        and x.action in ( 'A', 'R', 'N' )
                    then
                        l_error_message := 'Enter Valid Value for Plan Type';
                        l_error_column := 'PLAN_TYPE';
                        l_process_status := 'E';
                        l_error_value := 'plan_type:'
                                         || nvl(x.plan_type, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.plan_type is null
                        and x.termination_date is not null
                    then
                        l_error_message := 'Enter Valid Value for Plan Type';
                        l_error_column := 'PLAN_TYPE';
                        l_process_status := 'E';
                        l_error_value := 'plan_type:'
                                         || nvl(x.plan_type, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.plan_type_m is null
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Invalid Plan Type';
                        l_error_column := 'PLAN_TYPE';
                        l_process_status := 'W';
                        l_error_value := 'plan_type:'
                                         || nvl(x.plan_type, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.acc_id is null
                        and x.action <> 'N'
                    then
                        l_error_message := 'Employee does not belong to this employer for plan type ' || x.plan_type;
                        l_error_column := 'ACC_ID';
                        l_process_status := 'W';
                        l_error_value := 'ACC_ID:'
                                         || nvl(x.acc_id, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if x.er_ben_plan is null then
                        l_error_message := 'Cannot Enroll, Cannot find any matching plans setup for this employer with this effective date, please verify the effective date'
                        ;
                        l_error_column := 'ER_BEN_PLAN';
                        l_process_status := 'W';
                        l_error_value := 'er_ben_plan:'
                                         || nvl(x.er_ben_plan, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if
                        x.annual_election is null
                        and x.plan_type not in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Enter Valid Value for Annual Election for plan type ' || x.plan_type;
                        l_error_column := 'ANNUAL_ELECTION';
                        l_process_status := 'W';
                        l_error_value := 'annual_election:'
                                         || nvl(x.annual_election, 'NULL');
                        raise plan_validation_error;
                    end if;
      /* Vanitha: Commenting on 12/01/2016, we will add back when the life event code is added
         to the EDI/SAM uploads until then we will not insert

      IF X.ACTION in('A','C')THEN
        FOR XX IN (SELECT  COUNT(*)
                 FROM  BEN_PLAN_ENROLLMENT_SETUP BP
                WHERE   BP.PLAN_TYPE = X.PLAN_TYPE
                AND    X.ACC_ID = BP.ACC_ID
                 AND   BP.STATUS IN ('A','P')
                AND    BP.BEN_PLAN_ID_MAIN = X.er_ben_plan
                and    X.annual_election!=bp.annual_election )
         LOOP
              PC_BEN_LIFE_EVENTS.INSERT_EE_BEN_LIFE_EVENTS
              ( P_ACC_ID          => x.acc_id
               ,P_BEN_PLAN_ID     => x.ben_plan_id
               ,P_PLAN_TYPE       => x.plan_type
               ,P_LIFE_EVENT_CODE => 'ANNUAL_ELEC_UPDATE'
               ,P_DESCRIPTION     => 'Annual Election Change'
               ,P_ANNUAL_ELECTION => x.ANNUAL_ELECTION
               ,P_PAYROLL_CONTRIB => 0
               ,P_EFFECTIVE_DATE  => to_char(sysDATE,'mm/dd/yyyy')
               ,P_COV_TIER_NAME   => 'null'
               ,P_USER_ID         => p_user_id
               ,P_BATCH_NUMBER    => p_batch_number
               ,X_RETURN_STATUS   => L_RETURN_STATUS
               ,X_ERROR_MESSAGE   => L_ben_ERROR_MESSAGE);

               IF l_return_status <> 'S' THEN
                 L_ERROR_MESSAGE    := L_ben_ERROR_MESSAGE;
                 L_ERROR_COLUMN     := 'ANNUAL_ELECTION';
                 L_PROCESS_STATUS := 'E';
                 RAISE plan_validation_error;

               END IF;
        END LOOP;
      END IF;
      -- end of comment on 12/01/2016*/

      -- Added code for validating the coverage tier
      -- Joshi 8634 on 04/21/2020
                    if
                        x.covg_tier_name is null
                        and x.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                        and x.action in ( 'R', 'N' )
                    then
                        l_error_message := 'Enter Valid Value for Coverage Tier';
                        l_error_column := 'COVG_TIER_NAME';
                        l_process_status := 'W';
                        l_error_value := 'COVG_TIER_NAME:'
                                         || nvl(x.covg_tier_name, 'NULL');
                        raise plan_validation_error;
                    end if;
      -- code ends Joshi 8634 on 04/21/2020

                    if
                        validate_annual_election(x.er_ben_plan, x.annual_election) <> 'Y'
                        and x.action in ( 'R', 'N', 'A', 'C' )
                        and x.plan_type not in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) -- added this by Joshi for 8634.
                    then
                        l_error_message := 'Annual election should be within the defined for plan type ' || x.plan_type;
                        l_error_column := 'ANNUAL_ELECTION';
                        l_process_status := 'W';
                        l_error_value := 'annual_election:'
                                         || nvl(x.annual_election, 'NULL');
                        raise plan_validation_error;
                    end if;

                    if x.ben_plan_id is not null then --When we attach ee to renewed plans ben plan id
         --is NULL and ction code C.To handle the same add this condition
                        if
                            validate_ann_elec_change(x.ben_plan_id, x.er_ben_plan, x.annual_election) <> 'Y'
                            and x.action in ( 'A', 'C' )
                        then
                            l_error_message := 'Annual election should be within the defined for plan type ' || x.plan_type;
                            l_error_column := 'ANNUAL_ELECTION';
                            l_process_status := 'W';
                            l_error_value := 'annual_election:'
                                             || nvl(x.annual_election, 'NULL');
                            raise plan_validation_error;
                        end if;
                    end if;  --ee ben plan id NOT null loop

      --IF IS_NUMBER(X.annual_election) = 'N' THEN
      -- Added by Joshi for 8634
                    if
                        is_number(x.annual_election) = 'N'
                        and x.plan_type not in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                    then
                        l_error_message := 'Enter numeric value for Annual Election for plan type ' || x.plan_type;
                        l_error_column := 'ANNUAL_ELECTION';
                        l_process_status := 'W';
                        l_error_value := 'annual_election:'
                                         || nvl(x.annual_election, 'NULL');
                        raise plan_validation_error;
                    end if;
      /*
      IF (X.FIRST_PAYROLL_DATE IS NULL
      AND X.ACTION IN ( 'R','N')
      AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO')) OR IS_DATE(X.FIRST_PAYROLL_DATE) = 'N' THEN
        L_ERROR_MESSAGE       := 'Enter valid value for First Payroll Date MMDDYYYY for plan type '||X.plan_type;
        L_ERROR_COLUMN        := 'FIRST_PAYROLL_DATE';
        L_PROCESS_STATUS      := 'W';
        L_ERROR_VALUE         := 'FIRST_PAYROLL_DATE:' || NVL(X.FIRST_PAYROLL_DATE,'NULL');
        RAISE plan_validation_error;
      END IF;
      IF (X.PAY_CONTRB   IS NULL
      AND X.ACTION IN ( 'R','N')
      AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO') ) OR IS_NUMBER(X.PAY_CONTRB) = 'N'  THEN
        L_ERROR_MESSAGE      := 'Enter valid value for Pay Period Contribution for plan type '||X.plan_type;
        L_ERROR_COLUMN       := 'PAY_CONTRB';
        L_PROCESS_STATUS     := 'W';
        L_ERROR_VALUE        := 'PAY_CONTRB:' || NVL(X.PAY_CONTRB,'NULL');
        RAISE plan_validation_error;
      END IF;
      IF (X.NO_OF_PERIODS IS NULL
      AND X.ACTION IN ( 'R','N')
      AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO') )OR IS_NUMBER(X.NO_OF_PERIODS) = 'N' THEN
        L_ERROR_MESSAGE     := 'Enter valid value for Number of Pay Periods for plan type '||X.plan_type;
        L_ERROR_COLUMN      := 'NO_OF_PERIODS';
        L_PROCESS_STATUS    := 'W';
        L_ERROR_VALUE       := 'NO_OF_PERIODS:' || NVL(X.NO_OF_PERIODS,'NULL');
        RAISE plan_validation_error;
      END IF;
      IF X.PAY_CYCLE    IS NULL AND X.PLAN_TYPE NOT IN ('HRA','HRP','HR5','HR4','ACO')
      AND X.ACTION IN ( 'R','N')
      THEN
        L_ERROR_MESSAGE     := 'Enter valid value for Payroll Cycle for plan type '||X.plan_type;
        L_ERROR_COLUMN      := 'PAY_CYCLE';
        L_PROCESS_STATUS    := 'W';
        L_ERROR_VALUE       := 'PAY_CYCLE:' || NVL(X.PAY_CYCLE,'NULL');
        RAISE plan_validation_error;
      END IF;
      */
    --  IF X.COVG_TIER_NAME IS NULL AND X.PLAN_TYPE IN ('HRA','HRP','HR5','HR4','ACO') THEN
    --    L_ERROR_MESSAGE   := 'Enter valid value for Coverage Tier Name';
    --    L_ERROR_COLUMN    := 'COVG_TIER_NAME';
    --    L_PROCESS_STATUS  := 'W';
--    L_ERROR_VALUE         := 'COVG_TIER_NAME:' || NVL(X.COVG_TIER_NAME,'NULL');
    --    RAISE plan_validation_error;
    --  END IF;
                end if;

                if x.action not in ( 'T', 'R', 'N', 'C', 'A' ) then
                    l_error_message := 'Invalid Action Code for plan type ' || x.plan_type;
                    l_error_column := 'ACTION';
                    l_process_status := 'W';
                    l_error_value := 'action:'
                                     || nvl(x.action, 'NULL');
                    raise plan_validation_error;
                end if;

            exception
                when plan_validation_error then
                    pc_log.log_error('PROCESS_UPLOAD.validate_fsa_renewal', 'In plan_validation_error' || l_error_message);
                    update mass_enrollments
                    set
                        error_message = l_error_message,
                        error_column = l_error_column,
                        process_status = l_process_status,
                        error_value = l_error_value
                    where
                            batch_number = p_batch_number
                        and trunc(creation_date) = trunc(sysdate)
                        and account_type in ( 'FSA', 'HRA' )
                        and error_message is null
                        and process_status is null
                        and mass_enrollment_id = x.mass_enrollment_id;

                    update mass_enroll_plans
                    set
                        status = l_error_message
                    where
                            batch_number = p_batch_number
                        and mass_enroll_plan_id = x.mass_enroll_plan_id
                        and nvl(plan_type, 0) = nvl(x.plan_type, 0)
                        and status is null;  --Added NVL to handle NULL value of plan_type

            end;
        end loop;

  --Benefit Plan Setup Incomplete
        for x in (
            select
                a.*,
                c.mass_enrollment_id
            from
                ben_plan_enrollment_setup a,
                account                   b,
                mass_enrollments          c
            where
                    c.batch_number = p_batch_number
                and a.acc_id = b.acc_id
                and b.account_type in ( 'FSA', 'HRA' )
                and c.account_type in ( 'FSA', 'HRA' )
                and c.error_message is null
                and ( c.process_status is null
                      or c.process_status = 'W' )
                and c.entrp_id = b.entrp_id
                and c.action in ( 'R', 'N', 'T', 'A' )
                and ( a.status = 'A'
                      or ( a.plan_start_date <= trunc(sysdate)
                           and a.plan_end_date >= trunc(sysdate) ) )
        ) loop
            if x.plan_type is null
               or x.ben_plan_name is null then
                update mass_enrollments
                set
                    error_message = 'Benefit Plan Type is Incomplete, Set it up for Employer',
                    error_column = 'GROUP_NUMBER',
                    error_value = 'plan_type:'
                                  || nvl(x.plan_type, 'NULL')
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and account_type in ( 'FSA', 'HRA' )
                    and mass_enrollment_id = x.mass_enrollment_id
                    and error_message is null
                    and process_status is null
                    and action in ( 'C', 'R', 'N' );

            end if;
        end loop;

   --Check for Duplicate SSN's in the File
        for x in (
            select
                ssn,
                mass_enrollment_id
            from
                mass_enrollments
            where
                    batch_number = p_batch_number
                and action = 'N'
                and error_message is null
                and ( process_status is null
                      or process_status = 'W' )
            group by
                ssn,
                mass_enrollment_id
        )
             -- Having count(*) > 1)
         loop
            pc_log.log_error('PROCESS_UPLOAD.validate_fsa_renewals', 'Check for Duplicate SSN in the File ' || x.ssn);
            l_dup_count := 0;
            begin
                for zz in (
                    select
                        plan_type,
                        effective_date,
                        count(*) cnt
                    from
                        fsa_enroll_new_external
                    where
                        format_ssn(ssn) = x.ssn
                    group by
                        plan_type,
                        effective_date
                    having
                        count(*) > 1
                ) loop
                    if zz.cnt > 0 then
                        update mass_enroll_plans
                        set
                            status = 'Duplicate SSN for respective plan type-Pls check the file'
                        where
                                batch_number = p_batch_number
                            and mass_enrollment_id = x.mass_enrollment_id
                            and status is null;

                        l_dup_count := l_dup_count + 1;
                    end if;
                end loop;
            exception
                when others then
                    l_dup_count := 0;
            end;

            pc_log.log_error('PROCESS_UPLOAD.validate_fsa_renewals', 'Np of Duplicate SSN in the File for '
                                                                     || x.ssn
                                                                     || ': '
                                                                     || l_dup_count);

            if l_dup_count > 1 then
                update mass_enrollments
                set
                    error_message = 'Duplicate SSN in the File',
                    error_column = 'SSN',
                    process_status = 'E',
                    error_value = 'SSN:'
                                  || nvl(x.ssn, 'NULL')
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and error_message is null
                    and action = 'N'
                    and process_status is null
                    and ssn = x.ssn;

            end if;

        end loop;

    --Validate for Coverage Tier Name
    -- Joshi : 11555 added where clause not to include terminated records,
        for x in (
            select
                mrp.er_ben_plan_id,
                me.mass_enrollment_id,
                mrp.covg_tier_name,
                mrp.plan_type,
                mrp.mass_enroll_plan_id
            from
                mass_enrollments  me,
                mass_enroll_plans mrp
            where
                    me.batch_number = p_batch_number
                and me.batch_number = mrp.batch_number
                and me.mass_enrollment_id = mrp.mass_enrollment_id
                and mrp.covg_tier_name is not null
                and me.error_message is null
                and me.process_status is null
                and mrp.termination_date is null
        ) loop
            begin
                select
                    'Y'
                into l_ben_covg
                from
                    ben_plan_coverages
                where
                        ben_plan_id = x.er_ben_plan_id
                    and upper(x.covg_tier_name) = upper(ltrim(rtrim(coverage_tier_name)));

            exception
                when others then
                    l_ben_covg := 'N';
            end;

            if l_ben_covg <> 'Y' then
                update mass_enrollments
                set
                    error_message = 'Coverage Tier Name is not valid for plan type ' || x.plan_type,
                    error_column = 'COVG_TIER_NAME',
                    process_status = 'W',
                    error_value = 'COVERAGE_TIER_NAME:' || nvl(coverage_tier_name, 'NULL')
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and error_message is null
                    and process_status is null
                    and mass_enrollment_id = x.mass_enrollment_id;

                update mass_enroll_plans
                set
                    status = 'Coverage Tier Name is not valid'
                where
                        batch_number = p_batch_number
                    and mass_enroll_plan_id = x.mass_enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

        end loop;
      -- When all rows have warning then we have to error out
        for x in (
            select
                a.mass_enrollment_id,
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
                        when b.mass_enrollment_id is null then
                            0
                        else
                            1
                    end
                )        no_of_lines,
                count(*) no_of_records
            from
                mass_enrollments  a,
                mass_enroll_plans b
            where
                    a.mass_enrollment_id = b.mass_enrollment_id (+)
                and a.batch_number = b.batch_number (+)
                and a.batch_number = p_batch_number
            group by
                a.mass_enrollment_id
        ) loop
            if
                x.error_count > 0
                and x.error_count = x.no_of_lines
            then
      /* commented by Joshi for fixing EDI PROD issue (07/22/2020)
       UPDATE MASS_ENROLLMENTS
       SET   ERROR_MESSAGE   = 'Plan Information is Incomplete or Invalid, Enter Valid Plan Information',
             ERROR_COLUMN    = 'PLAN_TYPE',
             PROCESS_STATUS  = 'E'
      WHERE  MASS_ENROLLMENT_ID =  X.MASS_ENROLLMENT_ID
      AND    (PROCESS_STATUS IS NULL or PROCESS_STATUS  = 'W'); */
      -- Added by Joshi.
                update mass_enrollments
                set
                    error_message = nvl(error_message, 'Plan Information is Incomplete or Invalid, Enter Valid Plan Information'),
                    error_column = nvl(error_column, 'PLAN_TYPE'),
                    process_status = 'E'
                where
                        mass_enrollment_id = x.mass_enrollment_id
                    and ( process_status is null
                          or process_status = 'W' );

            end if;
        end loop;

    exception
        when others then
            pc_log.log_error('PROCESS_UPLOAD', 'In validate_fsa_renewals exception ' || sqlerrm);
            raise_application_error('-20002', 'Error in Validation ' || sqlerrm);
    end validate_fsa_renewals;

    procedure process_existing_hfsa_renew (
        p_user_id      in number default 0,
        p_batch_number in number
    ) is

        l_user_id       number;
        l_return_status varchar2(30);
        l_error_message varchar2(3200);
        is_stacked      varchar2(10);
        cnt1            number;
        issue_card      varchar2(1) := 'Y';
    begin
        l_user_id := p_user_id;
        pc_log.log_error('PROCESS_UPLOAD:process_existing_hfsa_renew', 'In process_existing_hfsa_renew');
        for x in (
            select
                a.mass_enrollment_id,
                rtrim(ltrim(a.first_name))   first_name,
                rtrim(ltrim(a.middle_name))  middle_name,
                rtrim(ltrim(a.last_name))    last_name,
                format_to_date(a.birth_date) birth_date,
                rtrim(ltrim(a.address))      address,
                rtrim(ltrim(a.city))         city,
                upper(a.state)               state,
                substr(a.zip, 1, 5)          zip,
                day_phone,
                a.acc_num,
                a.pers_id,
                a.gender,
                upper(a.debit_card)          debit_card,
                issue_conditional,
                effective_date,
                a.action,
                nvl((
                    select
                        card_allowed
                    from
                        enterprise
                    where
                        enterprise.entrp_id = a.entrp_id
                ), 1)                        card_allowed,
                a.orig_sys_vendor_ref
            from
                mass_enrollments a
            where
                    a.batch_number = p_batch_number
                and ( a.process_status is null
                      or a.process_status = 'W' )
                and a.pers_id is not null
                and a.acc_id is not null
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
                    phone_day = nvl(x.day_phone, phone_day),
                    gender = nvl(x.gender, gender),
                    birth_date = nvl(x.birth_date, birth_date),
                    last_update_date = sysdate,
                    last_updated_by = l_user_id,
                    orig_sys_vendor_ref = nvl(x.orig_sys_vendor_ref, orig_sys_vendor_ref)
                where
                    pers_id = x.pers_id;

            end if;

            if
                x.debit_card in ( 'YES', 'Y' )
                and x.card_allowed = 0
            then

/*select pc_account.is_stacked_account(entrp_id)into is_stacked from person where pers_id=x.pers_id;
if is_stacked='Y'then
select count(*)into cnt1 from account a,ben_plan_enrollment_setup b where a.acc_id=b.acc_id
and account_status=1and status='A'and pers_id=x.pers_id and product_type='FSA';
if cnt1=0then issue_card:='N';end if;end if;*/
                if issue_card = 'Y' then
                    insert into card_debit (
                        card_id,
                        start_date,
                        emitent,
                        note,
                        status,
                        created_by,
                        last_updated_by,
                        last_update_date,
                        issue_conditional
                    )
                        select
                            x.pers_id,
                            nvl(
                                format_to_date(x.effective_date),
                                sysdate
                            ),
                            6763, -- Metavante
                            'Mass Enrollment',
                            1,
                            l_user_id,
                            l_user_id,
                            sysdate,
                            'No'
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
--and exists(select 1 from account a,ben_plan_enrollment_setup b
--where a.acc_id=b.acc_id
--and account_status=1
--and status='A'
--and pers_id=x.pers_id
--and product_type='FSA');

            end if;

            update mass_enrollments a
            set
                error_message = 'Successfully Processed',
                setup_status = 'Yes'
            where
                ( process_status is null
                  or process_status = 'W' )
                and mass_enrollment_id = x.mass_enrollment_id;

            pc_log.log_error('PROCESS_UPLOAD:process_existing_hfsa_renew', 'After Update of mass_enrollments ' || sql%rowcount);
        end loop;

        pc_log.log_error('PROCESS_UPLOAD:process_existing_hfsa_renew', 'In Existing HFSA End ');
        mass_renew_enroll_employees(p_batch_number);
    exception
        when others then
            pc_log.log_error('PROCESS_UPLOAD:process_existing_hfsa_renew', 'Exception: ' || sqlerrm);
    end process_existing_hfsa_renew;

    procedure mass_renew_enroll_employees (
        p_batch_number in number
    ) is
        lv_create_error exception;
        x_return_status varchar2(30);
        x_error_message varchar2(3200);
    begin
        pc_log.log_error('PROCESS_UPLOAD:MASS_RENEW_ENROLL_EMPLOYEES', 'In Mass Renew: P_BATCH_NUMBER' || p_batch_number);
        for x in (
            select
                er_ben_plan_id,
                acc_id,
                annual_election,
                covg_tier_name,
                pers_id,
                effective_date
            from
                (
                    select
                        pc_benefit_plans.get_er_ben_plan(me.entrp_id,
                                                         x.plan_type,
                                                         format_to_date(x.effective_date)) er_ben_plan_id,
                        me.acc_id,
                        x.annual_election,
                        upper(x.covg_tier_name)                            covg_tier_name,
                        pers_id,
                        format_to_date(x.effective_date)                   effective_date
                    from
                        mass_enroll_plans x,
                        mass_enrollments  me
                    where
                            me.batch_number = p_batch_number
                        and me.mass_enrollment_id = x.mass_enrollment_id
                        and me.batch_number = x.batch_number
                        and x.action = 'R'
                        and x.status is null
   --AND (ME.error_column IS NULL OR ME.error_column = 'W') ---Modified by Puja on 28/06/2013
                        and ( me.process_status is null
                              or me.process_status = 'W' )
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
                )
        ) loop
            pc_log.log_error('PROCESS_UPLOAD:MASS_RENEW_ENROLL_EMPLOYEES : er_ben_plan_id ', x.er_ben_plan_id);
            pc_log.log_error('PROCESS_UPLOAD:MASS_RENEW_ENROLL_EMPLOYEES : effective_date ', x.effective_date);
            begin
       -- commented and called new procedure used only for EDI Renewal
       -- Joshi: 8634
       --PC_BENEFIT_PLANS.add_renew_employees(P_ACC_ID => X.ACC_ID , P_ANNUAL_ELECTION => X.ANNUAL_ELECTION , P_ER_BEN_PLAN_ID => X.er_ben_plan_id , P_COV_TIER_NAME => X.COVG_TIER_NAME , P_EFFECTIVE_DATE => X.effective_date , P_BATCH_NUMBER => P_BATCH_NUMBER , P_USER_ID => GET_USER_ID(v('APP_USER')) , X_RETURN_STATUS => X_RETURN_STATUS , X_ERROR_MESSAGE => X_ERROR_MESSAGE );
                pc_benefit_plans.add_renew_employees_edi(
                    p_acc_id          => x.acc_id,
                    p_annual_election => x.annual_election,
                    p_er_ben_plan_id  => x.er_ben_plan_id,
                    p_cov_tier_name   => x.covg_tier_name,
                    p_effective_date  => x.effective_date,
                    p_batch_number    => p_batch_number,
                    p_user_id         => get_user_id(v('APP_USER')),
                    x_return_status   => x_return_status,
                    x_error_message   => x_error_message
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
                    update mass_enrollments
                    set
                        process_status = 'E',
                        error_message = x_error_message
                    where
                            pers_id = x.pers_id
                        and process_status is null
                        or process_status = 'W';

            end;

        end loop;

        x_return_status := 'S';
        pc_benefit_plans.create_annual_election(
            p_batch_number  => p_batch_number,
            p_user_id       => get_user_id(v('APP_USER')),
            x_return_status => x_return_status,
            x_error_message => x_error_message
        );

        pc_fin.create_prefunded_receipt(
            p_batch_number => p_batch_number,
            p_user_id      => get_user_id(v('APP_USER'))
        );

    exception
        when others then
            pc_log.log_error('MASS_RENEW_ENROLL_EMPLOYEES', ' :EXCEPTION ' || sqlerrm);
    end mass_renew_enroll_employees;

    procedure process_fsa_enrollments_renew (
        pv_user_id     in number,
        p_batch_number in number
    ) is

        l_entrp_id      number;
        l_broker_id     number;
        l_fee_setup     number;
        l_count         number;
        l_pers_id_tbl   number_table := number_table();
        l_return_status varchar2(30);
        l_error_message varchar2(3200);
    begin
        dbms_output.put_line('In proc');
        pc_log.log_error('process_fsa_enrollments_renew', 'In Process Enrollments : P_BATCH_NUMBER ' || p_batch_number);
        insert into person (
            pers_id,
            first_name,
            middle_name,
            last_name,
            birth_date,
            title,
            gender,
            ssn,
            address,
            city,
            state,
            zip,
            mailmet,
            phone_day,
            phone_even,
            email,
            relat_code,
            note,
            entrp_id,
            person_type,
            mass_enrollment_id,
            creation_date,
            created_by,
            division_code,
            orig_sys_vendor_ref
        )
            select
                pers_seq.nextval,
                rtrim(ltrim(first_name)),
                rtrim(ltrim(middle_name)),
                rtrim(ltrim(last_name)),
                format_to_date(birth_date),
                title,
                decode(
                    initcap(gender),
                    'Male',
                    'M',
                    'Female',
                    'F',
                    upper(gender)
                ),
                decode(
                    instr(ssn, '-', 1),
                    0,
                    substr(ssn, 1, 3)
                    || '-'
                    || substr(ssn, 4, 2)
                    || '-'
                    || substr(ssn, 6, 9),
                    ssn
                ),
                rtrim(ltrim(address)),
                rtrim(ltrim(city)),
                upper(state),
                substr(zip, 1, 5),
                (
                    select
                        lookup_code
                    from
                        lookups
                    where
                            lookup_name = 'MAIL_TYPE'
                        and upper(description) like upper(contact_method)
                                                    || '%'
                        and contact_method is not null
                ),
                decode(
                    instr(day_phone, '-', 1),
                    0,
                    substr(day_phone, 1, 3)
                    || '-'
                    || substr(day_phone, 4, 3)
                    || '-'
                    || substr(day_phone, 7, 10),
                    day_phone
                ) day_phone,
                evening_phone,
                rtrim(ltrim(email_address)),
                1,
                decode(setup_status,
                       'No',
                       'Note **** '
                       || a.error_message
                       || '  '
                       || a.note
                       || ' in Mass Enrollments ',
                       nvl(a.note, 'Mass Enrollments')),
                b.entrp_id,
                'SUBSCRIBER',
                mass_enrollment_id,
                sysdate,
                a.created_by,
                upper(a.division_code),
                a.orig_sys_vendor_ref
            from
                mass_enrollments a,
                account          b
            where
                ( process_status is null
                  or process_status = 'W' )
                and a.batch_number = p_batch_number
                and a.action = 'N'
                and rtrim(
                    ltrim(a.group_number, ' '),
                    ' '
                ) = b.acc_num
                and b.account_type in ( 'HRA', 'FSA' )
                and not exists (
                    select
                        *
                    from
                        person  c,
                        account b
                    where
                            replace(c.ssn, '-') = replace(a.ssn, '-')
                        and c.pers_id = b.pers_id
                        and a.entrp_id = c.entrp_id
                        and b.account_type in ( 'HRA', 'FSA' )
                );

        pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'No of Person Inserted ' || sql%rowcount);
        for x in (
            select
                c.pers_id,
                a.mass_enrollment_id
            from
                person           c,
                mass_enrollments a
            where
                ( process_status is null
                  or process_status = 'W' )
                and a.batch_number = p_batch_number
                and a.mass_enrollment_id = c.mass_enrollment_id
        ) loop
            update mass_enrollments a
            set
                pers_id = x.pers_id
            where
                mass_enrollment_id = x.mass_enrollment_id;

            l_pers_id_tbl.extend;
            l_pers_id_tbl(l_pers_id_tbl.count) := x.pers_id;
        end loop;

        dbms_output.put_line('In proc2');
  --commit;

        pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'After Updating Mass Enrollments with person id' || sql%rowcount
        );
        update mass_enrollments a
        set
            error_message = 'Error in Person Setup'
        where
            error_message is null
            and process_status is null
            and a.batch_number = p_batch_number
            and a.account_type in ( 'HRA', 'FSA' )
            and a.action = 'N'
            and not exists (
                select
                    *
                from
                    person c
                where
                    replace(c.ssn, '-') = replace(a.ssn, '-')
            );

        pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'Before Inserting to account  ');
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
            hsa_effective_date,
            account_type,
            salesrep_id,
            am_id, -- added by joshi 5461 : populate Account manager
            enrollment_source
        )
            select
                acc_seq.nextval,
                b.pers_id,
                null,
                me.account_type || online_enroll_seq.nextval,
                d.plan_code,
                nvl(
                    format_to_date(me.start_date),
                    d.start_date
                ),
                0,
                nvl(me.broker_id, 0),
                decode(setup_status,
                       'No',
                       'Note **** '
                       || me.error_message
                       || '  '
                       || me.note
                       || ' in Mass Enrollments ',
                       nvl(me.note, 'Mass Enrollments')),
                d.fee_setup,
                d.fee_maint,
                sysdate,
                1,
                1,
                'Y',
                null,
                me.account_type,
                nvl((
                    select
                        salesrep_id
                    from
                        account
                    where
                        entrp_id = me.entrp_id
                ),
                    pc_broker.get_salesrep_id(me.broker_id)),
                pc_sales_team.get_salesrep_detail(me.entrp_id, 'SECONDARY'), --added by joshi 5461 : populate Account manager
                decode(pv_user_id, 2, 'EDI', 'PAPER')
            from
                mass_enrollments me,
                person           b,
                account          d
            where
                    me.mass_enrollment_id = b.mass_enrollment_id
                and me.batch_number = p_batch_number
                and me.action = 'N'
                and ( process_status is null
                      or process_status = 'W' )
                and b.entrp_id = d.entrp_id
                and d.account_type in ( 'HRA', 'FSA' )
                and not exists (
                    select
                        *
                    from
                        account
                    where
                        pers_id = b.pers_id
                );

        pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'After Inserting to Account table ');
        update person a
        set
            acc_numc = (
                select
                    reverse(acc_num)
                from
                    account
                where
                    a.pers_id = account.pers_id
            )
        where
            acc_numc is null;

        for x in (
            select
                pers_id,
                acc_id,
                acc_num
            from
                account
            where
                account.pers_id in (
                    select
                        *
                    from
                        table ( cast(l_pers_id_tbl as number_table) )
                )
        ) loop
            update mass_enrollments a
            set
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                pers_id = x.pers_id;

        end loop;

        update mass_enrollments a
        set
            error_message = 'Error in Account Setup'
        where
            error_message is null
            and process_status is null
            and a.action = 'N'
            and not exists (
                select
                    *
                from
                    person  c,
                    account b
                where
                        replace(c.ssn, '-') = replace(a.ssn, '-')
                    and c.pers_id = b.pers_id
                    and b.account_type in ( 'HRA', 'FSA' )
            )
            and a.batch_number = p_batch_number;
  -- Inserting into Insure

        pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'Before Inserting into Card Debit ');
        insert into card_debit (
            card_id,
            start_date,
            emitent,
            note,
            status,
            card_number,
            created_by,
            last_updated_by,
            last_update_date,
            issue_conditional
        )
            select
                b.pers_id,
                nvl(
                    greatest(
                        format_to_date(a.start_date),
                        format_to_date(a.effective_date)
                    ),
                    sysdate
                ),
                6763 -- Metavante
                ,
                'Mass Enrollment',
                1,
                null,
                a.created_by,
                a.created_by,
                sysdate,
                'No'
            from
                mass_enrollments a,
                person           b
            where
                    a.mass_enrollment_id = b.mass_enrollment_id
                and a.batch_number = p_batch_number
                and a.action = 'N'
                and ( process_status is null
                      or process_status = 'W' )
                and upper(a.debit_card) in ( 'Y', 'YES' )
                and a.account_type in ( 'HRA', 'FSA' )
                and exists (
                    select
                        *
                    from
                        enterprise
                    where
                            entrp_id = b.entrp_id
                        and nvl(card_allowed, 1) = 0
                )
                and not exists (
                    select
                        *
                    from
                        card_debit
                    where
                        card_id = b.pers_id
                );

        update mass_enrollments a
        set
            error_message = 'Error in card Setup'
        where
            error_message is null
            and a.batch_number = p_batch_number
            and upper(a.debit_card) in ( 'Y', 'YES' )
            and account_type = 'FSA'
            and not exists (
                select
                    *
                from
                    card_debit c
                where
                    a.pers_id = c.card_id
            )
            and exists (
                select
                    *
                from
                    enterprise
                where
                        entrp_id = a.entrp_id
                    and nvl(card_allowed, 1) = 0
            );

        pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'After Inserting into Card debit ');

   -- 8634:Joshi separating out insert stmt for HRA and FSA differently.
   -- for HRA annual election should be taken from ben_plan_coverage table.

        insert into ben_plan_enrollment_setup (
            ben_plan_id,
            ben_plan_name,
            ben_plan_number,
            plan_start_date,
            plan_end_date,
            status,
            runout_period_days,
            runout_period_term,
            funding_options,
            reimbursement_type,
            reimbursement_ded,
            rollover,
            term_eligibility,
            funding_type,
            acc_id,
            new_hire_contrib,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            plan_type,
            annual_election,
            effective_date,
            ben_plan_id_main,
            batch_number,
            grace_period,
            sf_ordinance_flag,
            qtly_rprt_start_date,
            allow_substantiation,
            claim_reimbursed_by /*For new enrollents ee claim reimbursed by should be same as ER */
        )
            select
                ben_plan_seq.nextval,
                emp_plan.ben_plan_name,
                emp_plan.ben_plan_number,
                emp_plan.plan_start_date,
                emp_plan.plan_end_date,
                'A',
                emp_plan.runout_period_days,
                emp_plan.runout_period_term,
                emp_plan.funding_options,
                emp_plan.reimbursement_type,
                emp_plan.reimbursement_ded,
                emp_plan.rollover,
                emp_plan.term_eligibility,
                emp_plan.funding_type,
                acc.acc_id,
                emp_plan.new_hire_contrib,
                sysdate,
                fsa.created_by,
                sysdate,
                fsa.created_by,
                emp_plan.note,--Notes of ER should be copied to EE
                fsa.plan_type,
                fsa.annual_election,
                format_to_date(fsa.effective_date),
                emp_plan.ben_plan_id,
                p_batch_number,
                emp_plan.grace_period,
                decode(emp_plan.appl_all_emp, 'Y', emp_plan.sf_ordinance_flag),
                decode(emp_plan.appl_all_emp, 'Y', emp_plan.qtly_rprt_start_date),
                nvl(emp_plan.allow_substantiation, 'N'),
                emp_plan.claim_reimbursed_by  /*For new enrollents ee claim reimbursed by should be same as ER */
            from
                mass_enroll_plans         fsa,
                mass_enrollments          me,
                account                   acc,
                person                    per,
                account                   emp,
                ben_plan_enrollment_setup emp_plan
            where
                    fsa.mass_enrollment_id = me.mass_enrollment_id
                and me.batch_number = p_batch_number
                and fsa.batch_number = p_batch_number
                and me.pers_id = per.pers_id
                and fsa.action = 'N'
                and fsa.status is null                          --To eliminate invalid plan types
                and ( me.process_status is null
                      or me.process_status = 'W' )
                and per.pers_id = acc.pers_id
                and acc.account_type in ( 'HRA', 'FSA' )           -- added by Joshi for 9675
                and fsa.plan_type not in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )  -- added by Joshi for 9675
  -- AND ACC.ACCOUNT_TYPE          = 'FSA' -                -- commented this for 9675.
                and per.entrp_id = emp.entrp_id
                and emp.account_type in ( 'HRA', 'FSA' )
                and emp.acc_id = emp_plan.acc_id
                and emp_plan.ben_plan_id = fsa.er_ben_plan_id
                and emp_plan.status = 'A';

  -- Added by Joshi for 8634. populating plan for HRA accounts
        insert into ben_plan_enrollment_setup (
            ben_plan_id,
            ben_plan_name,
            ben_plan_number,
            plan_start_date,
            plan_end_date,
            status,
            runout_period_days,
            runout_period_term,
            funding_options,
            reimbursement_type,
            reimbursement_ded,
            rollover,
            term_eligibility,
            funding_type,
            acc_id,
            new_hire_contrib,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            note,
            plan_type,
            annual_election,
            effective_date,
            ben_plan_id_main,
            batch_number,
            grace_period,
            sf_ordinance_flag,
            qtly_rprt_start_date,
            allow_substantiation,
            claim_reimbursed_by /*For new enrollents ee claim reimbursed by should be same as ER */
        )
            select
                ben_plan_seq.nextval,
                emp_plan.ben_plan_name,
                emp_plan.ben_plan_number,
                emp_plan.plan_start_date,
                emp_plan.plan_end_date,
                'A',
                emp_plan.runout_period_days,
                emp_plan.runout_period_term,
                emp_plan.funding_options,
                emp_plan.reimbursement_type,
                emp_plan.reimbursement_ded,
                emp_plan.rollover,
                emp_plan.term_eligibility,
                emp_plan.funding_type,
                acc.acc_id,
                emp_plan.new_hire_contrib,
                sysdate,
                fsa.created_by,
                sysdate,
                fsa.created_by,
                emp_plan.note,--Notes of ER should be copied to EE
                fsa.plan_type,
                bpc.annual_election, /* 8634: AE taken from ben_plan_coverage table */
                format_to_date(fsa.effective_date),
                emp_plan.ben_plan_id,
                p_batch_number,
                emp_plan.grace_period,
                decode(emp_plan.appl_all_emp, 'Y', emp_plan.sf_ordinance_flag),
                decode(emp_plan.appl_all_emp, 'Y', emp_plan.qtly_rprt_start_date),
                nvl(emp_plan.allow_substantiation, 'N'),
                emp_plan.claim_reimbursed_by  /*For new enrollents ee claim reimbursed by should be same as ER */
            from
                mass_enroll_plans         fsa,
                mass_enrollments          me,
                account                   acc,
                person                    per,
                account                   emp,
                ben_plan_enrollment_setup emp_plan,
                ben_plan_coverages        bpc
            where
                    fsa.mass_enrollment_id = me.mass_enrollment_id
                and me.batch_number = p_batch_number
                and fsa.batch_number = p_batch_number
                and me.pers_id = per.pers_id
                and fsa.action = 'N'
                and fsa.status is null                                --To eliminate invalid plan types
                and ( me.process_status is null
                      or me.process_status = 'W' )
                and per.pers_id = acc.pers_id
                and acc.account_type in ( 'HRA', 'FSA' )       -- added below Joshi for 9675
  -- AND ACC.ACCOUNT_TYPE          = 'HRA'                 commented by Joshi for 9675
                and per.entrp_id = emp.entrp_id
                and emp.account_type in ( 'HRA', 'FSA' )
                and emp.acc_id = emp_plan.acc_id
                and emp_plan.ben_plan_id = fsa.er_ben_plan_id
                and emp_plan.status = 'A'
                and fsa.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )  /* added follow clause by Joshi for 8634 */
                and bpc.ben_plan_id = emp_plan.ben_plan_id
                and upper(bpc.coverage_tier_name) = upper(fsa.covg_tier_name)
                and fsa.covg_tier_name is not null;

        for x in (
            select
                a.acc_id,
                a.ben_plan_id,
                b.mass_enrollment_id,
                b.mass_enroll_plan_id
            from
                ben_plan_enrollment_setup a,
                mass_enroll_plans         b,
                mass_enrollments          c
            where
                    a.batch_number = p_batch_number
                and a.batch_number = c.batch_number
                and a.batch_number = b.batch_number
                and a.acc_id = c.acc_id
                and b.plan_type = a.plan_type
                and b.mass_enrollment_id = c.mass_enrollment_id
                and a.ben_plan_id_main = b.er_ben_plan_id
        ) loop
            update mass_enroll_plans
            set
                ben_plan_id = x.ben_plan_id
            where
                mass_enroll_plan_id = x.mass_enroll_plan_id;

        end loop;

        pc_benefit_plans.create_annual_election(
            p_batch_number  => p_batch_number,
            p_user_id       => pv_user_id,
            x_return_status => l_return_status,
            x_error_message => l_error_message
        );

        pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'Afetr benefit  Plan setup ');
        pc_fin.create_prefunded_receipt(
            p_batch_number => p_batch_number,
            p_user_id      => get_user_id(v('APP_USER'))
        );

        insert into ben_plan_coverages (
            coverage_id,
            ben_plan_id,
            acc_id,
            coverage_type,
            deductible,
            start_date,
            end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            fixed_funding_amount,
            annual_election,
            fixed_funding_flag,
            deductible_rule_id,
            coverage_tier_name,
            max_rollover_amount
        )
            select
                coverage_seq.nextval,
                fsa.ben_plan_id,
                me.acc_id,
                c.coverage_type,
                c.deductible,
                c.start_date,
                c.end_date,
                sysdate,
                0,
                sysdate,
                0,
                c.fixed_funding_amount,
                c.annual_election, -- commented for 8634 FSA.annual_election ,
                c.fixed_funding_flag,
                c.deductible_rule_id,
                c.coverage_tier_name,
                c.max_rollover_amount
            from -- FSA_PLANS_ENROLL_V FSA,
    --FSA_UPLOADED_PLANS_V FSA ,
                mass_enroll_plans         fsa,
                mass_enrollments          me,
                ben_plan_enrollment_setup a,
                ben_plan_coverages        c
            where
                    fsa.batch_number = p_batch_number
                and me.batch_number = p_batch_number
                and fsa.action = 'N'
                and fsa.status is null
                and a.status in ( 'A', 'P' )
                and ( me.process_status is null
                      or me.process_status = 'W' )
                and fsa.mass_enrollment_id = me.mass_enrollment_id
                and fsa.er_ben_plan_id = a.ben_plan_id
                and a.ben_plan_id = c.ben_plan_id
                and a.entrp_id is not null
                and a.plan_type is not null
 --AND ME.PLAN_TYPE IN ('HRA','HRP','HR5','HR4','ACO') /* Plan type is always defined at Plan level */Along
                and fsa.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) /* Fix along with ticket#4363.Ticket#4651*/
                and upper(c.coverage_tier_name) = upper(fsa.covg_tier_name)
                and fsa.covg_tier_name is not null;

  -- Also take care of the case where the FSA plans come with no coverage tier specified
        insert into ben_plan_coverages (
            coverage_id,
            ben_plan_id,
            acc_id,
            coverage_type,
            deductible,
            start_date,
            end_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            fixed_funding_amount,
            annual_election,
            fixed_funding_flag,
            deductible_rule_id,
            coverage_tier_name,
            max_rollover_amount
        )
            select
                coverage_seq.nextval,
                fsa.ben_plan_id,
                me.acc_id,
                c.coverage_type,
                c.deductible,
                c.start_date,
                c.end_date,
                sysdate,
                0,
                sysdate,
                0,
                c.fixed_funding_amount,
                fsa.annual_election,
                c.fixed_funding_flag,
                c.deductible_rule_id,
                c.coverage_tier_name,
                c.max_rollover_amount
            from -- FSA_PLANS_ENROLL_V FSA,
    --FSA_UPLOADED_PLANS_V FSA ,
                mass_enroll_plans         fsa,
                mass_enrollments          me,
                ben_plan_enrollment_setup a,
                ben_plan_coverages        c
            where
                    fsa.batch_number = p_batch_number
                and me.batch_number = p_batch_number
                and fsa.action = 'N'
                and fsa.status is null
                and a.status in ( 'A', 'P' )
                and ( me.process_status is null
                      or me.process_status = 'W' )
                and fsa.mass_enrollment_id = me.mass_enrollment_id
                and fsa.er_ben_plan_id = a.ben_plan_id
                and a.ben_plan_id = c.ben_plan_id
                and a.entrp_id is not null
                and a.plan_type is not null
                and ( fsa.plan_type in ( 'FSA', 'LPF' )
                      and nvl(a.grace_period, 0) = 0 );

        update mass_enrollments a
        set
            error_message = 'Error in benefit plan Setup'
        where
            error_message is null
            and account_type in ( 'HRA', 'FSA' )
            and not exists (
                select
                    *
                from
                    ben_plan_enrollment_setup c
                where
                    a.acc_id = c.acc_id
            );

        update mass_enrollments a
        set
            error_message = 'Successfully Loaded',
            setup_status = 'Yes'
        where
            ( process_status is null
              or process_status = 'W' )
            and batch_number = p_batch_number
            and exists (
                select
                    *
                from
                    person
                where
                    mass_enrollment_id = a.mass_enrollment_id
            );

        commit;
    exception
        when others then
            pc_log.log_error('PROCESS_UPLOAD:process_fsa_enrollments_renew', 'In Process Enroll Exception ' || sqlerrm);
            raise_application_error('-20001', 'Error in Processing Enrollments' || sqlerrm);
    end process_fsa_enrollments_renew;

    procedure export_fsa_renewal (
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
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_sqlerrm       varchar2(32000);
        l_create_error exception;
        l_batch_number  number;
        l_valid_plan    number(10);
        l_acc_id        number(10);
        x_return_status varchar2(10);
        x_error_message varchar2(2000);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
        l_group_number  varchar(100);
        l_entrp_id      number;
        l_file_id       number;
        l_account_type  varchar(100);
    begin
        x_batch_number := batch_num_seq.nextval;
        pc_log.log_error('PROCESS_UPLOAD.export_fsa_renewal', 'pv_file_name :' || pv_file_name);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

  /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', pv_file_name, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            l_create_ddl := 'ALTER TABLE FSA_ENROLL_NEW_EXTERNAL ACCESS PARAMETERS ('
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
                            || '  LOCATION (ENROLL_DIR:'''
                            || lv_dest_file
                            || ''')';

            execute immediate l_create_ddl;
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of fsa renewals file' || sqlerrm;
                pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
                l_files.delete;
                l_files.extend(3);
                l_files(1) := '/u01/app/oracle/oradata/12QA/enroll/' || lv_dest_file;
                l_files(2) := '/u01/app/oracle/oradata/12QA/enroll/'
                              || lv_dest_file
                              || '.bad';
                l_files(3) := '/u01/app/oracle/oradata/12QA/enroll/' || l_log_file_name;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
          --to_names     => 'techsupport@sterlingadministration.com',
                    to_names     => 'Jagadeesh.Reddy@sterlingadministration.com; piyush.kumar@sterlingadministration.com, vhsqateam@sterlingadministration.com'
                    ,  -- InternalPurpouse
                    subject      => 'Error in FSA/HRA Enrollment file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );
--         attach => samfiles('/u01/app/oracle/oradata/12QA/enroll/'||lv_dest_file));
                raise l_create_error;
        end;
  -- Insert into File History table ( added by Joshi for 9072).
  -- moved the code from process_fsa_renwal to here (Joshi : 9670);
        if p_user_id = 2 then
            l_batch_number := x_batch_number;
            for x in (
                select distinct
                    group_number
                from
                    fsa_enroll_new_external
            ) loop
                l_group_number := x.group_number;
            end loop;

            for y in (
                select
                    entrp_id,
                    account_type
                from
                    account
                where
                    acc_num = l_group_number
            ) loop
                l_entrp_id := y.entrp_id;
                l_account_type := y.account_type;
            end loop;

            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => p_user_id,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => l_account_type,
                p_enrollment_source => 'EDI',
                p_file_type         => 'employee_eligibility',
                x_file_upload_id    => l_file_id
            );

        end if;
 -- code ends here 9072.

  --Delete already existing records.

        for x in (
            select
                mass_enrollment_id
            from
                mass_enrollments        me,
                fsa_enroll_new_external b
            where
                ( ( format_ssn(me.ssn) = format_ssn(b.ssn) )
                  or ( b.acct_number = me.acc_num ) )
        ) loop
            -- Added by Jaggi ##9547
            insert into mass_enrollments_history (
                mass_enroll_history_id,
                mass_enrollment_id,
                title,
                first_name,
                middle_name,
                last_name,
                gender,
                address,
                city,
                state,
                zip,
                contact_method,
                day_phone,
                evening_phone,
                email_address,
                birth_date,
                ssn,
                driver_license,
                passport,
                carrier,
                plan_type,
                deductible,
                effective_date,
                debit_card,
                plan_code,
                start_date,
                registration_date,
                account_status,
                setup_status,
                check_number,
                check_amount,
                employer_amount,
                employee_amount,
                entrp_acc_id,
                employer_name,
                broker_name,
                error_message,
                sign_on_file,
                note,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                error_column,
                entrp_id,
                group_number,
                bps_hra_plan,
                annual_election,
                issue_conditional,
                account_type,
                broker_id,
                health_fsa_flag,
                hfsa_effective_date,
                hfsa_annual_election,
                dep_fsa_flag,
                dfsa_effective_date,
                dfsa_annual_election,
                transit_fsa_flag,
                transit_effective_date,
                transit_annual_election,
                parking_fsa_flag,
                parking_effective_date,
                parking_annual_election,
                bicycle_effective_date,
                bicycle_fsa_flag,
                bicycle_annual_election,
                post_ded_fsa_flag,
                post_ded_effective_date,
                post_ded_annual_election,
                division_code,
                pers_id,
                acc_id,
                acc_num,
                batch_number,
                coverage_tier_name,
                hra_fsa_flag,
                action,
                process_status,
                tpa_id,
                orig_sys_vendor_ref,
                enrollment_source,
                termination_date,
                error_value
            )
                select
                    mass_enroll_history_seq_no.nextval,
                    mass_enrollment_id,
                    title,
                    first_name,
                    middle_name,
                    last_name,
                    gender,
                    address,
                    city,
                    state,
                    zip,
                    contact_method,
                    day_phone,
                    evening_phone,
                    email_address,
                    birth_date,
                    ssn,
                    driver_license,
                    passport,
                    carrier,
                    plan_type,
                    deductible,
                    effective_date,
                    debit_card,
                    plan_code,
                    start_date,
                    registration_date,
                    account_status,
                    setup_status,
                    check_number,
                    check_amount,
                    employer_amount,
                    employee_amount,
                    entrp_acc_id,
                    employer_name,
                    broker_name,
                    error_message,
                    sign_on_file,
                    note,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    error_column,
                    entrp_id,
                    group_number,
                    bps_hra_plan,
                    annual_election,
                    issue_conditional,
                    account_type,
                    broker_id,
                    health_fsa_flag,
                    hfsa_effective_date,
                    hfsa_annual_election,
                    dep_fsa_flag,
                    dfsa_effective_date,
                    dfsa_annual_election,
                    transit_fsa_flag,
                    transit_effective_date,
                    transit_annual_election,
                    parking_fsa_flag,
                    parking_effective_date,
                    parking_annual_election,
                    bicycle_effective_date,
                    bicycle_fsa_flag,
                    bicycle_annual_election,
                    post_ded_fsa_flag,
                    post_ded_effective_date,
                    post_ded_annual_election,
                    division_code,
                    pers_id,
                    acc_id,
                    acc_num,
                    batch_number,
                    coverage_tier_name,
                    hra_fsa_flag,
                    action,
                    process_status,
                    tpa_id,
                    orig_sys_vendor_ref,
                    enrollment_source,
                    termination_date,
                    error_value
                from
                    mass_enrollments
                where
                    mass_enrollment_id = x.mass_enrollment_id;
            -----
            delete from mass_enroll_plans
            where
                mass_enrollment_id = x.mass_enrollment_id;

            delete from mass_enrollments
            where
                mass_enrollment_id = x.mass_enrollment_id;

        end loop;

  --DELETE
 -- FROM MASS_ENROLLMENTS
 -- WHERE SSN IN
 --   (SELECT
 --     CASE
 --       WHEN LENGTH(SSN) < 9
 --       THEN LPAD(SSN,9,'0')
 --       ELSE SSN
 --     END SSN
 --   FROM FSA_ENROLL_NEW_EXTERNAL A
 --   )
 -- AND ACCOUNT_TYPE = 'FSA';

        begin
            insert into mass_enrollments (
                mass_enrollment_id,
                first_name,
                middle_name,
                last_name,
                gender,
                address,
                city,
                state,
                zip,
                contact_method,
                day_phone,
                evening_phone,
                email_address,
                birth_date,
                ssn,
                debit_card,
                plan_code,
                start_date,
                registration_date,
                account_status,
                setup_status,
                issue_conditional,
                broker_id,
                error_message,
                note,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                error_column,
                entrp_id,
                group_number,
                account_type,
                division_code,
                batch_number,
                acc_num,
        --ACTION, /* Joshi: 8634 Ignore Action code */
                tpa_id,
                orig_sys_vendor_ref
            )
                select
                    mass_enrollments_seq.nextval,
                    strip_bad(initcap(a.first_name)),
                    a.middle_name,
                    strip_bad(initcap(a.last_name)),
                    a.gender,
                    initcap(regexp_replace(a.address, '[[:cntrl:]]')),
                    initcap(regexp_replace(a.city, '[[:cntrl:]]')),
                    upper(regexp_replace(a.state, '[[:cntrl:]]')),
                    a.zip,
                    a.contact_method,
                    a.day_phone,
                    a.evening_phone,
                    a.email_address,
                    a.birth_date,
                    strip_bad(rtrim(ltrim(a.ssn))),
                    nvl(a.debit_card, 'NO'),
                    a.plan_code,
                    a.start_date,
                    a.registration_date,
                    a.account_status,
                    a.setup_status,
                    a.conditional_issue,
                    a.broker_number,
                    a.error_message,
                    a.note,
                    a.creation_date,
                    p_user_id,
                    a.last_update_date,
                    p_user_id,
                    a.error_column,
                    a.entrp_id,
                    a.group_number,
                    a.account_type,
                    a.division_code,
                    x_batch_number,
                    a.acc_num,
     -- UPPER(A.ACTION), /* Joshi: 8634 Ignore Action code */
                    tpa_id,
                    orig_sys_vendor_ref
                from
                    (
                        select distinct
                            first_name,
                            middle_name,
                            last_name,
                            decode(
                                upper(gender),
                                'M',
                                'M',
                                'F',
                                'F',
                                'FEMALE',
                                'F',
                                'MALE',
                                'M',
                                null
                            )                                      gender, -- added by jaggi #10836 Gender should allow only M,F,MALE,FEMALE apart from this shold enter null.
                            initcap(address)                       address,
                            initcap(city)                          city,
                            state,
                            case
                                when length(zip) < 5 then
                                    lpad(zip, 5, '0')
                                else
                                    zip
                            end                                    zip,
                            null                                   contact_method,
                            day_phone,
                            null                                   evening_phone,
                            email_address,
                            format_date(birth_date)                birth_date,
                            format_ssn(ssn)                        ssn,
        --ACTION ,
                            upper(debit_card)                      debit_card,
                            'FSA'                                  plan_code,
                            to_char(sysdate, 'MMDDRRRR')           start_date, --format_date(START_DATE) START_DATE
                            null                                   registration_date,
                            'Active'                               account_status,
                            'Yes'                                  setup_status,
                            initcap(nvl(conditional_issue, 'Yes')) conditional_issue,
                            broker_number,
                            null                                   error_message,
                            note,
                            sysdate                                creation_date,
                            sysdate                                last_update_date,
                            null                                   error_column,
                            pc_entrp.get_entrp_id(group_number)    entrp_id,
                            group_number,
                            null                                   account_type,
                            upper(division_code)                   division_code,
                            acct_number                            acc_num,
                            action,
                            tpa_id,
                            orig_sys_vendor_ref
                        from
                            fsa_enroll_new_external
                        where
                            ( ( p_user_id != 2 ) -- Sam upload should allow zero AE and edi shold not allow zero AE
                              or ( ( p_user_id = 2 )
                                   and nvl(
                                replace(
                                    replace(annual_election, '$', ''),
                                    '.00',
                                    ''
                                ),
                                1
                            ) != '0' ) )      -- added by Jaggi #10748: Sprint 41 - Do not process any $0 enrollments on FSA/HRA EDI. (#10575)
                    ) a;

            pc_log.log_error('PROCESS_UPLOAD', 'Number of rows insert into Mass enrollemnts' || sql%rowcount);
        exception
            when others then
                l_sqlerrm := 'Error in inserting into mass_enrollments ' || sqlerrm;
                pc_log.log_error('PROCESS_UPLOAD', 'Error in inserting into Mass enrollemnts' || l_sqlerrm);
                raise l_create_error;
        end;
  -- Added By Jaggi #9781
        for x in (
            select
                count(*) cnt
            from
                mass_enrollments
            where
                batch_number = x_batch_number
        ) loop
            if x.cnt = 0 then
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => p_user_id,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => l_account_type,
                    p_enrollment_source => 'EDI',
                    p_error             => 'Please check the file, template might be incorrect or file must be empty',
                    p_file_type         => 'employee_eligibility',
                    x_file_upload_id    => l_file_id
                );

            end if;
        end loop;
 -- end here --

  --Insert into Mass Enroll Plans
        update mass_enrollments
        set
            process_status = 'E',
            error_message = 'Enter Valid Group Number',
            error_column = 'GROUP_NUMBER',
            error_value = 'GROUP_NUMBER:' || 'NULL'
        where
            group_number is null
            and entrp_id is null
            and batch_number = x_batch_number;

        update mass_enrollments
        set
            process_status = 'E',
            error_message = 'Enter Valid Account Number or Social Security Number',
            error_column = 'SSN',
            error_value = 'SSN:' || 'NULL'
        where
            acc_num is null
            and ssn is null
            and batch_number = x_batch_number;

        begin
            insert into mass_enroll_plans (
                mass_enroll_plan_id,
                plan_type,
                deductible,
                effective_date,
                annual_election,
                first_payroll_date,
                pay_contrb,
                no_of_periods,
                pay_cycle,
        --ACTION, /* Joshi: 8634 Ignore Action code */
                plan_code,
                covg_tier_name,
                conditional_issue,
                broker_number,
                note,
                batch_number,
                mass_enrollment_id,
                ben_plan_id,
                created_by,
                creation_date,
                last_update_date,
                last_updated_by,
                termination_date
            )
                select
                    mass_enroll_plans_seq.nextval,
                    upper(a.plan_type),
                    a.deductible,
                    format_date(a.effective_date),
                    replace(a.annual_election, '$', ''),/* Ticket 4363 */
                    format_date(a.first_payroll_date),
                    replace(a.pay_contrb, '$', ''), /* Ticket#4363*/
                    a.no_of_periods,
                    upper(a.pay_cycle),
      --upper(a.ACTION) , /* Joshi: 8634 Ignore Action code */
                    a.plan_code,
                    ltrim(rtrim(strip_special_char(a.covg_tier_name))),--ltrim/rtrim does not remove junk
                    initcap(a.conditional_issue),
                    a.broker_number,
                    a.note,
                    x_batch_number,
                    b.mass_enrollment_id,
                    null, --Value will be inserted in Validation proc
                    p_user_id,
                    sysdate,
                    sysdate,
                    p_user_id,
                    format_date(a.termination_date)
                from
                    fsa_enroll_new_external a,
                    mass_enrollments        b
                where
                    ( ( format_ssn(a.ssn) = b.ssn )
                      or ( a.acct_number = b.acc_num ) )
                    and b.batch_number = x_batch_number
                    and ( ( p_user_id != 2 ) -- Sam upload should allow zero AE and edi shold not allow zero AE
                          or nvl(
                        replace(
                            replace(a.annual_election, '$', ''),
                            '.00',
                            ''
                        ),
                        1
                    ) != '0' ) -- added by Jaggi #10748: Sprint 41 - Do not process any $0 enrollments on FSA/HRA EDI. (#10575);
                    and b.process_status is null
                    and a.plan_type is not null;

            pc_log.log_error('NNAfter MEPInsert', sql%rowcount);
            pc_log.log_error('NNAfter MEPInsertBatch', x_batch_number);
            initialize_fsa_renewal(x_batch_number);
            commit;
            pc_log.log_error('PROCESS_UPLOAD', 'In export Renewal');
        exception
            when l_create_error then
       --Joshi: capture the file name in the file_upload_history table. 9670
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => p_user_id,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => l_account_type,
                    p_enrollment_source => 'EDI',
                    p_error             => sqlerrm,
                    p_file_type         => 'employee_eligibility',
                    x_file_upload_id    => l_file_id
                );

  -- code 9670 ends here.

                raise_application_error('-20001', 'Error ' || l_sqlerrm);
            when others then

      --Joshi: capture the file name in the file_upload_history table. 9670
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => p_user_id,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => l_account_type,
                    p_enrollment_source => 'EDI',
                    p_error             => sqlerrm,
                    p_file_type         => 'employee_eligibility',
                    x_file_upload_id    => l_file_id
                );
  -- code 9670 ends here.

                pc_log.log_error('PROCESS_UPLOAD', 'In excp' || sqlerrm);
                raise_application_error('-20001', 'WEN OTHERS ERROR Error in Inserting/Updating data in Mass Enrollments ' || sqlerrm
                );
                rollback;
        end; --End of Insert Loop
  -- Close the file if something goes wrong.
        if utl_file.is_open(l_file) then
            utl_file.fclose(l_file);
        end if;
  -- Delete file from wwv_flows
        delete from wwv_flow_files
        where
            name = pv_file_name;

        pc_log.log_error('process_upload.export_fsa_renewal', 'End');
    exception
        when others then

    --Joshi: capture the file name in the file_upload_history table. 9670
            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => p_user_id,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => l_account_type,
                p_enrollment_source => 'EDI',
                p_error             => sqlerrm,
                p_file_type         => 'employee_eligibility',
                x_file_upload_id    => l_file_id
            );

            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
          --to_names     => 'techsupport@sterlingadministration.com',
                to_names     => 'Jagadeesh.Reddy@sterlingadministration.com; piyush.kumar@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,shivani.jaiswal@sterlingadministration.com,srinivasulu.gudur@sterlingadministration.com, vhsqateam@sterlingadministration.com'
                ,  -- InternalPurpouse
                subject      => 'Error in FSA/HRA Enrollment file Upload ' || lv_dest_file,
                html_message => sqlerrm,
                attach       => l_files
            );
--         attach => samfiles('/u01/app/oracle/oradata/12QA/enroll/'||lv_dest_file));
  -- code 9670 ends here.
            pc_log.log_error('PROCESS_UPLOAD', 'In excp' || sqlerrm);
            rollback;
            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_fsa_renewal;

    procedure initialize_fsa_renewal (
        p_batch_number in number
    ) is
    begin
        pc_log.log_error('process_upload.initialize_fsa_renewal', 'Initialize Renewal Begin' || p_batch_number);
  -- Deletermine Account Type
        for x in (
            select
                a.account_type,
                a.plan_code,
                b.entrp_id,
                a.acc_id
            from
                account          a,
                mass_enrollments b
            where
                    a.entrp_id = b.entrp_id
                and b.batch_number = p_batch_number
            group by
                a.account_type,
                a.plan_code,
                b.entrp_id,
                a.acc_id
        ) loop
            update mass_enrollments
            set
                account_type = x.account_type,
                plan_code = x.plan_code,
                entrp_acc_id = x.acc_id
            where
                    entrp_id = x.entrp_id
                and batch_number = p_batch_number;

        end loop;

        for x in (
            select
                a.mass_enrollment_id,
                c.pers_id,
                d.acc_num,
                d.acc_id
            from
                mass_enrollments a,
                account          b,
                person           c,
                account          d
            where
                    a.batch_number = p_batch_number
                and ( a.process_status is null
                      or a.process_status = 'W' )
                and a.entrp_id = b.entrp_id
                and b.account_type in ( 'HRA', 'FSA' )
                and ( ( a.ssn is not null
                        and replace(c.ssn, '-') = replace(a.ssn, '-') )
                      or a.acc_num = d.acc_num )
                and c.pers_id = d.pers_id
                and b.entrp_id = c.entrp_id
                and d.account_type in ( 'HRA', 'FSA' )
        ) loop
            update mass_enrollments
            set
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                acc_num = x.acc_num
            where
                mass_enrollment_id = x.mass_enrollment_id;

        end loop;

        for x in (
            select
                ssn,
                count(*) cnt
            from
                mass_enrollments
            where
                batch_number = p_batch_number
            group by
                ssn
            having
                count(*) > 1
        ) loop
            if x.ssn is not null then
                update mass_enrollments
                set
                    process_status = 'E',
                    error_message = 'You are attempting to enroll in more than one plan , but values does not match between the rows,
                                 Please enter same values across rows if a member is enrolling in more than one plan',
                    error_value = 'SSN:'
                                  || nvl(x.ssn, 'NULL'),
                    error_column = 'SSN:'
                                   || nvl(x.ssn, 'NULL')
                where
                    ssn = x.ssn;

            end if;
        end loop;

        for x in (
            select
                b.effective_date,
                a.group_number,
                a.entrp_id,
                a.account_type,
                a.mass_enrollment_id,
                b.plan_type,
                b.mass_enroll_plan_id,
                b.termination_date,
                a.action,
                a.tpa_id
            from
                mass_enrollments  a,
                mass_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and a.process_status is null
                and b.status is null
                and ( a.action is null
                      or a.action <> 'A' )
                and a.mass_enrollment_id = b.mass_enrollment_id (+)
                and a.batch_number = b.batch_number (+)
        ) loop
            if ( (
                x.effective_date is null
                and x.termination_date is null
            )
            or (
                x.effective_date is not null
                and format_to_date(x.effective_date) is null
            ) ) then
                update mass_enroll_plans
                set
                    status = 'Enter valid value for Effective Date'
                where
                        batch_number = p_batch_number
                    and mass_enroll_plan_id = x.mass_enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null
                    and termination_date is null;

      -- Added by Joshi for fixing prod bug
                update mass_enrollments
                set
                    error_message = 'Enter valid value for Effective Date ' || x.plan_type,
                    error_column = 'EFFECTIVE_DATE',
                    process_status = 'E',
                    error_value = 'EFFECTIVE_DATE:'
                                  || nvl(x.effective_date, 'NULL')
                where
                        batch_number = p_batch_number
                    and trunc(creation_date) = trunc(sysdate)
                    and error_message is null
                    and process_status is null
                    and mass_enrollment_id = x.mass_enrollment_id;

            end if;

            if
                x.termination_date is not null
                and format_to_date(x.termination_date) is null
            then
                update mass_enroll_plans
                set
                    status = 'Enter valid value for Termination Date',
                    action = 'T'
                where
                        batch_number = p_batch_number
                    and mass_enroll_plan_id = x.mass_enroll_plan_id
                    and plan_type = x.plan_type
                    and status is null;

            end if;

            if ( x.group_number is null )
            or ( x.entrp_id is null )
            or ( x.account_type is null ) then
                if nvl(x.tpa_id, '*') = 'EASE' then
      -- Below update added by jaggi for Ticket#10125.
      -- In EASE file client_id is manditory, based on client ID we fetch entrp_id and other enterprise details, if client id is null or if wrong client id is uploaded below error message is thrown.
                    update mass_enrollments
                    set
                        error_message = 'Client ID OR Entrp_ID cannot be Null',
                        error_column = 'CLIENT_ID',
                        error_value = 'CLIENT_ID:' || entrp_id
                    where
                            batch_number = p_batch_number
                        and nvl(entrp_id, -1) = - 1
                        and nvl(tpa_id, '*') = 'EASE'
                        and error_message is null;

                else
                    update mass_enrollments
                    set
                        error_message = 'Group Number is Invalid for plan type ' || x.plan_type,
                        error_column = 'GROUP_NUMBER',
                        process_status = 'E',
                        error_value = 'GROUP_NUMBER:'
                                      || nvl(x.group_number, 'NULL')
                    where
                            batch_number = p_batch_number
                        and trunc(creation_date) = trunc(sysdate)
                        and error_message is null
                        and process_status is null
                        and mass_enrollment_id = x.mass_enrollment_id;

                    update mass_enroll_plans
                    set
                        status = 'Enter valid value for Group Number'
                    where
                            batch_number = p_batch_number
                        and mass_enroll_plan_id = x.mass_enroll_plan_id
                        and plan_type = x.plan_type
                        and status is null;

                end if;
            end if;

        end loop;

        update mass_enroll_plans
        set
            status = 'Cannot Terminate or Change Plan as Employee does not have plan ' || plan_type
        where
            mass_enroll_plan_id in (
                select
                    mass_enroll_plan_id
                from
                    mass_enroll_plans b, mass_enrollments  a
                where
                    b.termination_date is not null
                    and a.batch_number = p_batch_number
                    and a.batch_number = b.batch_number
                    and a.mass_enrollment_id = b.mass_enrollment_id
                    and not exists (
                        select
                            *
                        from
                            ben_plan_enrollment_setup bp
                        where
                                a.acc_id = bp.acc_id
                            and bp.plan_type = b.plan_type
                    )
            )
            and status is null;

        -- Update ben_plan_id in MASS_ENROLL_PLANS table
        for x in (
            select
                a.entrp_id,
                b.plan_type,
                b.effective_date,
                a.mass_enrollment_id,
                b.mass_enroll_plan_id,
                pc_benefit_plans.get_er_ben_plan(a.entrp_id,
                                                 b.plan_type,
                                                 nvl(
                                    format_to_date(b.effective_date),
                                    sysdate
                                )) er_ben_plan_id,
                a.acc_id
            from
                mass_enrollments  a,
                mass_enroll_plans b
            where
                    a.batch_number = p_batch_number
                and a.mass_enrollment_id = b.mass_enrollment_id
                and a.batch_number = b.batch_number
                and b.er_ben_plan_id is null
        ) loop
            pc_log.log_error('initialize_fsa_renewal', 'Derive er ben plan id');
            update mass_enroll_plans
            set
                er_ben_plan_id = x.er_ben_plan_id
            where
                    mass_enroll_plan_id = x.mass_enroll_plan_id
                and batch_number = p_batch_number
                and plan_type = x.plan_type;

            update mass_enroll_plans
            set
                ben_plan_id = pc_benefit_plans.get_ben_plan(x.er_ben_plan_id, x.acc_id)
            where
                    mass_enroll_plan_id = x.mass_enroll_plan_id
                and batch_number = p_batch_number
                and plan_type = x.plan_type;

        end loop;
  -- Determine Action
        for x in (
            select
                mp.er_ben_plan_id,
                me.acc_id,
                me.mass_enrollment_id,
                mp.mass_enroll_plan_id,
                mp.plan_type,
                me.action
            from
                mass_enrollments  me,
                mass_enroll_plans mp
            where
                    me.batch_number = p_batch_number
                and me.batch_number = mp.batch_number
                and me.mass_enrollment_id = mp.mass_enrollment_id
                and me.acc_id is not null
             -- AND MP.ACTION            IS NULL commented by Joshi for 8634
                and me.process_status is null
                and mp.status is null
        ) -- Ask this we need to add otherwise file value gets overwritten
         loop
            pc_log.log_error('process_upload.initialize_fsa_renewal', 'er_ben_plan_id  ' || x.er_ben_plan_id);
            if pc_benefit_plans.get_ben_plan(x.er_ben_plan_id, x.acc_id) is not null then
                update mass_enroll_plans
                set
                    action = decode(x.action, 'A', 'A', 'C'),
                    er_ben_plan_id = x.er_ben_plan_id
                where
                    mass_enroll_plan_id = x.mass_enroll_plan_id;

            else
                pc_log.log_error('process_upload.initialize_fsa_renewal', 'dont have the plan ');
                for zz in (
                    select
                        count(*) cnt
                    from
                        ben_plan_enrollment_setup
                    where
                            plan_type = x.plan_type
                        and status <> 'R'
                        and acc_id = x.acc_id
                ) loop
                    pc_log.log_error('process_upload.initialize_fsa_renewal', 'existing plan count ' || zz.cnt);
                    if zz.cnt > 0 then
                        update mass_enroll_plans
                        set
                            action = decode(x.action, 'A', 'A', 'R'),
                            er_ben_plan_id = x.er_ben_plan_id
                        where
                            mass_enroll_plan_id = x.mass_enroll_plan_id;

                    else
                        update mass_enroll_plans
                        set
                            action = decode(x.action, 'A', 'A', 'N'),
                            er_ben_plan_id = x.er_ben_plan_id
                        where
                            mass_enroll_plan_id = x.mass_enroll_plan_id;

                    end if;

                end loop;

            end if;

        end loop;

        update mass_enroll_plans
        set
            action = 'T'
        where
                batch_number = p_batch_number
            and termination_date is not null
            and status is null;
  -- determine mass enrollment action
        for x in (
            select
                me.mass_enrollment_id,
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
                mass_enroll_plans mp,
                mass_enrollments  me
            where
                    mp.mass_enrollment_id = me.mass_enrollment_id
                and me.batch_number = mp.batch_number
                and me.batch_number = p_batch_number
                and mp.termination_date is null
                and me.process_status is null
                and mp.status is null
            group by
                me.mass_enrollment_id
        ) loop
            pc_log.log_error('process_upload.initialize_fsa_renewal', 'Renewal count ' || x.renewal_count);
            pc_log.log_error('process_upload.initialize_fsa_renewal', 'change count ' || x.change_count);
            if x.renewal_count > 0 then
                update mass_enrollments
                set
                    action = 'R'
                where
                        mass_enrollment_id = x.mass_enrollment_id
                    and nvl(action, 'A') <> 'A';

            end if;

            if
                x.renewal_count = 0
                and x.change_count > 0
            then
                update mass_enrollments
                set
                    action = 'C'
                where
                        mass_enrollment_id = x.mass_enrollment_id
                    and nvl(action, 'A') <> 'A';

            end if;

        end loop;

        update mass_enroll_plans
        set
            action = 'N'
        where
            action is null
            and batch_number = p_batch_number
            and status is null;

  -- If no ssn exists then it is new
        update mass_enrollments
        set
            action = 'N'
        where
            action is null
            and batch_number = p_batch_number
            and acc_num is null
            and process_status is null;

        update mass_enrollments
        set
            action = 'C'
        where
            action is null
            and batch_number = p_batch_number
            and acc_num is not null
            and process_status is null;

        pc_log.log_error('process_upload.initialize_fsa_renewal', 'In Initialize End');
    exception
        when others then
            pc_log.log_error('process_upload.initialize_fsa_renewal:SQLERRM', sqlerrm);
    end initialize_fsa_renewal;

    procedure process_terminations (
        p_user_id      in number,
        p_batch_number in number
    ) is
        l_exists varchar2(1) := 'N';
    begin
        for x in (
            select
                me.acc_id,
                me.entrp_id,
                format_to_date(mep.termination_date) termination_date,
                mep.plan_type,
                bp.ben_plan_id,
                mep.mass_enroll_plan_id
            from
                mass_enrollments          me,
                mass_enroll_plans         mep,
                ben_plan_enrollment_setup bp
            where
                    me.mass_enrollment_id = mep.mass_enrollment_id
                and mep.plan_type = bp.plan_type
                and me.acc_id = bp.acc_id
                and mep.status is null
                and bp.status in ( 'A', 'I' )
                and ( me.process_status is null
                      or me.process_status = 'W' )
                and bp.ben_plan_id_main = mep.er_ben_plan_id
                and me.batch_number = p_batch_number
                and mep.termination_date is not null
                and ( ( format_to_date(mep.termination_date) >= format_to_date(mep.effective_date) )
                      or ( mep.effective_date is null ) )
        ) loop
            l_exists := 'Y';
            update mass_enroll_plans
            set
                ben_plan_id = x.ben_plan_id
            where
                mass_enroll_plan_id = x.mass_enroll_plan_id;

            pc_termination.insert_termination_interface(
                p_acc_id          => x.acc_id,
                p_entrp_id        => x.entrp_id,
                p_life_event_code => 'TERM_ONE_PLAN',
                p_effective_date  => x.termination_date,
                p_user_id         => p_user_id,
                p_plan_type       => x.plan_type,
                p_ben_plan_id     => x.ben_plan_id,
                p_batch_number    => p_batch_number
            );

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
                    format_to_date(mep.termination_date) termination_date,
                    mep.plan_type,
                    bp.ben_plan_id,
                    me.mass_enrollment_id
                from
                    mass_enrollments          me,
                    mass_enroll_plans         mep,
                    ben_plan_enrollment_setup bp
                where
                        me.mass_enrollment_id = mep.mass_enrollment_id
                    and mep.plan_type = bp.plan_type
                    and me.acc_id = bp.acc_id
                    and bp.effective_end_date is null
                    and ( ( format_to_date(mep.termination_date) >= format_to_date(mep.effective_date) )
                          or ( mep.effective_date is null ) )
                    and bp.ben_plan_id = mep.ben_plan_id
                    and me.batch_number = p_batch_number
            ) loop
                if x.termination_date is not null then
                    update mass_enrollments
                    set
                        process_status = 'S',
                        error_message = 'Terminated Successfully'
                    where
                            mass_enrollment_id = x.mass_enrollment_id
                        and process_status is null;

                end if;
            end loop;

        end if;

    exception
        when others then
            raise_application_error('-20001', 'Error in Process termination ' || sqlerrm);
    end process_terminations;

    function get_valid_state (
        p_state in varchar2
    ) return varchar2 is
        l_state varchar2(50);
    begin
        select
            state_name
        into l_state
        from
            us_states
        where
            state_abbr = p_state;

        return l_state;
    exception
        when others then
            return null;
    end get_valid_state;

    function validate_annual_election (
        p_ben_plan_id in number,
        p_election    in varchar2
    ) return varchar2 is

        l_election     varchar2(50) := 'N';
        l_min_election number;
        l_max_election number;
        l_plan_type    varchar2(255);
    begin
        pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION:P_ben_plan_id', p_ben_plan_id);
        pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION:P_election', p_election);
        select
            nvl(minimum_election, 0),
            maximum_election,
            plan_type
        into
            l_min_election,
            l_max_election,
            l_plan_type
        from
            ben_plan_enrollment_setup
        where
            ben_plan_id = p_ben_plan_id;

        pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION:l_min_election', l_min_election);
        pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION:l_max_election', l_max_election);
        if l_plan_type in ( 'TRN', 'PKG', 'UA1' ) then
            l_election := 'Y';
        else
            if
                l_min_election is not null
                and l_max_election is not null
            then
                if
                    p_election >= l_min_election
                    and p_election <= l_max_election
                then
                    l_election := 'Y';
                else
                    l_election := 'N';
                end if;

            else
                l_election := 'Y';
            end if;
        end if;

        pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION:l_election', l_election);
        return l_election;
    exception
        when no_data_found then
            pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION', 'NO_DATA_FOUND');
            return 'N';
        when others then
            pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION', sqlerrm);
            return null;
    end validate_annual_election;

    function validate_ann_elec_change (
        p_ben_plan_id    in number,
        p_er_ben_plan_id in number,
        p_election       in number
    ) return varchar2 is

        l_election     varchar2(50) := 'N';
        l_min_election number;
        l_max_election number;
        l_plan_type    varchar2(50);
    begin
        select
            minimum_election,
            maximum_election,
            plan_type
        into
            l_min_election,
            l_max_election,
            l_plan_type
        from
            ben_plan_enrollment_setup
        where
            ben_plan_id = p_er_ben_plan_id;

        if
            l_min_election is not null
            and l_max_election is not null
        then
            select
                'Y'
            into l_election
            from
                ben_plan_enrollment_setup
            where
                    ben_plan_id = p_ben_plan_id
                and p_election between l_min_election and l_max_election;
--           HAVING SUM(NVL(annual_election,0))+P_election >= l_min_election
--           AND    SUM(NVL(annual_election,0))+P_election <= l_max_election  ;
        else
            if l_plan_type in ( 'TRN', 'PKG', 'UA1' ) then
                l_election := 'Y';
            else
                l_election := 'N';
            end if;
        end if;

        return l_election;
    exception
        when no_data_found then
            return 'N';
        when others then
            pc_log.log_error('PROCESS_UPLOAD.VALIDATE_ANNUAL_ELECTION_change', sqlerrm);
            return null;
    end validate_ann_elec_change;

    procedure process_annual_election_change (
        p_user_id      in number default 0,
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
        l_count             number := 0;
    begin
        for x in (
            select
                mep.er_ben_plan_id,
                bp.plan_end_date,
                me.entrp_id,
                bp.plan_type,
                sum(mep.annual_election - bp.annual_election) change_amount,
                sum(mep.annual_election)                      new_annual_election,
                case
                    when bp.plan_start_date > sysdate then
                        greatest(bp.plan_start_date, sysdate)
                    else
                        least(bp.plan_end_date, sysdate)
                end                                           check_date
            from
                mass_enrollments          me,
                mass_enroll_plans         mep,
                ben_plan_enrollment_setup bp
            where
                    me.mass_enrollment_id = mep.mass_enrollment_id
                and mep.plan_type = bp.plan_type
                and me.acc_id = bp.acc_id
                and mep.status is null
                and mep.action in ( 'A', 'C' )
                and me.action in ( 'A', 'C' )
                and bp.status in ( 'A', 'P' )
                and ( me.process_status is null
                      or me.process_status = 'W' )
                and bp.ben_plan_id_main = mep.er_ben_plan_id
                and mep.annual_election != bp.annual_election
                and me.batch_number = p_batch_number
                and not exists (
                    select
                        *
                    from
                        income
                    where
                            income.acc_id = me.acc_id
                        and plan_type = bp.plan_type
                        and fee_code = 17
                        and fee_date between bp.plan_start_date and bp.plan_end_date
                )
            group by
                mep.er_ben_plan_id,
                bp.plan_end_date,
                me.entrp_id,
                bp.plan_type,
                bp.plan_start_date,
                bp.plan_end_date
            having
                sum(mep.annual_election - bp.annual_election) <> 0
        ) loop

           -- Initialize
            l_list_bill := null;
            l_prefund_list_bill := null;
            l_list_bill := employer_deposit_seq.nextval;

           -- Create ER Deposit for change
            pc_fin.create_employer_deposit(
                p_list_bill          => l_list_bill,
                p_entrp_id           => x.entrp_id,
                p_check_amount       => x.change_amount--x.ANNUAL_ELECTION
                ,
                p_check_date         => x.check_date -- 13121
                ,
                p_posted_balance     => x.change_amount--x.ANNUAL_ELECTION
                ,
                p_fee_bucket_balance => 0,
                p_remaining_balance  => 0,
                p_user_id            => get_user_id(v('APP_USER')),
                p_plan_type          => x.plan_type,
                p_note               => 'Annual Election Change',
                p_reason_code        => 12,
                p_check_number       => 'AE:'
                                  || p_batch_number
                                  || ':'
                                  || x.er_ben_plan_id
            );

            if x.plan_type = 'HRA' then
                l_prefund_list_bill := employer_deposit_seq.nextval;
           -- Create ER Deposit for change
                pc_fin.create_employer_deposit(
                    p_list_bill          => l_prefund_list_bill,
                    p_entrp_id           => x.entrp_id,
                    p_check_amount       => x.change_amount--x.ANNUAL_ELECTION
                    ,
                    p_check_date         => x.check_date  -- 13121
                    ,
                    p_posted_balance     => x.change_amount--x.ANNUAL_ELECTION
                    ,
                    p_fee_bucket_balance => 0,
                    p_remaining_balance  => 0,
                    p_user_id            => get_user_id(v('APP_USER')),
                    p_plan_type          => x.plan_type,
                    p_note               => 'Payroll Contribution Increase due to Annual Election Change',
                    p_reason_code        => 11,
                    p_check_number       => 'PC:'
                                      || p_batch_number
                                      || ':'
                                      || x.er_ben_plan_id
                );

            end if;

            for xx in (
                select
                    me.acc_id,
                    me.entrp_id,
                    mep.plan_type,
                    bp.plan_end_date-- Select plan end date  13121
                    ,
                    bp.ben_plan_id,
                    mep.mass_enroll_plan_id,
                    mep.er_ben_plan_id,
                    mep.annual_election,
                    mep.annual_election - bp.annual_election amount--pier 2683
                    ,
                    bp.annual_election                       ee_annual_election
                from
                    mass_enrollments          me,
                    mass_enroll_plans         mep,
                    ben_plan_enrollment_setup bp
                where
                        me.mass_enrollment_id = mep.mass_enrollment_id
                    and mep.plan_type = bp.plan_type
                    and me.acc_id = bp.acc_id
                    and mep.status is null
                    and mep.action in ( 'A', 'C' )
                    and me.action in ( 'A', 'C' )
                    and bp.status in ( 'A', 'P' )
                    and ( me.process_status is null
                          or me.process_status = 'W' )
                    and bp.ben_plan_id_main = mep.er_ben_plan_id
                    and mep.annual_election != bp.annual_election
                    and me.batch_number = p_batch_number
                    and mep.er_ben_plan_id = x.er_ben_plan_id
                    and not exists (
                        select
                            *
                        from
                            income
                        where
                                income.acc_id = me.acc_id
                            and plan_type = bp.plan_type
                            and fee_code = 17
                            and fee_date between bp.plan_start_date and bp.plan_end_date
                    )
            ) loop
                update mass_enroll_plans
                set
                    ben_plan_id = xx.ben_plan_id
                where
                    mass_enroll_plan_id = xx.mass_enroll_plan_id;

                update ben_plan_enrollment_setup
                set
                    annual_election = nvl(xx.annual_election, 0)--ANNUAL_ELECTION+
                    ,
                    batch_number = p_batch_number
                where
                        ben_plan_id = xx.ben_plan_id
                    and acc_id = xx.acc_id;
          /* Vanitha: Commenting on 12/01/2016, we will add back when the life event code is added
         to the EDI/SAM uploads until then we will not insert

          UPDATE BEN_LIFE_EVENT_HISTORY
            set   original_annual_election = NVL(x.ee_annual_election,0)
                , status = 'A'
                , processed_status = 'Y'
          WHERE   batch_number = p_batch_number
          AND     ben_plan_id = x.ben_plan_id;*/

                pc_log.log_error('Check', x.plan_end_date);

       -- Employee Annual election changes
                pc_log.log_error('Process Annual election change', 'End dated plan');
                pc_fin.create_receipt(
                    p_acc_id            => xx.acc_id,
                    p_fee_date          => x.check_date -- 13121
                    ,
                    p_entrp_id          => x.entrp_id,
                    p_er_amount         => xx.amount--x.annual_election
                    ,
                    p_pay_code          => 6,
                    p_plan_type         => xx.plan_type,
                    p_debit_card_posted => 'N',
                    p_list_bill         => l_list_bill,
                    p_fee_reason        => 12,
                    p_note              => 'Annual Election Change',
                    p_check_amount      => null,
                    p_user_id           => p_user_id,
                    p_check_number      => 'AE:'
                                      || p_batch_number
                                      || ':'
                                      || x.er_ben_plan_id
                );

                if xx.plan_type = 'HRA' then
                    pc_fin.create_receipt(
                        p_acc_id            => xx.acc_id,
                        p_fee_date          => x.check_date  -- 13121
                        ,
                        p_entrp_id          => x.entrp_id,
                        p_er_amount         => xx.amount--x.annual_election
                        ,
                        p_pay_code          => 6,
                        p_plan_type         => xx.plan_type,
                        p_debit_card_posted => 'N',
                        p_list_bill         => l_prefund_list_bill,
                        p_fee_reason        => 11,
                        p_note              => 'Payroll Contribution Increase due to Annual Election Change',
                        p_check_amount      => null,
                        p_user_id           => p_user_id,
                        p_check_number      => 'PC:'
                                          || p_batch_number
                                          || ':'
                                          || x.er_ben_plan_id
                    );
                end if;

            end loop;

        end loop;
    end process_annual_election_change;

    function get_entrp_id (
        p_entrp_acc_id in number,
        p_name         in varchar2,
        p_account_type in varchar2
    ) return number is
        l_entrp_id number;
    begin
        if p_name is not null then
            for x in (
                select
                    b.entrp_id
                from
                    account    a,
                    enterprise b
                where
                        upper(replace(
                            strip_bad(name),
                            ' ',
                            ''
                        )) = upper(replace(
                            strip_bad(p_name),
                            ' ',
                            ''
                        ))
                    and a.entrp_id = b.entrp_id
                    and a.account_type = nvl(p_account_type, 'HSA')
            ) loop
                l_entrp_id := x.entrp_id;
            end loop;
        end if;

        if p_entrp_acc_id is not null then
            for x in (
                select
                    entrp_id
                from
                    account
                where
                    acc_id = p_entrp_acc_id
            ) loop
                l_entrp_id := x.entrp_id;
            end loop;

        end if;

        return l_entrp_id;
    end get_entrp_id;

    procedure email_files (
        p_file_name    in varchar2,
        p_report_title in varchar2
    ) is
        l_html_message varchar2(3000);
    begin
        l_html_message := '<html>
                         <head>
                         <title>'
                          || p_report_title
                          || '</title>
                         </head>
                         <body bgcolor="#FFFFFF" link="#000080">
                         <table cellspacing="0" cellpadding="0" width="100%">
                         <tr align="LEFT" valign="BASELINE">
                         <td width="100%" valign="middle">'
                          || p_report_title
                          || '</td>
                         </table>
                         </body>
                         </html>';
        mail_utility.email_files(
            from_name    => 'oracle@sterlingadministration.com',
            to_names     => 'vhsteam@sterlingadministration.com,it-team@sterlingadministration.com,vanitha.subramanyam@sterlingadministration.com'
            ,
            subject      => p_report_title,
            html_message => l_html_message,
            attach       => samfiles('/u01/app/oracle/oradata/enroll/' || p_file_name)
        );

    end email_files;

    procedure write_hrafsa_audit_file (
        p_batch_number in number,
        p_file_name    in varchar2
    ) is

        l_utl_id        utl_file.file_type;
        l_file_name     varchar2(200);
        l_line          varchar2(3200);
        l_entrpid       number;
        l_employer_name varchar2(255);
        l_acc_type      varchar2(10);
        l_address       varchar2(100);
    begin
        l_file_name := p_batch_number
                       || '_'
                       || p_file_name
                       || '.csv';
        if file_exists(l_file_name, 'ENROLL_DIR') = 'TRUE' then
            --dbms_output.put_line('TRUe');
            pc_log.log_error(l_file_name || 'FILE ALREADY EXISTS', 'HRAFSA_AUDIT_FILE');
        else
            l_utl_id := utl_file.fopen('ENROLL_DIR', l_file_name, 'w');
               /*** Write the header here ***/

            l_line := 'TPA_ID'
                      || ','
                      || 'FIRST NAME'
                      || ','
                      || 'M.I.'
                      || ','
                      || 'LAST NAME'
                      || ','
                      || 'SOCIAL SECURITY NUMBER'
                      || ','
                      || 'STERLING ACCOUNT NUMBER'
                      || ','
                      || 'ACTION'
                      || ','
                      || 'GENDER'
                      || ','
                      || 'ADDRESS'
                      || ','
                      || 'CITY'
                      || ','
                      || 'STATE'
                      || ','
                      || 'ZIP'
                      || ','
                      || 'DAYTIME PHONE'
                      || ','
                      || 'EMAIL ADDRESS'
                      || ','
                      || 'BIRTH DATE'
                      || ','
                      || 'DIVISION CODE'
                      || ','
                      || 'PLAN TYPE'
                      || ','
                      || 'EFFECTIVE DATE'
                      || ','
                      || 'ANNUAL ELECTION'
                      || ','
                      || 'FIRST PAYROLL DATE'
                      || ','
                      || 'PRE-PAY PERIOD CONTRIBUTION'
                      || ','
                      || 'NUMBER OF PAY PERIODS'
                      || ','
                      || 'PAYROLL CYCLE'
                      || ','
                      || 'DEBIT CARD'
                      || ','
                      || 'COVERAGE TIER'
                      || ','
                      || 'TERMINATION DATE'
                      || ','
                      || 'PLAN CODE'
                      || ','
                      || 'GROUP NUMBER'
                      || ','
                      || 'ERROR MESSAGE'
                      || ','
                      || 'ERROR COLUMN'
                      || ','
                      || 'PROCESS STATUS'
                      || ','
                      || 'STATUS';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );



/*** Query for the batch number and write the lines */
            for i in (
                select
                    me.tpa_id,
                    me.first_name,
                    me.middle_name,
                    me.last_name,
                    me.ssn,
                    me.acc_num,
                    me.action,
                    me.gender,
                    me.city,
                    me.state,
                    me.zip,
                    me.day_phone,
                    me.email_address,
                    to_date(me.birth_date, 'MM/DD/YYYY')         birth_date,
                    me.division_code,
                    mp.plan_type,
                    to_date(mp.effective_date, 'MM/DD/YYYY')     effective_date,
                    mp.annual_election,
                    to_date(mp.first_payroll_date, 'MM/DD/YYYY') first_payroll_date,
                    mp.pay_contrb,
                    mp.no_of_periods,
                    mp.pay_cycle,
                    me.debit_card,
                    me.coverage_tier_name,
                    me.plan_code,
                    to_date(mp.termination_date, 'MM/DD/YYYY')   termination_date,
                    me.group_number,
                    me.account_type,
                    me.error_message,
                    mp.status,
                    me.entrp_id,
                    me.error_column,
                    me.process_status,
                    me.mass_enrollment_id
                from
                    mass_enrollments  me,
                    mass_enroll_plans mp
                where
                        me.mass_enrollment_id = mp.mass_enrollment_id
                    and me.batch_number = mp.batch_number
                    and me.batch_number = p_batch_number
                    and me.account_type in ( 'HRA', 'FSA' )
            ) loop
                begin
                    select
                        address
                    into l_address
                    from
                        person p
                    where
                        p.mass_enrollment_id = i.mass_enrollment_id;

                exception
                    when others then
                        l_address := null;
                end;

                l_line := i.tpa_id
                          || ','
                          || i.first_name
                          || ','
                          || i.middle_name
                          || ','
                          || i.last_name
                          || ','
                          || i.ssn
                          || ','
                          || i.acc_num
                          || ','
                          || i.action
                          || ','
                          || i.gender
                          || ','
                          || l_address
                          || ','
                          || i.city
                          || ','
                          || i.state
                          || ','
                          || i.zip
                          || ','
                          || i.day_phone
                          || ','
                          || i.email_address
                          || ','
                          || i.birth_date
                          || ','
                          || i.division_code
                          || ','
                          || i.plan_type
                          || ','
                          || i.effective_date
                          || ','
                          || i.annual_election
                          || ','
                          || i.first_payroll_date
                          || ','
                          || i.pay_contrb
                          || ','
                          || i.no_of_periods
                          || ','
                          || i.pay_cycle
                          || ','
                          || i.debit_card
                          || ','
                          || i.coverage_tier_name
                          || ','
                          || i.plan_code
                          || ','
                          || i.termination_date
                          || ','
                          || i.group_number
                          || ','
                          || i.error_message
                          || ','
                          || i.error_column
                          || ','
                          || i.process_status
                          || ','
                          || i.status;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_entrpid := i.entrp_id;
                l_acc_type := i.account_type;
            end loop;
      /* end of query loop */

            utl_file.fclose(file => l_utl_id);
            begin
                select
                    name
                into l_employer_name
                from
                    enterprise e
                where
                    e.entrp_id = l_entrpid;

            exception
                when others then
                    l_employer_name := null;
            end;

         --EMAIL_FILES(L_FILE_NAME,'Enrollment EDI File Uploaded for '||L_EMPLOYER_NAME||'_'||TO_CHAR(SYSDATE,'MM/DD/YYYY')||'_'||L_ACC_TYPE);
        end if;

    exception
        when others then
            pc_log.log_error('ERROR IN WRITING HRAFSA AUDIT FILE', sqlerrm);
    end write_hrafsa_audit_file;

    procedure write_hsa_audit_file (
        p_batch_number in number,
        p_file_name    in varchar2
    ) is

        l_utl_id        utl_file.file_type;
        l_file_name     varchar2(200);
        l_line          varchar2(3200);
        l_employer_name varchar2(255);
        l_address       varchar2(100);
    begin
        l_file_name := p_batch_number
                       || '_'
                       || p_file_name
                       || '.csv';
        if file_exists(p_batch_number
                       || '_'
                       || p_file_name
                       || '.csv', 'ENROLL_DIR') = 'TRUE' then
            pc_log.log_error(l_file_name || 'FILE ALREADY EXISTS', 'HSA_AUDIT_FILE');
        else
            l_utl_id := utl_file.fopen('ENROLL_DIR', l_file_name, 'w');
         /*** Write the header here ***/

            l_line := 'TITLE'
                      || ','
                      || 'FIRST NAME'
                      || ','
                      || 'MIDDLE NAME'
                      || ','
                      || 'LAST NAME'
                      || ','
                      || 'GENDER'
                      || ','
                      || 'ADDRESS'
                      || ','
                      || 'CITY'
                      || ','
                      || 'STATE'
                      || ','
                      || 'ZIP'
                      || ','
                      || 'PHONE'
                      || ','
                      || 'EMAIL ADDRESS'
                      || ','
                      || 'BIRTH DATE'
                      || ','
                      || 'SSN'
                      || ','
                      || 'DL'
                      || ','
                      || 'PASSPORT'
                      || ','
                      || 'CARRIER'
                      || ','
                      || 'PLAN TYPE'
                      || ','
                      || 'DEDUCTIBLE'
                      || ','
                      || 'PLAN EFFECTIVE DATE'
                      || ','
                      || 'PLAN CODE'
                      || ','
                      || 'OPEN DATE'
                      || ','
                      || 'CHECK NUMBER'
                      || ','
                      || 'CHECK AMOUNT'
                      || ','
                      || 'EMPLOYER CONTRIBUTION'
                      || ','
                      || 'EMPLOYEE CONTRIBUTION'
                      || ','
                      || 'ACCOUNT STATUS'
                      || ','
                      || 'SET UP STATUS'
                      || ','
                      || 'DEBIT CARD'
                      || ','
                      || 'EMPLOYER NAME'
                      || ','
                      || 'BROKER NAME'
                      || ','
                      || 'NOTE'
                      || ','
                      || 'SIGNATURE'
                      || ','
                      || 'GROUP NUMBER'
                      || ','
                      || 'ERROR MESSAGE'
                      || ','
                      || 'ERROR COLUMN'
                      || ','
                      || 'PROCESS STATUS';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );

/*** Query for the batch number and write the lines */
            for i in (
                select
                    me.title,
                    me.first_name,
                    me.middle_name,
                    me.last_name,
                    me.gender,
                    me.city,
                    me.state,
                    me.zip,
                    me.day_phone,
                    me.email_address,
                    to_date(me.birth_date, 'MM/DD/YYYY')     birth_date,
                    me.ssn,
                    me.driver_license,
                    me.passport,
                    me.carrier,
                    me.plan_type,
                    me.deductible,
                    to_date(me.effective_date, 'MM/DD/YYYY') effective_date,
                    me.plan_code,
                    to_date(me.effective_date, 'MM/DD/YYYY') open_date,
                    me.check_number,
                    me.check_amount,
                    me.employer_amount,
                    me.employee_amount,
                    me.account_status,
                    me.setup_status,
                    me.debit_card,
                    me.employer_name,
                    me.broker_name,
                    me.note,
                    me.sign_on_file,
                    me.group_number,
                    me.error_message,
                    me.error_column,
                    me.process_status,
                    me.mass_enrollment_id
                from
                    mass_enrollments me
                where
                        me.batch_number = p_batch_number
                    and me.account_type = 'HSA'
            ) loop
                begin
                    select
                        address
                    into l_address
                    from
                        person p
                    where
                        p.mass_enrollment_id = i.mass_enrollment_id;

                exception
                    when others then
                        l_address := null;
                end;

                l_line := i.title
                          || ','
                          || i.first_name
                          || ','
                          || i.middle_name
                          || ','
                          || i.last_name
                          || ','
                          || i.gender
                          || ','
                          || l_address
                          || ','
                          || i.city
                          || ','
                          || i.state
                          || ','
                          || i.zip
                          || ','
                          || i.day_phone
                          || ','
                          || i.email_address
                          || ','
                          || i.birth_date
                          || ','
                          || i.ssn
                          || ','
                          || i.driver_license
                          || ','
                          || i.passport
                          || ','
                          || i.carrier
                          || ','
                          || i.plan_type
                          || ','
                          || i.deductible
                          || ','
                          || i.effective_date
                          || ','
                          || i.plan_code
                          || ','
                          || i.open_date
                          || ','
                          || i.check_number
                          || ','
                          || i.check_amount
                          || ','
                          || i.employer_amount
                          || ','
                          || i.employee_amount
                          || ','
                          || i.account_status
                          || ','
                          || i.setup_status
                          || ','
                          || i.debit_card
                          || ','
                          || i.employer_name
                          || ','
                          || i.broker_name
                          || ','
                          || i.note
                          || ','
                          || i.sign_on_file
                          || ','
                          || i.group_number
                          || ','
                          || i.error_message;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_employer_name := i.employer_name;
            end loop;
      /* end of query loop */

            utl_file.fclose(file => l_utl_id);

        -- EMAIL_FILES(L_FILE_NAME,'Enrollment EDI File Uploaded for '||L_EMPLOYER_NAME||'_'||TO_CHAR(SYSDATE,'MM/DD/YYYY')||'_HSA');
        end if;

    exception
        when others then
            pc_log.log_error('ERROR IN WRITING HSA AUDIT FILE', sqlerrm);
    end write_hsa_audit_file;

    procedure write_dependent_audit_file (
        p_batch_number in number,
        p_file_name    in varchar2
    ) is

        l_utl_id         utl_file.file_type;
        l_file_name      varchar2(3200);
        l_line           varchar2(3200);
        l_employer_name  varchar2(255);
        l_subscriber_ssn varchar2(30);
    begin
        l_file_name := p_batch_number
                       || '_'
                       || p_file_name
                       || '.csv';
        if file_exists(p_batch_number
                       || '_'
                       || p_file_name
                       || '.csv', 'ENROLL_DIR') = 'TRUE' then
            pc_log.log_error(l_file_name || 'FILE ALREADY EXISTS', 'DEPENDENT_AUDIT_FILE');
        else
            l_utl_id := utl_file.fopen('ENROLL_DIR', l_file_name, 'w');
               /*** Write the header here ***/

            l_line := 'SUBSCRIBER SSN'
                      || ','
                      || 'FIRST NAME'
                      || ','
                      || 'MIDDLE INITIAL'
                      || ','
                      || 'LAST NAME'
                      || ','
                      || 'GENDER'
                      || ','
                      || 'BIRTH DATE'
                      || ','
                      || 'DEPENDENT/BENEFICIARY SSN'
                      || ','
                      || 'DEPENDENT RELATIONSHIP'
                      || ','
                      || 'BENEFICIARY/DEPENDENT'
                      || ','
                      || 'BENEFICIARY TYPE'
                      || ','
                      || 'BENEFICIARY RELATIONSHIP'
                      || ','
                      || 'EFFECTIVE DATE'
                      || ','
                      || 'DISTRIBUTION'
                      || ','
                      || ''
                      || ','
                      || ''
                      || ','
                      || 'DEBIT CARD FLAG'
                      || ','
                      || 'ERROR MESSAGE'
                      || ','
                      || 'ERROR COLUMN';

            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
/*** Query for the batch number and write the lines */
            for i in (
                select
                    md.subscriber_ssn,
                    md.first_name,
                    md.middle_name,
                    md.last_name,
                    md.gender,
                    to_date(md.birth_date, 'MM/DD/YYYY')     birth_date,
                    md.ssn,
                    md.relative,
                    md.dep_flag,
                    md.beneficiary_type,
                    md.beneficiary_relation,
                    to_date(md.effective_date, 'MM/DD/YYYY') effective_date,
                    md.distiribution,
                    md.debit_card_flag,
                    md.error_message,
                    md.error_column
                from
                    mass_enroll_dependant md
                where
                    md.batch_number = p_batch_number
            ) loop
                l_line := i.subscriber_ssn
                          || ','
                          || i.first_name
                          || ','
                          || i.middle_name
                          || ','
                          || i.last_name
                          || ','
                          || i.gender
                          || ','
                          || i.birth_date
                          || ','
                          || i.ssn
                          || ','
                          || i.relative
                          || ','
                          || i.dep_flag
                          || ','
                          || i.beneficiary_type
                          || ','
                          || i.beneficiary_relation
                          || ','
                          || i.effective_date
                          || ','
                          || i.distiribution
                          || ','
                          || ''
                          || ','
                          || ''
                          || ','
                          || i.debit_card_flag
                          || ','
                          || i.error_message
                          || ','
                          || i.error_column;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
                l_subscriber_ssn := i.subscriber_ssn;
            end loop;
      /* end of query loop */

            utl_file.fclose(file => l_utl_id);
            begin
                select
                    name
                into l_employer_name
                from
                    person     p,
                    enterprise e
                where
                        p.ssn = l_subscriber_ssn
                    and e.entrp_id = p.entrp_id
                    and rownum = 1;

            exception
                when others then
                    l_employer_name := null;
            end;

    -- EMAIL_FILES(L_FILE_NAME,'Dependent Enrollment EDI File Uploaded for '||L_EMPLOYER_NAME ||'_'|| TO_CHAR(SYSDATE,'MM/DD/YYYY'));
        end if;

    exception
        when others then
            pc_log.log_error('ERROR IN WRITING DEPENDENT AUDIT FILE', sqlerrm);
    end write_dependent_audit_file;

    procedure notify_annual_election is

        l_utl_id    utl_file.file_type;
        l_file_name varchar2(3200) := 'Daily_annual_election_'
                                      || to_char(sysdate, 'YYYYMMDD')
                                      || '.csv';
    begin
        for i in (
            select
                pc_account.get_acc_num_from_acc_id(a.acc_id)
                || ','
                || replace(
                    pc_person.get_person_name(pc_account.get_acc_num_from_acc_id(a.acc_id)),
                    ','
                )
                || ','
                || to_char(b.original_annual_election)
                || ','
                || to_char(a.annual_election)
                || ','
                || nvl((
                    select
                        pay_contrb
                    from
                        mass_enroll_plans
                    where
                            ben_plan_id = a.ben_plan_id
                        and trunc(creation_date) = trunc(b.creation_date)
                ),
                       0)
                || ','
                || replace(
                    pc_entrp.get_entrp_name(b.entrp_id),
                    ','
                )
                || ','
                || pc_entrp.get_acc_num(b.entrp_id) line
            from
                ben_plan_enrollment_setup a,
                ben_life_event_history    b
            where
                    a.ben_plan_id = b.ben_plan_id
                and b.life_event_code = 'ANNUAL_ELEC_UPDATE'
--       and trunc(b.creation_date)=trunc(a.creation_date)
                and trunc(b.creation_date) = trunc(sysdate) - 0
            order by
                b.creation_date
        ) loop
            if not utl_file.is_open(l_utl_id) then
                l_utl_id := utl_file.fopen('MAILER_DIR', l_file_name, 'W');
                utl_file.put_line(l_utl_id, 'Account Number,Name,Original Election Amount,New Election Amount,Per Pay Period Amount,Employer Name,ER Account Number'
                );
            end if;

            utl_file.put_line(l_utl_id, i.line);
        end loop;

        utl_file.fclose_all;
        if file_exists(l_file_name, 'MAILER_DIR') = 'TRUE' then
            mail_utility.send_file_in_emails(
                p_from_email   => 'oracle@sterlingadministration.com',
                p_to_email     => 'it-team@sterlingadministration.com,clientservices@sterlingadministration.com,sarah.soman@sterlingadministration.com'
                ,
                p_file_name    => l_file_name,
                p_sql          => null,
                p_html_message => null,
                p_report_title => 'Daily annual election Report for ' || to_char(sysdate, 'MM/DD/YYYY')
            );
        end if;

    exception
        when others then
            utl_file.fclose_all;
            dbms_output.put_line(sqlerrm);
    end;

    procedure reinstate_terminated_plans (
        p_user_id      in number,
        p_batch_number in number
    ) is
    begin
        pc_log.log_error('PROCESS_UPLOAD.reinstate_terminated_plans', 'In reinstate');
        for x in (
            select
                me.acc_id,
                me.entrp_id,
                format_to_date(mep.termination_date) termination_date,
                mep.plan_type,
                bp.ben_plan_id,
                mep.mass_enroll_plan_id,
                mep.effective_date,
                mep.annual_election
            from
                mass_enrollments          me,
                mass_enroll_plans         mep,
                ben_plan_enrollment_setup bp
            where
                    me.mass_enrollment_id = mep.mass_enrollment_id
                and mep.plan_type = bp.plan_type
                and me.acc_id = bp.acc_id
                and mep.status is null
                and bp.status in ( 'A', 'I' )
                and ( me.process_status is null
                      or me.process_status = 'W' )
                and bp.ben_plan_id_main = mep.er_ben_plan_id
                and me.batch_number = p_batch_number
                   --AND   BP.TERMINATED = 'Y'
                and bp.termination_req_date is not null
                and mep.termination_date is null
                and bp.effective_end_date is not null
                and to_date(mep.effective_date, 'mm/dd/rrrr') >= bp.plan_start_date
                and to_date(mep.effective_date, 'mm/dd/rrrr') <= bp.plan_end_date
        ) loop
            pc_log.log_error('Process_upload.reinstate_terminated_plans', 'In Proc');
            process_annual_election_change(p_user_id, p_batch_number);
             --Once annual election gets updated here, next time this proc will not be effective
             --because old and new annual election will be same.

            update ben_plan_enrollment_setup
            set
                status = 'A',
                terminated = null,
                termination_req_date = null,
                effective_end_date = null,
              --annual_election = X.annual_election,--alreay updated in process_annual change
                effective_date =
                    case
                        when plan_type in ( 'TRN', 'PKG' ) then
                            effective_date
                        else
                            to_date(x.effective_date, 'mm/dd/rrrr')
                    end,
                life_event_code = 'LOA_RETURN',
                last_update_date = sysdate
            where
                ben_plan_id = x.ben_plan_id;

        end loop;

    exception
        when others then
            pc_log.log_error('Process_upload.reinstate_terminated_plans', sqlerrm);
    end reinstate_terminated_plans;

-- 9071 Jagadeesh
    procedure process_tdameritrade_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) is

        l_batch_number number;
        lv_dest_file   varchar2(255);
        l_note         varchar2(255);
        l_user_name    varchar2(255);
        l_count        number;
    begin
        export_td_ameritrade_file(pv_file_name, p_user_id, l_batch_number);
        x_batch_number := l_batch_number;
        for x in (
            select
                user_name
            from
                sam_users
            where
                user_id = p_user_id
        ) loop
            l_user_name := x.user_name;
        end loop;
        -- Validations
        update investment_staging
        set
            process_status = 'E',
            process_message = 'Account does not exist'
        where
            acc_id is null
            and batch_number = l_batch_number;

    -- Insert into INVESTMENT
        for y in (
            select
                investment_acc_num,
                to_date(market_date, 'MM/DD/YYYY') market_date,
                invest_id,
                sum(market_value)                  market_value
            from
                investment_staging
            where
                    batch_number = l_batch_number
                and acc_id is not null
            group by
                investment_acc_num,
                market_date,
                invest_id
        ) loop
            l_note := 'Account balance as of '
                      || to_char(y.market_date, 'MM/DD/YYYY')
                      || '('
                      || l_user_name
                      || ')';

            select
                count(*)
            into l_count
            from
                invest_transfer
            where
                    investment_id = y.invest_id
                and invest_date = y.market_date;

            if l_count > 0 then
                update invest_transfer
                set
                    invest_amount = y.market_value,
                    note = l_note  -- Added by Joshi for #9385
                    ,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                        investment_id = y.invest_id
                    and invest_date = y.market_date;

                if sql%rowcount > 0 then
                    update investment_staging
                    set
                        process_status = 'S',
                        process_message = 'Successfully uploaded'
                    where
                            invest_id = y.invest_id
                        and batch_number = l_batch_number;

                end if;

            else
                insert into invest_transfer (
                    transfer_id,
                    investment_id,
                    invest_date,
                    invest_amount,
                    note,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( transfer_seq.nextval,
                           y.invest_id,
                           y.market_date,
                           y.market_value,
                           l_note,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id );

                if sql%rowcount > 0 then
                    update investment_staging
                    set
                        process_status = 'S',
                        process_message = 'Successfully uploaded'
                    where
                            invest_id = y.invest_id
                        and batch_number = l_batch_number;

                end if;

            end if;

        end loop;

        x_batch_number := l_batch_number;
    end process_tdameritrade_file;
-- 9071 Jagadeesh
    procedure export_td_ameritrade_file (
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
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_sqlerrm       varchar2(32000);
        l_create_error exception;
        l_batch_number  number;
        l_valid_plan    number(10);
        l_acc_id        number(10);
        x_return_status varchar2(10);
        x_error_message varchar2(2000);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
    begin
        x_batch_number := batch_num_seq.nextval;
        pc_log.log_error('PROCESS_UPLOAD.export_td_ameritrade_file', 'pv_file_name :' || pv_file_name);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
  /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', pv_file_name, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            l_create_ddl := 'ALTER TABLE TD_AMERITRADE_EXTERNAL ACCESS PARAMETERS ('
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
                            || '  LOCATION (ENROLL_DIR:'''
                            || lv_dest_file
                            || ''')';

            execute immediate l_create_ddl;
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of tdameritrade file' || sqlerrm;
                pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
                l_files.delete;
                l_files.extend(3);
                l_files(1) := '/u01/app/oracle/oradata/enroll/' || lv_dest_file;
                l_files(2) := '/u01/app/oracle/oradata/enroll/'
                              || lv_dest_file
                              || '.bad';
                l_files(3) := '/u01/app/oracle/oradata/enroll/' || l_log_file_name;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
                    to_names     => 'techsupport@sterlingadministration.com',
                    subject      => 'Error in TD Ameritrade file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );

                raise l_create_error;
        end;

        begin
     /** TD_AMERITRADE_STAGING **/
            insert into investment_staging (
                batch_number,
                investment_acc_num,
                first_name,
                last_name,
                market_date,
                market_value,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            )
                select
                    x_batch_number,
                    strip_bad(account_num),
                    first_name,
                    last_name,
                    market_date,
                    to_number(replace(market_value, ',', '')),
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id
                from
                    td_ameritrade_external;

            pc_log.log_error('PROCESS_UPLOAD', 'Number of rows insert into td_ameritrade enrollemnts' || sql%rowcount);
        exception
            when others then
                l_sqlerrm := 'Error in inserting into td_ameritrade_enrollments ' || sqlerrm;
                pc_log.log_error('PROCESS_UPLOAD', 'Error in inserting into td_ameritrade enrollemnts' || l_sqlerrm);
                raise l_create_error;
        end;
--       UPDATE Investment_staging  ## 8074 FOR AMERITRADE
        update investment_staging a
        set
            a.acc_id = (
                select
                    i.acc_id
                from
                    investment i
                where
                        strip_bad(i.invest_acc) = a.investment_acc_num
                    and invest_id = g_ameritrade_acct_no
                    and end_date is null
            ), -- #9837 Added by Joshi for prod fix,
            a.invest_id = (
                select
                    i.investment_id
                from
                    investment i
                where
                        strip_bad(i.invest_acc) = a.investment_acc_num
                    and invest_id = g_ameritrade_acct_no
                    and end_date is null
            )  -- #9837 Added by Joshi for prod fix,
        where
            a.batch_number = x_batch_number;

  -- Close the file if something goes wrong.
        if utl_file.is_open(l_file) then
            utl_file.fclose(l_file);
        end if;
  -- Delete file from wwv_flows
        delete from wwv_flow_files
        where
            name = pv_file_name;

        pc_log.log_error('process_upload.export_td_ameritrade_file', 'End');
    exception
        when others then
            pc_log.log_error('process_upload.export_td_ameritrade_file', 'In Export ameritrade Excp' || sqlerrm);
            rollback;
            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_td_ameritrade_file;

-- 9072 Jagadeesh
    function get_file_upload_history (
        p_entrp_code   varchar2,
        p_from_date    varchar2,
        p_to_date      varchar2,
        p_sort_column  varchar2,
        p_sort_order   varchar2,
        p_account_type varchar2
    ) return file_upload_history_t
        pipelined
        deterministic
    is

        l_file_upload_history file_upload_history_row_t;
        v_order               varchar2(1000);
        v_sql                 varchar2(4000);
        v_sql_cur             l_cursor;
        v_from_date           date;
        v_to_date             date;
        v_sort_column         varchar2(250);
        v_sort_order          varchar2(10);
    begin
        if
            nvl(
                rtrim(ltrim(p_sort_order)),
                '*'
            ) in ( 'ASC', 'DESC' )
            and nvl(p_sort_column, '*') <> '*'
        then
            v_sort_order := p_sort_order;
            v_order := ' order by '
                       || p_sort_column
                       || ' '
                       || p_sort_order;
        else
            v_sort_order := 'DESC';
            v_sort_column := 'CREATION_DATE';
            v_order := ' order by '
                       || p_sort_column
                       || ' '
                       || p_sort_order;
        end if;

        if is_date(p_from_date, 'MM/DD/YYYY') = 'Y' then
            v_from_date := to_date ( p_from_date, 'MM/DD/YYYY' );
        else
            v_from_date := null;
        end if;

        if
            v_from_date is not null
            and is_date(p_to_date, 'MM/DD/YYYY') = 'Y'
        then
            v_to_date := to_date ( p_to_date, 'MM/DD/YYYY' );
        else
            v_to_date := null;
            v_from_date := null;
        end if;
     -- Exists condition for TPA_ID = EASE added by Swamy for Ticket#9840 on 18/05/2021
        v_sql := ' select FILE_UPLOAD_ID
                    ,F.ENTRP_ID
                    ,E.NAME
                    ,BATCH_NUMBER
                    ,FILE_NAME
                    ,FILE_UPLOAD_RESULT
                    ,F.CREATION_DATE
                    ,ACCOUNT_TYPE
                    ,FILE_TYPE
                FROM File_upload_history f, Enterprise E
               WHERE F.Entrp_id          = E.Entrp_id
                 AND F.Enrollment_source = ''EDI''
                 AND File_upload_result like ''%failed%''
                 AND ENTRP_CODE          = '''
                 || p_entrp_code
                 || '''
                 AND Trunc(F.CREATION_DATE) >= NVL('''
                 || trunc(v_from_date)
                 || ''',Trunc(F.CREATION_DATE)) AND Trunc(F.CREATION_DATE) <= NVL('''
                 || trunc(v_to_date)
                 || ''',Trunc(F.CREATION_DATE))
                  AND (EXISTS (select *
                                  From mass_enrollments me
                                 where me.batch_number = f.batch_number
                                   and me.TPA_ID = ''EASE''
                                   and ( me.Error_message NOT LIKE ''%Successfully%'' ))
                  OR EXISTS (   select *
                                  From mass_enrollments me, mass_enroll_plans mp
                                 where me.batch_number = f.batch_number
                                   and me.mass_enrollment_id = mp.mass_enrollment_id(+)
                                   and me.batch_number = mp.batch_number(+)
                                   and ( me.Error_message NOT LIKE ''%Successfully%'' OR NVL(mp.status, ''S'') <> ''S'')))';
                    /* commented by Joshi for 9694. check for error in the mass_enroll_plans also
                 AND EXISTS ( SELECT *
                       FROM Mass_Enrollments
                      WHERE Batch_number = f.batch_number
                        AND Error_message NOT LIKE ''%Successfully%'')' */

        if p_account_type is not null then
            v_sql := v_sql
                     || ' and account_type =  '''
                     || p_account_type
                     || '''';
        end if;

        v_sql := v_sql || v_order;
        open v_sql_cur for v_sql;

        loop
            fetch v_sql_cur into
                l_file_upload_history.file_upload_id,
                l_file_upload_history.entrp_id,
                l_file_upload_history.name,
                l_file_upload_history.batch_number,
                l_file_upload_history.file_name,
                l_file_upload_history.file_upload_result,
                l_file_upload_history.creation_date,
                l_file_upload_history.account_type,
                l_file_upload_history.file_type;

            exit when v_sql_cur%notfound;
            pipe row ( l_file_upload_history );
        end loop;

        close v_sql_cur;
    exception
        when others then
            null;
    end get_file_upload_history;

-- 9072 Jagadeesh
    function get_discrepancy_report (
        p_batch_number in number,
        p_file_name    varchar2
    ) return discrepancy_report_t
        pipelined
        deterministic
    is
        l_discrepancy_report discrepancy_report_row_t;
        l_file_type          varchar2(100);
    begin
        select
            file_type
        into l_file_type
        from
            file_upload_history
        where
                batch_number = p_batch_number
            and file_name = p_file_name;

        if l_file_type = 'employee_eligibility' then
            for x in (
                select
                    tpa_id,
                    mass_enrollment_id,
                    first_name,
                    middle_name,
                    last_name,
                    acc_num,
                    'Error' process_status,
                    error_message,
                    error_value
                from
                    mass_enrollments
                where
                        batch_number = p_batch_number
                    and error_value is not null
            ) loop
                l_discrepancy_report.tpa_id := x.tpa_id;
                l_discrepancy_report.first_name := x.first_name;
                l_discrepancy_report.middle_name := x.middle_name;
                l_discrepancy_report.last_name := x.last_name;
                l_discrepancy_report.account_number := x.acc_num;
                l_discrepancy_report.processing_status := x.process_status;
                l_discrepancy_report.processing_message := get_enrollment_errors(x.mass_enrollment_id);
                l_discrepancy_report.error_value := x.error_value;
                pipe row ( l_discrepancy_report );
            end loop;

        else
            for x in (
                select
                    null    tpa_id,
                    first_name,
                    middle_name,
                    last_name,
                    acc_num,
                    'Error' process_status,
                    error_message,
                    error_value
                from
                    mass_enroll_dependant
                where
                        batch_number = p_batch_number
                    and error_message not like '%Successfully%'
            ) loop
                l_discrepancy_report.tpa_id := x.tpa_id;
                l_discrepancy_report.first_name := x.first_name;
                l_discrepancy_report.middle_name := x.middle_name;
                l_discrepancy_report.last_name := x.last_name;
                l_discrepancy_report.account_number := x.acc_num;
                l_discrepancy_report.processing_status := x.process_status;
                l_discrepancy_report.processing_message := x.error_message;
                l_discrepancy_report.error_value := x.error_value;
                pipe row ( l_discrepancy_report );
            end loop;
        end if;

    end get_discrepancy_report;

-- Added by Joshi for 9694.
    function get_enrollment_errors (
        p_mass_enrollment_id in number
    ) return varchar2 is
        l_error varchar2(4000);
    begin
        select
            listagg(status, ',') within group(
            order by
                status
            ) errors
        into l_error
        from
            (
                select distinct
                    status
                from
                    mass_enroll_plans
                where
                    mass_enrollment_id = p_mass_enrollment_id
                union
                select
                    error_message status
                from
                    mass_enrollments
                where
                    mass_enrollment_id = p_mass_enrollment_id
            );

        return l_error;
    end get_enrollment_errors;
-- Code ends here Joshi for 9694.

-- Procedure added by Swamy for Ticket#9840 on 18/05/2021
    procedure export_ease_enrollment_file (
        pv_file_name   in varchar2,
        x_batch_number out number
    ) as

        l_file          utl_file.file_type;
        l_buffer        raw(32767);
        l_amount        binary_integer := 32767;
        l_pos           integer := 1;
        l_blob          blob;
        l_blob_len      integer;
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        lv_create exception;
        l_row_count     number := -1;
        l_sqlerrm       varchar2(32000);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
        l_entrp_code    varchar(100);
        l_entrp_id      number;
        l_file_id       number;
        l_batch_number  number;
        l_plan_type     varchar2(100);
        l_account_type  varchar2(100);
        l_entrp_acc_id  account.acc_id%type;
        l_entrp_acc_num account.acc_num%type;
        l_state         varchar2(100);
        l_length        varchar2(100);
        l_plan_name     varchar2(100);
        l_plan_code     account.plan_code%type;
    begin
        x_batch_number := batch_num_seq.nextval;
        l_batch_number := x_batch_number;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE', 'Destination file ' || lv_dest_file);

      /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        l_create_ddl := 'ALTER TABLE MASS_EASE_ENROLLMENTS_EXTERNAL ACCESS PARAMETERS ('
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
                        || '  LOCATION (ENROLL_DIR:'''
                        || lv_dest_file
                        || ''')';

        pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE', 'l_create_ddl  ' || l_create_ddl);
        begin
            execute immediate l_create_ddl;
        exception
            when others then
                l_sqlerrm := sqlerrm;
                raise lv_create;
        end;

        for x in (
            select distinct
                client_id
            from
                mass_ease_enrollments_external
        ) loop
            l_entrp_code := x.client_id;
            l_account_type := 'HSA';
        end loop;

        for y in (
            select
                a.entrp_id,
                a.acc_id,
                a.acc_num,
                a.plan_code
            from
                account    a,
                enterprise e
            where
                    a.entrp_id = e.entrp_id
                and a.account_type = l_account_type
                and e.entrp_code = l_entrp_code
                and a.account_status = '1'
        )   -- Added by Swamy for Ticket#9937 on 09/06/2021.
         loop
            l_entrp_id := y.entrp_id;
            l_entrp_acc_id := y.acc_id;
            l_entrp_acc_num := y.acc_num;
            l_plan_code := y.plan_code;
        end loop;

        for j in (
            select
                plan_name
            from
                plans
            where
                    plan_sign = 'SHA'
                and plan_code = l_plan_code
        ) loop
            l_plan_name := j.plan_name;
        end loop;

        pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE', 'L_Entrp_Id '
                                                        || l_entrp_id
                                                        || 'l_plan_name :='
                                                        || l_plan_name);
        pc_file_upload.insert_file_upload_history(
            p_batch_num         => l_batch_number,
            p_user_id           => 427,
            pv_file_name        => pv_file_name,
            p_entrp_id          => l_entrp_id,
            p_action            => 'ENROLLMENT',
            p_account_type      => 'HSA',
            p_enrollment_source => 'EDI',
            p_file_type         => 'employee_eligibility',
            x_file_upload_id    => l_file_id
        );

        pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE', 'INSERT INTO MASS_ENROLLMENTS ' || l_entrp_code);
        insert into mass_enrollments (
            mass_enrollment_id,
            title,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            driver_license,
            passport,
            carrier,
            plan_type,
            deductible,
            effective_date,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            check_number,
            check_amount,
            employer_amount,
            employee_amount,
            entrp_acc_id,
            employer_name,
            broker_name,
            broker_id,
            error_message,
            sign_on_file,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            tpa_id,
            batch_number,
            division_code,
            enrollment_source,
            termination_date,
            annual_election
        )
            select
                mass_enrollments_seq.nextval,
                null                                   title,
                first_name,
                substr(middle_name, 1, 1),
                last_name,
                decode(
                    upper(sex),
                    'M',
                    'M',
                    'F',
                    'F',
                    'FEMALE',
                    'F',
                    'MALE',
                    'M',
                    null
                )                                      sex -- added by jaggi #10836 Gender should allow only M,F,MALE,FEMALE apart from this shold enter null.
                ,
                ( initcap(address_1)
                  || ' '
                  || initcap(ltrim(rtrim(address_2))) )  address    -- Production issue to concatinate address1 and address2 on 26/08/2021 Swamy Ticket#10263
                  ,
                initcap(city)                          city,
                state,
                zip,
                null                                   contact_method,
                null                                   day_phone,
                null                                   evening_phone,
                email                                  email_address,
                format_date(birth_date)                birth_date,
                case
                    when length(ssn) < 9 then
                        lpad(ssn, 9, '0')
                    else
                        replace(ssn, '-')
                end                                    ssn,
                null                                   driver_license,
                null                                   passport,
                replace(carrier, ';', '&'),
                initcap('Simple Hsa')                  plan_type,
                null                                   deductible,
                format_date(effective_date)            effective_date,
                decode(
                    pc_entrp.card_allowed(l_entrp_id),
                    0,
                    'Yes',
                    'NO'
                )                                      debit_card -- Added by Jaggi #10953
                ,
                l_plan_name                            plan_code,
                format_date(effective_date)            start_date,
                sysdate                                registration_date,
                nvl(employee_status, 'Active')         account_status,
                'Yes'                                  setup_status,
                null                                   check_number,
                null                                   check_amount,
                null                                   employer_amount,
                null                                   employee_amount,
                l_entrp_acc_id,
                company                                employer_name,
                null                                   broker_name,
                null                                   broker_id,
                null,
                'Yes'                                  sign_on_file,
                null                                   note,
                sysdate,
                0,
                sysdate,
                0,
                null,
                l_entrp_id,
                l_entrp_acc_num,
                'EASE'                                 tpa_id,
                x_batch_number,
                null                                   division_code,
                'EDI',
                format_date(termination_date)          termination_date,
                regexp_replace(election, '[^0-9]', '') election
            from
                mass_ease_enrollments_external a
            where
                ( first_name is not null
                  or ssn is not null )
                and lower(plan_type) = lower('Health Savings Account');

        pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE', 'after INSERT INTO MASS_ENROLLMENTS x_batch_number ' || x_batch_number);
        for x in (
            select
                count(*) cnt
            from
                mass_enrollments
            where
                batch_number = x_batch_number
        ) loop
            if x.cnt = 0 then
                l_sqlerrm := 'Please check the file, template might be incorrect or file must be empty';
                raise lv_create;
            end if;
        end loop;

        for k in (
            select
                mass_enrollment_id,
                state,
                length(state) len
            from
                mass_enrollments
            where
                batch_number = x_batch_number
        ) loop
            l_state := k.state;
            l_length := k.len;
     -- If the file contains the description then we need to extract the code.
            if l_length > 2 then
                for n in (
                    select
                        lookup_code
                    from
                        table ( pc_lookups.get_lookup_values('STATE') )
                    where
                        lower(description) = lower(l_state)
                ) loop
                    l_state := n.lookup_code;
                end loop;
            end if;

            update mass_enrollments
            set
                action =
                    case
                        when pc_account.check_duplicate(
                            replace(ssn, '-'),
                            group_number,
                            replace(employer_name, ','),
                            'HSA',
                            null
                        ) = 'N' then
                            'N'
                        else
                            'C'
                    end,
                state = l_state
            where
                    batch_number = x_batch_number
                and mass_enrollment_id = k.mass_enrollment_id;

        end loop;

        commit;
        pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE end', sql%rowcount);
    exception
        when lv_create then
            rollback;
            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => 427,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => 'HSA',
                p_enrollment_source => 'EDI',
                p_file_type         => 'employee_eligibility',
                p_error             => l_sqlerrm,
                x_file_upload_id    => l_file_id
            );
        -- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
            pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE error lv_create ', sqlerrm
                                                                             || ' lv_dest_file :='
                                                                             || lv_dest_file);
        -- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;

            pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
        /*l_files.delete;
        l_files.extend(3);
        l_files(1) := '/u01/app/oracle/oradata/enroll/'||lv_dest_file;
        l_files(2) := '/u01/app/oracle/oradata/enroll/'||lv_dest_file||'.bad';
        l_files(3) := '/u01/app/oracle/oradata/enroll/'||l_log_file_name;
        mail_utility.email_files(
                         from_name    => 'enrollments@sterlingadministration.com',
                         to_names     =>  'techsupport@sterlingadministration.com,productionsupport@sterlingadministration.com', --'srinivasa.swamy@sterlingadministration.com,Jagadeesh.Reddy@sterlingadministration.com,piyush.kumar@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,shivani.jaiswal@sterlingadministration.com,srinivasulu.gudur@sterlingadministration.com, vhsqateam@sterlingadministration.com',
                         subject      => 'Error in Enrollment file Upload '||lv_dest_file,
                         html_message => l_sqlerrm,
                         attach       => samfiles('/u01/app/oracle/oradata/enroll/'||lv_dest_file));
        */   -- Commented by Swamy for Ticket#10080 on 28/07/2021
            pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE error lv_create', l_sqlerrm);
        when others then
            rollback;
            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => 427,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => 'HSA',
                p_enrollment_source => 'EDI',
                p_file_type         => 'employee_eligibility',
                p_error             => sqlerrm,
                x_file_upload_id    => l_file_id
            );
       -- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
            pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE error others ', sqlerrm
                                                                          || ' lv_dest_file :='
                                                                          || lv_dest_file);
       -- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;

            pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
            l_files.delete;
            l_files.extend(3);
            l_files(1) := '/u01/app/oracle/oradata/enroll/' || lv_dest_file;
            l_files(2) := '/u01/app/oracle/oradata/enroll/'
                          || lv_dest_file
                          || '.bad';
            l_files(3) := '/u01/app/oracle/oradata/enroll/' || l_log_file_name;
            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
                to_names     => 'techsupport@sterlingadministration.com,productionsupport@sterlingadministration.com', --'srinivasa.swamy@sterlingadministration.com,Jagadeesh.Reddy@sterlingadministration.com,piyush.kumar@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,shivani.jaiswal@sterlingadministration.com,srinivasulu.gudur@sterlingadministration.com, vhsqateam@sterlingadministration.com', --'techsupport@sterlingadministration.com,productionsupport@sterlingadministration.com',
                subject      => 'Error in Enrollment file Upload ' || lv_dest_file,
                html_message => sqlerrm,
                attach       => samfiles('/u01/app/oracle/oradata/enroll/' || lv_dest_file)
            );

            pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE others', sqlerrm);
    end export_ease_enrollment_file;

-- Procedure added by Swamy for Ticket#9912 on 10/08/2021
    procedure process_mass_lsa_enrollments (
        pv_file_name   in varchar2,
        pv_entrp_id    in number,
        p_user_id      in number,
        p_account_type in varchar2
    ) is
        l_batch_number number;
    begin
        pc_log.log_error('process_mass_enrollments', 'In process_mass_enrollments');
        export_enrollment_file(pv_file_name, pv_entrp_id, p_user_id, null, l_batch_number);
        validate_lsa_enrollments(pv_entrp_id, p_user_id, l_batch_number, p_account_type);
        validate_enrollments(pv_entrp_id, p_user_id, l_batch_number);
        process_enrollments(pv_entrp_id, l_batch_number);
        commit;
    end process_mass_lsa_enrollments;

-- Procedure added by Swamy for Ticket#9912 on 10/08/2021
    procedure validate_lsa_enrollments (
        pv_entrp_id    in number,
        p_user_id      in number,
        p_batch_number in number,
        p_account_type in varchar2
    ) is
        l_batch_number number;
    begin
    -- uploaded_screen is used to identity from which screen the data is uploaded (from HSA/LSA screen), cannot use account_type column bcos account type is based on group number given in the excel file.
    -- Testing team loads LSA group no in HSA and vice versa, this gives wrong result in Last upload Result section in the apex screen
        update mass_enrollments
        set
            account_type = nvl(account_type, p_account_type),
            sign_on_file = decode(p_account_type, 'LSA', 'Y', sign_on_file),
            uploaded_screen = p_account_type
        where
            batch_number = p_batch_number;

        if p_account_type = 'LSA' then
            update mass_enrollments
            set
                error_message = 'Only LSA Enrollments are Allowed',
                error_column = 'Account_Type',
                error_value = 'Account_Type:' || account_type
            where
                    batch_number = p_batch_number
                and nvl(account_type, 'LSA') <> 'LSA'
                and error_message is null;

            update mass_enrollments
            set
                error_message = 'Incorrect Plan Code for LSA',
                error_column = 'plan_code',
                error_value = 'plan_code:' || plan_code
            where
                    batch_number = p_batch_number
                and nvl(account_type, 'LSA') = 'LSA'
                and upper(plan_code) <> upper('Lifestyle-Spending-Account')
                and error_message is null;

        else
            update mass_enrollments
            set
                error_message = 'Only HSA Enrollments are Allowed',
                error_column = 'Account_Type',
                error_value = 'Account_Type:' || account_type
            where
                    batch_number = p_batch_number
                and nvl(account_type, 'HSA') <> 'HSA'
                and error_message is null;

            update mass_enrollments
            set
                error_message = 'Incorrect Plan Code for HSA',
                error_column = 'plan_code',
                error_value = 'plan_code:' || plan_code
            where
                    batch_number = p_batch_number
                and nvl(account_type, 'HSA') = 'HSA'
                and upper(plan_code) = upper('Lifestyle-Spending-Account')
                and error_message is null;

        end if;

    end validate_lsa_enrollments;
-- Added Jaggi #10125
    procedure export_ease_fsa_enrollment_file (
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
        exc_no_file exception;
        lv_create exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_sqlerrm       varchar2(32000);
        l_create_error exception;
        l_batch_number  number;
        l_valid_plan    number(10);
        l_acc_id        number(10);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
        l_group_number  varchar(100);
        l_entrp_id      number;
        l_file_id       number;
        l_account_type  varchar2(100);
        l_entrp_code    varchar(100);
        l_entrp_acc_id  account.acc_id%type;
        l_entrp_acc_num account.acc_num%type;
        l_state         varchar2(100);
        l_length        varchar2(100);
        l_plan_name     varchar2(100);
        l_plan_code     account.plan_code%type;
        x_return_status varchar2(10);
        x_error_message varchar2(2000);
    begin
        x_batch_number := batch_num_seq.nextval;
        l_batch_number := x_batch_number;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('EXPORT_EASE_FSA_ENROLLMENT_FILE', 'Destination file ' || lv_dest_file);

      /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        l_create_ddl := 'ALTER TABLE MASS_FSA_EASE_ENROLL_EXTERNAL ACCESS PARAMETERS ('
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
                        || '  LOCATION (ENROLL_DIR:'''
                        || lv_dest_file
                        || ''')';

        pc_log.log_error('EXPORT_EASE_FSA_ENROLLMENT_FILE', 'l_create_ddl  ' || l_create_ddl);
        begin
            execute immediate l_create_ddl;
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of fsa renewals file' || sqlerrm;
                pc_file.extract_error_from_log(lv_dest_file || '.log', 'ENROLL_DIR', l_log_file_name);
                l_files.delete;
                l_files.extend(3);
                l_files(1) := '/u01/app/oracle/oradata/sam19qa/enroll/' || lv_dest_file;
                l_files(2) := '/u01/app/oracle/oradata/sam19qa/enroll/'
                              || lv_dest_file
                              || '.bad';
                l_files(3) := '/u01/app/oracle/oradata/sam19qa/enroll/' || l_log_file_name;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
          --to_names     => 'techsupport@sterlingadministration.com',
                    to_names     => 'Jagadeesh.Reddy@sterlingadministration.com; piyush.kumar@sterlingadministration.com, vhsqateam@sterlingadministration.com'
                    ,  -- InternalPurpouse
                    subject      => 'Error in EASE FSA Enrollment file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );
--         attach => samfiles('/u01/app/oracle/oradata/sam19qa/enroll/'||lv_dest_file));
                raise l_create_error;
        end;

  --Delete already existing records.
        for x in (
            select
                mass_enrollment_id
            from
                mass_enrollments              me,
                mass_fsa_ease_enroll_external b
            where
                replace(me.ssn, '-') = replace(b.ssn, '-')
        ) loop
            -- Added by Jaggi ##9547
            insert into mass_enrollments_history (
                mass_enroll_history_id,
                mass_enrollment_id,
                title,
                first_name,
                middle_name,
                last_name,
                gender,
                address,
                city,
                state,
                zip,
                contact_method,
                day_phone,
                evening_phone,
                email_address,
                birth_date,
                ssn,
                driver_license,
                passport,
                carrier,
                plan_type,
                deductible,
                effective_date,
                debit_card,
                plan_code,
                start_date,
                registration_date,
                account_status,
                setup_status,
                check_number,
                check_amount,
                employer_amount,
                employee_amount,
                entrp_acc_id,
                employer_name,
                broker_name,
                error_message,
                sign_on_file,
                note,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                error_column,
                entrp_id,
                group_number,
                bps_hra_plan,
                annual_election,
                issue_conditional,
                account_type,
                broker_id,
                health_fsa_flag,
                hfsa_effective_date,
                hfsa_annual_election,
                dep_fsa_flag,
                dfsa_effective_date,
                dfsa_annual_election,
                transit_fsa_flag,
                transit_effective_date,
                transit_annual_election,
                parking_fsa_flag,
                parking_effective_date,
                parking_annual_election,
                bicycle_effective_date,
                bicycle_fsa_flag,
                bicycle_annual_election,
                post_ded_fsa_flag,
                post_ded_effective_date,
                post_ded_annual_election,
                division_code,
                pers_id,
                acc_id,
                acc_num,
                batch_number,
                coverage_tier_name,
                hra_fsa_flag,
                action,
                process_status,
                tpa_id,
                orig_sys_vendor_ref,
                enrollment_source,
                termination_date,
                error_value
            )
                select
                    mass_enroll_history_seq_no.nextval,
                    mass_enrollment_id,
                    title,
                    first_name,
                    middle_name,
                    last_name,
                    gender,
                    address,
                    city,
                    state,
                    zip,
                    contact_method,
                    day_phone,
                    evening_phone,
                    email_address,
                    birth_date,
                    ssn,
                    driver_license,
                    passport,
                    carrier,
                    plan_type,
                    deductible,
                    effective_date,
                    debit_card,
                    plan_code,
                    start_date,
                    registration_date,
                    account_status,
                    setup_status,
                    check_number,
                    check_amount,
                    employer_amount,
                    employee_amount,
                    entrp_acc_id,
                    employer_name,
                    broker_name,
                    error_message,
                    sign_on_file,
                    note,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    error_column,
                    entrp_id,
                    group_number,
                    bps_hra_plan,
                    annual_election,
                    issue_conditional,
                    account_type,
                    broker_id,
                    health_fsa_flag,
                    hfsa_effective_date,
                    hfsa_annual_election,
                    dep_fsa_flag,
                    dfsa_effective_date,
                    dfsa_annual_election,
                    transit_fsa_flag,
                    transit_effective_date,
                    transit_annual_election,
                    parking_fsa_flag,
                    parking_effective_date,
                    parking_annual_election,
                    bicycle_effective_date,
                    bicycle_fsa_flag,
                    bicycle_annual_election,
                    post_ded_fsa_flag,
                    post_ded_effective_date,
                    post_ded_annual_election,
                    division_code,
                    pers_id,
                    acc_id,
                    acc_num,
                    batch_number,
                    coverage_tier_name,
                    hra_fsa_flag,
                    action,
                    process_status,
                    tpa_id,
                    orig_sys_vendor_ref,
                    enrollment_source,
                    termination_date,
                    error_value
                from
                    mass_enrollments
                where
                    mass_enrollment_id = x.mass_enrollment_id;
            -----
            delete from mass_enroll_plans
            where
                mass_enrollment_id = x.mass_enrollment_id;

            delete from mass_enrollments
            where
                mass_enrollment_id = x.mass_enrollment_id;

        end loop;

        for x in (
            select distinct
                client_id
            from
                mass_fsa_ease_enroll_external
        ) loop
            l_entrp_code := x.client_id;
            l_account_type := 'FSA';
        end loop;

        for y in (
            select
                a.entrp_id,
                a.acc_id,
                a.acc_num,
                a.plan_code
            from
                account    a,
                enterprise e
            where
                    a.entrp_id = e.entrp_id
                and a.account_type = l_account_type
                and e.entrp_code = l_entrp_code
        ) loop
            l_entrp_id := y.entrp_id;
            l_entrp_acc_id := y.acc_id;
            l_entrp_acc_num := y.acc_num;
            l_plan_code := y.plan_code;
        end loop;
  -- Insert into File History table ( added by Joshi for 9072).
  -- moved the code from process_fsa_renwal to here (Joshi : 9670);
        if p_user_id = 2 then
            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => p_user_id,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => l_account_type,
                p_enrollment_source => 'EDI',
                p_file_type         => 'employee_eligibility',
                x_file_upload_id    => l_file_id
            );
        end if;
 -- code ends here 9072.

        pc_log.log_error('EXPORT_EASE_ENROLLMENT_FILE', 'INSERT INTO MASS_ENROLLMENTS ' || l_entrp_code);
        insert into mass_enrollments (
            mass_enrollment_id,
            title,
            first_name,
            middle_name,
            last_name,
            gender
--        ,ACTION
            ,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            driver_license,
            passport,
            carrier
--        ,PLAN_TYPE
            ,
            deductible,
            effective_date,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            check_number,
            check_amount,
            employer_amount,
            employee_amount,
            entrp_acc_id,
            employer_name,
            broker_name,
            broker_id,
            error_message,
            sign_on_file,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            tpa_id,
            batch_number,
            division_code,
            enrollment_source,
            termination_date
--        ,ANNUAL_ELECTION
        )
            select
                mass_enrollments_seq.nextval,
                a.title,
                a.first_name,
                a.middle_name,
                a.last_name,
                a.sex
--           , ACTION
                ,
                a.address    -- Production issue to concatinate address1 and address2 on 26/08/2021
                ,
                a.city,
                a.state,
                a.zip,
                a.contact_method,
                a.day_phone,
                a.evening_phone,
                a.email_address,
                a.birth_date,
                a.ssn,
                a.driver_license,
                a.passport,
                a.carrier
--           , A.PLAN_TYPE
                ,
                a.deductible,
                a.effective_date,
                a.debit_card,
                a.plan_code,
                a.start_date,
                a.registration_date,
                a.account_status,
                a.setup_status,
                a.check_number,
                a.check_amount,
                a.employer_amount,
                a.employee_amount,
                l_entrp_acc_id,
                a.employer_name,
                a.broker_name,
                a.broker_id,
                a.error_message,
                a.sign_on_file,
                a.note,
                a.creation_date,
                a.created_by,
                a.last_update_date,
                a.last_updated_by,
                a.error_column,
                l_entrp_id,
                l_entrp_acc_num,
                a.tpa_id,
                x_batch_number,
                a.division_code,
                'EDI',
                a.termination_date
--           , A.ELECTION
            from
                (
                    select distinct
                        null                           title,
                        first_name,
                        substr(middle_name, 1, 1)      middle_name,
                        last_name,
                        decode(
                            upper(sex),
                            'M',
                            'M',
                            'F',
                            'F',
                            'FEMALE',
                            'F',
                            'MALE',
                            'M',
                            null
                        )                              sex -- added by jaggi #10836 Gender should allow only M,F,MALE,FEMALE apart from this shold enter null.
--           , ACTION
                        ,
                        ( initcap(address_1)
                          || ' '
                          || initcap(address_2) )        address    -- Production issue to concatinate address1 and address2 on 26/08/2021
                          ,
                        initcap(city)                  city,
                        state,
                        zip,
                        null                           contact_method,
                        null                           day_phone,
                        null                           evening_phone,
                        email                          email_address,
                        format_date(birth_date)        birth_date,
                        case
                            when length(ssn) < 9 then
                                lpad(ssn, 9, '0')
                            else
                                replace(ssn, '-')
                        end                            ssn,
                        null                           driver_license,
                        null                           passport,
                        replace(carrier, ';', '&')     carrier
--           , PLAN_TYPE
                        ,
                        null                           deductible,
                        format_date(sysdate)           effective_date  -- FORMAT_DATE(EFFECTIVE_DATE) EFFECTIVE_DATE Commented by swamy for Ticket#10406
                        ,
                        decode(
                            pc_entrp.card_allowed(l_entrp_id),
                            0,
                            'YES',
                            'NO'
                        )                              debit_card -- Added by Jaggi #10953
                        ,
                        l_plan_code                    plan_code,
                        format_date(sysdate)           start_date      --FORMAT_DATE(EFFECTIVE_DATE)  START_DATE  Commented by swamy for Ticket#10406
                        ,
                        sysdate                        registration_date,
                        nvl(employee_status, 'Active') account_status,
                        'Yes'                          setup_status,
                        null                           check_number,
                        null                           check_amount,
                        null                           employer_amount,
                        null                           employee_amount
--           , L_entrp_acc_id entrp_acc_id
                        ,
                        company                        employer_name,
                        null                           broker_name,
                        null                           broker_id,
                        null                           error_message,
                        'Y'                            sign_on_file,
                        null                           note,
                        sysdate                        creation_date,
                        0                              created_by,
                        sysdate                        last_update_date,
                        0                              last_updated_by,
                        null                           error_column,
                        'EASE'                         tpa_id,
                        null                           division_code,
                        format_date(termination_date)  termination_date
--           , regexp_replace(election, '[^0-9]', '') ELECTION
                    from
                        mass_fsa_ease_enroll_external
                    where
                        ( nvl(
                            replace(
                                replace(election, '$', ''),
                                '.00',
                                ''
                            ),
                            1
                        ) != '0' ) -- added by Jaggi #10748: Sprint 41 - Do not process any $0 enrollments on FSA/HRA EDI. (#10575);
                        and upper(plan_type) in ( 'FSA HEALTH CARE', 'FSA', 'FSA DEPENDENT CARE', 'DCA', 'PARKING',
                                                  'PKG', 'TRANSIT', 'TRN', 'LIMITED PURPOSE HEALTHCARE', 'LPF',
                                                  'UA1', 'BICYCLE' )
                ) a; -- added by #10998- Ease FSA eligibility file wrong plan type

        pc_log.log_error('EXPORT_EASE_FSA_ENROLLMENT_FILE', 'after INSERT INTO MASS_ENROLLMENTS x_batch_number ' || x_batch_number);
        for x in (
            select
                count(*) cnt
            from
                mass_enrollments
            where
                batch_number = x_batch_number
        ) loop
            if x.cnt = 0 then
                l_sqlerrm := 'Please check the file, template might be incorrect or file must be empty';
                raise lv_create;
            end if;
        end loop;

        for k in (
            select
                mass_enrollment_id,
                state,
                length(state) len
            from
                mass_enrollments
            where
                batch_number = x_batch_number
        ) loop
            l_state := k.state;
            l_length := k.len;
     -- If the file contains the description then we need to extract the code.
            if l_length > 2 then
                for n in (
                    select
                        lookup_code
                    from
                        table ( pc_lookups.get_lookup_values('STATE') )
                    where
                        lower(description) = lower(l_state)
                ) loop
                    l_state := n.lookup_code;
                end loop;
            end if;

            update mass_enrollments
            set
                action =
                    case
                        when pc_account.check_duplicate(
                            replace(ssn, '-'),
                            group_number,
                            replace(employer_name, ','),
                            'FSA',
                            null
                        ) = 'N' then
                            'N'
                        else
                            'C'
                    end,
                state = l_state
            where
                    batch_number = x_batch_number
                and mass_enrollment_id = k.mass_enrollment_id;

        end loop;
  -- Added By Jaggi #9781
        for x in (
            select
                count(*) cnt
            from
                mass_enrollments
            where
                batch_number = x_batch_number
        ) loop
            if x.cnt = 0 then
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => p_user_id,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => l_account_type,
                    p_enrollment_source => 'EDI',
                    p_error             => 'Please check the file, template might be incorrect or file must be empty',
                    p_file_type         => 'employee_eligibility',
                    x_file_upload_id    => l_file_id
                );

            end if;
        end loop;
 -- end here --

        update mass_enrollments
        set
            process_status = 'E',
            error_message = 'Enter Valid Account Number or Social Security Number',
            error_column = 'SSN',
            error_value = 'SSN:' || 'NULL'
        where
            acc_num is null
            and ssn is null
            and batch_number = x_batch_number;

        begin
            insert into mass_enroll_plans (
                mass_enroll_plan_id,
                plan_type,
                deductible,
                effective_date,
                annual_election,
                first_payroll_date,
                pay_contrb,
                no_of_periods,
                pay_cycle,
        --ACTION, /* Joshi: 8634 Ignore Action code */
                plan_code,
                covg_tier_name,
                conditional_issue,
                broker_number,
                note,
                batch_number,
                mass_enrollment_id,
                ben_plan_id,
                created_by,
                creation_date,
                last_update_date,
                last_updated_by,
                termination_date
            )
                select
                    mass_enroll_plans_seq.nextval,
                    decode(
                        upper(a.plan_type),
                        'FSA HEALTH CARE',
                        'FSA',
                        'FSA DEPENDENT CARE',
                        'DCA',
                        'PARKING',
                        'PKG',
                        'TRANSIT',
                        'TRN',
                        'LIMITED PURPOSE HEALTHCARE',
                        'LPF',
                        'BICYCLE',
                        'UA1'
                    ),
                    null,--      a.DEDUCTIBLE ,
                    format_date(a.effective_date),
                    replace(
                        regexp_replace(a.election, '\,+', ''),
                        '$',
                        ''
                    ),/* Ticket 4363 */
                    null,--      format_date(a.FIRST_PAYROLL_DATE),
                    replace(a.employee_cost_deduction_period, '$', ''), /* Ticket#4363*/
                    a.deduction_pay_periods,
                    upper(a.pay_cycle),
      --upper(a.ACTION) , /* Joshi: 8634 Ignore Action code */
                    l_plan_code,
                    null,--      LTRIM(RTRIM(STRIP_SPECIAL_CHAR(a.COVG_TIER_NAME))) ,--ltrim/rtrim does not remove junk
                    null,--      INITCAP(a.CONDITIONAL_ISSUE) ,
                    null,--      a.BROKER_NUMBER ,
                    null,--      a.NOTE ,
                    x_batch_number,
                    b.mass_enrollment_id,
                    null, --Value will be inserted in Validation proc
                    p_user_id,
                    sysdate,
                    sysdate,
                    p_user_id,
                    format_date(a.termination_date)
                from
                    mass_fsa_ease_enroll_external a,
                    mass_enrollments              b
                where
                    ( format_ssn(a.ssn) = format_ssn(b.ssn) )
                    and b.batch_number = x_batch_number
                    and ( nvl(
                        replace(
                            replace(a.election, '$', ''),
                            '.00',
                            ''
                        ),
                        1
                    ) != '0' ) -- added by Jaggi #10748: Sprint 41 - Do not process any $0 enrollments on FSA/HRA EDI. (#10575);
                    and b.process_status is null
                    and a.plan_type is not null;

            pc_log.log_error('NNAfter MEPInsert', sql%rowcount);
            pc_log.log_error('NNAfter MEPInsertBatch', x_batch_number);
            initialize_fsa_renewal(x_batch_number);
            commit;
            pc_log.log_error('PROCESS_UPLOAD', 'In export Renewal');
        exception
            when lv_create then
       --Joshi: capture the file name in the file_upload_history table. 9670
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => p_user_id,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => l_account_type,
                    p_enrollment_source => 'EDI',
                    p_error             => l_sqlerrm,
                    p_file_type         => 'employee_eligibility',
                    x_file_upload_id    => l_file_id
                );

  -- code 9670 ends here.

                raise_application_error('-20001', 'Error ' || l_sqlerrm);
            when others then

      --Joshi: capture the file name in the file_upload_history table. 9670
                pc_file_upload.insert_file_upload_history(
                    p_batch_num         => l_batch_number,
                    p_user_id           => p_user_id,
                    pv_file_name        => pv_file_name,
                    p_entrp_id          => l_entrp_id,
                    p_action            => 'ENROLLMENT',
                    p_account_type      => l_account_type,
                    p_enrollment_source => 'EDI',
                    p_error             => l_sqlerrm,
                    p_file_type         => 'employee_eligibility',
                    x_file_upload_id    => l_file_id
                );
  -- code 9670 ends here.

                pc_log.log_error('PROCESS_UPLOAD', 'In excp' || l_sqlerrm);
                raise_application_error('-20001', 'WEN OTHERS ERROR Error in Inserting/Updating data in Mass Enrollments ' || l_sqlerrm
                );
                rollback;
        end; --End of Insert Loop
  -- Close the file if something goes wrong.
        if utl_file.is_open(l_file) then
            utl_file.fclose(l_file);
        end if;
  -- Delete file from wwv_flows
        delete from wwv_flow_files
        where
            name = pv_file_name;

        pc_log.log_error('process_upload.export_fsa_renewal', 'End');
    exception
        when others then

    --Joshi: capture the file name in the file_upload_history table. 9670
            pc_file_upload.insert_file_upload_history(
                p_batch_num         => l_batch_number,
                p_user_id           => p_user_id,
                pv_file_name        => pv_file_name,
                p_entrp_id          => l_entrp_id,
                p_action            => 'ENROLLMENT',
                p_account_type      => l_account_type,
                p_enrollment_source => 'EDI',
                p_error             => l_sqlerrm,
                p_file_type         => 'employee_eligibility',
                x_file_upload_id    => l_file_id
            );

            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
          --to_names     => 'techsupport@sterlingadministration.com',
                to_names     => 'Jagadeesh.Reddy@sterlingadministration.com; piyush.kumar@sterlingadministration.com,nireesha.kalyanam@sterlingadministration.com,shivani.jaiswal@sterlingadministration.com,srinivasulu.gudur@sterlingadministration.com, vhsqateam@sterlingadministration.com'
                ,  -- InternalPurpouse
                subject      => 'Error in EASE FSA Enrollment file Upload ' || lv_dest_file,
                html_message => l_sqlerrm,
                attach       => l_files
            );
        -- attach => samfiles('/u01/app/oracle/oradata/sam19qa/'||lv_dest_file));
  -- code 9670 ends here.
            pc_log.log_error('PROCESS_UPLOAD', 'In excp' || l_sqlerrm);
            rollback;
            raise_application_error('-20001', 'Error in Exporting File ' || l_sqlerrm);
    end export_ease_fsa_enrollment_file;

-- Added by Swamy#11626
-- Covering procedure to upload the Discounts, called from Apex Upload employer discount screen(443 Screen)
    procedure process_employer_discount (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        x_batch_number number;
        erreur exception;
    begin
        x_error_status := 'S';

    -- Procedure to load the data from external table EMPLOYER_DISCOUNT_EXTERNAL to staging table employer_discount_staging
        process_upload.export_employer_discount(
            pv_file_name   => pv_file_name,
            p_user_id      => p_user_id,
            x_batch_number => x_batch_number
        );

    -- Procedure to validate the data in the staging table (employer_discount_staging)
        process_upload.validate_employer_discount(
            p_batch_number  => x_batch_number,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        if nvl(x_error_status, 'S') = 'S' then
       -- Procedure to load the sucessful data from staging table (employer_discount_staging) to main table Employer_discount
            process_upload.upsert_employer_discount(
                p_batch_number  => x_batch_number,
                p_user_id       => p_user_id,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            if nvl(x_error_status, 'S') = 'E' then
                raise erreur;
            end if;
        end if;

    exception
        when erreur then
            raise_application_error('-20001', 'Error in process_upload.process_employer_discount ' || x_error_message);
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            raise_application_error('-20001', 'Error in process_upload.process_employer_discount '
                                              || sqlerrm
                                              || ' x_error_message :='
                                              || x_error_message);
    end process_employer_discount;

-- Added by Swamy#11626
-- Procedure to load the data from external table EMPLOYER_DISCOUNT_EXTERNAL to staging table employer_discount_staging
    procedure export_employer_discount (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) is

        l_file       utl_file.file_type;
        l_buffer     raw(32767);
        l_amount     binary_integer := 32767;
        l_pos        integer := 1;
        l_blob       blob;
        l_blob_len   integer;
        error exception;
        l_create_ddl varchar2(32000);
        lv_dest_file varchar2(300);
        l_sqlerrm    varchar2(32000);
        l_create_error exception;
    begin
        x_batch_number := batch_num_seq.nextval;
        pc_log.log_error('PROCESS_UPLOAD.export_employer_discount', 'pv_file_name :' || pv_file_name);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('PROCESS_UPLOAD.export_employer_discount', 'lv_dest_file :' || lv_dest_file);
  /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('ENROLL_DIR', pv_file_name, 'w', 32767);
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
                name = pv_file_name;

        exception
            when others then
                null;
        end;

        begin
            l_create_ddl := 'ALTER TABLE employer_discount_EXTERNAL ACCESS PARAMETERS ('
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
                            || '  LOCATION (ENROLL_DIR:'''
                            || lv_dest_file
                            || ''')';

            pc_log.log_error('PROCESS_UPLOAD.export_employer_discount', 'l_create_ddl :' || l_create_ddl);
            execute immediate l_create_ddl;
            pc_log.log_error('PROCESS_UPLOAD.export_employer_discount', '1 x_batch_number:' || x_batch_number);
            insert into employer_discount_staging (
                acc_num,
                batch_number,
                ongoing_renewal,
                discount_start_date,
                discount_exp_date,
                discount_reason,
                renewal_fee,
                renewal_fee_calc_type,
                option_service_fee,
                option_service_fee_calc_type,
                note,
                discount_type,
                creation_date,
                created_by
            )
                select
                    acc_num,
                    x_batch_number,
                    ongoing_renewal,
                    discount_start_date,
                    discount_exp_date,
                    upper(disccount_reason),
                    renewal_fee    --To_Number(Replace(renewal_fee,',',''))
                    ,
                    upper(renewal_fee_calc_type),
                    option_service_fee     -- To_Number(Replace(option_service_fee,',',''))
                    ,
                    upper(option_service_fee_calc_type),
                    note,
                    upper(discount_type),
                    sysdate,
                    p_user_id
                from
                    employer_discount_external;
      -- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
      -- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;

        exception
            when others then
                pc_log.log_error('PROCESS_UPLOAD.export_employer_discount', 'Others 5 x_batch_number:'
                                                                            || x_batch_number
                                                                            || ' '
                                                                            || sqlerrm);
        end;

    end export_employer_discount;

-- Added by Swamy#11626
-- Procedure to validate the data in the staging table (employer_discount_staging)
    procedure validate_employer_discount (
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_error_status := 'S';
        update employer_discount_staging e
        set
            acc_id = (
                select
                    acc_id
                from
                    account a
                where
                        a.acc_num = nvl(e.acc_num, '*')
                    and a.acc_num like ( 'G%' )
            )
        where
            batch_number = p_batch_number;

        update employer_discount_staging e
        set
            process_status = 'E',
            error_message = 'Enter Valid Account Number',
            error_column = 'ACC_NUM',
            error_value = 'ACC_NUM is ' || 'NULL'
        where
                nvl(e.acc_num, '*') = '*'
            and batch_number = p_batch_number;

        update employer_discount_staging e
        set
            process_status = 'E',
            error_message = 'Enter Valid Account Number',
            error_column = 'ACC_NUM',
            error_value = 'No Account with Account Number found ' || e.acc_num
        where
                nvl(e.acc_id, 0) = 0
            and batch_number = p_batch_number;

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Ongoing Renewal',
            error_column = 'ONGOING_RENEWAL',
            error_value = 'ONGOING_RENEWAL IS ' || ongoing_renewal
        where
            ( is_number(ongoing_renewal) = 'N'
              or nvl(ongoing_renewal, '*') = '*' )
            and batch_number = p_batch_number;

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Ongoing Renewal',
            error_column = 'ONGOING_RENEWAL',
            error_value = 'ONGOING_RENEWAL IS ' || ongoing_renewal
        where
                length(ongoing_renewal) > 4
            and batch_number = p_batch_number
            and nvl(process_status, '*') = '*';

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Discount Expiration Date',
            error_column = 'DISCOUNT_EXP_DATE',
            error_value = 'DISCOUNT_EXP_DATE IS ' || discount_exp_date
        where
            ( is_date(discount_exp_date, 'MM/DD/YYYY') = 'N'
              or discount_exp_date is null )
            and batch_number = p_batch_number;

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Discount Start Date',
            error_column = 'DISCOUNT_START_DATE',
            error_value = 'DISCOUNT_START_DATE IS ' || discount_start_date
        where
            ( is_date(discount_start_date, 'MM/DD/YYYY') = 'N'
              or discount_start_date is null )
            and batch_number = p_batch_number;

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Discount Reason',
            error_column = 'DISCCOUNT_REASON',
            error_value = 'DISCCOUNT_REASON IS ' || discount_reason
        where
            upper(nvl(discount_reason, '*')) not in (
                select
                    lookup_code
                from
                    lookups
                where
                    lookup_name = 'DISCOUNT_REASON'
            )
            and batch_number = p_batch_number;

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Renewal Fee',
            error_column = 'RENEWAL_FEE',
            error_value = 'RENEWAL_FEE IS ' || renewal_fee
        where
            ( is_number(renewal_fee) = 'N' )
            and batch_number = p_batch_number;

        update employer_discount_staging s
        set
            s.process_status = 'E',
            s.error_message = 'Enter Valid Renewal Fee',
            s.error_column = 'RENEWAL_FEE',
            s.error_value = 'RENEWAL_FEE IS ' || renewal_fee
        where
                nvl(s.renewal_fee, 'N') = 'N'
            and s.batch_number = p_batch_number
            and not exists (
                select
                    1
                from
                    account a
                where
                        a.acc_id = s.acc_id
                    and a.account_type = 'COBRA'
            );

        update employer_discount_staging s
        set
            s.process_status = 'E',
            s.error_message = 'Enter Valid Renewal Fee / Optional Fee',
            s.error_column = 'RENEWAL_FEE/OPTION_SERVICE_FEE',
            s.error_value = 'RENEWAL_FEE IS '
                            || renewal_fee
                            || 'OPTION_SERVICE_FEE is'
                            || option_service_fee
        where
            ( nvl(s.renewal_fee, 'N') = 'N'
              and nvl(option_service_fee, 'N') = 'N' )
            and s.batch_number = p_batch_number
            and exists (
                select
                    1
                from
                    account a
                where
                        a.acc_id = s.acc_id
                    and a.account_type = 'COBRA'
            );

  -- Other than Cobra, the Renewal Fee is Manditory, so Renewal fee calc type is also manditory
        update employer_discount_staging s
        set
            process_status = 'E',
            error_message = 'Enter Valid Renewal Fee Calculation Type',
            error_column = 'RENEWAL_FEE_CALC_TYPE',
            error_value = 'RENEWAL_FEE_CALC_TYPE IS ' || renewal_fee_calc_type
        where
            nvl(
                upper(renewal_fee_calc_type),
                '*'
            ) not in ( 'PERCENTAGE', 'AMOUNT' )
            and batch_number = p_batch_number
            and not exists (
                select
                    1
                from
                    account a
                where
                        a.acc_id = s.acc_id
                    and a.account_type = 'COBRA'
            );

  -- For Cobra enither renewal fee or optional fee, any one is manditory,
  -- SO if Renewal Fee is given, then valid renewal fee calc type should be given
        update employer_discount_staging s
        set
            s.process_status = 'E',
            s.error_message = 'Enter Valid Renewal Fee Calculation Type',
            s.error_column = 'RENEWAL_FEE_CALC_TYPE',
            s.error_value = 'RENEWAL_FEE_CALC_TYPE IS ' || renewal_fee_calc_type
        where
            nvl(s.renewal_fee, 'N') not in ( 'N' )
            and s.batch_number = p_batch_number
            and nvl(
                upper(renewal_fee_calc_type),
                '*'
            ) not in ( 'PERCENTAGE', 'AMOUNT' )
            and exists (
                select
                    1
                from
                    account a
                where
                        a.acc_id = s.acc_id
                    and a.account_type = 'COBRA'
            );

    -- if Renewal Fee is not given, then renewal fee calc type should be null
        update employer_discount_staging s
        set
            s.process_status = 'E',
            s.error_message = 'Renewal Fee Calculation Type Should Be Null As Renewal Fee Is Not Provided',
            s.error_column = 'RENEWAL_FEE_CALC_TYPE',
            s.error_value = 'RENEWAL_FEE_CALC_TYPE IS ' || renewal_fee_calc_type
        where
                nvl(s.renewal_fee, 'N') = 'N'
            and s.batch_number = p_batch_number
            and nvl(
                upper(renewal_fee_calc_type),
                '*'
            ) <> '*'
            and exists (
                select
                    1
                from
                    account a
                where
                        a.acc_id = s.acc_id
                    and a.account_type = 'COBRA'
            );

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Optional Service Fee Calculation Type ',
            error_column = 'OPTION_SERVICE_FEE_CALC_TYPE',
            error_value = 'OPTION_SERVICE_FEE_CALC_TYPE IS ' || option_service_fee_calc_type
        where
            nvl(option_service_fee_calc_type, '*') not in ( 'PERCENTAGE', 'AMOUNT' )
            and batch_number = p_batch_number
            and option_service_fee is not null;

        update employer_discount_staging
        set
            process_status = 'E',
            error_message = 'Enter Valid Discount Type',
            error_column = 'DISCOUNT_TYPE',
            error_value = 'DISCOUNT_TYPE IS ' || discount_type
        where
            nvl(discount_type, '*') not in ( 'RENEWAL' )
            and batch_number = p_batch_number;

 -- To avoid Duplicate records i the same batch
        for i in (
            select
                a.acc_id,
                count(1)
            from
                employer_discount_staging a
            where
                a.batch_number = p_batch_number
            group by
                a.acc_id
            having
                count(1) > 1
        ) loop
            update employer_discount_staging b
            set
                b.process_status = 'E',
                b.error_message = 'Duplicate Account Number',
                b.error_column = 'ACC_NUM',
                b.error_value = 'ACC_NUM IS '
                                || (
                    select
                        acc_num
                    from
                        account
                    where
                        acc_id = i.acc_id
                )
            where
                    b.acc_id = i.acc_id
                and b.batch_number = p_batch_number;

        end loop;

        update employer_discount_staging s
        set
            s.discount_rec_no = nvl((
                select
                    (max(nvl(e.discount_rec_no, 0)) + 1)
                from
                    employer_discount e
                where
                        e.acc_id = s.acc_id
                    and nvl(e.discount_type, '*') = 'RENEWAL'
            ),
                                    1)
        where
            batch_number = p_batch_number;

        update employer_discount_staging s
        set
            s.process_status = 'S',
            s.imp_year = ongoing_renewal
        where
                batch_number = p_batch_number
            and nvl(process_status, '*') <> 'E';

    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PROCESS_UPLOAD.validate_employer_discount', 'Others  p_batch_number:'
                                                                          || p_batch_number
                                                                          || ' '
                                                                          || sqlerrm);
    end validate_employer_discount;

-- Added by Swamy#11626
-- Procedure to load the sucessful data from staging table (employer_discount_staging) to main table Employer_discount
    procedure upsert_employer_discount (
        p_batch_number  in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        x_batch_number number;
    begin
        pc_log.log_error('PROCESS_UPLOAD.upsert_employer_discount', '**1 p_batch_number:' || p_batch_number);
        x_error_status := 'S';
        for m in (
            select
                *
            from
                employer_discount_staging eds
            where
                    batch_number = p_batch_number
                and process_status = 'S'
        ) loop
            pc_log.log_error('PROCESS_UPLOAD.upsert_employer_discount', '**1 insert:' || p_batch_number);
            insert into employer_discount (
                acc_id,
                batch_number,
                discount_type,
                imp_year,
                ongoing_renewal,
                discount_start_date,
                discount_exp_date,
                renewal_fee,
                renewal_fee_calc_type,
                option_service_fee,
                option_service_fee_calc_type,
                discount_reason,
                note,
                creation_date,
                created_by,
                discount_rec_no
            ) values ( m.acc_id,
                       m.batch_number,
                       m.discount_type,
                       m.imp_year,
                       m.ongoing_renewal,
                       to_date(m.discount_start_date, 'MM/DD/YYYY'),
                       to_date(m.discount_exp_date, 'MM/DD/YYYY'),
                       m.renewal_fee,
                       decode(m.renewal_fee_calc_type, 'PERCENTAGE', 'P', 'AMOUNT', 'A'),
                       m.option_service_fee,
                       decode(m.option_service_fee_calc_type, 'PERCENTAGE', 'P', 'AMOUNT', 'A'),
                       m.discount_reason,
                       m.note,
                       sysdate,
                       p_user_id,
                       nvl(m.discount_rec_no, 1) );

        end loop;

    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PROCESS_UPLOAD.upsert_employer_discount', 'p_batch_number := '
                                                                        || p_batch_number
                                                                        || 'exception:'
                                                                        || sqlerrm);
    end upsert_employer_discount;

-- Added by Joshi for EE Navigator 12360
    procedure process_edi_eenav_files is

        l_parm_names    apex_application_global.vc_arr2;
        l_parm_values   apex_application_global.vc_arr2;
        l_clob          clob;
        json_content    apex_json.t_values;
        l_data_clob     clob;
        l_batch_number  number;
        x_return_status varchar2(255);
        x_error_message varchar2(4000);
        l_status        varchar2(10);
        l_msg           varchar2(2000);
        l_file_name     varchar2(4000);
        l_req_body      clob;
        l_upd_clob      clob;
        l_entrp_id      number;
    begin
        x_return_status := 'S';
        apex_web_service.oauth_authenticate(
            p_token_url     => 'https://sam.sterlinghsa.com:8082/ords/sam21pdb/sterlingftp/oauth/token',
            p_client_id     => 'AAWC6jbJW1xX9YSW7yVNLQ..',
            p_client_secret => 'MbGzcMQguBhm0qyGedFwVA..'
        );

        apex_web_service.g_request_headers(1).name := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
        dbms_output.put_line('x.file_name' || apex_web_service.oauth_get_last_token);

  -- Get the JSON response from the web service.
        l_clob := apex_web_service.make_rest_request(
            p_url         => 'https://sam.sterlinghsa.com:8082/ords/sam21pdb/sterlingftp/EDI/eenavigatorhsafiles/',
            p_http_method => 'GET',
            p_parm_name   => l_parm_names,
            p_parm_value  => l_parm_values
        );

  -- pc_log.log_error ('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', 'l_clob :'||l_clob);
  --insert into ee_nav_date(ENROLLMENT_FILE)  values (to_clob(l_clob)) ;

  -- get the file list
        if l_clob is not null then
            for x in (
                select
                    j.file_name,
                    j.id
                from
                        json_table ( l_clob, '$'
                            columns (
                                nested items[*]
                                    columns (
                                        nested geteenavigator_hsa_files[*]
                                            columns (
                                                file_name,
                                                id
                                            )
                                    )
                            )
                        )
                    j
                where
                    not exists (
                        select
                            *
                        from
                            edi_enrollment_documents
                        where
                                document_name = j.file_name
                            and document_source = 'EDI'
                            and j.id = remote_file_id
                            and document_type = 'EE_FILE_UPLOAD_HSA'
                    )
            ) loop

       -- get file content in JSON
     --  apex_web_service.g_request_headers(1).name  := 'Authorization';
     --  apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;

                pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', 'x.file_name :' || x.file_name);
                pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', 'x.ID :' || x.id);
                l_data_clob := apex_web_service.make_rest_request(
                    p_url         => 'https://sam.sterlinghsa.com:8082/ords/sam21pdb/sterlingftp/EDI/eenavhsajson/' || x.id,
                    p_http_method => 'GET',
                    p_parm_name   => l_parm_names,
                    p_parm_value  => l_parm_values
                );

                if l_data_clob is not null then
                    l_batch_number := null;
                    insert into edi_enrollment_documents (
                        document_id,
                        document_name,
                        document_data,
                        document_source,
                        document_type,
                        created_by,
                        creation_date,
                        batch_number,
                        remote_file_id
                    ) values ( edi_enrollment_document_seq.nextval,
                               x.file_name,
                               l_data_clob,
                               'EDI',
                               'EE_FILE_UPLOAD_HSA',
                               0,
                               sysdate,
                               batch_num_seq.nextval,
                               x.id ) returning batch_number into l_batch_number;

                    if l_batch_number is not null then
                        process_hsa_edi_enav(x.file_name, 421, l_batch_number, l_entrp_id, x_return_status,
                                             x_error_message);
                        pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', 'X_RETURN_STATUS ' || x_return_status);
                        pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', 'l_entrp_id ' || l_entrp_id);
                        if x_return_status = 'S' then
                            l_status := 'P';
                            l_msg := 'Successfully Processed';
                        else
                            l_status := 'E';
                            l_msg := x_error_message;
                        end if;

                    --upload the file into file_attachments table.
                        if
                            x_return_status = 'S'
                            and l_entrp_id is not null
                        then
                            process_upload.upload_enav_csv_file(l_batch_number, x.file_name);
                        end if;

                        pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', '3 in start ' || l_batch_number);
                        pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', '4 in start ' || x.file_name);
                        for xx in (
                            select
                                1
                            from
                                edi_enrollment_documents
                            where
                                    remote_file_id = x.id
                                and processed_flag = 'Y'
                                and batch_number = l_batch_number
                                and document_source = 'EDI'
                                and document_type = 'EE_FILE_UPLOAD_HSA'
                        ) loop
                            apex_web_service.g_request_headers(1).name := 'Authorization';
                            apex_web_service.g_request_headers(1).value := 'Bearer ' || apex_web_service.oauth_get_last_token;
                            apex_web_service.g_request_headers(2).name := 'Content-Type';
                            apex_web_service.g_request_headers(2).value := 'application/json';
                            apex_json.initialize_clob_output();
                            apex_json.open_object();
                            apex_json.write('fileid', x.id);
                            apex_json.write('batchnum', l_batch_number);
                            apex_json.write('processflg', l_status);
                            apex_json.write('processmsg', l_msg);
                            apex_json.close_all();
                            l_req_body := apex_json.get_clob_output();
                            apex_json.free_output();
                            pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', 'l_req_body ' || l_req_body);
                       -- dbms_output.put_line('l_req_body=' || l_req_body);
                            l_upd_clob := apex_web_service.make_rest_request(
                                p_url         => 'https://sam.sterlinghsa.com:8082/ords/sam21pdb/sterlingftp/EDI/eenavigatorhsafiles/'
                                ,
                                p_http_method => 'POST',
                                p_body        => l_req_body
                            );

                            dbms_output.put_line('l_clob=' || l_upd_clob);
                            pc_log.log_error('PROCESS_UPLOAD.PROCESS_EDI_EENAV_FILES', '7 in end ' || l_batch_number);
                        end loop;

                    end if;

                end if;

            end loop;
        end if;

    end process_edi_eenav_files;

    procedure insert_hsa_enav_staging (
        pv_file_name    in varchar2,
        p_batch_number  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_emp_name      enterprise.name%type;
        l_account_type  varchar2(100);
        l_entrp_acc_id  account.acc_id%type;
        l_entrp_acc_num account.acc_num%type;
        l_entrp_id      number;
        l_plan_code     account.plan_code%type;
        lv_create exception;
        l_state         varchar2(100);
        l_length        varchar2(100);
        l_plan_name     varchar2(100);
        l_sqlerrm       varchar2(32000);
        l_tax_id        varchar2(10);
        l_file_id       number;
    begin
        x_return_status := 'S';
        pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging p_batch_number: ', p_batch_number);
        for x in (
            select distinct
                tax_id
            from
                edi_hsa_enav_unprocessed_v
            where
                batch_number = p_batch_number
        ) loop
            l_tax_id := x.tax_id;
        end loop;

        for y in (
            select
                a.entrp_id,
                a.acc_id,
                a.acc_num,
                a.plan_code,
                e.name
            from
                account    a,
                enterprise e
            where
                    e.entrp_code = l_tax_id
                and a.account_type = 'HSA'
                and a.entrp_id = e.entrp_id
                and a.account_status = '1'
        ) loop
            l_entrp_id := y.entrp_id;
            l_entrp_acc_id := y.acc_id;
            l_entrp_acc_num := y.acc_num;
            l_plan_code := y.plan_code;
            l_emp_name := y.name;
        end loop;

        for j in (
            select
                plan_name
            from
                plans
            where
                    plan_sign = 'SHA'
                and plan_code = l_plan_code
        ) loop
            l_plan_name := j.plan_name;
        end loop;

        pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging l_emp_name: ', l_emp_name);
        pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging L_Entrp_Id: ', l_entrp_id);
        pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging L_entrp_acc_id: ', l_entrp_acc_id);
        pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging L_entrp_acc_num: ', l_entrp_acc_num);
        pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging L_plan_code: ', l_plan_code);
        insert into mass_enrollments (
            mass_enrollment_id,
            title,
            first_name,
            middle_name,
            last_name,
            gender,
            address,
            city,
            state,
            zip,
            contact_method,
            day_phone,
            evening_phone,
            email_address,
            birth_date,
            ssn,
            driver_license,
            passport,
            carrier,
            plan_type,
            deductible,
            effective_date,
            debit_card,
            plan_code,
            start_date,
            registration_date,
            account_status,
            setup_status,
            check_number,
            check_amount,
            employer_amount,
            employee_amount,
            entrp_acc_id,
            employer_name,
            broker_name,
            broker_id,
            error_message,
            sign_on_file,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            error_column,
            entrp_id,
            group_number,
            tpa_id,
            batch_number,
            division_code,
            enrollment_source,
            termination_date,
            annual_election
        )
            select
                mass_enrollments_seq.nextval,
                null                                 title,
                first_name,
                substr(middle_name, 1, 1),
                last_name,
                decode(
                    upper(gender),
                    'M',
                    'M',
                    'F',
                    'F',
                    'FEMALE',
                    'F',
                    'MALE',
                    'M',
                    null
                )                                    sex,
                ( initcap(address1)
                  || ' '
                  || initcap(ltrim(rtrim(address2))) ) address,
                initcap(city)                        city,
                state,
                zip,
                null                                 contact_method,
                phone                                day_phone,
                null                                 evening_phone,
                email                                email_address,
                format_date(birth_date)              birth_date,
                case
                    when length(ssn) < 9 then
                        lpad(ssn, 9, '0')
                    else
                        replace(ssn, '-')
                end                                  ssn,
                null                                 driver_license,
                null                                 passport,
                null --REPLACE(CARRIER,';','&')
                ,
                hsa_plan_type                        plan_type,
                null                                 deductible,
                format_date(effective_date)          effective_date,
                decode(
                    pc_entrp.card_allowed(l_entrp_id),
                    0,
                    'Yes',
                    'NO'
                )                                    debit_card,
                l_plan_name                          plan_code,
                format_date(effective_date)          start_date,
                sysdate                              registration_date,
                'Active'                             account_status,
                'Yes'                                setup_status,
                null                                 check_number,
                null                                 check_amount,
                null                                 employer_amount,
                null                                 employee_amount,
                l_entrp_acc_id,
                l_emp_name                           employer_name,
                null                                 broker_name,
                null                                 broker_id,
                null,
                'Yes'                                sign_on_file,
                null                                 note,
                sysdate,
                0,
                sysdate,
                0,
                null,
                l_entrp_id,
                l_entrp_acc_num,
                'EMPLOYEENAVIGATOR'                  tpa_id,
                p_batch_number,
                null                                 division_code,
                'EDI',
                format_date(termination_date)        termination_date,
                null                                 election
            from
                edi_hsa_enav_unprocessed_v a
            where
                    batch_number = p_batch_number
                and ( a.first_name is not null
                      or a.ssn is not null );

        for x in (
            select
                count(*) cnt
            from
                mass_enrollments
            where
                batch_number = p_batch_number
        ) loop
            if x.cnt = 0 then
                update edi_enrollment_documents
                set
                    processed_flag = 'N',
                    process_message = 'Please check the file, template might be incorrect or file must be empty'
                where
                    batch_number = p_batch_number;

                l_sqlerrm := 'Please check the file, template might be incorrect or file must be empty';
                raise lv_create;
            else
                update edi_enrollment_documents
                set
                    processed_flag = 'Y'
                where
                    batch_number = p_batch_number;

            end if;
        end loop;

        pc_file_upload.insert_file_upload_history(
            p_batch_num         => p_batch_number,
            p_user_id           => 427,
            pv_file_name        => pv_file_name,
            p_entrp_id          => l_entrp_id,
            p_action            => 'ENROLLMENT',
            p_account_type      => 'HSA',
            p_enrollment_source => 'EDI',
            p_file_type         => 'employee_eligibility',
            x_file_upload_id    => l_file_id
        );

        for k in (
            select
                mass_enrollment_id,
                state,
                length(state) len
            from
                mass_enrollments
            where
                batch_number = p_batch_number
        ) loop
            l_state := k.state;
            l_length := k.len;
     -- If the file contains the description then we need to extract the code.
            if l_length > 2 then
                for n in (
                    select
                        lookup_code
                    from
                        table ( pc_lookups.get_lookup_values('STATE') )
                    where
                        lower(description) = lower(l_state)
                ) loop
                    l_state := n.lookup_code;
                end loop;
            end if;

            update mass_enrollments
            set
                action =
                    case
                        when pc_account.check_duplicate(
                            replace(ssn, '-'),
                            group_number,
                            replace(employer_name, ','),
                            'HSA',
                            null
                        ) = 'N' then
                            'N'
                        else
                            'C'
                    end,
                state = l_state
            where
                    batch_number = p_batch_number
                and mass_enrollment_id = k.mass_enrollment_id;

        end loop;

        commit;
    exception
        when lv_create then
            x_return_status := 'E';
            x_error_message := l_sqlerrm;
        when others then
            pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging:p_batch_number ', p_batch_number);
            pc_log.log_error('process_upload.Insert_HSA_ENAV_Staging:sqlerrm ', sqlerrm);
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_hsa_enav_staging;

    procedure process_hsa_edi_enav (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_number  in out number,
        x_entrp_id      out number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        setup_error exception;
        l_batch_number number;
        l_entrp_acc_id number;
        l_entrp_id     number;
        l_file_id      number;
    begin
        x_return_status := 'S';
        l_batch_number := x_batch_number;
        pc_log.log_error('procesS_upload.process_hsa_edi_enav', ' x_batch_number : ' || x_batch_number);
        insert_hsa_enav_staging(pv_file_name, x_batch_number, p_user_id, x_return_status, x_error_message);
        if x_return_status <> 'S' then
            raise setup_error;
        end if;
        for x in (
            select distinct
                entrp_acc_id,
                entrp_id
            from
                mass_enrollments
            where
                batch_number = l_batch_number
        ) loop
            l_entrp_acc_id := x.entrp_acc_id;
            l_entrp_id := x.entrp_id;
        end loop;

        x_entrp_id := l_entrp_id;
        validate_enrollments(l_entrp_acc_id, p_user_id, l_batch_number);
        process_existing_accounts(p_user_id, l_batch_number);
 --   pc_notifications.closed_account_reactivation;
        process_enrollments(l_entrp_acc_id, l_batch_number);
        for x in (
            select
                acc_num
            from
                mass_enrollments
            where
                    batch_number = l_batch_number
                and action = 'N'
        ) loop
            pc_log.log_error('process_upload.process_hsa_edi_enav(tupdateing account:  ', x.acc_num);
            update account
            set
                enrollment_source = 'EDI',
                creation_date = sysdate,
                created_by = 0
            where
                acc_num = x.acc_num;
         -- AND TRUNC(creation_date) = TRUNC(SYSDATE);
        end loop;

        for x in (
            select distinct
                group_number
            from
                mass_enrollments
            where
                batch_number = l_batch_number
        ) loop
            pc_log.log_error('process_upload.process_hsa_edi_enav(triggering edi mail:  ', x.group_number);
            pc_notifications.notify_edi_file_received(l_entrp_id, pv_file_name);
        end loop;

        write_hsa_audit_file(l_batch_number, pv_file_name);

    -- Get the file ID.(added by Joshi for 9670)
        for f in (
            select
                file_upload_id
            from
                file_upload_history
            where
                    batch_number = l_batch_number
                and file_name = pv_file_name
                and entrp_id = l_entrp_id
        ) loop
            l_file_id := f.file_upload_id;
        end loop;

        pc_log.log_error('process_upload.process_hsa_edi_enav File_id:  ', l_file_id);
        for x in (
            select
                sum(
                    case
                        when error_message like '%Successfully Loaded%' then
                            1
                        else
                            0
                    end
                ) success_cnt,
                sum(
                    case
                        when error_message not like '%Successfully Loaded%' then
                            1
                        else
                            0
                    end
                ) failure_cnt
            from
                mass_enrollments
            where
                batch_number = l_batch_number
        ) loop
            if
                x.success_cnt = 0
                and x.failure_cnt = 0
            then
                update file_upload_history
                set
                    file_upload_result = 'Error processing your file, Contact Customer Service'
                where
                    file_upload_id = l_file_id;

            else
                if
                    x.success_cnt > 0
                    and x.failure_cnt = 0
                then
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' records '
                    where
                        file_upload_id = l_file_id;

                else
                    update file_upload_history
                    set
                        file_upload_result = 'Successfully Loaded '
                                             || nvl(x.success_cnt, 0)
                                             || ' records, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' records failed to load '
                        )
                    where
                        file_upload_id = l_file_id;

                end if;
            end if;
                   /*
                   IF x.failure_cnt > 0 THEN
                      -- send mail to employer on the EDI results
                      pc_notifications.Notify_EDI_DISCREPANCY_REPORT(l_entrp_id,pv_file_name);
                   END IF; */
        end loop;

        x_return_status := 'S';
    exception
        when setup_error then
            x_return_status := 'E';
            pc_log.log_error('process_upload.process_hsa_edi_enav', 'sqlerrm : ' || sqlerrm);
        when others then
            x_return_status := 'E';
            pc_log.log_error('process_upload.process_hsa_edi_enav', 'sqlerrm : ' || sqlerrm);
    end process_hsa_edi_enav;

    procedure upload_enav_csv_file (
        p_batch_number in number,
        p_file_name    in varchar2
    ) is

        l_csv_clob      clob;
        l_blob          blob;
        l_dest_offset   integer := 1;
        l_src_offset    integer := 1;
        l_lang_ctx      integer := dbms_lob.default_lang_ctx;
        l_warning       integer;
        l_acc_id        number;
        l_csv_file_name varchar2(500);
    begin
        for x in (
            select distinct
                entrp_id,
                group_number
            from
                mass_enrollments
            where
                batch_number = p_batch_number
        ) loop
            l_acc_id := pc_account.get_acc_id(x.group_number);
            select
                replace(p_file_name, '.xml', '.csv')
            into l_csv_file_name
            from
                dual;

-- create CSV data
            select
                'TITLE,FIRST_NAME,MIDDLE_NAME,LAST_NAME,GENDER,ADDRESS,CITY,STATE,ZIP,PHONE,EMAIL,BIRTH_DATE,SSN,DL,PASSPORT,CARRIER,PLAN_TYPE,DEDUCTIBLE,PLAN_EFFECTIVE_DATE,PLAN_CODE,'
                || 'OPEN_DATE,CHECK_NUMBER,CHECK_AMOUNT,EMPLOYER_CONTRIBUTION,EMPLOYEE_CONTRIBUTION,ACCOUNT_STATUS,SET_UP_STATUS,DEBIT_CARD,EMPLOYER_NAME,BROKER_NAME,NOTE,SIGNATURE,GROUP_NUMBER,'
                || 'ERROR_MESSAGE,ERROR_COLUMN,PROCESS_STATUS'
                || chr(10)
                || listagg(','
                           || first_name
                           || ','
                           || middle_name
                           || ','
                           || last_name
                           || ','
                           || gender
                           || ','
                           || address
                           || ','
                           || city
                           || ','
                           || state
                           || ','
                           || zip
                           || ','
                           || day_phone
                           || ','
                           || email_address
                           || ','
                           || birth_date
                           || ','
                           || ssn
                           || ','
                           || ',,,'
                           || plan_type
                           || ',,'
                           || effective_date
                           || ','
                           || plan_code
                           || ',,,,,,ACTIVE,Yes,Yes,'
                           || employer_name
                           || ',,,,'
                           || group_number
                           || ','
                           || ',,,'
                           || chr(10)) within group(
                order by
                    first_name
                )
            into l_csv_clob
            from
                mass_enrollments
            where
                batch_number = p_batch_number;

-- Convert CLOB to BLOB
            dbms_lob.createtemporary(l_blob, true);
            dbms_lob.converttoblob(
                dest_lob     => l_blob,
                src_clob     => l_csv_clob,
                amount       => dbms_lob.lobmaxsize,
                dest_offset  => l_dest_offset,
                src_offset   => l_src_offset,
                blob_csid    => dbms_lob.default_csid,
                lang_context => l_lang_ctx,
                warning      => l_warning
            );

            insert into file_attachments (
                attachment_id,
                document_name,
                document_type,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entity_name,
                entity_id,
                document_purpose,
                description,
                attachment
            ) values ( file_attachments_seq.nextval,
                       l_csv_file_name,
                       'application/vnd.ms-excel',
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACCOUNT',
                       l_acc_id,
                       'ELECTRONIC_FEED',
                       'Uploaded from Mass Enrollment',
                       l_blob );

        end loop;
    end upload_enav_csv_file;

end process_upload;
/


-- sqlcl_snapshot {"hash":"5e14b509a6a46e42e0da1e8c90a582cc996e81b0","type":"PACKAGE_BODY","name":"PROCESS_UPLOAD","schemaName":"SAMQA","sxml":""}