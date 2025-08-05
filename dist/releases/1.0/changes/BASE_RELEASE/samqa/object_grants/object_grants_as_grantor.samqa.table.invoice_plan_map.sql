-- liquibase formatted sql
-- changeset SAMQA:1754373940896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.invoice_plan_map.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.invoice_plan_map.sql:null:43290fc7007f9219c3b3ae7bdb0ee6e900091346:create

grant delete on samqa.invoice_plan_map to rl_sam_rw;

grant insert on samqa.invoice_plan_map to rl_sam_rw;

grant select on samqa.invoice_plan_map to rl_sam1_ro;

grant select on samqa.invoice_plan_map to rl_sam_rw;

grant select on samqa.invoice_plan_map to rl_sam_ro;

grant update on samqa.invoice_plan_map to rl_sam_rw;

