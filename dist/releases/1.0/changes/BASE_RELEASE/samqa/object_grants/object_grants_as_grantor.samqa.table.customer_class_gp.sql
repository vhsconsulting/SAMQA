-- liquibase formatted sql
-- changeset SAMQA:1754373939608 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.customer_class_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.customer_class_gp.sql:null:96f6f628eca5ba38889be4166a3dba023d4729cd:create

grant delete on samqa.customer_class_gp to rl_sam_rw;

grant insert on samqa.customer_class_gp to rl_sam_rw;

grant select on samqa.customer_class_gp to rl_sam1_ro;

grant select on samqa.customer_class_gp to rl_sam_rw;

grant select on samqa.customer_class_gp to rl_sam_ro;

grant update on samqa.customer_class_gp to rl_sam_rw;

