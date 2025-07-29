create or replace function samqa.sam_authenticate (
    p_username in varchar2,
    p_password in varchar2
) return boolean is

    l_password        varchar2(4000);
    l_stored_password varchar2(4000);
    l_expires_on      date;
    l_status          varchar2(3200);
    l_count           number;
    l_failed_logins   number;
begin

--   app_users.expire_sam_cookie;
-- First, check to see if the user is in the user table
    select
        count(*)
    into l_count
    from
        sam_users
    where
        user_name = lower(p_username);

    pc_log.log_error('AUTHENTICATE', 'p_username ' || p_username);
    if l_count > 0 then
  -- First, we fetch the stored hashed password and expire date
        select
            password,
            expires_on,
            status,
            failed_logins
        into
            l_stored_password,
            l_expires_on,
            l_status,
            l_failed_logins
        from
            sam_users
        where
            user_name = lower(p_username);

  -- Next, we check to see if the user's account is expired
  -- If it is, return FALSE
        if ( l_expires_on > sysdate
        or l_status = 'A' ) then
  -- if l_status = 'A' then
    -- If the account is not expired, we have to apply the custom hash
    -- function to the password
            l_password := sam_password_hash(
                lower(p_username),
                p_password
            );
            pc_log.log_error('AUTHENTICATE', 'password '
                                             || l_password
                                             || ' stored password '
                                             || l_stored_password);

    -- Finally, we compare them to see if they are the same and return
    -- either TRUE or FALSE
            if nvl(l_failed_logins, 0) > 3 then
                apex_util.set_authentication_result(6); -- Maximum Login Attempts Exceeded
                apex_util.set_custom_auth_status(p_status => 'Maximum Login Attempts Exceeded');
       --htp.p('Maximum Login Attempts Exceeded');
                return false;
            elsif l_password = l_stored_password then
                update sam_users
                set
                    failed_logins = 0,
                    last_activity_date = sysdate
                where
                    user_name = lower(p_username);

                pc_log.log_error('AUTHENTICATE', 'login success');
                owa_util.mime_header('text/html', false);
                app_users.set_sso_cookie(p_username);
     -- ns_auth_aux.set_sso_cookie(p_username);

                apex_util.set_authentication_result(0); -- Normal, successful authentication


                return true;
            else
                update sam_users
                set
                    failed_logins = nvl(failed_logins, 0) + 1
                where
                    user_name = lower(p_username);

                apex_util.set_authentication_result(4); -- Incorrect Password
                apex_util.set_custom_auth_status(p_status => 'Invalid Login Credentials');
                return false;
            end if;

        else
            apex_util.set_authentication_result(3);
            return false;
        end if;

    else
        apex_util.set_authentication_result(3);

  -- The username provided is not in the DEMO_USERS table
        return false;
    end if;

    commit;
end;
/


-- sqlcl_snapshot {"hash":"2627622548da4821727990fff615ebb6b980722e","type":"FUNCTION","name":"SAM_AUTHENTICATE","schemaName":"SAMQA","sxml":""}