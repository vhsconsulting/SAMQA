-- liquibase formatted sql
-- changeset SAMQA:1754373941901 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_commission_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_commission_history.sql:null:3c67cce6a42963ad5c0f122f84cb2958a4f452bb:create

grant delete on samqa.sales_commission_history to rl_sam_rw;

grant insert on samqa.sales_commission_history to rl_sam_rw;

grant select on samqa.sales_commission_history to rl_sam1_ro;

grant select on samqa.sales_commission_history to rl_sam_rw;

grant select on samqa.sales_commission_history to rl_sam_ro;

grant update on samqa.sales_commission_history to rl_sam_rw;

