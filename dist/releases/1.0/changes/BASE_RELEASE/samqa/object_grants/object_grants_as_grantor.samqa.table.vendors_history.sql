-- liquibase formatted sql
-- changeset SAMQA:1754373942487 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.vendors_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.vendors_history.sql:null:c04326956b02b9fe58478fefde61325a470fac98:create

grant delete on samqa.vendors_history to rl_sam_rw;

grant insert on samqa.vendors_history to rl_sam_rw;

grant select on samqa.vendors_history to rl_sam1_ro;

grant select on samqa.vendors_history to rl_sam_rw;

grant select on samqa.vendors_history to rl_sam_ro;

grant update on samqa.vendors_history to rl_sam_rw;

