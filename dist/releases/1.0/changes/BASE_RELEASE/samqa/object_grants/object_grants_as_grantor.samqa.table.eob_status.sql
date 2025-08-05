-- liquibase formatted sql
-- changeset SAMQA:1754373940287 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_status.sql:null:081dbf3295521fa324a4324c0c7c9d95c264cba1:create

grant delete on samqa.eob_status to rl_sam_rw;

grant insert on samqa.eob_status to rl_sam_rw;

grant select on samqa.eob_status to rl_sam1_ro;

grant select on samqa.eob_status to rl_sam_rw;

grant select on samqa.eob_status to rl_sam_ro;

grant update on samqa.eob_status to rl_sam_rw;

