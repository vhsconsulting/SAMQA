-- liquibase formatted sql
-- changeset SAMQA:1754373940880 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.invoice_parameters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.invoice_parameters.sql:null:8cdc5e03347b71dcb58ac9f0375032f209d3bbec:create

grant delete on samqa.invoice_parameters to rl_sam_rw;

grant insert on samqa.invoice_parameters to rl_sam_rw;

grant select on samqa.invoice_parameters to rl_sam1_ro;

grant select on samqa.invoice_parameters to rl_sam_rw;

grant select on samqa.invoice_parameters to rl_sam_ro;

grant update on samqa.invoice_parameters to rl_sam_rw;

