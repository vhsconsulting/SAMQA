-- liquibase formatted sql
-- changeset SAMQA:1754374180387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.listbill_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.listbill_dir.sql:null:c71cd409cb6058abd598d0f52898aa905355e1a3:create

grant execute on directory sys.listbill_dir to samqa;

grant read on directory sys.listbill_dir to samqa;

grant write on directory sys.listbill_dir to samqa;

