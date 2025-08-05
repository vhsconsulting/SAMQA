-- liquibase formatted sql
-- changeset SAMQA:1754373941087 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_fsa_ease_enroll_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_fsa_ease_enroll_external.sql:null:e54f1ab653e3615f44bc3f9e8e4932d98cf17356:create

grant select on samqa.mass_fsa_ease_enroll_external to rl_sam1_ro;

grant select on samqa.mass_fsa_ease_enroll_external to rl_sam_ro;

