-- liquibase formatted sql
-- changeset SAMQA:1754374180228 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.bank_serv_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.bank_serv_dir.sql:null:7a935f58cc08308b03bdfddfd7037a3de0330378:create

grant execute on directory sys.bank_serv_dir to samqa;

grant read on directory sys.bank_serv_dir to samqa;

grant write on directory sys.bank_serv_dir to samqa;

