-- liquibase formatted sql
-- changeset SAMQA:1754373942094 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.security_images.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.security_images.sql:null:d1128cbcd0e9d07ee4f583febf528e6def447e42:create

grant delete on samqa.security_images to rl_sam_rw;

grant insert on samqa.security_images to rl_sam_rw;

grant select on samqa.security_images to rl_sam1_ro;

grant select on samqa.security_images to rl_sam_rw;

grant select on samqa.security_images to rl_sam_ro;

grant update on samqa.security_images to rl_sam_rw;

