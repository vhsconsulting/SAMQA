-- liquibase formatted sql
-- changeset SAMQA:1754373941543 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.param_dates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.param_dates.sql:null:d6215ead29d16342372ae828fdfee572af6f5075:create

grant delete on samqa.param_dates to rl_sam_rw;

grant insert on samqa.param_dates to rl_sam_rw;

grant select on samqa.param_dates to rl_sam1_ro;

grant select on samqa.param_dates to rl_sam_rw;

grant select on samqa.param_dates to rl_sam_ro;

grant update on samqa.param_dates to rl_sam_rw;

