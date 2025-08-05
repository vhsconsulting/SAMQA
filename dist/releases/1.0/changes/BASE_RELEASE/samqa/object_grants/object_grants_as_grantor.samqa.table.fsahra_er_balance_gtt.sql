-- liquibase formatted sql
-- changeset SAMQA:1754373940553 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fsahra_er_balance_gtt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fsahra_er_balance_gtt.sql:null:67624e2107d6a2fe434c3ee7b252785bfb036b38:create

grant delete on samqa.fsahra_er_balance_gtt to rl_sam_rw;

grant insert on samqa.fsahra_er_balance_gtt to rl_sam_rw;

grant select on samqa.fsahra_er_balance_gtt to rl_sam1_ro;

grant select on samqa.fsahra_er_balance_gtt to rl_sam_ro;

grant select on samqa.fsahra_er_balance_gtt to rl_sam_rw;

grant update on samqa.fsahra_er_balance_gtt to rl_sam_rw;

