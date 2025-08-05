-- liquibase formatted sql
-- changeset SAMQA:1754373937278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.acc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.acc_seq.sql:null:503a8c373cdc74636bea3f1aac3810cef5bdc529:create

grant select on samqa.acc_seq to rl_sam_rw;

grant select on samqa.acc_seq to cobra;

