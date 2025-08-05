-- liquibase formatted sql
-- changeset SAMQA:1754373935563 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.sam_password_hash.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.sam_password_hash.sql:null:59f36ca67c7989c8a0d4c125ef85e50de59dc040:create

grant execute on samqa.sam_password_hash to rl_sam_ro;

