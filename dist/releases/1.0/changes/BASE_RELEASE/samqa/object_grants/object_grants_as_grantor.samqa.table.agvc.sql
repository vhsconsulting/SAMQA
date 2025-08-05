-- liquibase formatted sql
-- changeset SAMQA:1754373938564 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.agvc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.agvc.sql:null:18e2556bc32312aacf5025c6cb18267198af983d:create

grant delete on samqa.agvc to rl_sam_rw;

grant insert on samqa.agvc to rl_sam_rw;

grant select on samqa.agvc to rl_sam1_ro;

grant select on samqa.agvc to rl_sam_rw;

grant select on samqa.agvc to rl_sam_ro;

grant update on samqa.agvc to rl_sam_rw;

