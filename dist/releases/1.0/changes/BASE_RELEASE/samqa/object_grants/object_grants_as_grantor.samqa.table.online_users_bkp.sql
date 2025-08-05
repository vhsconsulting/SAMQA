-- liquibase formatted sql
-- changeset SAMQA:1754373941491 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_users_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_users_bkp.sql:null:ff2887f34f6388625e52c80b937cc36d360c0bbb:create

grant delete on samqa.online_users_bkp to rl_sam_rw;

grant insert on samqa.online_users_bkp to rl_sam_rw;

grant select on samqa.online_users_bkp to rl_sam1_ro;

grant select on samqa.online_users_bkp to rl_sam_rw;

grant select on samqa.online_users_bkp to rl_sam_ro;

grant update on samqa.online_users_bkp to rl_sam_rw;

