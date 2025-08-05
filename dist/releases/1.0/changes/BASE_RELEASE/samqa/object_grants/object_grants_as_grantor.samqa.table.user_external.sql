-- liquibase formatted sql
-- changeset SAMQA:1754373942396 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.user_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.user_external.sql:null:8a08affb8afb72e3ddae90a330cb6b63e2618604:create

grant select on samqa.user_external to rl_sam1_ro;

grant select on samqa.user_external to rl_sam_ro;

