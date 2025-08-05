-- liquibase formatted sql
-- changeset SAMQA:1754373940944 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.item_master.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.item_master.sql:null:cdc5eec1914d3ac7e77d33c1dcc91e7ff465cbd4:create

grant delete on samqa.item_master to rl_sam_rw;

grant insert on samqa.item_master to rl_sam_rw;

grant select on samqa.item_master to rl_sam1_ro;

grant select on samqa.item_master to rl_sam_rw;

grant select on samqa.item_master to rl_sam_ro;

grant update on samqa.item_master to rl_sam_rw;

