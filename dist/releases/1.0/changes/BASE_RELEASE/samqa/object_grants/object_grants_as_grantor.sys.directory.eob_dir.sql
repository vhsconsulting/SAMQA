-- liquibase formatted sql
-- changeset SAMQA:1754374180313 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.eob_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.eob_dir.sql:null:661bf2e5daba00c45a55089319d259060190e8df:create

grant execute on directory sys.eob_dir to samqa;

grant read on directory sys.eob_dir to samqa;

grant write on directory sys.eob_dir to samqa;

