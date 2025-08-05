-- liquibase formatted sql
-- changeset SAMQA:1754373945375 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.us_states.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.us_states.sql:null:238b2bb16d46811cabd488336a5893a50d898901:create

grant select on samqa.us_states to rl_sam_rw;

grant select on samqa.us_states to rl_sam_ro;

grant select on samqa.us_states to sgali;

grant select on samqa.us_states to rl_sam1_ro;

