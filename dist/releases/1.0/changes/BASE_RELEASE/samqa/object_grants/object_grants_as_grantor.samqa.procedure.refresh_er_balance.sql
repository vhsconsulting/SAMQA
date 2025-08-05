-- liquibase formatted sql
-- changeset SAMQA:1754373937064 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.refresh_er_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.refresh_er_balance.sql:null:f86dbafc98b024f2179df2096e1a5e5338a6f91d:create

grant execute on samqa.refresh_er_balance to rl_sam1_ro;

grant execute on samqa.refresh_er_balance to rl_sam_ro;

grant execute on samqa.refresh_er_balance to rl_sam_rw;

grant debug on samqa.refresh_er_balance to sgali;

grant debug on samqa.refresh_er_balance to rl_sam_rw;

grant debug on samqa.refresh_er_balance to rl_sam1_ro;

