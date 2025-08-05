-- liquibase formatted sql
-- changeset SAMQA:1754373941182 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_errors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_errors.sql:null:679f621d903f10922afd81e4fcdb912f7e7d2d94:create

grant delete on samqa.metavante_errors to rl_sam_rw;

grant insert on samqa.metavante_errors to rl_sam_rw;

grant select on samqa.metavante_errors to rl_sam1_ro;

grant select on samqa.metavante_errors to rl_sam_rw;

grant select on samqa.metavante_errors to rl_sam_ro;

grant update on samqa.metavante_errors to rl_sam_rw;

