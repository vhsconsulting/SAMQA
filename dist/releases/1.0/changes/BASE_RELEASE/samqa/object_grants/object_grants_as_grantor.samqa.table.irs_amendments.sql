-- liquibase formatted sql
-- changeset SAMQA:1754373940928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.irs_amendments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.irs_amendments.sql:null:a4e93cb6047e2d742a7a746166ad8907ab915516:create

grant delete on samqa.irs_amendments to rl_sam_rw;

grant insert on samqa.irs_amendments to rl_sam_rw;

grant select on samqa.irs_amendments to rl_sam1_ro;

grant select on samqa.irs_amendments to rl_sam_rw;

grant select on samqa.irs_amendments to rl_sam_ro;

grant update on samqa.irs_amendments to rl_sam_rw;

