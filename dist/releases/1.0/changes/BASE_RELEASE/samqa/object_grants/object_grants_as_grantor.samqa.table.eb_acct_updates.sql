-- liquibase formatted sql
-- changeset SAMQA:1754373939807 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eb_acct_updates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eb_acct_updates.sql:null:015b5dbd0a2ce4d15e91a7666e9210e1d657e0ae:create

grant delete on samqa.eb_acct_updates to rl_sam_rw;

grant insert on samqa.eb_acct_updates to rl_sam_rw;

grant select on samqa.eb_acct_updates to rl_sam1_ro;

grant select on samqa.eb_acct_updates to rl_sam_rw;

grant select on samqa.eb_acct_updates to rl_sam_ro;

grant update on samqa.eb_acct_updates to rl_sam_rw;

