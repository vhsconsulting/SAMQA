-- liquibase formatted sql
-- changeset SAMQA:1754373935545 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.sales_activity_log_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.sales_activity_log_fn.sql:null:54558932217b2f7ed5ee6ba82bc51d87411a4817:create

grant execute on samqa.sales_activity_log_fn to rl_sam_ro;

