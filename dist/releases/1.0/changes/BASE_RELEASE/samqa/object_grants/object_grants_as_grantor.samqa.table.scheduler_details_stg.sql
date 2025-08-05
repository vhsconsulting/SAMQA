-- liquibase formatted sql
-- changeset SAMQA:1754373942060 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.scheduler_details_stg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.scheduler_details_stg.sql:null:51291224ff317a3b949d91cbc2a80ac4b6c76cc5:create

grant delete on samqa.scheduler_details_stg to rl_sam_rw;

grant insert on samqa.scheduler_details_stg to rl_sam_rw;

grant select on samqa.scheduler_details_stg to rl_sam1_ro;

grant select on samqa.scheduler_details_stg to rl_sam_rw;

grant select on samqa.scheduler_details_stg to rl_sam_ro;

grant update on samqa.scheduler_details_stg to rl_sam_rw;

