-- liquibase formatted sql
-- changeset SAMQA:1754373943727 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_marketing_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_marketing_analytics_v.sql:null:9cc20c362fcb7175853de60b03d5ec071c40f0f3:create

grant select on samqa.employer_marketing_analytics_v to rl_sam1_ro;

grant select on samqa.employer_marketing_analytics_v to rl_sam_rw;

grant select on samqa.employer_marketing_analytics_v to rl_sam_ro;

grant select on samqa.employer_marketing_analytics_v to sgali;

