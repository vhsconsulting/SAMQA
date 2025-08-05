-- liquibase formatted sql
-- changeset SAMQA:1754374180435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.scripts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.scripts.sql:null:b10acb20ffc64ccd732e3f795c35aef53db8157b:create

grant execute on directory sys.scripts to samqa;

grant read on directory sys.scripts to samqa;

grant write on directory sys.scripts to samqa;

