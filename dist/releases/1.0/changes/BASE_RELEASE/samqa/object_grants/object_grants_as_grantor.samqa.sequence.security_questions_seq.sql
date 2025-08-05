-- liquibase formatted sql
-- changeset SAMQA:1754373938277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.security_questions_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.security_questions_seq.sql:null:d5fe09e1882c4466ad495c16af460750b4cb9bf8:create

grant select on samqa.security_questions_seq to rl_sam_rw;

