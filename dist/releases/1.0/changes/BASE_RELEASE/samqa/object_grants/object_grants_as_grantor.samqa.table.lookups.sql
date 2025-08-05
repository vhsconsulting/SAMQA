-- liquibase formatted sql
-- changeset SAMQA:1754373940992 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.lookups.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.lookups.sql:null:749a2eebf4c2da7e56a8ce09b89440bc7eaf1e76:create

grant delete on samqa.lookups to rl_sam_rw;

grant insert on samqa.lookups to rl_sam_rw;

grant select on samqa.lookups to rl_sam1_ro;

grant select on samqa.lookups to rl_sam_rw;

grant select on samqa.lookups to rl_sam_ro;

grant select on samqa.lookups to reportdb_ro;

grant update on samqa.lookups to rl_sam_rw;

