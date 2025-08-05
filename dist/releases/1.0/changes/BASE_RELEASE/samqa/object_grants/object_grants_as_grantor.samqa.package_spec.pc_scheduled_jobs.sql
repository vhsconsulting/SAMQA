-- liquibase formatted sql
-- changeset SAMQA:1754373936486 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_scheduled_jobs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_scheduled_jobs.sql:null:f6379a3593267edb46e6b6c2a6a5b85d7269e728:create

grant execute on samqa.pc_scheduled_jobs to rjoshi;

grant execute on samqa.pc_scheduled_jobs to rl_sam1_ro;

grant execute on samqa.pc_scheduled_jobs to rl_sam_rw;

grant execute on samqa.pc_scheduled_jobs to rl_sam_ro;

grant debug on samqa.pc_scheduled_jobs to rl_sam_ro;

grant debug on samqa.pc_scheduled_jobs to rl_sam1_ro;

grant debug on samqa.pc_scheduled_jobs to rl_sam_rw;

