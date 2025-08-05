-- liquibase formatted sql
-- changeset SAMQA:1754373942105 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.security_images_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.security_images_bkp.sql:null:710de1890397f3097e7aec675d1588151bc90a36:create

grant delete on samqa.security_images_bkp to rl_sam_rw;

grant insert on samqa.security_images_bkp to rl_sam_rw;

grant select on samqa.security_images_bkp to rl_sam1_ro;

grant select on samqa.security_images_bkp to rl_sam_rw;

grant select on samqa.security_images_bkp to rl_sam_ro;

grant update on samqa.security_images_bkp to rl_sam_rw;

