-- liquibase formatted sql
-- changeset SAMQA:1754373938696 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ar_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ar_invoice.sql:null:308c1cdbbeee3319ba181e244091a6f90ce0e95e:create

grant delete on samqa.ar_invoice to rl_sam_rw;

grant insert on samqa.ar_invoice to rl_sam_rw;

grant select on samqa.ar_invoice to rl_sam1_ro;

grant select on samqa.ar_invoice to rl_sam_rw;

grant select on samqa.ar_invoice to rl_sam_ro;

grant select on samqa.ar_invoice to reportdb_ro;

grant update on samqa.ar_invoice to rl_sam_rw;

