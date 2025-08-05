-- liquibase formatted sql
-- changeset SAMQA:1754373941917 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_commission_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_commission_report.sql:null:29e06ad9f16427e1da275401994580a7b7fd1928:create

grant delete on samqa.sales_commission_report to rl_sam_rw;

grant insert on samqa.sales_commission_report to rl_sam_rw;

grant select on samqa.sales_commission_report to rl_sam1_ro;

grant select on samqa.sales_commission_report to rl_sam_ro;

grant select on samqa.sales_commission_report to rl_sam_rw;

grant update on samqa.sales_commission_report to rl_sam_rw;

