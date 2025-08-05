create or replace editionable trigger samqa.online_users_af1 after
    insert or update on samqa.online_users
    for each row
declare
    v_process_status varchar2(1);
    v_error_message  varchar2(500);
    v_first_name     varchar2(500);
    v_last_name      varchar2(500);
    v_gender         varchar2(1);
    v_count          number;
    l_pers_id        person.pers_id%type;
begin
    update account
    set
        blocked_flag = :new.blocked
    where
            acc_num = :new.find_key
        and account_type = 'HSA'
        and blocked_flag <> :new.blocked;

-- Added by Joshi for 6794. migrate online user info to ACN.
--IF INSERTING THEN
    for x in (
        select
            a.acc_id,
            a.pers_id,
            a.acc_num,
            p.entrp_id,
            a.account_type
        from
            account a,
            person  p
        where
                p.pers_id = a.pers_id
            and a.account_type = 'HSA'
            and p.person_type = 'SUBSCRIBER'
            and a.plan_code = 1
            and a.acc_num = :new.find_key
    ) loop
        if pc_account.is_migrated(x.acc_id) = 'Y' then
            if x.entrp_id is not null then
                if pc_acn_migration.is_employer_migrated(x.entrp_id) = 'Y' then
                    insert into acn_employee_migration (
                        mig_seq_no,
                        acc_id,
                        pers_id,
                        account_type,
                        emp_acc_id,
                        user_name,
                        pw_question,
                        pw_answer,
                        email_address,
                        action_type,
                        subscriber_type,
                        creation_date,
                        created_by
                    ) values ( mig_seq.nextval,
                               x.acc_id,
                               x.pers_id,
                               x.account_type,
                               pc_entrp.get_acc_id(x.entrp_id),
                               :new.user_name,
                               :new.pw_question,
                               :new.pw_answer,
                               :new.email,
                               'U',
                               'E',
                               sysdate,
                               0 );

                end if;

            else
                insert into acn_employee_migration (
                    mig_seq_no,
                    acc_id,
                    pers_id,
                    account_type,
                    user_name,
                    pw_question,
                    pw_answer,
                    email_address,
                    action_type,
                    subscriber_type,
                    creation_date,
                    created_by
                ) values ( mig_seq.nextval,
                           x.acc_id,
                           x.pers_id,
                           x.account_type,
                           :new.user_name,
                           :new.pw_question,
                           :new.pw_answer,
                           :new.email,
                           'U',
                           'I',
                           sysdate,
                           0 );

            end if;

        end if;
    end loop;
--END IF;

    if updating then
        if
            :new.user_type = 'S'
            and ( :new.email <> :old.email )
        then
            l_pers_id := null;
            for k in (
                select
                    p.pers_id
                from
                    account a,
                    person  p
                where
                        a.pers_id = p.pers_id
                    and a.acc_num = :new.find_key
            ) loop
                l_pers_id := k.pers_id;
            end loop;
  --pc_employer_enroll_compliance.validate_notifications(p_acc_id => null,p_pers_id => :new.pers_id, P_SSN => :NEW.SSN , p_event_name => 'ADDRESS', p_ENTITY_TYPE => 'PERSON', p_account_status => null);
            pc_notification2.insert_events(
                p_acc_id      => null,
                p_pers_id     => l_pers_id,   -- Null replaced with l_pers_id by Swamy for Ticket#9048 on 06-May-2020
                p_event_name  => 'EMAIL',
                p_entity_type => 'ONLINE_USERS',
                p_entity_id   => :new.tax_id,  -- changed from null to l_pers_id by swamy for ticket#8609
                p_ssn         => :new.tax_id
            );

            pc_notification2.insert_audit_security_info(
                p_pers_id            => l_pers_id,
                p_email              => :old.email,
                p_phone_no           => null,
                p_user_id            => :new.user_id,
                p_new_email_phone_no => :new.email   -- Added by Swamy for Ticket#9774
            );

        end if;
    end if;
   -- Added by Swamy for 6794. migrate online user info to ACN.
   -- This is an Update record, so Tax_ID should be same, so that the correct employer is detected in SAAS database to update.
    if nvl(:new.tax_id,
           '*') = nvl(:old.tax_id,
                      '*') then
        for x in (
            select
                a.acc_id,
                a.entrp_id,
                a.account_type,
                a.acc_num
            from
                account            a,
                account_preference p
            where
                    a.acc_num = :new.find_key
                and a.acc_id = p.acc_id
                and a.account_type = 'HSA'
                and a.plan_code = 1
                and nvl(a.migrated_flag, 'N') = 'Y'
                and a.account_status in ( 1, 3 )
                and nvl(p.subscribe_to_acn, 'N') = 'Y'
        ) loop
            v_count := 0;
            for i in (
                select
                    count(*) total
                from
                    acn_employer_migration
                where
                        nvl(process_status, 'N') = 'N'
                    and entrp_code = :new.tax_id
            ) loop
                v_count := i.total;
            end loop;

            if nvl(v_count, 0) = 0 then
                insert into acn_employer_migration (
                    entrp_code,
                    entrp_id,
                    acc_id,
                    acc_num,
                    account_type,
                    action_type,
                    process_status,
                    creation_date,
                    created_by
                ) values ( :new.tax_id,
                           x.entrp_id,
                           x.acc_id,
                           x.acc_num,
                           x.account_type,
                           'U',-- 'I' = Insert,'U'= Update , 'C' = Change Plan(When the plan is changed from HSA to any other plan
                           'N',
                           sysdate,
                           0 );

            end if;

        end loop;
    end if;

end;
/

alter trigger samqa.online_users_af1 enable;


-- sqlcl_snapshot {"hash":"d89deaf6715c54edf10503eb86ea6af3fbfa5b03","type":"TRIGGER","name":"ONLINE_USERS_AF1","schemaName":"SAMQA","sxml":""}