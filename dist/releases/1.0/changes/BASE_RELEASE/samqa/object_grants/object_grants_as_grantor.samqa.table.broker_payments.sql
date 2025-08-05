-- liquibase formatted sql
-- changeset SAMQA:1754373939125 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_payments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_payments.sql:null:99df0d8a2c20bf277a7593e88371421ff7a055cb:create

grant delete on samqa.broker_payments to rl_sam_rw;

grant insert on samqa.broker_payments to rl_sam_rw;

grant select on samqa.broker_payments to rl_sam1_ro;

grant select on samqa.broker_payments to rl_sam_rw;

grant select on samqa.broker_payments to rl_sam_ro;

grant update on samqa.broker_payments to rl_sam_rw;

