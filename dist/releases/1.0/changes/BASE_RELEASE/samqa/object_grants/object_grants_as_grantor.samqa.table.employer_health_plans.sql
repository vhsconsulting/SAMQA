-- liquibase formatted sql
-- changeset SAMQA:1754373939960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_health_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_health_plans.sql:null:b1b27fa00949742f0a31c94f9c63dc3e350e15a4:create

grant delete on samqa.employer_health_plans to rl_sam_rw;

grant insert on samqa.employer_health_plans to rl_sam_rw;

grant select on samqa.employer_health_plans to rl_sam1_ro;

grant select on samqa.employer_health_plans to rl_sam_rw;

grant select on samqa.employer_health_plans to rl_sam_ro;

grant update on samqa.employer_health_plans to rl_sam_rw;

