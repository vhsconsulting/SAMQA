-- liquibase formatted sql
-- changeset SAMQA:1754373935703 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.as_sftp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.as_sftp.sql:null:1fe09840fc75a2081a39086812f371dbc94e25ca:create

grant execute on samqa.as_sftp to rl_sam_rw;

grant execute on samqa.as_sftp to rl_sam1_ro;

grant execute on samqa.as_sftp to rl_sam_ro;

grant debug on samqa.as_sftp to rl_sam_ro;

grant debug on samqa.as_sftp to rl_sam_rw;

grant debug on samqa.as_sftp to rl_sam1_ro;

