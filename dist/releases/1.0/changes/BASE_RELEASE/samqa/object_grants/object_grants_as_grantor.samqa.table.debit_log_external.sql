-- liquibase formatted sql
-- changeset SAMQA:1754373939676 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.debit_log_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.debit_log_external.sql:null:cabc562d9f15f1e9a31aa259766f6f1382250ee1:create

grant select on samqa.debit_log_external to rl_sam1_ro;

grant select on samqa.debit_log_external to rl_sam_ro;

