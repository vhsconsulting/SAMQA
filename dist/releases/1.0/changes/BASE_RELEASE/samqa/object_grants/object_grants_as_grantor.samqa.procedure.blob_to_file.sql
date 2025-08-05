-- liquibase formatted sql
-- changeset SAMQA:1754373936682 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.blob_to_file.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.blob_to_file.sql:null:af87fd13894ad46bb073869979625527f04f701e:create

grant execute on samqa.blob_to_file to rl_sam_ro;

grant execute on samqa.blob_to_file to rl_sam_rw;

grant execute on samqa.blob_to_file to rl_sam1_ro;

grant debug on samqa.blob_to_file to sgali;

grant debug on samqa.blob_to_file to rl_sam_rw;

grant debug on samqa.blob_to_file to rl_sam1_ro;

