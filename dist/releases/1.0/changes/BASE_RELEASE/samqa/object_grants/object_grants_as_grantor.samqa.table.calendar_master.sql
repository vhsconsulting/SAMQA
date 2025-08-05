-- liquibase formatted sql
-- changeset SAMQA:1754373939139 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.calendar_master.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.calendar_master.sql:null:699e2a794b8a2a534b93475ac763cf5f5969f4de:create

grant delete on samqa.calendar_master to rl_sam_rw;

grant insert on samqa.calendar_master to rl_sam_rw;

grant select on samqa.calendar_master to rl_sam1_ro;

grant select on samqa.calendar_master to rl_sam_rw;

grant select on samqa.calendar_master to rl_sam_ro;

grant update on samqa.calendar_master to rl_sam_rw;

