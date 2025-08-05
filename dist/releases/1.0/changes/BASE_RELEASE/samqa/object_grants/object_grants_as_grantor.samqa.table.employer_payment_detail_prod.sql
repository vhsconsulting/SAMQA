-- liquibase formatted sql
-- changeset SAMQA:1754373940031 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payment_detail_prod.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payment_detail_prod.sql:null:1fe601d3ff71cf227999a6ec762b7b703cfa1b9a:create

grant delete on samqa.employer_payment_detail_prod to rl_sam_rw;

grant insert on samqa.employer_payment_detail_prod to rl_sam_rw;

grant select on samqa.employer_payment_detail_prod to rl_sam1_ro;

grant select on samqa.employer_payment_detail_prod to rl_sam_ro;

grant select on samqa.employer_payment_detail_prod to rl_sam_rw;

grant update on samqa.employer_payment_detail_prod to rl_sam_rw;

