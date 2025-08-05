-- liquibase formatted sql
-- changeset SAMQA:1754373940732 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.hra_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.hra_enrollments_external.sql:null:88c1c7ff2d9dff544e84c7adc2d28d2af1a24421:create

grant select on samqa.hra_enrollments_external to rl_sam1_ro;

grant select on samqa.hra_enrollments_external to rl_sam_ro;

