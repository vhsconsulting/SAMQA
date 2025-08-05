-- liquibase formatted sql
-- changeset SAMQA:1754373942114 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.security_images_test.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.security_images_test.sql:null:9bb30a3d97b90b6fb556012f801ce0d467f3a1fc:create

grant delete on samqa.security_images_test to rl_sam_rw;

grant insert on samqa.security_images_test to rl_sam_rw;

grant select on samqa.security_images_test to rl_sam1_ro;

grant select on samqa.security_images_test to rl_sam_rw;

grant select on samqa.security_images_test to rl_sam_ro;

grant update on samqa.security_images_test to rl_sam_rw;

