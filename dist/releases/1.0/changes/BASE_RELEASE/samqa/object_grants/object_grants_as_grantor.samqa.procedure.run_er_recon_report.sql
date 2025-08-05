-- liquibase formatted sql
-- changeset SAMQA:1754373937129 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.run_er_recon_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.run_er_recon_report.sql:null:2fb539252de0e6ccedabba3bac6578eeedf6b7ad:create

grant execute on samqa.run_er_recon_report to rl_sam_ro;

grant execute on samqa.run_er_recon_report to rl_sam_rw;

grant execute on samqa.run_er_recon_report to rl_sam1_ro;

grant debug on samqa.run_er_recon_report to rl_sam_rw;

grant debug on samqa.run_er_recon_report to rl_sam1_ro;

