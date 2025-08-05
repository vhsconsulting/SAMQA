-- liquibase formatted sql
-- changeset SAMQA:1754373942471 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.vendors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.vendors.sql:null:713f3302631f30b8155875b00a722927a221148d:create

grant delete on samqa.vendors to rl_sam_rw;

grant insert on samqa.vendors to rl_sam_rw;

grant select on samqa.vendors to rl_sam1_ro;

grant select on samqa.vendors to rl_sam_rw;

grant select on samqa.vendors to rl_sam_ro;

grant update on samqa.vendors to rl_sam_rw;

