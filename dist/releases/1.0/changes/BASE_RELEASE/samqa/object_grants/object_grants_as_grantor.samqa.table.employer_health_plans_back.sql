-- liquibase formatted sql
-- changeset SAMQA:1754373939968 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_health_plans_back.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_health_plans_back.sql:null:6cafc58859bf5363c16102bd9381430126e309be:create

grant delete on samqa.employer_health_plans_back to rl_sam_rw;

grant insert on samqa.employer_health_plans_back to rl_sam_rw;

grant select on samqa.employer_health_plans_back to rl_sam1_ro;

grant select on samqa.employer_health_plans_back to rl_sam_rw;

grant select on samqa.employer_health_plans_back to rl_sam_ro;

grant update on samqa.employer_health_plans_back to rl_sam_rw;

