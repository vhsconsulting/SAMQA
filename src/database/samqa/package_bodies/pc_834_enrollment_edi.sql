create or replace package body samqa.pc_834_enrollment_edi as

    v_segment_counter    segment_counter_record := null;
    v_hd_segment_counter hd_segment_record;

    procedure export_edi_report (
        pv_file_name in varchar2,
        p_user_id    in number
    ) as

        l_file       utl_file.file_type;
        l_buffer     raw(32767);
        l_amount     binary_integer := 32767;
        l_pos        integer := 1;
        l_blob       blob;
        l_blob_len   integer;
        exc_no_file exception;
        l_create_ddl varchar2(32000);
        lv_dest_file varchar2(300);
        l_sqlerrm    varchar2(32000);
        l_create_error exception;
        l_change_num number;
    begin
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));


	      /* Get the contents of BLOB from wwv_flow_files */
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        l_file := utl_file.fopen('EDI_DIR', lv_dest_file, 'w', 32767);
        l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
	      -- Open / Creates the destination file.
        pc_log.log_error('export_edi_report ', l_blob_len);

	       -- Read chunks of the BLOB and write them to the file
	      -- until complete.
        while l_pos < l_blob_len loop
            dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
            utl_file.put_raw(l_file, l_buffer, true);
            l_pos := l_pos + l_amount;
        end loop;
	      -- Close the file.
        utl_file.fclose(l_file);
        pc_834_enrollment_edi.alter_edi_location(lv_dest_file);
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
                name = pv_file_name;

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
            commit;
    end export_edi_report;

    procedure alter_edi_location (
        p_file_name in varchar2
    ) is
        l_sqlerrm varchar2(3200);
    begin
        execute immediate '
                   ALTER TABLE ENROLLMENT_EDI_EXTERNAL
                    location (EDI_DIR:'''
                          || p_file_name
                          || ''')';
    exception
        when others then
            l_sqlerrm := 'Error in Changing location of EDI file' || sqlerrm;
            mail_utility.send_email('metavante@sterlingadministration.com', 'vanitha.subramanyam@sterlingadministration.com', 'Error in processing EDI  file'
            , 'Error in altering EDI  file  ' || p_file_name);
    end;

    procedure send_email_on_new_enrollment (
        p_batch_number in number
    ) as
        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
    begin
 -- Get the list of bad files and send email
        get_dir_list('/home/oracle/mailer/');
        for x in (
            select
                *
            from
                directory_list
            where
                    lastmodified > sysdate - 1
                and filename = '834_edi_enrollment.bad'
            order by
                lastmodified desc
        ) loop
            dbms_output.put_line('filename  ' || x.filename);
            mail_utility.send_file_in_emails('oracle@sterlingadministration.com',
                                             g_mail_list,
                                             x.filename,
                                             null,
                                             null,
                                             'Rejected records in 834 EDI file ' || to_char(sysdate, 'MM/DD/YYYY'));

        end loop;

        begin
            l_html_message := '<html>
          <head>
              <title>New Enrollments and Errors in 834 EDI Enrollment Process </title>
          </head>
          <body bgcolor="#FFFFFF" link="#000080">
           <table cellspacing="0" cellpadding="0" width="100%">
           <p>New Enrollments and Errors in 834 EDI Enrollment Process  </p>
           </table>
            </body>
            </html>';
            l_sql := 'SELECT b.acc_num "Account Number",a.ssn "SSN", pc_person.get_entrp_name(b.pers_id) "Employer Name" '
                     || 'FROM enrollment_edi_detail a, account b '
                     || '  WHERE  a.batch_number = '
                     || p_batch_number
                     || '    and  a.acc_id = b.acc_id '
                     || '    and  b.creation_date > sysdate-1 '
                     || '    and  a.person_type <> ''DEPENDANT'' '
                     || '    and  b.account_type IN (''HRA'',''FSA'') ';

            mail_utility.report_emails('oracle@sterlingadministration.com',
                                       g_mail_list,
                                       'edi_enrollments.xls',
                                       l_sql,
                                       l_html_message,
                                       '834 EDI enrollments processed on ' || to_char(sysdate, 'MM/DD/YYYY'));

        exception
            when others then
                dbms_output.put_line('Error in sending enrollment update' || sqlerrm);
        end;

        begin
            l_html_message := '<html>
          <head>
              <title>Unprocessed records in 834 EDI Enrollment Process </title>
          </head>
          <body bgcolor="#FFFFFF" link="#000080">
           <table cellspacing="0" cellpadding="0" width="100%">
           <p>Unprocessed records in 834 EDI Enrollment Process </p>
           </table>
            </body>
            </html>';
            l_sql := 'SELECT  subscriber_number "Subscriber Number", first_name "First Name" '
                     || '      , last_name "Last Name", person_type "Person Type", address "Address", city "City"     '
                     || '      , state "State", zip "Zip", ssn "SSN" ,benefit_begin_dt "Benefit Begin Date"    '
                     || '      , benefit_end_dt "Benefit End Date" , status_cd "Status" , pers_id "Person Number"  '
                     || '      , acc_num "Account Number" '
                     || ' FROM enrollment_edi_detail a'
                     || '  WHERE   a.batch_number = '
                     || p_batch_number
                     || '    and a.PERS_ID IS NULL  and  a.creation_date > sysdate-1  ';

            mail_utility.report_emails('oracle@sterlingadministration.com',
                                       g_mail_list,
                                       'edi_not_enrolled.xls',
                                       l_sql,
                                       l_html_message,
                                       '834 EDI enrollments not processed on ' || to_char(sysdate, 'MM/DD/YYYY'));

        exception
            when others then
                dbms_output.put_line('Error in sending enrollment update' || sqlerrm);
        end;

        begin
            l_html_message := '<html>
          <head>
              <title>Subscriber Records in 834 EDI Enrollment Process </title>
          </head>
          <body bgcolor="#FFFFFF" link="#000080">
           <table cellspacing="0" cellpadding="0" width="100%">
           <p>Subscriber Records in 834 EDI Enrollment Process </p>
           </table>
            </body>
            </html>';
            l_sql := 'SELECT  subscriber_number "Subscriber Number", first_name "First Name" '
                     || '      , last_name "Last Name", address "Address", city "City"     '
                     || '      , state "State", zip "Zip", ssn "SSN" ,benefit_begin_dt "Benefit Begin Date"    '
                     || '      , benefit_end_dt "Benefit End Date" , status_cd "Status"   '
                     || '      , acc_num "Account Number" , pers_id "Pers ID"   '
                     || ' FROM enrollment_edi_detail a'
                     || '  WHERE   a.batch_number = '
                     || p_batch_number
                     || '    and a.person_type = ''SUBSCRIBER''  and  a.creation_date > sysdate-1  ';

            mail_utility.report_emails('oracle@sterlingadministration.com',
                                       g_mail_list,
                                       'edi_subscribers.xls',
                                       l_sql,
                                       l_html_message,
                                       'Subscriber Records received in 834 EDI Enrollment  ' || to_char(sysdate, 'MM/DD/YYYY'));

        exception
            when others then
                dbms_output.put_line('Error in sending enrollment update' || sqlerrm);
        end;

        begin
            l_html_message := '<html>
          <head>
              <title>Dependent Records in 834 EDI Enrollment Process </title>
          </head>
          <body bgcolor="#FFFFFF" link="#000080">
           <table cellspacing="0" cellpadding="0" width="100%">
           <p>Dependent Records in 834 EDI Enrollment Process </p>
           </table>
            </body>
            </html>';
            l_sql := 'SELECT  subscriber_number "Subscriber Number", first_name "First Name" '
                     || '      , last_name "Last Name", address "Address", city "City"     '
                     || '      , state "State", zip "Zip", ssn "SSN" ,benefit_begin_dt "Benefit Begin Date"    '
                     || '      , benefit_end_dt "Benefit End Date" , status_cd "Status"   '
                     || '     , orig_system_ref "Dependent Number" , pers_id "Pers ID"   '
                     || ' FROM enrollment_edi_detail a'
                     || '  WHERE   a.batch_number = '
                     || p_batch_number
                     || '    and a.person_type = ''DEPENDANT''  and  a.creation_date > sysdate-1  ';

            mail_utility.report_emails('oracle@sterlingadministration.com',
                                       g_mail_list,
                                       'edi_dependents.xls',
                                       l_sql,
                                       l_html_message,
                                       'Dependent Records received in 834 EDI Enrollment  ' || to_char(sysdate, 'MM/DD/YYYY'));

        exception
            when others then
                dbms_output.put_line('Error in sending enrollment update' || sqlerrm);
        end;

        begin
            l_html_message := '<html>
              <head>
                  <title>Demographic Update in 834 EDI Enrollment File </title>
              </head>
              <body bgcolor="#FFFFFF" link="#000080">
               <table cellspacing="0" cellpadding="0" width="100%">
               <p>Demographic Update in 834 EDI Enrollment File  </p>
               </table>
                </body>
                </html>';
            l_sql := '   select distinct a.acc_num "Account Number",
                            b.first_name "First Name", b.last_name "Last Name"
                              ,   b.address "Address",b.city "City", b.state "State",b.zip "Zip"
                      from enrollment_edi_detail a, PERSON b
                      where  a.batch_number = '
                     || p_batch_number
                     || '    and a.pers_id = b.pers_id
                      and   trunc(b.last_update_date) > sysdate-1
                      and  trunc(a.creation_date) = trunc(b.last_update_date)
                      and a.person_type <> ''DEPENDANT'' ';
            mail_utility.report_emails('oracle@sterlingadministration.com',
                                       g_mail_list,
                                       'edi_demographic_update.xls',
                                       l_sql,
                                       l_html_message,
                                       'Demographic update in 834 EDI enrollments  ' || to_char(sysdate, 'MM/DD/YYYY'));

        exception
            when others then
                dbms_output.put_line('Error in sending demographic update' || sqlerrm);
        end;

        begin
            l_html_message := '<html>
              <head>
                  <title>Errors in 834 EDI Enrollment File </title>
              </head>
              <body bgcolor="#FFFFFF" link="#000080">
               <table cellspacing="0" cellpadding="0" width="100%">
               <p>Errors in 834 EDI Enrollment File  </p>
               </table>
                </body>
                </html>';
            l_sql := 'select first_name "First Name"
                          , last_name "Last Name",middle_name "Middle Name"
                          , subscriber_number "Subscriber Number"
                          , SSN
                          , benefit_begin_dt "Benefit Begin Date"
                          ,benefit_end_dt "Benefit End Date"
                          , error_code "Error Message"
                      from enrollment_edi_detail A
                     where   a.batch_number = '
                     || p_batch_number
                     || '    and ERROR_CODE IS NOT NULL
                     and   trunc(a.last_update_date) > sysdate-1
                     and    detail_id in ( select max(detail_id) from  enrollment_edi_detail b
                              where a.subscriber_number = b.subscriber_number)';
            mail_utility.report_emails('oracle@sterlingadministration.com',
                                       g_mail_list,
                                       'edi_errors.xls',
                                       l_sql,
                                       l_html_message,
                                       'Errors in 834 EDI enrollments  ' || to_char(sysdate, 'MM/DD/YYYY'));

        exception
            when others then
                dbms_output.put_line('Error in sending error report' || sqlerrm);
        end;

        begin
            l_html_message := '<html>
            <head>
                <title>Terminations in 834 EDI Enrollment File </title>
            </head>
            <body bgcolor="#FFFFFF" link="#000080">
             <table cellspacing="0" cellpadding="0" width="100%">
             <p>Terminations in 834 EDI Enrollment File  </p>
             </table>
              </body>
              </html>';
            l_sql := 'SELECT ''SUBSCRIBER'' "Subscriber/Dependent", ACC_NUM "Account Number", FIRST_NAME "First Name", LAST_NAME "Last Name", ORIG_SYSTEM_REF "Member Number", BENEFIT_END_DT "Termination Date"
                        , TO_CHAR(SYSDATE,''MM/DD/YYYY'') "Processed Date"
                        FROM ENROLLMENT_EDI_DETAIL A
                        WHERE  a.batch_number = '
                     || p_batch_number
                     || ' and BENEFIT_END_DT IS NOT NULL
                        AND   PERSON_TYPE= ''SUBSCRIBER''
                        AND   TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
                        UNION
                        SELECT  ''DEPENDENT'',ACC_NUM, FIRST_NAME, LAST_NAME, ORIG_SYSTEM_REF, BENEFIT_END_DT , TO_CHAR(SYSDATE,''MM/DD/YYYY'') "Processed Date"
                        FROM ENROLLMENT_EDI_DETAIL A
                        WHERE  a.batch_number = '
                     || p_batch_number
                     || '    and  BENEFIT_END_DT IS NOT NULL
                        AND   PERSON_TYPE= ''DEPENDANT''
                        AND   TRUNC(CREATION_DATE) = TRUNC(SYSDATE)';
            mail_utility.report_emails('oracle@sterlingadministration.com',
                                       g_mail_list,
                                       'terminations.xls',
                                       l_sql,
                                       l_html_message,
                                       'Terminations Received in 834 EDI enrollments  ' || to_char(sysdate, 'MM/DD/YYYY'));

        exception
            when others then
                dbms_output.put_line('Error in sending termination report' || sqlerrm);
        end;

        commit;
    exception
        when others then
