-- liquibase formatted sql
-- changeset SAMQA:1754373940257 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_errors.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_errors.sql:null:3b9844346a97b131aa8f94ced0679a9709fab3d2:create

grant delete on samqa.eob_errors to rl_sam_rw;

grant insert on samqa.eob_errors to rl_sam_rw;

grant select on samqa.eob_errors to rl_sam1_ro;

grant select on samqa.eob_errors to rl_sam_rw;

grant select on samqa.eob_errors to rl_sam_ro;

grant update on samqa.eob_errors to rl_sam_rw;

