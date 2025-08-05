-- liquibase formatted sql
-- changeset SAMQA:1754373926070 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.package_spec.pc_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.package_spec.pc_enrollments.sql:null:230ca26cd2a7b3daf4179e3eced20d679d3968fe:create

grant execute on newcobra.pc_enrollments to samqa;

grant debug on newcobra.pc_enrollments to samqa;

