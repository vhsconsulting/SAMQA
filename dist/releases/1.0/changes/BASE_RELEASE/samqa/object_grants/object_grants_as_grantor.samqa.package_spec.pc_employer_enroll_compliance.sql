-- liquibase formatted sql
-- changeset SAMQA:1754373936091 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_employer_enroll_compliance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_employer_enroll_compliance.sql:null:c4e384a03c2403563df457ce7847fdea3c6767bf:create

grant execute on samqa.pc_employer_enroll_compliance to rl_sam1_ro;

grant execute on samqa.pc_employer_enroll_compliance to rl_sam_rw;

grant execute on samqa.pc_employer_enroll_compliance to rl_sam_ro;

grant debug on samqa.pc_employer_enroll_compliance to rl_sam1_ro;

grant debug on samqa.pc_employer_enroll_compliance to rl_sam_rw;

grant debug on samqa.pc_employer_enroll_compliance to rl_sam_ro;

