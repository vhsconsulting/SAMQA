-- liquibase formatted sql
-- changeset SAMQA:1754373943919 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.file_upload_depend_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.file_upload_depend_v.sql:null:354adc9516b64deb12dbd3e7bf953b7556d16253:create

grant select on samqa.file_upload_depend_v to rl_sam1_ro;

grant select on samqa.file_upload_depend_v to rl_sam_ro;

grant select on samqa.file_upload_depend_v to rl_sam_rw;

