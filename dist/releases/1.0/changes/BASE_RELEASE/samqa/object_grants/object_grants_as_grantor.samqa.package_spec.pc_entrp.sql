-- liquibase formatted sql
-- changeset SAMQA:1754373936124 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_entrp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_entrp.sql:null:8714cbbd91bfdf9af79ebce2953ff20d982e9b62:create

grant execute on samqa.pc_entrp to rl_sam_ro;

grant execute on samqa.pc_entrp to rl_sam_rw;

grant execute on samqa.pc_entrp to rl_sam1_ro;

grant debug on samqa.pc_entrp to sgali;

grant debug on samqa.pc_entrp to rl_sam_rw;

grant debug on samqa.pc_entrp to rl_sam1_ro;

grant debug on samqa.pc_entrp to rl_sam_ro;

