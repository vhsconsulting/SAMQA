-- liquibase formatted sql
-- changeset SAMQA:1754374180369 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.hex_status_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.hex_status_dir.sql:null:ebd05b1976586bbec4f190e9518868a6e5e08339:create

grant execute on directory sys.hex_status_dir to samqa;

grant read on directory sys.hex_status_dir to samqa;

grant write on directory sys.hex_status_dir to samqa;

