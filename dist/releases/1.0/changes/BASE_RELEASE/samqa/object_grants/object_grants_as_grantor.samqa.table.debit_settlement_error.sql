-- liquibase formatted sql
-- changeset SAMQA:1754373939686 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_settlement_error.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_settlement_error.sql:null:78f20edf42eb727b42ed2812f8ea50e23b6deee7:create

grant delete on samqa.debit_settlement_error to rl_sam_rw;

grant insert on samqa.debit_settlement_error to rl_sam_rw;

grant select on samqa.debit_settlement_error to rl_sam1_ro;

grant select on samqa.debit_settlement_error to rl_sam_rw;

grant select on samqa.debit_settlement_error to rl_sam_ro;

grant update on samqa.debit_settlement_error to rl_sam_rw;

