-- liquibase formatted sql
-- changeset SAMQA:1754373942263 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.tax_forms.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.tax_forms.sql:null:fb7cca9e0c57d7247316770a3b3c82af8f220fe1:create

grant delete on samqa.tax_forms to rl_sam_rw;

grant insert on samqa.tax_forms to rl_sam_rw;

grant select on samqa.tax_forms to rl_sam1_ro;

grant select on samqa.tax_forms to rl_sam_rw;

grant select on samqa.tax_forms to rl_sam_ro;

grant update on samqa.tax_forms to rl_sam_rw;

