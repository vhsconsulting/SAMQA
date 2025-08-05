-- liquibase formatted sql
-- changeset SAMQA:1754373940801 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.income.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.income.sql:null:c653cf69abe785f603bf819b124c075dec8cab46:create

grant delete on samqa.income to rl_sam_rw;

grant insert on samqa.income to rl_sam_rw;

grant select on samqa.income to rl_sam1_ro;

grant select on samqa.income to rl_sam_rw;

grant select on samqa.income to rl_sam_ro;

grant select on samqa.income to reportdb_ro;

grant update on samqa.income to rl_sam_rw;

