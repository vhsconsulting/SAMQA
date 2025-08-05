-- liquibase formatted sql
-- changeset SAMQA:1754374180537 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.package_spec.utl_inaddr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.package_spec.utl_inaddr.sql:null:c03dfcd2b4e0f4244634be202b1ab3c58d619f87:create

grant execute on sys.utl_inaddr to samqa;

