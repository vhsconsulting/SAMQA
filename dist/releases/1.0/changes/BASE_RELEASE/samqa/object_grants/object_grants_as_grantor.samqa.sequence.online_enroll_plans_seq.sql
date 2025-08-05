-- liquibase formatted sql
-- changeset SAMQA:1754373938074 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.online_enroll_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.online_enroll_plans_seq.sql:null:099a0d5041ca28a090b124d3053b26ede43c4140:create

grant select on samqa.online_enroll_plans_seq to rl_sam_rw;

