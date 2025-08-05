-- liquibase formatted sql
-- changeset SAMQA:1754373936593 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_webservice_batch.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_webservice_batch.sql:null:0ec1db52921e88acc56c9aa1839fc26b4aae0591:create

grant execute on samqa.pc_webservice_batch to rl_sam_ro;

grant execute on samqa.pc_webservice_batch to rl_sam_rw;

grant execute on samqa.pc_webservice_batch to rl_sam1_ro;

grant debug on samqa.pc_webservice_batch to rl_sam_ro;

grant debug on samqa.pc_webservice_batch to sgali;

grant debug on samqa.pc_webservice_batch to rl_sam_rw;

grant debug on samqa.pc_webservice_batch to rl_sam1_ro;

