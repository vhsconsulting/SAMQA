-- liquibase formatted sql
-- changeset SAMQA:1754373938119 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.pers_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.pers_seq.sql:null:442f8fd68220ddc3f2577728ea2b11508e1af0b5:create

grant select on samqa.pers_seq to rl_sam_rw;

grant select on samqa.pers_seq to cobra;

