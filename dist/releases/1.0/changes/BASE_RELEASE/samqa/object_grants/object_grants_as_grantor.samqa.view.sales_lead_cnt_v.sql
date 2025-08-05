-- liquibase formatted sql
-- changeset SAMQA:1754373945060 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.sales_lead_cnt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.sales_lead_cnt_v.sql:null:ae0e82efeb5eb24046050b3dbdeac6a9da428310:create

grant select on samqa.sales_lead_cnt_v to rl_sam1_ro;

grant select on samqa.sales_lead_cnt_v to rl_sam_ro;

grant select on samqa.sales_lead_cnt_v to rl_sam_rw;

