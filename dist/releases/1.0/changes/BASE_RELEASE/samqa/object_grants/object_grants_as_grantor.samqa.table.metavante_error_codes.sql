-- liquibase formatted sql
-- changeset SAMQA:1754373941166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_error_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_error_codes.sql:null:be78151318c06b5f1b80c89e13e9e713a956edaa:create

grant delete on samqa.metavante_error_codes to rl_sam_rw;

grant insert on samqa.metavante_error_codes to rl_sam_rw;

grant select on samqa.metavante_error_codes to rl_sam1_ro;

grant select on samqa.metavante_error_codes to rl_sam_rw;

grant select on samqa.metavante_error_codes to rl_sam_ro;

grant update on samqa.metavante_error_codes to rl_sam_rw;

