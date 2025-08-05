-- liquibase formatted sql
-- changeset SAMQA:1754374133293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\app_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/app_users.sql:null:c6612a2e42611dc43d896614d9e414be41125240:create

create or replace package samqa.app_users is
    c_session_timeout_minutes constant number(2, 0) := 60;
    g_cookie_name constant varchar2(30) := 'SAM_SESSION';
    g_logout_url constant varchar2(255) := 'https://sam.sterlinghsa.com/';
--g_logout_url        constant varchar2(255) := 'f?p=sterlingmain_qa:101';
    procedure set_last_activity_date (
        p_user in varchar2 default v('APP_USER')
    );

    function is_session_valid return boolean;

    procedure set_sso_cookie (
        p_user_name varchar2
    );

    function sentry return boolean;

    procedure sam_logout;

    procedure expire_sam_cookie;

    function session_sentry return boolean;

    procedure set_logout_date;

end app_users;
/

