-- liquibase formatted sql
-- changeset SAMQA:1754373937725 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eob_eligible_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eob_eligible_staging_seq.sql:null:29038e74e036eb50ae2e28cdc31a22990f0eecba:create

grant select on samqa.eob_eligible_staging_seq to rl_sam_rw;

