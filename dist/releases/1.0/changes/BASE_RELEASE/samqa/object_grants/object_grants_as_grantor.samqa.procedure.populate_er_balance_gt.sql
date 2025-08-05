-- liquibase formatted sql
-- changeset SAMQA:1754373936985 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.populate_er_balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.populate_er_balance_gt.sql:null:9328e4d12e3dc4ce2c588dc9cbbaf0f75192987e:create

grant execute on samqa.populate_er_balance_gt to rl_sam_ro;

grant execute on samqa.populate_er_balance_gt to rl_sam_rw;

grant execute on samqa.populate_er_balance_gt to rl_sam1_ro;

grant debug on samqa.populate_er_balance_gt to rl_sam_rw;

grant debug on samqa.populate_er_balance_gt to rl_sam1_ro;

