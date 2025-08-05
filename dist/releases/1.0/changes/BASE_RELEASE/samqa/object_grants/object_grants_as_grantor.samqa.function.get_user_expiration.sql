-- liquibase formatted sql
-- changeset SAMQA:1754373935429 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_user_expiration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_user_expiration.sql:null:bbff0c1c1cf3ea719ed340bbab01e65d5ee9a7e0:create

grant execute on samqa.get_user_expiration to rl_sam_ro;

