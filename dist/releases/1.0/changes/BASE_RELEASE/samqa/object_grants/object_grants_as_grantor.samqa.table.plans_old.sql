-- liquibase formatted sql
-- changeset SAMQA:1754373941743 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plans_old.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plans_old.sql:null:98347bf71eaeb465f9b3ecb55803bcede0ba424f:create

grant delete on samqa.plans_old to rl_sam_rw;

grant insert on samqa.plans_old to rl_sam_rw;

grant select on samqa.plans_old to rl_sam1_ro;

grant select on samqa.plans_old to rl_sam_rw;

grant select on samqa.plans_old to rl_sam_ro;

grant update on samqa.plans_old to rl_sam_rw;

