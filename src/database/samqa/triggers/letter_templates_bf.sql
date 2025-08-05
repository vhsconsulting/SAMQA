create or replace editionable trigger samqa.letter_templates_bf before
    insert or update on samqa.letter_templates
    for each row
begin
-- Added by Swamy for Ticket#9669
    if inserting then
        :new.created_by := get_user_id(v('APP_USER'));
        :new.creation_date := sysdate;
    elsif updating then
        :new.last_updated_by := get_user_id(v('APP_USER'));
        :new.last_update_date := sysdate;
    end if;
end;
/

alter trigger samqa.letter_templates_bf enable;


-- sqlcl_snapshot {"hash":"fcd7d9266534cc07af1d49f4f3848ff0fc5399c9","type":"TRIGGER","name":"LETTER_TEMPLATES_BF","schemaName":"SAMQA","sxml":""}