-- liquibase formatted sql
-- changeset SAMQA:1754373938396 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.account_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.account_bkup.sql:null:999a4512f59fb752abef8e91d7143cbb4df3ad55:create

grant delete on samqa.account_bkup to rl_sam_rw;

grant insert on samqa.account_bkup to rl_sam_rw;

grant select on samqa.account_bkup to rl_sam1_ro;

grant select on samqa.account_bkup to rl_sam_ro;

grant select on samqa.account_bkup to rl_sam_rw;

grant update on samqa.account_bkup to rl_sam_rw;

