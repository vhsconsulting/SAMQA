-- liquibase formatted sql
-- changeset SAMQA:1754374180423 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.scheduler$_log_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.scheduler$_log_dir.sql:null:4cc2a4a1a9e791a176163b4fee822de90567a1ee:create

grant read on directory sys.scheduler$_log_dir to samqa;

grant write on directory sys.scheduler$_log_dir to samqa;

