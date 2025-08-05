-- liquibase formatted sql
-- changeset SAMQA:1754374166203 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\trg_updt_plan_emp_contacts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/trg_updt_plan_emp_contacts.sql:null:d45d31e275bd38e77284999b0667c9d6464785aa:create

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

