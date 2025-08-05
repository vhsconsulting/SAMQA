-- liquibase formatted sql
-- changeset SAMQA:1754373940328 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.erisa_aca_eligibility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.erisa_aca_eligibility.sql:null:5a9235c538e3be54cbcd993f12cea05573ad387a:create

grant delete on samqa.erisa_aca_eligibility to rl_sam_rw;

grant insert on samqa.erisa_aca_eligibility to rl_sam_rw;

grant select on samqa.erisa_aca_eligibility to rl_sam1_ro;

grant select on samqa.erisa_aca_eligibility to rl_sam_ro;

grant select on samqa.erisa_aca_eligibility to rl_sam_rw;

grant update on samqa.erisa_aca_eligibility to rl_sam_rw;

