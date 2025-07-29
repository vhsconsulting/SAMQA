create or replace editionable trigger samqa.events_update_trig before
    update on samqa.events
    referencing
            new as new
            old as old
    for each row
declare
    tmpvar number;
begin
    select
        user_id
    into tmpvar
    from
        sam_users
    where
        upper(user_name) = upper(v('APP_USER'));

    :new.last_update_date := sysdate;
    :new.last_updated_by := tmpvar;
exception
    when others then
        null;
end;
/

alter trigger samqa.events_update_trig enable;


-- sqlcl_snapshot {"hash":"d671abd4584b0ed782a87f7f83c87d49fd399470","type":"TRIGGER","name":"EVENTS_UPDATE_TRIG","schemaName":"SAMQA","sxml":""}