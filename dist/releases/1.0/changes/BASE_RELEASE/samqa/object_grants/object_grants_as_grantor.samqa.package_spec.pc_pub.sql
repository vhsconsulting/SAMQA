-- liquibase formatted sql
-- changeset SAMQA:1754373936414 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_pub.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_pub.sql:null:86e6d0727fb1d05965f1f6a8353376a4f20830d6:create

grant execute on samqa.pc_pub to rl_sam_ro;

grant execute on samqa.pc_pub to rl_sam_rw;

grant execute on samqa.pc_pub to rl_sam1_ro;

grant debug on samqa.pc_pub to sgali;

grant debug on samqa.pc_pub to rl_sam_rw;

grant debug on samqa.pc_pub to rl_sam1_ro;

