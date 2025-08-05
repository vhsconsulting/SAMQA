-- liquibase formatted sql
-- changeset SAMQA:1754373935592 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.strip_coverage_tier_char.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.strip_coverage_tier_char.sql:null:d05781613b04773106f11becb440869776b7a2e7:create

grant execute on samqa.strip_coverage_tier_char to rl_sam_ro;

