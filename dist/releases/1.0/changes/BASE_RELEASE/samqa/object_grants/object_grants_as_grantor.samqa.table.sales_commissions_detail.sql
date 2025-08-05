-- liquibase formatted sql
-- changeset SAMQA:1754373941924 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_commissions_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_commissions_detail.sql:null:65ed811cab3acf3c0eed742ba41d339de0f9eb6f:create

grant delete on samqa.sales_commissions_detail to rl_sam_rw;

grant insert on samqa.sales_commissions_detail to rl_sam_rw;

grant select on samqa.sales_commissions_detail to rl_sam1_ro;

grant select on samqa.sales_commissions_detail to rl_sam_ro;

grant select on samqa.sales_commissions_detail to rl_sam_rw;

grant update on samqa.sales_commissions_detail to rl_sam_rw;

