-- liquibase formatted sql
-- changeset SAMQA:1754373937440 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.change_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.change_seq.sql:null:d627248c6d87421f5bd0348488fd98a83dab53a8:create

grant select on samqa.change_seq to rl_sam_rw;

