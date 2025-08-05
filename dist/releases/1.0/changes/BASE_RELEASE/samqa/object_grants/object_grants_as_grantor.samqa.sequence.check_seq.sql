-- liquibase formatted sql
-- changeset SAMQA:1754373937444 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.check_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.check_seq.sql:null:7bdc5d9fbd7b088256e3d96dad9f2aef5c84f10a:create

grant select on samqa.check_seq to rl_sam_rw;

