-- liquibase formatted sql
-- changeset SAMQA:1754374133279 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\app_security.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/app_security.sql:null:4d3201b6018f34c50134cc3a4e50e88b4039e381:create

create or replace package samqa.app_security is
    function sentry_basic_auth return boolean;

    function sam_auth (
        p_username in varchar2,
        p_password in varchar2
    ) return boolean;

end app_security;
/

