-- liquibase formatted sql
-- changeset SAMQA:1754373938419 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.account_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.account_history.sql:null:93e3d16c8f4ce919c1e333c54113cfb12ad1c4a3:create

grant delete on samqa.account_history to rl_sam_rw;

grant insert on samqa.account_history to rl_sam_rw;

grant select on samqa.account_history to rl_sam1_ro;

grant select on samqa.account_history to rl_sam_rw;

grant select on samqa.account_history to rl_sam_ro;

grant update on samqa.account_history to rl_sam_rw;

