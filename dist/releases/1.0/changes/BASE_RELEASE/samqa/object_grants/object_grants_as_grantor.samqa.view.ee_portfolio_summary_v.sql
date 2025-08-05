-- liquibase formatted sql
-- changeset SAMQA:1754373943564 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ee_portfolio_summary_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ee_portfolio_summary_v.sql:null:69e3713d495f8736ed62549006fef6e72ad8942a:create

grant select on samqa.ee_portfolio_summary_v to rl_sam1_ro;

grant select on samqa.ee_portfolio_summary_v to rl_sam_rw;

grant select on samqa.ee_portfolio_summary_v to rl_sam_ro;

grant select on samqa.ee_portfolio_summary_v to sgali;

