-- liquibase formatted sql
-- changeset SAMQA:1754373941039 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_enroll_dependant_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_enroll_dependant_external.sql:null:173d6c4331cff4f01822aef7e0fe01e47bba23cd:create

grant select on samqa.mass_enroll_dependant_external to rl_sam1_ro;

grant select on samqa.mass_enroll_dependant_external to rl_sam_ro;

