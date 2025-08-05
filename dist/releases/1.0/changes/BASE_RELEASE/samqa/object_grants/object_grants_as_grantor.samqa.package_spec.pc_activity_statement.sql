-- liquibase formatted sql
-- changeset SAMQA:1754373935865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_activity_statement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_activity_statement.sql:null:e372db397f7d2f2f7b63d8c116e5f5e0034f304e:create

grant execute on samqa.pc_activity_statement to rl_sam_ro;

grant execute on samqa.pc_activity_statement to rl_sam_rw;

grant execute on samqa.pc_activity_statement to rl_sam1_ro;

grant debug on samqa.pc_activity_statement to sgali;

grant debug on samqa.pc_activity_statement to rl_sam_rw;

grant debug on samqa.pc_activity_statement to rl_sam1_ro;

grant debug on samqa.pc_activity_statement to rl_sam_ro;

