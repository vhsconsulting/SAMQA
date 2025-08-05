-- liquibase formatted sql
-- changeset SAMQA:1754373942134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.send_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.send_invoice.sql:null:60e27a1a93790f3dbdf02940c7fa2f54c627b3d7:create

grant delete on samqa.send_invoice to rl_sam_rw;

grant insert on samqa.send_invoice to rl_sam_rw;

grant select on samqa.send_invoice to rl_sam1_ro;

grant select on samqa.send_invoice to rl_sam_rw;

grant select on samqa.send_invoice to rl_sam_ro;

grant update on samqa.send_invoice to rl_sam_rw;

