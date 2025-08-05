-- liquibase formatted sql
-- changeset SAMQA:1754373941710 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plan_fee.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plan_fee.sql:null:4b1c4e49bbd8807e5ac50f9e1ed29d2c7dc67457:create

grant delete on samqa.plan_fee to rl_sam_rw;

grant insert on samqa.plan_fee to rl_sam_rw;

grant select on samqa.plan_fee to rl_sam1_ro;

grant select on samqa.plan_fee to rl_sam_rw;

grant select on samqa.plan_fee to rl_sam_ro;

grant update on samqa.plan_fee to rl_sam_rw;

