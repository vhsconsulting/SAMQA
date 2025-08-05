-- liquibase formatted sql
-- changeset SAMQA:1754373939487 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_interface_error.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_interface_error.sql:null:79da619dda5e2b104dc9d1670eb3a95536d126af:create

grant delete on samqa.cobra_interface_error to rl_sam_rw;

grant insert on samqa.cobra_interface_error to rl_sam_rw;

grant select on samqa.cobra_interface_error to rl_sam1_ro;

grant select on samqa.cobra_interface_error to rl_sam_rw;

grant select on samqa.cobra_interface_error to rl_sam_ro;

grant update on samqa.cobra_interface_error to rl_sam_rw;

