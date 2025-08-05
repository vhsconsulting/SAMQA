-- liquibase formatted sql
-- changeset SAMQA:1754374180234 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.bank_serv_dir_dev.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.bank_serv_dir_dev.sql:null:501aa9828c8589d09689eb78a573bb03dfa089d1:create

grant execute on directory sys.bank_serv_dir_dev to samqa;

grant read on directory sys.bank_serv_dir_dev to samqa;

grant write on directory sys.bank_serv_dir_dev to samqa;

