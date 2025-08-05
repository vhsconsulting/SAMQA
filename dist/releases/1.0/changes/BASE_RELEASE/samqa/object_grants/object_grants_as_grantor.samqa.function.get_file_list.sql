-- liquibase formatted sql
-- changeset SAMQA:1754373935309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_file_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_file_list.sql:null:1d9ac1a2ac72eef82e00f46eb73b3b044d5a8362:create

grant execute on samqa.get_file_list to rl_sam_rw;

grant execute on samqa.get_file_list to rl_sam1_ro;

grant execute on samqa.get_file_list to rl_sam_ro;

grant debug on samqa.get_file_list to rl_sam_rw;

grant debug on samqa.get_file_list to rl_sam1_ro;

