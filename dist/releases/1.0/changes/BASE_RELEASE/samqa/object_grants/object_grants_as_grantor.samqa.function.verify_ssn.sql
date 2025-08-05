-- liquibase formatted sql
-- changeset SAMQA:1754373935627 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.verify_ssn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.verify_ssn.sql:null:c6e66c19bd071a2e134521dc1ebef89b3f9fc998:create

grant execute on samqa.verify_ssn to rl_sam_ro;

