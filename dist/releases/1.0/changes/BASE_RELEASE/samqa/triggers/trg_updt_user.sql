-- liquibase formatted sql
-- changeset SAMQA:1754374166219 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\trg_updt_user.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/trg_updt_user.sql:null:01cd9aeaa6c4c9c059d892e5a2973af38ba0218a:create

create or replace editionable trigger samqa.trg_updt_user before
    update on samqa.rate_plan_detail
    for each row
declare
    ls_last_update_user number;
begin
    ls_last_update_user := get_user_id(sys_context('APEX$SESSION', 'APP_USER'));
    if ls_last_update_user is not null then
        :new.last_updated_by := ls_last_update_user;
    end if;
    :new.last_update_date := sysdate;
end;
/

alter trigger samqa.trg_updt_user enable;

