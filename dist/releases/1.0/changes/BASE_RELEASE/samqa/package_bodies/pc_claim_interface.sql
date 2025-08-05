-- liquibase formatted sql
-- changeset SAMQA:1754373982745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_claim_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_claim_interface.sql:null:031ea2161179c4c7f273aa379d60a207540b03dc:create

create or replace package body samqa.pc_claim_interface as

    procedure export_claims_file (
        pv_file_name in varchar2,
        p_user_id    in number,
        p_claim_type in varchar2 default null
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
        lv_create exception;
        l_sqlerrm    varchar2(32000);
        l_create_error exception;
        l_row_count  number := -1;
    begin
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
      --pc_log.log_error(' export claims ','lv_dest_file '||lv_dest_file);
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
        while l_pos < l_blob_len loop
            dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
            utl_file.put_raw(l_file, l_buffer, true);
            l_pos := l_pos + l_amount;
        end loop;

        utl_file.fclose(l_file);
        delete from wwv_flow_files
        where
            name = pv_file_name;
     /* IF p_claim_type = 'TAKEOVER' THEN
        null;
     else
          begin
             for x in (SELECT COUNT(*) cnt  FROM   CLAIMS_EXTERNAL)
             loop
                l_row_count := X.CNT;
             end loop;
         exception
              when others then
                 null;
         end;

         IF l_row_count = 0 THEN
            RAISE l_create_error;
         END IF;
      end if;   */
        if p_claim_type = 'TAKEOVER' then
            begin
                execute immediate '
                         ALTER TABLE CLAIMS_TAKEOVER_EXTERNAL
                          location (CLAIM_DIR:'''
                                  || lv_dest_file
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := 'Error in Changing location of Takeover Claims file' || sqlerrm;
                    raise l_create_error;
            end;
        else
            begin
                execute immediate '
                         ALTER TABLE CLAIMS_EXTERNAL
                          location (CLAIM_DIR:'''
                                  || lv_dest_file
                                  || ''')';
            exception
                when others then
                    l_sqlerrm := 'Error in Changing location of Claims file' || sqlerrm;
                    raise l_create_error;
            end;
        end if;

    exception
        when l_create_error then
            rollback;
            raise_application_error('-20001', 'Claim  file seems to be corrupted, Use correct template' || l_sqlerrm);
        when others then
            rollback;
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'Error in when others Exporting File ' || sqlerrm);
    end export_claims_file;

    procedure process_claims (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    ) is
    begin
        export_claims_file(pv_file_name, p_user_id);
        import_into_interface(p_user_id, p_batch_number);
        initialize_edi_claims(p_batch_number);
        pc_claim.import_uploaded_claims(p_user_id, p_batch_number);
        pc_claim.process_uploaded_claims(p_batch_number, p_user_id);
        for x in (
            select distinct
                er_acc_num
            from
                claim_interface
            where
                    batch_number = p_batch_number
                and er_acc_num = 'GFSA006937'
        ) loop
            reprocess_crmc_no_mem_claims;
        end loop;
   --COMMIT;
    end process_claims;

    procedure process_dep_claims (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    ) is
    begin
 --  export_claims_file(pv_file_name,p_user_id);
        import_dep_into_interface(p_user_id, p_batch_number);
        pc_claim.import_uploaded_claims(p_user_id, p_batch_number);
        pc_claim.process_uploaded_claims(p_batch_number, p_user_id);
   --COMMIT;
    end process_dep_claims;

    procedure import_dep_into_interface (
        p_user_id      in number,
        p_batch_number in varchar2
    ) is
    begin
   -- import dependents
        insert into claim_interface (
            claim_interface_id,
            er_acc_num,
            claim_number,
            member_id,
            service_plan_type,
            claim_amount,
            provider_name,
            patient_name,
            service_start_dt,
            service_end_dt,
            note,
            provider_flag,
            check_ach_flag,
            eob_required_ind,
            insurance_category,
            expense_category,
            address,
            city,
            state,
            zip,
            provider_acct_number,
            bank_name,
            bank_acct_number,
            routing_number,
            acc_id,
            pers_id,
            entrp_id,
            acc_num,
            interface_status,
            last_updated_by,
            last_update_date,
            created_by,
            creation_date,
            batch_number,
            other_insurance
        )
            select
                claim_interface_seq.nextval,
                a.tpa_id,
                a.claim_number,
                a.member_id,
                a.service_plan_type,
                a.claim_amount,
                a.provider_name,
                a.patient_name,
                a.service_start_dt,
                a.service_end_dt,
                a.note,
                a.provider_flag,
                a.check_ach_flag,
                a.eob_required_ind,
                a.insurance_category,
                a.expense_category,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.provider_acct_number,
                a.bank_name,
                a.bank_acct_number,
                a.routing_number,
                e.acc_id,
                b.pers_id,
                pc_person.get_entrp_from_pers_id(b.pers_id),
                e.acc_num,
                'NOT_INTERFACED',
                p_user_id,
                sysdate,
                p_user_id,
                sysdate,
                p_batch_number,
                a.other_insurance
            from
                claims_external a,
                person          b,
                account         e
            where
                    a.member_id = b.orig_sys_vendor_ref
                and b.pers_main = e.pers_id
                and a.tpa_id is not null
                and a.tpa_id = 'GFSA006937'
                and not exists (
                    select
                        *
                    from
                        claim_interface
                    where
                        claim_number = a.claim_number
                )
                and not exists (
                    select
                        count(d.pers_id),
                        c.claim_number,
                        c.member_id
                    from
                        claims_external c,
                        person          d
                    where
                            a.member_id = d.orig_sys_vendor_ref
                        and d.pers_id = b.pers_id
                        and c.member_id = a.member_id
                        and c.tpa_id is not null
                        and c.tpa_id = 'GFSA006937'
                        and not exists (
                            select
                                *
                            from
                                claim_interface
                            where
                                claim_number = c.claim_number
                        )
                    group by
                        c.claim_number,
                        c.member_id
                    having
                        count(d.pers_id) > 1
                );

    end import_dep_into_interface;

    procedure import_into_interface (
        p_user_id      in number,
        p_batch_number in varchar2
    ) is
    begin
        -- right now orig sys vendor ref
        -- comes only for cheyenne claims

        insert into claim_interface (
            claim_interface_id,
            er_acc_num,
            claim_number,
            member_id,
            service_plan_type,
            claim_amount,
            provider_name,
            patient_name,
            service_start_dt,
            service_end_dt,
            note,
            provider_flag,
            check_ach_flag,
            eob_required_ind,
            insurance_category,
            expense_category,
            address,
            city,
            state,
            zip,
            provider_acct_number,
            bank_name,
            bank_acct_number,
            routing_number,
            acc_id,
            pers_id,
            entrp_id,
            acc_num,
            interface_status,
            last_updated_by,
            last_update_date,
            created_by,
            creation_date,
            batch_number,
            other_insurance
        )
            select
                claim_interface_seq.nextval,
                a.tpa_id,
                a.claim_number,
                a.member_id,
                a.service_plan_type,
                a.claim_amount,
                a.provider_name,
                a.patient_name,
                a.service_start_dt,
                a.service_end_dt,
                a.note,
                a.provider_flag,
                a.check_ach_flag,
                a.eob_required_ind,
                a.insurance_category,
                a.expense_category,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.provider_acct_number,
                a.bank_name,
                a.bank_acct_number,
                a.routing_number,
                pc_person.acc_id(b.pers_id),
                b.pers_id,
                pc_person.get_entrp_from_pers_id(b.pers_id),
                pc_person.acc_num(b.pers_id),
                'NOT_INTERFACED',
                p_user_id,
                sysdate,
                p_user_id,
                sysdate,
                p_batch_number,
                a.other_insurance
            from
                claims_external a,
                person          b
            where
                    a.member_id = b.orig_sys_vendor_ref
                and a.tpa_id is not null
                and a.tpa_id = 'GFSA006937'
                and not exists (
                    select
                        *
                    from
                        claim_interface
                    where
                            claim_number = a.claim_number
                        and interface_status in ( 'PROCESSED', 'INTERFACED' )
                );

        insert into claim_interface (
            claim_interface_id,
            er_acc_num,
            claim_number,
            member_id,
            service_plan_type,
            claim_amount,
            provider_name,
            patient_name,
            service_start_dt,
            service_end_dt,
            note,
            provider_flag,
            check_ach_flag,
            eob_required_ind,
            insurance_category,
            expense_category,
            address,
            city,
            state,
            zip,
            provider_acct_number,
            bank_name,
            bank_acct_number,
            routing_number,
            interface_status,
            error_message,
            last_updated_by,
            last_update_date,
            created_by,
            creation_date,
            batch_number,
            other_insurance
        )
            select
                claim_interface_seq.nextval,
                a.tpa_id,
                a.claim_number,
                a.member_id,
                a.service_plan_type,
                a.claim_amount,
                a.provider_name,
                a.patient_name,
                a.service_start_dt,
                a.service_end_dt,
                a.note,
                a.provider_flag,
                a.check_ach_flag,
                a.eob_required_ind,
                a.insurance_category,
                a.expense_category,
                a.address,
                a.city,
                a.state,
                a.zip,
                a.provider_acct_number,
                a.bank_name,
                a.bank_acct_number,
                a.routing_number,
                'ERROR',
                'Cannot find member matching to the member ID ' || member_id,
                p_user_id,
                sysdate,
                p_user_id,
                sysdate,
                p_batch_number,
                a.other_insurance
            from
                claims_external a
            where
                not exists (
                    select
                        *
                    from
                        person b
                    where
                        b.orig_sys_vendor_ref = a.member_id
                    union
                    select
                        *
                    from
                        person b
                    where
                        b.ssn = format_ssn(a.member_id)
                    union
                    select
                        *
                    from
                        person b
                    where
                        replace(b.ssn, '-') = a.member_id
                );

        -- For the rest I will use SSN
        if sql%rowcount = 0 then
            insert into claim_interface (
                claim_interface_id,
                er_acc_num,
                claim_number,
                member_id,
                service_plan_type,
                claim_amount,
                provider_name,
                patient_name,
                service_start_dt,
                service_end_dt,
                note,
                provider_flag,
                check_ach_flag,
                eob_required_ind,
                insurance_category,
                expense_category,
                address,
                city,
                state,
                zip,
                provider_acct_number,
                bank_name,
                bank_acct_number,
                routing_number,
                interface_status,
                error_message,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                batch_number,
                other_insurance
            )
                select
                    claim_interface_seq.nextval,
                    a.tpa_id,
                    a.claim_number,
                    a.member_id,
                    a.service_plan_type,
                    a.claim_amount,
                    a.provider_name,
                    a.patient_name,
                    a.service_start_dt,
                    a.service_end_dt,
                    a.note,
                    a.provider_flag,
                    a.check_ach_flag,
                    a.eob_required_ind,
                    a.insurance_category,
                    a.expense_category,
                    a.address,
                    a.city,
                    a.state,
                    a.zip,
                    a.provider_acct_number,
                    a.bank_name,
                    a.bank_acct_number,
                    a.routing_number,
                    'ERROR',
                    'Cannot find any employer group matching to this TPA ID ',
                    p_user_id,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_batch_number,
                    a.other_insurance
                from
                    claims_external a
                where
                        a.tpa_id <> 'GFSA006937'
                    and not exists (
                        select
                            *
                        from
                            account
                        where
                            a.tpa_id = acc_num
                    );

            insert into claim_interface (
                claim_interface_id,
                er_acc_num,
                claim_number,
                member_id,
                service_plan_type,
                claim_amount,
                provider_name,
                patient_name,
                service_start_dt,
                service_end_dt,
                note,
                provider_flag,
                check_ach_flag,
                eob_required_ind,
                insurance_category,
                expense_category,
                address,
                city,
                state,
                zip,
                provider_acct_number,
                bank_name,
                bank_acct_number,
                routing_number,
                interface_status,
                error_message,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                batch_number,
                other_insurance
            )
                select
                    claim_interface_seq.nextval,
                    a.tpa_id,
                    a.claim_number,
                    a.member_id,
                    a.service_plan_type,
                    a.claim_amount,
                    a.provider_name,
                    a.patient_name,
                    a.service_start_dt,
                    a.service_end_dt,
                    a.note,
                    a.provider_flag,
                    a.check_ach_flag,
                    a.eob_required_ind,
                    a.insurance_category,
                    a.expense_category,
                    a.address,
                    a.city,
                    a.state,
                    a.zip,
                    a.provider_acct_number,
                    a.bank_name,
                    a.bank_acct_number,
                    a.routing_number,
                    'ERROR',
                    'Cannot find member matching to this SSN ' || member_id,
                    p_user_id,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_batch_number,
                    a.other_insurance
                from
                    claims_external a
                where
                        a.tpa_id <> 'GFSA006937'
                    and not exists (
                        select
                            *
                        from
                            person b
                        where
                            b.ssn = format_ssn(a.member_id)
                    );

            insert into claim_interface (
                claim_interface_id,
                er_acc_num,
                claim_number,
                member_id,
                service_plan_type,
                claim_amount,
                provider_name,
                patient_name,
                service_start_dt,
                service_end_dt,
                note,
                provider_flag,
                check_ach_flag,
                eob_required_ind,
                insurance_category,
                expense_category,
                address,
                city,
                state,
                zip,
                provider_acct_number,
                bank_name,
                bank_acct_number,
                routing_number,
                acc_id,
                pers_id,
                entrp_id,
                acc_num,
                interface_status,
                last_updated_by,
                last_update_date,
                created_by,
                creation_date,
                batch_number,
                other_insurance
            )
                select
                    claim_interface_seq.nextval,
                    a.tpa_id,
                    a.claim_number,
                    a.member_id,
                    a.service_plan_type,
                    a.claim_amount,
                    a.provider_name,
                    a.patient_name,
                    a.service_start_dt,
                    a.service_end_dt,
                    a.note,
                    a.provider_flag,
                    a.check_ach_flag,
                    a.eob_required_ind,
                    a.insurance_category,
                    a.expense_category,
                    a.address,
                    a.city,
                    a.state,
                    a.zip,
                    a.provider_acct_number,
                    a.bank_name,
                    a.bank_acct_number,
                    a.routing_number,
                    pc_person.acc_id(b.pers_id),
                    b.pers_id,
                    b.entrp_id,
                    pc_person.acc_num(b.pers_id),
                    'NOT_INTERFACED',
                    p_user_id,
                    sysdate,
                    p_user_id,
                    sysdate,
                    p_batch_number,
                    a.other_insurance
                from
                    claims_external a,
                    person          b,
                    account         c
                where
                        b.ssn = format_ssn(a.member_id)
                    and a.tpa_id = c.acc_num
                    and c.entrp_id = b.entrp_id
                    and a.tpa_id <> 'GFSA006937'
                    and not exists (
                        select
                            *
                        from
                            claim_interface
                        where
                            claim_number = a.claim_number
                    );

        end if;

    end import_into_interface;

    procedure initialize_edi_claims (
        p_batch_number in number
    ) is
    begin
        update claim_interface b
        set
            interface_status = 'ERROR',
            error_code = 'DUPLICATE_CLAIM',
            error_message = 'Claim had been processed already '
        where
                batch_number = p_batch_number
            and exists (
                select
                    *
                from
                    claim_detail
                where
                    service_code = b.claim_number
            )
            and interface_status = 'NOT_INTERFACED'
            and b.claim_number is not null;

        update claim_interface
        set
            interface_status = 'ERROR',
            error_message = 'Cannot get account number of member id ' || member_id,
            error_code = 'MEMBER_NOT_FOUND'
        where
                batch_number = p_batch_number
            and interface_status = 'NOT_INTERFACED'
            and not exists (
                select
                    *
                from
                    enrollment_edi_detail
                where
                    orig_system_ref = claim_interface.member_id
            )
            and er_acc_num = 'GFSA006937';

        update claim_interface a
        set
            interface_status = 'DUPLICATE',
            error_message = 'Duplicate Claims loaded ',
            error_code = 'DUPLICATE_CLAIM_IN_SAME_BATCH'
        where
                rowid > (
                    select
                        min(rowid)
                    from
                        claim_interface b
                    where
                            a.member_id = b.member_id
                        and a.interface_status = b.interface_status
                        and a.claim_amount = b.claim_amount
                        and a.batch_number = b.batch_number
                        and a.provider_name = b.provider_name
                        and a.patient_name = b.patient_name
                        and a.service_start_dt = b.service_start_dt
                        and a.service_end_dt = b.service_end_dt
                        and a.claim_number = b.claim_number
                )
            and interface_status = 'NOT_INTERFACED'
            and batch_number = p_batch_number;

        for x in (
            select
                count(distinct a.acc_num),
                b.orig_sys_vendor_ref,
                c.member_id
            from
                account         a,
                person          b,
                claim_interface c
            where
                    a.pers_id = b.pers_id
                and a.account_type in ( 'HRA', 'FSA' )
                and b.entrp_id = c.entrp_id
                and a.account_status = 1
                and b.orig_sys_vendor_ref = substr(member_id,
                                                   1,
                                                   length(member_id) - 2)
                                            || '01'
                and interface_status = 'NOT_INTERFACED'
             --  and   member_id = '193402'
            group by
                b.orig_sys_vendor_ref,
                c.member_id
            having
                count(distinct a.acc_num) > 1
        ) loop
            update claim_interface
            set
                interface_status = 'ERROR',
                error_code = 'MULTIPLE_ACCOUNTS',
                error_message = 'More than one account found for this member, Unable to process the claim '
            where
                    batch_number = p_batch_number
                and member_id = x.member_id;

        end loop;

        for x in (
            select
                count(distinct a.acc_num),
                b.orig_sys_vendor_ref,
                c.member_id
            from
                account         a,
                person          b,
                claim_interface c
            where
                    a.pers_id = nvl(b.pers_main, b.pers_id)
                and a.account_type in ( 'HRA', 'FSA' )
                and b.entrp_id = c.entrp_id
                and a.account_status = 1
                and b.orig_sys_vendor_ref = c.member_id
                and interface_status = 'NOT_INTERFACED'
             --  and   member_id = '193402'
            group by
                b.orig_sys_vendor_ref,
                c.member_id
            having
                count(distinct a.acc_num) > 1
        ) loop
            update claim_interface
            set
                interface_status = 'ERROR',
                error_code = 'MULTIPLE_ACCOUNTS',
                error_message = 'More than one account found for this member, Unable to process the claim '
            where
                    batch_number = p_batch_number
                and member_id = x.member_id;

        end loop;

        for x in (
            select
                a.member_id,
                d.acc_id                                                      acc_id,
                nvl(c.pers_main, c.pers_id)                                   pers_id,
                pc_person.get_entrp_from_pers_id(nvl(c.pers_main, c.pers_id)) entrp_id,
                d.acc_num,
                claim_interface_id
            from
                claim_interface a,
                person          c,
                account         d
            where
                    a.batch_number = p_batch_number
                and a.interface_status = 'NOT_INTERFACED'
                and a.er_acc_num = 'GFSA006937'
                and d.account_type in ( 'HRA', 'FSA' )
                and d.pers_id = nvl(c.pers_main, c.pers_id)
                and c.pers_end_date is null
                and ( a.acc_id is null
                      or a.entrp_id is null
                      or a.acc_num is null )
                and c.orig_sys_vendor_ref = a.member_id
        ) loop
            update claim_interface
            set
                acc_id = x.acc_id,
                pers_id = x.pers_id,
                entrp_id = x.entrp_id,
                acc_num = x.acc_num
            where
                    batch_number = p_batch_number
                and ( acc_id is null
                      or entrp_id is null
                      or acc_num is null )
                and interface_status = 'NOT_INTERFACED'
                and claim_interface_id = x.claim_interface_id;

        end loop;

        for x in (
            select
                a.member_id,
                d.acc_id                                                      acc_id,
                nvl(c.pers_main, c.pers_id)                                   pers_id,
                pc_person.get_entrp_from_pers_id(nvl(c.pers_main, c.pers_id)) entrp_id,
                d.acc_num,
                claim_interface_id
            from
                claim_interface a,
                claims_external b,
                person          c,
                account         d
            where
                    a.batch_number = p_batch_number
                and a.member_id = b.member_id
                and a.interface_status = 'NOT_INTERFACED'
                and b.tpa_id <> 'GFSA006937'
                and d.pers_id = nvl(c.pers_main, c.pers_id)
                and d.account_type in ( 'HRA', 'FSA' )
                and ( a.acc_id is null
                      or a.entrp_id is null
                      or a.acc_num is null )
                and replace(c.ssn, '-') = a.member_id
        ) loop
            update claim_interface
            set
                acc_id = x.acc_id,
                pers_id = x.pers_id,
                entrp_id = x.entrp_id,
                acc_num = x.acc_num
            where
                    batch_number = p_batch_number
                and ( acc_id is null
                      or entrp_id is null
                      or acc_num is null )
                and member_id = x.member_id
                and interface_status = 'NOT_INTERFACED'
                and claim_interface_id = x.claim_interface_id;

        end loop;

        update claim_interface c
        set
            interface_status = 'ERROR',
            error_message = 'Unable to identify  active benefit plan setup for  '
                            || member_id
                            || ' for the service dates, possible causes could be
                                benefit plan not setup, service dates crossing multiple plan years ',
            error_code = 'BENEFIT_PLAN_SETUP'
        where
                batch_number = p_batch_number
            and interface_status = 'NOT_INTERFACED'
            and not exists (
                select
                    *
                from
                    ben_plan_enrollment_setup bp
                where
                        bp.acc_id = c.acc_id
                    and bp.status <> 'R'
                    and format_to_date(c.service_start_dt) >= bp.plan_start_date
                    and format_to_date(c.service_end_dt) <= bp.plan_end_date
            );

        update claim_interface
        set
            interface_status = 'ERROR',
            error_message = 'Cannot get account number of member id ' || member_id,
            error_code = 'MEMBER_NOT_FOUND'
        where
            acc_id is null
            and batch_number = p_batch_number
            and interface_status = 'NOT_INTERFACED';

      -- temporary
      /*
       UPDATE claim_interface
         SET   interface_status ='WARNING'
           ,   error_code = 'PENDING_TO_WRITE_OFF_MEMBER_CLAIM'
           ,   error_message = 'Check the claims if duplicate dependent claims can be written off before processing '
        WHERE  pers_id in (86835,86835,87076,87076,124790,95199,95496,122909,126996,86643,86643,86643,86643,86643,86695,86755,86808,94759,94759,94759,95318,95367,95397,95458,95641,95641,151543,94840,94937,86755,95641,86865,94790,86755,95158,86847,95181,95141,94812,95592,94759,94733,107359,95592,86755,95641,86643,86847,94759,95368,95368,94812,86755)
         AND   batch_number = p_batch_number;*/

    end initialize_edi_claims;

    procedure ins_missing_account (
        p_claim_code       varchar2,
        p_note             varchar2,
        p_claim_error_flag varchar2
    ) as
        pragma autonomous_transaction;
    begin
        insert into payment_register (
            payment_register_id,
            claim_code,
            note,
            claim_error_flag
        ) values ( payment_register_seq.nextval,
                   p_claim_code,
                   p_note,
                   p_claim_error_flag );

        commit;
    end;

    procedure process_takeover_claims (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    ) is
    begin
        export_claims_file(pv_file_name, p_user_id, 'TAKEOVER');
        pc_claim.process_takeover_claim(p_batch_number, p_user_id);
   --COMMIT;
    end process_takeover_claims;

    procedure reprocess_crmc_no_mem_claims is
    begin
        for x in (
            select
                claim_interface_id,
                batch_number,
                member_id,
                b.entrp_id,
                b.pers_id,
                d.acc_id,
                d.acc_num
            from
                claim_interface a,
                person          b,
                account         d
            where
                    interface_status = 'ERROR'
                and b.pers_id = d.pers_id
                and b.orig_sys_vendor_ref = substr(member_id,
                                                   1,
                                                   length(member_id) - 2)
                                            || '01'
                and a.creation_date > '01-FEB-2013'
                and a.er_acc_num = 'GFSA006937'
                and error_message like 'Cannot get account number of member id%'
        ) loop
            update claim_interface
            set
                entrp_id = x.entrp_id,
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                acc_num = x.acc_num,
                interface_status = 'NOT_INTERFACED'
            where
                claim_interface_id = x.claim_interface_id;

            initialize_edi_claims(x.batch_number);
        end loop;

        for x in (
            select
                claim_interface_id,
                acc_num,
                batch_number
            from
                claim_interface a
            where
                    interface_status = 'NOT_INTERFACED'
                and error_message like 'Cannot get account number of member id%'
        ) loop
            pc_claim.import_uploaded_claims(0, x.batch_number);
        end loop;

        for x in (
            select
                claim_interface_id,
                acc_num,
                batch_number
            from
                claim_interface a
            where
                    interface_status = 'INTERFACED'
                and error_message like 'Cannot get account number of member id%'
        ) loop
            pc_claim.process_uploaded_claims(0, x.batch_number);
        end loop;

    end reprocess_crmc_no_mem_claims;

end pc_claim_interface;
/

