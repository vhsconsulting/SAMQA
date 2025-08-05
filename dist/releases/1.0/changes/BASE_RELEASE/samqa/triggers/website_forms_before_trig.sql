-- liquibase formatted sql
-- changeset SAMQA:1754374166266 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\website_forms_before_trig.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/website_forms_before_trig.sql:null:ab4fc7c0296f059564c4ca591a6f04cbb265f611:create

create or replace editionable trigger samqa.website_forms_before_trig before
    update or insert on samqa.website_forms
    referencing
            new as new
            old as old
    for each row
declare
    tmpvar number;
begin
    if inserting then
        :new.creation_date := sysdate;
        :new.created_by := get_user_id(v('APP_USER'));
    end if;

    :new.file_name := replace(:new.file_name,
                              ' ');
    :new.last_updated_date := sysdate;
    :new.last_updated_by := get_user_id(v('APP_USER'));
exception
    when others then
        null;
end;
/

alter trigger samqa.website_forms_before_trig enable;

