-- liquibase formatted sql
-- changeset SAMQA:1754373939706 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.deductible_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.deductible_balance.sql:null:fc13b6d63e27039a768d6d05ffb152bd4347e8fe:create

grant delete on samqa.deductible_balance to rl_sam_rw;

grant insert on samqa.deductible_balance to rl_sam_rw;

grant select on samqa.deductible_balance to rl_sam_ro;

grant select on samqa.deductible_balance to rl_sam1_ro;

grant select on samqa.deductible_balance to rl_sam_rw;

grant update on samqa.deductible_balance to rl_sam_rw;

