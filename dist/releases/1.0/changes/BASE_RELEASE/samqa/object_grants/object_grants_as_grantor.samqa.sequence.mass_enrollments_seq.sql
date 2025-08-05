-- liquibase formatted sql
-- changeset SAMQA:1754373937960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.mass_enrollments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.mass_enrollments_seq.sql:null:3fbc61e1a3c85100b0b7a62692029d99c5f5d560:create

grant select on samqa.mass_enrollments_seq to rl_sam_rw;

