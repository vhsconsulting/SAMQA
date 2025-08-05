-- liquibase formatted sql
-- changeset SAMQA:1754373937401 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.broker_assignment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.broker_assignment_seq.sql:null:6582d29c570c9d018a6ef0ad2e0400ebd54b50d2:create

grant select on samqa.broker_assignment_seq to rl_sam_rw;

