-- liquibase formatted sql
-- changeset SAMQA:1754374180277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.debit_card_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.debit_card_dir.sql:null:d49fd0981de96c7c81e06430d3a0395e23680214:create

grant execute on directory sys.debit_card_dir to samqa;

grant read on directory sys.debit_card_dir to samqa;

grant write on directory sys.debit_card_dir to samqa;

