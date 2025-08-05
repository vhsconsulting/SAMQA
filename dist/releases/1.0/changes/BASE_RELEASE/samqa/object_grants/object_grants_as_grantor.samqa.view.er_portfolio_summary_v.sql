-- liquibase formatted sql
-- changeset SAMQA:1754373943839 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_portfolio_summary_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_portfolio_summary_v.sql:null:60adc88ce7caffb6f53bb99d8cff048e0ba02806:create

grant select on samqa.er_portfolio_summary_v to rl_sam1_ro;

grant select on samqa.er_portfolio_summary_v to rl_sam_rw;

grant select on samqa.er_portfolio_summary_v to rl_sam_ro;

grant select on samqa.er_portfolio_summary_v to sgali;

