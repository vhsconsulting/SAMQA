-- liquibase formatted sql
-- changeset SAMQA:1754373941885 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_comm_paid.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_comm_paid.sql:null:94bffed29529d7d286b1eeb9228643447491f933:create

grant delete on samqa.sales_comm_paid to rl_sam_rw;

grant insert on samqa.sales_comm_paid to rl_sam_rw;

grant select on samqa.sales_comm_paid to rl_sam1_ro;

grant select on samqa.sales_comm_paid to rl_sam_rw;

grant select on samqa.sales_comm_paid to rl_sam_ro;

grant update on samqa.sales_comm_paid to rl_sam_rw;

