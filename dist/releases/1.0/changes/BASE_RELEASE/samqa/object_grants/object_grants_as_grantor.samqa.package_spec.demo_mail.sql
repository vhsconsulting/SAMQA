-- liquibase formatted sql
-- changeset SAMQA:1754373935725 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.demo_mail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.demo_mail.sql:null:43b977d90a2886dd423202912586f44f35c4401f:create

grant execute on samqa.demo_mail to rl_sam_ro;

grant execute on samqa.demo_mail to rl_sam_rw;

grant execute on samqa.demo_mail to rl_sam1_ro;

grant debug on samqa.demo_mail to rl_sam_ro;

grant debug on samqa.demo_mail to sgali;

grant debug on samqa.demo_mail to rl_sam_rw;

grant debug on samqa.demo_mail to rl_sam1_ro;

