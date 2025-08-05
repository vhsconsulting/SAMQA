-- liquibase formatted sql
-- changeset SAMQA:1754373926085 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.package_spec.pc_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.package_spec.pc_reports.sql:null:ab300f813cc1057e8a483f9aca7b07db03b26848:create

grant execute on newcobra.pc_reports to samqa;

grant debug on newcobra.pc_reports to samqa;

