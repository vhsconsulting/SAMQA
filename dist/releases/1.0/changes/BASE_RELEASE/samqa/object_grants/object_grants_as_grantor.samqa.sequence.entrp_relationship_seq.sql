-- liquibase formatted sql
-- changeset SAMQA:1754373937698 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.entrp_relationship_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.entrp_relationship_seq.sql:null:dcdb2383e06ac31c7ccc9505d6e3f09620e810cd:create

grant select on samqa.entrp_relationship_seq to rl_sam_rw;

