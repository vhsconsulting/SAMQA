-- liquibase formatted sql
-- changeset SAMQA:1754373936883 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.get_dir_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.get_dir_list.sql:null:1c9c5e269453bd05895911e0352f9ae102266c04:create

grant execute on samqa.get_dir_list to rl_sam_ro;

grant execute on samqa.get_dir_list to rl_sam_rw;

grant execute on samqa.get_dir_list to rl_sam1_ro;

grant debug on samqa.get_dir_list to sgali;

grant debug on samqa.get_dir_list to rl_sam_rw;

grant debug on samqa.get_dir_list to rl_sam1_ro;

