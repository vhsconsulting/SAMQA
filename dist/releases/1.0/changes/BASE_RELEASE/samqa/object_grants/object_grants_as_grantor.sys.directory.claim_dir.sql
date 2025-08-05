-- liquibase formatted sql
-- changeset SAMQA:1754374180253 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.sys.directory.claim_dir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/sys/object_grants/object_grants_as_grantor.sys.directory.claim_dir.sql:null:8bc3fe59ca2642bd526e731784cbf9e00c57034f:create

grant execute on directory sys.claim_dir to samqa;

grant read on directory sys.claim_dir to samqa;

grant write on directory sys.claim_dir to samqa;

