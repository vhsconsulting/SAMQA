-- liquibase formatted sql
-- changeset SAMQA:1754373936107 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_encrypt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_encrypt.sql:null:c203013f50a965b167fc3725b8ba6e9ab70c20dc:create

grant execute on samqa.pc_encrypt to rl_sam_ro;

grant execute on samqa.pc_encrypt to rl_sam_rw;

grant execute on samqa.pc_encrypt to rl_sam1_ro;

grant debug on samqa.pc_encrypt to sgali;

grant debug on samqa.pc_encrypt to rl_sam_rw;

grant debug on samqa.pc_encrypt to rl_sam1_ro;

grant debug on samqa.pc_encrypt to rl_sam_ro;

