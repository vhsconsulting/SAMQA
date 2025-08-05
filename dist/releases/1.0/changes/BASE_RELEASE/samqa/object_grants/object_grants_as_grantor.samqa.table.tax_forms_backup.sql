-- liquibase formatted sql
-- changeset SAMQA:1754373942273 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.tax_forms_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.tax_forms_backup.sql:null:ecd6a7de624dc665c9d8f7708783bc2552f20358:create

grant delete on samqa.tax_forms_backup to rl_sam_rw;

grant insert on samqa.tax_forms_backup to rl_sam_rw;

grant select on samqa.tax_forms_backup to rl_sam_rw;

grant select on samqa.tax_forms_backup to rl_sam_ro;

grant select on samqa.tax_forms_backup to rl_sam1_ro;

grant update on samqa.tax_forms_backup to rl_sam_rw;

