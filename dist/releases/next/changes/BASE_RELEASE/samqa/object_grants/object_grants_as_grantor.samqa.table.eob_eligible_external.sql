-- liquibase formatted sql
-- changeset SAMQA:1753779563199 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_eligible_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_eligible_external.sql:null:68a68373d181933c10e3cd76f4aa3590cdfcf836:create

grant select on samqa.eob_eligible_external to rl_sam1_ro;

grant select on samqa.eob_eligible_external to rl_sam_ro;

