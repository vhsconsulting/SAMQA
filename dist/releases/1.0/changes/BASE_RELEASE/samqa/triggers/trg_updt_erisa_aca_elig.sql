-- liquibase formatted sql
-- changeset SAMQA:1754374166181 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\trg_updt_erisa_aca_elig.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/trg_updt_erisa_aca_elig.sql:null:624bab4ae1f722fd80e7af76a0316f31bbf1f452:create

create or replace editionable trigger samqa.trg_updt_erisa_aca_elig before
    insert or update on samqa.erisa_aca_eligibility
    for each row
declare
    ls_last_update_user number;
    l_current_datetime  date;
begin
    ls_last_update_user := get_user_id(sys_context('APEX$SESSION', 'APP_USER'));
    l_current_datetime := sysdate;
    if inserting then
        if ls_last_update_user is not null then
            :new.created_by := ls_last_update_user;
            :new.last_updated_by := ls_last_update_user;
            :new.creation_date := l_current_datetime;
            :new.last_update_date := l_current_datetime;
        end if;
    elsif updating then
        if ls_last_update_user is not null then
            :new.last_updated_by := ls_last_update_user;
            :new.last_update_date := l_current_datetime;
        end if;
    end if;

end;
/

alter trigger samqa.trg_updt_erisa_aca_elig enable;

