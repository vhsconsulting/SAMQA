-- liquibase formatted sql
-- changeset SAMQA:1754373938711 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_invoice_dist_plans.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_invoice_dist_plans.sql:null:188d4ab61456fb1c586aef22a588ff804d8356a6:create

grant delete on samqa.ar_invoice_dist_plans to rl_sam_rw;

grant insert on samqa.ar_invoice_dist_plans to rl_sam_rw;

grant select on samqa.ar_invoice_dist_plans to rl_sam1_ro;

grant select on samqa.ar_invoice_dist_plans to rl_sam_rw;

grant select on samqa.ar_invoice_dist_plans to rl_sam_ro;

grant update on samqa.ar_invoice_dist_plans to rl_sam_rw;

