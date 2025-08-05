-- liquibase formatted sql
-- changeset SAMQA:1754373935476 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.is_alphanumeric.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.is_alphanumeric.sql:null:81c6d21a5a37a0095f5d95fcb285d88a8b4d5030:create

grant execute on samqa.is_alphanumeric to rl_sam_ro;

