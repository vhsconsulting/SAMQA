-- liquibase formatted sql
-- changeset SAMQA:1754373937954 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.mass_enroll_history_seq_no.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.mass_enroll_history_seq_no.sql:null:9142ac78031bf02e0fb039992208b7f0afdb7f1b:create

grant select on samqa.mass_enroll_history_seq_no to rl_sam_rw;

