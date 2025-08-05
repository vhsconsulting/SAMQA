-- liquibase formatted sql
-- changeset SAMQA:1754373938325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.user_role_entries_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.user_role_entries_seq.sql:null:f70f136d567728671e468736c4360be07820fa9c:create

grant select on samqa.user_role_entries_seq to rl_sam_rw;

