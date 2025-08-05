-- liquibase formatted sql
-- changeset SAMQA:1754373937652 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eb_update_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eb_update_seq.sql:null:a06c16b25abbe0b918533b94f12d201001b4bf59:create

grant select on samqa.eb_update_seq to rl_sam_rw;

