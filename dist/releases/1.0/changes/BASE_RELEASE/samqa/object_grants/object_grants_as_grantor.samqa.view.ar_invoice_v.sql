-- liquibase formatted sql
-- changeset SAMQA:1754373942911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ar_invoice_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ar_invoice_v.sql:null:46885b29760355621bdb13d8e80264a93bf3c6f7:create

grant select on samqa.ar_invoice_v to rl_sam1_ro;

grant select on samqa.ar_invoice_v to rl_sam_rw;

grant select on samqa.ar_invoice_v to rl_sam_ro;

grant select on samqa.ar_invoice_v to sgali;

