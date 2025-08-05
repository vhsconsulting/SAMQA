-- liquibase formatted sql
-- changeset SAMQA:1754373936713 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.cleanup_annual_election.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.cleanup_annual_election.sql:null:f57ec48e62faf883e95d2239e49919e0a700c9fb:create

grant execute on samqa.cleanup_annual_election to rl_sam_ro;

