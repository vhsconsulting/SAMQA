-- liquibase formatted sql
-- changeset SAMQA:1754373935471 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.in_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.in_list.sql:null:1eac64826875436427ec709dc30e708801e6699e:create

grant execute on samqa.in_list to rl_sam_ro;

