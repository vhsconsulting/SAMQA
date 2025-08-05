-- liquibase formatted sql
-- changeset SAMQA:1754374180494 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.wallet_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.wallet_dir.sql:null:58925a92d3f3471fe8161e5f6d384850dbfaff17:create

grant read on directory sys.wallet_dir to samqa;

grant write on directory sys.wallet_dir to samqa;

