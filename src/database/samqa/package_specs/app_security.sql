create or replace package samqa.app_security is
    function sentry_basic_auth return boolean;

    function sam_auth (
        p_username in varchar2,
        p_password in varchar2
    ) return boolean;

end app_security;
/


-- sqlcl_snapshot {"hash":"4d3201b6018f34c50134cc3a4e50e88b4039e381","type":"PACKAGE_SPEC","name":"APP_SECURITY","schemaName":"SAMQA","sxml":""}