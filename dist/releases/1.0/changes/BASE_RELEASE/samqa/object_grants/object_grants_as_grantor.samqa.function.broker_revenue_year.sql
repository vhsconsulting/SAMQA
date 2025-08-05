-- liquibase formatted sql
-- changeset SAMQA:1754373935164 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_revenue_year.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_revenue_year.sql:null:c8bce821bb5d174bfd4c5f66d27b075df3e19149:create

grant execute on samqa.broker_revenue_year to rl_sam_rw;

grant execute on samqa.broker_revenue_year to rl_sam_ro;

grant debug on samqa.broker_revenue_year to rl_sam_rw;

grant debug on samqa.broker_revenue_year to rl_sam_ro;

