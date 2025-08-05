-- liquibase formatted sql
-- changeset SAMQA:1754373940365 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.erisa_file_upload_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.erisa_file_upload_staging.sql:null:ac303bba3e890893e0e7edfef0080900a9336529:create

grant delete on samqa.erisa_file_upload_staging to rl_sam_rw;

grant insert on samqa.erisa_file_upload_staging to rl_sam_rw;

grant select on samqa.erisa_file_upload_staging to rl_sam1_ro;

grant select on samqa.erisa_file_upload_staging to rl_sam_rw;

grant select on samqa.erisa_file_upload_staging to rl_sam_ro;

grant update on samqa.erisa_file_upload_staging to rl_sam_rw;

