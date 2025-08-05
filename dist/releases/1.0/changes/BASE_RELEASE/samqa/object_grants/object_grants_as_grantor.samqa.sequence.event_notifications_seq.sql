-- liquibase formatted sql
-- changeset SAMQA:1754373937753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.event_notifications_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.event_notifications_seq.sql:null:5368212a6b13bd1acb503277712b62add6685729:create

grant select on samqa.event_notifications_seq to rl_sam_rw;

