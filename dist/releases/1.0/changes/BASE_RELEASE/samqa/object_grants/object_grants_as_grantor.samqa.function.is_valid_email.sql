-- liquibase formatted sql
-- changeset SAMQA:1754373935499 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.is_valid_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.is_valid_email.sql:null:b379025ac69b3d20ec5da0a66f2fe8e1db4674df:create

grant execute on samqa.is_valid_email to rl_sam_ro;

