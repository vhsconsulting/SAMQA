-- liquibase formatted sql
-- changeset SAMQA:1754374140525 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_sbs_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_sbs_migration.sql:null:0f36b2834df8e044ed9a578e62ff302afa372385:create

create or replace package samqa.pc_sbs_migration as
    procedure migrate_sbs_employer;

end;
/

