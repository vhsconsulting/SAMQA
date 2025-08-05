-- liquibase formatted sql
-- changeset SAMQA:1754373944466 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.invoice_detail_report_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.invoice_detail_report_v.sql:null:7ea4adaf7e4684a2e1136fc9902975b7dac2c211:create

grant select on samqa.invoice_detail_report_v to rl_sam1_ro;

grant select on samqa.invoice_detail_report_v to rl_sam_rw;

grant select on samqa.invoice_detail_report_v to rl_sam_ro;

grant select on samqa.invoice_detail_report_v to sgali;

