-- liquibase formatted sql
-- changeset SAMQA:1754373940336 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.erisa_aca_eligibility_bkup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.erisa_aca_eligibility_bkup.sql:null:60b5d464124bd87ab516c234cf29f9b5470ca95c:create

grant delete on samqa.erisa_aca_eligibility_bkup to rl_sam_rw;

grant insert on samqa.erisa_aca_eligibility_bkup to rl_sam_rw;

grant select on samqa.erisa_aca_eligibility_bkup to rl_sam1_ro;

grant select on samqa.erisa_aca_eligibility_bkup to rl_sam_ro;

grant select on samqa.erisa_aca_eligibility_bkup to rl_sam_rw;

grant update on samqa.erisa_aca_eligibility_bkup to rl_sam_rw;

