-- liquibase formatted sql
-- changeset SAMQA:1754373936895 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.insert_er_balance_gtt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.insert_er_balance_gtt.sql:null:98ea8569126487dad413f6e77546838d5cb2694b:create

grant execute on samqa.insert_er_balance_gtt to rl_sam_ro;

grant execute on samqa.insert_er_balance_gtt to rl_sam_rw;

grant execute on samqa.insert_er_balance_gtt to rl_sam1_ro;

grant debug on samqa.insert_er_balance_gtt to rl_sam_rw;

grant debug on samqa.insert_er_balance_gtt to rl_sam1_ro;

