-- liquibase formatted sql
-- changeset SAMQA:1754373941669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.person_flashback.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.person_flashback.sql:null:0d32e551ad6d5d6e3f6cf5a5bb62d569c339cf67:create

grant delete on samqa.person_flashback to rl_sam_rw;

grant insert on samqa.person_flashback to rl_sam_rw;

grant select on samqa.person_flashback to rl_sam_ro;

grant select on samqa.person_flashback to rl_sam_rw;

grant select on samqa.person_flashback to rl_sam1_ro;

grant update on samqa.person_flashback to rl_sam_rw;

