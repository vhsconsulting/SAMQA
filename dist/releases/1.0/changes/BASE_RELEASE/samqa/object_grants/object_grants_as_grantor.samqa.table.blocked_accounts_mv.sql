-- liquibase formatted sql
-- changeset SAMQA:1754373939011 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.blocked_accounts_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.blocked_accounts_mv.sql:null:69cca7b6049b9477bf826caca70fb5aac1a583f3:create

grant delete on samqa.blocked_accounts_mv to rl_sam_rw;

grant insert on samqa.blocked_accounts_mv to rl_sam_rw;

grant select on samqa.blocked_accounts_mv to rl_sam1_ro;

grant select on samqa.blocked_accounts_mv to rl_sam_rw;

grant select on samqa.blocked_accounts_mv to rl_sam_ro;

grant update on samqa.blocked_accounts_mv to rl_sam_rw;

