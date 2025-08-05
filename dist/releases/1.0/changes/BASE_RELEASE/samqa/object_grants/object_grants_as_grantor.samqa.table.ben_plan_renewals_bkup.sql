-- liquibase formatted sql
-- changeset SAMQA:1754373938955 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_renewals_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_renewals_bkup.sql:null:310e73d70d88ac4daf06bb7945281f5855964131:create

grant delete on samqa.ben_plan_renewals_bkup to rl_sam_rw;

grant insert on samqa.ben_plan_renewals_bkup to rl_sam_rw;

grant select on samqa.ben_plan_renewals_bkup to rl_sam1_ro;

grant select on samqa.ben_plan_renewals_bkup to rl_sam_ro;

grant select on samqa.ben_plan_renewals_bkup to rl_sam_rw;

grant update on samqa.ben_plan_renewals_bkup to rl_sam_rw;

