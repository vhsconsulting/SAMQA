-- liquibase formatted sql
-- changeset SAMQA:1754373935128 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_rev_rnw_by_broker_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_rev_rnw_by_broker_fn.sql:null:a001af2489756ab37271f4a5ca26ed8db0de2ed8:create

grant execute on samqa.broker_rev_rnw_by_broker_fn to rl_sam_ro;

