create or replace package body samqa.process_bill_format is

    procedure export_bill_format_file (
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
        pc_log.log_error('PROCESS_BILL_FORMAT', 'In export Bill format Proc');
        x_batch_num := batch_num_seq.nextval;
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
       --lv_dest_file := pv_file_name;
        pc_log.log_error('PROCESS_BILL_FORMAT', lv_dest_file);
        select
            blob_content
        into l_blob
        from
            wwv_flow_files
        where
            name = pv_file_name;

        pc_log.log_error('PROCESS_BILL_FORMAT', 'Afetr Select');
        l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
        l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
          -- Open / Creates the destination file.

        pc_log.log_error('PROCESS_BILL_FORMAT', 'Length' || l_blob_len);

        -- Read chunks of the BLOB and write them to the file
          -- until complete.
        while l_pos < l_blob_len loop
            dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
            utl_file.put_raw(l_file, l_buffer, true);
            l_pos := l_pos + l_amount;
        end loop;

          -- Close the file.
        utl_file.fclose(l_file);
        pc_log.log_error('PROCESS_BILL_FORMAT', 'After BLOB');

          -- Delete file from wwv_flow_files
 	 --      DELETE FROM wwv_flow_files
         --  WHERE NAME = pv_file_name;

        pc_log.log_error('PROCESS_BILL_FORMAT', 'After Delete');
        if file_length(lv_dest_file, 'ENROLL_DIR') > 0 then
            begin
                pc_log.log_error('PROCESS_BILL_FORMAT', 'In Loop');
                execute immediate '
                          ALTER TABLE BILL_FORMAT_EXTERNAL
                           location (ENROLL_DIR:'''
                                  || lv_dest_file
                                  || ''')';
                pc_log.log_error('PROCESS_BILL_FORMAT', 'After alter');
            exception
                when others then
                    raise_application_error('-20001', 'Error in Changing location of QB file' || sqlerrm);
                    x_return_status := 'E';
                    x_error_message := 'Error in Changing location of QB file' || sqlerrm;
                    raise lv_create;
            end;
        end if;

        pc_log.log_error('PROCESS_BILL_FORMAT', 'Before Insert');
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

        pc_log.log_error('PROCESS_BILL_FORMAT', 'after Insert');
    exception
        when lv_create then
            rollback;
            raise_application_error('-20001', 'QB Template file seems to be corrupted, Use correct template');
            x_return_status := 'E';
            x_error_message := 'QB Template file seems to be corrupted, Use correct template';
            pc_log.log_error('PROCESS_BILL_FORMAT', 'Here');
        when others then
            raise_application_error('-20001', 'Error in export QB file' || sqlerrm);
            x_return_status := 'E';
            x_error_message := 'Error in export QB file' || sqlerrm;
            pc_log.log_error('PROCESS_BILL_FORMAT', 'Here');
            rollback;
    end export_bill_format_file;

    procedure insert_bank_det (
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
            pc_entrp.get_acc_id_from_ein(group_acc_num)        acc_id,
            contrb_type,
            sum(nvl(er_contrb, 0) + nvl(ee_contrb, 0))         contribution_amount,
            sum(nvl(ee_fee_contrb, 0) + nvl(ee_fee_contrb, 0)) fee_amount,
            sum(total_contrb_amt),
            bank_name,
            bank_routing_num,
            bank_acct_num
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
            bank_acct_num;

        cursor c1_all_fetch_bill_data is
        select
            group_acc_num,
            pc_entrp.get_acc_id_from_ein(group_acc_num)        acc_id,
            contrb_type,
            sum(nvl(er_contrb, 0) + nvl(ee_contrb, 0))         contribution_amount,
            sum(nvl(ee_fee_contrb, 0) + nvl(ee_fee_contrb, 0)) fee_amount,
            sum(total_contrb_amt),
            bank_name,
            bank_routing_num,
            bank_acct_num
        from
            bill_format_staging
        where
            batch_number = p_batch_num
        group by
            group_acc_num,
            contrb_type,
            bank_name,
            bank_routing_num,
            bank_acct_num;

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

                    pc_log.log_error('PROCESS_BILL_FORMAT', 'Bank ID' || l_bank_id);
                    pc_log.log_error('PROCESS_BILL_FORMAT', 'Acct' || c1.bank_acct_num);
                    pc_log.log_error('PROCESS_BILL_FORMAT', 'Routing' || c1.bank_routing_num);
                exception
                    when no_data_found then
                        l_bank_id := null;
                        x_return_status := 'E';
                        pc_log.log_error('PROCESS_BILL_FORMAT', 'Unable to get the Bank ID for' || c1.bank_acct_num);
                        x_error_message := 'Unable to get the Bank ID' || sqlerrm;
                        update bill_format_staging
                        set
                            error_column = 'Y',
                            error_message = 'Bank ID for this Group not Found'
                        where
                            group_acc_num = c1.group_acc_num;

                    when others then
                        l_bank_id := null;
                        x_return_status := 'E';
                        pc_log.log_error('PROCESS_BILL_FORMAT', 'Unable to get the Bank ID' || c1.bank_acct_num);
                        x_error_message := 'Unable to get the Bank ID' || sqlerrm;
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

                        pc_log.log_error('PROCESS_BILL_FORMAT',
                                         'Detail Acct' || l_acc_id_det(i));
                        if l_acc_id_status(i) = 4 then
                            l_acc_id_det(i) := null;
                            l_acc_id_num(i) := null;
                            x_return_status := 'E';
                            x_error_message := 'This Employee Account is closed';
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

                            pc_log.log_error('PROCESS_BILL_FORMAT', 'Unable to get the Acc ID for employee account for SSN' || c2.ssn
                            );
                    end;

                    i := i + 1;
                end loop; --End of C2 loop
                pc_log.log_error('PROCESS_BILL_FORMAT', 'Value of i' || i);
                i := 1;
                commit;

 --Initialise all the arrays to NULL
                pc_log.log_error('PROCESS_BILL_FORMAT', 'Initialise arrays for cnt' || l_acc_id_det.count);
                for j in 1..l_acc_id_det.count loop
                    l_acc_id_det(j) := null;
                end loop;

            end if; --End IF for Group ID
        end loop; -- End of C1 loop

/* End of pgm to mark error records */

 /* Insert only the Good records */
        for c1 in c1_fetch_bill_data loop
            if c1.group_acc_num is not null then    --For Employer Contribution
                pc_log.log_error('PROCESS_BILL_FORMAT', 'Acc_id' || c1.acc_id);
                pc_log.log_error('PROCESS_BILL_FORMAT', 'group_id' || c1.group_acc_num);
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
                        pc_log.log_error('PROCESS_BILL_FORMAT', 'Unable to get the Bank ID' || sqlerrm);
                        x_error_message := 'Unable to get the Bank ID' || sqlerrm;
                    when others then
                        l_bank_id := null;
                        x_return_status := 'E';
                        pc_log.log_error('PROCESS_BILL_FORMAT', 'Unable to get the Bank ID' || sqlerrm);
                        x_error_message := 'Unable to get the Bank ID' || sqlerrm;
                end;

                pc_log.log_error('PROCESS_BILL_FORMAT', 'Bank_id' || l_bank_id);
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
                            pc_log.log_error('PROCESS_BILL_FORMAT', 'Error in call to INS_ACH_TRANSFER' || sqlerrm);
                            x_error_message := 'Error in call to INS_ACH_TRANSFER' || sqlerrm;
                    end;
                end if; -- Do not Insert the Error Records

                pc_log.log_error('PROCESS_BILL_FORMAT', 'After 1st Insert');
                pc_log.log_error('PROCESS_BILL_FORMAT', 'Group ID' || c1.group_acc_num);
                pc_log.log_error('PROCESS_BILL_FORMAT', 'Transaction ID' || x_transaction_id);

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

                        pc_log.log_error('PROCESS_BILL_FORMAT',
                                         'Detail Acct' || l_acc_id_det(i));
                        pc_log.log_error('PROCESS_BILL_FORMAT', 'SSN' || c2.ssn);
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

                pc_log.log_error('PROCESS_BILL_FORMAT', 'Count' || i);
                begin
                    x_return_status := 'S';
                    pc_log.log_error('PROCESS_BILL_FORMAT', 'Before Insert for transaction id' || x_transaction_id);
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

                    pc_log.log_error('PROCESS_BILL_FORMAT', 'After Insert');

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
                        pc_log.log_error('PROCESS_BILL_FORMAT', 'Error in call to INS_ACH_TRANSFER_DETAILS' || sqlerrm);
                        x_error_message := 'Error in call to INS_ACH_TRANSFER_DETAILS' || sqlerrm;
                end;

                pc_log.log_error('PROCESS_BILL_FORMAT', 'After success');
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

                    pc_log.log_error('PROCESS_BILL_FORMAT', 'Detail Acct' || l_ee_acc_id);
                    if l_ee_acc_status = 4 then
                        l_ee_acc_id := null;
                        x_return_status := 'E';
                        x_error_message := 'This Employee Account is Closed';
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

                        if l_ee_bank_status = 'A' then  -- Account closed
                            l_ee_bank_id := null;
                            x_return_status := 'E';
                            x_error_message := 'This Bank Account is Closed for the employee';
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
                            x_return_status := 'E';
                            pc_log.log_error('PROCESS_BILL_FORMAT', 'Unable to get the Bank ID for employee acct' || c3.ssn);
                            x_error_message := 'Unable to get the Bank ID for employee account' || sqlerrm;
                            update bill_format_staging
                            set
                                error_column = 'Y',
                                error_message = 'Unable to get the Bank ID for employee account'
                            where
                                ssn = c3.ssn;

                        when others then
                            l_ee_bank_id := null;
                            x_return_status := 'E';
                            pc_log.log_error('PROCESS_BILL_FORMAT', 'Unable to get the Bank ID for employee acct' || c3.ssn);
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
                pc_log.log_error('PROCESS_BILL_FORMAT', 'Employee Deposit' || c3.ssn);
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

                    pc_log.log_error('PROCESS_BILL_FORMAT', 'Detail Acct' || l_ee_acc_id);
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

                        pc_log.log_error('PROCESS_BILL_FORMAT', 'Transaction ID' || x_transaction_id);
                    exception
                        when others then
                            x_return_status := 'E';
                            pc_log.log_error('PROCESS_BILL_FORMAT', 'Error in call to INS_ACH_TRANSFER for Employee Deposit' || sqlerrm
                            );
                            x_error_message := 'Error in call to INS_ACH_TRANSFER for Employee deposit' || sqlerrm;
                    end;
                end if; -- Do not Insert errorneous records

            end loop; --End of C3 loop
        end if; --End of Employee Deposit
    end insert_bank_det;

    procedure process_bill_format_execute (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) as
        l_batch_num number;
    begin
        export_bill_format_file(pv_file_name, p_user_id, x_batch_num, x_error_message, x_return_status);
        l_batch_num := x_batch_num;
        insert_bank_det(l_batch_num, p_user_id, x_error_message, x_return_status);
        pc_log.log_error('PROCESS_BILL_FORMAT', 'Batch Num' || x_batch_num);
    end process_bill_format_execute;

end process_bill_format;
/


-- sqlcl_snapshot {"hash":"32f97a7383a37d91006e10f80f2fb3cdf0b8cb6d","type":"PACKAGE_BODY","name":"PROCESS_BILL_FORMAT","schemaName":"SAMQA","sxml":""}