-- liquibase formatted sql
-- changeset SAMQA:1754373941197 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_result_external.sql:null:d447fe788e55dc46d62535de83fca600506d9ebe:create

grant select on samqa.metavante_result_external to rl_sam1_ro;

grant select on samqa.metavante_result_external to rl_sam_ro;

