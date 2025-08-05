-- liquibase formatted sql
-- changeset SAMQA:1754373937396 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.benefit_codes_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.benefit_codes_stage_seq.sql:null:24874524d61fda680610f802b7924032fd009141:create

grant select on samqa.benefit_codes_stage_seq to rl_sam_rw;

