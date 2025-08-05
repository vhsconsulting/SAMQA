-- liquibase formatted sql
-- changeset SAMQA:1754373935204 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.file_exists.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.file_exists.sql:null:55cb6dffe3e0d62ace2acd9c7429b21e663c7c98:create

grant execute on samqa.file_exists to rl_sam_ro;

