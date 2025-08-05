-- liquibase formatted sql
-- changeset SAMQA:1754374180283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.debit_card_samdev.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.debit_card_samdev.sql:null:94dd6f70bf6e2c1c508e67f9a09d467169ab603d:create

grant execute on directory sys.debit_card_samdev to samqa;

grant read on directory sys.debit_card_samdev to samqa;

grant write on directory sys.debit_card_samdev to samqa;

