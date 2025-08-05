-- liquibase formatted sql
-- changeset SAMQA:1754373943833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_portfolio_dashboard_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_portfolio_dashboard_v.sql:null:9a46e0870c58f513043ea5b18a8aee171621a17d:create

grant select on samqa.er_portfolio_dashboard_v to rl_sam1_ro;

grant select on samqa.er_portfolio_dashboard_v to rl_sam_rw;

grant select on samqa.er_portfolio_dashboard_v to rl_sam_ro;

