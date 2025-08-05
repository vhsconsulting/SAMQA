-- liquibase formatted sql
-- changeset SAMQA:1754373939745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.deleted_online_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.deleted_online_users.sql:null:77e0ec3a6f8975b627af8a4f6294d43d93fe0eae:create

grant delete on samqa.deleted_online_users to rl_sam_rw;

grant insert on samqa.deleted_online_users to rl_sam_rw;

grant select on samqa.deleted_online_users to rl_sam1_ro;

grant select on samqa.deleted_online_users to rl_sam_rw;

grant select on samqa.deleted_online_users to rl_sam_ro;

grant update on samqa.deleted_online_users to rl_sam_rw;

