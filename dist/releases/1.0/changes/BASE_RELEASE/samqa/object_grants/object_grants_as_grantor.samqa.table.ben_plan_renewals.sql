-- liquibase formatted sql
-- changeset SAMQA:1754373938945 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_plan_renewals.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_plan_renewals.sql:null:9b5f413b5158eaa694fb1b396aa178fe2bb58fec:create

grant delete on samqa.ben_plan_renewals to rl_sam_rw;

grant insert on samqa.ben_plan_renewals to rl_sam_rw;

grant select on samqa.ben_plan_renewals to rl_sam1_ro;

grant select on samqa.ben_plan_renewals to rl_sam_rw;

grant select on samqa.ben_plan_renewals to rl_sam_ro;

grant update on samqa.ben_plan_renewals to rl_sam_rw;

