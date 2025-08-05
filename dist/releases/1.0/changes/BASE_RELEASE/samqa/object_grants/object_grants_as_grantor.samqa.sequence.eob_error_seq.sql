-- liquibase formatted sql
-- changeset SAMQA:1754373937730 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eob_error_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eob_error_seq.sql:null:e42b78a44ee40bd5603c84ef4c047b00d8270ad0:create

grant select on samqa.eob_error_seq to rl_sam_rw;

