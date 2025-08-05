-- liquibase formatted sql
-- changeset SAMQA:1754374180337 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.etl_script.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.etl_script.sql:null:fe8b17142433569043969c80cb8a10f58ee2f35e:create

grant execute on directory sys.etl_script to samqa;

grant read on directory sys.etl_script to samqa;

grant write on directory sys.etl_script to samqa;

