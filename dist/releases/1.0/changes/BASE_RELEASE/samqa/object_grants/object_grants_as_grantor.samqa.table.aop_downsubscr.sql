-- liquibase formatted sql
-- changeset SAMQA:1754373938625 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_downsubscr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_downsubscr.sql:null:921a523c788ab6b4b0a8207e0e3fcdecc675920c:create

grant delete on samqa.aop_downsubscr to rl_sam_rw;

grant insert on samqa.aop_downsubscr to rl_sam_rw;

grant select on samqa.aop_downsubscr to rl_sam1_ro;

grant select on samqa.aop_downsubscr to rl_sam_ro;

grant select on samqa.aop_downsubscr to rl_sam_rw;

grant update on samqa.aop_downsubscr to rl_sam_rw;

