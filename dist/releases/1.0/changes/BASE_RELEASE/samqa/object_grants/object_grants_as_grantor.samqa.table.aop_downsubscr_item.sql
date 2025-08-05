-- liquibase formatted sql
-- changeset SAMQA:1754373938634 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_downsubscr_item.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_downsubscr_item.sql:null:7edb22953fccd06c51e76a395f79715120117519:create

grant delete on samqa.aop_downsubscr_item to rl_sam_rw;

grant insert on samqa.aop_downsubscr_item to rl_sam_rw;

grant select on samqa.aop_downsubscr_item to rl_sam1_ro;

grant select on samqa.aop_downsubscr_item to rl_sam_ro;

grant select on samqa.aop_downsubscr_item to rl_sam_rw;

grant update on samqa.aop_downsubscr_item to rl_sam_rw;