-- Close the file if something goes wrong.

            dbms_output.put_line('error message ' || sqlerrm);
    end send_email_on_new_enrollment;

    procedure convert_string_to_date (
        date_string  varchar2,
        success_flag out boolean,
        date_value   out date
    ) as
    begin
        success_flag := true;
        date_value := null;
        if date_string is not null then
            date_value := to_date ( date_string, 'YYYYMMDD' );
        end if;

    exception
        when others then
            success_flag := false;
    end;

    procedure convert_string_to_date_time (
        date_string  varchar2,
        time_string  varchar2,
        success_flag out boolean,
        date_value   out date
    ) as
    begin
        success_flag := true;
        date_value := null;
        if date_string is not null then
            date_value := to_date ( date_string
                                    || time_string, 'YYYYMMDDHH24mi' );
        end if;

    exception
        when others then
            success_flag := false;
    end;

    procedure convert_string_to_number (
        number_string varchar2,
        success_flag  out boolean,
        number_value  out number
    ) as
    begin
        success_flag := true;
        number_value := null;
        if number_string is not null then
            number_value := to_number ( number_string );
        end if;
    exception
        when others then
            success_flag := false;
    end;

    procedure build_segment_error (
        p_segment_cd             varchar2,
        p_segment_position_count number,
        p_loop_id                varchar2,
        p_syntax_err_cd          varchar2,
        p_error_desc             varchar2,
        p_err_row                in out error_record
    ) as
    begin
        p_err_row.segment_element_ind := 'S';
        p_err_row.segment_cd := p_segment_cd;
        p_err_row.segment_position_count := p_segment_position_count;
        p_err_row.loop_id := p_loop_id;
        p_err_row.syntax_err_cd := p_syntax_err_cd;
        p_err_row.error_desc := p_error_desc;
    end;

    procedure insert_detail_row (
        p_batch_number in number,
        det_row        in out detail_record,
        err_row        in out error_record,
        file_line      number,
        p_header_id    in number
    )  --out is just to make it assignable
     as
    begin
        if det_row.status_cd = 'PROCESSED' then
            if det_row.subscriber_number is null then
                build_segment_error('INS', file_line, '2000', 3, 'INS Segment is Required.',
                                    err_row);
                det_row.status_cd := 'REJECTED';
            end if;

            if det_row.last_name is null then
                build_segment_error('NM1', file_line, '2100A', 3, 'NM1 Segment is Required.',
                                    err_row);
                det_row.status_cd := 'REJECTED';
            end if;

            if det_row.insurance_line_code is not null then
                if
                    det_row.benefit_begin_dt is null
                    and det_row.benefit_end_dt is null
                then
                    build_segment_error('DTP', file_line, '2300', 3, 'HD-DTP Segment is Required.',
                                        err_row);
                    det_row.status_cd := 'REJECTED';
                end if;
            end if;

        end if;

        insert into enrollment_edi_detail (
            header_id,
            detail_id,
            person_type,
            relationship_cd,
            maintenance_cd,
            maintenance_reason,
            benefit_status_cd,
            cobra_qualifying_event,
            employment_status_cd,
            student_status_cd,
            handicap_ind,
            subscriber_number,
            division_cd,
            termination_dt,
            cobra_qualifying_event_dt,
            cobra_begin_dt,
            cobra_end_dt,
            enrollment_begin_date,
            employment_start_date,
            employment_end_date,
            gender,
            marital_status,
            first_name,
            middle_name,
            last_name,
            address,
            city,
            state,
            zip,
            orig_system_ref,
            phone_work,
            phone_home,
            phone_cell,
            phone_extension,
            email,
            coverage_level,
            coverage_maintenance_cd,
            benefit_begin_dt,
            benefit_end_dt,
            insurance_line_code,
            coverage_description,
            birth_date,
            ssn,
            carrier_name,
            policy_number,
            deductible,
            pref_language,
            annual_election,
            payroll_frequency,
            contribution_amt,
            debit_card,
            status_cd,
     -- mass_enrollment_id,
            creation_date,
            last_update_date,
            batch_number
        ) values ( p_header_id,
                   enrollment_edi_det_seq.nextval,
                   det_row.person_type,
                   det_row.relationship_cd,
                   det_row.maintenance_cd,
                   det_row.maintenance_reason,
                   det_row.benefit_status_cd,
                   det_row.cobra_qualifying_event,
                   det_row.employment_status_cd,
                   det_row.student_status_cd,
                   det_row.handicap_ind,
                   det_row.subscriber_number,
                   det_row.division_cd,
                   det_row.termination_dt,
                   det_row.cobra_qualifying_event_dt,
                   det_row.cobra_begin_dt,
                   det_row.cobra_end_dt,
                   det_row.enrollment_begin_date,
                   det_row.employment_start_date,
                   det_row.employment_end_date,
                   det_row.gender,
                   det_row.marital_status,
                   det_row.first_name,
                   det_row.middle_name,
                   det_row.last_name,
                   det_row.address,
                   det_row.city,
                   det_row.state,
                   det_row.zip,
                   det_row.orig_system_ref,
                   det_row.phone_work,
                   det_row.phone_home,
                   det_row.phone_cell,
                   substr(det_row.phone_extension, 1, 6),
                   det_row.email,
                   det_row.coverage_level,
                   det_row.coverage_maintenance_cd,
                   det_row.benefit_begin_dt,
                   det_row.benefit_end_dt,
                   det_row.insurance_line_code,
                   det_row.coverage_description,
                   det_row.birth_date,
                   det_row.ssn,
                   det_row.carrier_name,
                   det_row.policy_number,
                   det_row.deductible,
                   det_row.pref_language,
                   det_row.annual_election,
                   det_row.payroll_frequency,
                   det_row.contribution_amt,
                   det_row.debit_card,
                   det_row.status_cd,
  --    mass_enrollments_seq.nextval,
                   sysdate,
                   sysdate,
                   p_batch_number );

        if det_row.status_cd = 'REJECTED' then
            insert into enrollment_edi_detail_error (
                detail_id,
                segment_element_ind,
                element_position,
                element_ref_number,
                bad_element_data,
                segment_cd,
                segment_position_count,
                loop_id,
                syntax_err_cd,
                error_desc
            ) values ( enrollment_edi_det_seq.currval,
                       err_row.segment_element_ind,
                       err_row.element_position,
                       err_row.element_ref_number,
                       err_row.bad_element_data,
                       err_row.segment_cd,
                       err_row.segment_position_count,
                       err_row.loop_id,
                       err_row.syntax_err_cd,
                       err_row.error_desc );

        end if;

    end;

    procedure build_element_error (
        p_element_position   varchar2,
        p_element_ref_number varchar2,
        p_bad_element_data   varchar2,
        p_syntax_err_cd      varchar2,
        p_error_desc         varchar2,
        p_err_row            in out error_record
    ) as
    begin
        p_err_row.segment_element_ind := 'E';
        p_err_row.element_position := p_element_position;
        p_err_row.element_ref_number := p_element_ref_number;
        p_err_row.bad_element_data := p_bad_element_data;
        p_err_row.syntax_err_cd := p_syntax_err_cd;
        p_err_row.error_desc := p_error_desc;
    end;

    procedure insert_header_row (
        p_batch_number in number,
        header_row     in out header_record,
        err_row        in out error_record,
        file_line      number
    ) as
    begin
        if header_row.status_cd = 'PROCESSED' then
            if header_row.trans_control_num is null then
                build_segment_error('ST', file_line, null, 3, 'ST Segment is Required.',
                                    err_row);
                header_row.status_cd := 'REJECTED';
            end if;

            if header_row.trans_purpose_cd is null then
                build_segment_error('BGN', file_line, null, 3, 'BGN Segment is Required.',
                                    err_row);
                header_row.status_cd := 'REJECTED';
            end if;

            if header_row.sponsor_id is null then
                build_segment_error('N1', file_line, '1000A', 3, 'N1-Sponsor Segment is Required.',
                                    err_row);
                header_row.status_cd := 'REJECTED';
            end if;

            if header_row.insurer_id is null then
                build_segment_error('N1', file_line, '1000B', 3, 'N1-Payer Segment is Required.',
                                    err_row);
                header_row.status_cd := 'REJECTED';
            end if;

        end if;

        insert into enrollment_edi_header (
            header_id,
            trans_control_num,
            trans_purpose_cd,
            trans_ref_id,
            trans_create_dt,
            trans_create_time,
            time_zone_cd,
            previous_trans_ref_id,
            action_cd,
            master_policy_num,
            file_effective_dt,
            maint_effective_dt,
            enrollment_dt,
            sponsor_id,
            sponsor_name,
            insurer_id,
            insurer_name,
            broker_account,
            tpa_account,
            records_received,
            records_processed,
            records_failed,
            segments_received,
            status_cd,
            segment_element_ind,
            element_position,
            element_ref_number,
            bad_element_data,
            segment_cd,
            segment_position_count,
            loop_id,
            syntax_err_cd,
            error_desc,
            batch_number,
            creation_date,
            last_update_date
        ) values ( enrollment_edi_header_seq.nextval,
                   header_row.trans_control_num,
                   header_row.trans_purpose_cd,
                   header_row.trans_ref_id,
                   header_row.trans_create_dt,
                   header_row.trans_create_time,
                   header_row.time_zone_cd,
                   header_row.previous_trans_ref_id,
                   header_row.action_cd,
                   header_row.master_policy_num,
                   header_row.file_effective_dt,
                   header_row.maint_effective_dt,
                   header_row.enrollment_dt,
                   header_row.sponsor_id,
                   header_row.sponsor_name,
                   header_row.insurer_id,
                   header_row.insurer_name,
                   header_row.broker_account,
                   header_row.tpa_account,
                   header_row.records_received,
                   header_row.records_processed,
                   header_row.records_failed,
                   header_row.segments_received,
                   header_row.status_cd,
                   err_row.segment_element_ind,
                   err_row.element_position,
                   err_row.element_ref_number,
                   err_row.bad_element_data,
                   err_row.segment_cd,
                   err_row.segment_position_count,
                   err_row.loop_id,
                   err_row.syntax_err_cd,
                   err_row.error_desc,
                   p_batch_number,
                   sysdate,
                   sysdate );

    end;

    procedure validate_segment_repeat (
        hdr_det_ind  varchar2,
        seg          varchar2,
        seg01        varchar2,
        loop_id      varchar2,
        error_desc   out varchar2,
        success_flag out boolean
    ) as
    begin
        error_desc := null;
        success_flag := true;
        if hdr_det_ind = 'HDR' then
            if seg = 'ST' then
                v_segment_counter.st := nvl(v_segment_counter.st, 0) + 1;
                if v_segment_counter.st > 1 then
                    success_flag := false;
                    error_desc := 'ST Segment is repeated more than once';
                end if;

            elsif seg = 'SE' then
                v_segment_counter.se := nvl(v_segment_counter.se, 0) + 1;
                if v_segment_counter.se > 1 then
                    success_flag := false;
                    error_desc := 'SE Segment is repeated more than once';
                end if;

            elsif seg = 'BGN' then
                v_segment_counter.bgn := nvl(v_segment_counter.bgn, 0) + 1;
                if v_segment_counter.bgn > 1 then
                    success_flag := false;
                    error_desc := 'BGN Segment is repeated more than once';
                end if;

            elsif seg = 'REF' then
                v_segment_counter.ref_38 := nvl(v_segment_counter.ref_38, 0) + 1;
                if v_segment_counter.ref_38 > 1 then
                    success_flag := false;
                    error_desc := 'REF Segment is repeated more than once';
                end if;

            elsif seg || seg01 = 'N1P5' then
                v_segment_counter.n1_p5 := nvl(v_segment_counter.n1_p5, 0) + 1;
                if v_segment_counter.n1_p5 > 1 then
                    success_flag := false;
                    error_desc := 'N1- Sponsor Segment is repeated more than once';
                end if;

            elsif seg || seg01 = 'N1IN' then
                v_segment_counter.n1_in := nvl(v_segment_counter.n1_in, 0) + 1;
                if v_segment_counter.n1_in > 1 then
                    success_flag := false;
                    error_desc := 'N1- Insurer Segment is repeated more than once';
                end if;

            elsif seg || seg01 in ( 'N1BO', 'N1TV' ) then
                v_segment_counter.n1_bo := nvl(v_segment_counter.n1_bo, 0) + 1;
                if v_segment_counter.n1_in > 2 then
                    success_flag := false;
                    error_desc := 'N1- TPA/Broker Segment is repeated more than twice';
                end if;

            end if;
        elsif hdr_det_ind = 'DET' then
            if loop_id = '2000' then
                if seg = 'REF' then
                    if seg || seg01 = 'REF0F' then
                        v_segment_counter.ref_0f := nvl(v_segment_counter.ref_0f, 0) + 1;
                        if v_segment_counter.ref_0f > 1 then
                            success_flag := false;
                            error_desc := 'REF 0F - Subscription Number Segment is repeated more than once';
                        end if;

                    elsif seg || seg01 = 'REF1L' then
                        v_segment_counter.ref_1l := nvl(v_segment_counter.ref_1l, 0) + 1;
                        if v_segment_counter.ref_1l > 1 then
                            success_flag := false;
                            error_desc := 'REF 1L - Policy Number Segment is repeated more than once';
                        end if;

                    elsif seg || seg01 = 'REF17' then
                        v_segment_counter.ref_17 := nvl(v_segment_counter.ref_17, 0) + 1;
                        if v_segment_counter.ref_17 > 1 then
                            success_flag := false;
                            error_desc := 'REF 17 - Member Identification Number Segment is repeated more than once.';
                        end if;

                    end if;
                end if;  --REF

                null;
                if seg = 'DTP' then
                    v_segment_counter.mem_dtp := nvl(v_segment_counter.mem_dtp, 0) + 1;
                    if v_segment_counter.mem_dtp > 20 then
                        success_flag := false;
                        error_desc := 'REF 17 - Member DTP Segment is repeated more than 20 times.';
                    end if;

                end if; --DTP

            end if; --2000

            if loop_id = '2100A' then
                if seg = 'NM1' then
                    v_segment_counter.mem_nm1 := nvl(v_segment_counter.mem_nm1, 0) + 1;
                    if v_segment_counter.mem_nm1 > 1 then
                        success_flag := false;
                        error_desc := 'Member NM1 Segment is repeated more than once.';
                    end if;

                elsif seg = 'PER' then
                    v_segment_counter.mem_per := nvl(v_segment_counter.mem_per, 0) + 1;
                    if v_segment_counter.mem_per > 1 then
                        success_flag := false;
                        error_desc := 'Member PER Segment is repeated more than once.';
                    end if;

                elsif seg = 'N3' then
                    v_segment_counter.mem_n3 := nvl(v_segment_counter.mem_n3, 0) + 1;
                    if v_segment_counter.mem_n3 > 1 then
                        success_flag := false;
                        error_desc := 'Member N3 Segment is repeated more than once.';
                    end if;

                elsif seg = 'DMG' then
                    v_segment_counter.mem_dmg := nvl(v_segment_counter.mem_dmg, 0) + 1;
                    if v_segment_counter.mem_dmg > 1 then
                        success_flag := false;
                        error_desc := 'Member DMG Segment is repeated more than once.';
                    end if;

                elsif seg = 'ICM' then
                    v_segment_counter.icm := nvl(v_segment_counter.icm, 0) + 1;
                    if v_segment_counter.icm > 1 then
                        success_flag := false;
                        error_desc := 'Member ICM Segment is repeated more than once.';
                    end if;

                elsif seg = 'LUI' then
                    v_segment_counter.lui := nvl(v_segment_counter.lui, 0) + 1;
                    if v_segment_counter.lui > 5 then
                        success_flag := false;
                        error_desc := 'Member LUI Segment is repeated more than 5 times.';
                    end if;

                end if;

            end if; --2100A
            if loop_id = '2300' then
                if seg = 'HD' then
                    v_segment_counter.hd := nvl(v_segment_counter.hd, 0) + 1;
                    v_hd_segment_counter := null;  --HD loop is initialized
                    if v_segment_counter.hd > 99 then
                        success_flag := false;
                        error_desc := 'Health Coverage HD Segment is repeated more than 99 times.';
                    end if;

                end if;

                if seg = 'DTP' then
                    v_hd_segment_counter.dtp := nvl(v_hd_segment_counter.dtp, 0) + 1;
                    if v_hd_segment_counter.dtp > 4 then
                        success_flag := false;
                        error_desc := 'Health Coverage DTP Segment is repeated more than 4 times.';
                    end if;

                elsif seg = 'AMT' then
                    v_hd_segment_counter.amt := nvl(v_hd_segment_counter.amt, 0) + 1;
                    if v_hd_segment_counter.amt > 4 then
                        success_flag := false;
                        error_desc := 'Health Coverage AMT Segment is repeated more than 4 times.';
                    end if;

                elsif seg = 'REF' then
                    v_hd_segment_counter.ref_17 := nvl(v_hd_segment_counter.ref_17, 0) + 1;
                    if v_hd_segment_counter.ref_17 > 2 then
                        success_flag := false;
                        error_desc := 'Health Coverage REF Segment is repeated more than 2 times.';
                    end if;

                end if;

            end if; --2300
        end if;-- hdr_det_ind

    end;

    procedure process_enrollment_header (
        p_batch_number in number
    ) as

        cursor hdr_cur is
        select
            case
                when seg = 'ACT' then
                    '1100C'
                else
                    case seg || s01
                            when 'N1P5' then
                                '1000A'
                            when 'N1IN' then
                                '1000B'
                            else
                                case
                                    when seg || s01 in ( 'N1BO', 'N1TV' ) then
                                            '1000C'
                                end
                    end
            end loop_id,
            ot.seg,
            ot.s01,
            ot.s02,
            ot.s03,
            ot.s04,
            ot.s05,
            ot.s06,
            ot.s07,
            ot.s08,
            ot.s09,
            ot.prv_seg,
            ot.prv_s01
        from
            (
                select
                    lead(a.seg, 1)
                    over(
                        order by
                            rownum
                    ) next_seg,
                    lag(a.seg, 1)
                    over(
                        order by
                            rownum
                    ) prv_seg,
                    lag(a.s01, 1)
                    over(
                        order by
                            rownum
                    ) prv_s01,
                    a.*
                from
                    enrollment_edi_external a  --production
                --FROM enrollment_edi_external_test a -- testing
                where
                    a.seg in ( 'ST', 'N1', 'ACT', 'BGN', 'DTP',
                               'REF', 'SE' )
            ) ot
        where
            ot.seg in ( 'ST', 'BGN', 'N1', 'ACT', 'SE' )
            or ( ot.seg = 'REF'
                 and ot.prv_seg = 'BGN' )
            or ( ot.seg = 'DTP'
                 and ot.next_seg = 'N1' );

        v_hdr_row         header_record;
        validation_failed exception;
        v_err_row         error_record := null;
        v_success_flag    boolean;
        v_converted_date  date;
        v_file_line       number;
        v_loop_id         varchar2(5) := null;
        v_seg_repeat_err  varchar2(100);
        v_seg_repeat_flag boolean;
    begin
   -- delete from enrollment_edi_header;
        v_segment_counter := null;
        for hdr_rec in hdr_cur loop
            v_file_line := v_file_line + 1;
            if hdr_rec.seg not in ( 'ST', 'BGN', 'DTP', 'REF', 'N1',
                                    'ACT', 'SE' ) then
                build_segment_error(hdr_rec.seg, v_file_line, null, 1, 'Unrecognized segment ID',
                                    v_err_row);
                raise validation_failed;
            end if;
    --  validate_segment_repeat('HDR',hdr_rec.seg,hdr_rec.s01,hdr_rec.loop_id,v_seg_repeat_err  ,v_seg_repeat_flag) ;
            if v_seg_repeat_flag = false then
                build_segment_error(hdr_rec.seg, v_file_line, hdr_rec.loop_id, 5, v_seg_repeat_err,
                                    v_err_row);

                raise validation_failed;
            end if;

            if hdr_rec.seg = 'ST' then
                v_hdr_row.trans_control_num := hdr_rec.s02;
                if hdr_rec.s01 is null then
                    build_element_error('ST01', '143', hdr_rec.s01, 1, 'Transaction Set Identifier Code is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s02 is null then
                    build_element_error('ST02', '329', hdr_rec.s02, 1, 'Trans Control Number is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

            elsif hdr_rec.seg = 'BGN' then
                v_hdr_row.trans_purpose_cd := hdr_rec.s01;
                if hdr_rec.s01 is null then
                    build_element_error('BGN01', '353', hdr_rec.s01, 1, 'Transaction Purpose Code is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s01 not in ( '00', '15', '22' ) then
                    build_element_error('BGN01', '353', hdr_rec.s01, 7, 'Transaction Purpose Code is Invalid.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.trans_ref_id := hdr_rec.s02;
                if hdr_rec.s02 is null then
                    build_element_error('BGN02', '127', hdr_rec.s02, 1, 'Trans Reference Number is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s03 is null then
                    build_element_error('BGN03', '373', hdr_rec.s03, 1, 'Trans Creation Date is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.trans_create_dt := hdr_rec.s03;
                convert_string_to_date(hdr_rec.s03, v_success_flag, v_converted_date);
                if v_success_flag = false then
                    build_element_error('BGN03', '373', hdr_rec.s03, 8, 'Trans Creation Date is invalid - Format Error.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s04 is null then
                    build_element_error('BGN04', '337', hdr_rec.s04, 1, 'Trans Creation time is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.trans_create_time := hdr_rec.s04;
                convert_string_to_date_time(hdr_rec.s03, hdr_rec.s04, v_success_flag, v_converted_date);
                if v_success_flag = false then
                    build_element_error('BGN04', '337', hdr_rec.s04, 9, 'Trans Creation Time is invalid - Format Error.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.time_zone_cd := hdr_rec.s05;
                v_hdr_row.previous_trans_ref_id := hdr_rec.s06;
                if hdr_rec.s08 is null then
                    build_element_error('BGN08', '306', hdr_rec.s08, 1, 'Action Code is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s08 not in ( '2', '4' ) then
                    build_element_error('BGN08', '306', hdr_rec.s08, 7, 'Action Code is Invalid.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.action_cd := hdr_rec.s08;
            elsif hdr_rec.seg = 'REF' then
                if hdr_rec.s01 is null then
                    build_element_error('REF01', '128', hdr_rec.s01, 1, 'Master Policy Num Qualifier is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s01 != '38' then
                    build_element_error('REF01', '128', hdr_rec.s01, 7, 'Master Policy Num Qualifier is invalid.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s02 is null then
                    build_element_error('REF02', '127', hdr_rec.s02, 1, 'Master Policy Number is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.master_policy_num := hdr_rec.s02;
            elsif hdr_rec.seg = 'DTP' then--coverage level dates
                if hdr_rec.s01 = '303' then
                    if hdr_rec.s03 is null then
                        build_element_error('DTP03', '1251', hdr_rec.s03, 1, 'Maintenance Effective Date is Required.',
                                            v_err_row);
                        raise validation_failed;
                    end if;

                    v_hdr_row.maint_effective_dt := hdr_rec.s03;
                    convert_string_to_date(hdr_rec.s03, v_success_flag, v_converted_date);
                    if v_success_flag = false then
                        build_element_error('DTP03', '1251', hdr_rec.s03, 8, 'Maintenance Effective Date is Invalid -Date Format error.'
                        ,
                                            v_err_row);
                        raise validation_failed;
                    end if;

                elsif hdr_rec.s01 = '382' then
                    if hdr_rec.s03 is null then
                        build_element_error('DTP03', '1251', hdr_rec.s03, 1, 'Enrollment Date is Required.',
                                            v_err_row);
                        raise validation_failed;
                    end if;

                    v_hdr_row.enrollment_dt := hdr_rec.s03;
                    if v_success_flag = false then
                        build_element_error('DTP03', '1251', hdr_rec.s03, 8, 'Enrollment Date is Invalid -Date Format error.',
                                            v_err_row);
                        raise validation_failed;
                    end if;

                elsif hdr_rec.s01 = '007' then
                    if hdr_rec.s03 is null then
                        build_element_error('DTP03', '1251', hdr_rec.s03, 1, 'File Effective Date is Required.',
                                            v_err_row);
                        raise validation_failed;
                    end if;

                    v_hdr_row.file_effective_dt := hdr_rec.s03;
                    if v_success_flag = false then
                        build_element_error('DTP03', '1251', hdr_rec.s03, 8, 'File Effective Date is Invalid -Date Format error.',
                                            v_err_row);
                        raise validation_failed;
                    end if;

                end if;
            elsif hdr_rec.seg || hdr_rec.s01 = 'N1P5' then
                v_hdr_row.sponsor_name := hdr_rec.s02;
                if hdr_rec.s03 is null then
                    build_element_error('N103', '66', hdr_rec.s03, 1, 'Sponsor Id Code Qualifier is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s03 not in ( 'FI', 'ZZ' ) then
                    build_element_error('N103', '66', hdr_rec.s03, 7, 'Sponsor Id Code Qualifier is Invalid.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s04 is null then
                    build_element_error('N104', '67', hdr_rec.s03, 1, 'Sponsor Id Code is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.sponsor_id := hdr_rec.s04;
            elsif hdr_rec.seg || hdr_rec.s01 = 'N1IN' then
                v_hdr_row.insurer_name := hdr_rec.s02;
                if hdr_rec.s03 is null then
                    build_element_error('N103', '66', hdr_rec.s03, 1, 'Insurer Id Code Qualifier is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s03 not in ( 'FI', 'XV' ) then
                    build_element_error('N103', '66', hdr_rec.s03, 7, 'Insurer Id Code Qualifier is Invalid.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s04 is null then
                    build_element_error('N104', '67', hdr_rec.s03, 1, 'Insurer Id Code is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.insurer_id := hdr_rec.s04;
            elsif hdr_rec.seg || hdr_rec.s01 in ( 'N1BO', 'N1TV' ) then
                if hdr_rec.s03 is null then
                    build_element_error('N103', '66', hdr_rec.s03, 1, 'TPA/Broker Id Code Qualifier is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s03 not in ( 'FI', 'XV', '94' ) then
                    build_element_error('N103', '66', hdr_rec.s03, 7, 'TPA/Broker Id Code Qualifier is Invalid.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s04 is null then
                    build_element_error('N104', '67', hdr_rec.s03, 1, 'TPA/Broker Id Code is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s02 is null then
                    build_element_error('N102', '93', hdr_rec.s03, 1, 'TPA/Broker Name is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s01 = 'BO' then
                    v_hdr_row.broker_id := hdr_rec.s04;
                    v_hdr_row.broker_name := hdr_rec.s02;
                elsif hdr_rec.s01 = 'TV' then
                    v_hdr_row.tpa_id := hdr_rec.s04;
                    v_hdr_row.tpa_name := hdr_rec.s02;
                end if;

            elsif hdr_rec.seg = 'ACT' then
                if hdr_rec.prv_seg = 'ACT' then
                    build_segment_error(hdr_rec.seg, v_file_line, '1100C', 5, 'Segment ACT is repeated more than once',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s01 is null then
                    build_element_error('ACT01', '93', hdr_rec.s01, 1, 'TPA/Broker Account Number is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.prv_s01 = 'BO' then
                    v_hdr_row.broker_account := hdr_rec.s01;
                elsif hdr_rec.prv_s01 = 'TV' then
                    v_hdr_row.tpa_account := hdr_rec.s01;
                end if;

            elsif hdr_rec.seg = 'SE' then
                if hdr_rec.s01 is null then
                    build_element_error('SE01', '96', hdr_rec.s01, 1, 'Segments count is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s02 is null then
                    build_element_error('SE02', '329', hdr_rec.s02, 1, 'Trans Control Number is Required.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                if hdr_rec.s02 != v_hdr_row.trans_control_num then
                    build_element_error('SE02', '329', hdr_rec.s02, 7, 'Trans Control Number in ST,SE segments not matching.',
                                        v_err_row);
                    raise validation_failed;
                end if;

                v_hdr_row.segments_received := hdr_rec.s01;
            end if;

        end loop;

        v_hdr_row.status_cd := 'PROCCESSED';
        insert_header_row(p_batch_number, v_hdr_row, v_err_row, v_file_line);
    --COMMIT;
    exception
        when validation_failed then
            v_hdr_row.status_cd := 'REJECTED';
            insert_header_row(p_batch_number, v_hdr_row, v_err_row, v_file_line);
     --commit;
        when others then
            raise_application_error(-20002,
                                    'Enrollment_EDI_Detail process failed. '
                                    || substr(sqlerrm, 1, 50));
    end;
 /* -- enrollment_file table
  INSERT
  INTO enrollment_edi_File
    (
      file_id,
      client_id ,
      file_name ,
      process_dt
    )
    VALUES
    (
      enrollment_file_seq.nextval,
      'client1',
      (SELECT s03 FROM enrollment_edi_header WHERE seg='BGN'
      ),
      sysdate
    );*/

    procedure process_enrollment_detail (
        p_batch_number in number
    ) as

        cursor det_cur is
        select
            rownum line_num,
            case
                when seg = 'INS' then
                    '2000'
                when seg = 'DSB' then
                    '2200'
                when seg in ( 'HD', 'IDC' ) then
                    '2300'
                when seg in ( 'LX', 'PLA' ) then
                    '2310'
                when seg = 'COB' then
                    '2320'
                when seg in ( 'ICM', 'HLH', 'LUI' ) then
                    '2100A'
                else
                    case seg || s01
                            when 'NM1IL' then
                                '2100A'
                            when 'NM170' then
                                '2100B'
                            when 'NM131' then
                                '2100C'
                            when 'NM1ES' then
                                '2100D'
                            when 'NM1M8' then
                                '2100E'
                            when 'NM1S3' then
                                '2100F'
                            else
                                case
                                    when seg || s01 in ( 'NM1E1', 'NM1EI', 'NM1EXS', 'NM1GD', 'NM1J6',
                                                         'NM1QD' ) then
                                            '2100G'
                                end
                    end
            end    loop_id,
            ot.seg,
            ot.s01,
            ot.s02,
            ot.s03,
            ot.s04,
            ot.s05,
            ot.s06,
            ot.s07,
            ot.s08,
            ot.s09,
            ot.s10,
            ot.s11,
            ot.s12,
            ot.s13,
            ot.s14,
            ot.s15,
            ot.s16,
            ot.s17,
            ot.s18,
            ot.next_seg,
            ot.prv_seg
        from
            (
                select
                    lead(a.seg, 1)
                    over(
                        order by
                            rownum
                    ) next_seg,
                    lag(a.seg, 1)
                    over(
                        order by
                            rownum
                    ) prv_seg,
                    a.*
                from
                    enrollment_edi_external a     --production
      --FROM enrollment_edi_external_test a --testing
                where
                    a.seg not in ( 'ST', 'N1', 'ACT', 'BGN', 'SE',
                                   'GS', 'ISA', 'GE', 'IEA' )
            ) ot
        where
            ot.seg not in ( 'ST', 'N1', 'ACT', 'BGN', 'GS',
                            'REF', 'SE', 'DTP', 'ISA', 'GE',
                            'IEA' )
            or ( ot.seg = 'REF'
                 and ot.prv_seg != 'BGN' )
            or ( ot.seg = 'DTP'
                 and nvl(ot.next_seg, 'x') != 'N1' );

        v_loop_id          varchar2(5) := null;
        v_count            number;
        v_det_row          detail_record := null;
        v_err_row          error_record := null;
        validation_failed exception;
        error_found        boolean := false;
        v_file_line        number;
        v_seg_repeat_err   varchar2(100);
        v_seg_repeat_flag  boolean;
        v_success_flag     boolean;
        v_converted_date   date;
        v_converted_number number;
        v_header_id        number;
    begin
  --delete from enrollment_edi_detail;
        v_segment_counter := null; --initializing as used by Header process too
        select
            count(*)
        into v_file_line
        from
            (
                select
                    lead(a.seg, 1)
                    over(
                        order by
                            rownum
                    ) next_seg,
                    lag(a.seg, 1)
                    over(
                        order by
                            rownum
                    ) prv_seg,
                    a.*
   -- FROM enrollment_edi_external_test a  --testing
                from
                    enrollment_edi_external a -- production
                where
                    a.seg in ( 'ST', 'N1', 'ACT', 'BGN', 'DTP',
                               'REF', 'GS', 'ISA' )
            ) ot
        where
            ot.seg in ( 'ST', 'BGN', 'N1', 'ACT', 'GS',
                        'ISA' )
            or ( ot.seg = 'REF'
                 and ot.prv_seg = 'BGN' )
            or ( ot.seg = 'DTP'
                 and ot.next_seg = 'N1' );

        for x in (
            select
                b.header_id
            from
                enrollment_edi_external a,
                enrollment_edi_header   b
            where
                    a.seg = 'N1'
                and a.s01 = 'P5'
                and a.s04 = b.sponsor_id
                and b.trans_create_dt = b.trans_create_dt
                and b.trans_create_time = b.trans_create_time
        ) loop
            v_header_id := x.header_id;
        end loop;

        pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'header id ' || v_header_id);
        for det_rec in det_cur loop
            v_file_line := v_file_line + 1;   --file line position needed for segment error reporting
            if error_found then                                              --error in the loop
                if ( det_rec.next_seg = 'INS'
                or det_rec.next_seg is null ) then --err in the loop except in the last row of the loop
                    insert_detail_row(p_batch_number, v_det_row, v_err_row, 0, v_header_id);
                    error_found := false;
                    v_det_row := null;
                    v_err_row := null;
                    v_segment_counter := null;
                end if;

            else -- not error_found then
                begin
                    if det_rec.loop_id is not null then -- obtaining loop ids for child segments
                        v_loop_id := det_rec.loop_id;
                    end if;
                    if det_rec.seg not in ( 'INS', 'REF', 'DTP', 'NM1', 'PER',
                                            'N3', 'N4', 'DMG', 'ICM', 'AMT',
                                            'HLH', 'LUI', 'DSB', 'IDC', 'LX',
                                            'PLA', 'COB', 'HD', 'IDC' ) then
                        build_segment_error(det_rec.seg, v_file_line, null, 1, 'Unrecognized segment ID',
                                            v_err_row);
                        raise validation_failed;
                    end if;
        --segment repeat validation
                    validate_segment_repeat('DET', det_rec.seg, det_rec.s01, v_loop_id, v_seg_repeat_err,
                                            v_seg_repeat_flag);

                    if v_seg_repeat_flag = false then
                        build_segment_error(det_rec.seg, v_file_line, v_loop_id, 5, v_seg_repeat_err,
                                            v_err_row);
                        raise validation_failed;
                    end if;

                    pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'INS segment validation');
                    if det_rec.seg = 'INS' then
                        v_det_row.person_type :=
                            case upper(det_rec.s01)
                                when 'Y' then
                                    'SUBSCRIBER'
                                when 'N' then
                                    'DEPENDANT'
                            end;

                        v_det_row.relationship_cd := det_rec.s02;
                        v_det_row.maintenance_cd := det_rec.s03;
                        v_det_row.benefit_status_cd := det_rec.s05;
                        if ( det_rec.s01 is null
                             or det_rec.s02 is null
                        or det_rec.s03 is null
                        or det_rec.s05 is null ) then
                            if det_rec.s01 is null then
                                build_element_error('INS01', '1073', null, 1, 'Person type is Required.',
                                                    v_err_row);
                            elsif det_rec.s02 is null then
                                build_element_error('INS02', '1069', null, 1, 'Relatiionship code is Required.',
                                                    v_err_row);
                            elsif det_rec.s03 is null then
                                build_element_error('INS03', '875', null, 1, 'Maintenance code is Required.',
                                                    v_err_row);
                            elsif det_rec.s05 is null then
                                build_element_error('INS05', '1216', null, 1, 'Benefit Status is Required.',
                                                    v_err_row);
                            end if;

                            raise validation_failed;
                        end if;

                        if upper(det_rec.s01) not in ( 'Y', 'N' ) then
                            build_element_error('INS01', '1073', det_rec.s01, 7, 'Person Type should be Y or N, other values not allowed.'
                            ,
                                                v_err_row);
                            raise validation_failed;
                        end if;

                        select
                            count(*)
                        into v_count
                        from
                            lookups
                        where
                                lookup_name = 'EDI_RELATIONSHIP_CODE'
                            and lookup_code = det_rec.s02;

                        if v_count = 0 then
                            build_element_error('INS02', '1069', det_rec.s02, 7, 'Relationship code is not valid.',
                                                v_err_row);
                            raise validation_failed;
                        end if;

                        if
                            upper(det_rec.s01) = 'Y'
                            and det_rec.s02 != '18'
                        then
                            build_element_error('INS02', '1069', det_rec.s01, 7, 'Relationship code for Subscriber shoule be 18-Self.'
                            ,
                                                v_err_row);
                            raise validation_failed;
                        end if;

                        select
                            count(*)
                        into v_count
                        from
                            lookups
                        where
                                lookup_name = 'EDI_MEM_MAINTENANCE_CODE'
                            and lookup_code = det_rec.s03;

                        if v_count = 0 then
                            build_element_error('INS03', '875', det_rec.s03, 7, 'Member Maintenance Code is Invalid.',
                                                v_err_row);
                            raise validation_failed;
                        end if;

                        v_det_row.maintenance_reason := det_rec.s04;
                        if det_rec.s04 is not null then
                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'EDI_MAINTENANCE_REASON'
                                and lookup_code = det_rec.s04;

                            if v_count = 0 then
                                build_element_error('INS04', '1203', det_rec.s04, 7, 'Member Maintenance Reason is invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                        end if;

                        select
                            count(*)
                        into v_count
                        from
                            lookups
                        where
                                lookup_name = 'EDI_BENEFIT_STATUS'
                            and lookup_code = det_rec.s05;

                        if v_count = 0 then
                            build_element_error('INS05', '1216', det_rec.s05, 7, 'Benefit Status Code is Invalid.',
                                                v_err_row);
                            raise validation_failed;
                        end if;

                        if det_rec.s07 is not null then
                            v_det_row.cobra_qualifying_event := det_rec.s07;
                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'EDI_COBRA_EVENT'
                                and lookup_code = det_rec.s07;

                            if v_count = 0 then
                                build_element_error('INS07', '1219', det_rec.s07, 7, 'COBRA Qualifying event is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                        end if;

                        if
                            det_rec.s01 = 'Y'
                            and det_rec.s08 is null
                        then
                            build_element_error('INS08', '584', det_rec.s08, 2, 'Employment Status is Required for Subscribers.',
                                                v_err_row);
                            raise validation_failed;
                        end if;

                        if det_rec.s08 is not null then
                            v_det_row.employment_status_cd := det_rec.s08;
                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'EDI_EMPLOYMENT_STATUS'
                                and lookup_code = det_rec.s08;

                            if v_count = 0 then
                                build_element_error('INS08', '584', det_rec.s08, 7, 'Employment Status is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                        end if;

                        if det_rec.s09 is not null then --?check when you have DOB

                            v_det_row.student_status_cd := det_rec.s09;
                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'EDI_STUDENT_STATUS'
                                and lookup_code = det_rec.s09;

                            if v_count = 0 then
                                build_element_error('INS09', '1220', det_rec.s09, 7, 'Student Status is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                        end if;

                        if det_rec.s10 is not null then
                            v_det_row.handicap_ind := det_rec.s10;
                            if det_rec.s10 not in ( 'Y', 'N' ) then
                                build_element_error('INS10', '1073', det_rec.s10, 7, 'Handicap Indicator is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                        end if;

                    end if; --INS Seg
                    if det_rec.prv_seg = 'INS' then
          --dbms_output.put_line('seg01 '||det_rec.seg||det_rec.s01||'-'||'prv_seg '||det_rec.prv_seg);
                        if det_rec.seg
                           || trim(det_rec.s01) != 'REF0F' then
                            build_segment_error('REF', v_file_line, v_loop_id, 3, 'Subscriber Number Segment is Required',
                                                v_err_row);
                            raise validation_failed;
                        end if;
                    end if;

                    if v_loop_id = '2000' then
                        if det_rec.seg
                           || trim(det_rec.s01) = 'REF0F' then
                            v_det_row.subscriber_number := det_rec.s02;
                        end if;

                        if det_rec.seg
                           || trim(det_rec.s01) = 'REF1L' then
                            v_det_row.policy_number := det_rec.s02;
                            v_det_row.orig_system_ref := det_rec.s02;
           /* IF det_rec.s02                 IS NULL THEN
              build_element_error('REF02' ,'127', det_rec.s02 ,1,'Policy Number is Required.',v_err_row);
              raise validation_failed;
            END IF;*/
                        end if;

                        if det_rec.seg
                           || trim(det_rec.s01) = 'REF23' then
          --  v_det_row.subscriber_number          := det_rec.s02;
                            v_det_row.orig_system_ref := det_rec.s02;
                            if det_rec.s02 is null then
                                build_element_error('REF02', '127', det_rec.s02, 1, 'Subscriber Number is Required.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                        end if;

      /*    IF det_rec.seg||trim(det_rec.s01) ='REF17' THEN
            v_det_row.Division_cd          := det_rec.s02;
            IF det_rec.s02                 IS NULL THEN
              build_element_error('REF02' ,'127', det_rec.s02 ,1,'Division Code is Required.',v_err_row);
              raise validation_failed;
            END IF;
          END IF;*/
                        if det_rec.seg = 'DTP' then -- not tested as sample file has no data...
                            if det_rec.s01 = '357' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'No Termination Date.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.termination_dt := det_rec.s03;
                            elsif det_rec.s01 = '301' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'No COBRA Qualifying event Date.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.cobra_qualifying_event_dt := det_rec.s03;
                            elsif det_rec.s01 = '340' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'No COBRA Begin Date.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.cobra_begin_dt := det_rec.s03;
                            elsif det_rec.s01 = '341' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'No COBRA End Date.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.cobra_end_dt := det_rec.s03;
                            elsif det_rec.s01 = '300' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'No Enrollment Begin Date.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.enrollment_begin_date := det_rec.s03;
                            elsif det_rec.s01 = '336' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'No Employment Start Date.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.employment_start_date := det_rec.s03;
                            elsif det_rec.s01 = '337' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'No Employment End Date.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.employment_end_date := det_rec.s03;
                            end if;

                            if det_rec.s01 in ( '357', '301', '340', '341', '300',
                                                '336', '337' ) then
                                convert_string_to_date(det_rec.s03, v_success_flag, v_converted_date);
                                if v_success_flag = false then
                                    if det_rec.s01 = '357' then
                                        build_element_error('DTP03', '1251', det_rec.s03, 8, 'Termination Date is Invalid -Date Format error.'
                                        ,
                                                            v_err_row);
                                        raise validation_failed;
                                    elsif det_rec.s01 = '301' then
                                        build_element_error('DTP03', '1251', det_rec.s03, 8, 'COBRA Qualifying event Date is Invalid -Date Format error.'
                                        ,
                                                            v_err_row);
                                        raise validation_failed;
                                    elsif det_rec.s01 = '340' then
                                        build_element_error('DTP03', '1251', det_rec.s03, 8, 'COBRA Begin Date is Invalid -Date Format error.'
                                        ,
                                                            v_err_row);
                                        raise validation_failed;
                                    elsif det_rec.s01 = '341' then
                                        build_element_error('DTP03', '1251', det_rec.s03, 8, 'COBRA End is Invalid -Date Format error.'
                                        ,
                                                            v_err_row);
                                        raise validation_failed;
                                    elsif det_rec.s01 = '300' then
                                        build_element_error('DTP03', '1251', det_rec.s03, 8, 'Enrollment Begin Date is Invalid -Date Format error.'
                                        ,
                                                            v_err_row);
                                        raise validation_failed;
                                    elsif det_rec.s01 = '336' then
                                        build_element_error('DTP03', '1251', det_rec.s03, 8, 'Employment Start Date is Invalid -Date Format error.'
                                        ,
                                                            v_err_row);
                                        raise validation_failed;
                                    elsif det_rec.s01 = '337' then
                                        build_element_error('DTP03', '1251', det_rec.s03, 8, 'Employment End Date is Invalid -Date Format error.'
                                        ,
                                                            v_err_row);
                                        raise validation_failed;
                                    end if;

                                end if;

                            end if;

                        end if; --DTP
                    end if;   --Loop 2000
                    pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', '2100A loop validation');
                    if v_loop_id = '2100A' then
                        if det_rec.seg = 'NM1' then --should we check if NM1 is present or not
                            if det_rec.s03 is null
                               or det_rec.s04 is null then
                                if det_rec.s03 is null then
                                    build_element_error('NM103', '1035', det_rec.s03, 1, 'Last Name is Required.',
                                                        v_err_row);
                                elsif det_rec.s04 is null then
                                    build_element_error('NM104', '1036', det_rec.s04, 1, 'First Name is Required.',
                                                        v_err_row);
                                end if;

                                raise validation_failed;
                            end if;

                            v_det_row.last_name := det_rec.s03;
                            v_det_row.first_name := det_rec.s04;
                            v_det_row.middle_name := det_rec.s05;
                            v_det_row.ssn := det_rec.s09;
                        end if;

                        pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'PER segment validation');
                        if det_rec.seg = 'PER' then --need to be tested as test file has no phone numbers

                            pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'PER segment value '
                                                                          || det_rec.s03
                                                                          || ' '
                                                                          || det_rec.s04);

                            if det_rec.s03 = 'HP' then
                                v_det_row.phone_home := det_rec.s04;
                            elsif det_rec.s03 = 'WP' then
                                v_det_row.phone_work := det_rec.s04;
                            elsif det_rec.s03 = 'TE' then
                                v_det_row.phone_cell := det_rec.s04;
                            elsif det_rec.s03 = 'EX' then
                                v_det_row.phone_extension := det_rec.s04;
                            elsif det_rec.s03 = 'EM' then
                                v_det_row.email := det_rec.s04;
                            end if;

                            pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'PER segment value '
                                                                          || det_rec.s05
                                                                          || ' '
                                                                          || det_rec.s06);

                            if det_rec.s05 = 'HP' then
                                v_det_row.phone_home := det_rec.s06;
                            elsif det_rec.s05 = 'WP' then
                                v_det_row.phone_work := det_rec.s06;
                            elsif det_rec.s05 = 'TE' then
                                v_det_row.phone_cell := det_rec.s06;
                            elsif det_rec.s05 = 'EX' then
                                v_det_row.phone_extension := det_rec.s06;
                            elsif det_rec.s05 = 'EM' then
                                v_det_row.email := det_rec.s06;
                            end if;

                            if det_rec.s07 = 'HP' then
                                v_det_row.phone_home := det_rec.s08;
                            elsif det_rec.s07 = 'WP' then
                                v_det_row.phone_work := det_rec.s08;
                            elsif det_rec.s07 = 'TE' then
                                v_det_row.phone_cell := det_rec.s08;
                            elsif det_rec.s07 = 'EX' then
                                v_det_row.phone_extension := det_rec.s08;
                            elsif det_rec.s07 = 'EM' then
                                v_det_row.email := det_rec.s08;
                            end if;

                        end if; --PER
                        pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'N3 segment validation');
                        if det_rec.seg = 'N3' then
                            if det_rec.s01 is null then
                                build_element_error('N301', '166', det_rec.s01, 1, 'Street address is Required.',
                                                    v_err_row);
                                v_err_row.error_desc := 'Street address is Required.';
                                raise validation_failed;
                            end if;

                            v_det_row.address := det_rec.s01
                                                 || '    '
                                                 || det_rec.s02;
                        end if; --N3
                        pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'N4 segment validation');
                        if det_rec.seg = 'N4' then
                            v_det_row.city := det_rec.s01;
                            v_det_row.state := det_rec.s02;
                            v_det_row.zip := det_rec.s03;
                            if det_rec.s01 is null
                               or det_rec.s02 is null
                            or det_rec.s03 is null then
                                if det_rec.s01 is null then
                                    build_element_error('N401', '19', det_rec.s01, 1, 'City is Required.',
                                                        v_err_row);
                                elsif det_rec.s02 is null then
                                    build_element_error('N402', '156', det_rec.s02, 1, 'State is Required.',
                                                        v_err_row);
                                elsif det_rec.s03 is null then
                                    build_element_error('N403', '116', det_rec.s03, 1, 'Zip Code is Required.',
                                                        v_err_row);
                                end if;

                                raise validation_failed;
                            end if;

                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'STATE'
                                and lookup_code = det_rec.s02;

                            if v_count = 0 then
                                build_element_error('N402', '156', det_rec.s02, 7, 'State is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                        end if; --N4
                        if det_rec.seg = 'DMG' then
                            v_det_row.birth_date := det_rec.s02;
                            v_det_row.gender := det_rec.s03;
                            if det_rec.s02 is null
                               or det_rec.s03 is null then
                                if det_rec.s02 is null then
                                    build_element_error('DMG02', '1251', det_rec.s02, 1, 'Date of Birth is Required.',
                                                        v_err_row);
                                elsif det_rec.s03 is null then
                                    build_element_error('DMG03', '1068', det_rec.s03, 1, 'Gender is Required.',
                                                        v_err_row);
                                end if;

                                raise validation_failed;
                            end if;

                            if det_rec.s04 is not null then
                                v_det_row.marital_status := det_rec.s04;
                                select
                                    count(*)
                                into v_count
                                from
                                    lookups
                                where
                                        lookup_name = 'EDI_MARITAL_STATUS'
                                    and lookup_code = det_rec.s04;

                                if v_count = 0 then
                                    build_element_error('DMG04', '1067', det_rec.s04, 7, 'Marital Status is Invalid.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                            end if;

                        end if;--DMG
                        pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'ICM segment validation');
                        if det_rec.seg = 'ICM' then
                            v_det_row.payroll_frequency := det_rec.s01;
                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'EDI_PAYROLL_FREQ_CD'
                                and lookup_code = det_rec.s01;

                            if v_count = 0 then
                                build_element_error('ICM01', '594', det_rec.s01, 7, 'Payroll Frequency Code is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            if det_rec.s02 is null then
                                build_element_error('ICM02', '782', det_rec.s02, 1, 'No Payroll contribution amount.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            v_det_row.contribution_amt := det_rec.s02;
                        end if; --ICM
                        if det_rec.seg = 'LUI' then
                            v_det_row.pref_language := det_rec.s02;
                        end if;

                    end if; --loop 2100A
                    pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', '2300 LOOP validation');
                    if v_loop_id = '2300' then
                        if det_rec.seg = 'HD' then
                            if det_rec.prv_seg = 'HD' then
                                build_segment_error('HD', v_file_line, v_loop_id, 5, 'HD segment exceeds maximum use.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            v_det_row.coverage_maintenance_cd := det_rec.s01;
                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'EDI_COVERAGE_MAINT_CD'
                                and lookup_code = det_rec.s01;

                            if v_count = 0 then
                                build_element_error('HD01', '875', det_rec.s01, 7, 'Health Coverage Maintenance Code is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            v_det_row.insurance_line_code := det_rec.s03; -- yet to know if this is to be validated
                            if det_rec.s03 is null then
                                build_element_error('HD03', '1205', det_rec.s03, 1, 'Insurance Line Code is Required.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            v_det_row.coverage_level := det_rec.s05;
                            if det_rec.s05 is not null then
                                select
                                    count(*)
                                into v_count
                                from
                                    lookups
                                where
                                        lookup_name = 'EDI_COVERAGE_LEVEL_CD'
                                    and lookup_code = det_rec.s05;

                                if v_count = 0 then
                                    build_element_error('HD05', '1207', det_rec.s05, 7, 'Coverage Level Code is Invalid.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                            end if;

                            v_det_row.coverage_description := det_rec.s04;
                        end if;--HD
                        if det_rec.seg = 'DTP' then--coverage level dates
                            if det_rec.s01 = '348' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'Benefit Begin Date is Required.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.benefit_begin_dt := det_rec.s03;
                                convert_string_to_date(det_rec.s03, v_success_flag, v_converted_date);
                                if v_success_flag = false then
                                    build_element_error('DTP03', '1251', det_rec.s03, 8, 'Benefit Begin Date is Invalid -Date Format error.'
                                    ,
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                            elsif det_rec.s01 = '349' then
                                if det_rec.s03 is null then
                                    build_element_error('DTP03', '1251', det_rec.s03, 1, 'Benefit End Date is Required.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.benefit_end_dt := det_rec.s03;
                                if v_success_flag = false then
                                    build_element_error('DTP03', '1251', det_rec.s03, 8, 'Benefit End Date is Invalid -Date Format error.'
                                    ,
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                            end if;

                        end if; --DTP
                        pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'AMT validation');
                        if det_rec.seg = 'AMT' then
                            if det_rec.s01 is null then
                                build_element_error('AMT01', '522', det_rec.s01, 1, 'Health Coverage AMT qualifier is Required.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            if det_rec.s02 is null then
                                build_element_error('AMT02', '782', det_rec.s02, 1, 'Health Coverage Monetary Amt is Required.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            select
                                count(*)
                            into v_count
                            from
                                lookups
                            where
                                    lookup_name = 'EDI_HD_AMT_CD'
                                and lookup_code = det_rec.s01;

                            if v_count = 0 then
                                build_element_error('AMT01', '522', det_rec.s01, 7, 'Health Coverage AMT qualifier is Invalid.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            if det_rec.s01 = 'D2' then
                                convert_string_to_number(det_rec.s02, v_success_flag, v_converted_number);
                                if v_success_flag = false then
                                    build_element_error('AMT02', '782', det_rec.s02, 6, 'Deductible amount has invalid characters.',
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.deductible := v_converted_number;
                            elsif det_rec.s01 = 'B9' then
                                convert_string_to_number(det_rec.s02, v_success_flag, v_converted_number);
                                if v_success_flag = false then
                                    build_element_error('AMT02', '782', det_rec.s02, 6, 'Annual Election amount has invalid characters.'
                                    ,
                                                        v_err_row);
                                    raise validation_failed;
                                end if;

                                v_det_row.annual_election := v_converted_number;
                            end if;

                        end if;--AMT
                        pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'REF validation');
                        if det_rec.seg = 'REF' then
                            if det_rec.s01 is null then
                                build_element_error('REF01', '128', det_rec.s01, 1, 'Health Coverage REF qualifier is Required.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;

                            if det_rec.s02 is null then
                                build_element_error('REF02', '127', det_rec.s02, 1, 'Health Coverage Policy Number is Required.',
                                                    v_err_row);
                                raise validation_failed;
                            end if;
                --double check this with Vanitha
                            if det_rec.s01 = '17' then
                                v_det_row.policy_number := det_rec.s02;
                            end if;

                        end if;

                    end if;  --loop 2300

        -- insert successful row
                    if ( det_rec.next_seg = 'INS'
                    or det_rec.next_seg is null ) then -- No error in the entire INS loop
                        v_det_row.status_cd := 'PROCESSED';
                        insert_detail_row(p_batch_number, v_det_row, v_err_row, v_file_line, v_header_id);
                        v_det_row := null;
                        v_segment_counter := null;
                    end if;

                exception
                    when validation_failed then
                        error_found := true;
                        v_det_row.status_cd := 'REJECTED';
                        if ( det_rec.next_seg = 'INS'
                        or det_rec.next_seg is null ) then -- error on the last row of the loop
                            insert_detail_row(p_batch_number, v_det_row, v_err_row, 0, v_header_id);
                            v_det_row := null;
                            v_err_row := null;
                            v_segment_counter := null;
                            error_found := false;
                        end if;

                end;
            end if;

        end loop;
  --COMMIT;

        update enrollment_edi_header
        set
            records_received = (
                select
                    count(*)
                from
                    enrollment_edi_detail
            ),
            records_processed = (
                select
                    count(*)
                from
                    enrollment_edi_detail
                where
                    status_cd = 'PROCESSED'
            ),
            records_failed = (
                select
                    count(*)
                from
                    enrollment_edi_detail
                where
                    status_cd = 'REJECTED'
            )
        where
            header_id = v_header_id;
  --commit;
    exception
        when others then
            pc_log.log_error('PROCESS_ENROLLMENT_DETAIL', 'sqlerrm ' || sqlerrm);
            raise_application_error(-20001,
                                    'Enrollment_EDI_Detail process failed. '
                                    || substr(sqlerrm, 1, 50));
    end;

    procedure process_edi_subscriber (
        p_batch_number in number,
        p_detail_id    in number default null
    ) is

        l_account_type   varchar2(30);
        l_entrp_acc_id   number;
        l_entrp_acc_num  varchar2(30);
        l_entrp_id       number;
        l_duplicate_flag varchar2(30) := 'N';
        l_pers_id        number;
        l_acc_id         number;
        l_acc_num        varchar2(30);
        l_benefit_plan   varchar2(30);
        l_ben_plan_id    number;
        l_ee_ben_plan_id number;
        l_ee_ben_plan    varchar2(30);
        l_sponsor_id     varchar2(30);
        l_status         varchar2(255) := 'SUCCESS';
        l_sqlerrm        varchar2(3200);
        l_return_status  varchar2(255) := 'S';
        l_error_message  varchar2(3200);
        l_batch_number   number;
    begin

   -- Let me do pre validation, without benefit plan date
   --
        update enrollment_edi_detail
        set
            error_code = 'BENEFIT_PLAN_DATE_MISSING',
            status_cd = 'INTERFACE_ERROR',
            last_update_date = sysdate
        where
            benefit_begin_dt is null;

        l_batch_number := batch_num_seq.nextval;
   -- Enrollment , we have to discuss with customers how they will tell us about HRA and FSA
   -- for now from EDI we will just do HRA
   -- I will check if the employer is FSA , if they are then just add
   -- it as benefit plans
        for x in (
            select
                birth_date,
                ssn,
                benefit_begin_dt,
                benefit_end_dt,
                decode(coverage_level, 'ECH', 'EE_CHILD', 'EMP', 'SINGLE',
                       'ESP', 'EE_SPOUSE', 'FAM', 'EE_FAMILY', 'SINGLE') coverage_level,
                email,
                phone_work,
                phone_home,
                orig_system_ref,
                subscriber_number,
                case
                    when gender not in ( 'M', 'F' ) then
                        'M'
                    else
                        gender
                end                                                      gender,
                first_name,
                middle_name,
                last_name,
                address,
                city,
                state,
                zip,
                hdr.header_id,
                detail_id,
                hdr.sponsor_id,
                mass_enrollment_id,
                nvl(annual_election, 250)                                annual_election,
                det.creation_date
            from
                enrollment_edi_detail det,
                enrollment_edi_header hdr
            where
                    det.batch_number = p_batch_number
                and det.person_type = 'SUBSCRIBER'
                and hdr.header_id = det.header_id
                and det.status_cd in ( 'PROCESSED' )
              -- AND    det.creation_date > '01-APR-2012'
                and det.detail_id = nvl(p_detail_id, det.detail_id)
                and det.maintenance_cd in ( '030', '021' )
        ) loop
     -- Derive Enterprise Id's and Account Numbers
     -- Derive only if it is null
     -- dbms_output.put_line('Entrp id '||pc_entrp.get_entrp_id_from_ein(x.sponsor_id));
     -- dbms_output.put_line('l_entrp_id '||l_entrp_id);

            if
                l_entrp_id is null
                and nvl(l_sponsor_id, '-1') <> x.sponsor_id
            then
                for xx in (
                    select
                        a.entrp_id,
                        b.acc_num,
                        b.acc_id,
                        b.account_type
                    from
                        enterprise a,
                        account    b
                    where
                            a.entrp_code = replace(x.sponsor_id, '-')
                        and a.entrp_id = b.entrp_id
                        and b.account_type in ( 'HRA', 'FSA' )
                ) loop
                    l_entrp_id := xx.entrp_id;
                    l_entrp_acc_num := xx.acc_num;
                    l_entrp_acc_id := xx.acc_id;
                    l_account_type := xx.account_type;
                end loop;

                l_sponsor_id := x.sponsor_id;

	     -- also see if the employer has benefit plan setup
	     -- I am checking only for HRA'S
                if l_ben_plan_id is null then
                    for xx in (
                        select
                            ben_plan_id,
                            plan_type
                        from
                            ben_plan_enrollment_setup
                        where
                                acc_id = l_entrp_acc_id
                            and plan_type in ( 'HRA', 'HR5', 'HRP' )
                            and entrp_id = l_entrp_id
                    ) loop
                        l_ben_plan_id := xx.ben_plan_id;
                        l_benefit_plan := xx.plan_type;
                    end loop;

                    if l_ben_plan_id is null then
                        l_status := 'ERROR';
                        update enrollment_edi_detail
                        set
                            error_code = 'BENEFIT_PLAN_NOT_SETUP',
                            status_cd = 'INTERFACE_ERROR',
                            last_update_date = sysdate
                        where
                            header_id = x.header_id;

                    end if;

                end if;

            end if; --  l_entrp_id IS NULL
            l_duplicate_flag := 'N';
            if l_status <> 'ERROR' then
                for xx in (
                    select
                        count(*) cnt
                    from
                        person  a,
                        account b
                    where
                            a.orig_sys_vendor_ref = x.subscriber_number
                        and a.entrp_id = l_entrp_id
                        and a.pers_id = b.pers_id
                        and b.account_type in ( 'HRA', 'FSA' )
                ) loop
                    if xx.cnt > 0 then
                        l_duplicate_flag := 'Y';
                    end if;
                end loop;

                if l_duplicate_flag = 'N' then
                    for xx in (
                        select
                            count(*) cnt
                        from
                            person  a,
                            account b
                        where
                                a.ssn = format_ssn(x.ssn)
                            and a.entrp_id = l_entrp_id
                            and a.pers_id = b.pers_id
                            and b.account_type in ( 'HRA', 'FSA' )
                    ) loop
                        if xx.cnt > 0 then
                            l_duplicate_flag := 'Y';
                        end if;
                    end loop;

                end if;
     --  dbms_output.put_line('Entrp id '||l_entrp_id||'SSN '||x.subscriber_number||'l_duplicate_flag '||l_duplicate_flag);
        -- if no duplicates found
                if l_duplicate_flag = 'N' then
                    begin
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
                            phone_even,
                            email,
                            relat_code,
                            note,
                            entrp_id,
                            person_type,
                            creation_date,
                            created_by,
                            orig_sys_vendor_ref
                        ) values ( pers_seq.nextval,
                                   initcap(x.first_name),
                                   substr(x.middle_name, 1, 1),
                                   initcap(x.last_name),
                                   to_date(x.birth_date, 'RRRRMMDD'),
                                   x.gender,
                                   format_ssn(x.ssn),
                                   initcap(x.address),
                                   initcap(x.city),
                                   x.state,
                                   x.zip,
                                   x.phone_work,
                                   x.phone_home,
                                   x.email,
                                   1,
                                   '837 EDI Enrollment',
                                   l_entrp_id,
                                   'SUBSCRIBER',
                                   sysdate,
                                   0,
                                   x.subscriber_number ) returning pers_id into l_pers_id;

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
                                l_pers_id,
                                null,
                                pc_account.generate_acc_num(plan_code, x.state),
                                plan_code,
                                nvl(to_date(x.benefit_begin_dt, 'RRRRMMDD'), sysdate),
                                0,
                                nvl(broker_id, 0),
                                '837 EDI Enrollment',
                                0,
                                fee_maint,
                                sysdate,
                                1 --CASE WHEN TO_DATE(x.benefit_begin_dt,'RRRRMMDD') > SYSDATE THEN
                 -- 3 ELSE 1 END
                                ,
                                1,
                                'Y',
                                null,
                                account_type,
                                annual_election,
                                bps_hra_plan,
                                salesrep_id,
                                'EDI'
                            from
                                account
                            where
                                entrp_id = l_entrp_id;

        /* For now we are not offering debit cards for 837 EDI enrollments
	INSERT INTO CARD_DEBIT
        (card_id,start_date,emitent,note,status,card_number
        ,created_by, last_updated_by,last_update_date
        ,issue_conditional )
        SELECT L_PERS_ID
             ,  NVL(TO_DATE(x.benefit_begin_dt,'RRRRMMDD'), SYSDATE)
             , 6763 -- Metavante
             , 'Mass Enrollment'
             , 2
             , NULL
             , 0
             , 0
             , SYSDATE
             , NULL
        FROM  ENTERPRISE WHERE ENTRP_ID = L_ENTRP_ID AND NVL(CARD_ALLOWED,1) = 0);
        */
                    exception
                        when others then
                            l_sqlerrm := sqlerrm;
                            update enrollment_edi_detail
                            set
                                error_code = l_sqlerrm,
                                status_cd = 'INTERFACE_ERROR',
                                last_update_date = sysdate
                            where
                                    status_cd = 'PROCESSED'
                                and subscriber_number = x.subscriber_number;

                    end;
                else
      /** change address **/
                    update person
                    set
                        address = initcap(x.address),
                        city = x.city,
                        state = x.state,
                        zip = x.zip,
                        last_update_date = sysdate,
                        last_updated_by = 0
         -- ,   orig_sys_vendor_ref = x.subscriber_number
                    where
                            orig_sys_vendor_ref = x.subscriber_number
     --   AND   orig_sys_vendor_ref = x.orig_system_ref
                        and entrp_id = l_entrp_id
                        and last_updated_by = 0
                        and ( upper(address) <> upper(x.address) );

                    null;
                end if;
        /**  let me get pers_id, acc_id, acc_num for this record **/

                for xx in (
                    select
                        a.acc_num,
                        a.acc_id,
                        b.pers_id
                    from
                        account a,
                        person  b
                    where
                            b.orig_sys_vendor_ref = x.subscriber_number
                        and a.pers_id = b.pers_id
                        and a.account_type = l_account_type
                        and b.entrp_id = l_entrp_id
                ) loop
                    l_pers_id := xx.pers_id;
                    l_acc_id := xx.acc_id;
                    l_acc_num := xx.acc_num;
                    dbms_output.put_line('Setting up benefit plan for '
                                         || xx.acc_num
                                         || ' ben plan id '
                                         || l_ben_plan_id
                                         || ' coverage level '
                                         || x.coverage_level);

                    l_ben_plan_id := pc_benefit_plans.get_er_ben_plan(l_entrp_id,
                                                                      'HRA',
                                                                      nvl(to_date(x.benefit_begin_dt, 'RRRRMMDD'), sysdate));

                    l_ee_ben_plan_id := null;
                    l_ee_ben_plan_id := pc_benefit_plans.get_ben_plan(l_ben_plan_id, l_acc_id);
                    if l_ee_ben_plan_id is null then
                        pc_benefit_plans.insert_benefit_plan(
                            p_er_ben_plan_id  => l_ben_plan_id,
                            p_acc_id          => l_acc_id,
                            p_effective_date  => x.benefit_begin_dt,
                            p_annual_election => x.annual_election,
                            p_coverage_level  => x.coverage_level,
                            p_eob_required    => null,
                            p_batch_number    => l_batch_number,
                            x_return_status   => l_return_status,
                            x_error_message   => l_error_message
                        );

                        if l_return_status <> 'E' then
                            update enrollment_edi_detail
                            set
                                status_cd = 'INTERFACED',
                                error_code = l_error_message,
                                acc_id = l_acc_id,
                                pers_id = l_pers_id,
                                acc_num = l_acc_num,
                                last_update_date = sysdate
                            where
                                    detail_id = x.detail_id
                                and status_cd = 'PROCESSED';

                        end if;

                    else
                        if x.benefit_end_dt is not null then
                            update ben_plan_enrollment_setup
                            set
                                status =
                                    case
                                        when to_date(x.benefit_end_dt, 'YYYYMMDD') < sysdate then
                                            'I'
                                        else
                                            status
                                    end,
                                last_updated_by = 0,
                                last_update_date = sysdate,
                                effective_end_date = least(
                                    greatest(to_date(x.benefit_end_dt, 'YYYYMMDD'), plan_start_date),
                                    plan_end_date
                                ),
                                termination_req_date = x.creation_date,
                                note = note || ' terminated from edi file '
                            where
                                    ben_plan_id = l_ee_ben_plan_id
                                and effective_end_date is null;

                        end if;
                    end if;
        --

                end loop;

            end if; -- l_status


            update enrollment_edi_detail
            set
                status_cd = 'INTERFACED',
                acc_id = l_acc_id,
                pers_id = l_pers_id,
                acc_num = l_acc_num,
                last_update_date = sysdate
            where
                    detail_id = x.detail_id
                and status_cd = 'PROCESSED';

        end loop; -- End of Additions
        for x in (
            select
                b.batch_number
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                exists (
                    select
                        *
                    from
                        income
                    where
                            income.acc_id = a.acc_id
                        and fee_code = 12
                )
                and b.batch_number = l_batch_number
                and a.account_type in ( 'HRA', 'FSA' )
                and a.entrp_id is null
                and b.status <> 'R'
                and a.acc_id = b.acc_id
            group by
                b.batch_number
        ) loop
            pc_benefit_plans.create_annual_election(l_batch_number, 0, l_return_status, l_error_message);
        end loop;

    exception
        when others then
            raise;
    end process_edi_subscriber;

    procedure process_edi_dependant (
        p_batch_number in number
    ) is

        l_account_type   varchar2(30);
        l_entrp_acc_id   number;
        l_entrp_acc_num  varchar2(30);
        l_entrp_id       number;
        l_duplicate_flag varchar2(30) := 'N';
        l_pers_id        number;
        l_acc_id         number;
        l_acc_num        varchar2(30);
        l_benefit_plan   varchar2(30);
        l_ben_plan_id    number;
        l_ee_ben_plan    varchar2(30);
        l_sponsor_id     varchar2(30);
        l_status         varchar2(255) := 'SUCCESS';
        l_sqlerrm        varchar2(3200);
    begin


   -- Enrollment , we have to discuss with customers how they will tell us about HRA and FSA
   -- for now from EDI we will just do HRA
   -- I will check if the employer is FSA , if they are then just add
   -- it as benefit plans
        for a in (
            select
                det.birth_date,
                det.ssn,
                det.benefit_begin_dt,
                det.coverage_level,
                det.email,
                det.phone_work,
                det.phone_home,
                det.orig_system_ref,
                det.subscriber_number,
                case
                    when det.gender not in ( 'M', 'F' ) then
                        'M'
                    else
                        det.gender
                end       gender,
                det.first_name,
                det.middle_name,
                det.last_name,
                det.address,
                det.city,
                det.state,
                det.zip,
                hdr.header_id,
                detail_id,
                hdr.sponsor_id
	--	, det.mass_enrollment_id
                ,
                decode(relationship_cd, '19', 3, '01', 2,
                       4) relat_code,
                c.pers_id,
                d.acc_id
  --  , c.mass_enrollment_id
            from
                enrollment_edi_detail det,
                enrollment_edi_header hdr,
                person                c,
                account               d
            where
                    det.batch_number = p_batch_number
                and hdr.header_id = det.header_id
                and c.orig_sys_vendor_ref = det.subscriber_number
                and d.pers_id = c.pers_id
                and c.entrp_id is not null
                and d.account_status <> 5
	 --   AND   det.status_cd  = 'PROCESSED'
                and det.person_type = 'DEPENDANT'
        ) loop
            begin
                l_duplicate_flag := 'N';
                l_pers_id := null;
                for x in (
                    select
                        pers_id
                    from
                        person a
                    where
                            pers_main = a.pers_id
                        and orig_sys_vendor_ref = a.orig_system_ref
                ) loop
                    l_duplicate_flag := 'Y';
                    l_pers_id := x.pers_id;
                end loop;

                if l_duplicate_flag = 'N' then
                    for x in (
                        select
                            pers_id
                        from
                            person a
                        where
                                pers_main = a.pers_id
                            and ssn = format_ssn(a.ssn)
                    ) loop
                        l_duplicate_flag := 'Y';
                        l_pers_id := x.pers_id;
                    end loop;
                end if;

                if l_duplicate_flag = 'N' then
                    select
                        pers_seq.nextval
                    into l_pers_id
                    from
                        dual;

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
                        orig_sys_vendor_ref
                    )
                        select
                            l_pers_id,
                            initcap(a.first_name),
                            initcap(substr(a.middle_name, 1, 1)),
                            initcap(a.last_name),
                            to_date(a.birth_date, 'RRRRMMDD'),
                            a.gender,
                            format_ssn(a.ssn),
                            a.relat_code,
                            '837 EDI Enrollment',
                            a.pers_id,
                            'DEPENDANT',
                            a.orig_system_ref
                        from
                            dual
                        where
                            not exists (
                                select
                                    *
                                from
                                    person c
                                where
                                        replace(c.ssn, '-') = a.ssn
                                    and ssn is not null
                                    and pers_main is not null
                                    and a.ssn <> '999999999'
                                    and pers_main = a.pers_id
                                union
                                select
                                    *
                                from
                                    person c
                                where
                                        orig_sys_vendor_ref = a.orig_system_ref
                                    and pers_main = a.pers_id
                                    and a.orig_system_ref is not null
                                    and pers_main is not null
                            )
                                and exists (
                                select
                                    *
                                from
                                    ben_plan_enrollment_setup
                                where
                                        acc_id = a.acc_id
                                    and plan_type in ( 'HRA', 'HRP', 'HR5' )
                                    and status <> 'R'
                            );

                end if;
     --  IF  SQL%ROWCOUNT > 0 THEN
     --    FOR X IN (SELECT PERS_ID FROM PERSON WHERE ORIG_SYS_VENDOR_REF = A.orig_system_ref)
     --    LOOP
                update enrollment_edi_detail
                set
                    status_cd = 'INTERFACED',
                    last_update_date = sysdate,
                    pers_id = l_pers_id
                where
                    detail_id = a.detail_id;
      --   END LOOP;
      -- END IF;
            exception
                when others then
                    l_sqlerrm := sqlerrm;
                    update enrollment_edi_detail
                    set
                        error_code = l_sqlerrm,
                        status_cd = 'INTERFACE_ERROR',
                        last_update_date = sysdate
                    where
                            status_cd = 'PROCESSED'
                        and detail_id = a.detail_id;

            end;
        end loop;
    end process_edi_dependant;

    procedure process_edi_file (
        p_file_name in varchar2
    ) is
        l_batch_number number;
    begin
        l_batch_number := batch_num_seq.nextval;
        if p_file_name is not null then
            pc_834_enrollment_edi.alter_edi_location(p_file_name);
            pc_834_enrollment_edi.process_enrollment_header(l_batch_number);
            pc_834_enrollment_edi.process_enrollment_detail(l_batch_number);
            pc_834_enrollment_edi.process_edi_subscriber(l_batch_number);
            pc_834_enrollment_edi.process_edi_dependant(l_batch_number);
            pc_834_enrollment_edi.update_orig_sys_ref_person;
            pc_834_enrollment_edi.send_email_on_new_enrollment(l_batch_number);
        end if;

    end process_edi_file;

    procedure update_orig_sys_ref_person as
    begin
        update person
        set
            orig_sys_vendor_ref = null
        where
            entrp_id is null
            and orig_sys_vendor_ref not like 'COB%'
            and pers_id in (
                select
                    pers_id
                from
                    account
                where
                    account_status = 5
            );

        update person
        set
            orig_sys_vendor_ref = null
        where
            entrp_id is null
            and orig_sys_vendor_ref not like 'COB%'
            and pers_main in (
                select
                    pers_id
                from
                    account
                where
                    account_status = 5
            );

    end update_orig_sys_ref_person;

end pc_834_enrollment_edi;
/


-- sqlcl_snapshot {"hash":"699e4e64f6efa04f9f0e9a2ca8ca8b2b9ae3c487","type":"PACKAGE_BODY","name":"PC_834_ENROLLMENT_EDI","schemaName":"SAMQA","sxml":""}