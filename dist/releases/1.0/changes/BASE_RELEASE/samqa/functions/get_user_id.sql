-- liquibase formatted sql
-- changeset SAMQA:1754373927999 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_user_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_user_id.sql:null:ce127d8950f59ad0663b43609ff99208584527d5:create

create or replace function samqa.get_user_id (
    p_user_name varchar2
) return number is
    l_user_id number;
begin
    select
        user_id
    into l_user_id
    from
        sam_users
    where
        user_name = lower(p_user_name);

    return l_user_id;
exception
    when others then
        return null;
end;
/

