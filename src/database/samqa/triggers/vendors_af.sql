create or replace editionable trigger samqa.vendors_af after
    update on samqa.vendors
    for each row
begin
    if :old.address1 <> :new.address1
    or :old.address2 <> :new.address2
    or :old.city <> :new.city
    or :old.state <> :new.state
    or :old.zip <> :new.zip then
        insert into vendors_history (
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
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( :old.vendor_id,
                   :old.orig_sys_vendor_ref,
                   :old.vendor_name,
                   :old.address1,
                   :old.address2,
                   :old.city,
                   :old.state,
                   :old.zip,
                   :old.expense_account,
                   :old.acc_num,
                   :old.vendor_in_peachtree,
                   sysdate,
                   get_user_id(v('APP_USER')),
                   sysdate,
                   get_user_id(v('APP_USER')) );

    end if;
end;
/

alter trigger samqa.vendors_af enable;


-- sqlcl_snapshot {"hash":"2a759b640ca3dcf56d26c6b11b8f3c16ee14d41d","type":"TRIGGER","name":"VENDORS_AF","schemaName":"SAMQA","sxml":""}