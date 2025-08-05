-- liquibase formatted sql
-- changeset SAMQA:1754373940085 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payments_prod.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payments_prod.sql:null:2f3377d1a72a49f8088fcacab7a3f5ca577702fa:create

grant delete on samqa.employer_payments_prod to rl_sam_rw;

grant insert on samqa.employer_payments_prod to rl_sam_rw;

grant select on samqa.employer_payments_prod to rl_sam_rw;

grant select on samqa.employer_payments_prod to rl_sam1_ro;

grant select on samqa.employer_payments_prod to rl_sam_ro;

grant update on samqa.employer_payments_prod to rl_sam_rw;

