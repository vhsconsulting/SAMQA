-- liquibase formatted sql
-- changeset SAMQA:1754373935977 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_cobra_disbursement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_cobra_disbursement.sql:null:b6453292ac0b90aa597a808ded86151cb9b8b909:create

grant execute on samqa.pc_cobra_disbursement to rl_sam_rw;

grant execute on samqa.pc_cobra_disbursement to rl_sam1_ro;

grant execute on samqa.pc_cobra_disbursement to rl_sam_ro;

grant debug on samqa.pc_cobra_disbursement to rl_sam_rw;

grant debug on samqa.pc_cobra_disbursement to rl_sam1_ro;

grant debug on samqa.pc_cobra_disbursement to rl_sam_ro;

