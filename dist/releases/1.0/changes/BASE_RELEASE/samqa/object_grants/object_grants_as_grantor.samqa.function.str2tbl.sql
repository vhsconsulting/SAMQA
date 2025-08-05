-- liquibase formatted sql
-- changeset SAMQA:1754373935581 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.str2tbl.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.str2tbl.sql:null:70ba009a7ee6f45cf4bf3ca4e426b831a92c3b65:create

grant execute on samqa.str2tbl to rl_sam_ro;

