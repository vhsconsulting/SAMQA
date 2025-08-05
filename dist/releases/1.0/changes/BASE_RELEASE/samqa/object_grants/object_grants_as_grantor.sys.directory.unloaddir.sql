-- liquibase formatted sql
-- changeset SAMQA:1754374180470 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.unloaddir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.unloaddir.sql:null:03481a583cfded3a5abfec4b90d8ed7129cf3cc9:create

grant read on directory sys.unloaddir to samqa;

grant write on directory sys.unloaddir to samqa;

