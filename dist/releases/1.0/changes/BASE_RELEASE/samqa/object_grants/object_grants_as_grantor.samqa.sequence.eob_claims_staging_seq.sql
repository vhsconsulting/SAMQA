-- liquibase formatted sql
-- changeset SAMQA:1754373937715 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eob_claims_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eob_claims_staging_seq.sql:null:67288621ce4eae6ad345e9817175264710def1ba:create

grant select on samqa.eob_claims_staging_seq to rl_sam_rw;

