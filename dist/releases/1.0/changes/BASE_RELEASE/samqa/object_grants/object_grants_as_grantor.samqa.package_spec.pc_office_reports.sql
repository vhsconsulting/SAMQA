-- liquibase formatted sql
-- changeset SAMQA:1754373936339 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_office_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_office_reports.sql:null:dcbf22533b8ebd2b8950985cb3698effd0c0fbdb:create

grant execute on samqa.pc_office_reports to rl_sam_ro;

grant debug on samqa.pc_office_reports to rl_sam_ro;

