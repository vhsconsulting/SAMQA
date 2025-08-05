-- liquibase formatted sql
-- changeset SAMQA:1754373926079 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.package_spec.pc_premium.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.package_spec.pc_premium.sql:null:b16b2888c591ed2624c6ddd8d6b9b32cb9ee3c03:create

grant execute on newcobra.pc_premium to samqa;

grant debug on newcobra.pc_premium to samqa;

