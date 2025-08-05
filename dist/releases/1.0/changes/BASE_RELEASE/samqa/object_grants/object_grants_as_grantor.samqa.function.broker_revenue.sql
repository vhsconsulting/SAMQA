-- liquibase formatted sql
-- changeset SAMQA:1754373935142 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_revenue.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_revenue.sql:null:3dc8d186f6a1ff2aea2b2908f268d133524050a0:create

grant execute on samqa.broker_revenue to rl_sam_rw;

grant execute on samqa.broker_revenue to rl_sam_ro;

grant debug on samqa.broker_revenue to rl_sam_rw;

grant debug on samqa.broker_revenue to rl_sam_ro;

