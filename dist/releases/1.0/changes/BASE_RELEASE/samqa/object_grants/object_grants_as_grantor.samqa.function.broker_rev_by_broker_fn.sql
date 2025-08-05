-- liquibase formatted sql
-- changeset SAMQA:1754373935120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_rev_by_broker_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_rev_by_broker_fn.sql:null:804172748e7f662679b0d6de132346047bd228f3:create

grant execute on samqa.broker_rev_by_broker_fn to rl_sam_ro;

