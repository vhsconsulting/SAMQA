-- liquibase formatted sql
-- changeset SAMQA:1754373937710 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.entrp_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.entrp_staging_seq.sql:null:a73ff79ecf61c3396cf389e8b2a4e212394d092e:create

grant select on samqa.entrp_staging_seq to rl_sam_rw;

