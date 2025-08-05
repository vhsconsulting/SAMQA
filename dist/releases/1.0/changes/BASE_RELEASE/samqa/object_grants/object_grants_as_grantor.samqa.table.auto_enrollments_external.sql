-- liquibase formatted sql
-- changeset SAMQA:1754373938775 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.auto_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.auto_enrollments_external.sql:null:5ceb524a61839ccfe9475fe674f6c58261b8fbe4:create

grant select on samqa.auto_enrollments_external to rl_sam1_ro;

grant select on samqa.auto_enrollments_external to rl_sam_ro;

