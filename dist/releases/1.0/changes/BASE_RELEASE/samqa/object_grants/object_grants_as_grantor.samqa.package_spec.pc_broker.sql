-- liquibase formatted sql
-- changeset SAMQA:1754373935917 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_broker.sql:null:c00f4e7bac39fd2b979c54beaf1544f49dcdd40c:create

grant execute on samqa.pc_broker to rl_sam_ro;

grant execute on samqa.pc_broker to rl_sam_rw;

grant execute on samqa.pc_broker to rl_sam1_ro;

grant debug on samqa.pc_broker to rl_sam_ro;

grant debug on samqa.pc_broker to sgali;

grant debug on samqa.pc_broker to rl_sam_rw;

grant debug on samqa.pc_broker to rl_sam1_ro;

