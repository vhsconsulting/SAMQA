create or replace function samqa.vedc_sentry return boolean is
    l_app_id number := apex_application.g_flow_id;
begin
    if apex_custom_auth.is_session_valid then
        return true;
    end if;
  -- check if a developer is using the system log him directly.
    apex_application.g_flow_id := 4000;
    if apex_custom_auth.is_session_valid then
        apex_application.g_instance := apex_custom_auth.get_session_id_from_cookie;
        apex_application.g_user := apex_custom_auth.get_username;
    end if;

    apex_application.g_flow_id := l_app_id;
    if ( apex_application.g_user is not null ) then
        apex_custom_auth.post_login(
            p_uname      => apex_application.g_user,
            p_session_id => apex_application.g_instance,
            p_app_page   => apex_application.g_flow_id
                          || ':'
                          || nvl(apex_application.g_flow_step_id, 0)
        );

        return true;
    end if;

    return false;
end;
/


-- sqlcl_snapshot {"hash":"a36e23206b2ed8d339319adc7e4f07cd99d42d48","type":"FUNCTION","name":"VEDC_SENTRY","schemaName":"SAMQA","sxml":""}