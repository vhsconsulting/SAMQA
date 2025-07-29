create or replace editionable trigger samqa.debit_card_on_update after
    update on samqa.person
    for each row
declare
    v_update_id         debit_card_updates.update_id%type;
    v_acc_num           debit_card_updates.acc_num%type;
    v_acc_id            number;
    v_ssn_changed       char(1) := 'N';
    v_demo_changed      char(1) := 'N';
    v_ssn_oldval        debit_card_updates.ssn_oldval%type := null;
    v_ssn_newval        debit_card_updates.ssn_newval%type := null;
    v_first_name        debit_card_updates.first_name%type := null;
    v_middle_name       debit_card_updates.middle_name%type := null;
    v_last_name         debit_card_updates.last_name%type := null;
    v_address           debit_card_updates.address%type := null;
    v_city              debit_card_updates.city%type := null;
    v_state             debit_card_updates.state%type := null;
    v_zip               debit_card_updates.zip%type := null;
    v_account_type      varchar2(30) := null;
    v_debit_card_status card_debit.status%type;
begin

  -- Employer Change History
    if nvl(:old.entrp_id,
           -1) <> nvl(:new.entrp_id,
                      -1) then
        begin
            select
                acc_id,
                acc_num
            into
                v_acc_id,
                v_acc_num
            from
                account
            where
                pers_id = :new.pers_id;

        exception
            when others then
                null;
        end;

        insert into account_history (
            acc_id,
            acc_num,
            old_entrp_id,
            new_entrp_id,
            creation_date
        ) values ( v_acc_id,
                   v_acc_num,
                   :old.entrp_id,
                   :new.entrp_id,
                   sysdate );

        pc_utility.insert_notes(:new.pers_id,
                                'PERSON',
                                'Employer Changed ',
                                get_user_id(v('APP_USER')),
                                sysdate,
                                :new.pers_id,
                                v_acc_id,
                                :old.entrp_id);

    end if;
--
-- check to see if this is an Account Holder
--
    if :new.relat_code = 1 then

--
-- check to see if demographics have changed
--
        if :new.first_name <> :old.first_name
        or :new.middle_name <> :old.middle_name
        or :new.last_name <> :old.last_name
        or :new.address <> :old.address
        or :new.city <> :old.city
        or :new.state <> :old.state
        or :new.zip <> :old.zip then
            v_first_name := :new.first_name;
            v_middle_name := :new.middle_name;
            v_last_name := :new.last_name;
            v_address := :new.address;
            v_city := :new.city;
            v_state := :new.state;
            v_zip := :new.zip;
            v_demo_changed := 'Y';
        end if;

        if :new.address <> :old.address
        or :new.city <> :old.city
        or :new.state <> :old.state
        or :new.zip <> :old.zip then
            pc_utility.insert_notes(:new.pers_id,
                                    'PERSON',
                                    'Address Changed Old:address '
                                    || :old.address
                                    || ' '
                                    || :old.city
                                    || ' '
                                    || :old.state
                                    || ' '
                                    || :old.zip,
                                    get_user_id(v('APP_USER')),
                                    sysdate,
                                    :new.pers_id,
                                    v_acc_id,
                                    :old.entrp_id);

        end if;

        if :new.first_name <> :old.first_name
        or :new.middle_name <> :old.middle_name
        or :new.last_name <> :old.last_name then
            pc_utility.insert_notes(:new.pers_id,
                                    'PERSON',
                                    'Name Changed Old Name is '
                                    || :old.first_name
                                    || ' '
                                    || :old.middle_name
                                    || ' '
                                    || :old.last_name,
                                    get_user_id(v('APP_USER')),
                                    sysdate,
                                    :new.pers_id,
                                    v_acc_id,
                                    :old.entrp_id);
        end if;
 -- Commented by Swamy on 18/02/2020 due to Mutating Trigger Production issue.
 -- The below code is moved to Apex Screen 2 (Personal Information) in the Process update_online_users
/*IF :NEW.SSN <> :OLD.SSN THEN
   v_ssn_changed := 'Y';

   UPDATE online_users
   SET    tax_id = :NEW.SSN
   where  TAX_ID = :old.SSN;
   PC_UTILITY.INSERT_NOTES(:new.PERS_ID,'PERSON'
                           ,'SSN Changed Old SSN is '||:old.SSN
                           ,GET_USER_ID(V('APP_USER')),sysdate,:new.pers_id,v_acc_id,:old.entrp_id);

    -- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
  	 UPDATE Alert_Preferences
	    SET SSN = REPLACE(:NEW.SSN,'-')
	  WHERE SSN = REPLACE(:OLD.SSN,'-');

END IF;
*/
 -- Email changes in SAM should be captured into event_notification table only for Subscriber.
 -- Vanitha: We will send notification only if the email and phone number changed from online for the user
 -- We will not send email for changes to subscriber screen, changes to subscriber happen for EDI feeds and manual updates
