-- liquibase formatted sql
-- changeset SAMQA:1754373940390 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.events.sql:null:d17b4c0d92a1c13aa841a6b1280703f332a2ae81:create

grant delete on samqa.events to rl_sam_rw;

grant insert on samqa.events to rl_sam_rw;

grant select on samqa.events to rl_sam1_ro;

grant select on samqa.events to rl_sam_rw;

grant select on samqa.events to rl_sam_ro;

grant update on samqa.events to rl_sam_rw;

