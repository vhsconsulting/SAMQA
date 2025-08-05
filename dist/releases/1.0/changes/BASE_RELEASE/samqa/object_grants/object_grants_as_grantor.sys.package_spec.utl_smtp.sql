-- liquibase formatted sql
-- changeset SAMQA:1754374180541 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.package_spec.utl_smtp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.package_spec.utl_smtp.sql:null:a4fbc7b4ea719a39d1cbb14c94e96cc1bc63418e:create

grant execute on sys.utl_smtp to samqa;

