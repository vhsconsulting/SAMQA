-- liquibase formatted sql
-- changeset SAMQA:1754373935445 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_user_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_user_name.sql:null:e49730960f38c592f0f1582d4a6aef777a264839:create

grant execute on samqa.get_user_name to rl_sam_ro;

grant execute on samqa.get_user_name to rl_sam_rw;

grant execute on samqa.get_user_name to rl_sam1_ro;

grant debug on samqa.get_user_name to sgali;

grant debug on samqa.get_user_name to rl_sam_rw;

grant debug on samqa.get_user_name to rl_sam1_ro;

