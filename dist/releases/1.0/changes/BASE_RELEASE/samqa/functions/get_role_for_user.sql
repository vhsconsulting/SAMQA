-- liquibase formatted sql
-- changeset SAMQA:1754373927892 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_role_for_user.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_role_for_user.sql:null:bea3965db07e0ad15ace9259b378e970f1030b29:create

create or replace function samqa.get_role_for_user (
    p_user_name in varchar2
) return varchar2 is
    l_role_name varchar2(30);
begin
    select
        role_name
    into l_role_name
    from
        sam_roles
    where
        role_id in (
            select
                role_id
            from
                sam_users
            where
                upper(user_name) = ( p_user_name )
        );

    return l_role_name;
exception
    when others then
        return null;
end;
/

