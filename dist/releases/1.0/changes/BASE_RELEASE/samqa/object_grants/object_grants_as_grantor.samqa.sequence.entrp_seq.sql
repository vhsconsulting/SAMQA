-- liquibase formatted sql
-- changeset SAMQA:1754373937704 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.entrp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.entrp_seq.sql:null:cf9a93dbccf6aba6cf6682dd1fabe4b7fd37c0a6:create

grant select on samqa.entrp_seq to rl_sam_rw;

grant select on samqa.entrp_seq to cobra;

