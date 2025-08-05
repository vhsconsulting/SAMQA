-- liquibase formatted sql
-- changeset SAMQA:1754373938040 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.notes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.notes_seq.sql:null:2558c1cb59073d467d9e7021a6af20318c4501e5:create

grant select on samqa.notes_seq to rl_sam_rw;

