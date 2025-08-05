-- liquibase formatted sql
-- changeset SAMQA:1754373936010 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_compliance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_compliance.sql:null:9d5be725f640063452d1da31c52aa043658f2988:create

grant execute on samqa.pc_compliance to rl_sam_ro;

grant execute on samqa.pc_compliance to rl_sam_rw;

grant execute on samqa.pc_compliance to rl_sam1_ro;

grant debug on samqa.pc_compliance to sgali;

grant debug on samqa.pc_compliance to rl_sam_rw;

grant debug on samqa.pc_compliance to rl_sam1_ro;

grant debug on samqa.pc_compliance to rl_sam_ro;

