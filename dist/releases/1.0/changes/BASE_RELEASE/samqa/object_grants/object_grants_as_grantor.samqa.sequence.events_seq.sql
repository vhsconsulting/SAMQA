-- liquibase formatted sql
-- changeset SAMQA:1754373937769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.events_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.events_seq.sql:null:0583f3d7370608e624e1344fef7a39b8e1f3247f:create

grant select on samqa.events_seq to rl_sam_rw;

