-- liquibase formatted sql
-- changeset SAMQA:1754373938668 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_downsubscr_template.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_downsubscr_template.sql:null:e7ae74cad6201f0554136093ffff0a0995c58e24:create

grant delete on samqa.aop_downsubscr_template to rl_sam_rw;

grant insert on samqa.aop_downsubscr_template to rl_sam_rw;

grant select on samqa.aop_downsubscr_template to rl_sam1_ro;

grant select on samqa.aop_downsubscr_template to rl_sam_ro;

grant select on samqa.aop_downsubscr_template to rl_sam_rw;

grant update on samqa.aop_downsubscr_template to rl_sam_rw;

