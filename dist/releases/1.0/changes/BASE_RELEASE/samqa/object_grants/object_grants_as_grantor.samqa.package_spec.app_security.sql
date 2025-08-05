-- liquibase formatted sql
-- changeset SAMQA:1754373935684 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.app_security.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.app_security.sql:null:9298765a340446621210ca810a0ee7261416ea23:create

grant execute on samqa.app_security to rl_sam_ro;

grant debug on samqa.app_security to rl_sam_ro;

