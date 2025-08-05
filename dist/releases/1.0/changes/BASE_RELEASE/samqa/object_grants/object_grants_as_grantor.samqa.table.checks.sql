-- liquibase formatted sql
-- changeset SAMQA:1754373939243 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.checks.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.checks.sql:null:8800e6704ef8f3c547d22528f01e95dac0a15a14:create

grant delete on samqa.checks to rl_sam_rw;

grant insert on samqa.checks to rl_sam_rw;

grant select on samqa.checks to rl_sam1_ro;

grant select on samqa.checks to newcobra;

grant select on samqa.checks to rl_sam_rw;

grant select on samqa.checks to rl_sam_ro;

grant update on samqa.checks to rl_sam_rw;

