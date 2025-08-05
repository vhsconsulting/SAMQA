-- liquibase formatted sql
-- changeset SAMQA:1754373937422 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.calender_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.calender_seq.sql:null:72433f2b9e0f92eb09eaa8f2dc037d619c838538:create

grant select on samqa.calender_seq to rl_sam_rw;

