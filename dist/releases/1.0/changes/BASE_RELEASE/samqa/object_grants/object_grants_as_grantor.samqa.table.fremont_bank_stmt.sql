-- liquibase formatted sql
-- changeset SAMQA:1754373940534 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fremont_bank_stmt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fremont_bank_stmt.sql:null:f78e4729226cf3867c53bed8f08b759ff7f821e6:create

grant delete on samqa.fremont_bank_stmt to rl_sam_rw;

grant insert on samqa.fremont_bank_stmt to rl_sam_rw;

grant select on samqa.fremont_bank_stmt to rl_sam1_ro;

grant select on samqa.fremont_bank_stmt to rl_sam_rw;

grant select on samqa.fremont_bank_stmt to rl_sam_ro;

grant update on samqa.fremont_bank_stmt to rl_sam_rw;

