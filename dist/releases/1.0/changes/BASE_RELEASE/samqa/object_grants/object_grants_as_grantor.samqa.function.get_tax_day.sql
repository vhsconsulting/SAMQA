-- liquibase formatted sql
-- changeset SAMQA:1754373935422 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_tax_day.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_tax_day.sql:null:14ee99fa19e91e817f7c14a05235ef7967cde7c4:create

grant execute on samqa.get_tax_day to rl_sam_rw;

grant execute on samqa.get_tax_day to rl_sam_ro;

grant execute on samqa.get_tax_day to rl_sam1_ro;

grant debug on samqa.get_tax_day to sgali;

grant debug on samqa.get_tax_day to rl_sam_rw;

grant debug on samqa.get_tax_day to rl_sam1_ro;

