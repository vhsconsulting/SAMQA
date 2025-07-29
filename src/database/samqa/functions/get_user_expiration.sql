create or replace function samqa.get_user_expiration (
    p_user_name in varchar2
) return date is
    l_expiry_date date;
begin
-- pc_log.log_error('GET_USER_EXPIRATION, USER NAME',p_user_name);
    for x in (
        select
            expires_on,
            user_id,
            user_name
        from
            sam_users
        where
            user_name = lower(p_user_name)
    ) loop
        l_expiry_date := x.expires_on;
        insert into user_login_history (
            user_id,
            user_name,
            login_date,
            creation_date
        ) values ( x.user_id,
                   x.user_name,
                   sysdate,
                   sysdate );

    end loop;
-- pc_log.log_error('GET_USER_EXPIRATION, EXPIRY DATE ',l_expiry_date);
    return l_expiry_date;
end;
/


-- sqlcl_snapshot {"hash":"7577cb51748c37d8c354038b229fa9bd21a51070","type":"FUNCTION","name":"GET_USER_EXPIRATION","schemaName":"SAMQA","sxml":""}