-- liquibase formatted sql
-- changeset SAMQA:1754373936978 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.new_transform_file.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.new_transform_file.sql:null:9203a28fba81dfb4ed90441b0f3ebd8b82d7f5b7:create

grant execute on samqa.new_transform_file to rl_sam_ro;

grant execute on samqa.new_transform_file to rl_sam_rw;

grant execute on samqa.new_transform_file to rl_sam1_ro;

grant debug on samqa.new_transform_file to sgali;

grant debug on samqa.new_transform_file to rl_sam_rw;

grant debug on samqa.new_transform_file to rl_sam1_ro;

