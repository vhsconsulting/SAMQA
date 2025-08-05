-- liquibase formatted sql
-- changeset SAMQA:1754373937919 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.life_event_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.life_event_seq.sql:null:0be3a71db41845f0cbcbf8b4bd909e5a4108cd72:create

grant select on samqa.life_event_seq to rl_sam_rw;

