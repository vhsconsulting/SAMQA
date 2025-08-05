-- liquibase formatted sql
-- changeset SAMQA:1754373938872 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.batch_jobs_result_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.batch_jobs_result_log.sql:null:c7f2e1fea1f635e1f2e5610e2a2e2c1032b62e69:create

grant delete on samqa.batch_jobs_result_log to rl_sam_rw;

grant insert on samqa.batch_jobs_result_log to rl_sam_rw;

grant select on samqa.batch_jobs_result_log to rl_sam1_ro;

grant select on samqa.batch_jobs_result_log to rl_sam_ro;

grant select on samqa.batch_jobs_result_log to rl_sam_rw;

grant update on samqa.batch_jobs_result_log to rl_sam_rw;

