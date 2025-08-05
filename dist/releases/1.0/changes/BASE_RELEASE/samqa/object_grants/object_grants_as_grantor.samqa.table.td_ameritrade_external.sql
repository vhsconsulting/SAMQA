-- liquibase formatted sql
-- changeset SAMQA:1754373942278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.td_ameritrade_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.td_ameritrade_external.sql:null:ac91dc7a7c7b321d476cf3f51721e640e0917002:create

grant select on samqa.td_ameritrade_external to rl_sam1_ro;

grant select on samqa.td_ameritrade_external to rl_sam_ro;

