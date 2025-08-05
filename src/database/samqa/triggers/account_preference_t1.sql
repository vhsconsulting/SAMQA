create or replace editionable trigger samqa.account_preference_t1 before
    insert or update on samqa.account_preference
    for each row
declare                                          -- Start Added by Swamy Ticket#7799
    v_entrp_code    enterprise.entrp_code%type;
    v_count         number := 0;
    v_sysdate       date;
    v_creation_date date;
    v_new_reg_date  date;
    v_reg_date      date;                            -- End Of Addition by Swamy Ticket#7799
begin

  -- Start Added by Swamy Ticket#7799
  -- As per this Ticket any newly enrolled Product should set the flg_new_existing as "NEW" for all the products enrolled on the same date.
  -- else the first product enrolled should be set to "NEW" and the subsequent new product enrollement should be set as "Existing".
  -- For New Enrollments for Employer
    if
        inserting
        and nvl(:new.entrp_id,
                0) <> 0
    then
    -- Get the Tax Id and Registration Date for the new Product from account Table
        for j in (
            select
                e.entrp_code,
                a.reg_date
            from
                enterprise e,
                account    a
            where
                    e.entrp_id = a.entrp_id
                and e.entrp_id = :new.entrp_id
        ) loop
            v_entrp_code := j.entrp_code;
            v_new_reg_date := j.reg_date;
        end loop;

    -- Get the Registration date of the first registered product
        for i in (
            select
                min(a.reg_date) reg_date
            from
                enterprise e,
                account    a
            where
                    e.entrp_id = a.entrp_id
                and e.entrp_code = v_entrp_code
                and a.decline_date is null
        ) loop
            v_count := v_count + 1;
            v_reg_date := i.reg_date;
        end loop;
    -- If the new registration date is same as the first registered product then assign the value as new, else assign the value as Existing.
        if v_count > 0 then
            if trunc(v_new_reg_date) = trunc(v_reg_date) then
                :new.flg_new_existing := 'NEW';
            else
                :new.flg_new_existing := 'EXISTING';
            end if;
        end if;

        pc_log.log_error('Account_Preference_T1',
                         'V_Count :='
                         || v_count
                         || 'V_New_Reg_Date := '
                         || v_new_reg_date
                         || ' V_Reg_Date :='
                         || v_reg_date
                         || ' :New.Flg_New_Existing :='
                         || :new.flg_new_existing);

    end if;
  -- Ended by Swamy Ticket#7799

    -- Trigger added by swamy  for 6794 acn migration.
    if updating then
        pc_log.log_error('Account_Preference_T1', 'Inside Account_Preference_Trigger ');
        if
            nvl(:old.subscribe_to_acn,
                'N') = 'N'
            and nvl(:new.subscribe_to_acn,
                    'N') = 'Y'
        then
            pc_acn_migration.insert_acn_employer_migration(
                p_acc_id      => :old.acc_id,
                p_entrp_id    => :old.entrp_id,
                p_action_type => 'I'
            );

        -- Joshi: Added below code 6794 ACN Migration.
        --  migrate employees.
            insert into acn_employee_migration (
                mig_seq_no,
                acc_id,
                pers_id,
                account_type,
                emp_acc_id,
                action_type,
                subscriber_type,
                creation_date,
                created_by
            )
                select
                    mig_seq.nextval,
                    a.acc_id,
                    a.pers_id,
                    a.account_type,
                    ea.acc_id,
                    'I',
                    'E',
                    sysdate,
                    0
                from
                    person     p,
                    account    a,
                    enterprise e,
                    account    ea
                where
                        p.pers_id = a.pers_id
                    and ea.entrp_id = p.entrp_id
                    and ea.entrp_id = e.entrp_id
                    and a.plan_code = 1
                    and ea.acc_id = :old.acc_id
                    and a.account_type = 'HSA'
                    and a.account_status = 1;

            pc_log.log_error('Account_Preference_T1', sqlerrm);
        elsif
            nvl(:old.subscribe_to_acn,
                'N') = 'Y'
            and nvl(:new.subscribe_to_acn,
                    'N') = 'N'
        then
          -- If The Subscribe_To_Acn Is Made "N", Then Migration Should Not Happen.Delete all the records from Staging table for which Migration is scheduled.
            delete from acn_employer_migration
            where
                    acc_id = :new.acc_id
                and nvl(process_status, 'N') <> ( 'Y' );

        end if;

    end if;

exception -- no need ???
    when others then
        pc_log.log_error('Account_Preference_T1', sqlerrm);
        null;
end account_preference_t1;
/

alter trigger samqa.account_preference_t1 enable;


-- sqlcl_snapshot {"hash":"e5f870bb208df17d50f431d5113cc1794cc9412c","type":"TRIGGER","name":"ACCOUNT_PREFERENCE_T1","schemaName":"SAMQA","sxml":""}