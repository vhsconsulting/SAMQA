-- liquibase formatted sql
-- changeset SAMQA:1754373941892 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_comm_rates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_comm_rates.sql:null:745bd60ac6957687487c0b505d7a75dc9fa275ff:create

grant delete on samqa.sales_comm_rates to rl_sam_rw;

grant insert on samqa.sales_comm_rates to rl_sam_rw;

grant select on samqa.sales_comm_rates to rl_sam_ro;

grant select on samqa.sales_comm_rates to rl_sam1_ro;

grant select on samqa.sales_comm_rates to rl_sam_rw;

grant update on samqa.sales_comm_rates to rl_sam_rw;

