-- liquibase formatted sql
-- changeset SAMQA:1754373938502 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.acn_employee_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.acn_employee_migration.sql:null:8b9e03db91773862d77281631e0e99b1808a8039:create

grant delete on samqa.acn_employee_migration to rl_sam_rw;

grant insert on samqa.acn_employee_migration to rl_sam_rw;

grant select on samqa.acn_employee_migration to rl_sam1_ro;

grant select on samqa.acn_employee_migration to rl_sam_ro;

grant select on samqa.acn_employee_migration to rl_sam_rw;

grant update on samqa.acn_employee_migration to rl_sam_rw;

