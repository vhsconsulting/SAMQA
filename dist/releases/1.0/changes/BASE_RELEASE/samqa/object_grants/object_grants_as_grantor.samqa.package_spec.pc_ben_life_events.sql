-- liquibase formatted sql
-- changeset SAMQA:1754373935898 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_ben_life_events.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_ben_life_events.sql:null:5cccbdaaef2cace83875686a88cba60c29c38bb9:create

grant execute on samqa.pc_ben_life_events to rl_sam_ro;

grant execute on samqa.pc_ben_life_events to rl_sam_rw;

grant execute on samqa.pc_ben_life_events to rl_sam1_ro;

grant debug on samqa.pc_ben_life_events to rl_sam_ro;

grant debug on samqa.pc_ben_life_events to sgali;

grant debug on samqa.pc_ben_life_events to rl_sam_rw;

grant debug on samqa.pc_ben_life_events to rl_sam1_ro;

