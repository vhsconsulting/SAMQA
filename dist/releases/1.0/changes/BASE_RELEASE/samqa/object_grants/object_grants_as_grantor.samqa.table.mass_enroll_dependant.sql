-- liquibase formatted sql
-- changeset SAMQA:1754373941039 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_enroll_dependant.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_enroll_dependant.sql:null:fd4159699a9f8fc5d55817ff6c5feccd6fe03be8:create

grant delete on samqa.mass_enroll_dependant to rl_sam_rw;

grant insert on samqa.mass_enroll_dependant to rl_sam_rw;

grant select on samqa.mass_enroll_dependant to rl_sam1_ro;

grant select on samqa.mass_enroll_dependant to rl_sam_rw;

grant select on samqa.mass_enroll_dependant to rl_sam_ro;

grant update on samqa.mass_enroll_dependant to rl_sam_rw;

