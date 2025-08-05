-- liquibase formatted sql
-- changeset SAMQA:1754373940849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.investment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.investment.sql:null:bfc3fcc4febed1c78b0fb0c6231cbf49d7d5437f:create

grant delete on samqa.investment to rl_sam_rw;

grant insert on samqa.investment to rl_sam_rw;

grant select on samqa.investment to rl_sam1_ro;

grant select on samqa.investment to rl_sam_rw;

grant select on samqa.investment to rl_sam_ro;

grant update on samqa.investment to rl_sam_rw;

