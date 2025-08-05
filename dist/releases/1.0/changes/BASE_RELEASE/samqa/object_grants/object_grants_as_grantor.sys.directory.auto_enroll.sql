-- liquibase formatted sql
-- changeset SAMQA:1754374180223 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.auto_enroll.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.auto_enroll.sql:null:51a8de6c4e06732ae1e49329dfb54d60e1cdb1cf:create

grant execute on directory sys.auto_enroll to samqa;

grant read on directory sys.auto_enroll to samqa;

grant write on directory sys.auto_enroll to samqa;

