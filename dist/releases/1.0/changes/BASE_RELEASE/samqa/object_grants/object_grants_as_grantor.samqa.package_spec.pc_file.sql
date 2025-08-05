-- liquibase formatted sql
-- changeset SAMQA:1754373936170 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_file.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_file.sql:null:9b7f98ce74d42e0b636bafeb3d7cf941e1805329:create

grant execute on samqa.pc_file to rl_sam_ro;

grant execute on samqa.pc_file to rl_sam_rw;

grant execute on samqa.pc_file to rl_sam1_ro;

grant debug on samqa.pc_file to sgali;

grant debug on samqa.pc_file to rl_sam_rw;

grant debug on samqa.pc_file to rl_sam1_ro;

grant debug on samqa.pc_file to rl_sam_ro;

