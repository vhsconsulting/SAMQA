-- liquibase formatted sql
-- changeset SAMQA:1754374180501 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.webservice_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.webservice_dir.sql:null:c1624d71340b18331e039603dc33cc10da1c1383:create

grant execute on directory sys.webservice_dir to samqa;

grant read on directory sys.webservice_dir to samqa;

grant write on directory sys.webservice_dir to samqa;

