-- liquibase formatted sql
-- changeset SAMQA:1754373926065 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.package_spec.pc_cobra_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.package_spec.pc_cobra_notifications.sql:null:f6bef401f38116f667f45ac53877d3fceb74fbbb:create

grant execute on newcobra.pc_cobra_notifications to samqa;

grant debug on newcobra.pc_cobra_notifications to samqa;

