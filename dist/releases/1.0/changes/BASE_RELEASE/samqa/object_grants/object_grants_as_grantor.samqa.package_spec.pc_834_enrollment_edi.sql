-- liquibase formatted sql
-- changeset SAMQA:1754373935805 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_834_enrollment_edi.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_834_enrollment_edi.sql:null:657f3defcefb6fc4e6815c8636b5324462b6c863:create

grant execute on samqa.pc_834_enrollment_edi to rl_sam_ro;

grant execute on samqa.pc_834_enrollment_edi to rl_sam_rw;

grant execute on samqa.pc_834_enrollment_edi to rl_sam1_ro;

grant debug on samqa.pc_834_enrollment_edi to rl_sam_ro;

grant debug on samqa.pc_834_enrollment_edi to sgali;

grant debug on samqa.pc_834_enrollment_edi to rl_sam_rw;

grant debug on samqa.pc_834_enrollment_edi to rl_sam1_ro;

