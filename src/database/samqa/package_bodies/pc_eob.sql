create or replace package body samqa.pc_eob as

    procedure insert_eob_header (
        p_eob_id         in varchar2,
        p_claim_number   in varchar2,
        p_provider_id    in number,
        p_description    in varchar2,
        p_service_start  in varchar2,
        p_service_end    in varchar2,
        p_service_amount in number,
        p_amount_due     in number,
        p_modified       in varchar2,
        p_source         in varchar2,
        p_acc_id         in number,
        p_user_id        in number
    ) is
        l_eob_count number := 0;
    begin
        pc_log.log_error('insert_eob_header', 'start eob_id ' || p_eob_id);
        select
            count(*)
        into l_eob_count
        from
            eob_header
        where
            eob_id = p_eob_id;

        if l_eob_count = 0 then
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
                acc_id,
                source,
                creation_date,
                last_update_date,
                last_updated_by,
                created_by
            ) values ( p_eob_id,
                       p_user_id,
                       p_claim_number,
                       p_provider_id,
                       p_description,
                       to_date(p_service_start, 'MM/DD/RRRR'),
                       to_date(p_service_end, 'MM/DD/RRRR'),
                       p_service_amount,
                       p_amount_due,
                       'New',
                       'NEW',
                       p_modified,
                       p_acc_id,
                       p_source,
                       sysdate,
                       sysdate,
                       p_user_id,
                       p_user_id );

        end if;

    exception
        when others then
            pc_log.log_error('insert_eob_header', 'Error message :' || sqlerrm);
    end insert_eob_header;

    procedure insert_eob_detail (
        p_eob_id         in varchar2,
        p_eob_detail_id  in pc_online_enrollment.varchar2_tbl,
        p_service_start  in pc_online_enrollment.varchar2_tbl,
        p_service_end    in pc_online_enrollment.varchar2_tbl,
        p_description    in pc_online_enrollment.varchar2_tbl,
        p_medical_code   in pc_online_enrollment.varchar2_tbl,
        p_amount_charged in pc_online_enrollment.varchar2_tbl,
        p_ins_amount     in pc_online_enrollment.varchar2_tbl,
        p_final_amount   in pc_online_enrollment.varchar2_tbl,
        p_source         in varchar2,
        p_modified       in pc_online_enrollment.varchar2_tbl,
        p_user_id        in number
    ) is

        e_forall_error exception;
        pragma exception_init ( e_forall_error, -24381 );
        l_eob_detail_id  pc_online_enrollment.varchar2_tbl;
        l_service_start  pc_online_enrollment.varchar2_tbl;
        l_service_end    pc_online_enrollment.varchar2_tbl;
        l_description    pc_online_enrollment.varchar2_tbl;
        l_medical_code   pc_online_enrollment.varchar2_tbl;
        l_amount_charged pc_online_enrollment.varchar2_tbl;
        l_ins_amount     pc_online_enrollment.varchar2_tbl;
        l_final_amount   pc_online_enrollment.varchar2_tbl;
        l_modified       pc_online_enrollment.varchar2_tbl;
    begin
        pc_log.log_error('insert_eob_detail', 'start eob_id ' || p_eob_id);
        pc_log.log_error('insert_eob_detail', 'p_eob_detail_id.count ' || p_eob_detail_id.count);
        l_eob_detail_id := pc_online_enrollment.array_fill(p_eob_detail_id, p_eob_detail_id.count);
        l_service_start := pc_online_enrollment.array_fill(p_service_start, p_eob_detail_id.count);
        l_service_end := pc_online_enrollment.array_fill(p_service_end, p_eob_detail_id.count);
        l_description := pc_online_enrollment.array_fill(p_description, p_eob_detail_id.count);
        l_medical_code := pc_online_enrollment.array_fill(p_medical_code, p_eob_detail_id.count);
        l_amount_charged := pc_online_enrollment.array_fill(p_amount_charged, p_eob_detail_id.count);
        l_ins_amount := pc_online_enrollment.array_fill(p_ins_amount, p_eob_detail_id.count);
        l_final_amount := pc_online_enrollment.array_fill(p_final_amount, p_eob_detail_id.count);
        l_modified := pc_online_enrollment.array_fill(p_modified, p_eob_detail_id.count);
        for i in 1..l_eob_detail_id.count loop
            if l_eob_detail_id(i) is null then
                l_eob_detail_id.delete(i);
                l_service_start.delete(i);
                l_service_end.delete(i);
                l_description.delete(i);
                l_medical_code.delete(i);
                l_amount_charged.delete(i);
                l_ins_amount.delete(i);
                l_final_amount.delete(i);
                l_modified.delete(i);
            end if;
        end loop;

        delete from eob_detail
        where
            eob_id = p_eob_id;

        forall i in l_eob_detail_id.first..l_eob_detail_id.last save exceptions
            insert into eob_detail (
                eob_id,
                eob_detail_id,
                service_date_from,
                service_date_to,
                description,
                medical_code,
                amount_charged,
                ins_paid_amount,
                final_patient_amount,
                modified,
                source,
                creation_date,
                last_update_date,
                last_updated_by,
                created_by
            ) values ( p_eob_id,
                       l_eob_detail_id(i),
                       to_date(l_service_start(i),
                               'MM/DD/RRRR'),
                       to_date(l_service_end(i),
                               'MM/DD/RRRR'),
                       l_description(i),
                       l_medical_code(i),
                       l_amount_charged(i),
                       l_ins_amount(i),
                       l_final_amount(i),
                       l_modified(i),
                       p_source,
                       sysdate,
                       sysdate,
                       p_user_id,
                       p_user_id );

    exception
        when e_forall_error then
            for i in 1..sql%bulk_exceptions.count loop
                pc_log.log_error('insert_eob_detail',
                                 'SQLCODE:'
                                 || sql%bulk_exceptions(i).error_code);

                pc_log.log_error('insert_eob_detail',
                                 'SQLERRM:'
                                 || sqlerrm(-sql%bulk_exceptions(i).error_code));

            end loop;
        when others then
            pc_log.log_error('insert_eob_header', 'Error message :' || sqlerrm);
    end insert_eob_detail;

    procedure insert_vendor_from_eob (
        p_provider_id   in number,
        p_acc_id        in number,
        p_payee_type    in varchar2,
        p_payee_acc_num in varchar2,
        p_user_id       in number,
        x_vendor_id     out number
    ) is
    begin
        x_vendor_id := vendor_seq.nextval;
        pc_log.log_error('insert_vendor_from_eob', 'Start if insert_vendor_from_eob');
        pc_log.log_error('insert_vendor_from_eob', 'p_provider_id ' || p_provider_id);
        insert into vendors (
            vendor_id,
            orig_sys_vendor_ref,
            vendor_name,
            address1,
            address2,
            city,
            state,
            zip,
            expense_account,
            acc_num,
            vendor_in_peachtree,
            vendor_acc_num,
            acc_id,
            vendor_tax_id,
            vendor_type,
            vendor_status,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                x_vendor_id,
                eob_provider_id,
                provider_name -- Payee Name
                ,
                address1       -- Payee Address
                ,
                address2,
                city             -- Payee City
                ,
                state            -- Payee State
                ,
                zip              -- Payee Zip
                ,
                2400             -- Expense Account
                ,
                pc_account.get_acc_num_from_acc_id(p_acc_id),
                'N',
                p_payee_acc_num -- Payee Account Number
                ,
                p_acc_id,
                null,
                p_payee_type,
                'A',
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                eob_provider
            where
                eob_provider_id = p_provider_id;

    exception
        when others then
            pc_log.log_error('insert_vendor_from_eob', 'Error message :' || sqlerrm);
    end insert_vendor_from_eob;

    procedure update_claim_with_eob (
        p_eob_id   in varchar2,
        p_claim_id in number,
        p_user_id  in number
    ) is
    begin
        pc_log.log_error('update_claim_with_eob', 'p_eob_id ' || p_eob_id);
        pc_log.log_error('update_claim_with_eob', 'p_claim_id ' || p_claim_id);
        if p_eob_id is not null then
            for x in (
                select
                    claim_status
                from
                    claimn
                where
                    claim_id = p_claim_id
            ) loop
                pc_log.log_error('update_claim_with_eob', 'claim_status ' || x.claim_status);
                update eob_header
                set
                    claim_id = p_claim_id,
                    eob_status_code = x.claim_status,
                    eob_status = pc_lookups.get_claim_status(x.claim_status),
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                    eob_id = p_eob_id;

            end loop;

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
                attachment
            )
                select
                    file_attachments_seq.nextval,
                    document_name,
                    document_type,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    'CLAIMN',
                    to_char(p_claim_id),
                    attachment
                from
                    file_attachments
                where
                        entity_id = replace(p_eob_id, 'p', '')
                    and entity_name = 'EOB';

        end if;

        if p_claim_id is not null then
        /* UPDATE claimn
          set    claim_status =   DECODE(pc_claim.has_document(claim_id),'Y','PENDING_REVIEW','PENDING_DOC')
         WHERE  claim_id= p_claim_id AND PERS_ID IN ( SELECT PERS_ID FROM ACCOUNT WHERE ACCOUNT.PERS_ID = CLAIMN.PERS_ID AND ACCOUNT_TYPE IN ('HRA','FSA'))
         ;*/

            update claimn
            set
                claim_status = 'PENDING_REVIEW'
            where
                    claim_id = p_claim_id
                and claim_status = 'PENDING_DOC'
                and service_type is not null
                and service_type <> 'HSA';

            for x in (
                select
                    claim_id,
                    claim_status
                from
                    claimn
                where
                    claim_id = p_claim_id
            ) loop
                update eob_header
                set
                    eob_status_code = x.claim_status,
                    eob_status = pc_lookups.get_claim_status(x.claim_status),
                    last_update_date = sysdate
                where
                    claim_id = x.claim_id;

            end loop;

        end if;

    exception
        when others then
            pc_log.log_error('update_claim_with_eob', 'Error message :' || sqlerrm);
    end update_claim_with_eob;
      
      -- obsolete as health expense is no longer in business
    procedure send_file (
        x_file_name out varchar2
    ) is

        l_file_id    number;
        l_file_name  varchar2(3200);
        l_line       varchar2(32000);
        l_sqlerrm    varchar2(32000);
        l_utl_id     utl_file.file_type;
        l_file_count number := 0;
    begin
        l_file_id := pc_debit_card.insert_file_seq('HEALTH_EXPENSE');
        for x in (
            select
                count(*) cnt
            from
                hex_eob_status_v
        ) loop
            if x.cnt > 0 then
                l_file_name := 'Sterling_EOB_Status_' || to_char(sysdate, 'YYYYMMDD');
                x_file_name := l_file_name;
            end if;
        end loop;

    /** Health Expense Status
	{
	  const __default = self::Unknown;
	  const Unknown         =  1;  // Should never happen - uninitialized variable?
	  const NewEOB          =  2;  // Just got in, not yet processed
	  const InProgress      = 11;  // Processing now
	  const Open            =  5;  // Processing done, open for payment
	  const WaitingDocument = 12;  // Can't be closed until document is not sent
	  const InDispute       =  3;  // Disputing charges with insurance or provider
	  const Reimbursing     = 13;  // Reimbursement process started
	  const Paid            = 15;  // Paid by TPA
	  const UserClosedPaid  = 16;  // Closed by user: remaining balance was paid
	  const SysClosedOther  = 14;  // E.g. old EOB
	  const Obsoleted       = 17;  // Old claim made obsoleted by an adjustment
	}

       ID Displayed Description
  5 Received
New EOB, just received from the insurance
22
Paid Reimbursement was accepted and paid
23
Partially paid
Reimbursement or payment was done in part
24
Denied  FSA reimbursement request was denied
25 Denied
HSA payment was denied
26 Denied
HRA reimbursement was denied
27 Pending Contribution
Waiting for Employer to fund account
28 Pending Contribution
Waiting for you to fund the account
29 Declined
Declined due to incorrect information, can be re-tried
    **/

        if x_file_name is not null then
            update external_files
            set
                file_name = l_file_name
            where
                file_id = l_file_id;

            l_utl_id := utl_file.fopen('HEX_STATUS_DIR', l_file_name, 'w');  --testing
            for x in (
                select
                    eob_id,
                    created_by,
                    eob_status,
                    date_of_payment,
                    nvl(amount, 0) amount
                from
                    hex_eob_status_v
            ) loop
                l_file_count := l_file_count + 1;
                l_line := x.eob_id
                          || ','
                          || x.created_by
                          || ','
                          || x.eob_status
                          || ','
                          || x.date_of_payment
                          || ','
                          || x.amount;

                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_line
                );
            end loop;

            l_line := 'Sterling HSA,' || l_file_count;
            utl_file.put_line(
                file   => l_utl_id,
                buffer => l_line
            );
            utl_file.fclose(file => l_utl_id);
            if file_length(x_file_name, 'HEX_STATUS_DIR') = 0 then
                x_file_name := null;
                update external_files
                set
                    result_flag = 'Y'
                where
                    file_id = l_file_id;

            end if;

        end if;

        commit;
    exception
        when others then
            rollback;
            raise_application_error(-20030, ' File Creation Process Failed. ' || sqlerrm);
    end send_file;
      -- obsolete as health expense is no longer in business

    procedure process_hex_status (
        p_file_name     in varchar2,
        x_error_message out varchar2
    ) is

        l_sqlerrm varchar2(32000);
        l_sql     varchar2(32000);
        l_exists  varchar2(30) := 'N';
        l_create_error exception;
        l_count   number := 0;
        l_processed exception;
    begin
        if file_length(p_file_name, 'HEX_INS_DIR') > 0 then
            l_sql := l_sql
                     || 'HEX_INS_DIR:'''
                     || p_file_name
                     || ''',';
            l_exists := 'Y';
        end if;

        if l_exists = 'N' then
            null;
        else
            l_sql := 'ALTER TABLE EOB_STATUS_EXTERNAL LOCATION ('
                     || rtrim(l_sql, ',')
                     || ')';
            begin
                execute immediate l_sql;
            exception
                when others then
                    rollback;
                    x_error_message := 'Error when altering table ' || sqlerrm;
                    raise l_create_error;
            end;

        end if;

        insert into eob_status (
            user_id,
            account_id,
            action,
            carrier_name,
            carrier_id,
            user_name,
            password,
            status_id,
            status_message,
            member_id,
            created_on,
            last_updated_on,
            creation_date
        )
            select
                user_id,
                account_id,
                action,
                carrier_name,
                carrier_id,
                user_name,
                password,
                status_id,
                status_message,
                member_id,
                created_on,
                last_updated_on,
                sysdate
            from
                eob_status_external
            where
                not exists (
                    select
                        *
                    from
                        eob_status
                    where
                        user_id = eob_status_external.user_id
                );

        for x in (
            select
                user_id,
                account_id,
                action,
                carrier_name,
                carrier_id,
                user_name,
                password,
                status_id,
                status_message,
                member_id,
                created_on,
                last_updated_on
            from
                eob_status_external
            where
                exists (
                    select
                        *
                    from
                        eob_status
                    where
                        user_id = eob_status_external.user_id
                )
        ) loop
            update eob_status
            set
                account_id = x.account_id,
                action = x.action,
                carrier_name = x.carrier_name,
                carrier_id = x.carrier_id,
                user_name = x.user_name,
                password = x.password,
                status_id = x.status_id,
                status_message = x.status_message,
                member_id = x.member_id,
                created_on = x.created_on,
                last_updated_on = x.last_updated_on,
                last_update_date = sysdate
            where
                user_id = x.user_id;

        end loop;

        update_hex_status;
    exception
        when l_create_error then
            null;
        when others then
            x_error_message := sqlerrm;
    end process_hex_status;
      -- obsolete as health expense is no longer in business

    procedure update_hex_status is
    begin
        for x in (
            select
                ou.tax_id,
                ou.user_id,
                eb.carrier_name,
                eb.status_id,
                eb.user_name,
                eb.password,
                eb.member_id
            from
                eob_status   eb,
                online_users ou
            where
                    eb.user_id = ou.user_id
                and eb.last_update_date > sysdate - 1
        ) loop
            pc_insure.update_carrier_status(
                p_ssn          => x.tax_id,
                p_carrier_name => x.carrier_name,
                p_carrier_user => x.user_name,
                p_carrier_pwd  => x.password,
                p_status       => x.status_id,
                p_policy_num   => x.member_id,
                p_user_id      => x.user_id
            );
        end loop;
    end update_hex_status;

    function get_eob_number (
        p_claim_id in number
    ) return varchar2 is
        l_eob_number varchar2(255);
    begin
        for x in (
            select  ---WM_CONCAT(eob_id) eob_no -- Commented by RPRABU 0n 17/10/2017
                listagg(eob_id, ',') within group(
                order by
                    eob_id
                ) eob_no  -- Added by RPRABU 0n 17/10/2017
            from
                eob_header
            where
                claim_id = p_claim_id
        ) loop
            l_eob_number := x.eob_no;
        end loop;

        return l_eob_number;
    end get_eob_number;

end pc_eob;
/


-- sqlcl_snapshot {"hash":"145067871edd0dc4c93df6e9c469bd0c809d361f","type":"PACKAGE_BODY","name":"PC_EOB","schemaName":"SAMQA","sxml":""}