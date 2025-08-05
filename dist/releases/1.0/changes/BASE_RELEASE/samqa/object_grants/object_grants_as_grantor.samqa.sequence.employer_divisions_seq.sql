-- liquibase formatted sql
-- changeset SAMQA:1754373937675 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.employer_divisions_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.employer_divisions_seq.sql:null:b7ae2448502dff8d37cf70a15cd72f11547e29cd:create

grant select on samqa.employer_divisions_seq to rl_sam_rw;

