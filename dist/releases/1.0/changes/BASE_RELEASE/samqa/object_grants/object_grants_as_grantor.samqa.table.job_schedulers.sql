-- liquibase formatted sql
-- changeset SAMQA:1754373940960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.job_schedulers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.job_schedulers.sql:null:42d5f7e09e74fc2c850e8f02c6ab3d6d812f5ad2:create

grant delete on samqa.job_schedulers to rl_sam_rw;

grant insert on samqa.job_schedulers to rl_sam_rw;

grant select on samqa.job_schedulers to rl_sam1_ro;

grant select on samqa.job_schedulers to rl_sam_ro;

grant select on samqa.job_schedulers to rl_sam_rw;

grant update on samqa.job_schedulers to rl_sam_rw;

