-- liquibase formatted sql
-- changeset SAMQA:1754374027795 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_eob_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_eob_upload.sql:null:69285613eb5be2a959c883f82d11eb601713cb05:create

create or replace package body samqa.pc_eob_upload is

/******************************************************************************
   NAME:      PC_EOB_UPLOAD
   PURPOSE:   TO UPLOAD FILE FEED INTO EOB_HEADER  TABLES
 ******************************************************************************/

--PROCEDURE TO CAPTURE ERRORS OCCURED WHILE PERFORMING FILE FEED UPDATES--
    procedure log_eob_error (
        p_label   in varchar2,
        p_message in varchar2
    ) is
    begin
        insert into eob_errors (
            err_id,
            label,
            message,
            creation_date
        ) values ( eob_error_seq.nextval,
                   p_label,
                   p_message,
                   sysdate );

        commit;
    exception
        when others then
            null;
    end log_eob_error;

--PROCEDURE TO SEND MAIL ALERT WHEN ERROR OCCURS WHILE PERFORMING FILE FEED UPDATES-- 
    procedure send_alert (
        p_file_name in varchar2
    ) is
    begin
        if file_exists(p_file_name, 'EOB_DIR') = 'TRUE' then
            if file_exists(p_file_name || '.bad', 'EOB_DIR') = 'TRUE' then
                mail_utility.email_files(
                    from_name    => 'noreply@sterlinghsa.com',
                    to_names     => 'vathsala.yj@sterlinghsa.com',
                    subject      => 'EOB Rejected File',
                    html_message => 'EOB Rejected File',
                    attach       => samfiles('/u01/app/oracle/oradata/hex/eob/'
                                       || p_file_name
                                       || '.bad')
                );
            end if;

            if file_exists(p_file_name || '.log', 'EOB_DIR') = 'TRUE' then
                mail_utility.email_files(
                    from_name    => 'noreply@sterlinghsa.com',
                    to_names     => 'vathsala.yj@sterlinghsa.com',
                    subject      => 'EOB Log File',
                    html_message => 'EOB Telecom Log File',
                    attach       => samfiles('/u01/app/oracle/oradata/hex/eob/'
                                       || p_file_name
                                       || '.log')
                );

            end if;

        end if;
    end send_alert;

