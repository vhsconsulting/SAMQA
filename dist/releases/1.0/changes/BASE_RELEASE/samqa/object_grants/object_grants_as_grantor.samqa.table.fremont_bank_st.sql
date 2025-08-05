-- liquibase formatted sql
-- changeset SAMQA:1754373940527 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fremont_bank_st.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fremont_bank_st.sql:null:6d4f3b7465b4aff7e305a4449e53ffb565543d86:create

grant delete on samqa.fremont_bank_st to rl_sam_rw;

grant insert on samqa.fremont_bank_st to rl_sam_rw;

grant select on samqa.fremont_bank_st to rl_sam1_ro;

grant select on samqa.fremont_bank_st to rl_sam_rw;

grant select on samqa.fremont_bank_st to rl_sam_ro;

grant update on samqa.fremont_bank_st to rl_sam_rw;

