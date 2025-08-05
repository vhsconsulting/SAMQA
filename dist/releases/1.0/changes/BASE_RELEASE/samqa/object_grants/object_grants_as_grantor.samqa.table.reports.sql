-- liquibase formatted sql
-- changeset SAMQA:1754373941843 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.reports.sql:null:1d58ae3e406ac9e9b0dffaee3995dd82d4b36e19:create

grant delete on samqa.reports to rl_sam_rw;

grant insert on samqa.reports to rl_sam_rw;

grant select on samqa.reports to rl_sam1_ro;

grant select on samqa.reports to rl_sam_rw;

grant select on samqa.reports to rl_sam_ro;

grant update on samqa.reports to rl_sam_rw;

