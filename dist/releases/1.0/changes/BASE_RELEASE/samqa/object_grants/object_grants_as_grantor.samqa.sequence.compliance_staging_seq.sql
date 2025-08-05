-- liquibase formatted sql
-- changeset SAMQA:1754373937531 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.compliance_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.compliance_staging_seq.sql:null:4c3f3ae8a6b989d8f5c70128953da3dd37c7632c:create

grant select on samqa.compliance_staging_seq to rl_sam_rw;

