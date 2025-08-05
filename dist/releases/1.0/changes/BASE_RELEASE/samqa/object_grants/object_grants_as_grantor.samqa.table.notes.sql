-- liquibase formatted sql
-- changeset SAMQA:1754373941341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.notes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.notes.sql:null:414846f961b5b8c4d4b9fe56e9855d13ac3248b6:create

grant delete on samqa.notes to rl_sam_rw;

grant insert on samqa.notes to rl_sam_rw;

grant select on samqa.notes to rl_sam1_ro;

grant select on samqa.notes to rl_sam_rw;

grant select on samqa.notes to rl_sam_ro;

grant update on samqa.notes to rl_sam_rw;

