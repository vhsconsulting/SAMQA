-- liquibase formatted sql
-- changeset SAMQA:1754373937897 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.letter_templates_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.letter_templates_seq.sql:null:d7d6be84c8927148c47d5420d9f8fb984471a9c1:create

grant select on samqa.letter_templates_seq to rl_sam_rw;

