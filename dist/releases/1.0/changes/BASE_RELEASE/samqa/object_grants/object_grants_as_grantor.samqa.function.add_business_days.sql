-- liquibase formatted sql
-- changeset SAMQA:1754373935093 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.add_business_days.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.add_business_days.sql:null:ab5df47a968d0d5486177ebdec6e6d576d073325:create

grant execute on samqa.add_business_days to rl_sam_ro;

