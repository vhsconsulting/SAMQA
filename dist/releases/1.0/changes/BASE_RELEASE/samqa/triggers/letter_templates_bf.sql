-- liquibase formatted sql
-- changeset SAMQA:1754374165865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\letter_templates_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/letter_templates_bf.sql:null:faa1a5bbc3cb925e5d1d0a5878420de824ba5db8:create

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

