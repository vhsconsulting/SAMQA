-- liquibase formatted sql
-- changeset SAMQA:1754373935393 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_role_id.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_role_id.sql:null:434da6f9ff9695208b42a421b041add5f7c9c46d:create

grant execute on samqa.get_role_id to rl_sam_ro;

