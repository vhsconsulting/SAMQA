-- liquibase formatted sql
-- changeset SAMQA:1754374180429 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.scheduler_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.scheduler_dir.sql:null:46e90110bf64e11005d6268f0614d4f18e481019:create

grant execute on directory sys.scheduler_dir to samqa;

grant read on directory sys.scheduler_dir to samqa;

grant write on directory sys.scheduler_dir to samqa;

