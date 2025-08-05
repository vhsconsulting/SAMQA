-- liquibase formatted sql
-- changeset SAMQA:1754373936989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.process_bps_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.process_bps_claims.sql:null:18b9762c9040d5f4c774036f681d2b524f795cc8:create

grant execute on samqa.process_bps_claims to rl_sam_ro;

