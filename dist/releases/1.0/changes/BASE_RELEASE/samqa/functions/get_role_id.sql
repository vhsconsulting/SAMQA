-- liquibase formatted sql
-- changeset SAMQA:1754373927911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_role_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_role_id.sql:null:5d9243455454ba4f78d610032eec68cf54cc3e76:create

create or replace function samqa.get_role_id (
    p_user_name in varchar2
) return varchar2 is
    l_role_id number;
begin
    select
        role_id
    into l_role_id
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

    return l_role_id;
exception
    when others then
        return null;
end;
/

