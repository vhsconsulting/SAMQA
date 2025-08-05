-- liquibase formatted sql
-- changeset SAMQA:1754374180247 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.checks_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.checks_dir.sql:null:b6dbf589b2e1a961daad0f98489e389e27919c5f:create

grant execute on directory sys.checks_dir to samqa;

grant read on directory sys.checks_dir to samqa;

grant write on directory sys.checks_dir to samqa;

