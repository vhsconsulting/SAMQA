-- liquibase formatted sql
-- changeset SAMQA:1754373941026 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_ease_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_ease_enrollments_external.sql:null:aaca8327e3717c72ffcf559e35d4d02abc33e6ad:create

grant alter on samqa.mass_ease_enrollments_external to public;

grant select on samqa.mass_ease_enrollments_external to rl_sam1_ro;

grant select on samqa.mass_ease_enrollments_external to rl_sam_ro;

grant select on samqa.mass_ease_enrollments_external to public;

grant read on samqa.mass_ease_enrollments_external to public;

