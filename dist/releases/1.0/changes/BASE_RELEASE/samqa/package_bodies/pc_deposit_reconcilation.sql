-- liquibase formatted sql
-- changeset SAMQA:1754374002924 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_deposit_reconcilation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_deposit_reconcilation.sql:null:e10f1f456ef071d3b955c63cb84546f5df9c1918:create

create or replace package body samqa.pc_deposit_reconcilation as

    procedure export_deposit_report (
        pv_file_name in varchar2,
        p_user_id    in number
    ) as

        l_file           utl_file.file_type;
        l_buffer         raw(32767);
        l_amount         binary_integer := 32767;
        l_pos            integer := 1;
        l_blob           blob;
        l_blob_len       integer;
        exc_no_file exception;
        l_create_ddl     varchar2(32000);
        lv_dest_file     varchar2(300);
        l_sqlerrm        varchar2(32000);
        l_create_error exception;
        l_change_num     number;
        v_batch_number   number;            -- Added by Swamy wrt Ticket#6588 on 20/09/2018
        v_process_status varchar2(1);       -- Added by Swamy wrt Ticket#6588 on 20/09/2018
        v_error_message  varchar2(255);     -- Added by Swamy wrt Ticket#6588 on 20/09/2018
        erreur exception;         -- Added by Swamy wrt Ticket#6588 on 20/09/2018
    begin
        pc_log.log_error('PC_DEPOSIT_RECONCILATION.export_deposit_report,pv_file_name', pv_file_name);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));

        pc_log.log_error('PC_DEPOSIT_RECONCILATION.export_deposit_report,lv_dest_file', lv_dest_file);

       /* l_create_ddl := 'CREATE TABLE  DEPOSIT_RECONCILE_EXTERNAL '||
			      '(FIRST_NAME     VARCHAR2(2000) '||
			      ',LAST_NAME      VARCHAR2(2000) '||
			      ',ACC_NUM        VARCHAR2(30) '||
			      ',CHECK_NUMBER   VARCHAR2(255) '||
			      ',CHECK_AMOUNT   NUMBER '||
			      ',TRANS_DATE     VARCHAR2(30) '||
			      ',NEW_APP_FLAG   VARCHAR2(1)  '||
			      ',NEW_APP_AMOUNT NUMBER      '||
			      ',POSTED_FLAG    VARCHAR2(30) '||
			      ',STATUS         VARCHAR2(30))'||
			      '  ORGANIZATION EXTERNAL '||
			      '  ( TYPE ORACLE_LOADER DEFAULT DIRECTORY DEBIT_DIR '||
			      '  ACCESS PARAMETERS ('||
			      '  records delimited by newline skip 1'||
			      '  badfile ''deposit_reconcile.bad'' '||
			      '  logfile ''deposit_reconcile.log'' '||
			      '  fields terminated by '','' '||
			      '  optionally enclosed by ''"'' '||
			      '  LRTRIM '||
			      '  MISSING FIELD VALUES ARE NULL ) '||
			      '  LOCATION ('''|| lv_dest_file ||''')'||
			      '  ) REJECT LIMIT 1 ';*/


	      /* Get the contents of BLOB from wwv_flow_files */
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        pc_log.log_error('PC_DEPOSIT_RECONCILATION.export_deposit_report,pv_file_name', pv_file_name);
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
	     /* DELETE FROM wwv_flow_files
	      WHERE NAME = pv_file_name;
*/

        begin
            execute immediate '
                   ALTER TABLE DEPOSIT_RECONCILE_EXTERNAL
                    location (DEBIT_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of deposit reconcilation file' || sqlerrm;
                raise l_create_error;
        end;

        -- Start Added by Swamy wrt Ticket#6588 on 20/09/2018
		/*   -- Commented by Swamy and moved the code below wrt Ticket#6588 on 20/09/2018
		FOR X IN ( SELECT CHECK_NUMBER, TO_CHAR(TO_DATE(TRANS_DATE,'MM/DD/YYYY'),'YYYY') TYEAR
                      FROM  DEPOSIT_RECONCILE_EXTERNAL)
          LOOP
             BEGIN
                IF TO_CHAR(SYSDATE,'YYYY') <> X.TYEAR THEN
                    l_sqlerrm := 'Error in processing deposit upload, there seems to be some problem with transaction date '
                    ||x.tyear||' for '||x.check_number;
                END IF;
             EXCEPTION
               WHEN OTHERS THEN
                  RAISE l_create_error;
             END;
          END LOOP;
		  */
		-- Initializing Batch Number
        select
            batch_num_seq.nextval
        into v_batch_number
        from
            dual;

        pc_log.log_error('DEPOSIT_UPLOAD', 'Posting Employer Deposit batch_number ' || v_batch_number);
        -- Deleting all the records in the Staging table
        delete from deposit_reconcile_stage;
        -- Inserting the records from external table to staging table
        insert into deposit_reconcile_stage (
            first_name,
            last_name,
            acc_num,
            check_number,
            check_amount,
            trans_date,
            ssn,
            reason_code,
            er_fee_amount,
            ee_fee_amount,
            batch_number,
            process_status,
            error_message
        )
            select
                first_name,
                last_name,
                acc_num,
                check_number,
                check_amount,
                trans_date,
                ssn,
                reason_code,
                er_fee_amount,
                ee_fee_amount,
                v_batch_number,
                null,
                null
            from
                deposit_reconcile_external
            where
                acc_num is not null;

         -- End by Swamy wrt Ticket#6588 on 20/09/2018

        pc_log.log_error('DEPOSIT_UPLOAD', 'Posting Employer Deposit');

     /*** Posting deposit to employer deposit ***/
        for x in (
            select
                dep.check_number,
                dep.check_amount,
                to_date(dep.trans_date, 'MM/DD/YYYY')                  check_date,
                acc.entrp_id,
                acc.acc_id,
                acc.pers_id,
                dep.reason_code,
                nvl(dep.er_fee_amount, 0) + nvl(dep.ee_fee_amount, 0)  fee_amount,
                to_char(to_date(dep.trans_date, 'MM/DD/YYYY'), 'YYYY') tyear    -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                dep.acc_num       -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                acc.account_type  -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                acc.plan_code     -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                ( initcap(dep.first_name)
                  || initcap(decode(
                    nvl(dep.last_name, '*'),
                    '*',
                    '.',
                    (' '
                     || dep.last_name
                     || '.')
                )) )                                                   name   -- Added by Swamy wrt Ticket#6588 on 20/09/2018
            from
                deposit_reconcile_stage dep   -- Replaced Deposit_Reconcile_External with Deposit_Reconcile_Stage by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                account                 acc
            where
                    dep.acc_num = acc.acc_num
                and dep.first_name is not null
         --  AND   acc.account_status <> 4
                and acc.entrp_id is not null
        /*AND   NOT EXISTS ( SELECT * FROM EMPLOYER_DEPOSITS B
                            WHERE ACC.ENTRP_ID = B.ENTRP_ID
                              AND DEP.CHECK_NUMBER = B.CHECK_NUMBER))*/   -- Commented and included in the loop to display the error message by Swamy wrt Ticket#6588 on 20/09/2018
        ) loop
            begin
	      -- Start Added by Swamy wrt Ticket#6588 on 20/09/2018
          -- Initializing the variables
                v_process_status := 'S';
                v_error_message := null;
		  -- Moved the code from top to here
                if to_char(sysdate, 'YYYY') <> x.tyear then
                    v_process_status := 'E';
                    v_error_message := 'Error in processing deposit upload, there seems to be some problem with transaction date '
                                       || x.tyear
                                       || ' for '
                                       || x.check_number;
                    raise erreur;
                end if;
          -- For Simple HSA contribution should not be uploaded
                if
                    x.account_type = 'HSA'
                    and x.plan_code = 8
                then
                    v_error_message := 'Cannot Upload Contribution for employer '
                                       || x.name
                                       || 'This Employer offers Simple-HSA plan and can only contribute online.';
                    v_process_status := 'E';
                    raise erreur;
                end if;
          -- Moved the code from top to here
                for m in (
                    select
                        1
                    from
                        employer_deposits b
                    where
                            b.entrp_id = x.entrp_id
                        and b.check_number = x.check_number
                ) loop
                    v_error_message := ' Contribution already uploaded for employer for check No := ' || x.check_number;
                    v_process_status := 'E';
                    raise erreur;
                end loop;
         -- End by Swamy wrt Ticket#6588 on 20/09/2018
		 -- IF x.entrp_id IS NOT NULL THEN    -- Commented by Swamy as we are selecting only records with entrp_id as not null
                insert into employer_deposits a (
                    employer_deposit_id,
                    entrp_id,
                    list_bill,
                    check_number,
                    check_amount,
                    check_date,
                    posted_balance,
                    fee_bucket_balance,
                    remaining_balance,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    note,
                    reason_code,
                    pay_code
                ) values ( employer_deposit_seq.nextval -- EMPLOYER_DEPOSIT_ID
                ,
                           x.entrp_id -- ENTRP_ID
                           ,
                           employer_deposit_seq.currval -- LIST_BILL
                           ,
                           x.check_number -- CHECK_NUMBER
                           ,
                           x.check_amount -- CHECK_AMOUNT
                           ,
                           x.check_date   -- CHECK_DATE
                           ,
                           0   -- POSTED_BALANCE
                           ,
                           0   -- FEE_BUCKET_BALANCE
                           ,
                           x.check_amount -- REMAINING_BALANCE
                           ,
                           p_user_id -- CREATED_BY
                           ,
                           sysdate   -- CREATION_DATE
                           ,
                           p_user_id -- LAST_UPDATED_BY
                           ,
                           sysdate   -- LAST_UPDATE_DATE
                           ,
                           'Uploaded deposit',
                           nvl(x.reason_code, 4),
                           1 ); -- NOTE

        -- Start Added by Swamy wrt Ticket#6588 on 20/09/2018
            exception
                when erreur then
                    null;
                when others then
                    v_process_status := 'E';
                    v_error_message := ' Others ' || sqlerrm(sqlcode);
            end;

            pc_log.log_error('DEPOSIT_UPLOAD', 'Posting deposit register Update Deposit_Reconcile_Stage X.Acc_Num := '
                                               || x.acc_num
                                               || ' V_Process_Status :='
                                               || v_process_status
                                               || 'V_Error_Message :='
                                               || v_error_message
                                               || ' V_Batch_Number :='
                                               || v_batch_number);

        -- Update The Staging Table With The Relavent Errors With Message Or Sucessful Records With Process_Status = S.
            update deposit_reconcile_stage
            set
                process_status = v_process_status,
                error_message = v_error_message
            where
                    batch_number = v_batch_number
                and acc_num = x.acc_num;
        -- End by Swamy wrt Ticket#6588 on 20/09/2018
        end loop;

        pc_log.log_error('DEPOSIT_UPLOAD', 'Posting deposit register');
        for x in (
            select
                dep.check_number,
                dep.check_amount,
                to_date(dep.trans_date, 'MM/DD/YYYY') check_date,
                acc.entrp_id,
                acc.acc_id,
                acc.pers_id,
                case
                    when dep.trans_date <> to_char(c.check_date, 'MM/DD/YYYY') then
                        null
                    else
                        c.list_bill
                end                                   list_bill,
                case
                    when dep.trans_date <> to_char(c.check_date, 'MM/DD/YYYY') then
                        null
                    else
                        c.employer_deposit_id
                end                                   employer_deposit_id,
                case
                    when dep.trans_date <> to_char(c.check_date, 'MM/DD/YYYY') then
                        0
                    else
                        c.posted_balance
                end                                   posted_balance,
                case
                    when dep.trans_date <> to_char(c.check_date, 'MM/DD/YYYY') then
                        c.check_amount - ( nvl(dep.er_fee_amount, 0) + nvl(dep.ee_fee_amount, 0) )
                    else
                        c.remaining_balance
                end                                   remaining_balance,
                acc.acc_num,
                (
                    select
                        name
                    from
                        enterprise
                    where
                        entrp_id = acc.entrp_id
                )                                     name,
                case
                    when dep.trans_date <> to_char(c.check_date, 'MM/DD/YYYY')
                         and c.creation_date < trunc(sysdate) then
                        'Y'
                    else
                        'N'
                end                                   duplicate_flag,
                case
                    when dep.trans_date <> to_char(c.check_date, 'MM/DD/YYYY')
                         and c.creation_date < trunc(sysdate) then
                        'Check Number '
                        || dep.check_number
                        || ' already posted on '
                        || c.creation_date
                end                                   note
            from
                deposit_reconcile_stage dep   -- Replaced Deposit_Reconcile_External with Deposit_Reconcile_Stage by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                account                 acc,
                employer_deposits       c
            where
                    dep.acc_num = acc.acc_num
                and dep.first_name is not null
                and acc.entrp_id is not null
                and acc.entrp_id = c.entrp_id
                and dep.check_number = c.check_number
                and dep.process_status = 'S'            -- Added by Swamy wrt Ticket#6588 on 20/09/2018, Take Only The Sucessful Records From Staging Table
                and not exists (
                    select
                        *
                    from
                        deposit_register b
                    where
                            acc.entrp_id = b.entrp_id
                        and dep.check_number = b.check_number
                )
        ) loop
            insert into deposit_register (
                deposit_register_id,
                first_name,
                acc_num,
                check_number,
                check_amount,
                trans_date,
                status,
                posted_flag,
                reconciled_flag,
                entrp_id,
                acc_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                list_bill,
                orig_sys_ref,
                duplicate_flag,
                note
            ) values ( deposit_register_seq.nextval,
                       x.name,
                       x.acc_num,
                       x.check_number,
                       x.check_amount,
                       to_char(x.check_date, 'MM/DD/YYYY'),
                       'EXISTING',
                       decode(x.posted_balance, 0, 'N', 'Y'),
                       decode(x.remaining_balance, 0, 'N', 'Y'),
                       x.entrp_id,
                       x.acc_id,
                       sysdate,
                       get_user_id(v('APP_USER')),
                       sysdate,
                       get_user_id(v('APP_USER')),
                       x.list_bill,
                       x.employer_deposit_id,
                       x.duplicate_flag,
                       x.note );

        end loop;

    /*** Posting deposit to individual deposit ***/
        pc_log.log_error('DEPOSIT_UPLOAD', 'Posting Individual Depsoit');
        for x in (
            select
                dep.first_name,
                dep.last_name,
                dep.acc_num,
                dep.trans_date,
                dep.check_number,
                dep.check_amount,
                to_date(dep.trans_date, 'MM/DD/YYYY')                  check_date,
                acc.entrp_id,
                acc.acc_id,
                acc.pers_id,
                acc.account_status,
                nvl(dep.reason_code, 4)                                reason_code,
                nvl(dep.er_fee_amount, 0)                              er_fee_amount,
                nvl(dep.ee_fee_amount, 0)                              ee_fee_amount,
                acc.account_type           -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                acc.plan_code              -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                ( initcap(dep.first_name)
                  || initcap(decode(
                    nvl(dep.last_name, '*'),
                    '*',
                    '.',
                    (' '
                     || dep.last_name
                     || '.')
                )) )                                                   name   -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                to_char(to_date(dep.trans_date, 'MM/DD/YYYY'), 'YYYY') tyear    -- Added by Swamy wrt Ticket#6588 on 20/09/2018
            from
                deposit_reconcile_stage dep  -- Replaced Deposit_Reconcile_External with Deposit_Reconcile_Stage by Swamy wrt Ticket#6588 on 20/09/2018
                ,
                account                 acc
            where
                    dep.acc_num = acc.acc_num
                and dep.first_name is not null
                and acc.pers_id is not null
		/*AND   acc.account_status <> 4
	    AND   NOT EXISTS ( SELECT * FROM INCOME B
                            WHERE ACC.ACC_ID = B.ACC_ID
                              AND DEP.CHECK_NUMBER = B.CC_NUMBER))*/   -- Commented and moved below by Swamy wrt Ticket#6588 on 20/09/2018
        ) loop
            begin
      -- Start Added by Swamy wrt Ticket#6588 on 20/09/2018
                v_process_status := 'S';
                v_error_message := null;
      -- Moved code from top to here
                if to_char(sysdate, 'YYYY') <> x.tyear then
                    v_process_status := 'E';
                    v_error_message := 'Error in processing deposit upload, there seems to be some problem with transaction date '
                                       || x.tyear
                                       || ' for '
                                       || x.check_number;
                    raise erreur;
                end if;

      -- Moved code from top to here, in order to capture the error message to be displayed in Apex.
                if x.account_status = 4 then
                    v_error_message := 'Closed Account, Cannot Post Funds';
                    v_process_status := 'E';
                    raise erreur;
                end if;
      -- For Simple HSA, Contribution shoould not be allowed.
                if
                    x.account_type = 'HSA'
                    and x.plan_code = 8
                then
                    v_error_message := 'Cannot Upload Contribution for employee '
                                       || x.name
                                       || 'This employee is enrolled in Simple-HSA plan and can only contribute online.';
                    v_process_status := 'E';
                    raise erreur;
                end if;
       -- Moved code from top to here, in order to capture the error message to be displayed in Apex.
                for n in (
                    select
                        1
                    from
                        income b
                    where
                            b.acc_id = x.acc_id
                        and b.cc_number = x.check_number
                ) loop
                    v_error_message := 'Contribution already uploaded for employee '
                                       || x.acc_num
                                       || ' for check No := '
                                       || x.check_number;
                    v_process_status := 'E';
                    raise erreur;
                end loop;
     -- End by Swamy wrt Ticket#6588 on 20/09/2018
	 -- IF x.pers_id IS NOT NULL THEN   -- Commented by Swamy as we are selecting only records with pers_id as not null
                l_change_num := null;
                insert into income (
                    change_num,
                    acc_id,
                    fee_date,
                    fee_code,
                    amount,
                    amount_add,
                    ee_fee_amount,
                    pay_code,
                    cc_number,
                    note,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_updated_date,
                    transaction_type
                ) values ( change_seq.nextval -- change_num
                ,
                           x.acc_id   -- acc_id
                           ,
                           x.check_date -- fee_date
                           ,
                           x.reason_code -- fee_code(Regular Contribution)
                           ,
                           0 -- employer deposit
                           ,
                           x.check_amount -- employee deposit
                           ,
                           x.ee_fee_amount,
                           1 -- pay code ( check )
                           ,
                           x.check_number -- cc_number
                           ,
                           'generate ' || to_char(sysdate, 'MM/DD/YYYY'),
                           p_user_id -- CREATED_BY
                           ,
                           sysdate   -- CREATION_DATE
                           ,
                           p_user_id -- LAST_UPDATED_BY
                           ,
                           sysdate,
                           'P' ) returning change_num into l_change_num;   -- LAST_UPDATE_DATE);

	  -- Start Added by Swamy wrt Ticket#6588 on 20/09/2018
            exception
                when erreur then
                    null;
                when others then
                    v_process_status := 'E';
                    v_error_message := ' Others ' || sqlerrm(sqlcode);
            end;

            pc_log.log_error('DEPOSIT_UPLOAD', 'Posting deposit register Update Deposit_Reconcile_Stage X.Acc_Num := '
                                               || x.acc_num
                                               || ' V_Process_Status :='
                                               || v_process_status
                                               || 'V_Error_Message :='
                                               || v_error_message
                                               || ' V_Batch_Number :='
                                               || v_batch_number);

      -- Update The Staging Table With The Relavent Errors Message Or Sucessful/Failure Records With Process_Status = S/E.
            update deposit_reconcile_stage
            set
                process_status = v_process_status,
                error_message = v_error_message
            where
                    batch_number = v_batch_number
                and acc_num = x.acc_num;
     -- End by Swamy wrt Ticket#6588 on 20/09/2018
        end loop;

        pc_log.log_error('DEPOSIT_UPLOAD', 'Posting SSN Depsoit');
        insert into deposit_register (
            deposit_register_id,
            first_name,
            last_name,
            ssn,
            check_number,
            check_amount,
            trans_date,
            posted_flag,
            reconciled_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                deposit_register_seq.nextval,
                first_name,
                last_name,
                ssn,
                check_number,
                check_amount + nvl(ee_fee_amount, 0),
                trans_date,
                'N',
                'N',
                sysdate,
                get_user_id(v('APP_USER')),
                sysdate,
                get_user_id(v('APP_USER'))
            from
                deposit_reconcile_stage dep        -- Replaced Deposit_Reconcile_External with Deposit_Reconcile_Stage by Swamy wrt Ticket#6588 on 20/09/2018
            where
                ssn is not null
                and dep.process_status = 'S'            -- Added by Swamy wrt Ticket#6588 on 20/09/2018, Take Only The Sucessful Records From Staging Table
                and not exists (
                    select
                        1
                    from
                        deposit_register b             -- Added by Swamy wrt Ticket#6588 on 20/09/2018
                    where
                            b.ssn = dep.ssn
                        and b.check_number = dep.check_number
                );

      -- Added by Swamy wrt Ticket#6588 on 20/09/2018
	  -- Update all the records with status as 'E' for all those records which did not load.
        update deposit_reconcile_stage
        set
            process_status = 'E',
            error_message = 'Record not loaded.'
        where
                batch_number = v_batch_number
            and process_status is null;

        commit;
    exception
        when l_create_error then
           /*mail_utility.send_email('oracle@sterlingadministration.com'
                   ,'vanitha.subramanyam@sterlingadministration.com'
                   ,'Error in processing deposit reconcilation  file'
                   ,'Error in altering deposit reconcilation file  '|| lv_dest_file);
           */
            null;
            raise_application_error('-20001', 'Error in processing File ' || l_sqlerrm);
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
    end export_deposit_report;

    procedure update_account is
    begin
        update deposit_register
        set
            acc_id = (
                select
                    acc_id
                from
                    person  a,
                    account b
                where
                        a.ssn = deposit_register.acc_num
                    and a.pers_id = b.pers_id
            )
        where
            instr(acc_num, '-') > 0;

        update deposit_register
        set
            acc_num = (
                select
                    acc_num
                from
                    account
                where
                    account.acc_id = deposit_register.acc_id
            )
        where
            instr(acc_num, '-') > 0;

        commit;
    end update_account;

    procedure reconcile_account is
    begin
        for x in (
            select
                deposit_register_id
            from
                deposit_audit_v
            where
                    reconciled_flag = 'N'
                and nvl(posted_amount, 0) = nvl(check_amount, 0)
        ) loop
            update deposit_register
            set
                reconciled_flag = 'Y',
                last_update_date = sysdate,
                last_updated_by = 0
            where
                deposit_register_id = x.deposit_register_id;

        end loop;

        for x in (
            select
                a.*,
                b.account_type
            from
                (
                    select
                        entrp_id,
                        list_bill,
                        check_date,
                        check_amount,
                        posted_balance,
                        remaining_balance,
                        refund_amount,
                        reason_code,
                        employer_deposit_id,
                        (
                            select
                                sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0))
                            from
                                income c
                            where
                                    a.list_bill = c.list_bill
                                and c.contributor = a.entrp_id
                        ) actual_posted_balance,
                        (
                            select
                                sum(nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0))
                            from
                                income c
                            where
                                    a.list_bill = c.list_bill
                                and c.contributor = a.entrp_id
                        ) fee_bucket_balance
                    from
                        employer_deposits a
                )       a,
                account b
            where
                a.entrp_id = b.entrp_id
            order by
                check_date desc
        ) loop
            if x.account_type = 'HSA' then
                update employer_deposits
                set
                    remaining_balance = check_amount - ( nvl(x.actual_posted_balance, 0) + nvl(refund_amount, 0) ),
                    posted_balance = x.actual_posted_balance,
                    fee_bucket_balance = x.fee_bucket_balance,
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                    list_bill = x.list_bill;

                if nvl(x.posted_balance, 0) = nvl(x.actual_posted_balance, 0) then
                    update deposit_register
                    set
                        reconciled_flag = 'Y',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                        orig_sys_ref = x.employer_deposit_id;

                end if;

                if nvl(x.posted_balance, 0) <> nvl(x.actual_posted_balance, 0) then
                    update deposit_register
                    set
                        reconciled_flag = 'N',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                        orig_sys_ref = x.employer_deposit_id;

                end if;

            end if;

            if
                x.account_type in ( 'HRA', 'FSA' )
                and x.reason_code in ( 11, 12 )
            then
                update employer_deposits
                set
                    remaining_balance = nvl(check_amount, 0) - nvl(x.actual_posted_balance, 0),
                    posted_balance = x.actual_posted_balance
                where
                    list_bill = x.list_bill;

                if nvl(x.posted_balance, 0) = nvl(x.actual_posted_balance, 0) then
                    update deposit_register
                    set
                        reconciled_flag = 'Y',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                            orig_sys_ref = x.employer_deposit_id
                        and reconciled_flag = 'N';

                end if;

                if nvl(x.posted_balance, 0) <> nvl(x.actual_posted_balance, 0) then
                    update deposit_register
                    set
                        reconciled_flag = 'N',
                        last_update_date = sysdate,
                        last_updated_by = 0
                    where
                            orig_sys_ref = x.employer_deposit_id
                        and reconciled_flag = 'Y';

                end if;

            end if;

            if
                x.account_type in ( 'HRA', 'FSA', 'POP' )
                and x.reason_code not in ( 11, 12 )
            then
                update deposit_register
                set
                    reconciled_flag = 'Y',
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                        orig_sys_ref = x.employer_deposit_id
                    and reconciled_flag = 'N';

            end if;

        end loop;

        commit;
    end;

end pc_deposit_reconcilation;
/

