-- liquibase formatted sql
-- changeset SAMQA:1754373937265 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.update_orig_sys_ref_person.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.update_orig_sys_ref_person.sql:null:4dc045c87c7feb57970fccdc85255f31d3ce1f86:create

grant execute on samqa.update_orig_sys_ref_person to rl_sam_ro;

grant execute on samqa.update_orig_sys_ref_person to rl_sam_rw;

grant execute on samqa.update_orig_sys_ref_person to rl_sam1_ro;

grant debug on samqa.update_orig_sys_ref_person to sgali;

grant debug on samqa.update_orig_sys_ref_person to rl_sam_rw;

grant debug on samqa.update_orig_sys_ref_person to rl_sam1_ro;

