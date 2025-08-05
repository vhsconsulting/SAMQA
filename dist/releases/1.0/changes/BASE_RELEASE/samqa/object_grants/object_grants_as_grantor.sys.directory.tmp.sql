-- liquibase formatted sql
-- changeset SAMQA:1754374180465 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.tmp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.tmp.sql:null:4921974298c766a06dc91588fc7cbf33105eee47:create

grant read on directory sys.tmp to samqa;

grant write on directory sys.tmp to samqa;

