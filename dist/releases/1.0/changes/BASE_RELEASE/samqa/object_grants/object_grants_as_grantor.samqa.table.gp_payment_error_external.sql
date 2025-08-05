-- liquibase formatted sql
-- changeset SAMQA:1754373940669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_payment_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_payment_error_external.sql:null:669f92d36647378d386c4ff74abb46f4a4f8d8e6:create

grant select on samqa.gp_payment_error_external to rl_sam1_ro;

grant select on samqa.gp_payment_error_external to rl_sam_ro;

