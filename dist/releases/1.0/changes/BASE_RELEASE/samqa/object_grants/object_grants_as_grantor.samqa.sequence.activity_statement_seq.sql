-- liquibase formatted sql
-- changeset SAMQA:1754373937315 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.activity_statement_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.activity_statement_seq.sql:null:d210d701aa9898817dd2adc62de560736ad71277:create

grant select on samqa.activity_statement_seq to rl_sam_rw;

