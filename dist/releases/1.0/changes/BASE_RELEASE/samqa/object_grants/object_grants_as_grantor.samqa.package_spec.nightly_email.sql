-- liquibase formatted sql
-- changeset SAMQA:1754373935780 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.nightly_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.nightly_email.sql:null:30b805717408f2034cc7b6a78aa88d5d6cbe3fa0:create

grant execute on samqa.nightly_email to rl_sam_ro;

grant execute on samqa.nightly_email to rl_sam_rw;

grant execute on samqa.nightly_email to rl_sam1_ro;

grant debug on samqa.nightly_email to rl_sam_ro;

grant debug on samqa.nightly_email to sgali;

grant debug on samqa.nightly_email to rl_sam_rw;

grant debug on samqa.nightly_email to rl_sam1_ro;

