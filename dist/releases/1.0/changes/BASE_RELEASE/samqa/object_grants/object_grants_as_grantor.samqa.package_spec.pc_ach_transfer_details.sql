-- liquibase formatted sql
-- changeset SAMQA:1754373935837 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_ach_transfer_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_ach_transfer_details.sql:null:ce8b4c235ed1240a0360d93504182e51a0cf031e:create

grant execute on samqa.pc_ach_transfer_details to rl_sam_ro;

grant execute on samqa.pc_ach_transfer_details to rl_sam_rw;

grant execute on samqa.pc_ach_transfer_details to rl_sam1_ro;

grant debug on samqa.pc_ach_transfer_details to rl_sam_ro;

grant debug on samqa.pc_ach_transfer_details to sgali;

grant debug on samqa.pc_ach_transfer_details to rl_sam_rw;

grant debug on samqa.pc_ach_transfer_details to rl_sam1_ro;

