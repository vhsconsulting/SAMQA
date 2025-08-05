-- liquibase formatted sql
-- changeset SAMQA:1754373941134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_cards.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_cards.sql:null:e5defea2b0ebe8cd9a5ca4cb59e5af0177382132:create

grant delete on samqa.metavante_cards to rl_sam_rw;

grant insert on samqa.metavante_cards to rl_sam_rw;

grant select on samqa.metavante_cards to rl_sam1_ro;

grant select on samqa.metavante_cards to rl_sam_rw;

grant select on samqa.metavante_cards to rl_sam_ro;

grant update on samqa.metavante_cards to rl_sam_rw;

