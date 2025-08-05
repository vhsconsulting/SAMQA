-- liquibase formatted sql
-- changeset SAMQA:1754373941484 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_users.sql:null:099610b609c6da78833a5e986d481dd228ab3e14:create

grant delete on samqa.online_users to rl_sam_rw;

grant insert on samqa.online_users to rl_sam_rw;

grant select on samqa.online_users to rl_sam1_ro;

grant select on samqa.online_users to rl_sam_rw;

grant select on samqa.online_users to rl_sam_ro;

grant update on samqa.online_users to rl_sam_rw;

