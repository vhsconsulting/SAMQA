-- liquibase formatted sql
-- changeset SAMQA:1754373941806 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.rate_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.rate_plans.sql:null:a7606e29741a7e7b724bcfd56bef6100b655586c:create

grant alter on samqa.rate_plans to public;

grant delete on samqa.rate_plans to public;

grant delete on samqa.rate_plans to rl_sam_rw;

grant index on samqa.rate_plans to public;

grant insert on samqa.rate_plans to public;

grant insert on samqa.rate_plans to rl_sam_rw;

grant select on samqa.rate_plans to rl_sam1_ro;

grant select on samqa.rate_plans to public;

grant select on samqa.rate_plans to rl_sam_rw;

grant select on samqa.rate_plans to rl_sam_ro;

grant update on samqa.rate_plans to public;

grant update on samqa.rate_plans to rl_sam_rw;

grant references on samqa.rate_plans to public;

grant read on samqa.rate_plans to public;

grant on commit refresh on samqa.rate_plans to public;

grant query rewrite on samqa.rate_plans to public;

grant debug on samqa.rate_plans to public;

grant flashback on samqa.rate_plans to public;

