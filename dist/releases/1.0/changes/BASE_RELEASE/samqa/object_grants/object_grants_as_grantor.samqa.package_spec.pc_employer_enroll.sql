-- liquibase formatted sql
-- changeset SAMQA:1754373936083 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_employer_enroll.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_employer_enroll.sql:null:7ebd7dd224a72400747938df15f7fd2ac19ff91b:create

grant execute on samqa.pc_employer_enroll to rl_sam_rw;

grant execute on samqa.pc_employer_enroll to rl_sam_ro;

grant execute on samqa.pc_employer_enroll to rl_sam1_ro;

grant debug on samqa.pc_employer_enroll to rl_sam1_ro;

grant debug on samqa.pc_employer_enroll to rl_sam_ro;

grant debug on samqa.pc_employer_enroll to sgali;

grant debug on samqa.pc_employer_enroll to rl_sam_rw;

