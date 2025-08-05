-- liquibase formatted sql
-- changeset SAMQA:1754373927287 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_assigned_uname.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_assigned_uname.sql:null:94e7d2b39c88832450d3ebde15ab40526c46cd9f:create

create or replace function samqa.get_assigned_uname (
    p_user_id in varchar2
) return varchar2 is
    tmpvar varchar2(30);
begin
    select
        full_name
    into tmpvar
    from
        crm_users
    where
        "id" = p_user_id;

    return tmpvar;
exception
    when no_data_found then
        return null;
    when others then
       -- Consider logging the error and then re-raise
        raise;
end get_assigned_uname;
/

