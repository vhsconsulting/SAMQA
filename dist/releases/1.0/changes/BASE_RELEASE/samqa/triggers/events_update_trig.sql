-- liquibase formatted sql
-- changeset SAMQA:1754374165515 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\events_update_trig.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/events_update_trig.sql:null:8208c7bc96701a6e307b3f666aa05cb914340832:create

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

