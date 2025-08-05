-- liquibase formatted sql
-- changeset SAMQA:1754373941994 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.salesrep_030421.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.salesrep_030421.sql:null:0b74ffe7ef68e0080fc55ecc574558eaeacfca08:create

grant delete on samqa.salesrep_030421 to rl_sam_rw;

grant insert on samqa.salesrep_030421 to rl_sam_rw;

grant select on samqa.salesrep_030421 to rl_sam1_ro;

grant select on samqa.salesrep_030421 to rl_sam_ro;

grant select on samqa.salesrep_030421 to rl_sam_rw;

grant update on samqa.salesrep_030421 to rl_sam_rw;

