-- liquibase formatted sql
-- changeset SAMQA:1754373935170 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.check_user_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.check_user_name.sql:null:a1afd4e21e01286c35bb3153f9f0b8a1c1f6f663:create

grant execute on samqa.check_user_name to rl_sam_ro;

