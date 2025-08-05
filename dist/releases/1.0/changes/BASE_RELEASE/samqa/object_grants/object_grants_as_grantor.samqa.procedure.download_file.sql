-- liquibase formatted sql
-- changeset SAMQA:1754373936849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.download_file.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.download_file.sql:null:3e48e6a866d689c869553c96bad9e5bbccc75988:create

grant execute on samqa.download_file to rl_sam_ro;

grant execute on samqa.download_file to rl_sam_rw;

grant execute on samqa.download_file to rl_sam1_ro;

grant debug on samqa.download_file to sgali;

grant debug on samqa.download_file to rl_sam_rw;

grant debug on samqa.download_file to rl_sam1_ro;

