-- liquibase formatted sql
-- changeset SAMQA:1754373938660 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_downsubscr_output.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_downsubscr_output.sql:null:f737bcd48b709105a3f5092d590b1db10a5a01d4:create

grant delete on samqa.aop_downsubscr_output to rl_sam_rw;

grant insert on samqa.aop_downsubscr_output to rl_sam_rw;

grant select on samqa.aop_downsubscr_output to rl_sam1_ro;

grant select on samqa.aop_downsubscr_output to rl_sam_ro;

grant select on samqa.aop_downsubscr_output to rl_sam_rw;

grant update on samqa.aop_downsubscr_output to rl_sam_rw;

