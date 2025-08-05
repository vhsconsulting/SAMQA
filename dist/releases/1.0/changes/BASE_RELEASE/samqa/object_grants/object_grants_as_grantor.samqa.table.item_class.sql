-- liquibase formatted sql
-- changeset SAMQA:1754373940944 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.item_class.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.item_class.sql:null:500bf0958d308c9a80fa41583fc4e43093fa8670:create

grant delete on samqa.item_class to rl_sam_rw;

grant insert on samqa.item_class to rl_sam_rw;

grant select on samqa.item_class to rl_sam1_ro;

grant select on samqa.item_class to rl_sam_rw;

grant select on samqa.item_class to rl_sam_ro;

grant update on samqa.item_class to rl_sam_rw;

