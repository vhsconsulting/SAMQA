create or replace editionable trigger samqa.sam_users_bf before
    insert or update on samqa.sam_users
    for each row
begin
    if inserting then
        :new.created_by := get_user_id(v('APP_USER'));
        :new.creation_date := sysdate;
    end if;

    :new.last_updated_by := get_user_id(v('APP_USER'));
    :new.last_update_date := sysdate;
end;
/

alter trigger samqa.sam_users_bf enable;


-- sqlcl_snapshot {"hash":"6c303273112671ec61e468851f45dcd6c8975494","type":"TRIGGER","name":"SAM_USERS_BF","schemaName":"SAMQA","sxml":""}