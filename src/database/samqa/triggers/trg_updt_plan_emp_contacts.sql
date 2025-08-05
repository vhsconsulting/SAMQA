create or replace editionable trigger samqa.trg_updt_plan_emp_contacts before
    insert or update on samqa.plan_employer_contacts
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

alter trigger samqa.trg_updt_plan_emp_contacts enable;


-- sqlcl_snapshot {"hash":"f0afba342712d637efc69b5dc7e435b37f394b55","type":"TRIGGER","name":"TRG_UPDT_PLAN_EMP_CONTACTS","schemaName":"SAMQA","sxml":""}