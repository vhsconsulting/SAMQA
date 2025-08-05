create or replace editionable trigger samqa.employer_deposits_bf before
    insert or update on samqa.employer_deposits
    for each row
begin
    if inserting then
        :new.creation_date := sysdate;
        :new.created_by := get_user_id(v('APP_USER'));
    end if;

    :new.last_update_date := sysdate;
    :new.last_updated_by := get_user_id(v('APP_USER'));
end;
/

alter trigger samqa.employer_deposits_bf enable;


-- sqlcl_snapshot {"hash":"b2f294298b1041710953ca81a28339ba5435e5da","type":"TRIGGER","name":"EMPLOYER_DEPOSITS_BF","schemaName":"SAMQA","sxml":""}