-- liquibase formatted sql
-- changeset SAMQA:1754373936397 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_person.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_person.sql:null:1aacf3c871bcace70b85432a92961f2994ac0c44:create

grant execute on samqa.pc_person to rl_sam_ro;

grant execute on samqa.pc_person to rl_sam_rw;

grant execute on samqa.pc_person to rl_sam1_ro;

grant debug on samqa.pc_person to rl_sam_ro;

grant debug on samqa.pc_person to sgali;

grant debug on samqa.pc_person to rl_sam_rw;

grant debug on samqa.pc_person to rl_sam1_ro;

