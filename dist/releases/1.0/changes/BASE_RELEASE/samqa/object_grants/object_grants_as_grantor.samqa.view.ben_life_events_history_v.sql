-- liquibase formatted sql
-- changeset SAMQA:1754373942975 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ben_life_events_history_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ben_life_events_history_v.sql:null:e9c2d17c37c776e822463951beaa462c6b71610d:create

grant select on samqa.ben_life_events_history_v to rl_sam1_ro;

grant select on samqa.ben_life_events_history_v to rl_sam_rw;

grant select on samqa.ben_life_events_history_v to rl_sam_ro;

grant select on samqa.ben_life_events_history_v to sgali;

