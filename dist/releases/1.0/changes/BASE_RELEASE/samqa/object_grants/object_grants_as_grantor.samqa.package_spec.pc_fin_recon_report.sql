-- liquibase formatted sql
-- changeset SAMQA:1754373936195 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_fin_recon_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_fin_recon_report.sql:null:c4d4b5abd00bd6878fcffcb018ba2c6cd3b77602:create

grant execute on samqa.pc_fin_recon_report to rl_sam_ro;

grant execute on samqa.pc_fin_recon_report to rl_sam_rw;

grant execute on samqa.pc_fin_recon_report to rl_sam1_ro;

grant debug on samqa.pc_fin_recon_report to sgali;

grant debug on samqa.pc_fin_recon_report to rl_sam_rw;

grant debug on samqa.pc_fin_recon_report to rl_sam1_ro;

grant debug on samqa.pc_fin_recon_report to rl_sam_ro;

