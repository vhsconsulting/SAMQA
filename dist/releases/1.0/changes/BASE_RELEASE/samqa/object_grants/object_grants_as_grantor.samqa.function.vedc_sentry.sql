-- liquibase formatted sql
-- changeset SAMQA:1754373935613 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.vedc_sentry.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.vedc_sentry.sql:null:7546cdfe6600666e83437f152e85f7cd560d9a60:create

grant execute on samqa.vedc_sentry to rl_sam_ro;

