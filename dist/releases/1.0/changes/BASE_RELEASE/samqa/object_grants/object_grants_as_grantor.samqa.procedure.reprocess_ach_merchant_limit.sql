-- liquibase formatted sql
-- changeset SAMQA:1754373937084 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.reprocess_ach_merchant_limit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.reprocess_ach_merchant_limit.sql:null:5897ac7fcc7cbf1434ac7e86ac93b7c5f1a9858f:create

grant execute on samqa.reprocess_ach_merchant_limit to rl_sam_ro;

grant execute on samqa.reprocess_ach_merchant_limit to rl_sam_rw;

grant execute on samqa.reprocess_ach_merchant_limit to rl_sam1_ro;

grant debug on samqa.reprocess_ach_merchant_limit to sgali;

grant debug on samqa.reprocess_ach_merchant_limit to rl_sam_rw;

grant debug on samqa.reprocess_ach_merchant_limit to rl_sam1_ro;

