-- liquibase formatted sql
-- changeset SAMQA:1754373935772 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.mail_utility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.mail_utility.sql:null:90141385c358417056cb6e4c6aab7c341954d7db:create

grant execute on samqa.mail_utility to rl_sam_ro;

grant execute on samqa.mail_utility to rl_sam_rw;

grant execute on samqa.mail_utility to rl_sam1_ro;

grant debug on samqa.mail_utility to rl_sam_ro;

grant debug on samqa.mail_utility to sgali;

grant debug on samqa.mail_utility to rl_sam_rw;

grant debug on samqa.mail_utility to rl_sam1_ro;

