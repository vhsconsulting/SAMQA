-- liquibase formatted sql
-- changeset SAMQA:1754373937137 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.run_hsa_manual_scheuler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.run_hsa_manual_scheuler.sql:null:505160a6233201f6136b7d6441601a5d8d623ee6:create

grant execute on samqa.run_hsa_manual_scheuler to rl_sam_ro;

grant execute on samqa.run_hsa_manual_scheuler to public;

grant execute on samqa.run_hsa_manual_scheuler to rl_sam_rw;

grant execute on samqa.run_hsa_manual_scheuler to rl_sam1_ro;

grant debug on samqa.run_hsa_manual_scheuler to public;

grant debug on samqa.run_hsa_manual_scheuler to rl_sam_rw;

grant debug on samqa.run_hsa_manual_scheuler to rl_sam1_ro;

