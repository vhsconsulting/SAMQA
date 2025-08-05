-- liquibase formatted sql
-- changeset SAMQA:1754373941735 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plans.sql:null:6b29be011da8db6c09cc0c9d87b73a08f5e9970e:create

grant delete on samqa.plans to rl_sam_rw;

grant insert on samqa.plans to rl_sam_rw;

grant select on samqa.plans to rl_sam1_ro;

grant select on samqa.plans to rl_sam_ro;

grant select on samqa.plans to rl_sam_rw;

grant select on samqa.plans to reportdb_ro;

grant update on samqa.plans to rl_sam_rw;

