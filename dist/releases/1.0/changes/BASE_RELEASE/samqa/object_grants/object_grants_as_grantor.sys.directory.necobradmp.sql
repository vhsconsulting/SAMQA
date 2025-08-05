-- liquibase formatted sql
-- changeset SAMQA:1754374180399 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.necobradmp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.necobradmp.sql:null:7897ba6e5b73e1a1ee3496c81b19ad23c4c2725a:create

grant execute on directory sys.necobradmp to samqa;

grant read on directory sys.necobradmp to samqa;

grant write on directory sys.necobradmp to samqa;

