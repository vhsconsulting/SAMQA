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


-- sqlcl_snapshot {"hash":"68da10137b6d7ea027eec878a48549c7a41e90fc","type":"TRIGGER","name":"TRG_UPDT_ERISA_ACA_ELIG","schemaName":"SAMQA","sxml":""}