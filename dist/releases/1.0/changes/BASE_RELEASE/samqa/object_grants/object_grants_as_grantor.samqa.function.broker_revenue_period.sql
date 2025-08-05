-- liquibase formatted sql
-- changeset SAMQA:1754373935155 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_revenue_period.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_revenue_period.sql:null:91bded79638996b9e196d2ce8df975c244651d00:create

grant execute on samqa.broker_revenue_period to rl_sam_ro;

