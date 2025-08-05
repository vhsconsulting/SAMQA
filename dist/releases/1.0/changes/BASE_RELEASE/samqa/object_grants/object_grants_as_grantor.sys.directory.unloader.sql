-- liquibase formatted sql
-- changeset SAMQA:1754374180476 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.unloader.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.unloader.sql:null:a0ae6ec53de17c31a8893a56d41a8bfee875b51b:create

grant read on directory sys.unloader to samqa;

grant write on directory sys.unloader to samqa;

