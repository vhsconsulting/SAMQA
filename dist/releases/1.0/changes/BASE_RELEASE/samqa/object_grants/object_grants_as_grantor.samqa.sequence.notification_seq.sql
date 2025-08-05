-- liquibase formatted sql
-- changeset SAMQA:1754373938068 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.notification_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.notification_seq.sql:null:a859f835f16bb833068347caa689c404bdedd23e:create

grant select on samqa.notification_seq to rl_sam_rw;

