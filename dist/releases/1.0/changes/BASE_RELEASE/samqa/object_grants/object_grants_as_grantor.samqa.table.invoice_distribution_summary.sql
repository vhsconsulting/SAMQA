-- liquibase formatted sql
-- changeset SAMQA:1754373940865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.invoice_distribution_summary.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.invoice_distribution_summary.sql:null:602426b592bcb8fa5d8edba9bdfbd18218ef9cba:create

grant delete on samqa.invoice_distribution_summary to rl_sam_rw;

grant insert on samqa.invoice_distribution_summary to rl_sam_rw;

grant select on samqa.invoice_distribution_summary to rl_sam1_ro;

grant select on samqa.invoice_distribution_summary to rl_sam_rw;

grant select on samqa.invoice_distribution_summary to rl_sam_ro;

grant update on samqa.invoice_distribution_summary to rl_sam_rw;

