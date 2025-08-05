-- liquibase formatted sql
-- changeset SAMQA:1754373936702 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.check_grace_period_claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.check_grace_period_claim.sql:null:d240f0d239c33578fbd7a2105f3de91df713228f:create

grant execute on samqa.check_grace_period_claim to rl_sam_ro;

