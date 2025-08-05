-- liquibase formatted sql
-- changeset SAMQA:1754373938763 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_quote_lines_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_quote_lines_staging.sql:null:4eff0905f577e93fd8025abba78ac9ad02439dfa:create

grant delete on samqa.ar_quote_lines_staging to rl_sam_rw;

grant insert on samqa.ar_quote_lines_staging to rl_sam_rw;

grant select on samqa.ar_quote_lines_staging to rl_sam1_ro;

grant select on samqa.ar_quote_lines_staging to rl_sam_ro;

grant select on samqa.ar_quote_lines_staging to rl_sam_rw;

grant update on samqa.ar_quote_lines_staging to rl_sam_rw;

