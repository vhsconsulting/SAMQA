-- liquibase formatted sql
-- changeset SAMQA:1754373938062 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.notification_schedule_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.notification_schedule_seq.sql:null:76b88858e68a6fcc07ad091d5e96e3e1f0a095c4:create

grant select on samqa.notification_schedule_seq to rl_sam_rw;

