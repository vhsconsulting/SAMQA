-- liquibase formatted sql
-- changeset SAMQA:1754373935576 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.spell_number.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.spell_number.sql:null:8171b08f61ae949ffece8428936f6c27d607aa29:create

grant execute on samqa.spell_number to rl_sam_ro;

grant execute on samqa.spell_number to rl_sam_rw;

grant execute on samqa.spell_number to rl_sam1_ro;

grant debug on samqa.spell_number to sgali;

grant debug on samqa.spell_number to rl_sam_rw;

grant debug on samqa.spell_number to rl_sam1_ro;

