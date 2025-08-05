-- liquibase formatted sql
-- changeset SAMQA:1754373938879 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ben_life_event_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ben_life_event_history.sql:null:fa73c4a50de75a97a75df216d010f46e70921dd2:create

grant delete on samqa.ben_life_event_history to rl_sam_rw;

grant insert on samqa.ben_life_event_history to rl_sam_rw;

grant select on samqa.ben_life_event_history to rl_sam1_ro;

grant select on samqa.ben_life_event_history to rl_sam_rw;

grant select on samqa.ben_life_event_history to rl_sam_ro;

grant update on samqa.ben_life_event_history to rl_sam_rw;

