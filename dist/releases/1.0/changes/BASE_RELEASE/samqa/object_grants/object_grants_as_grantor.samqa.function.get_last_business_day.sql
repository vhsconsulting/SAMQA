-- liquibase formatted sql
-- changeset SAMQA:1754373935316 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_last_business_day.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_last_business_day.sql:null:dde0c5a5b1ebcea843a28c15340d1d479629e0f9:create

grant execute on samqa.get_last_business_day to rl_sam_rw;

grant execute on samqa.get_last_business_day to rl_sam1_ro;

grant execute on samqa.get_last_business_day to rl_sam_ro;

grant debug on samqa.get_last_business_day to rl_sam_rw;

grant debug on samqa.get_last_business_day to rl_sam1_ro;

