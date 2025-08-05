-- liquibase formatted sql
-- changeset SAMQA:1754374180216 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.asis_rebate_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.asis_rebate_dir.sql:null:3ad688df763861011b11f0ab1e3752e32d7e0b1b:create

grant execute on directory sys.asis_rebate_dir to samqa;

grant read on directory sys.asis_rebate_dir to samqa;

grant write on directory sys.asis_rebate_dir to samqa;

