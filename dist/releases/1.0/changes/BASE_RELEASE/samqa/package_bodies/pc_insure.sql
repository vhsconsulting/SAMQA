-- liquibase formatted sql
-- changeset SAMQA:1754374035185 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_insure.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_insure.sql:null:c7ed0c4a21f768513346b1208372afa01c191f62:create

create or replace package body samqa.pc_insure as

    function get_carrier_supported (
        p_carrier_id in number
    ) return varchar2 is
        l_carrier_supported varchar2(1) := 'N';
    begin
        for x in (
            select
                carrier_supported
            from
                enterprise
            where
                entrp_id = p_carrier_id
        ) loop
            l_carrier_supported := x.carrier_supported;
        end loop;

        return l_carrier_supported;
    end get_carrier_supported;

    function is_eob_allowed (
        p_entrp_id in number
    ) return varchar2 is
        l_allow_eob varchar2(1) := 'Y';
    begin
    /* FOR X IN ( SELECT allow_eob
                  FROM ACCOUNT_PREFERENCE
                WHERE  entrp_id = P_ENTRP_ID)
     LOOP
       l_allow_eob := X.allow_eob;
     END LOOP;*/
        return l_allow_eob;
    end is_eob_allowed;

    function get_eob_status (
        p_ssn in varchar2
    ) return varchar2 is
        l_status varchar2(30);
    begin
        for x in (
            select
                b.allow_eob,
                b.carrier_supported,
                nvl(b.eob_connection_status, 'NOT_CONNECTED') eob_connection_status
            from
                person a,
                insure b
            where
                    a.ssn = format_ssn(p_ssn)
                and a.pers_id = b.pers_id
        ) loop
            if nvl(l_status, 'SHOW_CONNECT') in ( 'SHOW_CONNECT', 'NO_EOB' ) then
                if
                    x.carrier_supported = 'Y'
                    and x.eob_connection_status in ( 'IN_PROCESS', 'SUCCESS' )
                then
                    l_status := 'SHOW_MANAGE';
                end if;

                if x.carrier_supported = 'N' then
                    l_status := 'NO_EOB';
                end if;
                if
                    x.carrier_supported = 'Y'
                    and x.eob_connection_status in ( 'REVOKED', 'NOT_CONNECTED' )
                then
                    l_status := 'SHOW_CONNECT';
                end if;

            end if;
        end loop;

        return nvl(l_status, 'NO_EOB');
    end get_eob_status;

    procedure update_revoked_date (
        p_pers_id in number,
        p_uers_id in number
    ) is
    begin
        pc_log.log_error('PC_INSURE.update_revoked_date', 'in update_revoked_date' || p_pers_id);
        for x in (
            select
                pp.pers_id
            from
                person p,
                person pp
            where
                    p.pers_id = p_pers_id
                and p.ssn = pp.ssn
        ) loop
            pc_log.log_error('PC_INSURE.update_revoked_date', 'Revoking ' || x.pers_id);
            update insure
            set
                revoked_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = p_uers_id,
                eob_connection_status = 'REVOKED'
            where
                pers_id = x.pers_id;

        end loop;

    end update_revoked_date;

    procedure update_carrier_status (
        p_ssn          in varchar2,
        p_carrier_name in varchar2,
        p_carrier_user in varchar2,
        p_carrier_pwd  in varchar2,
        p_status       in varchar2,
        p_policy_num   in varchar2,
        p_user_id      in number
    ) is
        l_carrier_id   number;
        l_insur_exist  number := 0;
        l_carrier_name varchar2(3200);
    begin
      /** First check the carrier they had entered is in our system
        , if not create it ***/
        pc_log.log_error('PC_INSURE.update_carrier_status', 'P_SSN'
                                                            || p_ssn
                                                            || 'P_CARRIER_NAME '
                                                            || p_carrier_name
                                                            || 'P_STATUS'
                                                            || p_status);

        l_carrier_name := p_carrier_name;
        if p_carrier_name = '' then
            l_carrier_name := null;
        end if;
        for xx in (
            select
                entrp_id
            from
                enterprise
            where
                    en_code = 3
                and name = l_carrier_name
        ) loop
            l_carrier_id := xx.entrp_id;
        end loop;

        pc_log.log_error('PC_INSURE.update_carrier_status', 'CARRIER ID ' || l_carrier_id);
        if
            l_carrier_id is null
            and p_carrier_name is not null
        then
            l_carrier_id := entrp_seq.nextval;
            insert into enterprise (
                entrp_id,
                en_code,
                name,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                carrier_supported
            ) values ( l_carrier_id,
                       3,
                       l_carrier_name,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       'Y' );

        else
            update enterprise
            set
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                carrier_supported = 'Y'
            where
                entrp_id = l_carrier_id;

        end if;

      /** updating the status of all the connection parameters ***/
        for x in (
            select
                a.pers_id,
                pc_person.count_insure(a.pers_id) insur_exist
            from
                person a
            where
                a.ssn = format_ssn(p_ssn)
        ) loop
            l_insur_exist := x.insur_exist;
            pc_log.log_error('PC_INSURE.update_carrier_status', 'INSUR EXIST '
                                                                || l_insur_exist
                                                                || ' pers_id '
                                                                || x.pers_id
                                                                || 'P_STATUS '
                                                                || p_status);

            if l_insur_exist > 0 then
                update insure
                set
                    eob_connection_status =
                        case
                            when p_status in ( '2', '3' ) then
                                'SUCCESS'
                            when p_status = '0'
                                 and eob_connection_status = 'REVOKED' then
                                'REVOKED'
                            when p_status = '0'
                                 and eob_connection_status not in ( 'SUCCESS', 'REVOKED' ) then
                                'NOT_CONNECTED'
                        end,
                    allow_eob = 'Y',
                    carrier_supported = 'Y',
                    carrier_user_name = p_carrier_user,
                    carrier_password = p_carrier_pwd,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    policy_num = p_policy_num,
                    deductible = nvl(deductible, 1200),
                    insur_id = nvl(l_carrier_id, insur_id),
                    revoked_date =
                        case
                            when p_status = '0'
                                 and eob_connection_status = 'REVOKED' then
                                sysdate
                            else
                                null
                        end
                where
                    pers_id = x.pers_id
                returning insur_id into l_carrier_id;

                if sql%rowcount = 0 then
                    l_insur_exist := 0;
                end if;
                pc_log.log_error('PC_INSURE.update_carrier_status', 'SQL%ROWCOUNT ' || l_insur_exist);
            end if;

            if
                l_insur_exist = 0
                and l_carrier_id is not null
            then
                insert into insure (
                    pers_id,
                    insur_id,
                    start_date,
                    note,
                    plan_type,
                    eob_connection_status,
                    allow_eob,
                    carrier_supported,
                    carrier_user_name,
                    deductible,
                    carrier_password,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    policy_num
                ) values ( x.pers_id,
                           l_carrier_id,
                           sysdate,
                           'Inserted from Health Expense Connection ',
                           0,
                           case
                               when p_status in ( '2', '3' ) then
                                   'SUCCESS'
                               else
                                   'NOT_CONNECTED'
                           end,
                           'Y',
                           'Y',
                           p_carrier_user,
                           1200,
                           p_carrier_pwd,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           p_policy_num );

            end if;

        end loop;

    exception
        when others then
            pc_log.log_error('update_carrier_status', sqlerrm);
    end update_carrier_status;

    function get_allow_eob (
        p_entrp_id in number
    ) return varchar2 is
        l_allow_eob varchar2(1) := 'Y';
    begin

 /*   FOR X IN ( SELECT NVL(ALLOW_EOB,'N') ALLOW_EOB
                 FROM  ACCOUNT_PREFERENCE
           		WHERE  ENTRP_ID = P_ENTRP_ID)
    LOOP
       L_ALLOW_EOB := X.ALLOW_EOB;
    END LOOP;*/
        return nvl(l_allow_eob, 'N');
    end get_allow_eob;

    function get_carrier_id (
        p_carrier in varchar2
    ) return number is
        l_entrp_id number;
    begin
        for x in (
            select
                entrp_id
            from
                enterprise
            where
                    upper(replace(
                        strip_bad(name),
                        ' ',
                        ''
                    )) = upper(replace(
                        strip_bad(p_carrier),
                        ' ',
                        ''
                    ))
                and en_code = 3
        ) loop
            l_entrp_id := x.entrp_id;
        end loop;

        return l_entrp_id;
    exception
        when others then
            return null;
    end get_carrier_id;

    procedure export_hrafsa_health_plan (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
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
        l_sqlerrm      varchar2(32000);
        l_create_error exception;
        l_batch_number number;
        l_pers_id      number;
        l_acc_id       number;
        l_ssn          varchar2(100);
        l_acc_num      varchar2(100);
        l_carrier      varchar2(100);
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
            execute immediate 'ALTER TABLE HEALTH_PLAN_EXTERNAL
         location (ENROLL_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of health plan upload file' || sqlerrm;
                raise l_create_error;
        end;

        insert into health_plan_upload (
            health_plan_id,
            first_name,
            last_name,
            ssn,
            acc_num,
            carrier,
            deductible,
            effective_date,
            plan_type,
            account_type,
            batch_number,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                health_plan_upload_seq.nextval,
                first_name,
                last_name,
                format_ssn(ssn),
                acc_num,
                replace(carrier, ';', '&'),
                nvl(a.deductible, 1200)     deductible,
                format_date(effective_date) effective_date,
                plan_type,
                regexp_replace(account_type, '[^ -~]', ''),
                x_batch_number,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                health_plan_external a;

  --Open This Loop just to upadet SSN and ACC NUM values
        for x in (
            select
                *
            from
                health_plan_upload
            where
                    batch_number = x_batch_number
                and processed_status = 'N'
        ) loop
            update health_plan_upload a
            set
                error_message = 'SSN or ACCT# needs to be specified',
                processed_status = 'E'
            where
                    processed_status = 'N'
                and batch_number = x.batch_number
                and x.ssn is null
                and x.acc_num is null;

            update health_plan_upload a
            set
                error_message = 'Carrier Name cannot be NULL',
                processed_status = 'E'
            where
                    processed_status = 'N'
                and batch_number = x.batch_number
                and replace(ssn, '-') = replace(x.ssn, '-')
                and x.carrier is null;

            update health_plan_upload a
            set
                error_message = 'Plan Type cannot be NULL',
                processed_status = 'E'
            where
                    processed_status = 'N'
                and batch_number = x.batch_number
                and replace(ssn, '-') = replace(x.ssn, '-')
                and x.plan_type is null;

            update health_plan_upload a
            set
                error_message = 'Account Type needs to be specified',
                processed_status = 'E'
            where
                    processed_status = 'N'
                and batch_number = x.batch_number
                and replace(ssn, '-') = replace(x.ssn, '-')
                and x.account_type is null;

            if ( x.acc_num is not null
                 or x.ssn is not null ) then
                for xx in (
                    select
                        a.acc_num,
                        a.acc_id,
                        b.pers_id
                    from
                        account a,
                        person  b
                    where
                            b.ssn = x.ssn
                        and a.pers_id = b.pers_id
                        and a.account_status <> 4
                        and a.acc_num = x.acc_num
                        and a.account_type = x.account_type
                    union
                    select
                        a.acc_num,
                        a.acc_id,
                        b.pers_id
                    from
                        account a,
                        person  b
                    where
                            b.ssn = x.ssn
                        and a.account_status <> 4
                        and a.account_type = x.account_type
                        and x.acc_num is null
                    union
                    select
                        a.acc_num,
                        a.acc_id,
                        b.pers_id
                    from
                        account a,
                        person  b
                    where
                            a.acc_num = x.acc_num
                        and a.account_status <> 4
                        and a.account_type = x.account_type
                        and x.ssn is null
                ) loop
                    l_pers_id := xx.pers_id;
                    l_acc_num := xx.acc_num;
                    l_acc_id := xx.acc_id;
                end loop;
            else
                update health_plan_upload a
                set
                    error_message = 'Cannot derive Account information',
                    processed_status = 'E'
                where
                        processed_status = 'N'
                    and batch_number = x.batch_number
                    and ssn = x.ssn
                    and l_pers_id is null
                    and l_acc_num is null
                    and l_acc_id is null;

            end if;

            select
                pc_insure.get_carrier_id(x.carrier)
            into l_carrier
            from
                dual;

            if l_carrier is null then
                update health_plan_upload a
                set
                    error_message = 'Carrier Not defined',
                    processed_status = 'E'
                where
                        processed_status = 'N'
                    and batch_number = x.batch_number
                    and replace(ssn, '-') = replace(x.ssn, '-')
                    and x.carrier is not null;

            end if;

        end loop;

  -- Inserting into Insure
        insert into insure (
            pers_id,
            insur_id,
            plan_type,
            start_date,
            deductible,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                b.pers_id,
                get_carrier_id(carrier)                    carrier_id,
                pc_lookups.get_plan_type_code(a.plan_type) plan_type,
                format_to_date(a.effective_date),
                nvl(deductible, 1200)                      deductible,
                'Health Carrier Update',
                a.creation_date,
                a.created_by,
                a.last_update_date,
                a.last_updated_by
            from
                health_plan_upload a,
                person             b,
                account            c
            where
                    a.ssn = b.ssn
                and b.pers_id = c.pers_id
                and c.account_type = a.account_type
                and processed_status = 'N'
                and batch_number = x_batch_number
                and not exists (
                    select
                        *
                    from
                        insure
                    where
                        insure.pers_id = b.pers_id
                );

        for i in (
            select
                b.pers_id,
                get_carrier_id(carrier)                  carrier_id,
                pc_lookups.get_plan_type_code(plan_type) plan_type,
                format_to_date(a.effective_date)         effective_date,
                nvl(deductible, 1200)                    deductible
            from
                health_plan_external a,
                person               b,
                account              c
            where
                    format_ssn(a.ssn) = format_ssn(b.ssn)
                and b.pers_id = c.pers_id
                and c.account_type = a.account_type
        ) loop
            update insure
            set
                plan_type = i.plan_type,
                start_date = i.effective_date,
                deductible = i.deductible,
                note = 'Health Plan Update',
                creation_date = sysdate,
                created_by = p_user_id,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    pers_id = i.pers_id
                and insur_id = i.carrier_id;

        end loop;

        update health_plan_upload
        set
            error_message = 'Successfully Loaded',
            processed_status = 'S'
        where
                processed_status = 'N'
            and batch_number = x_batch_number;

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
    end export_hrafsa_health_plan;

end pc_insure;
/

