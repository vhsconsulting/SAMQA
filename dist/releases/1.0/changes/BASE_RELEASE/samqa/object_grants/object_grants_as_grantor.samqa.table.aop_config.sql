-- liquibase formatted sql
-- changeset SAMQA:1754373938617 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aop_config.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aop_config.sql:null:8e0f24486c8493202c865bec1d83d470b65c3432:create

grant delete on samqa.aop_config to rl_sam_rw;

grant insert on samqa.aop_config to rl_sam_rw;

grant select on samqa.aop_config to rl_sam1_ro;

grant select on samqa.aop_config to rl_sam_ro;

grant select on samqa.aop_config to rl_sam_rw;

grant update on samqa.aop_config to rl_sam_rw;

