-- liquibase formatted sql
-- changeset SAMQA:1754373937932 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.log_batch_sequence.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.log_batch_sequence.sql:null:e6fdb6ec68f58b9c745bd3b5a09dbc509ea491dd:create

grant select on samqa.log_batch_sequence to rl_sam_rw;

