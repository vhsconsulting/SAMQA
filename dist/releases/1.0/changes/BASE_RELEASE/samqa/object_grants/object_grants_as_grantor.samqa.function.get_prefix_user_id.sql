-- liquibase formatted sql
-- changeset SAMQA:1754373935352 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_prefix_user_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_prefix_user_id.sql:null:2099be8a380b7071656732688dd53afe09f37cad:create

grant execute on samqa.get_prefix_user_id to rl_sam_ro;

