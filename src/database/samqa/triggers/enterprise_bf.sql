create or replace editionable trigger samqa.enterprise_bf before
    insert or update on samqa.enterprise
    for each row
declare
-- Start Additon by Swamy for Ticket#6794
    v_first_name       contact.first_name%type;
    v_last_name        contact.last_name%type;
    v_gender           contact.gender%type;
    v_flg_mig          account.migrated_flag%type;
    v_acc_id           account.acc_id%type;
    v_acc_num          account.acc_num%type;
    v_account_type     account.account_type%type;
    v_plan_code        number;
    v_process_status   varchar2(100);
    v_error_message    varchar2(500);
    v_subscribe_to_acn varchar2(1);
-- End of Additon by Swamy for Ticket#6794
begin
  -- Carriage returns were being written in address which causes
  -- metavante to reject the files
    :new.address := replace(
        replace(:new.address,
                chr(10),
                ' '),
        chr(13),
        ' '
    );

    :new.entrp_code := regexp_replace(:new.entrp_code,
                                      '[^[:alnum:]]+',
                                      '');
    if :new.entrp_code <> :old.entrp_code then
        update online_users
        set
            tax_id = replace(:new.entrp_code,
                             '-')
        where
                tax_id = replace(:old.entrp_code,
                                 '-')
            and tax_id is not null;

        update online_users
        set
            tax_id = replace(:new.entrp_code,
                             '-')
        where
                find_key = pc_entrp.get_acc_num(:new.entrp_id)
            and tax_id is null;

        update contact
        set
            entity_id = replace(:new.entrp_code,
                                '-')
        where
            entity_id = replace(:old.entrp_code,
                                '-');

    end if;

-- Start Additon by Swamy for Ticket#6794
    if updating then
   -- Get Acc_Id
        v_acc_id := null;
        v_account_type := null;
        v_plan_code := null;
        v_flg_mig := null;
        v_acc_num := null;
        v_subscribe_to_acn := null;
        for j in (
            select
                a.acc_id,
                a.migrated_flag,
                a.plan_code,
                a.account_type,
                a.acc_num,
                p.subscribe_to_acn
            from
                account            a,
                account_preference p
            where
                    a.entrp_id = :new.entrp_id
                and a.acc_id = p.acc_id
                and a.entrp_id = p.entrp_id
                and a.account_status in ( 1, 3 )
        ) loop
            v_acc_id := j.acc_id;
            v_flg_mig := nvl(j.migrated_flag, 'N');
            v_plan_code := j.plan_code;
            v_account_type := j.account_type;
            v_acc_num := j.acc_num;
            v_subscribe_to_acn := nvl(j.subscribe_to_acn, 'N');
        end loop;

        if (
            nvl(v_acc_id, -1) <> -1
            and nvl(v_flg_mig, 'N') = 'Y'
            and nvl(v_plan_code, 0) = 1
            and v_account_type = 'HSA'
            and v_subscribe_to_acn = 'Y'
        ) then
       -- Insert the record into the staging table only if the employer is already migrated to ACN and demographic information is changed/updated.
            if ( :new.name <> :old.name
            or :new.address <> :old.address
            or :new.city <> :old.city
            or :new.state <> :old.state
            or :new.zip <> :old.zip
            or :new.entrp_email <> :old.entrp_email
            or :new.entrp_phones <> :old.entrp_phones
            or :new.entrp_contact <> :old.entrp_contact ) then
                v_first_name := null;
                v_last_name := null;
                v_gender := null;
		 -- Get The Contact Details
                pc_contact.get_names(
                    p_entrp_code     => :new.entrp_code,
                    p_entrp_contact  => :new.entrp_contact,
                    p_first_name     => v_first_name,
                    p_last_name      => v_last_name,
                    p_gender         => v_gender,
                    x_process_status => v_process_status,
                    x_error_message  => v_error_message
                );

                if
                    nvl(v_first_name, '*') = '*'
                    and nvl(v_last_name, '*') = '*'
                then
                    v_first_name := nvl(v_first_name,
                                        substr(:new.name,
                                               1,
                                               29));
                end if;

                insert into acn_employer_migration (
                    entrp_code,
                    entrp_id,
                    company_name,
                    address,
                    city,
                    state,
                    zip,
                    first_name,
                    last_name,
                    gender,
                    entrp_phones,
                    entrp_email,
                    entrp_fax,
                    batch_number,
                    acc_id,
                    acc_num,
                    account_type,
                    action_type,
                    process_status,
                    creation_date,
                    created_by
                ) values ( :new.entrp_code,
                           :new.entrp_id,
                           :new.name,
                           :new.address,
                           :new.city,
                           :new.state,
                           :new.zip,
                           v_first_name,
                           v_last_name,
                           v_gender,
                           :new.entrp_phones,
                           :new.entrp_email,
                           :new.entrp_fax,
                           null,
                           v_acc_id,
                           v_acc_num,
                           v_account_type,
                           'U',-- 'I' = Insert,'U'= Update , 'C' = Changed(When the plan is changed from HSA to any other plan
                           'N',
                           sysdate,
                           0 );

            end if;
        end if;

   -- End of Additon by Swamy for Ticket#6794
   -- Added by Swamy for Ticket#7732
   -- The Name and Address change in Enterprise table should be populated in Vendors and Invoice_parameters Table.
        if nvl(:new.name,
               'N') <> nvl(:old.name,
                           'N')
        or nvl(:new.address,
               'N') <> nvl(:old.address,
                           'N')
        or nvl(:new.city,
               'N') <> nvl(:old.city,
                           'N')
        or nvl(:new.state,
               'N') <> nvl(:old.state,
                           'N')
        or nvl(:new.zip,
               'N') <> nvl(:old.zip,
                           'N') then
            update vendors
            set
                vendor_name = :new.name,
                address1 = :new.address,
                city = :new.city,
                state = :new.state,
                zip = :new.zip,
                last_updated_by = :new.last_updated_by,
                last_update_date = sysdate
            where
                acc_id = v_acc_id;

            update invoice_parameters
            set
                billing_name = :new.name,
                billing_address = :new.address,
                billing_city = :new.city,
                billing_state = :new.state,
                billing_zip = :new.zip,
                last_updated_by = :new.last_updated_by,
                last_update_date = sysdate
            where
                entity_id = :new.entrp_id;

        end if;

    end if;

end;
/

alter trigger samqa.enterprise_bf enable;


-- sqlcl_snapshot {"hash":"b50f9ad1c305ab0bc36a2e327c2bf7b89b235ea3","type":"TRIGGER","name":"ENTERPRISE_BF","schemaName":"SAMQA","sxml":""}