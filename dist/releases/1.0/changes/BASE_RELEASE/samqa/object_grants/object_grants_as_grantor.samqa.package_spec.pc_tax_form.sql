-- liquibase formatted sql
-- changeset SAMQA:1754373936495 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_tax_form.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_tax_form.sql:null:21e96d63d4579846fe2eb32f7ff71f568056a35a:create

grant execute on samqa.pc_tax_form to rl_sam_ro;

grant execute on samqa.pc_tax_form to rl_sam_rw;

grant execute on samqa.pc_tax_form to rl_sam1_ro;

grant debug on samqa.pc_tax_form to sgali;

grant debug on samqa.pc_tax_form to rl_sam_rw;

grant debug on samqa.pc_tax_form to rl_sam_ro;

grant debug on samqa.pc_tax_form to rl_sam1_ro;

