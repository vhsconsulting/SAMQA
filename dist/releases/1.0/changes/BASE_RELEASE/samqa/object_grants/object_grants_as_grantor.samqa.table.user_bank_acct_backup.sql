-- liquibase formatted sql
-- changeset SAMQA:1754373942377 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.user_bank_acct_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.user_bank_acct_backup.sql:null:f279e12fd771e1084cf1a0893e018f4c1678a1ad:create

grant delete on samqa.user_bank_acct_backup to rl_sam_rw;

grant insert on samqa.user_bank_acct_backup to rl_sam_rw;

grant select on samqa.user_bank_acct_backup to rl_sam1_ro;

grant select on samqa.user_bank_acct_backup to rl_sam_ro;

grant select on samqa.user_bank_acct_backup to rl_sam_rw;

grant update on samqa.user_bank_acct_backup to rl_sam_rw;

