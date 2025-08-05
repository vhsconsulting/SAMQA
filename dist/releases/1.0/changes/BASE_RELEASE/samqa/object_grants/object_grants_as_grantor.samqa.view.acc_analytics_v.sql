-- liquibase formatted sql
-- changeset SAMQA:1754373942660 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_analytics_v.sql:null:145f50a792863fafb4c08e20a493c24f438eb94f:create

grant select on samqa.acc_analytics_v to rl_sam1_ro;

grant select on samqa.acc_analytics_v to rl_sam_ro;

grant select on samqa.acc_analytics_v to rl_sam_rw;

grant select on samqa.acc_analytics_v to sgali;

