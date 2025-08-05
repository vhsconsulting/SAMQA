-- liquibase formatted sql
-- changeset SAMQA:1754373942139 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.settlement_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.settlement_external.sql:null:7a6e16d5f628c45a42e8e0f8c8b7aaf3ec791b9d:create

grant select on samqa.settlement_external to rl_sam1_ro;

grant select on samqa.settlement_external to rl_sam_ro;

