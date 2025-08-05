-- liquibase formatted sql
-- changeset SAMQA:1754373935739 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.export_excel_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.export_excel_pkg.sql:null:4b58f3d17aee77963a402124842e0c88ea8cb1c2:create

grant execute on samqa.export_excel_pkg to rl_sam_ro;

grant execute on samqa.export_excel_pkg to rl_sam_rw;

grant execute on samqa.export_excel_pkg to rl_sam1_ro;

grant debug on samqa.export_excel_pkg to rl_sam_ro;

grant debug on samqa.export_excel_pkg to sgali;

grant debug on samqa.export_excel_pkg to rl_sam_rw;

grant debug on samqa.export_excel_pkg to rl_sam1_ro;

