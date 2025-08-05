-- liquibase formatted sql
-- changeset SAMQA:1754373935148 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_revenue_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_revenue_mv.sql:null:dfa8c67f59083ba3cd6f4f9c6fbf6efb812ba260:create

grant execute on samqa.broker_revenue_mv to rl_sam_ro;

