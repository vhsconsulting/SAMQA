-- liquibase formatted sql
-- changeset SAMQA:1754373941081 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_enrollments_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_enrollments_history.sql:null:7c5d6cb0a0ad599ea8d758934d887c4e3fe907e9:create

grant delete on samqa.mass_enrollments_history to rl_sam_rw;

grant insert on samqa.mass_enrollments_history to rl_sam_rw;

grant select on samqa.mass_enrollments_history to rl_sam1_ro;

grant select on samqa.mass_enrollments_history to rl_sam_ro;

grant select on samqa.mass_enrollments_history to rl_sam_rw;

grant update on samqa.mass_enrollments_history to rl_sam_rw;

