-- liquibase formatted sql
-- changeset SAMQA:1754373936257 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_invoice_division.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_invoice_division.sql:null:d8352c35026ed0e91e393bdbf16de721583a69d8:create

grant execute on samqa.pc_invoice_division to rl_sam_ro;

grant execute on samqa.pc_invoice_division to rl_sam_rw;

grant execute on samqa.pc_invoice_division to rl_sam1_ro;

grant debug on samqa.pc_invoice_division to sgali;

grant debug on samqa.pc_invoice_division to rl_sam_rw;

grant debug on samqa.pc_invoice_division to rl_sam1_ro;

