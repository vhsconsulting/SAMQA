-- liquibase formatted sql
-- changeset SAMQA:1754373941071 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_enrollments.sql:null:38d0f483628b235ba0bbd49753fd44baab77a680:create

grant delete on samqa.mass_enrollments to rl_sam_rw;

grant insert on samqa.mass_enrollments to rl_sam_rw;

grant select on samqa.mass_enrollments to rl_sam1_ro;

grant select on samqa.mass_enrollments to rl_sam_rw;

grant select on samqa.mass_enrollments to rl_sam_ro;

grant update on samqa.mass_enrollments to rl_sam_rw;

