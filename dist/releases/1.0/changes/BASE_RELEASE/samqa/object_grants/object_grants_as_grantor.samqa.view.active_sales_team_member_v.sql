-- liquibase formatted sql
-- changeset SAMQA:1754373942864 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.active_sales_team_member_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.active_sales_team_member_v.sql:null:933f38c71b52aac0dc2de27e8e1a864372f9fe19:create

grant select on samqa.active_sales_team_member_v to rl_sam1_ro;

grant select on samqa.active_sales_team_member_v to rl_sam_rw;

grant select on samqa.active_sales_team_member_v to rl_sam_ro;

grant select on samqa.active_sales_team_member_v to sgali;

