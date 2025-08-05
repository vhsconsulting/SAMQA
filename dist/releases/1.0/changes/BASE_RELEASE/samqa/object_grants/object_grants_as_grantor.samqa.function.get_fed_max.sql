-- liquibase formatted sql
-- changeset SAMQA:1754373935300 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_fed_max.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_fed_max.sql:null:843ba81dd1edc231b1b31eae04182acf3261bd44:create

grant execute on samqa.get_fed_max to rl_sam_ro;

