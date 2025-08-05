-- liquibase formatted sql
-- changeset SAMQA:1754373935756 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.ftp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.ftp.sql:null:88c2423c9f9d5904944d5948b526280bdcd29525:create

grant execute on samqa.ftp to rl_sam_ro;

grant execute on samqa.ftp to rl_sam_rw;

grant execute on samqa.ftp to rl_sam1_ro;

grant debug on samqa.ftp to rl_sam_ro;

grant debug on samqa.ftp to sgali;

grant debug on samqa.ftp to rl_sam_rw;

grant debug on samqa.ftp to rl_sam1_ro;

