-- liquibase formatted sql
-- changeset SAMQA:1754374180289 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.debit_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.debit_dir.sql:null:187f1920f545953bffd172d23ea8fbff71678bba:create

grant execute on directory sys.debit_dir to samqa;

grant read on directory sys.debit_dir to samqa;

grant write on directory sys.debit_dir to samqa;

