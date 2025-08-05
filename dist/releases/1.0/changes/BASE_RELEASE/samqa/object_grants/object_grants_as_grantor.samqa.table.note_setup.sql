-- liquibase formatted sql
-- changeset SAMQA:1754373941325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.note_setup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.note_setup.sql:null:129aab94749157543a295b5d2392145ac592d7c2:create

grant delete on samqa.note_setup to rl_sam_rw;

grant insert on samqa.note_setup to rl_sam_rw;

grant select on samqa.note_setup to rl_sam1_ro;

grant select on samqa.note_setup to rl_sam_ro;

grant select on samqa.note_setup to rl_sam_rw;

grant update on samqa.note_setup to rl_sam_rw;

