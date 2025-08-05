-- liquibase formatted sql
-- changeset SAMQA:1754373937817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.fsa_relationship_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.fsa_relationship_seq.sql:null:707b11ea4b9009b77e3ffd03266c0dc37e1e01d8:create

grant select on samqa.fsa_relationship_seq to rl_sam_rw;

