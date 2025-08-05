-- liquibase formatted sql
-- changeset SAMQA:1754373937817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.fsa_online_enroll_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.fsa_online_enroll_seq.sql:null:0ecdad4706b69522bf07d266aea5beaa9fbccab6:create

grant select on samqa.fsa_online_enroll_seq to rl_sam_rw;

