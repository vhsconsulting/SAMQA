-- liquibase formatted sql
-- changeset SAMQA:1754374029940 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_file_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_file_upload.sql:null:c1afce6245a12f86db5c864ace05eec8ab29184a:create

create or replace package body samqa.pc_file_upload as

    function get_creation_date (
        p_entity_id   in number,
        p_entity_name in varchar2
    ) return date is
        l_creation_date date;
    begin
        for x in (
            select
                max(creation_date) creation_date
            from
                file_attachments
            where
                    entity_id = to_char(p_entity_id)
                and entity_name = p_entity_name
        ) loop
            l_creation_date := x.creation_date;
        end loop;

        return l_creation_date;
    end get_creation_date;

    procedure export_online_attachments (
        p_file_name   in varchar2,
        p_mime_type   in varchar2,
        p_document    in blob,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2
    ) as

        l_file_name    varchar2(300);
        l_account_type varchar2(300);
        l_user_id      number;
        src_file       bfile;
        dst_file       blob;
        lgh_file       binary_integer;
    begin
        pc_log.log_error('export_online_attachments', 'fILE NAME ' || l_file_name);
        insert into file_attachments (
            attachment_id,
            document_name,
            document_type,
            attachment,
            entity_name,
            entity_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( file_attachments_seq.nextval,
                   p_file_name,
                   p_mime_type,
                   empty_blob(),
                   p_entity_name,
                   p_entity_id,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id ) return attachment into dst_file;

	--NOTE: p_Source_File_Name is the value of APEX_APPLICATION_FILES.NAME
        for x in (
            select
                a.account_type,
                b.created_by user_id
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = b.acc_id
                and a.account_status = 1
                and b.ben_plan_id = p_entity_id
                and a.account_type in ( 'COBRA', 'ERISA_WRAP', 'FORM_5500', 'POP' )
        ) loop
            pc_notifications.notify_plan_document_upload(p_file_name, x.user_id, p_entity_name, p_entity_id);
        end loop;

        dbms_lob.open(src_file, dbms_lob.lob_readonly);
        dbms_lob.loadfromfile(dst_file,
                              src_file,
                              dbms_lob.getlength(src_file));
        dbms_lob.fileclose(src_file);

	--NOTE: p_Source_File_Name is the value of APEX_APPLICATION_FILES.NAME

	--Once the file has been successfully copied to Attachments, delete it from the source FLOWS table
/*	DELETE FROM wwv_flow_files
	WHERE NAME = p_FILE_NAME;*/
    end export_online_attachments;

    procedure export_attachments (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    ) as
        l_file_name varchar2(300);
    begin
        l_file_name := substr(p_file_name,
                              instr(p_file_name, '/', 1) + 1,
                              length(p_file_name) - instr(p_file_name, '/', 1));

        pc_log.log_error('export_attachments', 'fILE NAME ' || l_file_name);
        insert into file_attachments (
            attachment_id,
            document_name,
            document_type,
            attachment,
            entity_name,
            entity_id,
            document_purpose,
            description,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                file_attachments_seq.nextval,
                l_file_name,
                mime_type,
                blob_content,
                p_entity_name,
                p_entity_id,
                p_doc_purpose,
                p_description,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                wwv_flow_files
            where
                name = p_file_name;

	--NOTE: p_Source_File_Name is the value of APEX_APPLICATION_FILES.NAME
        for x in (
            select
                a.account_type,
                b.created_by user_id
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = b.acc_id
                and a.account_status = 1
                and b.ben_plan_id = p_entity_id
                and a.account_type in ( 'COBRA', 'ERISA_WRAP', 'FORM_5500', 'POP' )
        ) loop
            pc_notifications.notify_plan_document_upload(p_file_name, x.user_id, p_entity_name, p_entity_id);
        end loop;
	--Once the file has been successfully copied to Attachments, delete it from the source FLOWS table
        delete from wwv_flow_files
        where
            name = p_file_name;

    end export_attachments;

    function insert_file_seq (
        p_action in varchar2
    ) return number is
        l_file_id number;
    begin
        insert into external_files (
            file_id,
            file_action,
            creation_date,
            last_update_date
        ) values ( file_seq.nextval,
                   p_action,
                   sysdate,
                   sysdate ) returning file_id into l_file_id;

        return l_file_id;
    end;

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2 is
        x_file_name varchar2(320);
    begin
        select
            decode(p_result,
                   'RESULT',
                   replace(file_name, '.mbi', '.res'),
                   'EXPORT',
                   replace(file_name, '.mbi', '.exp'))
        into x_file_name
        from
            external_files
        where
                file_id = (
                    select
                        max(file_id)
                    from
                        external_files
                    where
                        file_action = p_action
                )
            and trunc(creation_date) >= trunc(sysdate) - 1
            and nvl(result_flag, 'N') = 'N';

        return x_file_name;
    exception
        when others then
            return null;
    end;

    function get_file_seq (
        p_action in varchar2
    ) return varchar2 is
        x_file_name varchar2(320);
    begin
        select
            file_name || '.out'
        into x_file_name
        from
            external_files
        where
                file_id = (
                    select
                        max(file_id)
                    from
                        external_files
                    where
                        file_action = p_action
                )
 --     AND   trunc(creation_date) >=  trunc(sysdate)-1
            and nvl(result_flag, 'N') = 'N';

        return x_file_name;
    exception
        when others then
            return null;
    end;

    procedure insert_sql_file (
        p_file_name   in varchar2,
        p_sql         in varchar2,
        p_upload_file in varchar2,
        p_subject     in varchar2
    ) as

        f_lob         bfile;
        b_lob         blob;
        l_utl_id      utl_file.file_type;
        l_file_name   varchar2(3200);
        l_line        varchar2(32000);
        l_line_tbl    varchar2_4000_tbl;
        l_dest_blob   blob;
        l_src_offset  number := 1;
        l_dest_offset number := 1;
        l_src_osin    number;
        l_dst_osin    number;
    begin
        if p_file_name is not null then
            l_utl_id := utl_file.fopen('ENROLL_DIR', p_file_name, 'w');
            utl_file.put_line(
                file   => l_utl_id,
                buffer => p_sql
            );
            utl_file.fclose(file => l_utl_id);
            f_lob := bfilename('ENROLL_DIR', p_file_name);
            delete from files
            where
                name = p_file_name;

            insert into files (
                file_id,
                name,
                content_type,
                blob_content,
                last_updated,
                description
            ) values ( file_seq.nextval,
                       p_file_name,
                       'SQL',
                       empty_blob(),
                       sysdate,
                       p_subject ) return blob_content into b_lob;

            dbms_output.put_line('Loaded XML File using DBMS_LOB.LoadFromFile: (ID=1001).');
            dbms_lob.open(f_lob, dbms_lob.lob_readonly);
            dbms_lob.loadfromfile(b_lob,
                                  f_lob,
                                  dbms_lob.getlength(f_lob));
            dbms_lob.fileclose(f_lob);
        end if;
    exception
        when others then
            dbms_output.put_line(sqlerrm
                                 || '...'
                                 || dbms_utility.format_error_backtrace);
    end;

    procedure export_deposit_report (
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
    begin
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        l_create_ddl := 'CREATE TABLE  DEPOSIT_RECONCILE_EXTERNAL '
                        || '(FIRST_NAME     VARCHAR2(2000) '
                        || ',LAST_NAME      VARCHAR2(2000) '
                        || ',ACC_NUM        VARCHAR2(30) '
                        || ',CHECK_NUMBER   VARCHAR2(255) '
                        || ',CHECK_AMOUNT   NUMBER '
                        || ',TRANS_DATE     VARCHAR2(30) '
                        || ',NEW_APP_FLAG   VARCHAR2(1)  '
                        || ',NEW_APP_AMOUNT NUMBER      '
                        || ',POSTED_FLAG    VARCHAR2(30) '
                        || ',STATUS         VARCHAR2(30))'
                        || '  ORGANIZATION EXTERNAL '
                        || '  ( TYPE ORACLE_LOADER DEFAULT DIRECTORY DEBIT_DIR '
                        || '  ACCESS PARAMETERS ('
                        || '  records delimited by newline skip 1'
                        || '  badfile ''deposit_reconcile.bad'' '
                        || '  logfile ''deposit_reconcile.log'' '
                        || '  fields terminated by '','' '
                        || '  optionally enclosed by ''"'' '
                        || '  LRTRIM '
                        || '  MISSING FIELD VALUES ARE NULL ) '
                        || '  LOCATION ('''
                        || lv_dest_file
                        || ''')'
                        || '  ) REJECT LIMIT 1 ';


	      /* Get the contents of BLOB from wwv_flow_files */
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        l_file := utl_file.fopen('DEBIT_DIR', lv_dest_file, 'w', 32767);
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

        begin
            execute immediate 'DROP TABLE DEPOSIT_RECONCILE_EXTERNAL ';
        exception
            when others then
                raise;
        end;
        execute immediate l_create_ddl;
        insert into deposit_register (
            deposit_register_id,
            first_name,
            last_name,
            acc_num,
            check_number,
            check_amount,
            trans_date
	     --  ,STATUS
	    --   ,POSTED_FLAG
            ,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                deposit_register_seq.nextval,
                first_name,
                last_name,
                acc_num,
                check_number,
                check_amount,
                trans_date
		 --  ,  DECODE(STATUS,NULL,'NEW','EXISTING')
		  -- ,  DECODE(POSTED_FLAG,NULL,NULL,'Y')
                ,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                deposit_reconcile_external a
            where
                first_name is not null
                and acc_num is not null;

        update (
            select
                acc_id,
                (
                    select
                        acc_id
                    from
                        account
                    where
                        acc_num = upper(a.acc_num)
                ) new_acc_id
            from
                deposit_register a
            where
                status = 'EXISTING'
        )
        set
            acc_id = new_acc_id;

        update (
            select
                entrp_id,
                (
                    select
                        entrp_id
                    from
                        account
                    where
                        acc_num = upper(a.acc_num)
                ) new_entrp_id
            from
                deposit_register a
            where
                status = 'EXISTING'
        )
        set
            entrp_id = new_entrp_id;

        insert into income (
            change_num,
            acc_id,
            fee_date,
            fee_code,
            amount,
            amount_add,
            contributor,
            contributor_amount,
            pay_code,
            cc_number,
            note
        )
            select
                change_seq.nextval,
                acc_id,
                to_date(trans_date, 'MM/DD/YYYY'),
                4,
                0,
                check_amount,
                null,
                null,
                1,
                check_number,
                'generate ' || to_char(sysdate, 'MM/DD/YYYY')
            from
                deposit_reconcile_external a,
                account                    b
            where
                    a.acc_num = b.acc_num
                and b.entrp_id is null;
	     --  AND   POSTED_FLAG IS NULL;

        commit;
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
    end export_deposit_report;

    procedure export_online_disbursement (
        pv_file_name in varchar2,
        p_user_id    in number
    ) as

        l_file         utl_file.file_type;
        l_buffer       raw(32767);
        l_amount       binary_integer := 32767;
        l_pos          integer := 1;
        l_blob         blob;
        l_blob_len     integer;
        exc_no_file exception;
        l_create_ddl   varchar2(32000);
        lv_dest_file   varchar2(300);
        l_batch_number varchar2(30);
    begin
        l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        l_create_ddl := 'CREATE TABLE  ONLINE_DISB_EXTERNAL '
                        || '(FIRST_NAME     VARCHAR2(2000) '
                        || ',LAST_NAME      VARCHAR2(2000) '
                        || ',ACC_NUM        VARCHAR2(30) '
                        || ',CLAIM_TYPE     VARCHAR2(255) '
                        || ',AMOUNT         NUMBER )'
                        || '  ORGANIZATION EXTERNAL '
                        || '  ( TYPE ORACLE_LOADER DEFAULT DIRECTORY CLAIM_DIR '
                        || '  ACCESS PARAMETERS ('
                        || '  records delimited by newline skip 1'
                        || '  badfile ''online_disb.bad'' '
                        || '  logfile ''online_disb.log'' '
                        || '  fields terminated by '','' '
                        || '  optionally enclosed by ''"'' '
                        || '  LRTRIM '
                        || '  MISSING FIELD VALUES ARE NULL ) '
                        || '  LOCATION ('''
                        || lv_dest_file
                        || ''')'
                        || '  ) REJECT LIMIT 5 ';


	      /* Get the contents of BLOB from wwv_flow_files */
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        l_file := utl_file.fopen('CLAIM_DIR', lv_dest_file, 'w', 32767);
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

        begin
            execute immediate 'DROP TABLE ONLINE_DISB_EXTERNAL ';
        exception
            when others then
                raise;
        end;
        execute immediate l_create_ddl;
        insert into payment_register (
            payment_register_id,
            batch_number,
            acc_num,
            acc_id,
            pers_id,
            provider_name,
            claim_code,
            claim_id,
            trans_date,
            gl_account,
            cash_account,
            claim_amount,
            claim_type,
            peachtree_interfaced,
            note
        )
            select
                payment_register_seq.nextval,
                l_batch_number,
                a.acc_num,
                a.acc_id,
                b.pers_id,
                'eDisbursement',
                upper(substr(b.last_name, 1, 4))
                || to_char(sysdate, 'YYYYMMDDHHMISS'),
                doc_seq.nextval,
                sysdate,
                (
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                            account_type = 'GL_ACCOUNT'
                        and status = 'A'
                ),
                nvl((
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                        substr(account_type, 1, 3) like substr(a.acc_num, 1, 3)
                                                        || '%'
                        and status = 'A'
                ),
                    (
                    select
                        account_num
                    from
                        payment_acc_info
                    where
                            substr(account_type, 1, 3) = 'SHA'
                        and status = 'A'
                )),
                c.amount,
                'ONLINE',
                'Y',
                'Online Disbursement'
            from
                account              a,
                person               b,
                online_disb_external c
            where
                    a.acc_num = c.acc_num
                and a.pers_id = b.pers_id;

        insert into claimn (
            claim_id,
            pers_id,
            pers_patient,
            claim_code,
            prov_name,
            claim_date_start,
            claim_date_end,
            service_status,
            claim_amount,
            claim_paid,
            claim_pending,
            note
        )
            select
                claim_id,
                pers_id,
                pers_id,
                claim_code,
                provider_name,
                sysdate,
                trans_date,
                3,
                claim_amount,
                claim_amount,
                0,
                'Disbursement Created for ' || to_char(sysdate, 'YYYYMMDD')
            from
                payment_register a
            where
                    a.batch_number = l_batch_number
                and not exists (
                    select
                        *
                    from
                        claimn
                    where
                        claim_id = a.claim_id
                );

        insert into payment (
            change_num,
            claimn_id,
            pay_date,
            amount,
            reason_code,
            pay_num,
            note,
            acc_id
        )
            select
                change_seq.nextval,
                claim_id,
                trans_date,
                claim_amount,
                19,
                to_char(sysdate, 'YYYYMMDD'),
                'Generate Disbursement ' || to_char(sysdate, 'YYYYMMDD'),
                acc_id
            from
                payment_register a
            where
                    a.batch_number = l_batch_number
                and not exists (
                    select
                        *
                    from
                        payment
                    where
                        claimn_id = a.claim_id
                );

        commit;
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
    end export_online_disbursement;

    procedure export_ach_format_file (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_create_ddl   varchar2(32000);
       -- pv_file_name VARCHAR2(1000) := 'HSA_Bill_Format.csv';
        l_file         utl_file.file_type;
        l_buffer       raw(32767);
        l_amount       binary_integer := 32767;
        l_pos          integer := 1;
        l_blob         blob;
        l_blob_len     integer;
        exc_no_file exception;
        lv_dest_file   varchar2(300);
        lv_create exception;
        l_row_count    number := -1;
        l_batch_number number;
    begin
        x_return_status := 'S';
        dbms_output.put_line('In export Bill format Proc');
        x_batch_num := batch_num_seq.nextval;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
       --lv_dest_file := pv_file_name;
        dbms_output.put_line(lv_dest_file);
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        dbms_output.put_line('Afetr Select');
        l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
        l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
          -- Open / Creates the destination file.

        dbms_output.put_line('Length' || l_blob_len);

        -- Read chunks of the BLOB and write them to the file
          -- until complete.
        while l_pos < l_blob_len loop
            dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
            utl_file.put_raw(l_file, l_buffer, true);
            l_pos := l_pos + l_amount;
        end loop;

          -- Close the file.
        utl_file.fclose(l_file);
        dbms_output.put_line('After BLOB');

          -- Delete file from wwv_flow_files
 	 --      DELETE FROM wwv_flow_files
         --  WHERE NAME = pv_file_name;

        dbms_output.put_line('After Delete');
        if file_length(lv_dest_file, 'ENROLL_DIR') > 0 then
            begin
                dbms_output.put_line('In Loop');
                execute immediate '
                          ALTER TABLE BILL_FORMAT_EXTERNAL
                           location (ENROLL_DIR:'''
                                  || lv_dest_file
                                  || ''')';
                dbms_output.put_line('After alter');
            exception
                when others then
                    raise_application_error('-20001', 'Error in Changing location of QB file' || sqlerrm);
                    x_return_status := 'E';
                    x_error_message := 'Error in Changing location of QB file' || sqlerrm;
                    raise lv_create;
            end;
        end if;

        dbms_output.put_line('Before Insert');
        x_error_message := 'Before Insert';
        insert into bill_format_staging (
            tpa_id,
            group_name,
            group_acc_num,
            first_name,
            last_name,
            ssn,
            contrb_type,
            er_contrb,
            ee_contrb,
            er_fee_contrb,
            ee_fee_contrb,
            total_contrb_amt,
            bank_name,
            bank_routing_num,
            bank_acct_num,
            account_type,
            batch_number,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                tpa_id,
                group_name,
                group_id,
                first_name,
                last_name,
                ssn,
                contrb_type,
                er_contrb,
                ee_contrb,
                er_fee_contrb,
                ee_fee_contrb,
                total_contrb_amt,
                bank_name,
                bank_routing_num,
                bank_acct_num,
                account_type,
                x_batch_num,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                bill_format_external;

        dbms_output.put_line('after Insert');
        x_error_message := 'After Insert';
    exception
        when lv_create then
            rollback;
            raise_application_error('-20001', 'ACH Template file seems to be corrupted, Use correct template');
            x_return_status := 'E';
            x_error_message := 'ACH Template file seems to be corrupted, Use correct template';
            dbms_output.put_line('Here');
        when others then
            raise_application_error('-20001', 'Error in export QB file' || sqlerrm);
            x_return_status := 'E';
            x_error_message := 'Error in export ACH file' || sqlerrm;
            dbms_output.put_line('Here');
            rollback;
    end export_ach_format_file;

    procedure insert_ach_bank_det (
        p_batch_num     in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_acc_id              varchar2(100);
        l_bank_status         varchar2(10);
        l_entrp_id            varchar2(100);
        l_acc_num             varchar2(100);
        l_bank_id             varchar2(100);
        l_amount              number(10);
        l_grp_entrp_id        number(10);
        l_ee_entrp_id         number(10);
        l_fee_amount          number(10);
        x_transaction_id      number(10);
        l_ee_acc_id           number(10);
        l_ee_acc_status       varchar2(10);
        l_ee_acc_num          varchar2(100);
        l_ee_bank_id          varchar2(10);
        l_ee_bank_status      varchar2(10);
        l_acc_id_det          pc_ach_transfer_details.number_tbl;
        l_acc_id_num          pc_ach_transfer_details.number_tbl;
        l_acc_id_status       pc_ach_transfer_details.number_tbl;
        l_ee_contrb           pc_ach_transfer_details.number_tbl;
        l_er_contrb           pc_ach_transfer_details.number_tbl;
        l_er_fee_contrb       pc_ach_transfer_details.number_tbl;
        l_ee_fee_contrb       pc_ach_transfer_details.number_tbl;
        x_xfer_detail_id      pc_ach_transfer_details.number_tbl;
        i                     number := 1;
        employer_contrib_flag varchar2(1) := 'N';
        cursor c1_fetch_bill_data is
        select
            group_acc_num,
            pc_entrp.get_acc_id_from_ein(group_acc_num, account_type) acc_id,
            contrb_type,
            sum(nvl(er_contrb, 0) + nvl(ee_contrb, 0))                contribution_amount,
            sum(nvl(ee_fee_contrb, 0) + nvl(er_fee_contrb, 0))        fee_amount,
            sum(total_contrb_amt),
            bank_name,
            bank_routing_num,
            bank_acct_num,
            account_type
        from
            bill_format_staging
        where
                batch_number = p_batch_num
            and error_column is null
        group by
            group_acc_num,
            contrb_type,
            bank_name,
            bank_routing_num,
            bank_acct_num,
            account_type;

        cursor c1_all_fetch_bill_data is
        select
            group_acc_num,
            pc_entrp.get_acc_id_from_ein(group_acc_num, account_type) acc_id,
            contrb_type,
            sum(nvl(er_contrb, 0) + nvl(ee_contrb, 0))                contribution_amount,
            sum(nvl(ee_fee_contrb, 0) + nvl(er_fee_contrb, 0))        fee_amount,
            sum(total_contrb_amt),
            bank_name,
            bank_routing_num,
            bank_acct_num,
            account_type
        from
            bill_format_staging
        where
            batch_number = p_batch_num
        group by
            group_acc_num,
            contrb_type,
            bank_name,
            bank_routing_num,
            bank_acct_num,
            account_type;

        cursor c2_all_data (
            p_group_id varchar2
        ) is
        select
            *
        from
            bill_format_staging
        where
                group_acc_num = p_group_id
            and batch_number = p_batch_num;

        cursor c2_data (
            p_group_id varchar2
        ) is
        select
            *
        from
            bill_format_staging
        where
                group_acc_num = p_group_id
            and error_column is null
            and batch_number = p_batch_num;

        cursor c3_all_employee_data is
        select
            *
        from
            bill_format_staging
        where
            batch_number = p_batch_num;

        cursor c3_employee_data is
        select
            *
        from
            bill_format_staging
        where
            error_column is null
            and batch_number = p_batch_num;

    begin

    /* Looping to mark the errorred records */

        for c1 in c1_all_fetch_bill_data loop
            if c1.group_acc_num is not null then    --For Employer Contribution
                x_return_status := 'S';
                x_error_message := null;
                employer_contrib_flag := 'Y';

 	/* Loop through all the records to error our the unwanted one */
                begin
                    if
                        c1.bank_acct_num is null
                        and c1.bank_routing_num is null
                        and c1.bank_name is null
                    then
                        select
                            bank_acct_id,
                            status
                        into
                            l_bank_id,
                            l_bank_status
                        from
                            user_bank_acct
                        where
                            bank_account_usage = 'BANK_DRAFT';
	    	       --AND status = 'A';

                        if l_bank_status = 'I' then
                            l_bank_id := null;
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'This Bank is Inactive'
                            where
                                group_acc_num = c1.group_acc_num;

                        end if;

                    else
                        select
                            bank_acct_id,
                            status
                        into
                            l_bank_id,
                            l_bank_status
                        from
                            user_bank_acct
                        where
                                acc_id = c1.acc_id
                            and bank_acct_num = c1.bank_acct_num
                            and bank_routing_num = c1.bank_routing_num;
	       		--AND status = 'A';

                        if l_bank_status = 'I' then
                            l_bank_id := null;
                            x_return_status := 'E';
                            x_error_message := 'This Bank is Inactive';
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'This Bank is Inactive'
                            where
                                group_acc_num = c1.group_acc_num;

                        end if;

                    end if;

                    dbms_output.put_line('Bank ID' || l_bank_id);
                    dbms_output.put_line('Acct' || c1.bank_acct_num);
                    dbms_output.put_line('Routing' || c1.bank_routing_num);
                exception
                    when no_data_found then
                        l_bank_id := null;
	    	     --x_return_status := 'E';
                        dbms_output.put_line('Unable to get the Bank ID for' || c1.bank_acct_num);
	             -- x_error_message := 'Unable to get the Bank ID'||sqlerrm;
                        update bill_format_staging
                        set
                            error_column = 'Y',
                            error_message = 'Bank ID for this Group not Found'
                        where
                            group_acc_num = c1.group_acc_num;

                    when others then
                        l_bank_id := null;
	    	     --x_return_status := 'E' ;
                        dbms_output.put_line('Unable to get the Bank ID' || c1.bank_acct_num);
	 	     --x_error_message := 'Unable to get the Bank ID'||sqlerrm;
                        update bill_format_staging
                        set
                            error_column = 'Y',
                            error_message = 'Bank ID for this Group not Found'
                        where
                            group_acc_num = c1.group_acc_num;

                end;

                for c2 in c2_all_data(c1.group_acc_num) loop
                    begin
                        select
                            b.acc_id,
                            a.acc_numc,
                            account_status  --- To Insert into Details Table
                        into
                                l_acc_id_det
                            (i),
                            l_acc_id_num(i),
                            l_acc_id_status(i)
                        from
                            person  a,
                            account b
                        where
                                a.ssn = c2.ssn
                            and a.pers_id = b.pers_id
                            and b.account_type = c2.account_type;
	     	--AND    account_status <> 4 ;

                        dbms_output.put_line('Detail Acct' || l_acc_id_det(i));
                        if l_acc_id_status(i) = 4 then
                            l_acc_id_det(i) := null;
                            l_acc_id_num(i) := null;
	     	    --x_return_status := 'E' ;
	     	    --x_error_message := 'This Employee Account is closed';
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'This Employee Account is closed'
                            where
                                ssn = c2.ssn;

                        end if;

                    exception
                        when no_data_found then
	        --l_acc_id_det(i) := NULL;

                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'Unable to get the Acc ID for employee account'
                            where
                                ssn = c2.ssn;

                            dbms_output.put_line('Unable to get the Acc ID for employee account for SSN' || c2.ssn);
                    end;

                    i := i + 1;
                end loop; --End of C2 loop

	    --Mark all teh records which don't have the same entrp ID

                for c2 in c2_all_data(c1.group_acc_num) loop
                    begin
                        select
                            pc_entrp.get_entrp_id_from_ein(c1.group_acc_num)
                        into l_grp_entrp_id
                        from
                            dual;

                        select
                            entrp_id
                        into l_ee_entrp_id
                        from
                            person
                        where
                            ssn = c2.ssn;

                        if l_grp_entrp_id != l_ee_entrp_id then
	          --l_acc_id_det(i) := NULL;
	     	  --l_acc_id_num(i) := NULL;
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'This Employee does not belong to this Employer'
                            where
                                    ssn = c2.ssn
                                and error_column is null;

                        end if;

                    exception
                        when no_data_found then
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'This employee does not belong to this employer'
                            where
                                    ssn = c2.ssn
                                and error_column is null;

                        when others then
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'This employee does not belong to this employer'
                            where
                                    ssn = c2.ssn
                                and error_column is null;

                    end;
                end loop;

                dbms_output.put_line('Value of i' || i);
                i := 1;
                commit;

 --Initialise all the arrays to NULL
                dbms_output.put_line('Initialise arrays for cnt' || l_acc_id_det.count);
                for j in 1..l_acc_id_det.count loop
                    l_acc_id_det(j) := null;
                end loop;

            end if; --End IF for Group ID
        end loop; -- End of C1 loop

/* End of pgm to mark error records */

 /* Insert only the Good records */
        for c1 in c1_fetch_bill_data loop
            if c1.group_acc_num is not null then    --For Employer Contribution
                dbms_output.put_line('Acc_id' || c1.acc_id);
                dbms_output.put_line('group_id' || c1.group_acc_num);
                employer_contrib_flag := 'Y';
                x_return_status := 'S';
                x_error_message := null;
                begin
                    if
                        c1.bank_acct_num is null
                        and c1.bank_routing_num is null
                        and c1.bank_name is null
                    then
                        select
                            bank_acct_id
                        into l_bank_id
                        from
                            user_bank_acct
                        where
                                bank_account_usage = 'BANK_DRAFT'
                            and status = 'A';

                    else
                        select
                            bank_acct_id
                        into l_bank_id
                        from
                            user_bank_acct
                        where
                                acc_id = c1.acc_id
                            and bank_acct_num = c1.bank_acct_num
                            and bank_routing_num = c1.bank_routing_num
                            and status = 'A';

                    end if;
                exception
                    when no_data_found then
                        l_bank_id := null;
                        x_return_status := 'E';
                        dbms_output.put_line('Unable to get the Bank ID' || sqlerrm);
                        x_error_message := 'Unable to get the Bank ID' || sqlerrm;
                    when others then
                        l_bank_id := null;
                        x_return_status := 'E';
                        dbms_output.put_line('Unable to get the Bank ID' || sqlerrm);
                        x_error_message := 'Unable to get the Bank ID' || sqlerrm;
                end;

                dbms_output.put_line('Bank_id' || l_bank_id);
                if l_bank_id is not null then
                    begin
                        x_return_status := 'S';
                        pc_ach_transfer.ins_ach_transfer(c1.acc_id, l_bank_id, 'C', c1.contribution_amount, c1.fee_amount,
                                                         sysdate + 1, 4, 2, p_user_id, -- User ID
                                                          5,
                                                         x_transaction_id, x_return_status, x_error_message);

                        update bill_format_staging
                        set
                            grp_acc_id = c1.acc_id,
                            transaction_id = x_transaction_id
                        where
                                group_acc_num = c1.group_acc_num
                            and batch_number = p_batch_num;

                    exception
                        when others then
                            x_return_status := 'E';
                            dbms_output.put_line('Error in call to INS_ACH_TRANSFER' || sqlerrm);
                            x_error_message := 'Error in call to INS_ACH_TRANSFER' || sqlerrm;
                    end;
                end if; -- Do not Insert the Error Records

                dbms_output.put_line('After 1st Insert');
                dbms_output.put_line('Group ID' || c1.group_acc_num);
                dbms_output.put_line('Transaction ID' || x_transaction_id);

     --Call to PCH_ACH_TRANSFER_DETAILS
                i := 1;-- Need to initialise again

                for c2 in c2_data(c1.group_acc_num) loop
                    begin
                        select
                            b.acc_id,
                            a.acc_numc  --- To Insert into Details Table
                        into
                                l_acc_id_det
                            (i),
                            l_acc_id_num(i)
                        from
                            person  a,
                            account b
                        where
                                a.ssn = c2.ssn
                            and a.pers_id = b.pers_id
                            and b.account_type = c2.account_type
                            and account_status <> 4;

                        dbms_output.put_line('Detail Acct' || l_acc_id_det(i));
                        dbms_output.put_line('SSN' || c2.ssn);
                        update bill_format_staging
                        set
                            emp_acc_id = l_acc_id_det(i),
                            emp_acc_num = l_acc_id_num(i)
                        where
                                ssn = c2.ssn
                            and batch_number = p_batch_num;

                    exception
                        when no_data_found then
                            l_acc_id_det(i) := null;
                            l_acc_id_num(i) := null;
                        when others then
                            l_acc_id_det(i) := null;
                            l_acc_id_num(i) := null;
                    end;

                    l_ee_contrb(i) := c2.ee_contrb;
                    l_er_contrb(i) := c2.er_contrb;
                    l_er_fee_contrb(i) := c2.er_fee_contrb;
                    l_ee_fee_contrb(i) := c2.ee_fee_contrb;
                    i := i + 1;
                end loop; --End of C2 loop

                dbms_output.put_line('Count' || i);
                begin
                    x_return_status := 'S';
                    dbms_output.put_line('Before Insert for transaction id' || x_transaction_id);
                    if x_transaction_id is not null then
                        pc_ach_transfer_details.mass_ins_ach_transfer_details(x_transaction_id, c1.acc_id  -- Group Acc ID
                        , l_acc_id_det, l_ee_contrb   --??
                        , l_er_contrb  --??
                        ,
                                                                              l_er_fee_contrb --??
                                                                              , l_ee_fee_contrb  --??
                                                                              , p_user_id -- User ID
                                                                              , x_xfer_detail_id, x_return_status,
                                                                              x_error_message);
                    end if; -- Do not insert error records that were not inserted in ACH_TRANSFER table

                    dbms_output.put_line('After Insert');

    	--Initialise all the arrays to NULL befor the next Insert

                    for j in 1..l_acc_id_det.count loop
                        l_acc_id_det(j) := null;
                        l_ee_contrb(j) := null;
                        l_er_contrb(j) := null;
                        l_er_fee_contrb(j) := null;
                        l_ee_fee_contrb(j) := null;
                        l_acc_id_num(j) := null;
                    end loop;

                exception
                    when others then
                        x_return_status := 'E';
                        dbms_output.put_line('Error in call to INS_ACH_TRANSFER_DETAILS' || sqlerrm);
                        x_error_message := 'Error in call to INS_ACH_TRANSFER_DETAILS' || sqlerrm;
                end;

                dbms_output.put_line('After success');
            end if; --End of Group ID loop
        end loop;  -- End of c1 loop

        if ( employer_contrib_flag = 'N' ) then -- Employee Deposit

/* Mark the incorrect records */

            for c3 in c3_all_employee_data loop
                x_return_status := 'S';
                x_error_message := null;
                begin
                    select
                        b.acc_id,
                        account_status  --- To Insert into Details Table
                    into
                        l_ee_acc_id,
                        l_ee_acc_status
                    from
                        person  a,
                        account b
                    where
                            a.ssn = c3.ssn
                        and a.pers_id = b.pers_id
                        and b.account_type = c3.account_type;
      	--AND    account_status <> 4 ;          --Eliminate Closed Accounts

                    dbms_output.put_line('Detail Acct' || l_ee_acc_id);
                    if l_ee_acc_status = 4 then
                        l_ee_acc_id := null;
      	  -- x_return_status := 'E';
          --  x_error_message := 'This Employee Account is Closed';
                        update bill_format_staging
                        set
                            error_column = 'Y',
                            error_message = 'This Employee Account is Closed'
                        where
                            ssn = c3.ssn;

                    end if;

                exception
                    when no_data_found then
                        l_ee_acc_id := null;
                        x_return_status := 'E';
                        x_error_message := 'Unable to get the Acc ID for employee account';
                        update bill_format_staging
                        set
                            error_column = 'Y',
                            error_message = 'Unable to get the Acc ID for employee account'
                        where
                            ssn = c3.ssn;

                    when others then
                        l_ee_acc_id := null;
                        x_return_status := 'E';
                        x_error_message := 'Unable to get the Acc ID for employee account';
                        update bill_format_staging
                        set
                            error_column = 'Y',
                            error_message = 'Unable to get the Acc ID for employee account'
                        where
                            ssn = c3.ssn;

                end;

                if l_ee_acc_id is not null then   --If Acc Id is already null then no need to check further
                    begin
                        select
                            bank_acct_id,
                            status
                        into
                            l_ee_bank_id,
                            l_ee_bank_status
                        from
                            user_bank_acct
                        where
                                acc_id = l_ee_acc_id
                            and bank_acct_num = c3.bank_acct_num
                            and bank_routing_num = c3.bank_routing_num;
         --AND status = 'A';

                        if l_ee_bank_status = 'I' then  -- Account closed
                            l_ee_bank_id := null;
          -- x_return_status := 'E' ;
          -- x_error_message := 'This Bank Account is Closed for the employee';
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'This Bank Account is Closed for the employee'
                            where
                                ssn = c3.ssn;

                        end if;

                    exception
                        when no_data_found then
                            l_ee_bank_id := null;
               --x_return_status := 'E' ;
                            dbms_output.put_line('Unable to get the Bank ID for employee acct' || c3.ssn);
  	     --x_error_message := 'Unable to get the Bank ID for employee account'||sqlerrm;
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'Unable to get the Bank ID for employee account'
                            where
                                ssn = c3.ssn;

                        when others then
                            l_ee_bank_id := null;
                            x_return_status := 'E';
                            dbms_output.put_line('Unable to get the Bank ID for employee acct' || c3.ssn);
                            x_error_message := 'Unable to get the Bank ID for employee account' || sqlerrm;
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'Unable to get the Bank ID for employee account'
                            where
                                ssn = c3.ssn;

                    end;
                end if; --If Bank Id is already null then no need to check further
            end loop; --End of C3 loop

/*All wrong records marked */

            for c3 in c3_employee_data loop
                dbms_output.put_line('Employee Deposit' || c3.ssn);
                begin
                    select
                        b.acc_id,
                        a.acc_numc --- To Insert into Details Table
                    into
                        l_ee_acc_id,
                        l_ee_acc_num
                    from
                        person  a,
                        account b
                    where
                            a.ssn = c3.ssn
                        and a.pers_id = b.pers_id
                        and b.account_type = c3.account_type
                        and account_status <> 4;          --Eliminate Closed Accounts

                    dbms_output.put_line('Detail Acct' || l_ee_acc_id);
                exception
                    when no_data_found then
                        l_ee_acc_id := null;
                        l_ee_acc_num := null;
                    when others then
                        l_ee_acc_id := null;
                        l_ee_acc_num := null;
                end;

                begin
                    select
                        bank_acct_id
                    into l_ee_bank_id
                    from
                        user_bank_acct
                    where
                            acc_id = l_ee_acc_id
                        and bank_acct_num = c3.bank_acct_num
                        and bank_routing_num = c3.bank_routing_num
                        and status = 'A';

                exception
                    when no_data_found then
                        l_ee_bank_id := null;
                    when others then
                        l_ee_bank_id := null;
                end;

                if l_ee_bank_id is not null then
                    begin
                        x_return_status := 'S';
                        pc_ach_transfer.ins_ach_transfer(l_ee_acc_id,
                                                         l_ee_bank_id,
                                                         'C',
                                                         nvl(c3.er_contrb, 0) + nvl(c3.ee_contrb, 0),
                                                         nvl(c3.ee_fee_contrb, 0) + nvl(c3.ee_fee_contrb, 0),
                                                         sysdate + 1,
                                                         4,
                                                         2,
                                                         p_user_id,  -- User ID
                                                         5,
                                                         x_transaction_id,
                                                         x_return_status,
                                                         x_error_message);

                        update bill_format_staging
                        set
                            grp_acc_id = l_ee_acc_id,
                            emp_acc_num = l_ee_acc_num,
                            transaction_id = x_transaction_id
                        where
                                batch_number = p_batch_num
                            and ssn = c3.ssn;

                        dbms_output.put_line('Transaction ID' || x_transaction_id);
                    exception
                        when others then
                            x_return_status := 'E';
                            dbms_output.put_line('Error in call to INS_ACH_TRANSFER for Employee Deposit' || sqlerrm);
                            x_error_message := 'Error in call to INS_ACH_TRANSFER for Employee deposit' || sqlerrm;
                    end;
                end if; -- Do not Insert errorneous records

            end loop; --End of C3 loop
        end if; --End of Employee Deposit
    end insert_ach_bank_det;

    procedure process_ach_format_execute (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) as
        l_batch_num number;
    begin
        export_ach_format_file(pv_file_name, p_user_id, x_batch_num, x_error_message, x_return_status);
        l_batch_num := x_batch_num;
        insert_ach_bank_det(l_batch_num, p_user_id, x_error_message, x_return_status);
        dbms_output.put_line('Batch Num' || x_batch_num);
    end process_ach_format_execute;

    procedure export_list_bill (
        pv_file_name    in varchar2,
        p_user_id       in number,
        p_list_bill     in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_create_ddl     varchar2(32000);
        -- pv_file_name VARCHAR2(1000) := 'HSA_Bill_Format.csv';
        l_file           utl_file.file_type;
        l_buffer         raw(32767);
        l_amount         binary_integer := 32767;
        l_pos            integer := 1;
        l_blob           blob;
        l_blob_len       integer;
        exc_no_file exception;
        lv_dest_file     varchar2(300);
        lv_create exception;
        l_row_count      number := -1;
        l_batch_number   number;
        v_plan_type      employer_deposits.plan_type%type;                   -- Added By Swamy Ticket#6320 on 27/08/2018
        v_check_date     employer_deposits.check_date%type;                  -- Added By Swamy Ticket#6320 on 27/08/2018
        v_err_msg        varchar2(300);                                      -- Added By Swamy Ticket#6320 on 27/08/2018
        v_process_status varchar2(1);                                        -- Added By Swamy Ticket#6320 on 27/08/2018
        v_entrp_id       employer_deposits.entrp_id%type;                    -- Added By Swamy Ticket#6320 on 27/08/2018
        v_empr_acc_num   account.acc_num%type;                               -- Added By Swamy Ticket#6320 on 27/08/2018
        v_ben_plan_id    ben_plan_enrollment_setup.ben_plan_id%type;         -- Added By Swamy Ticket#6320 on 27/08/2018
        v_termination    ben_plan_enrollment_setup.effective_end_date%type;  -- Added By Swamy Ticket#6320 on 27/08/2018
        erreur exception;                                          -- Added By Swamy Ticket#6320 on 27/08/2018

    begin
        x_return_status := 'S';
        dbms_output.put_line('In export Bill format Proc');
        x_batch_num := batch_num_seq.nextval;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
        --lv_dest_file := pv_file_name;
        dbms_output.put_line(lv_dest_file);
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        dbms_output.put_line('Afetr Select');
        l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
        l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
           -- Open / Creates the destination file.

        dbms_output.put_line('Length' || l_blob_len);

         -- Read chunks of the BLOB and write them to the file
           -- until complete.
        while l_pos < l_blob_len loop
            dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
            utl_file.put_raw(l_file, l_buffer, true);
            l_pos := l_pos + l_amount;
        end loop;

           -- Close the file.
        utl_file.fclose(l_file);
        dbms_output.put_line('After BLOB');

           -- Delete file from wwv_flow_files
  	 --      DELETE FROM wwv_flow_files
          --  WHERE NAME = pv_file_name;

        dbms_output.put_line('After Delete');
        if file_length(lv_dest_file, 'ENROLL_DIR') > 0 then
            begin
                dbms_output.put_line('In Loop');
                execute immediate '
                           ALTER TABLE LIST_FORMAT_EXTERNAL
                            location (ENROLL_DIR:'''
                                  || lv_dest_file
                                  || ''')';
                dbms_output.put_line('After alter');
            exception
                when others then
                    raise_application_error('-20001', 'Error in Changing location of QB file' || sqlerrm);
                    x_return_status := 'E';
                    x_error_message := 'Error in Changing location of QB file' || sqlerrm;
                    raise lv_create;
            end;
        end if;

        dbms_output.put_line('Before Insert');
        pc_log.log_error('PC_FILE_UPLOAD.EXPORT_LIST_BILL', 'LIST BILL ' || p_list_bill);
        insert into list_bill_upload_staging (
            list_bill_upload_id,
            first_name,
            last_name,
            er_contrb,
            ee_contrb,
            er_fee_contrb,
            ee_fee_contrb,
            reason_code,
            note,
            acct_num,
            list_bill_num,
            batch_number,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                list_bill_upload_staging_seq.nextval,
                first_name,
                last_name,
                nvl(er_contrb, 0),
                nvl(ee_contrb, 0),
                nvl(er_fee_contrb, 0),
                nvl(ee_fee_contrb, 0),
                (
                    select
                        fee_code
                    from
                        fee_names
                    where
                        upper(fee_name) = upper(ltrim(rtrim(reason_code)))
                ),
                note,
                acc_num,
                p_list_bill,
                x_batch_num,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                list_format_external
            where
                nvl(er_contrb, 0) + nvl(ee_contrb, 0) + nvl(er_fee_contrb, 0) + nvl(ee_fee_contrb, 0) <> 0;

        update list_bill_upload_staging
        set
            acct_num =
                case
                    when is_number(acct_num) = 'Y' then
                        format_ssn(acct_num)
                    else
                        acct_num
                end
        where
            batch_number = x_batch_num;

	   -- Commented Below By Swamy Ticket#6320 on 26/08/2018, this functionality is handled below
	   /*
       -- if it contains - that means it is SSN
       FOR X IN ( SELECT C.ACC_NUM, A.ACC_NUM SSN, C.ACCOUNT_STATUS
                   FROM  LIST_FORMAT_EXTERNAL a, PERSON b, ACCOUNT c
                  WHERE  A.ACC_NUM LIKE '%-%'
                  AND    A.ACC_NUM = B.SSN
                  AND    B.PERS_ID = C.PERS_ID)
       LOOP
          UPDATE LIST_BILL_UPLOAD_STAGING
          SET    ACCT_NUM = x.acc_num
          WHERE  ACCT_NUM = X.SSN
          AND    batch_number = X_batch_num;

          IF X.ACCOUNT_STATUS = 4 THEN
            UPDATE LIST_BILL_UPLOAD_STAGING
             SET ERROR_MESSAGE =  'Employee Account is Closed'
               ,PROCESS_STATUS = 'E'
             WHERE  batch_number = X_batch_num
               AND  ACCT_NUM =X.acc_num;
          END IF;
       END LOOP;
       */

	   -- Start Added Below By Swamy Ticket#6320 on 26/08/2018
        for j in (
            select
                e.plan_type,
                e.check_date,
                e.entrp_id,
                a.acc_num
            from
                employer_deposits e,
                account           a
            where
                    e.entrp_id = a.entrp_id
                and e.list_bill = p_list_bill
        ) loop
            v_plan_type := j.plan_type;
            v_check_date := j.check_date;
            v_entrp_id := j.entrp_id;
            v_empr_acc_num := j.acc_num;
        end loop;

        pc_log.log_error('PC_FILE_UPLOAD.EXPORT_LIST_BILL', 'V_Plan_Type '
                                                            || v_plan_type
                                                            || ' V_Check_Date :='
                                                            || v_check_date
                                                            || ' V_Entrp_Id :='
                                                            || v_entrp_id
                                                            || ' V_Empr_Acc_Num :='
                                                            || v_empr_acc_num);

        for x in (
            select
                c.acc_num,
                c.account_status,
                c.acc_id,
                a.list_bill_upload_id,
                c.account_type,
                c.plan_code
            from
                list_bill_upload_staging a,
                person                   b,
                account                  c
            where
                ( ( a.acct_num = b.ssn
                    and b.entrp_id = v_entrp_id )
                  or ( a.acct_num = c.acc_num ) )
                and b.pers_id = c.pers_id
                and a.batch_number = x_batch_num
        ) loop
            begin
	       -- Initialising the variables
                v_err_msg := null;
                v_process_status := null;
                v_ben_plan_id := null;
                pc_log.log_error('PC_FILE_UPLOAD.EXPORT_LIST_BILL', 'X.Acc_Id '
                                                                    || x.acc_id
                                                                    || ' X.Account_Status :='
                                                                    || x.account_status
                                                                    || ' X.List_Bill_Upload_Id :='
                                                                    || x.list_bill_upload_id);
           -- Check If The Employee Belongs To The Listbill Employer.
                if v_entrp_id <> pc_person.get_entrp_id(x.acc_id) then
                    v_err_msg := 'This Employee does not belong to employer := ' || v_empr_acc_num;
                    v_process_status := 'E';
                    raise erreur;
                end if;

           -- Check if the Status of the Account of the employee is closed
                if x.account_status = 4 then
                    v_err_msg := 'Employee Account is Closed';
                    v_process_status := 'E';
                    raise erreur;
                end if;

                if nvl(v_plan_type, x.account_type) not in ( 'HSA', 'LSA' ) then   -- LSA Added by Swamy for Ticket#11144
		      -- Depending On The Check Date Of The List Bill, Get The Termination Date And Ben_Plan_Id Of The Latest Current Year Plan.
                    for m in (
                        select
                            ben_plan_id,
                            effective_end_date
                        from
                            ben_plan_enrollment_setup
                        where
                                acc_id = x.acc_id
                            and plan_type = v_plan_type
                            and plan_start_date <= v_check_date
                            and plan_end_date >= v_check_date
                    ) loop
                        v_termination := m.effective_end_date;
                        v_ben_plan_id := m.ben_plan_id;
                    end loop;

                    pc_log.log_error('PC_FILE_UPLOAD.EXPORT_LIST_BILL', 'V_Termination '
                                                                        || v_termination
                                                                        || ' V_Ben_Plan_Id :='
                                                                        || v_ben_plan_id);
		      -- If the check date is greater than the Termination date, then contribution should be stopped with the below error message.
		      -- Employee is terminated and he should no longer receive the contribution.
                    if v_ben_plan_id is not null then
                        if v_check_date > nvl(v_termination, v_check_date) then
                            v_err_msg := 'Please upload the payroll contribution with the date lesser or equal to the termination date.'
                            ;
                            v_process_status := 'E';
                            raise erreur;
                        end if;
                    else
                        v_err_msg := 'There is no Benefit Plan setup for this employee';
                        v_process_status := 'E';
                        raise erreur;
                    end if;
          /* Elsif Nvl(V_Plan_Type,X.Account_Type) = 'HSA' Then
               If X.Plan_Code = 8 Then
                 V_Err_Msg        := 'Contributions not allowed for Simple-HSA plans';
                 V_Process_Status := 'E';
                 Raise Erreur;
              End If;  */
                end if;

            exception
                when erreur then
                    null;
                when others then
                    v_err_msg := v_err_msg
                                 || sqlerrm
                                 || ( sqlcode );
            end;

            update list_bill_upload_staging
            set
                error_message = v_err_msg,
                process_status = v_process_status,
                acct_num = x.acc_num
            where
                    batch_number = x_batch_num
                and list_bill_upload_id = x.list_bill_upload_id;

        end loop;
	   -- End By Swamy Ticket#6320 on 26/08/2018

        dbms_output.put_line('after Insert');
    exception
        when lv_create then
            rollback;
            raise_application_error('-20001', 'Upload List Template file seems to be corrupted, Use correct template');
            x_return_status := 'E';
            x_error_message := 'Upload List Template file seems to be corrupted, Use correct template';
            pc_log.log_error('PC_FILE_UPLOAD.EXPORT_LIST_BILL', 'Exception lv_create := ' || x_error_message);
            dbms_output.put_line('Here');
        when others then
            raise_application_error('-20001', 'Error in export Upload List file' || sqlerrm);
            x_return_status := 'E';
            x_error_message := 'Error in export Upload Listfile' || sqlerrm;
            pc_log.log_error('PC_FILE_UPLOAD.EXPORT_LIST_BILL', 'Exception Others := ' || x_error_message);
            dbms_output.put_line('Here');
            rollback;
    end export_list_bill;

    procedure insert_bill_details (
        p_batch_num     in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is

        l_acc_num      varchar2(100);
        l_check_number number;
        l_check_amount number;
        l_acc_id       number;
        cursor all_list_data is
        select
            *
        from
            list_bill_upload_staging
        where
                batch_number = p_batch_num
            and process_status = 'S';

    begin
        x_return_status := 'S';
        for x in (
            select
                acc.acc_id,
                erd.check_date,
                lb.ee_contrb,
                lb.er_contrb,
                lb.ee_fee_contrb,
                lb.er_fee_contrb,
                nvl(lb.reason_code, erd.reason_code) reason_code,
                erd.pay_code,
                erd.check_amount,
                erd.check_number,
                lb.note,
                erd.plan_type,
                erd.entrp_id,
                erd.list_bill,
                lb.list_bill_upload_id
            from
                list_bill_upload_staging lb,
                account                  acc,
                employer_deposits        erd
            where
                    lb.acct_num = acc.acc_num
                and erd.entrp_id = pc_person.get_entrp_id(acc.acc_id)
                and erd.employer_deposit_id = lb.list_bill_num
                and lb.batch_number = p_batch_num
                and lb.process_status is null
                and not exists (
                    select
                        *
                    from
                        income inc
                    where
                            inc.acc_id = acc.acc_id
                        and inc.contributor = erd.entrp_id
                        and inc.list_bill = erd.list_bill
                        and cc_number = erd.check_number
                )
        ) loop
            if x.ee_contrb + x.er_contrb + x.ee_fee_contrb + x.er_fee_contrb <> 0 then
                insert into income (
                    change_num,
                    acc_id,
                    fee_date  -- from the File
                    ,
                    fee_code  -- 'C'  Contribution type ( refer to fee Names table )
                    ,
                    amount    --Er Contribution
                    ,
                    amount_add -- Ee Contribution
                    ,
                    ee_fee_amount,
                    er_fee_amount,
                    contributor -- Entrp_id of employer
                    ,
                    contributor_amount,
                    pay_code   -- Is CHECK (Pay Code = 1 for Check )
                    ,
                    cc_number    -- employer deposits check number
                    ,
                    list_bill,
                    note,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_updated_date,
                    plan_type
                ) values ( change_seq.nextval,
                           x.acc_id,
                           x.check_date,
                           x.reason_code,
                           x.er_contrb,
                           x.ee_contrb,
                           x.ee_fee_contrb,
                           x.er_fee_contrb,
                           x.entrp_id,
                           x.check_amount,
                           x.pay_code -- Refer to Pay_type View
                           ,
                           x.check_number,
                           x.list_bill,
                           x.note,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           sysdate,
                           x.plan_type );

                if sql%rowcount > 0 then
                    update list_bill_upload_staging
                    set
                        process_status = 'S',
                        last_update_date = sysdate,
                        last_updated_by = p_user_id
                    where
                        list_bill_upload_id = x.list_bill_upload_id;

                end if;

            end if;
        end loop;

        dbms_output.put_line('After Insert');
        update list_bill_upload_staging
        set
            process_status = 'E',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
                batch_number = p_batch_num
            and process_status is null;

        for c2 in all_list_data loop
            dbms_output.put_line('Acct Num' || c2.acct_num);
            dbms_output.put_line('List Bill' || c2.list_bill_num);
            dbms_output.put_line('Entrp_id'
                                 || pc_entrp.get_entrp_id(c2.acct_num));
            for x in (
                select
                    sum(nvl(amount, 0) + nvl(amount_add, 0))           balance,
                    sum(nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) fee_bucket,
                    contributor_amount,
                    cc_number
                from
                    income
                where
                        list_bill = c2.list_bill_num
                    and contributor = pc_person.get_entrp_id(income.acc_id)
                group by
                    contributor_amount,
                    cc_number
            ) loop
                update employer_deposits
                set
                    posted_balance = x.balance,
                    fee_bucket_balance = x.fee_bucket,
                    remaining_balance = x.contributor_amount - ( x.balance + x.fee_bucket ),
                    check_amount = x.contributor_amount,
                    last_update_date = sysdate
                where
                    employer_deposit_id = c2.list_bill_num;

            end loop;

            dbms_output.put_line('After Update');
        end loop;

    exception
        when no_data_found then
            raise_application_error('-20001', 'Error in Insert details of Upload List ' || sqlerrm);
            x_return_status := 'E';
            x_error_message := 'Error in Insert details of Upload List' || sqlerrm;
            dbms_output.put_line('Here');
            rollback;
        when others then
            raise_application_error('-20001', 'Error in Insert details of Upload List ' || sqlerrm);
            x_return_status := 'E';
            x_error_message := 'Error in Insert details of Upload List' || sqlerrm;
            dbms_output.put_line('Here');
            rollback;
    end insert_bill_details;

    procedure process_bill_execute (
        pv_file_name    in varchar2,
        p_user_id       in number,
        p_list_bill     in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) as
        l_batch_num number;
    begin
        export_list_bill(pv_file_name, p_user_id, p_list_bill, x_batch_num, x_error_message,
                         x_return_status);
        l_batch_num := x_batch_num;
        insert_bill_details(l_batch_num, p_user_id, x_error_message, x_return_status);
        dbms_output.put_line('Batch Num' || x_batch_num);
    end process_bill_execute;

    procedure process_website_upload (
        p_batch_num     in number,
        p_user_id       in number,
        pv_file_name    in varchar2,
        p_entrp_id      in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) as
        l_batch_num      number;
        l_file_upload_id number;
    begin
  -- Data already inserted into staging table

        if pv_file_name is not null then
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
                       pv_file_name,
                       p_batch_num,
                       'LIST UPLOAD',
                       sysdate,
                       421,
                       sysdate,
                       421 ) returning file_upload_id into l_file_upload_id;

        end if;

        insert_ach_bank_det(p_batch_num, p_user_id, x_error_message, x_return_status);
    --dbms_output.put_line('Batch Num'||X_batch_num);

        if pv_file_name is not null then
            for x in (
                select
                    sum(
                        case
                            when error_column = 'E' then
                                1
                            else
                                0
                        end
                    ) failure_cnt,
                    sum(
                        case
                            when nvl(error_column, 'E') <> 'E' then
                                1
                            else
                                0
                        end
                    ) success_cnt
                from
                    bill_format_staging
                where
                    batch_number = p_batch_num
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
                                             || ' records, '
                                             || decode(
                            nvl(x.failure_cnt, 0),
                            0,
                            '',
                            nvl(x.failure_cnt, 0)
                            || ' records failed to load '
                        )
                    where
                        file_upload_id = l_file_upload_id;

                end if;
            end loop;
        end if;

    exception
        when others then
            rollback;
    end process_website_upload;

    procedure export_sam_attachments (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    ) as
        l_file_name varchar2(300);
    begin
        l_file_name := substr(p_file_name,
                              instr(p_file_name, '/', 1) + 1,
                              length(p_file_name) - instr(p_file_name, '/', 1));

        pc_log.log_error('export_attachments', 'fILE NAME ' || l_file_name);
        insert into file_attachments (
            attachment_id,
            document_name,
            document_type,
            attachment,
            entity_name,
            entity_id,
            document_purpose,
            description,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                file_attachments_seq.nextval,
                l_file_name,
                mime_type,
                blob_content,
                p_entity_name,
                p_entity_id,
                p_doc_purpose,
                p_description,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                wwv_flow_files
            where
                name = p_file_name;

	--NOTE: p_Source_File_Name is the value of APEX_APPLICATION_FILES.NAME

	--Once the file has been successfully copied to Attachments, delete it from the source FLOWS table
        delete from wwv_flow_files
        where
            name = p_file_name;

    end export_sam_attachments;

    procedure export_sam_cobra_attachments (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    ) as
        l_file_name varchar2(300);
    begin
        l_file_name := substr(p_file_name,
                              instr(p_file_name, '/', 1) + 1,
                              length(p_file_name) - instr(p_file_name, '/', 1));

        pc_log.log_error('export_attachments', 'fILE NAME ' || l_file_name);
        insert into file_attachments (
            attachment_id,
            document_name,
            document_type,
            attachment,
            entity_name,
            entity_id,
            document_purpose,
            description,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                file_attachments_seq.nextval,
                l_file_name,
                mime_type,
                blob_content,
                p_entity_name,
                p_entity_id,
                p_doc_purpose,
                p_description,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                apex_application_temp_files
            where
                name = p_file_name;

	--Once the file has been successfully copied to Attachments, delete it from the source FLOWS table
        delete from apex_application_temp_files
        where
            name = p_file_name;

    end export_sam_cobra_attachments;

    procedure export_pdf_application (
        p_file_name in varchar2
    ) as
        v_bfile     bfile;
        v_blob      blob;
        v_acc_id    number;
        l_doc_count number := 0;
    begin
 -- Note the use of empty_blob(). This initializes the blob object first.
        v_acc_id := pc_account.get_acc_id(upper(replace(p_file_name, '.pdf', '')));

        select
            count(*)
        into l_doc_count
        from
            file_attachments
        where
                document_purpose = 'APP'
            and entity_id = v_acc_id
            and entity_name = 'ACCOUNT';

        if l_doc_count = 0 then
--Why: You need to initialize a blob object before you access or populate it.
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
                       p_file_name,
                       'application/pdf',
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'ACCOUNT',
                       v_acc_id,
                       'APP',
                       'Uploaded from Scheduler',
                       empty_blob() ) returning attachment into v_blob;


-- Get a BFILE locator that is associated with the physical file on the DIRECTORY

            v_bfile := bfilename('PDF_DIR', p_file_name);
-- Open the file using DBMS_LOB

            dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);
-- Load the file into the BLOB pointer

            dbms_lob.loadfromfile(v_blob,
                                  v_bfile,
                                  dbms_lob.getlength(v_bfile));
-- Close the file

            dbms_lob.fileclose(v_bfile);
--COMMIT;
        end if;

    end export_pdf_application;

    procedure load_document (
        p_dir in varchar2
    ) is
    begin
 /* FOR X IN ( SELECT DIRECTORY_PATH FROM all_DIRECTORIES
             WHERE DIRECTORY_NAME =p_dir)
  LOOP
       get_dir_list( X.DIRECTORY_PATH );
  END LOOP;
  for x in (SELECT file_id, FILENAME, LASTMODIFIED , file_id ID
           FROM DIRECTORY_LIST )
  loop
    pc_file_upload.export_pdf_application(x.filename);
  end loop;*/
        pc_file_upload.export_pdf_application(p_dir);
        commit;
    end load_document;

    procedure export_csv_file (
        p_file_name   in varchar2,
        p_acc_num     in varchar2,
        p_doc_purpose in varchar2
    ) as
        v_bfile     bfile;
        v_blob      blob;
        v_acc_id    number;
        l_doc_count number := 0;
    begin
 -- Note the use of empty_blob(). This initializes the blob object first.
        v_acc_id := pc_account.get_acc_id(upper(p_acc_num));
        pc_log.log_error('export_csv_file, file_name', p_file_name);
        pc_log.log_error('export_csv_file, acc_num', p_acc_num);

--Why: You need to initialize a blob object before you access or populate it.
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
                   p_file_name,
                   'application/vnd.ms-excel',
                   sysdate,
                   0,
                   sysdate,
                   0,
                   'ACCOUNT',
                   v_acc_id,
                   nvl(p_doc_purpose, 'ELECTRONIC_FEED'),
                   'Uploaded from Mass Enrollment',
                   empty_blob() ) returning attachment into v_blob;


-- Get a BFILE locator that is associated with the physical file on the DIRECTORY

        v_bfile := bfilename('ENROLL_DIR', p_file_name);
-- Open the file using DBMS_LOB

        dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);
-- Load the file into the BLOB pointer

        dbms_lob.loadfromfile(v_blob,
                              v_bfile,
                              dbms_lob.getlength(v_bfile));
-- Close the file

        dbms_lob.fileclose(v_bfile);
    end export_csv_file;

    procedure upload_hsa_electronic_feeds is

        l_create_ddl varchar2(3200);
        l_acc_num    varchar2(3200);
        l_entrp_id   number;
        v_bfile      bfile;
        v_blob       blob;
        v_acc_id     number;
        l_doc_count  number := 0;
        access_error exception;
        pragma exception_init ( access_error, -30653 );
    begin
        for x in (
            select
                directory_path
            from
                all_directories
            where
                directory_name = 'HSA_AUTO_ENROLL'
        ) loop
            get_dir_list(x.directory_path);
        end loop;

        for x in (
            select
                file_id,
                filename,
                lastmodified,
                file_id id
            from
                directory_list
            where
                ( filename like '%csv'
                  or filename like '%txt%'
                  or filename like '%edi%' )
        ) loop
            begin
                begin
                    l_create_ddl := 'ALTER TABLE AUTO_ENROLLMENTS_EXTERNAL LOCATION (HSA_AUTO_ENROLL:'''
                                    || x.filename
                                    || ''')';
                    execute immediate l_create_ddl;
                exception
                    when others then
                        null;
                end;

                begin
                    for xx in (
                        select distinct
                            employer_name,
                            group_number
                        from
                            auto_enrollments_external
                    ) loop
                        l_acc_num := null;
                        l_entrp_id := null;
                        if xx.group_number is null then
                            for xxxx in (
                                select
                                    b.acc_num
                                from
                                    enterprise a,
                                    account    b
                                where
                                        name like xx.employer_name || '%'
                                        and a.entrp_id = b.entrp_id
                                    and account_type = 'HSA'
                            ) loop
                                l_acc_num := xxxx.acc_num;
                            end loop;
                        end if;

                        v_acc_id := pc_account.get_acc_id(upper(nvl(xx.group_number, l_acc_num)));

                    end loop;

                exception
                    when access_error then
                        null;
                        v_acc_id := null;
                end;
 -- Note the use of empty_blob(). This initializes the blob object first.

--Why: You need to initialize a blob object before you access or populate it.
                if v_acc_id is not null then
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
                               x.filename,
                               'application/vnd.ms-excel',
                               sysdate,
                               0,
                               x.lastmodified,
                               0,
                               'ACCOUNT',
                               v_acc_id,
                               'ELECTRONIC_FEED',
                               'Uploaded from Mass Enrollment',
                               empty_blob() ) returning attachment into v_blob;


          -- Get a BFILE locator that is associated with the physical file on the DIRECTORY

                    v_bfile := bfilename('HSA_AUTO_ENROLL', x.filename);
          -- Open the file using DBMS_LOB

                    dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);
          -- Load the file into the BLOB pointer

                    dbms_lob.loadfromfile(v_blob,
                                          v_bfile,
                                          dbms_lob.getlength(v_bfile));
          -- Close the file
                    pc_log.log_error('LENGTH OF BLOB',
                                     dbms_lob.getlength(v_bfile));
                    dbms_lob.filecloseall;
                end if;

            exception
                when others then
                    dbms_lob.filecloseall;
                    pc_log.log_error('SQL ERROR ', sqlerrm);
       --RAISE;
            end;
        end loop;

    end upload_hsa_electronic_feeds;

    procedure upload_fsa_electronic_feeds is

        l_create_ddl varchar2(3200);
        l_acc_num    varchar2(3200);
        l_entrp_id   number;
        v_bfile      bfile;
        v_blob       blob;
        v_acc_id     number;
        l_doc_count  number := 0;
        access_error exception;
        pragma exception_init ( access_error, -30653 );
    begin
        for x in (
            select
                directory_path
            from
                all_directories
            where
                directory_name = 'AUTO_ENROLL'
        ) loop
            get_dir_list(x.directory_path);
        end loop;

        for x in (
            select
                file_id,
                filename,
                lastmodified,
                file_id id
            from
                directory_list
            where
                ( filename like '%csv'
                  or filename like '%txt%'
                  or filename like '%edi%' )
        ) loop
            begin
                begin
                    l_create_ddl := 'ALTER TABLE FSA_ENROLL_NEW_EXTERNAL LOCATION (AUTO_ENROLL:'''
                                    || x.filename
                                    || ''')';
                    execute immediate l_create_ddl;
                exception
                    when others then
                        null;
                end;

                begin
                    for xx in (
                        select distinct
                            group_number
                        from
                            fsa_enroll_new_external
                    ) loop
                        v_acc_id := pc_account.get_acc_id(xx.group_number);
                    end loop;

                exception
                    when access_error then
                        null;
                        v_acc_id := null;
                end;
 -- Note the use of empty_blob(). This initializes the blob object first.

--Why: You need to initialize a blob object before you access or populate it.
                if v_acc_id is not null then
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
                               x.filename,
                               'application/vnd.ms-excel',
                               sysdate,
                               0,
                               x.lastmodified,
                               0,
                               'ACCOUNT',
                               v_acc_id,
                               'ELECTRONIC_FEED',
                               'Uploaded from Mass Enrollment',
                               empty_blob() ) returning attachment into v_blob;


          -- Get a BFILE locator that is associated with the physical file on the DIRECTORY

                    v_bfile := bfilename('AUTO_ENROLL', x.filename);
          -- Open the file using DBMS_LOB

                    dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);
          -- Load the file into the BLOB pointer

                    dbms_lob.loadfromfile(v_blob,
                                          v_bfile,
                                          dbms_lob.getlength(v_bfile));
          -- Close the file
                    dbms_lob.filecloseall;
                end if;

            exception
                when others then
                    dbms_lob.filecloseall;
                    pc_log.log_error('SQL ERROR ', sqlerrm);
       --RAISE;
            end;
        end loop;

    end;
-- Added by Swamy on 04/Jun/2018 wrt development Ticket# 5469
-- Procedure will insert data from apex_application_temp_files to FILE_ATTACHMENTS.

    procedure export_attachments_new (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    ) as
        l_file_name varchar2(300);
        v_count     number;
    begin
        l_file_name := substr(p_file_name,
                              instr(p_file_name, '/', 1) + 1,
                              length(p_file_name) - instr(p_file_name, '/', 1));

        pc_log.log_error('export_attachments', 'fILE NAME ' || l_file_name);
        select
            count(*)
        into v_count
        from
            apex_application_temp_files
        where
            name = p_file_name;

        pc_log.log_error('p_file_name :=', 'p_file_name'
                                           || p_file_name
                                           || ' v_count :='
                                           || v_count);
        insert into file_attachments (
            attachment_id,
            document_name,
            document_type,
            attachment,
            entity_name,
            entity_id,
            document_purpose,
            description,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                file_attachments_seq.nextval,
                l_file_name,
                mime_type,
                blob_content,
                p_entity_name,
                p_entity_id,
                p_doc_purpose,
                p_description,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                apex_application_temp_files
            where
                name = p_file_name;

	--NOTE: p_Source_File_Name is the value of APEX_APPLICATION_FILES.NAME
        for x in (
            select
                a.account_type,
                b.created_by user_id
            from
                account                   a,
                ben_plan_enrollment_setup b
            where
                    a.acc_id = b.acc_id
                and a.account_status = 1
                and b.ben_plan_id = p_entity_id
                and a.account_type in ( 'COBRA', 'ERISA_WRAP', 'FORM_5500', 'POP' )
        ) loop
            pc_notifications.notify_plan_document_upload(p_file_name, x.user_id, p_entity_name, p_entity_id);
        end loop;
	--Once the file has been successfully copied to Attachments, delete it from the source FLOWS table
        delete from apex_application_temp_files
        where
            name = p_file_name;

    end export_attachments_new;

    procedure export_document (
        p_file_name   in varchar2,
        p_entity_id   in varchar2,
        p_entity_name in varchar2,
        p_dir         in varchar2,
        p_doc_purpose in varchar2,
        p_note        in varchar2
    ) as
        v_bfile     bfile;
        v_blob      blob;
        v_acc_id    number;
        l_doc_count number := 0;
    begin

   --Why: You need to initialize a blob object before you access or populate it.
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
                   p_file_name,
                   'application/vnd.ms-excel',
                   sysdate,
                   0,
                   sysdate,
                   0,
                   p_entity_name,
                   p_entity_id,
                   p_doc_purpose,
                   p_note,
                   empty_blob() ) returning attachment into v_blob;


  -- Get a BFILE locator that is associated with the physical file on the DIRECTORY

        v_bfile := bfilename(p_dir, p_file_name);
    -- Open the file using DBMS_LOB

        dbms_lob.fileopen(v_bfile, dbms_lob.file_readonly);
    -- Load the file into the BLOB pointer

        dbms_lob.loadfromfile(v_blob,
                              v_bfile,
                              dbms_lob.getlength(v_bfile));
    -- Close the file

        dbms_lob.fileclose(v_bfile);
    --COMMIT;

    end export_document;

-- Added by Joshi for 9072
    procedure insert_file_upload_history (
        p_batch_num         in number,
        p_user_id           in number,
        pv_file_name        in varchar2,
        p_entrp_id          in varchar2,
        p_action            in varchar2,
        p_account_type      in varchar2,
        p_enrollment_source in varchar2,
        p_file_type         in varchar2,
        p_error             in varchar2 default null -- Added bu Joshi for 9670.
        ,
        x_file_upload_id    out number
    ) as
        pragma autonomous_transaction;
        l_file_id     number;
        l_entrp_id    number;
        l_batch_nmber number;
    begin
        for x in (
            select
                max(file_upload_id) file_upload_id
            from
                file_upload_history
            where
                file_name = pv_file_name
        ) loop
            l_file_id := x.file_upload_id;
            x_file_upload_id := x.file_upload_id;
        end loop;

        if nvl(l_file_id, 0) <> 0 then
            update file_upload_history
            set
                entrp_id = p_entrp_id,
                batch_number = p_batch_num,
                file_upload_result = p_error,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                file_upload_id = l_file_id;

        end if;

        if
            nvl(l_file_id, 0) = 0
            and pv_file_name is not null
        then
            insert into file_upload_history (
                file_upload_id,
                entrp_id,
                file_name,
                batch_number,
                action,
                account_type,
                enrollment_source,
                file_type,
                file_upload_result,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( file_upload_history_seq.nextval,
                       p_entrp_id,
                       pv_file_name,
                       p_batch_num,
                       p_action,
                       p_account_type,
                       p_enrollment_source,
                       p_file_type,
                       p_error,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id ) returning file_upload_id into x_file_upload_id;

        end if;

        commit;
    end insert_file_upload_history;

-- Added by Swamy for Ticket#12309
    procedure giact_insert_file_attachments (
        p_user_bank_stg_id in number,
        p_attachment_id    in number,
        p_entity_id        in number,
        p_entity_name      in varchar2,
        p_document_purpose in varchar2,
        p_batch_number     in number,
        p_source           in varchar2,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    ) is
    begin
    -- For FSA/HRA enrollments the bank data is saved in user_bank_Acct_staging table, so user_bank_stg_id is used.
    -- For FSA/HRA Renewals the bank data is saved in online_fsa_hra_staging table, so attachment_id is used.
    -- For Cobra enrollments and renewals bank data is saved in user_bank_Acct_staging table, so user_bank_stg_id is used.as attachment is null,used NVL condition in renewal
        if nvl(p_source, '*') = 'E' then
            insert into file_attachments (
                attachment_id,
                document_name,
                document_type,
                attachment,
                entity_name,
                entity_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                document_purpose
            )
                (
                    select
                        file_attachments_seq.nextval,
                        document_name,
                        document_type,
                        attachment,
                        p_entity_name,
                        p_entity_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        p_document_purpose
                    from
                        file_attachments_staging fs
                    where
                            plan_id = p_user_bank_stg_id
                        and batch_number = p_batch_number
                  --AND NOT EXISTS (SELECT * FROM FILE_ATTACHMENTS fa WHERE fa.ATTACHMENT_ID =FS.plan_ID) 
                );

        elsif nvl(p_source, '*') = 'R' then
            insert into file_attachments (
                attachment_id,
                document_name,
                document_type,
                attachment,
                entity_name,
                entity_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                document_purpose
            )
                (
                    select
                        file_attachments_seq.nextval,
                        document_name,
                        document_type,
                        attachment,
                        p_entity_name,
                        p_entity_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        p_document_purpose
                    from
                        file_attachments_staging fs
                    where
                            attachment_id = nvl(p_attachment_id, attachment_id)   -- NVL Added by Swamy for Ticket#12534 
                        and plan_id = p_user_bank_stg_id
                        and batch_number = p_batch_number
                );

        end if;
    exception
        when others then
            rollback;
            x_error_message := 'In giact_insert_File_Attachments when others : ' || sqlerrm;
            x_error_status := 'E';
            pc_log.log_error('PC_file_upload.giact_insert_File_Attachments', sqlerrm || dbms_utility.format_error_backtrace);
    end giact_insert_file_attachments;

end pc_file_upload;
/

