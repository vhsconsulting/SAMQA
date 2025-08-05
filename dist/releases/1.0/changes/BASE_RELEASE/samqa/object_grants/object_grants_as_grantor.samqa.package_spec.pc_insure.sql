-- liquibase formatted sql
-- changeset SAMQA:1754373936241 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_insure.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_insure.sql:null:a52e5ce35bc7c7c12c4b883627fb45b44ab76639:create

grant execute on samqa.pc_insure to rl_sam_ro;

grant execute on samqa.pc_insure to rl_sam_rw;

grant execute on samqa.pc_insure to rl_sam1_ro;

grant debug on samqa.pc_insure to rl_sam_ro;

grant debug on samqa.pc_insure to sgali;

grant debug on samqa.pc_insure to rl_sam_rw;

grant debug on samqa.pc_insure to rl_sam1_ro;

