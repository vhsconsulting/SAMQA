-- liquibase formatted sql
-- changeset SAMQA:1754373938642 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_downsubscr_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_downsubscr_log.sql:null:926cd3b0645ba9927e8869dc56d1a192e274390a:create

grant delete on samqa.aop_downsubscr_log to rl_sam_rw;

grant insert on samqa.aop_downsubscr_log to rl_sam_rw;

grant select on samqa.aop_downsubscr_log to rl_sam1_ro;

grant select on samqa.aop_downsubscr_log to rl_sam_ro;

grant select on samqa.aop_downsubscr_log to rl_sam_rw;

grant update on samqa.aop_downsubscr_log to rl_sam_rw;

