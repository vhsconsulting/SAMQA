-- liquibase formatted sql
-- changeset SAMQA:1754373936644 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.unloader.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.unloader.sql:null:54a87821c9a7fcfbe55f04739af1c8383e693912:create

grant execute on samqa.unloader to rl_sam_ro;

grant execute on samqa.unloader to rl_sam_rw;

grant execute on samqa.unloader to rl_sam1_ro;

grant debug on samqa.unloader to sgali;

grant debug on samqa.unloader to rl_sam_rw;

grant debug on samqa.unloader to rl_sam1_ro;

grant debug on samqa.unloader to rl_sam_ro;

