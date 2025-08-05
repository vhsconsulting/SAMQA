-- liquibase formatted sql
-- changeset SAMQA:1754373935411 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_salesrep_user_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_salesrep_user_name.sql:null:450ae9afcb58bffeb361e194ef6afcebef95a31b:create

grant execute on samqa.get_salesrep_user_name to rl_sam_ro;

