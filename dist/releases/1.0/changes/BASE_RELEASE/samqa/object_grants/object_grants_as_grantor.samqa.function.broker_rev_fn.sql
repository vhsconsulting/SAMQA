-- liquibase formatted sql
-- changeset SAMQA:1754373935124 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_rev_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_rev_fn.sql:null:12ad427de99c1dc1438b3c00a25306a557372445:create

grant execute on samqa.broker_rev_fn to rl_sam_ro;

