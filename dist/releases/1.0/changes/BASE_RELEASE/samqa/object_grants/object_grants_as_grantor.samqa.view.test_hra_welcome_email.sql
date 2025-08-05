-- liquibase formatted sql
-- changeset SAMQA:1754373945342 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.test_hra_welcome_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.test_hra_welcome_email.sql:null:841f2c98c67069bdf432b09bd156489d63d9e4d9:create

grant select on samqa.test_hra_welcome_email to rl_sam_rw;

grant select on samqa.test_hra_welcome_email to rl_sam_ro;

grant select on samqa.test_hra_welcome_email to sgali;

grant select on samqa.test_hra_welcome_email to rl_sam1_ro;

