-- liquibase formatted sql
-- changeset SAMQA:1754373940976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.list_bill_upload_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.list_bill_upload_staging.sql:null:a97d41ced008c54f94a3791c06e480218fa3723a:create

grant delete on samqa.list_bill_upload_staging to rl_sam_rw;

grant insert on samqa.list_bill_upload_staging to rl_sam_rw;

grant select on samqa.list_bill_upload_staging to rl_sam1_ro;

grant select on samqa.list_bill_upload_staging to rl_sam_rw;

grant select on samqa.list_bill_upload_staging to rl_sam_ro;

grant update on samqa.list_bill_upload_staging to rl_sam_rw;

