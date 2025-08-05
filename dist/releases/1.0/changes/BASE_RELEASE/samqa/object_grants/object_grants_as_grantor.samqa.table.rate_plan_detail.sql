-- liquibase formatted sql
-- changeset SAMQA:1754373941784 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.rate_plan_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.rate_plan_detail.sql:null:7dd12d003266109aaafbd6814f31af3edfaf8090:create

grant alter on samqa.rate_plan_detail to newcobra;

grant alter on samqa.rate_plan_detail to public;

grant delete on samqa.rate_plan_detail to newcobra;

grant delete on samqa.rate_plan_detail to public;

grant delete on samqa.rate_plan_detail to rl_sam_rw;

grant index on samqa.rate_plan_detail to newcobra;

grant index on samqa.rate_plan_detail to public;

grant insert on samqa.rate_plan_detail to newcobra;

grant insert on samqa.rate_plan_detail to public;

grant insert on samqa.rate_plan_detail to rl_sam_rw;

grant select on samqa.rate_plan_detail to rl_sam1_ro;

grant select on samqa.rate_plan_detail to newcobra;

grant select on samqa.rate_plan_detail to public;

grant select on samqa.rate_plan_detail to rl_sam_rw;

grant select on samqa.rate_plan_detail to rl_sam_ro;

grant update on samqa.rate_plan_detail to newcobra;

grant update on samqa.rate_plan_detail to public;

grant update on samqa.rate_plan_detail to rl_sam_rw;

grant references on samqa.rate_plan_detail to newcobra;

grant references on samqa.rate_plan_detail to public;

grant read on samqa.rate_plan_detail to newcobra;

grant read on samqa.rate_plan_detail to public;

grant on commit refresh on samqa.rate_plan_detail to newcobra;

grant on commit refresh on samqa.rate_plan_detail to public;

grant query rewrite on samqa.rate_plan_detail to newcobra;

grant query rewrite on samqa.rate_plan_detail to public;

grant debug on samqa.rate_plan_detail to newcobra;

grant debug on samqa.rate_plan_detail to public;

grant flashback on samqa.rate_plan_detail to newcobra;

grant flashback on samqa.rate_plan_detail to public;

