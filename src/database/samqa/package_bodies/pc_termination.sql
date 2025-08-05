create or replace package body samqa.pc_termination as

    procedure process_termination_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    ) is
        l_batch_number number;
    begin
        if p_batch_number is null then
            l_batch_number := batch_num_seq.nextval;
        else
            l_batch_number := p_batch_number;
        end if;

        export_termination_file(
            pv_file_name   => pv_file_name,
            p_user_id      => p_user_id,
            p_batch_number => l_batch_number
        );
        import_termination_file(l_batch_number);
        terminate_plans(l_batch_number, p_user_id);
         --  terminate_dependants(p_batch_number);

    end process_termination_file;

    procedure export_termination_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
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

        pc_log.log_error(' export_termination_file ', 'lv_dest_file ' || lv_dest_file);
              /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            pc_log.log_error(' export_termination_file ', 'Got the blob content');
            l_file := utl_file.fopen('ENROLL_DIR', lv_dest_file, 'w', 32767);
            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
                  -- Open / Creates the destination file.
            while l_pos < l_blob_len loop
                dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
                utl_file.put_raw(l_file, l_buffer, true);
                l_pos := l_pos + l_amount;
            end loop;

            pc_log.log_error(' export_termination_file ', 'Got the blob content');
            utl_file.fclose(l_file);
            delete from wwv_flow_files
            where
                name = pv_file_name;

        exception
            when no_data_found then
                null;
        end;

        begin
            for x in (
                select
                    count(*) cnt
                from
                    termination_external
            ) loop
                l_row_count := x.cnt;
            end loop;
        exception
            when others then
                null;
        end;

           --  IF l_row_count = 0 THEN
            --    RAISE lv_create;
          --   END IF;

        begin
            execute immediate '
                           ALTER TABLE termination_external
                            location (ENROLL_DIR:'''
                              || lv_dest_file
                              || ''')';
        exception
            when others then
                l_sqlerrm := 'Error in Changing location of Scheduler Detail file' || sqlerrm;
                raise l_create_error;
        end;

    exception
        when l_create_error then
            rollback;
            raise_application_error('-20001', 'Termination file seems to be corrupted, Use correct template');
        when others then
            rollback;
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;
            delete from wwv_flow_files
            where
                name = pv_file_name;

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_termination_file;

    procedure import_termination_file (
        p_batch_number in varchar2
    ) is
    begin
        pc_log.log_error('import_termination_file', 'batch number ' || p_batch_number);
        insert into termination_interface (
            termination_intf_id,
            batch_number,
            er_acc_num,
            ein,
            ssn,
            ee_acc_num,
            last_name,
            first_name,
            termination_date,
            plan_type,
            tpa_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                termination_interface_seq.nextval,
                p_batch_number,
                case
                    when acc_num like 'G%' then
                        acc_num
                    else
                        null
                end,
                replace(
                    case
                        when acc_num like 'G%' then
                            null
                        else acc_num
                    end, '-'),
                replace(
                    case
                        when substr(ssn, 1, 1) in('I', 'H', 'F') then
                            null
                        else format_ssn(b.ssn)
                    end,
                    '-'),
                case
                    when substr(ssn, 1, 1) in ( 'I', 'H', 'F' ) then
                        ssn
                    else
                        null
                end,
                b.last_name,
                b.first_name,
                to_date(format_date(b.termination_date),
                        'MMDDYYYY'),
                b.plan_type,
                tpa_id,
                sysdate,
                0,
                sysdate,
                0
            from
                termination_external b;

        pc_log.log_error('import_termination_file', 'no of rows inserted ' || sql%rowcount);
        update termination_interface
        set
            error_message = 'Employer Information Cannot be Null',
            processed = 'E'
        where
            er_acc_num is null
            and ein is null;

        update termination_interface
        set
            error_message = 'Employee Information Cannot be Null',
            processed = 'E'
        where
            ee_acc_num is null
            and ssn is null;

        update termination_interface
        set
            error_message = 'Plan Type is Required',
            processed = 'E'
        where
            plan_type is null;

        update termination_interface
        set
            error_message = 'Termination Date is Required',
            processed = 'E'
        where
            termination_date is null;

        for x in (
            select
                er_acc_num,
                b.entrp_id
            from
                termination_interface     x,
                account                   b,
                ben_plan_enrollment_setup c
            where
                    x.batch_number = p_batch_number
                and nvl(processed, 'N') = 'N'
                and x.er_acc_num is not null
                and x.er_acc_num = b.acc_num
                and b.acc_id = c.acc_id
                and c.status in ( 'I', 'A' )
                and x.plan_type = c.plan_type
                and x.termination_date between c.plan_start_date and c.plan_end_date
            group by
                er_acc_num,
                b.entrp_id
        ) loop
            update termination_interface
            set
                entrp_id = x.entrp_id
            where
                er_acc_num = x.er_acc_num;

            pc_log.log_error('import_termination_file', 'ENTRP_ID ' || x.entrp_id);
        end loop;

        pc_log.log_error('import_termination_file', 'Getting EIN ');
        for x in (
            select
                x.ein,
                b.entrp_id,
                b.acc_num
            from
                termination_interface     x,
                account                   b,
                enterprise                en,
                ben_plan_enrollment_setup c
            where
                    x.batch_number = p_batch_number
                and nvl(processed, 'N') = 'N'
                and replace(en.entrp_code, '-') = replace(x.ein, '-')
                and x.ein is not null
                and c.status in ( 'I', 'A' )
                and en.entrp_id = b.entrp_id
                and b.acc_id = c.acc_id
                and x.plan_type = c.plan_type
                and x.termination_date between c.plan_start_date and c.plan_end_date
            group by
                x.ein,
                b.entrp_id,
                b.acc_num
        ) loop
            update termination_interface
            set
                entrp_id = x.entrp_id,
                er_acc_num = x.acc_num
            where
                ein = x.ein;

            pc_log.log_error('import_termination_file', 'EIN ' || x.ein);
            pc_log.log_error('import_termination_file', 'ENTRP_ID ' || x.entrp_id);
        end loop;

        for x in (
            select
                x.termination_intf_id,
                d.ben_plan_id,
                d.acc_id,
                x.ssn,
                b.pers_id,
                c.acc_num
            from
                termination_interface     x,
                person                    b,
                account                   c,
                ben_plan_enrollment_setup d
            where
                    x.batch_number = p_batch_number
                and b.entrp_id = x.entrp_id
                and nvl(processed, 'N') = 'N'
                and b.ssn = format_ssn(x.ssn)
                and c.pers_id = b.pers_id
                and c.acc_id = d.acc_id
                and d.status in ( 'I', 'A' )
                and x.plan_type = d.plan_type
                and d.effective_end_date is null
                and d.plan_start_date <= sysdate
                and d.plan_end_date >= sysdate
        ) loop
            update termination_interface
            set
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                ben_plan_id = x.ben_plan_id,
                ee_acc_num = x.acc_num
            where
                termination_intf_id = x.termination_intf_id;

        end loop;

        for x in (
            select
                x.termination_intf_id,
                d.ben_plan_id,
                d.acc_id,
                x.ee_acc_num,
                b.pers_id
            from
                termination_interface     x,
                person                    b,
                account                   c,
                ben_plan_enrollment_setup d
            where
                    c.acc_num = x.ee_acc_num
                and x.batch_number = p_batch_number
                and nvl(processed, 'N') = 'N'
                and b.entrp_id = x.entrp_id
                and c.pers_id = b.pers_id
                and c.acc_id = d.acc_id
                and d.status in ( 'I', 'A' )
                and x.plan_type = d.plan_type
                and d.effective_end_date is null
                and d.plan_start_date <= sysdate
                and d.plan_end_date >= sysdate
        ) loop
            update termination_interface
            set
                pers_id = x.pers_id,
                acc_id = x.acc_id,
                ben_plan_id = x.ben_plan_id
            where
                termination_intf_id = x.termination_intf_id;

        end loop;

        update termination_interface
        set
            error_message = 'Cannot find Employer Account ',
            processed = 'E'
        where
            entrp_id is null
            and batch_number = p_batch_number
            and ( processed = 'N'
                  or processed is null );

        update termination_interface
        set
            error_message = 'Cannot find Employee Account or plan associated with it or
                                Employee Account number is incorrect or Employee might be already terminated',
            processed = 'E'
        where
            acc_id is null
            and batch_number = p_batch_number
            and ( processed = 'N'
                  or processed is null );

    end import_termination_file;

    procedure terminate_plans (
        p_batch_number in varchar2,
        p_user_id      in number
    ) is
        l_count               number := 0;
        v_terminate_all_plans varchar2(1);  -- Added by Swamy for Ticket#3730(Queens Issue)
    begin

            -- Terminate Plans for Subscriber

        for xx in (
            select
                a.ben_plan_id,
                a.termination_intf_id,
                a.termination_date,
                a.acc_id,
                a.pers_id,
                a.plan_type,
                a.entrp_id      -- Added by Swamy for Ticket#3730(Queens Issue)
            from
                termination_interface a
            where
                    a.batch_number = p_batch_number
                and nvl(a.processed, 'N') = 'N'
        ) loop
					   -- Start of Addition by Swamy for Ticket#3730(Queens Issue)
					   -- As per the functionality termination_req_date should be updated for all plans whos (plan_end_date+NVL(grace_period,0)+NVL(runout_period_days,0) > SYSDATE)
					   -- Suppose if a product has 2 plans 2018 and 2019 with the above condition satisfying, then termination_req_date for both the plans should get updated.
                       -- But Only for Queens, it Should update only the current plan. So we introduced a new flag at account preference and the terminate_all_plans for Queens will always be "N".
            v_terminate_all_plans := 'Y';
            for t in (
                select
                    terminate_all_plans
                from
                    account_preference
                where
                    entrp_id = xx.entrp_id
            ) loop
                v_terminate_all_plans := nvl(t.terminate_all_plans, 'Y');
            end loop;
					   -- End of Addition Swamy for Ticket#3730(Queens Issue)
            if
                xx.plan_type is not null
                and v_terminate_all_plans = 'Y'
            then    -- AND Cond. added by swamy for Ticket#3730(Queens Issue)
                update ben_plan_enrollment_setup
                       --Ticket#3730.Status of the plan always remains active while termination
                set
                    status = 'A'
                       ---status = case when  trunc(xx.termination_date) <= trunc(sysdate) then 'I' else 'A' END
                    ,
                    effective_end_date = xx.termination_date,
                    termination_req_date = sysdate,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    life_event_code = 'TERM_PLAN'
                where
                        plan_type = xx.plan_type
                    and effective_end_date is null
                    and acc_id = xx.acc_id
                    and plan_end_date + nvl(grace_period, 0) + nvl(runout_period_days, 0) > sysdate;

            else
                update ben_plan_enrollment_setup
                      --Ticket#3730.Status of the plan always remains active while termination
                set
                    status = 'A'
                      --status = case when  trunc(xx.termination_date) <= trunc(sysdate) then 'I' else 'A' END
                    ,
                    effective_end_date = xx.termination_date,
                    termination_req_date = sysdate,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    life_event_code = 'TERM_PLAN'
                where
                        ben_plan_id = xx.ben_plan_id
                    and acc_id = xx.acc_id
                    and effective_end_date is null;

            end if;

            for x in (
                select
                    b.scheduler_id,
                    b.plan_type
                from
                    scheduler_details a,
                    scheduler_master  b
                where
                        a.scheduler_id = b.scheduler_id
                    and b.plan_type = nvl(xx.plan_type,
                                          pc_benefit_plans.get_ben_plan_type(xx.ben_plan_id))
                    and a.acc_id = xx.acc_id
            ) loop
                update scheduler_details
                set
                    status =
                        case
                            when trunc(xx.termination_date) <= trunc(sysdate) then
                                'I'
                            else
                                'A'
                        end,
                    effective_end_date = xx.termination_date,
                    last_updated_date = sysdate
                where
                        scheduler_id = x.scheduler_id
                    and acc_id = xx.acc_id;

            end loop;

            update termination_interface
            set
                acc_id = xx.acc_id,
                pers_id = xx.pers_id,
                processed = 'R',
                last_updated_by = 0,
                last_update_date = sysdate
            where
                termination_intf_id = xx.termination_intf_id;

        end loop;

        for x in (
            select
                count(a.ben_plan_id) term_cnt,
                nvl((
                    select
                        count(bp.ben_plan_id)
                    from
                        ben_plan_enrollment_setup bp
                    where
                            a.acc_id = bp.acc_id
                        and bp.status in('I', 'A')
                        and plan_end_date > sysdate
                ),
                    0)               ben_plan_cnt,
                a.acc_id,
                a.pers_id
            from
                termination_interface a
            where
                    nvl(a.processed, 'N') = 'R'
                and a.batch_number = p_batch_number
            group by
                a.acc_id,
                a.pers_id
        ) loop
                   /*  IF  x.term_cnt = x.ben_plan_cnt THEN
                        UPDATE CARD_DEBIT
                         SET    STATUS = 3
                           ,    NOTE = NOTE||' Terminated upon request from file feed'
                        WHERE  CARD_ID = X.PERS_ID;

                        FOR zz IN ( SELECT PERS_ID
                                    FROM   PERSON
                                    WHERE  PERS_MAIN = X.PERS_ID)
                        LOOP
                            UPDATE CARD_DEBIT
                              SET    STATUS = 3
                                ,    NOTE = NOTE||' Terminated upon request from file feed'
                            WHERE  CARD_ID = ZZ.PERS_ID;
                        END LOOP;
                    END IF;*/
            update termination_interface
            set
                pers_id = x.pers_id,
                processed = 'Y',
                last_updated_by = 0,
                last_update_date = sysdate
            where
                    pers_id = x.pers_id
                and processed = 'R';

        end loop;

    end terminate_plans;

    procedure terminate_dependants (
        p_batch_number in varchar2
    ) is
    begin
        for x in (
            select
                a.termination_intf_id,
                a.termination_date,
                c.pers_id
            from
                termination_interface a,
                person                c
            where
                    a.batch_number = p_batch_number
                and nvl(a.processed, 'N') = 'N'
                and c.person_type <> 'SUBSCRIBER'
                and c.ssn = format_ssn(a.ssn)
        ) loop
            update person
            set
                pers_end_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = 0,
                note = 'Terminated dependants from the file feed request '
            where
                pers_id = x.pers_id;

                 -- End dating debit card
            update card_debit
            set
                status = 3
            where
                card_id = x.pers_id;

            update termination_interface
            set
                pers_id = x.pers_id,
                processed = 'Y',
                last_updated_by = 0,
                last_update_date = sysdate
            where
                termination_intf_id = x.termination_intf_id;

        end loop;
    end terminate_dependants;

    procedure insert_termination_interface (
        p_acc_id          in number,
        p_entrp_id        in number,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number,
        p_plan_type       in varchar2,
        p_ben_plan_id     in number,
        p_batch_number    in number default null
    ) is
        l_batch_number number;
    begin
        -- let us lump all of the day's termination in one
	-- batch for the adhoc requests so we can process it
	-- all at once
        if p_batch_number is null then
            l_batch_number := to_char(sysdate, 'YYYYMMDD');
        else
            l_batch_number := p_batch_number;
        end if;

        insert into termination_interface (
            termination_intf_id,
            batch_number,
            entrp_id,
            er_acc_num,
            termination_date,
            ben_plan_id,
            plan_type,
            acc_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            pers_id
        )
            select
                termination_interface_seq.nextval,
                l_batch_number,
                pc_person.get_entrp_id(acc_id),
                pc_entrp.get_acc_num(p_entrp_id),
                p_effective_date,
                p_ben_plan_id,
                pc_benefit_plans.get_ben_plan_type(p_ben_plan_id),
                p_acc_id,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                a.pers_id
            from
                account a
            where
                a.acc_id = p_acc_id;

    end insert_termination_interface;

    procedure ins_termination_interface (
        p_acc_id          in number,
        p_entrp_id        in number,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number,
        p_plan_type       in varchar2,
        p_ben_plan_id     in number,
        p_batch_number    in varchar2
    ) is
    begin
        insert into termination_interface (
            termination_intf_id,
            batch_number,
            entrp_id,
            er_acc_num,
            ssn,
            last_name,
            first_name,
            termination_date,
            plan_type,
            acc_id,
            pers_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            ben_plan_id
        )
            select
                termination_interface_seq.nextval,
                p_batch_number,
                p_entrp_id,
                (
                    select
                        acc_num
                    from
                        account
                    where
                        entrp_id = p_entrp_id
                ),
                ssn,
                last_name,
                first_name,
                p_effective_date,
                p_plan_type,
                p_acc_id,
                a.pers_id,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                p_ben_plan_id
            from
                account a,
                person  p
            where
                    a.acc_id = p_acc_id
                and a.pers_id = p.pers_id;

    end ins_termination_interface;

    procedure term_all_plans (
        p_acc_id          in number,
        p_batch_number    in varchar2,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number
    ) is
    begin
        for xx in (
            select
                pc_person.get_entrp_id(acc_id) entrp_id,
                plan_type,
                ben_plan_id
            from
                ben_plan_enrollment_setup
            where
                    acc_id = p_acc_id
                and status in ( 'I', 'A' )
                and effective_end_date is null
        ) loop
            ins_termination_interface(
                p_acc_id          => p_acc_id,
                p_entrp_id        => xx.entrp_id,
                p_life_event_code => p_life_event_code,
                p_effective_date  => p_effective_date,
                p_user_id         => p_user_id,
                p_plan_type       => xx.plan_type,
                p_ben_plan_id     => xx.ben_plan_id,
                p_batch_number    => p_batch_number
            );
        end loop;

        terminate_plans(
            p_batch_number => p_batch_number,
            p_user_id      => p_user_id
        );
         -- terminate dependants
        for dep in (
            select
                c.pers_id
            from
                person c
            where
                c.pers_main = (
                    select
                        pers_id
                    from
                        account
                    where
                        acc_id = p_acc_id
                )
        ) loop
            update person
            set
                pers_end_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = 0,
                note = 'Terminated dependants online '
            where
                pers_id = dep.pers_id;

            update card_debit
            set
                status = 3
            where
                card_id = dep.pers_id;

        end loop;

        pc_schedule.inactivate_scheduler(
            p_acc_id         => p_acc_id,
            p_effective_date => p_effective_date
        );
    end term_all_plans;

    procedure term_one_plan (
        p_acc_id          in number,
        p_batch_number    in varchar2,
        p_ben_plan_id     in number,
        p_entrp_id        in number,
        p_life_event_code in varchar2,
        p_effective_date  in date,
        p_user_id         in number
    ) is
        l_plan_type varchar2(30);
    begin
        select
            plan_type
        into l_plan_type
        from
            ben_plan_enrollment_setup
        where
            ben_plan_id = p_ben_plan_id;

        pc_termination.ins_termination_interface(
            p_acc_id          => p_acc_id,
            p_entrp_id        => p_entrp_id,
            p_life_event_code => p_life_event_code,
            p_effective_date  => p_effective_date,
            p_user_id         => p_user_id,
            p_plan_type       => l_plan_type,
            p_ben_plan_id     => p_ben_plan_id,
            p_batch_number    => p_batch_number
        );
          --If Termination date > SYSDATE then don't set the status of plan as Inactive
     --But for less than SYSDATES, set the plan as inactive
     --Ticket#2687
     /*   IF p_effective_date <= SYSDATE THEN
           UPDATE     ben_plan_enrollment_setup
                SET    status = 'I'
                       ,effective_end_date = p_effective_date
                       ,life_event_code = p_life_event_code
                       ,last_update_date = sysdate
                       ,last_updated_by  = p_user_id
                       ,termination_req_date = SYSDATE
                WHERE  ben_plan_id = p_ben_plan_id;
        ELSE
     */
      -- Commented the above by Swamy for Ticket#7717.Status will not be set to 'I' during terminations
        update ben_plan_enrollment_setup
        set
            effective_end_date = p_effective_date,
            life_event_code = p_life_event_code,
            last_update_date = sysdate,
            last_updated_by = p_user_id,
            termination_req_date = sysdate
        where
            ben_plan_id = p_ben_plan_id;
      --   END IF;

        update termination_interface
        set
            processed = 'Y',
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                batch_number = p_batch_number
            and ben_plan_id = p_ben_plan_id;

    end term_one_plan;

end pc_termination;
/


-- sqlcl_snapshot {"hash":"d7672e8bb318952c394c8a7b68bd77bd629959a1","type":"PACKAGE_BODY","name":"PC_TERMINATION","schemaName":"SAMQA","sxml":""}