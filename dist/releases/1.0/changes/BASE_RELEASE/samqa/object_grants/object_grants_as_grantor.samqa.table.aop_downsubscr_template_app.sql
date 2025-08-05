-- liquibase formatted sql
-- changeset SAMQA:1754373938676 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_downsubscr_template_app.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_downsubscr_template_app.sql:null:3c7dc360df9550b7aa33ae7d4bc0ba06ff35ccc0:create

grant delete on samqa.aop_downsubscr_template_app to rl_sam_rw;

grant insert on samqa.aop_downsubscr_template_app to rl_sam_rw;

grant select on samqa.aop_downsubscr_template_app to rl_sam1_ro;

grant select on samqa.aop_downsubscr_template_app to rl_sam_ro;

grant select on samqa.aop_downsubscr_template_app to rl_sam_rw;

grant update on samqa.aop_downsubscr_template_app to rl_sam_rw;

