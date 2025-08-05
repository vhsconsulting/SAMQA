-- liquibase formatted sql
-- changeset SAMQA:1754373939996 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payment_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payment_bkp.sql:null:0c86bf5a83924c131cf6b82da07b9d13ddfddc1c:create

grant delete on samqa.employer_payment_bkp to rl_sam_rw;

grant insert on samqa.employer_payment_bkp to rl_sam_rw;

grant select on samqa.employer_payment_bkp to rl_sam1_ro;

grant select on samqa.employer_payment_bkp to rl_sam_rw;

grant select on samqa.employer_payment_bkp to rl_sam_ro;

grant update on samqa.employer_payment_bkp to rl_sam_rw;

