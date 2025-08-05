-- liquibase formatted sql
-- changeset SAMQA:1754373943927 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.file_upload_history_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.file_upload_history_v.sql:null:15aff24d5cac3e7335ce136ed3793ba2d2dd4ce2:create

grant select on samqa.file_upload_history_v to rl_sam1_ro;

grant select on samqa.file_upload_history_v to rl_sam_rw;

grant select on samqa.file_upload_history_v to rl_sam_ro;

grant select on samqa.file_upload_history_v to sgali;

