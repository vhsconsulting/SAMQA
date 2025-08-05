-- liquibase formatted sql
-- changeset SAMQA:1754373938756 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_quote_lines.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_quote_lines.sql:null:8de3143c6c9fc5ceede4716203a40b77aa3760ac:create

grant delete on samqa.ar_quote_lines to rl_sam_rw;

grant insert on samqa.ar_quote_lines to rl_sam_rw;

grant insert on samqa.ar_quote_lines to cobra;

grant select on samqa.ar_quote_lines to rl_sam1_ro;

grant select on samqa.ar_quote_lines to rl_sam_rw;

grant select on samqa.ar_quote_lines to rl_sam_ro;

grant select on samqa.ar_quote_lines to cobra;

grant select on samqa.ar_quote_lines to asis;

grant update on samqa.ar_quote_lines to rl_sam_rw;

grant update on samqa.ar_quote_lines to cobra;

