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


-- sqlcl_snapshot {"hash":"650ef796b9c5993dfc6899a3cbe280cd06a18792","type":"TRIGGER","name":"WEBSITE_FORMS_BEFORE_TRIG","schemaName":"SAMQA","sxml":""}