/*IF :NEW.person_type = 'SUBSCRIBER' AND (:NEW.email <> :OLD.email)  THEN

   pc_notification2.INSERT_EVENTS(p_acc_id      =>  NULL ,
                                  p_pers_id     => :NEW.pers_id,
                                  p_event_name  => 'EMAIL',
                                  p_ENTITY_TYPE => 'PERSON',
                                  P_ENTITY_ID   =>  :NEW.pers_id ,
                                  p_ssn         => :NEW.ssn);

   pc_notification2.insert_audit_security_info(
                                  p_pers_id     => :NEW.pers_id,
                                  p_email       => :OLD.email,
                                  p_phone_no    => NULL,
                                  p_user_id     => :NEW.LAST_UPDATED_BY );
END IF;
-- Phone no changes in SAM should be captured into event_notification table only for Subscriber.
IF :NEW.person_type = 'SUBSCRIBER' AND (REPLACE(STRIP_BAD(:NEW.phone_day),'-') <> REPLACE(STRIP_BAD(:OLD.phone_day),'-')) THEN
    pc_notification2.INSERT_EVENTS(p_acc_id      =>  NULL ,
                                   p_pers_id     => :NEW.pers_id,
                                   p_event_name  => 'PHONE',
                                   p_ENTITY_TYPE => 'PERSON',
                                   P_ENTITY_ID   =>  :NEW.pers_id ,
                                   p_ssn         => :NEW.ssn);

    pc_notification2.insert_audit_security_info(
                                  p_pers_id     => :NEW.pers_id,
                                  p_email       => NULL,
                                  p_phone_no    => REPLACE(STRIP_BAD(:OLD.phone_day),'-'),
                                  p_user_id     => :NEW.LAST_UPDATED_BY );


END IF;
*/
-- END of Addition by swamy for Ticket#7920(Alert Notification) Sprint 21
--
-- only execute if there were changes
--
        if v_ssn_changed = 'Y'
        or v_demo_changed = 'Y' then

--
-- check the debit card existence/status
--
            begin
                select
                    status
                into v_debit_card_status
                from
                    card_debit
                where
                    card_id = :new.pers_id;

            exception
                when no_data_found then
                    v_debit_card_status := null;
            end;
--
-- get the Account Number from ACCOUNT
--
            begin
                select
                    acc_num,
                    account_type
                into
                    v_acc_num,
                    v_account_type
                from
                    account
                where
                    account.pers_id = nvl(:new.pers_main,
                                          :new.pers_id);

            exception
                when no_data_found then
                    null;
            end;
--

--
-- only record change for debit cards if status is not null
-- 1) debit card record not found, or
-- 2) debit card is closed
--
            if v_debit_card_status is not null
               or v_debit_card_status <> 3
            or v_account_type in ( 'HRA', 'FSA', 'COBRA' ) then

--
-- get the next update id
--
                select
                    eb_update_seq.nextval
                into v_update_id
                from
                    dual;

-- insert the row as unprocessed
--
                insert into debit_card_updates (
                    update_id,
                    pers_id,
                    first_name,
                    middle_name,
                    last_name,
                    ssn_oldval,
                    ssn_newval,
                    address,
                    city,
                    state,
                    zip,
                    acc_num,
                    date_changed,
                    demo_changed,
                    demo_processed,
                    acc_num_changed,
                    acc_num_processed
                ) values ( v_update_id,
                           :new.pers_id,
                           v_first_name,
                           v_middle_name,
                           v_last_name,
                           v_ssn_oldval,
                           v_ssn_newval,
                           v_address,
                           v_city,
                           v_state,
                           v_zip,
                           v_acc_num,
                           sysdate,
                           v_demo_changed,
                           'N',
                           'N',
                           'N' );

            end if;

        end if;

-- 6794: Added by Joshi for migrating data to ACN if any demographic info changed.
        if v_demo_changed = 'Y'
        or ( :new.ssn <> :old.ssn )
        or ( :new.email <> :old.email )
        or ( :new.birth_date <> :old.birth_date )
        or ( :new.gender <> :old.gender ) then
            begin
                select
                    acc_id,
                    acc_num,
                    account_type
                into
                    v_acc_id,
                    v_acc_num,
                    v_account_type
                from
                    account
                where
                    pers_id = :new.pers_id;

            exception
                when others then
                    null;
            end;

            if
                v_acc_id is not null
                and pc_account.is_migrated(v_acc_id) = 'Y'
            then
                insert into acn_employee_migration --EMPLOYEE_MIGRATE_STAGE
                 (
                    mig_seq_no,
                    acc_id,
                    pers_id,
                    account_type,
                    first_name,
                    middle_name,
                    last_name,
                    gender,
                    ssn,
                    birth_date,
                    address1,
                    city,
                    state,
                    zip,
                    phone_day,
                    phone_even,
                    email_address,
                    action_type,
                    creation_date,
                    created_by
                ) values ( mig_seq.nextval,
                           v_acc_id,
                           :new.pers_id,
                           v_account_type,
                           :new.first_name,
                           :new.middle_name,
                           :new.last_name,
                           :new.gender,
                           replace(:new.ssn,
                                   '-'),
                           to_char(:new.birth_date,
                                   'MM/DD/YYYY'),
                           :new.address,
                           :new.city,
                           :new.state,
                           :new.zip,
                           :new.phone_day,
                           :new.phone_even,
                           :new.email,
                           'U',
                           sysdate,
                           0 );

            end if;

        end if;

    end if;

 -- Added by Swamy for Ticket#9374 on 01/10/2020
    if :new.ssn <> :old.ssn then
        pc_person.insert_person_audit(:new.pers_id,
                                      :old.ssn,
                                      :new.ssn,
                                      get_user_id(v('APP_USER')),
                                      sysdate);
    end if;

end;
/

alter trigger samqa.debit_card_on_update enable;


-- sqlcl_snapshot {"hash":"eeb11f5992ae708cf80cb852fcfb9c7c9d859762","type":"TRIGGER","name":"DEBIT_CARD_ON_UPDATE","schemaName":"SAMQA","sxml":""}