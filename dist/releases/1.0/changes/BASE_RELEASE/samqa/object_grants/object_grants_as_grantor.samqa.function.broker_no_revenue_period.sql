-- liquibase formatted sql
-- changeset SAMQA:1754373935110 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_no_revenue_period.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_no_revenue_period.sql:null:9c755ab83d92011aefcaac39b7429f64fc61c703:create

grant execute on samqa.broker_no_revenue_period to rl_sam_ro;

grant execute on samqa.broker_no_revenue_period to rl_sam_rw;

grant debug on samqa.broker_no_revenue_period to rl_sam_ro;

grant debug on samqa.broker_no_revenue_period to rl_sam_rw;

