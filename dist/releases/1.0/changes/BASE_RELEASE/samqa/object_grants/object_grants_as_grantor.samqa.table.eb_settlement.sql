-- liquibase formatted sql
-- changeset SAMQA:1754373939816 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eb_settlement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eb_settlement.sql:null:8f4336c5ff2bf1b11bad8ae43a745522fb3420bb:create

grant delete on samqa.eb_settlement to rl_sam_rw;

grant insert on samqa.eb_settlement to rl_sam_rw;

grant select on samqa.eb_settlement to rl_sam1_ro;

grant select on samqa.eb_settlement to rl_sam_rw;

grant select on samqa.eb_settlement to rl_sam_ro;

grant update on samqa.eb_settlement to rl_sam_rw;

