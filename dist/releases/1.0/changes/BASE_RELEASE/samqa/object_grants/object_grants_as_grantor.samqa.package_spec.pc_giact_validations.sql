-- liquibase formatted sql
-- changeset SAMQA:1754373936216 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_giact_validations.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_giact_validations.sql:null:41becdf95c317822085a5b810565a26c04b78b73:create

grant execute on samqa.pc_giact_validations to rl_sam_ro;

grant debug on samqa.pc_giact_validations to rl_sam_ro;

