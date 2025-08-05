-- liquibase formatted sql
-- changeset SAMQA:1754374180307 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.enroll_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.enroll_dir.sql:null:4897bfa11e05a59e5b7e5e3fa9b2877ad59dd09e:create

grant execute on directory sys.enroll_dir to samqa;

grant read on directory sys.enroll_dir to samqa;

grant write on directory sys.enroll_dir to samqa;

