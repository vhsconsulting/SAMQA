-- liquibase formatted sql
-- changeset SAMQA:1754373942406 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.user_login_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.user_login_history.sql:null:00973e372f6f7d54d89931e2b64606bf7cd79cac:create

grant delete on samqa.user_login_history to rl_sam_rw;

grant insert on samqa.user_login_history to rl_sam_rw;

grant select on samqa.user_login_history to rl_sam1_ro;

grant select on samqa.user_login_history to rl_sam_rw;

grant select on samqa.user_login_history to rl_sam_ro;

grant update on samqa.user_login_history to rl_sam_rw;

