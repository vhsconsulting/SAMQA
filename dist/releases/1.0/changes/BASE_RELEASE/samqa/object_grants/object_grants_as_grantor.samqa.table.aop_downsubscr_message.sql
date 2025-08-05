-- liquibase formatted sql
-- changeset SAMQA:1754373938652 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_downsubscr_message.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_downsubscr_message.sql:null:03cb0006cf9594020e4b269c3c700c73cc502a6c:create

grant delete on samqa.aop_downsubscr_message to rl_sam_rw;

grant insert on samqa.aop_downsubscr_message to rl_sam_rw;

grant select on samqa.aop_downsubscr_message to rl_sam1_ro;

grant select on samqa.aop_downsubscr_message to rl_sam_ro;

grant select on samqa.aop_downsubscr_message to rl_sam_rw;

grant update on samqa.aop_downsubscr_message to rl_sam_rw;

