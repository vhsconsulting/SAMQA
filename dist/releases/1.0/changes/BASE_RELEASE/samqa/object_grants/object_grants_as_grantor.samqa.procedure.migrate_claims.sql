-- liquibase formatted sql
-- changeset SAMQA:1754373936942 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.migrate_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.migrate_claims.sql:null:e79c675e841cc94cbe5214793c961697cc59dacc:create

grant execute on samqa.migrate_claims to rl_sam_ro;

