-- liquibase formatted sql
-- changeset SAMQA:1754373939762 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.deposit_reconcile_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.deposit_reconcile_external.sql:null:134ce4d45bcc3123b90aff834c25c6fc31fae9d8:create

grant select on samqa.deposit_reconcile_external to rl_sam1_ro;

grant select on samqa.deposit_reconcile_external to rl_sam_ro;

