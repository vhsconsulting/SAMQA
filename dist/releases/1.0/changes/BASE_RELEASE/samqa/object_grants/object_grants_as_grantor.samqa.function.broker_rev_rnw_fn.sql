-- liquibase formatted sql
-- changeset SAMQA:1754373935133 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.broker_rev_rnw_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.broker_rev_rnw_fn.sql:null:199ffbbc581cfea1c29903266d91e349b889cfff:create

grant execute on samqa.broker_rev_rnw_fn to rl_sam_ro;