--PROCEDURE TO UPLOAD FILE FEED INTO EOB_HEADER TABLE--
    procedure eob_header_upload (
        p_header_file in varchar2
    ) is

        eob_dir      varchar2(100);
        l_sql        varchar2(32000);
        l_file_name  varchar2(100);
        type t_eob_header is
            table of eob_header_external%rowtype;
        l_eob_header t_eob_header;
    begin
        eob_dir := '/u01/app/oracle/oradata/hex/eob';
        l_sql := 'ALTER TABLE EOB_HEADER_EXTERNAL LOCATION(EOB_DIR:'''
                 || p_header_file
                 || ''')';
        begin
            execute immediate l_sql;
        exception
            when others then
                log_eob_error('EOB_HEADER_EXTERNAL', sqlerrm);
                send_alert(l_file_name);
        end;

        l_file_name := rtrim(p_header_file, '.csv');
        begin
            select
                *
            bulk collect
            into l_eob_header
            from
                eob_header_external ehe
            where
                exists (
                    select
                        1
                    from
                        eob_header e
                    where
                        e.eob_id = ehe.eob_id
                );

        exception
            when others then
                log_eob_error('EOB_HEADER_EXTERNAL' || p_header_file, sqlerrm);
                send_alert(l_file_name);
        end;

        for eh in 1..l_eob_header.count loop
            begin
                update eob_header e
                set
                    user_id = l_eob_header(eh).tpa_user_id,
                    action = l_eob_header(eh).action,
                    eob_status = l_eob_header(eh).status,
                    claim_number = l_eob_header(eh).claim_number,
                    service_date_from = format_to_date(l_eob_header(eh).service_date_from),
                    provider_name = l_eob_header(eh).provider_name,
                    provider_id = l_eob_header(eh).provider_id,
                    insplan_id = l_eob_header(eh).insplan_id,
                    company_id = l_eob_header(eh).company_id,
                    creation_date = nvl(
                        format_to_date(l_eob_header(eh).creation_date),
                        sysdate
                    ),
                    last_update_date = nvl(
                        format_to_date(l_eob_header(eh).last_update_date),
                        sysdate
                    ),
                    patient_first_name = l_eob_header(eh).patient_first_name,
                    patient_last_name = l_eob_header(eh).patient_last_name
                where
                    e.eob_id = l_eob_header(eh).eob_id;

            exception
                when others then
                    rollback;
                    log_eob_error('EOB_HEADER', sqlerrm);
                    send_alert(l_file_name);
            end;
        end loop;

        begin
            insert into eob_header (
                eob_id,
                user_id,
                claim_number,
                provider_id,
                description,
                service_date_from,
                service_date_to,
                service_amount,
                amount_due,
                eob_status,
                eob_status_code,
                modified,
                claim_id,
                acc_id,
                source,
                creation_date,
                last_update_date,
                last_updated_by,
                created_by,
                action,
                provider_name,
                insplan_id,
                company_id,
                patient_first_name,
                patient_last_name
            )
                select
                    eob_id,
                    tpa_user_id,
                    claim_number,
                    provider_id,
                    null,
                    format_to_date(service_date_from) service_date_from,
                    null,
                    null,
                    null,
                    status,
                    'NEW',
                    null,
                    null,
                    null,
                    'HEALTH_EXPENSE',
                    nvl(
                        format_to_date(creation_date),
                        sysdate
                    )                                 creation_date,
                    nvl(
                        format_to_date(last_update_date),
                        sysdate
                    )                                 last_update_date,
                    null,
                    null,
                    action,
                    provider_name,
                    insplan_id,
                    company_id,
                    patient_first_name,
                    patient_last_name
                from
                    eob_header_external eh
                where
                    eh.eob_id is not null
                    and not exists (
                        select
                            1
                        from
                            eob_header e
                        where
                            eh.eob_id = e.eob_id
                    );

        exception
            when others then
                rollback;
                log_eob_error('EOB_HEADER', sqlerrm);
                send_alert(l_file_name);
        end;

        commit;
    end eob_header_upload;

--PROCEDURE TO UPLOAD FILE FEED INTO EOB_DETAIL TABLE--
    procedure eob_detail_upload (
        p_detail_file in varchar2
    ) is

        eob_dir      varchar2(100);
        l_sql        varchar2(32000);
        l_file_name  varchar2(100);
        type t_eob_detail is
            table of eob_detail_external%rowtype;
        l_eob_detail t_eob_detail;
        type t_eob_rec is
            table of t_eob_header;
        l_eob_header t_eob_rec;
        l_cnt        number := 0;
    begin
        eob_dir := '/u01/app/oracle/oradata/hex/eob';
        l_sql := 'ALTER TABLE EOB_DETAIL_EXTERNAL LOCATION(EOB_DIR:'''
                 || p_detail_file
                 || ''')';
        begin
            execute immediate l_sql;
        exception
            when others then
                log_eob_error('EOB_DETAIL_EXTERNAL', sqlerrm);
                send_alert(l_file_name);
        end;

        l_file_name := rtrim(p_detail_file, '.csv');
        begin
            select
                *
            bulk collect
            into l_eob_detail
            from
                eob_detail_external ede
            where
                exists (
                    select
                        1
                    from
                        eob_detail e
                    where
                        ede.eob_detail_id = e.eob_detail_id
                );

        exception
            when others then
                log_eob_error('EOB_DETAIL_EXTERNAL' || p_detail_file, sqlerrm);
                send_alert(l_file_name);
        end;

        for ed in 1..l_eob_detail.count loop
            begin
                begin
                    select
                        count(*)
                    into l_cnt
                    from
                        eob_header
                    where
                            eob_id = l_eob_detail(ed).eob_id
                        and claim_id is not null;

                exception
                    when others then
                        l_cnt := 0;
                end;

                if l_cnt = 0 then
                    update eob_detail e
                    set
                        eob_id = l_eob_detail(ed).eob_id,
                        action = l_eob_detail(ed).action,
                        error_flag = l_eob_detail(ed).error_flag,
                        service_date_from = format_to_date(l_eob_detail(ed).service_date_from),
                        medical_code = l_eob_detail(ed).procedure_code,
                        description = l_eob_detail(ed).description,
                        amount_charged = l_eob_detail(ed).amount_charged,
                        amount_withdiscount = l_eob_detail(ed).amount_withdiscount,
                        amount_notcovered = l_eob_detail(ed).amount_notcovered,
                        amount_paidbyins = l_eob_detail(ed).amount_paidbyins,
                        amount_planpayment = l_eob_detail(ed).amount_planpayment,
                        amount_deductible = l_eob_detail(ed).amount_deductible,
                        amount_coinsurance = l_eob_detail(ed).amount_coinsurance,
                        amount_copay = l_eob_detail(ed).amount_copay,
                        final_patient_amount = l_eob_detail(ed).final_patient_amount,
                        creation_date = nvl(
                            format_to_date(l_eob_detail(ed).creation_date),
                            sysdate
                        ),
                        last_update_date = nvl(
                            format_to_date(l_eob_detail(ed).last_update_date),
                            sysdate
                        )
                    where
                        e.eob_detail_id = l_eob_detail(ed).eob_detail_id;

                end if;

            exception
                when others then
                    log_eob_error('EOB_DETAIL', sqlerrm);
                    send_alert(l_file_name);
            end;
        end loop;

        begin
            insert into eob_detail (
                eob_detail_id,
                eob_id,
                service_date_from,
                service_date_to,
                description,
                medical_code,
                amount_charged,
                ins_paid_amount,
                final_patient_amount,
                modified,
                insurance_notes,
                patient_notes,
                source,
                creation_date,
                last_update_date,
                last_updated_by,
                created_by,
                action,
                error_flag,
                amount_withdiscount,
                amount_notcovered,
                amount_paidbyins,
                amount_planpayment,
                amount_deductible,
                amount_coinsurance,
                amount_copay
            )
                select
                    eob_detail_id,
                    eob_id,
                    format_to_date(service_date_from) service_date_from,
                    format_to_date(service_date_from),
                    description,
                    procedure_code,
                    amount_charged,
                    null,
                    final_patient_amount,
                    null,
                    null,
                    null,
                    null,
                    nvl(
                        format_to_date(creation_date),
                        sysdate
                    )                                 creation_date,
                    nvl(
                        format_to_date(last_update_date),
                        sysdate
                    )                                 last_update_date,
                    null,
                    null,
                    action,
                    error_flag,
                    amount_withdiscount,
                    amount_notcovered,
                    amount_paidbyins,
                    amount_planpayment,
                    amount_deductible,
                    amount_coinsurance,
                    amount_copay
                from
                    eob_detail_external ed
                where
                    ed.eob_detail_id is not null
                    and not exists (
                        select
                            1
                        from
                            eob_detail e
                        where
                            ed.eob_detail_id = e.eob_detail_id
                    );

        exception
            when others then
                log_eob_error('EOB_DETAIL', sqlerrm);
                send_alert(l_file_name);
        end;

        begin
            select
                eob_id,
                description,
                amount_charged,
                final_patient_amount
            bulk collect
            into l_eob_header
            from
                eob_detail_external ed
            where
                exists (
                    select
                        1
                    from
                        eob_header e
                    where
                        e.eob_id = ed.eob_id
                );

            forall i in 1..l_eob_header.count save exceptions
                update eob_header e
                set
                    e.description = l_eob_header(i).description,
                    e.service_amount = l_eob_header(i).service_amt,
                    e.amount_due = l_eob_header(i).amt_due
                where
                    e.eob_id = l_eob_header(i).eobid;

        exception
            when others then
                null;
        end;

        commit;
    end eob_detail_upload;

--PROCEDURE TO UPLOAD FILE FEED INTO EOB_ELIGIBLE_EXTERNAL  TABLES--
    procedure eob_eligible_upload (
        p_eligible_file in varchar2,
        p_load          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        eob_dir         varchar2(100);
        l_sql           varchar2(4000);
        l_file_name     varchar2(100);
        l_file          utl_file.file_type;
        l_blob_len      integer;
        temp            number := 0;
        l_pos           integer := 1;
        l_amount        binary_integer := 32767;
        l_buffer        raw(32767);
        l_blob          blob;
        seq_num         number;
        lv_dest_file    varchar2(4000);
        e_forbulk_error exception;
        l_count         number := 0;
        l_cnt           number := 0;
        pragma exception_init ( e_forbulk_error, -24381 );
        type t_eligible_info is
            table of t_eligible_rec;
        l_eligible_info t_eligible_info;
    begin
        eob_dir := '/u01/app/oracle/oradata/hex/eob';
        x_return_status := 'S';
        if p_load = 'A' then --SAM Screen EOB Upload
            lv_dest_file := substr(p_eligible_file,
                                   instr(p_eligible_file, '/', 1) + 1,
                                   length(p_eligible_file) - instr(p_eligible_file, '/', 1));

            begin
                select
                    blob_content
                into l_blob
                from
                    wwv_flow_files
                where
                    name = p_eligible_file;

                l_file := utl_file.fopen('EOB_DIR', p_eligible_file, 'w');--, 32767);
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
                    name = p_eligible_file;

            exception
                when others then
                    x_error_message := 'Error in Uploading file Stage 1' || sqlerrm;
                    x_return_status := 'E';
                    pc_eob_upload.log_eob_error('EOB_CLAIMS_EXTERNAL', sqlerrm);
            end;

        else
            lv_dest_file := p_eligible_file;
        end if;
   
   --L_SQL := 'ALTER TABLE EOB_ELIGIBLE_EXTERNAL LOCATION(EOB_DIR:'''||P_ELIGIBLE_FILE||''')';
        l_sql := 'ALTER TABLE EOB_ELIGIBLE_EXTERNAL LOCATION(EOB_DIR:'''
                 || lv_dest_file
                 || ''')';
        begin
            execute immediate l_sql;
        exception
            when others then
                x_error_message := 'Error in Uploading file Stage 2' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('EOB_ELIGIBLE_EXTERNAL', sqlerrm);
        end;

        l_file_name := rtrim(p_eligible_file, '.csv');
        begin
     --Added by karthe
            seq_num := null;
            seq_num := eob_eligible_staging_seq.nextval;
            insert into eob_eligible_staging (
                eligible_upload_id,
                account_no,
                member_id,
                ssn,
                emp_last_name,
                emp_first_name,
                emp_dob,
                process_date
            )
                select
                    seq_num, --Added by karthe
                    e.account_no,
                    e.member_id,
                    format_ssn(e.ssn),
                    e.emp_last_name,
                    e.emp_first_name,
                    format_to_date(e.emp_dob),
                    trunc(sysdate)
                from
                    eob_eligible_external e
                where
                    e.account_no is not null;

        exception
            when others then
                x_error_message := 'Error in Uploading file Stage 3' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('EOB_ELIGIBLE_STAGING INSERT', sqlerrm);
        end;

        begin
            select
                e.eligible_upload_id,
                p.pers_id,
                e.member_id,
                e.ssn
            bulk collect
            into l_eligible_info
            from
                person               p,
                eob_eligible_staging e
            where
                    e.eligible_upload_id = seq_num --Added by karthe
                and p.ssn = e.ssn
                and p.birth_date = e.emp_dob
                and e.process_date = trunc(sysdate);

        exception
            when others then
                x_error_message := 'Error in Uploading file Stage 4' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('MAPPING NOT FOUND', sqlerrm);
        end;

        for e in 1..l_eligible_info.count loop
            begin
                select distinct
                    1
                into l_cnt
                from
                    insure
         --WHERE PERS_ID = L_ELIGIBLE_INFO(E).T_PERS_ID;
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            person
                        where
                            ssn = l_eligible_info(e).t_ssn
                    );

            exception
                when no_data_found then
                    update eob_eligible_staging e
                    set
                        process_status = 'E',
                        err_msg = 'Person Details not found in Insure'
                    where
                            eligible_upload_id = seq_num
                        and ssn = l_eligible_info(e).t_ssn
                        and pers_id is null
                        and e.process_status is null;

                when others then
                    pc_eob_upload.log_eob_error('eob eligible update ' || l_eligible_info(e).t_ssn,
                                                sqlerrm);
            end;
        end loop;

        l_count := 0;
        for e in 1..l_eligible_info.count loop
            begin
                select distinct
                    1
                into l_count
                from
                    insure
                where
                    pers_id in (
                        select
                            pers_id
                        from
                            person
                        where
                            ssn <> l_eligible_info(e).t_ssn
                    )
                    and insurance_member_id = l_eligible_info(e).t_member_id;

                if l_count = 1 then
                    update eob_eligible_staging e
                    set
                        process_status = 'E',
                        err_msg = 'Member Id already associated to 1 Social'
                    where
                            eligible_upload_id = seq_num
                        and ssn = l_eligible_info(e).t_ssn
                        and pers_id is null
                        and e.process_status is null;

                end if;

            exception
                when no_data_found then
                    null;
                when others then
                    pc_eob_upload.log_eob_error('eob eligible update ' || l_eligible_info(e).t_ssn,
                                                sqlerrm);
            end;
        end loop;

        begin
            forall e in 1..l_eligible_info.count save exceptions
                update insure i
                set
                    insurance_member_id = l_eligible_info(e).t_member_id
                where
                        i.pers_id = l_eligible_info(e).t_pers_id
                    and l_count <> 1;

            forall e in 1..l_eligible_info.count
                update eob_eligible_staging
                set
                    pers_id = l_eligible_info(e).t_pers_id,
                    process_status = 'P'
                where
                        eligible_upload_id = l_eligible_info(e).t_seq_num
                    and member_id = l_eligible_info(e).t_member_id
                    and err_msg is null;

        exception
            when e_forbulk_error then
                for i in 1..sql%bulk_exceptions.count loop
                    pc_eob_upload.log_eob_error('update insure failed',
                                                'SQLCODE:'
                                                || sql%bulk_exceptions(i).error_code);

                    pc_eob_upload.log_eob_error('update insure failed',
                                                'SQLERRM:'
                                                || sqlerrm(-sql%bulk_exceptions(i).error_code));

                end loop;
            when others then
                rollback;
                x_error_message := 'Error in Uploading file Stage 5' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('INSURE', sqlerrm);
        end;

        begin
            update eob_eligible_staging e
            set
                process_status = 'E',
                err_msg = 'Mapping Not found'
            where
                    e.eligible_upload_id = seq_num  --Added by karthe
                and e.process_status is null;

        exception
            when others then
                rollback;
                x_error_message := 'Error in Uploading file Stage 6' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('EOB_ELIGIBLE_STAGING', sqlerrm);
        end;

        commit;
    end eob_eligible_upload;
 
--PROCEDURE TO UPLOAD FILE FEED INTO EOB_CLAIMS_EXTERNAL, STAGING  TABLES
    procedure eob_claims_upload (
        p_claims_file   in varchar2,
        p_load          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        eob_dir          varchar2(100);
        l_sql            varchar2(32000);
        seq_num          number;
        lv_dest_file     varchar2(4000);
        l_blob_len       integer;
        l_blob           blob;
        l_buffer         raw(32767);
        l_file           utl_file.file_type;
        l_pos            integer := 1;
        l_amount         binary_integer := 32767;
        e_forbulk_error exception;
        pragma exception_init ( e_forbulk_error, -24381 );
        type t_dupeob_rec is
            table of eob_header_rec;
        l_dupeob_header  t_dupeob_rec;
        type t_eob_rec is
            table of eob_header_rec;
        l_eob_header     t_eob_rec;
        type t_eob_claims_rec is
            table of eob_claims_staging%rowtype;
        l_eob_claims_rec t_eob_claims_rec;
        type t_eob_amt is
            table of t_eob_amt_rec;
        l_eob_amt        t_eob_amt;
    begin
        eob_dir := '/u01/app/oracle/oradata/hex/eob';
        if p_load = 'A' then --SAM Screen EOB Upload
            lv_dest_file := substr(p_claims_file,
                                   instr(p_claims_file, '/', 1) + 1,
                                   length(p_claims_file) - instr(p_claims_file, '/', 1));

            begin
                select
                    blob_content
                into l_blob
                from
                    wwv_flow_files
                where
                    name = p_claims_file;

                l_file := utl_file.fopen('EOB_DIR', p_claims_file, 'w');--, 32767);
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
                    name = p_claims_file;

            exception
                when others then
                    x_error_message := 'Error in Uploading Claim file Stage 1' || sqlerrm;
                    x_return_status := 'E';
                    pc_eob_upload.log_eob_error('EOB_CLAIMS_EXTERNAL', sqlerrm);
            end;

        else
            lv_dest_file := p_claims_file;
        end if;

        l_sql := 'ALTER TABLE EOB_CLAIMS_EXTERNAL LOCATION(EOB_DIR:'''
                 || lv_dest_file
                 || ''')';
        begin
            execute immediate l_sql;
            process_eob_claims(x_error_message, x_return_status);
        exception
            when others then
                x_error_message := 'Error in Uploading Claim file Stage 2' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('EOB_CLAIMS_EXTERNAL Stage 1', sqlerrm);
        end;

    end eob_claims_upload;

    procedure uha_eob_claims_upload (
        p_claims_file   in varchar2,
        p_load          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        eob_dir          varchar2(100);
        l_sql            varchar2(32000);
        seq_num          number;
        lv_dest_file     varchar2(4000);
        l_blob_len       integer;
        l_blob           blob;
        l_buffer         raw(32767);
        l_file           utl_file.file_type;
        l_pos            integer := 1;
        l_amount         binary_integer := 32767;
        e_forbulk_error exception;
        pragma exception_init ( e_forbulk_error, -24381 );
        type t_dupeob_rec is
            table of eob_header_rec;
        l_dupeob_header  t_dupeob_rec;
        type t_eob_rec is
            table of eob_header_rec;
        l_eob_header     t_eob_rec;
        type t_eob_claims_rec is
            table of eob_claims_staging%rowtype;
        l_eob_claims_rec t_eob_claims_rec;
        type t_eob_amt is
            table of t_eob_amt_rec;
        l_eob_amt        t_eob_amt;
        l_files          samfiles := samfiles();
    begin
        x_return_status := 'S';
        eob_dir := '/u01/app/oracle/oradata/autoenroll/EOB/IN';
        if p_load = 'A' then --SAM Screen EOB Upload
            lv_dest_file := substr(p_claims_file,
                                   instr(p_claims_file, '/', 1) + 1,
                                   length(p_claims_file) - instr(p_claims_file, '/', 1));

            begin
                select
                    blob_content
                into l_blob
                from
                    wwv_flow_files
                where
                    name = p_claims_file;

                l_file := utl_file.fopen('EOB_IN_DIR', p_claims_file, 'w');--, 32767);
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
                    name = p_claims_file;

            exception
                when others then
                    x_error_message := 'Error in Uploading Claim file Stage 1' || sqlerrm;
                    x_return_status := 'E';
                    pc_eob_upload.log_eob_error('EOB_CLAIMS_EXTERNAL', sqlerrm);
            end;

        else
            lv_dest_file := p_claims_file;
        end if;

        l_sql := 'ALTER TABLE EOB_CLAIMS_EXTERNAL LOCATION(EOB_IN_DIR:'''
                 || lv_dest_file
                 || ''')';
        begin
            execute immediate l_sql;
            process_eob_claims(x_error_message, x_return_status);
        exception
            when others then
                x_error_message := 'Error in Uploading Claim file Stage 2' || sqlerrm;
                x_return_status := 'E';
                l_files(1) := '/u01/app/oracle/oradata/autoenroll/EOB/IN/' || lv_dest_file;
                mail_utility.email_files(
                    from_name    => 'enrollments@sterlingadministration.com',
                    to_names     => 'techsupport@sterlingadministration.com',
                    subject      => 'Error in UHA claim  file Upload ' || lv_dest_file,
                    html_message => sqlerrm,
                    attach       => l_files
                );

                pc_eob_upload.log_eob_error('EOB_CLAIMS_EXTERNAL Stage 1', sqlerrm);
        end;

    end uha_eob_claims_upload;

    procedure process_eob_claims (
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        eob_dir          varchar2(100);
        l_sql            varchar2(32000);
        seq_num          number;
        lv_dest_file     varchar2(4000);
        l_blob_len       integer;
        l_blob           blob;
        l_buffer         raw(32767);
        l_file           utl_file.file_type;
        l_pos            integer := 1;
        l_amount         binary_integer := 32767;
        e_forbulk_error exception;
        pragma exception_init ( e_forbulk_error, -24381 );
        type t_dupeob_rec is
            table of eob_header_rec;
        l_dupeob_header  t_dupeob_rec;
        type t_eob_rec is
            table of eob_header_rec;
        l_eob_header     t_eob_rec;
        type t_eob_claims_rec is
            table of eob_claims_staging%rowtype;
        l_eob_claims_rec t_eob_claims_rec;
        type t_eob_amt is
            table of t_eob_amt_rec;
        l_eob_amt        t_eob_amt;
    begin
        begin
            seq_num := null;
            seq_num := eob_claims_staging_seq.nextval;
            insert into eob_claims_staging (
                claims_upload_id,
                claim_number,
                provider_payment_number,
                adjustment_number,
                benefit_line_number,
                received_date,
                processed_date,
                check_date,
                group_name,
                group_number,
                account_no,
                member_id,
                emp_first_name,
                emp_last_name,
                emp_dob,
                gender,
                product_id,
                plan_code,
                dependent_seq_num,
                claimant_first_name,
                claimant_last_name,
                dependent_dob,
                dependent_gender,
                relationship_code,
                provider_taxid_num,
                provider_payee_name,
                provider_first_name,
                provider_last_name,
                provider_type,
                provider_speciality,
                provider_zipcode,
                claim_category,
                benefit_type,
                service_category,
                service_from_date,
                service_to_date,
                cpt_code,
                num_of_services,
                diagnosis_code1,
                diagnosis_code2,
                amount_charged,
                amount_excluded,
                excluded_remark_code1,
                excluded_remark_code2,
                covered_expense,
                copay,
                deductible,
                coinsurance,
                cob_paid,
                paid_amount,
                provider_check_amount,
                provider_check_number,
                employee_check_number,
                employee_check_amount,
                class_code,
                escrow_amount,
                cpt_modifier,
                employee_location,
                provider_city,
                provider_state,
                place_of_service,
                provider_contract_num,
                provider_address,
                provider_address2,
                provider_npi,
                drg_revenue_code,
                excluded_amt_all_others,
                excluded_amt_ppo_discount,
                excluded_amt_rc_exceeded,
                excluded_amt_plan_limit,
                excluded_amt_duplicate,
                excluded_amt_otherins,
                excluded_amt_adj_rev,
                process_date,
                ssn,
                tpa_id,
                orig_claim_number,
                patient_responsibility
            )
                select
                    seq_num,
                    e.claim_number,
                    e.provider_payment_number,
                    e.adjustment_number,
                    e.benefit_line_number,
                    format_to_date(e.received_date),
                    format_to_date(e.processed_date),
                    format_to_date(e.check_date),
                    e.group_name,
                    e.group_number,
                    e.account_no,
                    e.member_id,
                    e.emp_first_name,
                    e.emp_last_name,
                    format_to_date(e.emp_dob),
                    e.gender,
                    e.product_id,
                    e.plan_code,
                    e.dependent_seq_num,
                    e.claimant_first_name,
                    e.claimant_last_name,
                    format_to_date(e.dependent_dob),
                    e.dependent_gender,
                    e.relationship_code,
                    e.provider_taxid_num,
                    e.provider_payee_name,
                    e.provider_first_name,
                    e.provider_last_name,
                    e.provider_type,
                    e.provider_speciality,
                    e.provider_zipcode,
                    e.claim_category,
                    e.benefit_type,
                    e.service_category,
                    format_to_date(e.service_from_date),
                    format_to_date(e.service_to_date),
                    e.cpt_code,
                    e.num_of_services,
                    e.diagnosis_code1,
                    e.diagnosis_code2,
                    e.amount_charged,
                    e.amount_excluded,
                    e.excluded_remark_code1,
                    e.excluded_remark_code2,
                    e.covered_expense,
                    e.copay,
                    e.deductible,
                    e.coinsurance,
                    e.cob_paid,
                    e.paid_amount,
                    e.provider_check_amount,
                    e.provider_check_number,
                    e.employee_check_number,
                    e.employee_check_amount,
                    e.class_code,
                    e.escrow_amount,
                    e.cpt_modifier,
                    e.employee_location,
                    e.provider_city,
                    e.provider_state,
                    e.place_of_service,
                    e.provider_contract_num,
                    e.provider_address,
                    e.provider_address2,
                    e.provider_npi,
                    e.drg_revenue_code,
                    e.excluded_amt_all_others,
                    e.excluded_amt_ppo_discount,
                    e.excluded_amt_rc_exceeded,
                    e.excluded_amt_plan_limit,
                    e.excluded_amt_duplicate,
                    e.excluded_amt_otherins,
                    e.excluded_amt_adj_rev,
                    trunc(sysdate),
                    e.ssn,
                    e.tpa_id,
                    e.orig_claim_number,
                    e.patient_responsibility
                from
                    eob_claims_external e
                where
                    e.claim_number is not null;

        exception
            when others then
                rollback;
                pc_eob_upload.log_eob_error('EOB_CLAIMS_STAGING 2', sqlerrm);
        end;

        begin
            select distinct
                claim_number,
                provider_payee_name,
                provider_taxid_num,
                member_id,
                ssn,
                claimant_first_name,
                claimant_last_name
            bulk collect
            into l_dupeob_header
            from
                eob_claims_staging ec
            where
                    claims_upload_id = seq_num
                and exists (
                    select
                        1
                    from
                        person p
                    where
                        p.ssn = format_ssn(ec.ssn)
                )
                and exists (
                    select
                        1
                    from
                        eob_header e
                    where
                            e.claim_number = ec.claim_number
                        and e.description = ec.provider_payee_name
                        and ec.claimant_first_name = e.patient_first_name
                        and ec.claimant_last_name = e.patient_last_name
                );

            forall i in 1..l_dupeob_header.count save exceptions
                update eob_claims_staging e
                set
                    process_status = 'E',
                    err_msg = 'Duplicate Claim Number exists for same or different Employee'
                where
                        claims_upload_id = seq_num
                    and e.claim_number = l_dupeob_header(i).claim_number
                    and e.provider_payee_name = l_dupeob_header(i).provider_payee_name
                    and e.claimant_first_name = l_dupeob_header(i).patient_first_name
                    and e.claimant_last_name = l_dupeob_header(i).patient_last_name
                    and e.ssn = l_dupeob_header(i).ssn;

        exception
            when e_forbulk_error then
                for i in 1..sql%bulk_exceptions.count loop
                    pc_eob_upload.log_eob_error('update claims staging failed',
                                                'SQLCODE:'
                                                || sql%bulk_exceptions(i).error_code);

                    pc_eob_upload.log_eob_error('update claims staging failed',
                                                'SQLERRM:'
                                                || sqlerrm(-sql%bulk_exceptions(i).error_code));

                end loop;
            when others then
                x_error_message := 'Error in Uploading file Stage 5' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('Duplicate Claim Number Error Staging 3', sqlerrm);
        end;

        begin
            select
                claim_number,
                provider_payee_name,
                provider_taxid_num,
                member_id,
                ssn,
                claimant_first_name,
                claimant_last_name
            bulk collect
            into l_eob_header
            from
                (
                    select distinct
                        claim_number,
                        provider_payee_name,
                        provider_taxid_num,
                        member_id,
                        ssn,
                        claimant_first_name,
                        claimant_last_name
                    from
                        eob_claims_staging ec
                    where
                            claims_upload_id = seq_num
                        and exists (
                            select
                                1
                            from
                                insure i,
                                person p
                            where
                                    p.ssn = format_ssn(ec.ssn)
                                and i.pers_id = p.pers_id
                        )
                        and not exists (
                            select
                                1
                            from
                                eob_header e
                            where
                                    e.claim_number = ec.claim_number
                                and e.description = ec.provider_payee_name
                                and ec.claimant_first_name = e.patient_first_name
                                and ec.claimant_last_name = e.patient_last_name
                        )
                    union
                    select distinct
                        claim_number,
                        provider_payee_name,
                        provider_taxid_num,
                        member_id,
                        ssn,
                        claimant_first_name,
                        claimant_last_name
                    from
                        eob_claims_staging ec
                    where
                            claims_upload_id = seq_num
                        and exists (
                            select
                                1
                            from
                                insure i,
                                person p
                            where
                                    i.insurance_member_id = ec.member_id
                                and i.pers_id = p.pers_id
                        )
                        and not exists (
                            select
                                1
                            from
                                eob_header e
                            where
                                    e.claim_number = ec.claim_number
                                and e.description = ec.provider_payee_name
                        )
                );

        exception
            when others then
                pc_eob_upload.log_eob_error('EOB_CLAIMS_STAGING 4', sqlerrm);
        end;

        begin
            forall i in 1..l_eob_header.count save exceptions
                insert into eob_header (
                    eob_id,
                    claim_number,
                    description,
                    member_id,
                    eob_status,
                    eob_status_code,
                    source,
                    ssn,
                    patient_first_name,
                    patient_last_name,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( eob_header_seq.nextval,
                           l_eob_header(i).claim_number,
                           l_eob_header(i).provider_payee_name,
                           l_eob_header(i).member_id,
                           'New',
                           'NEW',
                           'CARRIER_FEED',
                           l_eob_header(i).ssn,
                           l_eob_header(i).patient_first_name,
                           l_eob_header(i).patient_last_name,
                           trunc(sysdate),
                           0,
                           sysdate,
                           0 );

            forall i in 1..l_eob_header.count save exceptions
                update eob_claims_staging e
                set
                    process_status = 'P'
                where
                        claims_upload_id = seq_num
                    and e.claim_number = l_eob_header(i).claim_number
                    and e.provider_payee_name = l_eob_header(i).provider_payee_name
                    and e.ssn = l_eob_header(i).ssn
                    and e.claimant_first_name = l_eob_header(i).patient_first_name
                    and e.claimant_last_name = l_eob_header(i).patient_last_name;

        exception
            when e_forbulk_error then
                for i in 1..sql%bulk_exceptions.count loop
                    pc_eob_upload.log_eob_error('insert eob_header and update claims staging failed',
                                                'SQLCODE:'
                                                || sql%bulk_exceptions(i).error_code);

                    pc_eob_upload.log_eob_error('insert eob_header and update claims staging failed',
                                                'SQLERRM:'
                                                || sqlerrm(-sql%bulk_exceptions(i).error_code));

                end loop;
            when others then
                pc_eob_upload.log_eob_error('EOB_header Stage 5', sqlerrm);
        end;

        begin
            delete from eob_detail ed
            where
                eob_id in (
                    select
                        eob_id
                    from
                        eob_header         eh, eob_claims_staging ec
                    where
                            ec.claims_upload_id = seq_num
                        and eh.eob_id = ed.eob_id
                        and eh.claim_number = ec.claim_number
                        and eh.description = ec.provider_payee_name
                        and ec.claimant_first_name = eh.patient_first_name
                        and ec.claimant_last_name = eh.patient_last_name
                        and ed.provider_tax_id = ec.provider_taxid_num
                );

            insert into eob_detail (
                eob_detail_id,
                eob_id,
                provider_payment_number,
                adjustment_number,
                benefit_line_number,
                received_date,
                processed_date,
                check_date,
                group_name,
                group_number,
                account_number,
                employee_first_name,
                employee_last_name,
                employee_dob,
                employee_gender,
                product_id,
                plan_code,
                dependent_sequence_number,
                claimant_first_name,
                claimant_last_name,
                dependent_dob,
                dependent_gender,
                relationship_code,
                provider_tax_id,
                provider_payee_name,
                provider_first_name,
                provider_last_name,
                provider_type,
                provider_speciality,
                provider_zip_code,
                claim_category,
                benefit_type,
                service_category,
                service_date_from,
                service_date_to,
                cpt_code,
                no_of_services,
                diagnosis_code1,
                diagnosis_code2,
                amount_charged,
                amount_excluded,
                excluded_remark_code1,
                excluded_remark_code2,
                covered_expense,
                amount_withdiscount, -- SAME AS COVERED EXPENSE
                amount_paidbyins, -- SAME AS PAID_AMOUNT
                amount_copay,
                amount_deductible,
                amount_coinsurance,
                amount_notcovered, -- SAME AS AMOUNT_EXCLUDED
                cob_paid,
                paid_amount,
                provider_check_amount,
                provider_check_number,
                employee_check_number,
                employee_check_amount,
                class_code,
                escrow_amount,
                cpt_modifier,
                employee_location,
                provider_city,
                provider_state,
                place_of_service,
                provider_contract_no,
                provider_address,
                provider_address2,
                provider_npi,
                drg_revenue_code,
                excluded_amt_all_others,
                excluded_amt_ppo_discount,
                excluded_amt_rc_exceeded,
                excluded_amt_plan_limitation,
                excluded_amt_dup_submission,
                excluded_amt_oth_ins_coverage,
                excluded_amt_adjust_reverse,
                batch_number,
                patient_responsibility,
                final_patient_amount,
                orig_claim_number,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            )
                select
                    eob_detail_seq.nextval,
                    eh.eob_id,
                    e.provider_payment_number,
                    e.adjustment_number,
                    e.benefit_line_number,
                    trunc(sysdate),--E.RECEIVED_DATE, --Commented and added Sysdate by Karthe on 23/03/2014 for the Seechange ticket 625
                    e.processed_date,
                    e.check_date,
                    e.group_name,
                    e.group_number,
                    e.account_no,
                    e.emp_first_name,
                    e.emp_last_name,
                    e.emp_dob,
                    e.gender,
                    e.product_id,
                    e.plan_code,
                    e.dependent_seq_num,
                    e.claimant_first_name,
                    e.claimant_last_name,
                    e.dependent_dob,
                    e.dependent_gender,
                    e.relationship_code,
                    e.provider_taxid_num,
                    e.provider_payee_name,
                    e.provider_first_name,
                    e.provider_last_name,
                    e.provider_type,
                    e.provider_speciality,
                    e.provider_zipcode,
                    e.claim_category,
                    e.benefit_type,
                    e.service_category,
                    e.service_from_date,
                    e.service_to_date,
                    e.cpt_code,
                    e.num_of_services,
                    e.diagnosis_code1,
                    e.diagnosis_code2,
                    e.amount_charged,
                    e.amount_excluded,
                    e.excluded_remark_code1,
                    e.excluded_remark_code2,
                    e.covered_expense,  -- same as AMOUNT_WITHDISCOUNT
                    e.covered_expense,  -- AMOUNT_WITHDISCOUNT
                    e.paid_amount, -- AMOUNT_PAIDBYINS
                    e.copay,
                    e.deductible,
                    e.coinsurance,
                    e.amount_excluded,
                    e.cob_paid,
                    e.paid_amount,
                    e.provider_check_amount,
                    e.provider_check_number,
                    e.employee_check_number,
                    e.employee_check_amount,
                    e.class_code,
                    e.escrow_amount,
                    e.cpt_modifier,
                    e.employee_location,
                    e.provider_city,
                    e.provider_state,
                    e.place_of_service,
                    e.provider_contract_num,
                    e.provider_address,
                    e.provider_address2,
                    e.provider_npi,
                    e.drg_revenue_code,
                    e.excluded_amt_all_others,
                    e.excluded_amt_ppo_discount,
                    e.excluded_amt_rc_exceeded,
                    e.excluded_amt_plan_limit,
                    e.excluded_amt_duplicate,
                    e.excluded_amt_otherins,
                    e.excluded_amt_adj_rev,
                    seq_num,
                    e.patient_responsibility,
                    e.patient_responsibility,
                    e.claim_number,
                    sysdate,
                    0,
                    sysdate,
                    0
                from
                    eob_claims_staging e,
                    eob_header         eh
                where
                        claims_upload_id = seq_num
                    and e.claim_number = eh.claim_number
                    and eh.description = e.provider_payee_name
                    and e.claimant_first_name = eh.patient_first_name
                    and e.claimant_last_name = eh.patient_last_name
                    and not exists (
                        select
                            1
                        from
                            eob_detail ed
                        where
                            eh.eob_id = ed.eob_id
                    );

            select
                eob_id,
                sum(amount_charged),
                sum(nvl(patient_responsibility, 0) * 1.4)
           --SUM(COVERED_EXPENSE-AMOUNT_COINSURANCE-AMOUNT_COPAY-AMOUNT_DEDUCTIBLE-COB_PAID-PAID_AMOUNT)-- AMOUNT_DUE --from table(pc_eob_utility.get_eob_detail_info(ed.eob_id)))
            bulk collect
            into l_eob_amt
            from
                eob_detail ed
            where
                batch_number = seq_num
            group by
                eob_id;

            forall i in 1..l_eob_amt.count save exceptions
                update eob_header eh
                set
                    service_amount = l_eob_amt(i).service_amt,
                    amount_due = l_eob_amt(i).amount_due
                where
                    eh.eob_id = l_eob_amt(i).eobid;

            forall i in 1..l_eob_header.count save exceptions
                update eob_header e
                set
                    service_date_from = (
                        select
                            service_date_from
                        from
                            eob_detail d
                        where
                                e.eob_id = d.eob_id
                            and batch_number = seq_num
                            and rownum = 1
                    ),
                    service_date_to = (
                        select
                            service_date_to
                        from
                            eob_detail d
                        where
                                e.eob_id = d.eob_id
                            and batch_number = seq_num
                            and rownum = 1
                    )
              /*  USER_ID = (SELECT USER_ID  
                           FROM insure M, PERSON P, online_users u
                           WHERE M.insurance_MEMBER_ID = L_EOB_HEADER(I).member_id 
                           and M.pers_id = p.pers_id 
                           and FORMAT_SSN(U.TAX_ID) = p.ssn
                           AND USER_STATUS = 'A'
                           AND ROWNUM=1)*/
                where
                        e.claim_number = l_eob_header(i).claim_number
                    and e.description = l_eob_header(i).provider_payee_name
                    and e.ssn = l_eob_header(i).ssn;

        exception
            when e_forbulk_error then
                for i in 1..sql%bulk_exceptions.count loop
                    pc_eob_upload.log_eob_error('update claims staging failed',
                                                'SQLCODE:'
                                                || sql%bulk_exceptions(i).error_code);

                    pc_eob_upload.log_eob_error('update claims staging failed',
                                                'SQLERRM:'
                                                || sqlerrm(-sql%bulk_exceptions(i).error_code));

                end loop;
            when others then
                x_error_message := 'Error in Uploading file Stage 6' || sqlerrm;
                x_return_status := 'E';
                pc_eob_upload.log_eob_error('EOB_DETAIL STAGE 6', sqlerrm);
        end;

        commit;
    exception
        when others then
            x_error_message := 'Error in Uploading file Stage 7' || sqlerrm;
            x_return_status := 'E';
            pc_eob_upload.log_eob_error('CLAIMS Stage 7', sqlerrm);
    end process_eob_claims;
-- PROCEDURE TO GENERATE EOB_ELIGIBILITY_FILE
    procedure generate_uha_eligibility_file as

        l_eligibility_tbl eligibility_tbl := eligibility_tbl();
        l_utl_id          utl_file.file_type;
        l_file_name       varchar2(3200);
        l_line            varchar2(32000);
        l_conn            utl_tcp.connection;
    begin
        for x in (
            select
                sc.period_date,
                num_business_days(sc.period_date, sysdate) no_days
            from
                scheduler_calendar sc,
                calendar_master    cm,
                scheduler_master   sm
            where
                cm.entrp_id in (
                    select
                        entrp_id
                    from
                        enterprise
                    where
                            replace(entrp_code, '-') = '990263440'
                        and en_code = 3
                )
                and cm.calendar_id = sm.calendar_id
                and sm.scheduler_id = sc.schedule_id
                and cm.calendar_type = 'CARRIER_CLAIM_CYCLE'
        ) loop
            if round(x.no_days) = 2 then
                select
                    '"'
                    || b.first_name
                    || '"'                              first_name,
                    '"'
                    || b.last_name
                    || '"'                              last_name,
                    to_char(b.birth_date, 'MM/DD/YYYY') birth_date,
                    b.ssn,
                    '"'
                    || a.insurance_member_id
                    || '"'                              insurance_member_id
                bulk collect
                into l_eligibility_tbl
                from
                    insure a,
                    person b
                where
                        a.pers_id = b.pers_id
                    and a.insur_id in (
                        select
                            entrp_id
                        from
                            enterprise
                        where
                                replace(entrp_code, '-') = '990263440'
                            and en_code = 3
                    );

            end if;
        end loop;

        if l_eligibility_tbl.count > 0 then
            l_file_name := 'UHA_ELIGIBILITY_'
                           || to_char(sysdate, 'MMDDYYYY')
                           || '.csv';
            l_utl_id := utl_file.fopen('EOB_OUT_DIR', l_file_name, 'w');
            for i in 1..l_eligibility_tbl.count loop
                l_line := l_eligibility_tbl(i).first_name
                          || ','
                          || l_eligibility_tbl(i).last_name
                          || ','
                          || l_eligibility_tbl(i).birth_date
                          || ','
                          || l_eligibility_tbl(i).ssn
                          || ','
                          || l_eligibility_tbl(i).member_id;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

        end if;

        if l_file_name is not null then
            utl_file.fclose(file => l_utl_id);
            l_conn := ftp.login('216.109.157.41', '21', 'ftpadmin', 'SterlinGFtP2@!2admIn');
            ftp.binary(p_conn => l_conn);
            ftp.put(
                p_conn      => l_conn,
                p_from_dir  => 'EOB_OUT_DIR',
                p_from_file => l_file_name,
                p_to_file   => '/FILES/OUT/UHA/' || l_file_name
            );

            ftp.logout(l_conn);
        end if;

    end generate_uha_eligibility_file;

end pc_eob_upload;
/

