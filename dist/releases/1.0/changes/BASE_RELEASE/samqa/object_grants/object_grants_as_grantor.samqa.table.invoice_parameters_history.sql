-- liquibase formatted sql
-- changeset SAMQA:1754373940880 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.invoice_parameters_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.invoice_parameters_history.sql:null:891b458d987cf2e6b90b6944e96728203d86554a:create

grant delete on samqa.invoice_parameters_history to rl_sam_rw;

grant insert on samqa.invoice_parameters_history to rl_sam_rw;

grant select on samqa.invoice_parameters_history to rl_sam_rw;

grant select on samqa.invoice_parameters_history to rl_sam1_ro;

grant select on samqa.invoice_parameters_history to rjoshi;

grant select on samqa.invoice_parameters_history to rl_sam_ro;

grant update on samqa.invoice_parameters_history to rl_sam_rw;

