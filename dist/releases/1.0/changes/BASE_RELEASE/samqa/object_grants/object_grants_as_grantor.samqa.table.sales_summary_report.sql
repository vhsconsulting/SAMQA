-- liquibase formatted sql
-- changeset SAMQA:1754373941959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_summary_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_summary_report.sql:null:2e6b17bf6f9e3df023b650e95826b20b2826b6c2:create

grant delete on samqa.sales_summary_report to rl_sam_rw;

grant insert on samqa.sales_summary_report to rl_sam_rw;

grant select on samqa.sales_summary_report to rl_sam1_ro;

grant select on samqa.sales_summary_report to rl_sam_ro;

grant select on samqa.sales_summary_report to rl_sam_rw;

grant update on samqa.sales_summary_report to rl_sam_rw;

