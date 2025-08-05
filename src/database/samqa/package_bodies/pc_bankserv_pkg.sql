create or replace package body samqa.pc_bankserv_pkg is

    procedure pc_bankserv_txn (
        p_batch_number in number,
        p_user_id      in number
    ) is

        p_entrp_id      number;
        p_contributor   number;
        p_acc_num       varchar2(100);
        l_first_name    varchar2(100);
        l_last_name     varchar2(100);
        l_status        varchar2(10);
        p_acct_type     varchar2(100);
        l_list_bill     number;
        l_error_status  varchar2(10);
        l_error_message varchar2(1000);
        l_detail_id     number;
        l_change_num    number;
        l_count         number := 0;
    begin
        for x in (
            select
                a.*,
                b.entrp_id,
                b.pers_id,
                b.account_type,
                b.acc_num,
                bts.return_date,
                bts.record_id
            from
                bankserv_txn_staging bts,
                ach_transfer         a,
                account              b
            where
                    bts.cust_ref_num = a.transaction_id
                and bts.processed = 'N'
                and bts.batch_number = p_batch_number
                and a.acc_id = b.acc_id
        ) loop
            validate_data(x.transaction_id, l_status);
            if l_status = 'S' then
                if x.transaction_type = 'C' then  -- Individual record

                    if x.entrp_id is null then       --Create an entry in INCOME table

                        select
                            count(*)
                        into l_count
                        from
                            income
                        where
                                acc_id = x.acc_id
                            and cc_number in ( 'ACH'
                                               || x.transaction_id
                                               || '-adj', 'Bankserv'
                                                          || x.transaction_id
                                                          || '-adj' );

                        if l_count = 0 then
                            insert into income (
                                change_num,
                                acc_id,
                                fee_date,
                                fee_code,
                                amount_add,
                                ee_fee_amount,
                                contributor,
                                pay_code,
                                note,
                                amount,
                                cc_number,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_updated_date
                            ) values ( change_seq.nextval,
                                       x.acc_id,
                                       x.return_date,
                                       x.reason_code,
                                       - nvl(x.amount, 0),
                                       - nvl(x.fee_amount, 0),
                                       null,
                                       5,
                                       'Bankserv Adjustment entry for Transaction ID:' || x.transaction_id,
                                       0,
                                       case
                                           when x.pay_code = 3 then
                                               'ACH'
                                               || x.transaction_id
                                               || '-adj'
                                           else
                                               'Bankserv'
                                               || x.transaction_id
                                               || '-adj'
                                       end,
                                       p_user_id,
                                       sysdate,
                                       p_user_id,
                                       sysdate ) return change_num into l_change_num;

                            for xx in (
                                select
                                    first_name,
                                    last_name
                                from
                                    person
                                where
                                    pers_id = x.pers_id
                            ) loop
                                update bankserv_txn_staging
                                set
                                    transaction_type = 'C',
                                    transaction_id = l_change_num,
                                    acc_num = x.acc_num,
                                    contributor = 'Subscriber',
                                    first_name = xx.first_name,
                                    last_name = xx.last_name,
                                    processed = 'Y',
                                    transaction_entity = 'INCOME'
                                where
                                    record_id = x.record_id;

                            end loop;

                        else
                            update bankserv_txn_staging
                            set
                                transaction_type = 'C',
                                transaction_id = null,
                                acc_num = x.acc_num,
                                contributor = 'Subscriber',
                                error_message = 'Adjustment already processed',
                                processed = 'E'
                            where
                                record_id = x.record_id;

                        end if;

                    else
                        l_count := 0;
                        select
                            count(*)
                        into l_count
                        from
                            employer_deposits
                        where
                                entrp_id = x.entrp_id
                            and check_number in ( 'ACH'
                                                  || x.transaction_id
                                                  || '-adj', 'Bankserv'
                                                             || x.transaction_id
                                                             || '-adj' );

                        if l_count = 0 then
                            insert into employer_deposits (
                                employer_deposit_id,
                                entrp_id,
                                list_bill,
                                check_amount,
                                posted_balance,
                                remaining_balance,
                                fee_bucket_balance,
                                check_date,
                                note,
                                reason_code,
                                pay_code,
                                check_number,
                                plan_type,
                                created_by,
                                creation_date,
                                last_updated_by,
                                last_update_date
                            ) values ( employer_deposit_seq.nextval,
                                       x.entrp_id,
                                       employer_deposit_seq.currval,
                                       - x.total_amount,
                                       - x.total_amount,
                                       0,
                                       - x.fee_amount,
                                       x.return_date,
                                       'Bankserv Adjustment entry for Transaction ID:' || x.transaction_id,
                                       x.reason_code,
                                       5,
                                       'Bankserv'
                                       || x.transaction_id
                                       || '-adj',
                                       x.plan_type,
                                       p_user_id,
                                       sysdate,
                                       p_user_id,
                                       sysdate ) returning list_bill into l_list_bill;

                            if x.account_type = 'HSA' then
                                for xx in (
                                    select
                                        transaction_id,
                                        a.acc_id,
                                        acct_id,
                                        transaction_date,
                                        reason_code,
                                        employer_contrib,
                                        a.pay_code,
                                        decode(a.pay_code, 3, 'ACH'
                                                              || transaction_id
                                                              || '-adj', 'BankServ'
                                                                         || transaction_id
                                                                         || '-adj') cc_number,
                                        'Bankserv Adjustment generate ' || sysdate,
                                        employee_contrib,
                                        ee_fee_amount,
                                        er_fee_amount,
                                        total_amount,
                                        b.entrp_id,
                                        'I'
                                    from
                                        ach_emp_detail_v a,
                                        account          b
                                    where
                                            transaction_id = x.transaction_id
                                        and a.group_acc_id = b.acc_id
                                        and b.entrp_id = x.entrp_id
                                ) loop
                                    insert into income (
                                        change_num,
                                        acc_id,
                                        fee_date,
                                        fee_code,
                                        amount,
                                        pay_code,
                                        cc_number,
                                        note,
                                        amount_add,
                                        ee_fee_amount,
                                        er_fee_amount,
                                        contributor_amount,
                                        contributor,
                                        transaction_type,
                                        list_bill
                                    ) values ( change_seq.nextval,
                                               xx.acc_id,
                                               x.return_date,
                                               xx.reason_code,
                                               - nvl(xx.employer_contrib, 0),
                                               xx.pay_code,
                                               xx.cc_number,
                                               'Bankserv Adjustment generate ' || sysdate,
                                               - nvl(xx.employee_contrib, 0),
                                               - nvl(xx.ee_fee_amount, 0),
                                               - nvl(xx.er_fee_amount, 0),
                                               - nvl(xx.total_amount, 0),
                                               x.entrp_id,
                                               'I',
                                               l_list_bill );

                                end loop;

                            end if;

                            update bankserv_txn_staging
                            set
                                transaction_type = 'C',
                                transaction_id = l_list_bill,
                                acc_num = x.acc_num,
                                contributor = 'Employer',
                                employer_name = pc_entrp.get_entrp_name(x.entrp_id),
                                error_message = null,
                                processed = 'Y',
                                transaction_entity = 'EMPLOYER_DEPOSITS'
                            where
                                record_id = x.record_id;

                        else
                            update bankserv_txn_staging
                            set
                                transaction_type = 'C',
                                transaction_id = null,
                                acc_num = x.acc_num,
                                contributor = 'Employer',
                                error_message = 'Adjustment already processed',
                                processed = 'E'
                            where
                                record_id = x.record_id;

                        end if;

                    end if;

                elsif
                    x.transaction_type = 'F'
                    and x.entrp_id is not null
                then -- Insert in Employer Payments
                    l_count := 0;
                    select
                        count(*)
                    into l_count
                    from
                        employer_payments
                    where
                            entrp_id = x.entrp_id
                        and check_number in ( 'ACH'
                                              || x.transaction_id
                                              || '-adj', 'Bankserv'
                                                         || x.transaction_id
                                                         || '-adj' );

                    if l_count = 0 then
                        insert into employer_payments (
                            employer_payment_id,
                            entrp_id,
                            list_bill,
                            note,
                            reason_code,
                            transaction_date,
                            pay_code,
                            check_amount,
                            check_date,
                            check_number,
                            plan_type,
                            creation_date,
                            created_by,
                            last_updated_by,
                            last_update_date,
                            invoice_id
                        )
                            select
                                employer_payments_seq.nextval,
                                x.entrp_id,
                                employer_payments_seq.currval,
                                'Bankserv Adjustment for Transaction ID:' || x.transaction_id,
                                reason_code,
                                x.return_date,
                                5,
                                - check_amount,
                                x.return_date,
                                'Bankserv'
                                || x.transaction_id
                                || '-adj',
                                plan_type,
                                sysdate,
                                p_user_id,
                                p_user_id,
                                sysdate,
                                x.invoice_id
                            from
                                employer_payments
                            where
                                invoice_id = x.invoice_id;

                        update bankserv_txn_staging
                        set
                            transaction_type = 'F',
                            transaction_id = x.invoice_id, -- we have mant payment records created so this cannot be associated with one source
                            acc_num = x.acc_num,
                            contributor = 'Employer',
                            employer_name = pc_entrp.get_entrp_name(x.entrp_id),
                            error_message = null,
                            processed = 'Y',
                            transaction_entity = 'EMPLOYER_PAYMENTS'
                        where
                            record_id = x.record_id;

                    else
                        update bankserv_txn_staging
                        set
                            transaction_type = 'F',
                            transaction_id = null,
                            acc_num = x.acc_num,
                            contributor = 'Employer',
                            error_message = 'Adjustment already processed',
                            processed = 'E'
                        where
                            record_id = x.record_id;

                    end if;

                end if;

            end if;

        end loop;

        pc_log.log_error('PC_BANKSERV_PKG.PC_BANKSERV_TXN', 'Success :');
    end pc_bankserv_txn;

    procedure upload_bankserv_data (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) is

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
        x_batch_number := batch_num_seq.nextval;
        pc_log.log_error('PC_BANKSERV_PKG.Upload_Bankserv_data', 'pv_file_name :' || pv_file_name);
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

            l_file := utl_file.fopen('BANK_SERV_DIR', pv_file_name, 'w', 32767);
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

        l_create_ddl := 'ALTER TABLE BANKSERV_TXN_EXTERNAL ACCESS PARAMETERS ('
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
                        || '  LOCATION (BANK_SERV_DIR:'''
                        || lv_dest_file
                        || ''')';

        execute immediate l_create_ddl;

   --x_batch_number := BATCH_NUM_SEQ.NEXTVAL;

        insert into bankserv_txn_staging (
            record_id,
            company_number,
            routing_num,
            acc_number,
            check_number,
            check_date,
            return_date,
            amount,
            reference_number,
            origin,
            created_by_file,
            return_code,
            rtn,
            rtn_queue,
            status,
            cust_id,
            cust_ref_num,
            first_name,
            last_name,
            product_type,
            batch_number
        )
            select
                change_seq.nextval,
                company_number,
                routing_num,
                acc_number,
                check_number,
                check_date,
                return_date,
                amount,
                reference_number,
                origin,
                created_by,
                return_code,
                rtn,
                rtn_queue,
                status,
                cust_id,
                cust_ref_num,
                first_name,
                last_name,
                product_type,
                x_batch_number
            from
                bankserv_txn_external
            where
                company_number is not null
                and cust_ref_num is not null;

        pc_bankserv_txn(x_batch_number, p_user_id);
        pc_log.log_error('PC_BANKSERV_PKG.UPLOAD_BANKSERV_DATA', 'Success :');
    end upload_bankserv_data;

    procedure validate_data (
        p_txn_id in number,
        p_status out varchar2
    ) is
        l_status number;
    begin
        pc_log.log_error('PC_BANKSERV_PKG.Validate Data', 'In Proc:');
        p_status := 'S';
        select
            count(*)
        into l_status
        from
            ach_transfer
        where
            transaction_id = p_txn_id;

        if l_status = 0 then
            update bankserv_txn_staging
            set
                processed = 'E',
                error_column = 'Y',
                error_message = 'Customer Ref# is incorrect'
            where
                cust_ref_num = p_txn_id;

            p_status := 'E';
        end if;

        pc_log.log_error('PC_BANKSERV_PKG.Validate_Data', 'Success :');
    end validate_data;

end pc_bankserv_pkg;
/


-- sqlcl_snapshot {"hash":"d247f2c188f202382cd57ff959fd9286635915dd","type":"PACKAGE_BODY","name":"PC_BANKSERV_PKG","schemaName":"SAMQA","sxml":""}