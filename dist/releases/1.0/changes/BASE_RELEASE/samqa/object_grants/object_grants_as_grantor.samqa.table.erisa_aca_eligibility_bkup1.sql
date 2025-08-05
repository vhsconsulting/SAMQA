-- liquibase formatted sql
-- changeset SAMQA:1754373940344 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.erisa_aca_eligibility_bkup1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.erisa_aca_eligibility_bkup1.sql:null:c26ad595ef14332d99390a79e2480aef97c9bb27:create

grant delete on samqa.erisa_aca_eligibility_bkup1 to rl_sam_rw;

grant insert on samqa.erisa_aca_eligibility_bkup1 to rl_sam_rw;

grant select on samqa.erisa_aca_eligibility_bkup1 to rl_sam1_ro;

grant select on samqa.erisa_aca_eligibility_bkup1 to rl_sam_ro;

grant select on samqa.erisa_aca_eligibility_bkup1 to rl_sam_rw;

grant update on samqa.erisa_aca_eligibility_bkup1 to rl_sam_rw;

