-- liquibase formatted sql
-- changeset SAMQA:1754373936504 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_termination.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_termination.sql:null:a1889cf82fe66e3f1cd0b412d43ee019880d0c7b:create

grant execute on samqa.pc_termination to rl_sam_ro;

grant execute on samqa.pc_termination to rl_sam_rw;

grant execute on samqa.pc_termination to rl_sam1_ro;

grant debug on samqa.pc_termination to rl_sam_ro;

grant debug on samqa.pc_termination to sgali;

grant debug on samqa.pc_termination to rl_sam_rw;

grant debug on samqa.pc_termination to rl_sam1_ro;

