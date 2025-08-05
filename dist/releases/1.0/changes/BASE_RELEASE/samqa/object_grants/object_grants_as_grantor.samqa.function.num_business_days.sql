-- liquibase formatted sql
-- changeset SAMQA:1754373935518 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.num_business_days.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.num_business_days.sql:null:a9958d758f6273bafa65932f07353895f5e9903f:create

grant execute on samqa.num_business_days to rl_sam_ro;

