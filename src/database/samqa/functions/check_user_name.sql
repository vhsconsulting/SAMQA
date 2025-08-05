create or replace function samqa.check_user_name (
    p_user_name in varchar2
) return varchar2 is
begin
    if
        ( regexp_like(
            upper(p_user_name),
            '^.*[A-Z].*$'
        )
        or (
            regexp_like(
                upper(p_user_name),
                '^.*[A-Z].*$'
            )
            and regexp_like(
                upper(p_user_name),
                '^.*[0-9].*$'
            )
        ) )
        and not regexp_like(
            upper(p_user_name),
            '^.*[^A-Z,0-9].*$'
        )
    then
        return 'Y';
    else
        return 'N';
    end if;
end;
/


-- sqlcl_snapshot {"hash":"84b38d5aa2c0bccb6c7590d155e6ff8c4f51e8c6","type":"FUNCTION","name":"CHECK_USER_NAME","schemaName":"SAMQA","sxml":""}