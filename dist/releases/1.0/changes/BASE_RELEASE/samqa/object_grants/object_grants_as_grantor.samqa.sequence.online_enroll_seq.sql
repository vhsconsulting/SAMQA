-- liquibase formatted sql
-- changeset SAMQA:1754373938078 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.online_enroll_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.online_enroll_seq.sql:null:ddeb335174e999e98fd95029c8fae285b4a4040b:create

grant select on samqa.online_enroll_seq to rl_sam_rw;

