-- liquibase formatted sql
-- changeset SAMQA:1754373944387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.income_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.income_analytics_v.sql:null:b6d63b86521fcc341c73d4fc38ef09b0c6c9eacd:create

grant select on samqa.income_analytics_v to rl_sam1_ro;

grant select on samqa.income_analytics_v to rl_sam_rw;

grant select on samqa.income_analytics_v to rl_sam_ro;

grant select on samqa.income_analytics_v to sgali;

