-- liquibase formatted sql
-- changeset SAMQA:1754373939555 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.contact_user_map.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.contact_user_map.sql:null:4dd56ba041963c57b9a6ab71eb3d9499c9eac556:create

grant delete on samqa.contact_user_map to rl_sam_rw;

grant insert on samqa.contact_user_map to rl_sam_rw;

grant select on samqa.contact_user_map to rl_sam1_ro;

grant select on samqa.contact_user_map to rl_sam_rw;

grant select on samqa.contact_user_map to rl_sam_ro;

grant update on samqa.contact_user_map to rl_sam_rw;

