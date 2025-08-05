-- liquibase formatted sql
-- changeset SAMQA:1754373937897 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.letter_pref_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.letter_pref_seq.sql:null:52a092b4625d3d1c4295977b2268b984349b4919:create

grant select on samqa.letter_pref_seq to rl_sam_rw;

