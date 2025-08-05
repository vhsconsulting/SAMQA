-- liquibase formatted sql
-- changeset SAMQA:1754373944107 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_sales_report.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_sales_report.sql:null:f07cca86bc4d2fb71dbc04b8285d5d84d2a98500:create

grant select on samqa.fsa_hra_sales_report to rl_sam1_ro;

grant select on samqa.fsa_hra_sales_report to rl_sam_rw;

grant select on samqa.fsa_hra_sales_report to rl_sam_ro;

