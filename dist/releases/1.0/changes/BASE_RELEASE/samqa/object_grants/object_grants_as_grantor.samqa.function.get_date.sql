-- liquibase formatted sql
-- changeset SAMQA:1754373935264 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_date.sql:null:b2467f22b4d08e301e31d568b58d184ff9556898:create

grant execute on samqa.get_date to rl_sam_ro;

