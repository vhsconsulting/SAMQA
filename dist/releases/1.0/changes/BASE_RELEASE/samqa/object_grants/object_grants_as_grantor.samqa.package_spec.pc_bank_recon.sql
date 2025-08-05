-- liquibase formatted sql
-- changeset SAMQA:1754373935882 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_bank_recon.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_bank_recon.sql:null:891023f634537398010c53852ee4b6dbf86e957e:create

grant execute on samqa.pc_bank_recon to rl_sam_ro;

grant execute on samqa.pc_bank_recon to rl_sam_rw;

grant execute on samqa.pc_bank_recon to rl_sam1_ro;

grant debug on samqa.pc_bank_recon to sgali;

grant debug on samqa.pc_bank_recon to rl_sam_rw;

grant debug on samqa.pc_bank_recon to rl_sam1_ro;

grant debug on samqa.pc_bank_recon to rl_sam_ro;

