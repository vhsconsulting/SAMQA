-- liquibase formatted sql
-- changeset SAMQA:1754374166112 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\sam_users_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/sam_users_bf.sql:null:09cf66cb5b995ae5b7dfb3b42b9812be5855be80:create

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

