-- liquibase formatted sql
-- changeset SAMQA:1754373940005 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payment_bkp_prod.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payment_bkp_prod.sql:null:2c3b2a1b0e83ba323e63fbb2cb3d40b5e43b20b1:create

grant delete on samqa.employer_payment_bkp_prod to rl_sam_rw;

grant insert on samqa.employer_payment_bkp_prod to rl_sam_rw;

grant select on samqa.employer_payment_bkp_prod to rl_sam1_ro;

grant select on samqa.employer_payment_bkp_prod to rl_sam_ro;

grant select on samqa.employer_payment_bkp_prod to rl_sam_rw;

grant update on samqa.employer_payment_bkp_prod to rl_sam_rw;

