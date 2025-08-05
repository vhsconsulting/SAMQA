-- liquibase formatted sql
-- changeset SAMQA:1754373942027 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sam_users_pwd_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sam_users_pwd_history.sql:null:bf41faf9656274e8c4b3dde85ea7b4fb48ff081b:create

grant delete on samqa.sam_users_pwd_history to rl_sam_rw;

grant insert on samqa.sam_users_pwd_history to rl_sam_rw;

grant select on samqa.sam_users_pwd_history to rl_sam_ro;

grant select on samqa.sam_users_pwd_history to rl_sam_rw;

grant select on samqa.sam_users_pwd_history to rl_sam1_ro;

grant update on samqa.sam_users_pwd_history to rl_sam_rw;

