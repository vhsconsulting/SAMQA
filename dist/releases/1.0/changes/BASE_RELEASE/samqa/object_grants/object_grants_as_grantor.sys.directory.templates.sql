-- liquibase formatted sql
-- changeset SAMQA:1754374180460 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.templates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.templates.sql:null:8b7aac995f1e26d48530a0fe0d2358e62617a82c:create

grant execute on directory sys.templates to samqa;

grant read on directory sys.templates to samqa;

grant write on directory sys.templates to samqa;

