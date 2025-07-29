-- liquibase formatted sql
-- changeset SAMQA:1753779558765 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_user_name_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_user_name_details.sql:null:e95685414131cb26529c5e7941ffac5e8fd096fb:create

grant execute on samqa.get_user_name_details to rl_sam_ro;

