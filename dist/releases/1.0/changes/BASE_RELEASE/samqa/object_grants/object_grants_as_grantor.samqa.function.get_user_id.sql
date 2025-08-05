-- liquibase formatted sql
-- changeset SAMQA:1754373935435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_user_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_user_id.sql:null:3faae1c5ee12698070711d3699148c07a02fe14c:create

grant execute on samqa.get_user_id to rl_sam_ro;

