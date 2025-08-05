-- liquibase formatted sql
-- changeset SAMQA:1754374180318 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.eob_in_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.eob_in_dir.sql:null:0068a48e05bc9928eb6b5532006e4ea120b88434:create

grant execute on directory sys.eob_in_dir to samqa;

grant read on directory sys.eob_in_dir to samqa;

grant write on directory sys.eob_in_dir to samqa;

