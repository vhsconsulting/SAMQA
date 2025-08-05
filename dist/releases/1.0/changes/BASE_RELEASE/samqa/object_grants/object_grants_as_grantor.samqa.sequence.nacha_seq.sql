-- liquibase formatted sql
-- changeset SAMQA:1754373938024 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.nacha_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.nacha_seq.sql:null:4c59398c231349ad29b2bbc22e61e66cd3ea53de:create

grant select on samqa.nacha_seq to rl_sam_rw;

