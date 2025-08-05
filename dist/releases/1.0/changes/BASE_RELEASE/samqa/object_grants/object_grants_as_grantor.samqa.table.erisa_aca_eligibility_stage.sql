-- liquibase formatted sql
-- changeset SAMQA:1754373940352 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.erisa_aca_eligibility_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.erisa_aca_eligibility_stage.sql:null:e719d527e2a53a4aa6ee4f89957a32f4569140d4:create

grant delete on samqa.erisa_aca_eligibility_stage to rl_sam_rw;

grant insert on samqa.erisa_aca_eligibility_stage to rl_sam_rw;

grant select on samqa.erisa_aca_eligibility_stage to rl_sam1_ro;

grant select on samqa.erisa_aca_eligibility_stage to rl_sam_ro;

grant select on samqa.erisa_aca_eligibility_stage to rl_sam_rw;

grant update on samqa.erisa_aca_eligibility_stage to rl_sam_rw;

