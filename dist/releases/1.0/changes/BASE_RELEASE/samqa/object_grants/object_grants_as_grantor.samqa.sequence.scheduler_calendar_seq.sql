-- liquibase formatted sql
-- changeset SAMQA:1754373938246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.scheduler_calendar_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.scheduler_calendar_seq.sql:null:809f4c2a58a45a3b16350959d5456684f0ca9abb:create

grant select on samqa.scheduler_calendar_seq to rl_sam_rw;

