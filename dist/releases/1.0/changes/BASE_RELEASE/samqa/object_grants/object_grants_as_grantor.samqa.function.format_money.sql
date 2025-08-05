-- liquibase formatted sql
-- changeset SAMQA:1754373935222 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.format_money.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.format_money.sql:null:ffeab7cd80eea3f864649f7784734db1f749efc2:create

grant execute on samqa.format_money to rl_sam_ro;

