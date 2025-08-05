-- liquibase formatted sql
-- changeset SAMQA:1754373941909 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_commission_range.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_commission_range.sql:null:4af0c98fb7df625f7aedf093d7bd46b0cba0ba04:create

grant delete on samqa.sales_commission_range to rl_sam_rw;

grant insert on samqa.sales_commission_range to rl_sam_rw;

grant select on samqa.sales_commission_range to rl_sam1_ro;

grant select on samqa.sales_commission_range to rl_sam_ro;

grant select on samqa.sales_commission_range to rl_sam_rw;

grant update on samqa.sales_commission_range to rl_sam_rw;

