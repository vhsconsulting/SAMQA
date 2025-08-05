-- liquibase formatted sql
-- changeset SAMQA:1754374180532 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.package_spec.utl_http.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.package_spec.utl_http.sql:null:09d92ef7ead84c8c073c7a180d8fabc1947bc66b:create

grant execute on sys.utl_http to samqa;

