-- liquibase formatted sql
-- changeset SAMQA:1754373941970 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_team_member.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_team_member.sql:null:fbd10b948458e256bea4fd0d6952ade5ad67b9d6:create

grant delete on samqa.sales_team_member to rl_sam_rw;

grant insert on samqa.sales_team_member to rl_sam_rw;

grant select on samqa.sales_team_member to rl_sam1_ro;

grant select on samqa.sales_team_member to rl_sam_rw;

grant select on samqa.sales_team_member to rl_sam_ro;

grant update on samqa.sales_team_member to rl_sam_rw;

