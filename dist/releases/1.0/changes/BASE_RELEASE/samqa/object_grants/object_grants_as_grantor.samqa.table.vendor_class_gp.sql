-- liquibase formatted sql
-- changeset SAMQA:1754373942457 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.vendor_class_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.vendor_class_gp.sql:null:dd1e3938cdc6db01ce9f96fec42ce83d4d4174c7:create

grant delete on samqa.vendor_class_gp to rl_sam_rw;

grant insert on samqa.vendor_class_gp to rl_sam_rw;

grant select on samqa.vendor_class_gp to rl_sam1_ro;

grant select on samqa.vendor_class_gp to rl_sam_rw;

grant select on samqa.vendor_class_gp to rl_sam_ro;

grant update on samqa.vendor_class_gp to rl_sam_rw;

