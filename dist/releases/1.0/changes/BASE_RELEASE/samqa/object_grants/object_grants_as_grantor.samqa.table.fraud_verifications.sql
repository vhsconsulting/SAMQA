-- liquibase formatted sql
-- changeset SAMQA:1754373940519 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fraud_verifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fraud_verifications.sql:null:c08d2a5a39300d13ba2f87a40e56b7afb5de3030:create

grant delete on samqa.fraud_verifications to rl_sam_rw;

grant insert on samqa.fraud_verifications to rl_sam_rw;

grant select on samqa.fraud_verifications to rl_sam1_ro;

grant select on samqa.fraud_verifications to rl_sam_rw;

grant select on samqa.fraud_verifications to rl_sam_ro;

grant update on samqa.fraud_verifications to rl_sam_rw;

