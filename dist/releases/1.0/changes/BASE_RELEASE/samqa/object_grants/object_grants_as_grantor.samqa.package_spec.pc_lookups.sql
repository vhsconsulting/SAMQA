-- liquibase formatted sql
-- changeset SAMQA:1754373936293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_lookups.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_lookups.sql:null:99bf617a3d2dd87fb605dae60d7ef3729eb72a81:create

grant execute on samqa.pc_lookups to public;

grant execute on samqa.pc_lookups to rl_sam_ro;

grant execute on samqa.pc_lookups to rl_sam_rw;

grant execute on samqa.pc_lookups to rl_sam1_ro;

grant debug on samqa.pc_lookups to public;

grant debug on samqa.pc_lookups to sgali;

grant debug on samqa.pc_lookups to rl_sam_rw;

grant debug on samqa.pc_lookups to rl_sam1_ro;

grant debug on samqa.pc_lookups to rl_sam_ro;

