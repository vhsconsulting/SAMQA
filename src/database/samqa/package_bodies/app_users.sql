create or replace package body samqa.app_users is

    procedure set_last_activity_date (
        p_user in varchar2 default v('APP_USER')
    ) is
        pragma autonomous_transaction;
        l_current_user varchar2(30);
    begin
        l_current_user := nvl(p_user,
                              v('APP_USER'));
        update sam_users
        set
            last_activity_date = sysdate
        where
            upper(user_name) = l_current_user;

        commit;
    end;

    function is_session_valid return boolean is
        l_current_user     varchar2(30);
        l_is_session_valid varchar2(1);
    begin
        l_current_user := v('APP_USER');
        select
            case
                when ( last_activity_date + app_users.c_session_timeout_minutes / 1440 ) < sysdate then
                    'N'
                else
                    'Y'
            end
        into l_is_session_valid
        from
            sam_users
        where
            upper(user_name) = l_current_user;

        if l_is_session_valid = 'N' then
            return false;
        else
            return true;
        end if;
    end;

    procedure set_sso_cookie (
        p_user_name varchar2
    ) is
          --
          --  sets suite cookie, called from check_credentials only
          --
        l_t_id number := null;
    begin
        owa_cookie.send(
            name    => g_cookie_name,
            value   => upper(p_user_name)
                     || '^'
                     || v('APP_SESSION'),
            expires => null,
            path    => '/'
        );
    end set_sso_cookie;

    function session_sentry return boolean is
        l_result boolean;
    begin
        if apex_application.g_flow_step_id = 101 /* should be the number of the login page */ then
            return true;
        else
            l_result := sentry;
            return l_result;
        end if;
    end session_sentry;

    function sentry return boolean as

        l_current_sid number;
        l_username    varchar2(3200) := null;
        l_cookie      owa_cookie.cookie := owa_cookie.get(g_cookie_name);
        l_result      apex_plugin.t_authentication_inval_result;
        l_session_id  number;
    begin
        l_session_id := wwv_flow_custom_auth_std.get_session_id_from_cookie;
        if l_session_id is null then
            owa_util.redirect_url(g_logout_url);
            return true;
        end if;
        begin
            l_username := upper(wwv_flow_utilities.string_to_table2(
                l_cookie.vals(1),
                sep => '^'
            )(1));

            l_current_sid := upper(wwv_flow_utilities.string_to_table2(
                l_cookie.vals(1),
                sep => '^'
            )(2));

        exception
            when no_data_found then
                l_username := null;
            when others then
                return false;
        end;

        if l_username is null
           or l_current_sid is null then
            return true;
        else
       --
       -- if the apex session from the cookie is valid, re-instantiate the session
       --
       -- pc_log.log_error('SENTRY','l_current_sid:'||l_current_sid);

            if apex_custom_auth.is_session_valid then
                wwv_flow.g_instance := l_current_sid;
                if l_username = apex_custom_auth.get_username then
                    pc_log.log_error('SENTRY', 'User name seems to match ');
                    apex_custom_auth.define_user_session(
                        p_user       => l_username,
                        p_session_id => l_current_sid
                    );
               -- pc_log.log_error('SENTRY','Established session');
                    return true;
                else
                    if v('APP_USER') = 'nobody'
                    or v('APP_USER') is null then
                        pc_log.log_error('SENTRY',
                                         'v(APP_USER:' || v('APP_USER'));
                        apex_authentication.logout(
                            p_session_id => v('APP_SESSION'),
                            p_app_id     => v('APP_ID')
                        );

                        owa_util.redirect_url(g_logout_url);
                        return true;
                    end if;
                end if;

            else
                pc_log.log_error('SENTRY', 'session is not valid , user name : ' || apex_custom_auth.get_username);
                return true;
            end if;
        end if;

    exception
        when others then
            pc_log.log_error('SENTRY', 'SQLERRM' || sqlerrm);
            return false;
    end sentry;

    procedure expire_sam_cookie is
        l_t_id number := null;
    begin
        htp.init;
       -- pc_log.log_error('SENTRY','expire_sam_cookie:');

        owa_util.mime_header('text/html', false);
        owa_cookie.send(
            name    => g_cookie_name,
            value   => 'user_logged_out',
            expires => sysdate - 100,
            path    => '/'
        );

    end expire_sam_cookie;

    procedure sam_logout as

        l_sqlerrm               varchar2(4000) default null;
        l_user_name             varchar2(400) default null;
        l_target_instance       varchar2(400) default null;
        l_target_url            varchar2(4000) default null;
        l_target_app_alias      varchar2(4000) default null;
        l_target_app_id         number default null;
        l_target_logout_page_id number default null;
        l_last_instance         varchar2(400) default null;
        l_last_url              varchar2(4000) default null;
        l_last_app_id           number default null;
        l_calling_app_id        number default v('APP_ID');
        l_calling_instance      varchar2(400) default null;
        l_script                varchar2(400) default '/pls/htmldb';
        l_host                  varchar2(400) default owa_util.get_cgi_env('HTTP_HOST');
        l_app_cnt               number default null;
        l_logout_cnt            number := 0;
        l_app_found             boolean := false;
    begin
        expire_sam_cookie;
        apex_util.set_session_lifetime_seconds(-1);
      --apex_custom_auth.logout_then_go_to_url (p_args => 103||':'||g_logout_url);

        wwv_flow.g_unrecoverable_error := true;
    exception
        when others then
            l_sqlerrm := sqlerrm;
         -- pc_log.log_error('SENTRY','Error in logout :'||l_sqlerrm);

        -- consider logging exceptions to a debug table from here

    end sam_logout;

    procedure set_logout_date is

        l_cookie    owa_cookie.cookie := owa_cookie.get(g_cookie_name);
        l_user_name varchar2(400) default null;
    begin
         -- pc_log.log_error('SENTRY','post_logout:');

        l_user_name := lower(wwv_flow_utilities.string_to_table2(
            l_cookie.vals(1),
            sep => '^'
        )(1));

        update sam_users
        set
            logout_date = sysdate
        where
            user_name = l_user_name;

    end set_logout_date;

end app_users;
/


-- sqlcl_snapshot {"hash":"484ed26b15568872d09b29ffc6b08e9b86f1601a","type":"PACKAGE_BODY","name":"APP_USERS","schemaName":"SAMQA","sxml":""}