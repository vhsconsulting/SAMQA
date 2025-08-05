-- liquibase formatted sql
-- changeset SAMQA:1754373957445 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_ach_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_ach_upload.sql:null:677dd0bef7f9e38070cbf7a3c7f0a38739150fdd:create

create or replace package body samqa.pc_ach_upload as

    procedure process_ach_upload (
        p_batch_num     in number,
        p_user_id       in number,
        p_source        in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    ) is
        l_batch_number number;
    begin
        x_return_status := 'S';
        derive_values_for_ach_upload(
            p_batch_num => p_batch_num,
            p_user_id   => p_user_id,
            p_source    => p_source
        );
        validate_ach_upload(
            p_batch_num => p_batch_num,
            p_user_id   => p_user_id,
            p_source    => p_source
        );
        if p_source = 'ONLINE' then
            for x in (
                select
                    count(*) cnt
                from
                    ach_upload_staging
                where
                        batch_number = p_batch_num
                    and process_status = 'E'
            ) loop
                if x.cnt > 0 then
                    x_return_status := 'E';
                end if;
            end loop;
        end if;

        if p_source in ( 'SAM', 'FTP' ) then
            insert_ach_upload(
                p_batch_num     => p_batch_num,
                p_user_id       => p_user_id,
                x_return_status => x_return_status,
                x_error_message => x_error_message
            );
        end if;

    end process_ach_upload;

    procedure derive_values_for_ach_upload (
        p_batch_num in number,
        p_user_id   in number,
        p_source    in varchar2
    ) is
        l_bank_acct_id  number;
        l_return_status varchar2(255) := 'S';
        l_error_message varchar2(3200);
    begin
         -- Deriving all ER Values
         -- Because different modes of getting the feeds
         -- I added all different possible er information
         -- and derived them too
           -- htp.p('derive_values_for_ach_upload');
        update ach_upload_staging
        set
            entrp_id = pc_entrp.get_acc_id_from_ein(ein, account_type),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            ein is not null
            and entrp_id is null
            and batch_number = p_batch_num;

        update ach_upload_staging
        set
            entrp_id = pc_entrp.get_entrp_id(er_acc_num),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            ein is null
            and er_acc_num is not null
            and entrp_id is null
            and batch_number = p_batch_num;

        update ach_upload_staging
        set
            er_acc_id = pc_entrp.get_acc_id(entrp_id),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            entrp_id is not null
            and er_acc_id is null
            and batch_number = p_batch_num;

        update ach_upload_staging
        set
            er_acc_num = pc_account.get_acc_num(er_acc_id),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            er_acc_id is null
            and batch_number = p_batch_num;

        -- Deriving all account holder values
        for x in (
            select
                a.ssn,
                b.acc_id
            from
                ach_upload_staging a,
                account            b,
                person             c
            where
                    c.ssn = format_ssn(a.ssn)
                and batch_number = p_batch_num
                and b.pers_id = c.pers_id
                and c.entrp_id = a.entrp_id
                and a.ssn is not null
                and a.entrp_id is not null
                and a.acc_id is null
                and b.account_status <> 4
        ) loop
            update ach_upload_staging
            set
                acc_id = x.acc_id,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                ssn is not null
                and ssn = x.ssn
                and entrp_id is not null
                and acc_id is null
                and batch_number = p_batch_num;

        end loop;

        update ach_upload_staging
        set
            acc_id = pc_account.get_acc_id_from_ssn(ssn, entrp_id),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            ssn is not null
            and entrp_id is not null
            and acc_id is null
            and batch_number = p_batch_num;

        update ach_upload_staging
        set
            acc_id = pc_account.get_acc_id(acc_num),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            acc_num is not null
            and batch_number = p_batch_num;

        update ach_upload_staging
        set
            acc_num = pc_account.get_acc_num_from_acc_id(acc_id),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            acc_id is not null
            and acc_num is null
            and batch_number = p_batch_num;

         -- Derive Reason Code
         -- Derive Reason Code
        update ach_upload_staging
        set
            reason_code = (
                select
                    fee_code
                from
                    fee_names
                where
                    upper(fee_name) = upper(rtrim(ltrim(contribution_reason)))
            ),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            contribution_reason is not null
            and reason_code is null
            and upper(replace(contribution_reason, ' ')) not in ( 'SETUPFEE', 'MONTHLYFEE', 'RENEWALFEE' )
            and batch_number = p_batch_num;
     -- Derive Reason Code
        update ach_upload_staging
        set
            reason_code = (
                select
                    reason_code
                from
                    pay_reason
                where
                    upper(replace(reason_name, ' ')) = upper(rtrim(ltrim(replace(contribution_reason, ' '))))
            ),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            contribution_reason is not null
            and reason_code is null
            and upper(replace(contribution_reason, ' ')) in ( 'SETUPFEE', 'MONTHLYFEE', 'RENEWALFEE' )
            and batch_number = p_batch_num;

         -- Derive bank account
        update ach_upload_staging
        set
            bank_acct_id = pc_user_bank_acct.get_user_bank_acct_from_bank(er_acc_id, bank_acct_num, bank_routing_num, null),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            bank_acct_id is null
           --  AND   bank_name IS NOT NULL
            and bank_routing_num is not null
            and bank_acct_num is not null
            and er_acc_id is not null
            and batch_number = p_batch_num;

         -- Derive bank account for employees , trying to see if the bank is setup with employee
        update ach_upload_staging
        set
            bank_acct_id = pc_user_bank_acct.get_user_bank_acct_from_bank(acc_id, bank_acct_num, bank_routing_num, null),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            bank_acct_id is null
            and bank_name is not null
            and bank_routing_num is not null
            and bank_acct_num is not null
            and acc_id is not null
            and batch_number = p_batch_num;

         -- Derive bank account for FTP feeds with bank_account_usage =  'BANK_DRAFT'
        update ach_upload_staging a
        set
            bank_acct_id = (
                select
                    bank_acct_id
                from
                    user_bank_acct b
                where
                        b.acc_id = a.er_acc_id
                    and b.bank_account_usage in ( 'BANK_DRAFT', 'OFFICE' )
                    and status = 'A'
            ),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            bank_acct_id is null
            and bank_name is null
            and bank_routing_num is null
            and bank_acct_num is null
            and source in ( 'SAM', 'FTP' )
            and batch_number = p_batch_num;

        update ach_upload_staging a
        set
            reason_code = 4 -- defaulting to regular contribution
            ,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            reason_code is null
             --AND   source = 'FTP'
            and batch_number = p_batch_num;
         --   htp.p(' end derive_values_for_ach_upload');

        for x in (
            select
                ach_upload_id,
                source,
                bank_name,
                bank_acct_num,
                bank_routing_num,
                acc_id,
                acc_num,
                er_acc_id,
                er_acc_num
            from
                ach_upload_staging
            where
                bank_acct_id is null
                and ( acc_id is not null )
                and er_acc_num is null
                and er_acc_id is null
                and batch_number = p_batch_num
        ) loop
            l_bank_acct_id := null;
            pc_user_bank_acct.insert_user_bank_acct(
                p_acc_num          => x.acc_num,
                p_display_name     => x.bank_name,
                p_bank_acct_type   => 'C',
                p_bank_routing_num => x.bank_routing_num,
                p_bank_acct_num    => x.bank_acct_num,
                p_bank_name        => x.bank_name,
                p_user_id          => p_user_id,
                x_bank_acct_id     => l_bank_acct_id,
                x_return_status    => l_return_status,
                x_error_message    => l_error_message
            );

            if
                l_return_status = 'S'
                and l_bank_acct_id is not null
            then
                update ach_upload_staging
                set
                    bank_acct_id = l_bank_acct_id
                where
                    ach_upload_id = x.ach_upload_id;

                update user_bank_acct
                set
                    bank_account_usage = 'IN_OFFICE'
                where
                    bank_acct_id = l_bank_acct_id;

            end if;

        end loop;

        update ach_upload_staging
        set
            er_amount = replace(
                replace(er_amount,
                        chr(13)),
                ' ',
                ''
            ),
            ee_amount = replace(
                replace(ee_amount,
                        chr(13)),
                ' ',
                ''
            ),
            ee_fee_amount = replace(
                replace(ee_fee_amount,
                        chr(13)),
                ' ',
                ''
            ),
            er_fee_amount = replace(
                replace(er_fee_amount,
                        chr(13)),
                ' ',
                ''
            ),
            total_amount = replace(
                replace(total_amount,
                        chr(13)),
                ' ',
                ''
            ),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            batch_number = p_batch_num;

        update ach_upload_staging
        set
            source = p_source
        where
            source is null;

        commit;
    end;

    procedure validate_ach_upload (
        p_batch_num in number,
        p_user_id   in number,
        p_source    in varchar2
    ) is
        l_sqlerrm varchar2(3200);
    begin
          --  htp.p('validate_ach_upload');
        for x in (
            select
                b.account_status,
                b.complete_flag,
                a.ach_upload_id,
                b.account_type,
                a.plan_type
            from
                ach_upload_staging a,
                account            b
            where
                    a.batch_number = p_batch_num
                and a.acc_id = b.acc_id
                and ( b.account_status = 4
                      or b.complete_flag = 0 )
        ) loop
            update ach_upload_staging
            set
                process_status =
                    case
                        when x.account_status = 4
                             and source = 'ONLINE' then
                            'E'
                        when x.account_type in ( 'HRA', 'FSA' )
                             and x.plan_type is null then
                            'E'
                        when source = 'ONLINE'
                             and x.complete_flag = 0 then
                            'E'
                        when source = 'ONLINE'
                             and first_name is null
                             and last_name is null
                             and ssn is null
                             and acc_num is null then
                            'E'
                        when source = 'ONLINE'
                             and ssn is not null
                             and acc_num is null then
                            'E'
                        else
                            null
                    end,
                error_column =
                    case
                        when x.account_status = 4
                             and source = 'ONLINE' then
                            'SSN'
                        when x.account_type in ( 'HRA', 'FSA' )
                             and x.plan_type is null then
                            'PLAN_TYPE'
                        when source = 'ONLINE'
                             and x.complete_flag = 0 then
                            'SSN'
                        when source = 'ONLINE'
                             and first_name is null
                             and last_name is null
                             and ssn is null
                             and acc_num is null then
                            'SSN'
                        when source = 'ONLINE'
                             and ssn is not null
                             and acc_num is null then
                            'SSN'
                        else
                            null
                    end,
                error_message =
                    case
                        when x.account_status = 4
                             and source = 'ONLINE' then
                            'Account is Closed'
                        when x.complete_flag = 0
                             and source = 'ONLINE' then
                            'Account is Incomplete'
                        when x.account_type in ( 'HRA', 'FSA' )
                             and x.plan_type is null then
                            'Plan type cannot be null'
                        when source = 'ONLINE'
                             and first_name is null
                             and last_name is null
                             and ssn is null
                             and acc_num is null then
                            'Enter Valid Account Number, Blank rows are not allowed'
                        when source = 'ONLINE'
                             and ssn is not null
                             and acc_num is null then
                            'Enter Valid Account Number, Blank rows are not allowed'
                    end,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    ach_upload_id = x.ach_upload_id
                and batch_number = p_batch_num;

        end loop;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'ACC_NUM',
            error_message = 'Account Number or SSN must be specified',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            acc_num is null
            and ssn is null
            and entrp_id is null
            and batch_number = p_batch_num;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'BANK_ACCT_ID',
            error_message = 'Enter valid value for Bank Account',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            bank_acct_id is null
            and bank_name is null
            and bank_routing_num is null
            and bank_acct_num is null
            and source = 'FTP'
            and batch_number = p_batch_num;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'BANK_ACCT_ID',
            error_message = 'Unable to Derive bank account',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            bank_acct_id is null
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'BANK_ACCT_ID',
            error_message = 'Bank is Inactive',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            bank_acct_id is not null
            and batch_number = p_batch_num
            and pc_user_bank_acct.get_bank_acct_status(bank_acct_id) = 'I'
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'ACC_NUM',
            error_message = 'Cannot Schedule Contribution because Employee Account is Closed',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            acc_id is null
            and ( acc_num is not null
                  or ssn is null )
            and batch_number = p_batch_num
            and pc_account.get_account_status(acc_id) = 4
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'ACC_NUM',
            error_message = 'Cannot find matching Account information for the Employee',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            acc_id is null
            and ( acc_num is not null
                  or ssn is not null )
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'ER_ACC_NUM',
            error_message = 'Cannot find matching Account information for the Employer ',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            er_acc_id is null
            and er_acc_num is not null
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'ACC_NUM',
            error_message = 'Catch Up Contribution Only Available for Participants 55 or Older',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                reason_code = 6
            and batch_number = p_batch_num
            and exists (
                select
                    *
                from
                    person
                where
                        replace(ssn, '-') = ach_upload_staging.ssn
                    and round(months_between(sysdate, person.birth_date) / 12) < 55
            )
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'TRANSACTION_DATE',
            error_message = 'Invalid Transaction Date ',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                is_date(transaction_date, 'MM/DD/YYYY') = 'N'
            and batch_number = p_batch_num
            and process_status is null;

        /*    UPDATE ach_upload_staging
            SET    process_status = 'E'
              ,    error_column   = 'TRANSACTION_DATE'
              ,    error_message  = 'Transaction Date Cannot be Backdated'
              ,   last_updated_by = p_user_id
              ,   last_update_date = SYSDATE
           --Modified for 4918. This validation failes for contributions created on same day. Hence added TRUNC
            WHERE  TO_DATE(transaction_date,'MM/DD/YYYY') <  TRUNC(SYSDATE)
             AND   batch_number = p_batch_num
             AND   process_status IS NULL;*/

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'ER_AMOUNT',
            error_message = 'Invalid Employer Contribution',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                is_number(er_amount) = 'N'
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'EE_AMOUNT',
            error_message = 'Invalid Employee Contribution',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                is_number(er_amount) = 'N'
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'EE_FEE_AMOUNT',
            error_message = 'Invalid Employee Fee',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                is_number(ee_fee_amount) = 'N'
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'ER_FEE_AMOUNT',
            error_message = 'Invalid Employer Fee',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                is_number(er_fee_amount) = 'N'
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'TOTAL_AMOUNT',
            error_message = 'Invalid Total Amount',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                is_number(total_amount) = 'N'
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'TOTAL_AMOUNT',
            error_message = 'Contributions do not Add up to Total',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                total_amount <> nvl(ee_amount, 0) + nvl(er_amount, 0) + nvl(ee_fee_amount, 0) + nvl(er_fee_amount, 0)
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging
        set
            process_status = 'E',
            error_column = 'TOTAL_AMOUNT',
            error_message = 'Contribution Amounts cannot be negative',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            ( nvl(ee_amount, 0) < 0
              or nvl(er_amount, 0) < 0
              or nvl(ee_fee_amount, 0) < 0
              or nvl(er_fee_amount, 0) < 0 )
            and batch_number = p_batch_num
            and process_status is null;

        update ach_upload_staging a
        set
            process_status = 'E',
            error_column = 'TOTAL_AMOUNT',
            error_message = 'There is already ACH transaction scheduled for amount '
                            || total_amount
                            || ' and for date '
                            || transaction_date,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            exists (
                select
                    *
                from
                    ach_transfer
                where
                        ach_transfer.acc_id = a.acc_id
                    and trunc(ach_transfer.transaction_date) = trunc(
                        case
                            when is_date(a.transaction_date, 'MM/DD/YYYY') = 'Y' then
                                to_date(a.transaction_date,
      'MM/DD/YYYY')
                            when is_date(a.transaction_date, 'MMDDYYYY') = 'Y' then
                                to_date(a.transaction_date,
      'MMDDYYYY')
                        end
                    )
                    and ach_transfer.total_amount = a.total_amount
            )
            and batch_number = p_batch_num
            and source = 'SAM'
            and process_status is null;

        update ach_upload_staging a
        set
            process_status = 'E',
            error_column = 'TOTAL_AMOUNT',
            error_message = 'There is already ACH transaction scheduled for amount '
                            || total_amount
                            || ' and for date '
                            || transaction_date,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            exists (
                select
                    *
                from
                    ach_transfer
                where
                        ach_transfer.acc_id = a.er_acc_id
                    and trunc(ach_transfer.transaction_date) = trunc(
                        case
                            when is_date(a.transaction_date, 'MM/DD/YYYY') = 'Y' then
                                to_date(a.transaction_date,
      'MM/DD/YYYY')
                            when is_date(a.transaction_date, 'MMDDYYYY') = 'Y' then
                                to_date(a.transaction_date,
      'MMDDYYYY')
                        end
                    )
                    and ach_transfer.total_amount = a.total_amount
            )
            and batch_number = p_batch_num
            and source = 'SAM'
            and process_status is null;

    exception
        when others then
            l_sqlerrm := sqlerrm;
            update ach_upload_staging
            set
                process_status = 'E',
                error_message = l_sqlerrm,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    batch_number = p_batch_num
                and process_status is null;

    end validate_ach_upload;

    procedure insert_ach_upload (
        p_batch_num     in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_transaction_id number;
    begin
        x_return_status := 'S';
             -- Scheduling Employer account
        for x in (
            select
                er_acc_id,
                bank_acct_id,
                sum(nvl(to_number(ee_amount), 0) + nvl(to_number(er_amount), 0))         amount,
                sum(nvl(to_number(ee_fee_amount), 0) + nvl(to_number(er_fee_amount), 0)) fee_amount,
                reason_code,
                decode(source, 'ONLINE', 5, 3)                                           pay_code,
                trunc(
                    case
                        when
                            is_date(transaction_date, 'MM/DD/YYYY') = 'Y'
                            and to_date(transaction_date,
                      'MM/DD/YYYY') > sysdate
                        then
                            to_date(transaction_date,
                      'MM/DD/YYYY')
                        when
                            is_date(transaction_date, 'MMDDYYYY') = 'Y'
                            and to_date(transaction_date,
                      'MMDDYYYY') > sysdate
                        then
                            to_date(transaction_date,
                      'MMDDYYYY')
                        else sysdate + 1
                    end
                )                                                                        transaction_date,
                plan_type,
                case
                    when upper(replace(contribution_reason, ' ')) in ( 'SETUPFEE', 'MONTHLYFEE', 'RENEWALFEE' ) then
                        'F'
                    else
                        'C'
                end                                                                      transaction_type,
                invoice_id
            from
                ach_upload_staging
            where
                process_status is null
                and er_acc_id is not null
                and acc_id is null
                and batch_number = p_batch_num
            group by
                er_acc_id,
                bank_acct_id,
                reason_code,
                pay_code,
                transaction_date,
                source,
                plan_type,
                upper(replace(contribution_reason, ' ')),
                invoice_id
        ) loop
            x_return_status := 'S';
            pc_ach_transfer.ins_ach_transfer(
                p_acc_id           => x.er_acc_id,
                p_bank_acct_id     => x.bank_acct_id,
                p_transaction_type => x.transaction_type,
                p_amount           => x.amount,
                p_fee_amount       => x.fee_amount,
                p_transaction_date => x.transaction_date,
                p_reason_code      => x.reason_code,
                p_status           => 2 -- Pending
                ,
                p_user_id          => p_user_id,
                p_pay_code         => x.pay_code,
                x_transaction_id   => l_transaction_id,
                x_return_status    => x_return_status,
                x_error_message    => x_error_message
            );

            if x_return_status <> 'S' then
                update ach_upload_staging
                set
                    process_status = 'E',
                    error_message = 'Error in Scheduling ACH ' || x_error_message,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        er_acc_id = x.er_acc_id
                    and batch_number = p_batch_num
                    and process_status is null;

            else
                update ach_upload_staging
                set
                    transaction_id = l_transaction_id,
                    process_status = 'S',
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        er_acc_id = x.er_acc_id
                    and batch_number = p_batch_num
                    and process_status is null;

                update ach_transfer
                set
                    plan_type = x.plan_type,
                    invoice_id = x.invoice_id
                where
                    transaction_id = l_transaction_id;

            end if;

        end loop;

        for x in (
            select
                er_acc_id,
                bank_acct_id,
                sum(nvl(to_number(ee_amount), 0) + nvl(to_number(er_amount), 0))         amount,
                sum(nvl(to_number(ee_fee_amount), 0) + nvl(to_number(er_fee_amount), 0)) fee_amount,
                reason_code,
                decode(source, 'ONLINE', 5, 3)                                           pay_code,
                case
                    when upper(replace(contribution_reason, ' ')) in ( 'SETUPFEE', 'MONTHLYFEE', 'RENEWALFEE' ) then
                        'F'
                    else
                        'C'
                end                                                                      transaction_type,
                trunc(
                    case
                        when
                            is_date(transaction_date, 'MM/DD/YYYY') = 'Y'
                            and to_date(transaction_date,
                      'MM/DD/YYYY') > sysdate
                        then
                            to_date(transaction_date,
                      'MM/DD/YYYY')
                        when
                            is_date(transaction_date, 'MMDDYYYY') = 'Y'
                            and to_date(transaction_date,
                      'MMDDYYYY') > sysdate
                        then
                            to_date(transaction_date,
                      'MMDDYYYY')
                        else sysdate + 1
                    end
                )                                                                        transaction_date
            from
                ach_upload_staging
            where
                process_status is null
                and er_acc_id is not null
                and acc_id is not null
                and batch_number = p_batch_num
            group by
                er_acc_id,
                bank_acct_id,
                reason_code,
                pay_code,
                transaction_date,
                source,
                upper(replace(contribution_reason, ' '))
        ) loop
            x_return_status := 'S';
            pc_ach_transfer.ins_ach_transfer(
                p_acc_id           => x.er_acc_id,
                p_bank_acct_id     => x.bank_acct_id,
                p_transaction_type => 'C',
                p_amount           => x.amount,
                p_fee_amount       => x.fee_amount,
                p_transaction_date => x.transaction_date,
                p_reason_code      => x.reason_code,
                p_status           => 2 -- Pending
                ,
                p_user_id          => p_user_id,
                p_pay_code         => x.pay_code,
                x_transaction_id   => l_transaction_id,
                x_return_status    => x_return_status,
                x_error_message    => x_error_message
            );

            if x_return_status <> 'S' then
                update ach_upload_staging
                set
                    process_status = 'E',
                    error_message = 'Error in Scheduling ACH ' || x_error_message,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        er_acc_id = x.er_acc_id
                    and batch_number = p_batch_num
                    and process_status is null;

            else
                update ach_upload_staging
                set
                    transaction_id = l_transaction_id,
                    process_status = 'S',
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        er_acc_id = x.er_acc_id
                    and batch_number = p_batch_num
                    and process_status is null;

            end if;

            insert into ach_transfer_details (
                xfer_detail_id,
                transaction_id,
                group_acc_id,
                acc_id,
                ee_amount,
                er_amount,
                ee_fee_amount,
                er_fee_amount,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date
            )
                select
                    ach_transfer_details_seq.nextval,
                    l_transaction_id,
                    er_acc_id,
                    acc_id,
                    to_number(ee_amount),
                    to_number(er_amount),
                    to_number(ee_fee_amount),
                    to_number(er_fee_amount),
                    last_updated_by,
                    created_by,
                    sysdate,
                    sysdate
                from
                    ach_upload_staging
                where
                        transaction_id = l_transaction_id
                    and er_acc_id = x.er_acc_id
                    and batch_number = p_batch_num
                    and acc_id is not null
                    and process_status = 'S';

        end loop;
             -- Scheduling Employee account
        for x in (
            select
                acc_id,
                bank_acct_id,
                sum(nvl(to_number(ee_amount), 0) + nvl(to_number(er_amount), 0))         amount,
                sum(nvl(to_number(ee_fee_amount), 0) + nvl(to_number(er_fee_amount), 0)) fee_amount,
                reason_code,
                pay_code,
                case
                    when upper(replace(contribution_reason, ' ')) in ( 'SETUPFEE', 'MONTHLYFEE', 'RENEWALFEE' ) then
                        'F'
                    else
                        'C'
                end                                                                      transaction_type,
                trunc(
                    case
                        when is_date(transaction_date, 'MM/DD/YYYY') = 'Y' then
                            to_date(transaction_date,
                      'MM/DD/YYYY')
                        when is_date(transaction_date, 'MMDDYYYY') = 'Y' then
                            to_date(transaction_date,
                      'MMDDYYYY')
                        else sysdate
                    end
                )                                                                        transaction_date
            from
                ach_upload_staging
            where
                process_status is null
                and acc_id is not null
                and er_acc_id is null
                and batch_number = p_batch_num
            group by
                acc_id,
                bank_acct_id,
                reason_code,
                pay_code,
                transaction_date,
                upper(replace(contribution_reason, ' '))
        ) loop
            x_return_status := 'S';
            pc_ach_transfer.ins_ach_transfer(
                p_acc_id           => x.acc_id,
                p_bank_acct_id     => x.bank_acct_id,
                p_transaction_type => 'C',
                p_amount           => x.amount,
                p_fee_amount       => x.fee_amount,
                p_transaction_date => x.transaction_date,
                p_reason_code      => x.reason_code,
                p_status           => 2 -- Pending
                ,
                p_user_id          => p_user_id,
                p_pay_code         => x.pay_code,
                x_transaction_id   => l_transaction_id,
                x_return_status    => x_return_status,
                x_error_message    => x_error_message
            );

            if x_return_status <> 'S' then
                update ach_upload_staging
                set
                    process_status = 'E',
                    error_message = 'Error in Scheduling ACH ' || x_error_message,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        acc_id = x.acc_id
                    and batch_number = p_batch_num
                    and process_status is null;

            else
                update ach_upload_staging
                set
                    transaction_id = l_transaction_id,
                    last_updated_by = p_user_id,
                    last_update_date = sysdate,
                    process_status = 'S'
                where
                        acc_id = x.acc_id
                    and batch_number = p_batch_num
                    and process_status is null;

            end if;

        end loop;

    exception
        when others then
            rollback;
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_ach_upload;

    procedure export_ach_upload_file (
        pv_file_name    in varchar2,
        p_user_id       in number,
        p_source        in varchar2 default 'SAM',
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
        pc_log.log_error('PC_ACH_UPLOAD.export_ach_upload_file,p_source', p_source);
        if p_source = 'SAM' then
            lv_dest_file := substr(pv_file_name,
                                   instr(pv_file_name, '/', 1) + 1,
                                   length(pv_file_name) - instr(pv_file_name, '/', 1));
               --lv_dest_file := pv_file_name;
            dbms_output.put_line(lv_dest_file);
            pc_log.log_error('PC_ACH_UPLOAD.export_ach_upload_file, lv_dest_file', lv_dest_file);
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            l_file := utl_file.fopen('BANK_SERV_DIR', lv_dest_file, 'w', 32767);
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

        else
            lv_dest_file := pv_file_name;
        end if;

        if file_length(lv_dest_file, 'BANK_SERV_DIR') > 0 then
            begin
                dbms_output.put_line('In Loop');
                execute immediate '
                                  ALTER TABLE ACH_UPLOAD_EXTERNAL
                                   location (BANK_SERV_DIR:'''
                                  || lv_dest_file
                                  || ''')';
                dbms_output.put_line('After alter');
            exception
                when others then
                    x_return_status := 'E';
                    x_error_message := 'Error in Changing location of Bank Serv file' || sqlerrm;
                    raise lv_create;
            end;
        else
                     -- Added by Joshi. if file is not found in folder. raise error.
            x_return_status := 'E';
            x_error_message := 'The file is not found in the direcorry';
            raise lv_create;
        end if;

        dbms_output.put_line('Before Insert');
        x_error_message := 'Before Insert';
        insert into ach_upload_staging (
            ach_upload_id,
            tpa_id,
            group_name,
            ein,
            er_acc_num,
            first_name,
            last_name,
            ssn,
            contribution_reason,
            er_amount,
            ee_amount,
            er_fee_amount,
            ee_fee_amount,
            total_amount,
            bank_name,
            bank_routing_num,
            bank_acct_num,
            account_type,
            transaction_date,
            pay_code,
            batch_number,
            acc_num,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            source,
            plan_type,
            invoice_id,
            note
        )
            select
                ach_upload_staging_seq.nextval,
                tpa_id,
                group_name,
                decode(
                    substr(group_id, 1, 1),
                    'G',
                    null,
                    group_id
                ),
                decode(
                    substr(group_id, 1, 1),
                    'G',
                    group_id,
                    null
                ),
                first_name,
                last_name,
                ssn,
                contribution_reason,
                er_amount,
                ee_amount,
                er_fee_amount,
                ee_fee_amount,
                nvl(total_amount,
                    nvl(er_amount, 0) + nvl(ee_amount, 0) + nvl(ee_fee_amount, 0) + nvl(er_fee_amount, 0)),
                bank_name,
                bank_routing_num,
                bank_acct_num,
                account_type,
                nvl(transaction_date,
                    to_char(sysdate + 1, 'MM/DD/RRRR')),
                decode(pay_code, 'Bank Draft', 3, 5),
                x_batch_num,
                acc_num,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                p_source,
                plan_type,
                invoice_id,
                note
            from
                ach_upload_external;

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
            raise_application_error('-20001', 'Error in export of ACH upload file' || sqlerrm);
            x_return_status := 'E';
            x_error_message := 'Error in export ACH file' || sqlerrm;
            dbms_output.put_line('Here');
            rollback;
    end export_ach_upload_file;

    procedure process_ftp_listbill (
        p_file_name     in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_batch_num number;
    begin
        pc_log.log_error('PC_ACH_UPLOAD', 'p_file_name ' || p_file_name);
        x_return_status := 'S';
         -- :P_batch_num := dbms_random.value;
        if
            p_file_name is not null
            and p_file_name like '%csv'
        then
             --htp.p(:P_batch_num);
            pc_log.log_error('PC_ACH_UPLOAD', 'export_ach_upload_file ' || p_file_name);
            pc_ach_upload.export_ach_upload_file(
                pv_file_name    => p_file_name,
                p_user_id       => 0,
                p_source        => 'FTP',
                x_batch_num     => l_batch_num,
                x_error_message => x_error_message,
                x_return_status => x_return_status
            );

            pc_log.log_error('PC_ACH_UPLOAD', 'x_error_message ' || x_error_message);
            if
                l_batch_num is not null
                and x_return_status = 'S'
            then
                pc_ach_upload.process_ach_upload(
                    p_batch_num     => l_batch_num,
                    p_user_id       => get_user_id(v('app_user')),
                    p_source        => 'FTP',
                    x_error_message => x_error_message,
                    x_return_status => x_return_status
                );
            end if;

        else
            x_error_message := 'We can process only .csv file ';
            x_return_status := 'E';
        end if;

    exception
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'E';
    end process_ftp_listbill;

end pc_ach_upload;
/

