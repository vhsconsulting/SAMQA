-- liquibase formatted sql
-- changeset SAMQA:1754373942075 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.scheduler_master.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.scheduler_master.sql:null:ad5a4cccb150bff1533b097082f37073b20fc154:create

grant delete on samqa.scheduler_master to rl_sam_rw;

grant insert on samqa.scheduler_master to rl_sam_rw;

grant select on samqa.scheduler_master to rl_sam1_ro;

grant select on samqa.scheduler_master to rl_sam_rw;

grant select on samqa.scheduler_master to rl_sam_ro;

grant update on samqa.scheduler_master to rl_sam_rw;

