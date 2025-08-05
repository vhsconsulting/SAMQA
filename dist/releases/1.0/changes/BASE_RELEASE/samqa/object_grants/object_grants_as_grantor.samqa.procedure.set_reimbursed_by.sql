-- liquibase formatted sql
-- changeset SAMQA:1754373937216 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.set_reimbursed_by.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.set_reimbursed_by.sql:null:a71e1b7fcb4a44b9648c701785e437a645a283f6:create

grant execute on samqa.set_reimbursed_by to rl_sam_ro;

grant execute on samqa.set_reimbursed_by to rl_sam_rw;

grant execute on samqa.set_reimbursed_by to rl_sam1_ro;

grant debug on samqa.set_reimbursed_by to rl_sam_rw;

grant debug on samqa.set_reimbursed_by to rl_sam1_ro;

