-- liquibase formatted sql
-- changeset SAMQA:1754373940214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_claims_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_claims_external.sql:null:ddf90d959b6f81a66afa33a8eb76e62586b8ed7d:create

grant select on samqa.eob_claims_external to rl_sam1_ro;

grant select on samqa.eob_claims_external to rl_sam_ro;

