create or replace function samqa.get_user_name_details (
    p_user_name varchar2
) return varchar2 is
    l_user_name varchar2(50);
begin
    select
        nvl(first_name
            || ' '
            || last_name, p_user_name)
    into l_user_name
    from
        employee  e,
        sam_users s
    where
            e.user_id = s.user_id
        and term_date is null
        and upper(user_name) = upper(p_user_name);

    return l_user_name;
exception
    when no_data_found then
        return p_user_name;
    when others then
        return p_user_name;
end;
/


-- sqlcl_snapshot {"hash":"bfa23ed43c2f3ba0ec9f10da0778c022024e60e1","type":"FUNCTION","name":"GET_USER_NAME_DETAILS","schemaName":"SAMQA","sxml":""}