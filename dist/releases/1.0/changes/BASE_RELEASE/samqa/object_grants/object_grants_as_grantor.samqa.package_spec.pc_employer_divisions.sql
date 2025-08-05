-- liquibase formatted sql
-- changeset SAMQA:1754373936075 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_employer_divisions.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_employer_divisions.sql:null:839233388d63f8d1aa3cde04303cbb8d2ff83933:create

grant execute on samqa.pc_employer_divisions to rl_sam_ro;

grant execute on samqa.pc_employer_divisions to rl_sam_rw;

grant execute on samqa.pc_employer_divisions to rl_sam1_ro;

grant debug on samqa.pc_employer_divisions to rl_sam_ro;

grant debug on samqa.pc_employer_divisions to sgali;

grant debug on samqa.pc_employer_divisions to rl_sam_rw;

grant debug on samqa.pc_employer_divisions to rl_sam1_ro;

