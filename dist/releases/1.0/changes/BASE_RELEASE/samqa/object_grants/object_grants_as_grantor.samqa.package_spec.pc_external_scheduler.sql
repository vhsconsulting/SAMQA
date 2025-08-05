-- liquibase formatted sql
-- changeset SAMQA:1754373936160 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_external_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_external_scheduler.sql:null:174024203824262de6719d9fd8c17a38e6a0dfcc:create

grant execute on samqa.pc_external_scheduler to rl_sam_ro;

grant execute on samqa.pc_external_scheduler to rl_sam_rw;

grant execute on samqa.pc_external_scheduler to rl_sam1_ro;

grant debug on samqa.pc_external_scheduler to sgali;

grant debug on samqa.pc_external_scheduler to rl_sam_rw;

grant debug on samqa.pc_external_scheduler to rl_sam1_ro;

grant debug on samqa.pc_external_scheduler to rl_sam_ro;

