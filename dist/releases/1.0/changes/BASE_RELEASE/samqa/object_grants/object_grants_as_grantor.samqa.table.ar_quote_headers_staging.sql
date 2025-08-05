-- liquibase formatted sql
-- changeset SAMQA:1754373938746 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_quote_headers_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_quote_headers_staging.sql:null:6077551eb51614f7fcde07009269445cd2551224:create

grant delete on samqa.ar_quote_headers_staging to rl_sam_rw;

grant insert on samqa.ar_quote_headers_staging to rl_sam_rw;

grant select on samqa.ar_quote_headers_staging to rl_sam_rw;

grant select on samqa.ar_quote_headers_staging to rl_sam1_ro;

grant select on samqa.ar_quote_headers_staging to rl_sam_ro;

grant update on samqa.ar_quote_headers_staging to rl_sam_rw;

