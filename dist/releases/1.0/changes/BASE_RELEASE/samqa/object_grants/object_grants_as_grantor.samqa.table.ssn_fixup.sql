-- liquibase formatted sql
-- changeset SAMQA:1754373942213 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ssn_fixup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ssn_fixup.sql:null:810b350dddd45f2f3fa2e14febaa1616f37c1767:create

grant delete on samqa.ssn_fixup to rl_sam_rw;

grant insert on samqa.ssn_fixup to rl_sam_rw;

grant select on samqa.ssn_fixup to rl_sam1_ro;

grant select on samqa.ssn_fixup to rl_sam_rw;

grant select on samqa.ssn_fixup to rl_sam_ro;

grant update on samqa.ssn_fixup to rl_sam_rw;

