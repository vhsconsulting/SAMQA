-- liquibase formatted sql
-- changeset SAMQA:1754373942479 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.vendors_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.vendors_backup.sql:null:10b36168a708b464d4be8307b41cc8c72e95acbf:create

grant delete on samqa.vendors_backup to rl_sam_rw;

grant insert on samqa.vendors_backup to rl_sam_rw;

grant select on samqa.vendors_backup to rl_sam1_ro;

grant select on samqa.vendors_backup to rl_sam_rw;

grant select on samqa.vendors_backup to rl_sam_ro;

grant update on samqa.vendors_backup to rl_sam_rw;

