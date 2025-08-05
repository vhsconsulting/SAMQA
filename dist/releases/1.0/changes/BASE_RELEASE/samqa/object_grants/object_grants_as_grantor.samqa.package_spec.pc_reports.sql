-- liquibase formatted sql
-- changeset SAMQA:1754373936430 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_reports.sql:null:2ccfc3dae463f202f4e102e09ed894f5e2124c1d:create

grant execute on samqa.pc_reports to rl_sam1_ro;

grant execute on samqa.pc_reports to rl_sam_rw;

grant execute on samqa.pc_reports to rl_sam_ro;

grant debug on samqa.pc_reports to rl_sam_ro;

grant debug on samqa.pc_reports to rl_sam1_ro;

grant debug on samqa.pc_reports to rl_sam_rw;

