-- liquibase formatted sql
-- changeset SAMQA:1754373936208 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_giact_api.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_giact_api.sql:null:1f8bad36d11a373e30e26a601fb007f9ff62c8f6:create

grant execute on samqa.pc_giact_api to public;

grant debug on samqa.pc_giact_api to public;

