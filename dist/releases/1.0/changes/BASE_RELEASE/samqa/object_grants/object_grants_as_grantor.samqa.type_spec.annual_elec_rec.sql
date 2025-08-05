-- liquibase formatted sql
-- changeset SAMQA:1754373942564 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.annual_elec_rec.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.annual_elec_rec.sql:null:96640701762be905b1c546545c002bb3f41c501a:create

grant execute on samqa.annual_elec_rec to rl_sam1_ro;

grant execute on samqa.annual_elec_rec to rl_sam_ro;

grant execute on samqa.annual_elec_rec to rl_sam_rw;

