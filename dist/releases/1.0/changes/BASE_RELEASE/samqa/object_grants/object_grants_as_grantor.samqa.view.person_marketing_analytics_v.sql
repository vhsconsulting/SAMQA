-- liquibase formatted sql
-- changeset SAMQA:1754373944900 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.person_marketing_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.person_marketing_analytics_v.sql:null:9a68b26d6b21ae0d974d3048f2a7c3d5bc88827d:create

grant select on samqa.person_marketing_analytics_v to rl_sam1_ro;

grant select on samqa.person_marketing_analytics_v to rl_sam_rw;

grant select on samqa.person_marketing_analytics_v to rl_sam_ro;

grant select on samqa.person_marketing_analytics_v to sgali;

