-- liquibase formatted sql
-- changeset SAMQA:1754373942086 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.scheduler_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.scheduler_stage.sql:null:b0a19e37114fb7720b31979e0c57a8f015f9a7b4:create

grant delete on samqa.scheduler_stage to rl_sam_rw;

grant insert on samqa.scheduler_stage to rl_sam_rw;

grant select on samqa.scheduler_stage to rl_sam1_ro;

grant select on samqa.scheduler_stage to rl_sam_ro;

grant select on samqa.scheduler_stage to rl_sam_rw;

grant update on samqa.scheduler_stage to rl_sam_rw;

