-- liquibase formatted sql
-- changeset SAMQA:1754373936559 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_web_compliance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_web_compliance.sql:null:87e49292442b9c26d1caf1511e829d974efd2ee0:create

grant execute on samqa.pc_web_compliance to rl_sam_rw;

grant execute on samqa.pc_web_compliance to rl_sam_ro;

grant execute on samqa.pc_web_compliance to rl_temp_access_ro;

grant execute on samqa.pc_web_compliance to rl_sam1_ro;

grant debug on samqa.pc_web_compliance to rl_temp_access_ro;

grant debug on samqa.pc_web_compliance to sgali;

grant debug on samqa.pc_web_compliance to rl_sam_rw;

grant debug on samqa.pc_web_compliance to rl_sam1_ro;

grant debug on samqa.pc_web_compliance to rl_sam_ro;

