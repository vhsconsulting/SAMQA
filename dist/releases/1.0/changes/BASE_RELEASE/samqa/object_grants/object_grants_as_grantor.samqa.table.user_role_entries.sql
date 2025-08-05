-- liquibase formatted sql
-- changeset SAMQA:1754373942429 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.user_role_entries.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.user_role_entries.sql:null:a27d86e715903d5fa3e74e3f2e7017d4ebc00ed1:create

grant delete on samqa.user_role_entries to rl_sam_rw;

grant insert on samqa.user_role_entries to rl_sam_rw;

grant select on samqa.user_role_entries to rl_sam1_ro;

grant select on samqa.user_role_entries to rl_sam_rw;

grant select on samqa.user_role_entries to rl_sam_ro;

grant update on samqa.user_role_entries to rl_sam_rw;

