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


-- sqlcl_snapshot {"hash":"5d9243455454ba4f78d610032eec68cf54cc3e76","type":"FUNCTION","name":"GET_ROLE_ID","schemaName":"SAMQA","sxml":""}