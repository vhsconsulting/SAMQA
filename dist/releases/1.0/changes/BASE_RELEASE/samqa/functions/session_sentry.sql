-- liquibase formatted sql
-- changeset SAMQA:1754373928507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\session_sentry.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/session_sentry.sql:null:5eaaefd96b706f94e3e507e358f4d9cb78efdfa6:create

create or replace function samqa.session_sentry (
    puser in varchar2 default 'APEX_PUBLIC_USER'
) return boolean is
    vusername varchar2(512);
    vsession  number;
    c         owa_cookie.cookie;
begin
  -- extract user from HTTP header
 -- vUsername := UPPER(owa_util.get_cgi_env('REMOTE_USER'));
    vusername := apex_custom_auth.get_username;

     -- extract session id
--  vSession := wwv_flow_custom_auth_std.get_session_id_from_cookie;
    vsession := v('APP_SESSION');

  -- check that the executing user account is the
  -- same as the apex application user, and that
  -- a username was populated in the header
    if user^= upper(puser)
       or vusername is null then
        return false;
    end if;

  -- Get SessionId.
  -- Check Application Session Cookie.

    if wwv_flow_custom_auth_std.is_session_valid then
        apex_application.g_instance := vsession;

    -- check requeted username matches session username
        if vusername = wwv_flow_custom_auth_std.get_username then
            wwv_flow_custom_auth.define_user_session(
                p_user       => vusername,
                p_session_id => vsession
            );
            return true;
        else
      -- Unset the Session Cookie and redirect back here to take other branch.
            wwv_flow_custom_auth_std.logout(
                p_this_flow           => v('FLOW_ID'),
                p_next_flow_page_sess => v('FLOW_ID')
                                         || ':'
                                         || nvl(
                    v('FLOW_PAGE_ID'),
                    0
                )
                                         || ':'
                                         || vsession
            );
      -- Tell Apex Engine to quit.
            apex_application.g_unrecoverable_error := true;
            return false;
        end if;

    else
    -- Application Session Cookie not valid --> Define a new Apex Session.
        wwv_flow_custom_auth.define_user_session(
            p_user       => vusername,
            p_session_id => wwv_flow_custom_auth.get_next_session_id
        );
    -- Tell Apex Engine to quit.
        apex_application.g_unrecoverable_error := true;
        if owa_util.get_cgi_env('REQUEST_METHOD') = 'GET' then
            wwv_flow_custom_auth.remember_deep_link(p_url => 'f?'
                                                             || wwv_flow_utilities.url_decode2(owa_util.get_cgi_env('QUERY_STRING')))
                                                             ;
        else
            wwv_flow_custom_auth.remember_deep_link(p_url => 'f?p='
                                                             || to_char(apex_application.g_flow_id)
                                                             || ':'
                                                             || to_char(nvl(apex_application.g_flow_step_id, 0))
                                                             || ':'
                                                             || to_char(apex_application.g_instance));
        end if;
    -- Register the Session in Apex Sessions Table, set Cookie, redirect back.
        wwv_flow_custom_auth_std.post_login(
            p_uname      => vusername,
            p_session_id => nv('APP_SESSION'),
            p_flow_page  => apex_application.g_flow_id
                           || ':'
                           || nvl(apex_application.g_flow_step_id, 0)
        );

        return false;
    end if;

end session_sentry;
/

