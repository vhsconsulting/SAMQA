-- liquibase formatted sql
-- changeset SAMQA:1754373936249 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_invoice.sql:null:28f6695b65e3b11bba2bb0fa31c088b4dc824b5e:create

grant execute on samqa.pc_invoice to rl_sam_ro;

grant execute on samqa.pc_invoice to rl_sam_rw;

grant execute on samqa.pc_invoice to rl_sam1_ro;

grant debug on samqa.pc_invoice to sgali;

grant debug on samqa.pc_invoice to rl_sam_rw;

grant debug on samqa.pc_invoice to rl_sam1_ro;

grant debug on samqa.pc_invoice to rl_sam_ro;

