-- liquibase formatted sql
-- changeset SAMQA:1754373935597 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.strip_special_char.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.strip_special_char.sql:null:37cdafd4b5dee2be25ed6eb602441aa0dd695621:create

grant execute on samqa.strip_special_char to rl_sam_ro;

