-- liquibase formatted sql
-- changeset SAMQA:1754373938309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.transfer_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.transfer_seq.sql:null:6d36b2649933c28195db3cf2f66cc4bea0782ecf:create

grant select on samqa.transfer_seq to rl_sam_rw;

