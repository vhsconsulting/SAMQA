-- liquibase formatted sql
-- changeset SAMQA:1754373935829 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_ach_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_ach_transfer.sql:null:f3f8d27e385f71bf25744979102cbf9a75903445:create

grant execute on samqa.pc_ach_transfer to rl_sam_ro;

grant execute on samqa.pc_ach_transfer to rl_sam_rw;

grant execute on samqa.pc_ach_transfer to rl_sam1_ro;

grant debug on samqa.pc_ach_transfer to rl_sam_ro;

grant debug on samqa.pc_ach_transfer to sgali;

grant debug on samqa.pc_ach_transfer to rl_sam_rw;

grant debug on samqa.pc_ach_transfer to rl_sam1_ro;

