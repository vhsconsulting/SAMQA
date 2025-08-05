-- liquibase formatted sql
-- changeset SAMQA:1754373943102 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_marketing_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_marketing_analytics_v.sql:null:7a8f590b3e6c4ec5d31846fd265cbbd29367768c:create

grant select on samqa.broker_marketing_analytics_v to rl_sam1_ro;

grant select on samqa.broker_marketing_analytics_v to rl_sam_rw;

grant select on samqa.broker_marketing_analytics_v to rl_sam_ro;

grant select on samqa.broker_marketing_analytics_v to sgali;

