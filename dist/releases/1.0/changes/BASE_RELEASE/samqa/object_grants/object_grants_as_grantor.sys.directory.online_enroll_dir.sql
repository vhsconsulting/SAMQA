-- liquibase formatted sql
-- changeset SAMQA:1754374180405 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.online_enroll_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.online_enroll_dir.sql:null:600111f420392e941dc70e09e9e09bdfc91a2bf9:create

grant execute on directory sys.online_enroll_dir to samqa;

grant read on directory sys.online_enroll_dir to samqa;

grant write on directory sys.online_enroll_dir to samqa;

