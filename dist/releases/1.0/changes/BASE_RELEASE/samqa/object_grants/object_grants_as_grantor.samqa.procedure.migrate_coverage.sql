-- liquibase formatted sql
-- changeset SAMQA:1754373936955 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.migrate_coverage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.migrate_coverage.sql:null:51a9d686de2b2a38090cb0d030f2938ccb2536df:create

grant execute on samqa.migrate_coverage to rl_sam_ro;

grant execute on samqa.migrate_coverage to rl_sam_rw;

grant execute on samqa.migrate_coverage to rl_sam1_ro;

grant debug on samqa.migrate_coverage to sgali;

grant debug on samqa.migrate_coverage to rl_sam_rw;

grant debug on samqa.migrate_coverage to rl_sam1_ro;

