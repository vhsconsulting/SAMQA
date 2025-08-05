-- liquibase formatted sql
-- changeset SAMQA:1754374180441 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.settlement_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.settlement_dir.sql:null:a18e7d21960586ad1d747c37a46a78e7332853da:create

grant execute on directory sys.settlement_dir to samqa;

grant read on directory sys.settlement_dir to samqa;

grant write on directory sys.settlement_dir to samqa;

