-- liquibase formatted sql
-- changeset SAMQA:1754373935104 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.add_working_days.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.add_working_days.sql:null:86db08b6734df215548223c4bfdaf7d446b5038f:create

grant execute on samqa.add_working_days to rl_sam_ro;

