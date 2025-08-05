-- liquibase formatted sql
-- changeset SAMQA:1754373936061 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_deposit_reconcilation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_deposit_reconcilation.sql:null:a6fea1e0cb7680b4218e82ad7b01b4fec7c4906b:create

grant execute on samqa.pc_deposit_reconcilation to rl_sam_ro;

grant execute on samqa.pc_deposit_reconcilation to rl_sam_rw;

grant execute on samqa.pc_deposit_reconcilation to rl_sam1_ro;

grant debug on samqa.pc_deposit_reconcilation to rl_sam_ro;

grant debug on samqa.pc_deposit_reconcilation to sgali;

grant debug on samqa.pc_deposit_reconcilation to rl_sam_rw;

grant debug on samqa.pc_deposit_reconcilation to rl_sam1_ro;

