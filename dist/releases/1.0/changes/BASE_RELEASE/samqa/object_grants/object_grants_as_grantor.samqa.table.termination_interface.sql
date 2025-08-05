-- liquibase formatted sql
-- changeset SAMQA:1754373942318 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.termination_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.termination_interface.sql:null:63f04ba65dd91bc47b7d970fd7b275566eb9fb7d:create

grant delete on samqa.termination_interface to rl_sam_rw;

grant insert on samqa.termination_interface to rl_sam_rw;

grant select on samqa.termination_interface to rl_sam1_ro;

grant select on samqa.termination_interface to rl_sam_rw;

grant select on samqa.termination_interface to rl_sam_ro;

grant update on samqa.termination_interface to rl_sam_rw;

