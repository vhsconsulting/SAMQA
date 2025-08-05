-- liquibase formatted sql
-- changeset SAMQA:1754373935512 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.notes_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.notes_list.sql:null:73b355db10404ac0b918013d4b513877f7e30056:create

grant execute on samqa.notes_list to rl_sam_ro;

