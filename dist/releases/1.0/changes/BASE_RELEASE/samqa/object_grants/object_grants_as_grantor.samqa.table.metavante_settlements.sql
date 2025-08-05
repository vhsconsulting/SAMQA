-- liquibase formatted sql
-- changeset SAMQA:1754373941197 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_settlements.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_settlements.sql:null:95e9a4b1e230ef368a085f2a5576d041ed8556dc:create

grant delete on samqa.metavante_settlements to rl_sam_rw;

grant insert on samqa.metavante_settlements to rl_sam_rw;

grant select on samqa.metavante_settlements to rl_sam1_ro;

grant select on samqa.metavante_settlements to rl_sam_rw;

grant select on samqa.metavante_settlements to rl_sam_ro;

grant update on samqa.metavante_settlements to rl_sam_rw;

