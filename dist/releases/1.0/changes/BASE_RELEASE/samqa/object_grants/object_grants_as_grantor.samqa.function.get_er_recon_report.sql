-- liquibase formatted sql
-- changeset SAMQA:1754373935296 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_er_recon_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_er_recon_report.sql:null:3afbc434da53ba2642fec9a88e48228911433bb6:create

grant execute on samqa.get_er_recon_report to rl_sam_ro;

