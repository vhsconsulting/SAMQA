-- liquibase formatted sql
-- changeset SAMQA:1754373941662 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.person_audit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.person_audit.sql:null:c51cabff7625a41210e300515f9c9374af81ce57:create

grant delete on samqa.person_audit to rl_sam_rw;

grant insert on samqa.person_audit to rl_sam_rw;

grant select on samqa.person_audit to rl_sam_rw;

grant select on samqa.person_audit to rl_sam1_ro;

grant select on samqa.person_audit to rl_sam_ro;

grant update on samqa.person_audit to rl_sam_rw;

