-- liquibase formatted sql
-- changeset SAMQA:1754373936099 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_employer_fin.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_employer_fin.sql:null:4c5e2f822180cbfdb7ab8a3612968b6ac8f6ec26:create

grant execute on samqa.pc_employer_fin to rl_sam_ro;

grant execute on samqa.pc_employer_fin to rl_sam_rw;

grant execute on samqa.pc_employer_fin to rl_sam1_ro;

grant debug on samqa.pc_employer_fin to sgali;

grant debug on samqa.pc_employer_fin to rl_sam_rw;

grant debug on samqa.pc_employer_fin to rl_sam1_ro;

grant debug on samqa.pc_employer_fin to rl_sam_ro;

