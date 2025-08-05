-- liquibase formatted sql
-- changeset SAMQA:1754373935115 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_no_revenue_year.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_no_revenue_year.sql:null:d0ce6a14f9129cef42fcf3d8788b441021c78d4d:create

grant execute on samqa.broker_no_revenue_year to rl_sam_ro;

