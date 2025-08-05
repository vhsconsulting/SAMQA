-- liquibase formatted sql
-- changeset SAMQA:1754373941978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_team_member_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_team_member_bkup.sql:null:a7f2a66a2db92e53a6b0a6b87704cbf39fd609f5:create

grant delete on samqa.sales_team_member_bkup to rl_sam_rw;

grant insert on samqa.sales_team_member_bkup to rl_sam_rw;

grant select on samqa.sales_team_member_bkup to rl_sam_rw;

grant select on samqa.sales_team_member_bkup to rl_sam1_ro;

grant select on samqa.sales_team_member_bkup to rl_sam_ro;

grant update on samqa.sales_team_member_bkup to rl_sam_rw;

