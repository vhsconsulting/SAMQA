-- liquibase formatted sql
-- changeset SAMQA:1754373935506 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.isalphanumeric.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.isalphanumeric.sql:null:7f6e111eb65f4659c4e3762909b4a2de53be755f:create

grant execute on samqa.isalphanumeric to rl_sam_ro;

