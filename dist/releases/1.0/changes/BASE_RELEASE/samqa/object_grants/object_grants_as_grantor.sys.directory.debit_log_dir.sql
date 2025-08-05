-- liquibase formatted sql
-- changeset SAMQA:1754374180295 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.debit_log_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.debit_log_dir.sql:null:2e31db45621fcca49e1cff91a833cf87ddd056f0:create

grant execute on directory sys.debit_log_dir to samqa;

grant read on directory sys.debit_log_dir to samqa;

grant write on directory sys.debit_log_dir to samqa;

