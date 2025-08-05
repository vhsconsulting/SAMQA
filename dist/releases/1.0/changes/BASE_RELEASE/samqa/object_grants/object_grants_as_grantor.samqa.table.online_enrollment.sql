-- liquibase formatted sql
-- changeset SAMQA:1754373941410 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_enrollment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_enrollment.sql:null:bf5b1d2fa332d544797d6a29ee6a5f2ccd120efd:create

grant delete on samqa.online_enrollment to rl_sam_rw;

grant insert on samqa.online_enrollment to rl_sam_rw;

grant select on samqa.online_enrollment to rl_sam1_ro;

grant select on samqa.online_enrollment to rl_sam_rw;

grant select on samqa.online_enrollment to rl_sam_ro;

grant update on samqa.online_enrollment to rl_sam_rw;

