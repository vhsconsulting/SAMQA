-- liquibase formatted sql
-- changeset SAMQA:1754373936610 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.process_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.process_upload.sql:null:66574313bcf00ea26ce35353b2d4f470ac28ac74:create

grant execute on samqa.process_upload to rl_sam_ro;

grant execute on samqa.process_upload to rl_sam_rw;

grant execute on samqa.process_upload to rl_sam1_ro;

grant debug on samqa.process_upload to rl_sam_ro;

grant debug on samqa.process_upload to sgali;

grant debug on samqa.process_upload to rl_sam_rw;

grant debug on samqa.process_upload to rl_sam1_ro;

