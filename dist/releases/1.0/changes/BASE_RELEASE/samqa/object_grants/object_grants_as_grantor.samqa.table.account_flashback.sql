-- liquibase formatted sql
-- changeset SAMQA:1754373938412 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.account_flashback.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.account_flashback.sql:null:a416d7d4e4b7f0eef3f9f3109f3c25e0121ede5a:create

grant delete on samqa.account_flashback to rl_sam_rw;

grant insert on samqa.account_flashback to rl_sam_rw;

grant select on samqa.account_flashback to rl_sam_rw;

grant select on samqa.account_flashback to rl_sam1_ro;

grant select on samqa.account_flashback to rl_sam_ro;

grant update on samqa.account_flashback to rl_sam_rw;

